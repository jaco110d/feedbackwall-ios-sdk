import Foundation

/// Model for submitting survey responses to the backend.
struct SurveyResponseSubmission: Encodable {
    /// The ID of the survey being responded to.
    let surveyId: String
    
    /// The user ID (either identified user or anonymous device ID).
    let userId: String
    
    /// The trigger that initiated this survey.
    let trigger: String
    
    /// The list of answers to survey questions.
    let answers: [SurveyAnswer]
    
    /// Metadata about the device and app.
    let metadata: SurveyResponseMetadata
    
    /// Survey version at time of response - used for versioning support.
    /// Optional since older surveys may not have a version number yet.
    let surveyVersion: Int?
}

/// A single answer to a survey question.
struct SurveyAnswer: Encodable {
    /// The ID of the question being answered.
    let questionId: String
    
    /// The answer value (could be text, selected option, or rating).
    let value: String
}

/// Metadata included with survey response submissions.
struct SurveyResponseMetadata: Encodable {
    /// The app version.
    let appVersion: String
    
    /// The platform (always "iOS" for this SDK).
    let platform: String
    
    /// The device locale.
    let deviceLocale: String
}

/// Response from the survey submission endpoint.
struct SurveySubmissionResponse: Decodable {
    /// Status of the submission (e.g., "ok").
    let status: String
}

// MARK: - Survey Impression

/// Model for recording a survey impression (when survey is shown to user).
struct SurveyImpressionRequest: Encodable {
    /// The ID of the survey being shown.
    let surveyId: String
    
    /// The user ID (either identified user or anonymous device ID).
    let userId: String
    
    /// The action type - always "shown" when recording an impression.
    let action: String
}

/// Response from the survey impression endpoint.
struct SurveyImpressionResponse: Decodable {
    /// Status of the impression recording (e.g., "ok").
    let status: String
}

