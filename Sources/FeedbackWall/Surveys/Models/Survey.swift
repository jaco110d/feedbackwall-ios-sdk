import Foundation

/// Represents a survey returned from the FeedbackWall backend.
public struct Survey: Decodable {
    /// Unique identifier for the survey.
    public let id: String
    
    /// The survey title displayed to the user.
    public let title: String
    
    /// Optional description text shown below the title.
    public let description: String?
    
    /// The list of questions in this survey.
    public let questions: [SurveyQuestion]
    
    /// Optional theme customization for the survey UI.
    public let theme: SurveyTheme?
}

/// Represents a single question within a survey.
public struct SurveyQuestion: Decodable {
    /// Unique identifier for the question.
    public let id: String
    
    /// The type of question (determines UI rendering).
    public let type: SurveyQuestionType
    
    /// The question text displayed to the user.
    public let text: String
    
    /// Available options for multiple choice questions.
    public let options: [String]?
    
    /// Placeholder text for text input questions.
    public let placeholder: String?
}

/// The supported question types in the FeedbackWall SDK.
public enum SurveyQuestionType: String, Decodable {
    case multipleChoice = "multiple_choice"
    case rating = "rating"
    case text = "text"
}

/// Theme customization options for the survey UI.
public struct SurveyTheme: Decodable {
    /// Primary color in hex format (e.g., "#FF3366").
    public let primaryColorHex: String?
    
    /// Corner radius for cards and buttons.
    public let cornerRadius: Double?
}

