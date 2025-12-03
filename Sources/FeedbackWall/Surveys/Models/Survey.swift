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
    
    /// Version number - increments when survey is edited after receiving responses.
    /// Optional since older surveys may not have a version number yet.
    public let version: Int?
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
    
    // MARK: - Layout Properties
    
    /// Layout mode: "popup" (centered card with overlay) or "fullscreen".
    public let layout: String?
    
    // MARK: - Color Properties
    
    /// Primary color in hex format (e.g., "#C2662D").
    /// Used for submit button background and active elements.
    public let primaryColorHex: String?
    
    /// Background color for the survey card in hex format.
    public let backgroundColorHex: String?
    
    /// Text color for labels (title, description, question text) in hex format.
    public let textColorHex: String?
    
    /// Button text color in hex format.
    public let buttonTextColorHex: String?
    
    /// Background color for selected multiple choice options.
    public let optionSelectedBackgroundHex: String?
    
    /// Text color for selected multiple choice options.
    public let optionSelectedTextHex: String?
    
    // MARK: - Corner Radius Properties
    
    /// Corner radius for the main survey card (only used for layout: "popup").
    public let cornerRadius: Double?
    
    /// Corner radius for buttons.
    public let buttonCornerRadius: Double?
    
    // MARK: - Typography Properties
    
    /// Font family: "system", "rounded", "serif", "mono", "casual".
    public let fontFamily: String?
    
    /// Base font size (used for options, body text).
    public let fontSize: Double?
    
    /// Text alignment: "left" or "center".
    public let textAlign: String?
    
    /// Font size for the title/question text.
    public let titleFontSize: Double?
    
    /// Font size for description and labels.
    public let bodyFontSize: Double?
    
    /// Font size for button titles.
    public let buttonFontSize: Double?
    
    // MARK: - Spacing Properties
    
    /// Content padding inside the survey card (all sides).
    public let contentPadding: Double?
    
    // MARK: - Display Settings
    
    /// Delay in seconds before showing the survey (0-30).
    public let delaySeconds: Int?
    
    /// Whether to show the close button. If false, user must complete the survey.
    public let showCloseButton: Bool?
    
    /// Entrance animation type.
    /// Supported: "slideFromBottom", "slideFromTop", "slideFromLeft", "slideFromRight", "fadeIn", "scale", "none".
    public let entranceAnimation: String?
    
    /// Animation speed: "fast" (0.5s), "normal" (0.75s), "slow" (1.0s).
    public let animationSpeed: String?
}
