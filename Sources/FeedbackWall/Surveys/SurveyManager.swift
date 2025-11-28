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
            if let survey = await checkTrigger(trigger) {
                await showSurvey(survey, trigger: trigger)
            }
        }
    }
    
    /// Checks if a survey should be shown for the given trigger.
    /// - Parameter trigger: The trigger identifier (e.g., "onboarding_completed").
    /// - Returns: The Survey if one should be shown, otherwise nil.
    func checkTrigger(_ trigger: String) async -> Survey? {
        guard let config = FeedbackWall.currentConfig else {
            Logger.warning("FeedbackWall not configured. Call configure() first.")
            return nil
        }
        
        let request = TriggerCheckRequest(
            trigger: trigger,
            userId: UserSession.shared.userId,
            traits: UserSession.shared.traits?.mapValues { AnyCodable($0) },
            appVersion: config.appVersion,
            platform: config.platform,
            deviceLocale: config.deviceLocale
        )
        
        do {
            let response: TriggerCheckResponse = try await NetworkClient.shared.post(
                "/api/sdk/triggers/check",
                body: request
            )
            
            if response.show, let survey = response.survey {
                Logger.info("Survey available for trigger: \(trigger)")
                return survey
            } else {
                Logger.debug("No survey to show for trigger: \(trigger)")
                return nil
            }
        } catch {
            // Fail silently as per PRD - no crash, no modal, only log
            Logger.error("Failed to check trigger: \(error.localizedDescription)")
            return nil
        }
    }
    
    /// Submits survey responses to the backend.
    /// - Parameters:
    ///   - surveyId: The ID of the survey being responded to.
    ///   - userId: The user ID (identified or anonymous).
    ///   - trigger: The trigger that initiated the survey.
    ///   - answers: The user's answers.
    ///   - metadata: Device and app metadata.
    ///   - surveyVersion: The survey version at time of response (optional).
    func submitResponses(
        surveyId: String,
        userId: String,
        trigger: String,
        answers: [SurveyAnswer],
        metadata: SurveyResponseMetadata,
        surveyVersion: Int? = nil
    ) async {
        let submission = SurveyResponseSubmission(
            surveyId: surveyId,
            userId: userId,
            trigger: trigger,
            answers: answers,
            metadata: metadata,
            surveyVersion: surveyVersion
        )
        
        do {
            let _: SurveySubmissionResponse = try await NetworkClient.shared.post(
                "/api/sdk/responses",
                body: submission
            )
            Logger.info("Survey response submitted successfully")
        } catch {
            // Fail silently - modal closes regardless
            Logger.error("Failed to submit survey response: \(error.localizedDescription)")
        }
    }
    
    /// Submits survey responses to the backend (convenience method).
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
        
        let metadata = SurveyResponseMetadata(
            appVersion: config.appVersion,
            platform: config.platform,
            deviceLocale: config.deviceLocale
        )
        
        await submitResponses(
            surveyId: survey.id,
            userId: UserSession.shared.userId,
            trigger: trigger,
            answers: answers,
            metadata: metadata,
            surveyVersion: survey.version
        )
    }
    
    // MARK: - Private Methods
    
    @MainActor
    private func showSurvey(_ survey: Survey, trigger: String) {
        // Apply delay if configured
        let delaySeconds = ThemeDisplayResolver.delaySeconds(from: survey.theme)
        
        if delaySeconds > 0 {
            Logger.debug("Delaying survey presentation by \(delaySeconds) seconds")
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: UInt64(delaySeconds) * 1_000_000_000)
                presentSurvey(survey, trigger: trigger)
            }
        } else {
            presentSurvey(survey, trigger: trigger)
        }
    }
    
    @MainActor
    private func presentSurvey(_ survey: Survey, trigger: String) {
        guard let topViewController = TopViewControllerFinder.find() else {
            Logger.error("Could not find top view controller to present survey")
            return
        }
        
        // Double-check we're not already showing a survey (in case of race condition with delay)
        guard !isShowingSurvey else {
            Logger.debug("Already showing a survey, skipping delayed presentation")
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
        
        topViewController.present(surveyVC, animated: false) {
            // Trigger entrance animation after presentation
            surveyVC.performEntranceAnimation()
        }
        Logger.info("Presented survey: \(survey.id)")
    }
}
