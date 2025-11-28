import UIKit

/// Manages survey presentation logic including trigger checking and UI display.
final class SurveyManager {
    
    // MARK: - Singleton
    
    static let shared = SurveyManager()
    
    // MARK: - Properties
    
    private var isShowingSurvey = false
    private var currentTrigger: String?
    
    // MARK: - Initialization
    
    private init() {}
    
    // MARK: - Public Methods
    
    /// Handles a trigger event by checking with the backend and potentially showing a survey.
    /// - Parameter trigger: The trigger identifier.
    func handle(trigger: String) {
        Logger.debug("Handling trigger: \(trigger)")
        
        // Prevent multiple simultaneous surveys
        guard !isShowingSurvey else {
            Logger.debug("Already showing a survey, ignoring trigger: \(trigger)")
            return
        }
        
        currentTrigger = trigger
        
        Task {
            await checkAndShowSurvey(for: trigger)
        }
    }
    
    // MARK: - Private Methods
    
    private func checkAndShowSurvey(for trigger: String) async {
        guard let config = FeedbackWall.currentConfig else {
            Logger.warning("FeedbackWall not configured. Call configure() first.")
            return
        }
        
        let request = TriggerCheckRequest(
            trigger: trigger,
            userId: UserSession.shared.userId,
            traits: UserSession.shared.traits?.mapValues { AnyCodable($0) },
            appVersion: config.appVersion,
            platform: config.platform,
            deviceLocale: config.deviceLocale
        )
        
        let result: Result<TriggerCheckResponse, NetworkClient.NetworkError> = await NetworkClient.shared.post(
            endpoint: "/sdk/triggers/check",
            body: request
        )
        
        switch result {
        case .success(let response):
            if response.show, let survey = response.survey {
                Logger.info("Survey available for trigger: \(trigger)")
                await showSurvey(survey, trigger: trigger)
            } else {
                Logger.debug("No survey to show for trigger: \(trigger)")
            }
            
        case .failure(let error):
            // Fail silently as per PRD - no crash, no modal, only log
            Logger.error("Failed to check trigger: \(error)")
        }
    }
    
    @MainActor
    private func showSurvey(_ survey: Survey, trigger: String) {
        guard let topViewController = TopViewControllerFinder.find() else {
            Logger.error("Could not find top view controller to present survey")
            return
        }
        
        isShowingSurvey = true
        
        let surveyVC = FeedbackWallViewController(
            survey: survey,
            trigger: trigger,
            onDismiss: { [weak self] in
                self?.isShowingSurvey = false
                self?.currentTrigger = nil
            }
        )
        
        surveyVC.modalPresentationStyle = .overFullScreen
        surveyVC.modalTransitionStyle = .crossDissolve
        
        topViewController.present(surveyVC, animated: true)
        Logger.info("Presented survey: \(survey.id)")
    }
    
    /// Submits survey responses to the backend.
    /// - Parameters:
    ///   - survey: The survey being responded to.
    ///   - trigger: The trigger that initiated the survey.
    ///   - answers: The user's answers.
    func submitResponse(
        for survey: Survey,
        trigger: String,
        answers: [SurveyAnswer]
    ) async {
        guard let config = FeedbackWall.currentConfig else {
            Logger.warning("FeedbackWall not configured. Cannot submit response.")
            return
        }
        
        let submission = SurveyResponseSubmission(
            surveyId: survey.id,
            userId: UserSession.shared.userId,
            trigger: trigger,
            answers: answers,
            metadata: SurveyResponseMetadata(
                appVersion: config.appVersion,
                platform: config.platform,
                deviceLocale: config.deviceLocale
            )
        )
        
        let result: Result<SurveySubmissionResponse, NetworkClient.NetworkError> = await NetworkClient.shared.post(
            endpoint: "/sdk/responses",
            body: submission
        )
        
        switch result {
        case .success:
            Logger.info("Survey response submitted successfully")
        case .failure(let error):
            // Fail silently - modal closes regardless
            Logger.error("Failed to submit survey response: \(error)")
        }
    }
}

