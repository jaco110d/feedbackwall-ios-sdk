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
/// All properties are optional and fall back to sensible defaults when missing.
public struct SurveyTheme: Decodable {
    
    // MARK: - Color Properties
    
    /// Primary color in hex format (e.g., "#FF3366").
    /// Used for primary button backgrounds and selected states.
    public let primaryColorHex: String?
    
    /// Background color for the survey card in hex format.
    public let backgroundColorHex: String?
    
    /// Text color for labels (title, description, question text) in hex format.
    public let textColorHex: String?
    
    /// Button text color in hex format.
    /// Falls back to white when primary color is dark.
    public let buttonTextColorHex: String?
    
    // MARK: - Corner Radius Properties
    
    /// Corner radius for the main survey card.
    public let cornerRadius: Double?
    
    /// Corner radius for buttons.
    /// Falls back to existing design if not provided.
    public let buttonCornerRadius: Double?
    
    // MARK: - Typography Properties
    
    /// Font family for the survey UI.
    /// Supported values: "system", "rounded", "serif", "monospaced".
    /// Falls back to system font if not provided or unrecognized.
    public let fontFamily: String?
    
    /// Font size for the main title label.
    public let titleFontSize: Double?
    
    /// Font size for description, question text, and answer text.
    public let bodyFontSize: Double?
    
    /// Font size for button titles.
    public let buttonFontSize: Double?
}

