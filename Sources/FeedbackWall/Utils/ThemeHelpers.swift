import UIKit

// MARK: - Theme Defaults

/// Default values for survey theme properties.
/// These values are used when theme fields are null or missing.
enum SurveyThemeDefaults {
    // Layout
    static let layout: String = "popup"
    
    // Colors
    static let primaryColorHex: String = "#C2662D"
    static let backgroundColorHex: String = "#FFFBF7"
    static let textColorHex: String = "#1A1A1A"
    static let buttonTextColorHex: String = "#FFFFFF"
    static let optionSelectedBackgroundHex: String = "#C2662D"
    static let optionSelectedTextHex: String = "#FFFFFF"
    
    // Corner Radii
    static let cornerRadius: CGFloat = 16
    static let buttonCornerRadius: CGFloat = 10
    
    // Typography
    static let fontFamily: String = "system"
    static let fontSize: CGFloat = 14
    static let textAlign: String = "left"
    static let titleFontSize: CGFloat = 18
    static let bodyFontSize: CGFloat = 14
    static let buttonFontSize: CGFloat = 15
    
    // Spacing
    static let contentPadding: CGFloat = 20
    
    // Display Settings
    static let delaySeconds: Int = 0
    static let showCloseButton: Bool = true
    static let entranceAnimation: String = "slideFromBottom"
    static let animationSpeed: String = "normal"
}

// MARK: - UIColor Hex Extension

extension UIColor {
    
    /// Creates a UIColor from a hex string.
    /// Supports 6-character (RGB) and 8-character (RGBA) hex strings.
    /// - Parameter hex: A hex string like "#FF3366" or "FF3366".
    /// - Returns: A UIColor if parsing succeeds, nil otherwise.
    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        
        let length = hexSanitized.count
        guard length == 6 || length == 8 else { return nil }
        
        if length == 6 {
            self.init(
                red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
                green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
                blue: CGFloat(rgb & 0x0000FF) / 255.0,
                alpha: 1.0
            )
        } else {
            self.init(
                red: CGFloat((rgb & 0xFF000000) >> 24) / 255.0,
                green: CGFloat((rgb & 0x00FF0000) >> 16) / 255.0,
                blue: CGFloat((rgb & 0x0000FF00) >> 8) / 255.0,
                alpha: CGFloat(rgb & 0x000000FF) / 255.0
            )
        }
    }
    
    /// Determines if the color is dark based on luminance.
    /// Uses the W3C formula for relative luminance.
    var isDark: Bool {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        guard getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return false
        }
        
        // W3C luminance formula
        let luminance = 0.299 * red + 0.587 * green + 0.114 * blue
        return luminance < 0.5
    }
}

// MARK: - Entrance Animation

/// Entrance animation types for survey presentation.
enum EntranceAnimation: String {
    case slideFromBottom
    case slideFromTop
    case slideFromLeft
    case slideFromRight
    case fadeIn
    case scale
    case none
    
    /// Creates an EntranceAnimation from a string, with default fallback.
    init(from string: String?) {
        if let string = string, let animation = EntranceAnimation(rawValue: string) {
            self = animation
        } else {
            self = .slideFromBottom
        }
    }
}

// MARK: - Animation Speed

/// Animation speed options for survey transitions.
enum AnimationSpeed: String {
    case fast
    case normal
    case slow
    
    /// The duration in seconds for this animation speed.
    var duration: TimeInterval {
        switch self {
        case .fast: return 0.5
        case .normal: return 0.75
        case .slow: return 1.0
        }
    }
    
    /// Creates an AnimationSpeed from a string, with default fallback.
    init(from string: String?) {
        if let string = string, let speed = AnimationSpeed(rawValue: string) {
            self = speed
        } else {
            self = .normal
        }
    }
}

// MARK: - Theme Font Factory

/// Factory for creating themed fonts based on SurveyTheme configuration.
/// Provides a centralized way to generate fonts with the correct family and size.
enum ThemeFontFactory {
    
    // MARK: - Font Creation
    
    /// Creates a title font based on the theme configuration.
    /// - Parameters:
    ///   - theme: The survey theme (optional).
    ///   - weight: The font weight. Defaults to `.bold`.
    /// - Returns: A configured UIFont.
    static func titleFont(from theme: SurveyTheme?, weight: UIFont.Weight = .bold) -> UIFont {
        let size = validatedSize(theme?.titleFontSize, default: SurveyThemeDefaults.titleFontSize)
        return makeFont(family: theme?.fontFamily, size: size, weight: weight)
    }
    
    /// Creates a body font based on the theme configuration.
    /// Used for description labels, question text, and answer options.
    /// - Parameters:
    ///   - theme: The survey theme (optional).
    ///   - weight: The font weight. Defaults to `.regular`.
    /// - Returns: A configured UIFont.
    static func bodyFont(from theme: SurveyTheme?, weight: UIFont.Weight = .regular) -> UIFont {
        let size = validatedSize(theme?.bodyFontSize, default: SurveyThemeDefaults.bodyFontSize)
        return makeFont(family: theme?.fontFamily, size: size, weight: weight)
    }
    
    /// Creates a base font (used for options) based on theme configuration.
    /// - Parameters:
    ///   - theme: The survey theme (optional).
    ///   - weight: The font weight. Defaults to `.regular`.
    /// - Returns: A configured UIFont.
    static func baseFont(from theme: SurveyTheme?, weight: UIFont.Weight = .regular) -> UIFont {
        let size = validatedSize(theme?.fontSize, default: SurveyThemeDefaults.fontSize)
        return makeFont(family: theme?.fontFamily, size: size, weight: weight)
    }
    
    /// Creates a button font based on the theme configuration.
    /// - Parameters:
    ///   - theme: The survey theme (optional).
    ///   - weight: The font weight. Defaults to `.semibold`.
    /// - Returns: A configured UIFont.
    static func buttonFont(from theme: SurveyTheme?, weight: UIFont.Weight = .semibold) -> UIFont {
        let size = validatedSize(theme?.buttonFontSize, default: SurveyThemeDefaults.buttonFontSize)
        return makeFont(family: theme?.fontFamily, size: size, weight: weight)
    }
    
    /// Creates a question text font based on the theme configuration.
    /// Uses baseFontSize * 1.15 with regular weight (matches web preview).
    /// - Parameter theme: The survey theme (optional).
    /// - Returns: A configured UIFont.
    static func questionFont(from theme: SurveyTheme?) -> UIFont {
        let baseSize = validatedSize(theme?.fontSize, default: SurveyThemeDefaults.fontSize)
        let size = baseSize * 1.15  // Question text is 1.15x base size
        return makeFont(family: theme?.fontFamily, size: size, weight: .regular)
    }
    
    /// Creates a header label font ("Quick question").
    /// Uses 16pt with semibold weight for better visibility.
    /// - Parameter theme: The survey theme (optional).
    /// - Returns: A configured UIFont.
    static func headerLabelFont(from theme: SurveyTheme?) -> UIFont {
        return makeFont(family: theme?.fontFamily, size: 16, weight: .semibold)
    }
    
    // MARK: - Private Helpers
    
    /// Validates and returns a font size, falling back to default if invalid.
    /// - Parameters:
    ///   - size: The size value from theme (optional).
    ///   - defaultSize: The default size to use if value is missing or invalid.
    /// - Returns: A valid CGFloat size.
    private static func validatedSize(_ size: Double?, default defaultSize: CGFloat) -> CGFloat {
        guard let size = size, size > 0 else {
            return defaultSize
        }
        // Clamp to reasonable bounds (8pt - 100pt)
        return CGFloat(max(8, min(100, size)))
    }
    
    /// Creates a font with the specified family, size, and weight.
    /// - Parameters:
    ///   - family: The font family string (optional).
    ///   - size: The font size.
    ///   - weight: The font weight.
    /// - Returns: A configured UIFont.
    private static func makeFont(family: String?, size: CGFloat, weight: UIFont.Weight) -> UIFont {
        let baseFont = UIFont.systemFont(ofSize: size, weight: weight)
        
        guard let family = family?.lowercased(), !family.isEmpty else {
            return baseFont
        }
        
        switch family {
        case "system":
            return baseFont
            
        case "rounded":
            // Use rounded system font design (SF Rounded)
            if let descriptor = baseFont.fontDescriptor.withDesign(.rounded) {
                return UIFont(descriptor: descriptor, size: size)
            }
            Logger.warning("Failed to create rounded font, using system font")
            return baseFont
            
        case "serif":
            // Use serif system font design (New York)
            if let descriptor = baseFont.fontDescriptor.withDesign(.serif) {
                return UIFont(descriptor: descriptor, size: size)
            }
            Logger.warning("Failed to create serif font, using system font")
            return baseFont
            
        case "mono", "monospaced":
            // Use monospaced system font (SF Mono)
            return UIFont.monospacedSystemFont(ofSize: size, weight: weight)
            
        case "casual":
            // Use a casual font - fallback to rounded if Marker Felt unavailable
            if let markerFelt = UIFont(name: "MarkerFelt-Wide", size: size) {
                return markerFelt
            }
            // Fallback to rounded
            if let descriptor = baseFont.fontDescriptor.withDesign(.rounded) {
                return UIFont(descriptor: descriptor, size: size)
            }
            Logger.warning("Failed to create casual font, using system font")
            return baseFont
            
        default:
            Logger.warning("Unknown font family '\(family)', using system font")
            return baseFont
        }
    }
}

// MARK: - Theme Color Resolver

/// Resolves colors from SurveyTheme with safe fallbacks.
/// Centralizes color resolution logic and provides sensible defaults.
enum ThemeColorResolver {
    
    // MARK: - Color Resolution
    
    /// Resolves the primary color from theme.
    /// - Parameter theme: The survey theme (optional).
    /// - Returns: The resolved primary UIColor.
    static func primaryColor(from theme: SurveyTheme?) -> UIColor {
        guard let hex = theme?.primaryColorHex else {
            return UIColor(hex: SurveyThemeDefaults.primaryColorHex)!
        }
        
        guard let color = UIColor(hex: hex) else {
            Logger.warning("Failed to parse primaryColorHex '\(hex)', using default")
            return UIColor(hex: SurveyThemeDefaults.primaryColorHex)!
        }
        
        return color
    }
    
    /// Resolves the background color from theme.
    /// - Parameter theme: The survey theme (optional).
    /// - Returns: The resolved background UIColor.
    static func backgroundColor(from theme: SurveyTheme?) -> UIColor {
        guard let hex = theme?.backgroundColorHex else {
            return UIColor(hex: SurveyThemeDefaults.backgroundColorHex)!
        }
        
        guard let color = UIColor(hex: hex) else {
            Logger.warning("Failed to parse backgroundColorHex '\(hex)', using default")
            return UIColor(hex: SurveyThemeDefaults.backgroundColorHex)!
        }
        
        return color
    }
    
    /// Resolves the text color from theme.
    /// - Parameter theme: The survey theme (optional).
    /// - Returns: The resolved text UIColor.
    static func textColor(from theme: SurveyTheme?) -> UIColor {
        guard let hex = theme?.textColorHex else {
            return UIColor(hex: SurveyThemeDefaults.textColorHex)!
        }
        
        guard let color = UIColor(hex: hex) else {
            Logger.warning("Failed to parse textColorHex '\(hex)', using default")
            return UIColor(hex: SurveyThemeDefaults.textColorHex)!
        }
        
        return color
    }
    
    /// Resolves the button text color from theme.
    /// - Parameter theme: The survey theme (optional).
    /// - Returns: The resolved button text UIColor.
    static func buttonTextColor(from theme: SurveyTheme?) -> UIColor {
        guard let hex = theme?.buttonTextColorHex else {
            return UIColor(hex: SurveyThemeDefaults.buttonTextColorHex)!
        }
        
        guard let color = UIColor(hex: hex) else {
            Logger.warning("Failed to parse buttonTextColorHex '\(hex)', using default")
            return UIColor(hex: SurveyThemeDefaults.buttonTextColorHex)!
        }
        
        return color
    }
    
    /// Resolves the selected option background color from theme.
    /// Returns primaryColor with 20% opacity (NOT solid color).
    /// - Parameter theme: The survey theme (optional).
    /// - Returns: The resolved selected option background UIColor.
    static func optionSelectedBackground(from theme: SurveyTheme?) -> UIColor {
        // Per web spec: selected background is primaryColor @ 20% opacity
        return primaryColor(from: theme).withAlphaComponent(0.2)
    }
    
    /// Resolves the selected option text color from theme.
    /// Returns textColor (NOT white) - text stays the same when selected.
    /// - Parameter theme: The survey theme (optional).
    /// - Returns: The resolved selected option text UIColor.
    static func optionSelectedText(from theme: SurveyTheme?) -> UIColor {
        // Per web spec: text color stays the same when selected (NOT white)
        return textColor(from: theme)
    }
    
    /// Returns the selected radio button border/fill color.
    /// - Parameter theme: The survey theme (optional).
    /// - Returns: The primary UIColor for selected radio buttons.
    static func radioSelectedColor(from theme: SurveyTheme?) -> UIColor {
        return primaryColor(from: theme)
    }
    
    /// Returns the unselected option background color.
    /// Derived from text color with 8% opacity.
    /// - Parameter theme: The survey theme (optional).
    /// - Returns: The unselected option background UIColor.
    static func optionUnselectedBackground(from theme: SurveyTheme?) -> UIColor {
        return textColor(from: theme).withAlphaComponent(0.08)
    }
    
    /// Returns the unselected option border color.
    /// Derived from text color with 30% opacity.
    /// - Parameter theme: The survey theme (optional).
    /// - Returns: The unselected option border UIColor.
    static func optionUnselectedBorder(from theme: SurveyTheme?) -> UIColor {
        return textColor(from: theme).withAlphaComponent(0.30)
    }
    
    /// Returns the label color (e.g., "Quick question" label).
    /// Derived from text color with 60% opacity.
    /// - Parameter theme: The survey theme (optional).
    /// - Returns: The label UIColor.
    static func labelColor(from theme: SurveyTheme?) -> UIColor {
        return textColor(from: theme).withAlphaComponent(0.60)
    }
    
    /// Returns the close button color.
    /// Derived from text color with 60% opacity.
    /// - Parameter theme: The survey theme (optional).
    /// - Returns: The close button UIColor.
    static func closeButtonColor(from theme: SurveyTheme?) -> UIColor {
        return textColor(from: theme).withAlphaComponent(0.60)
    }
}

// MARK: - Corner Radius Resolver

/// Resolves corner radius values from SurveyTheme with safe fallbacks.
enum ThemeCornerRadiusResolver {
    
    // MARK: - Resolution
    
    /// Resolves the card corner radius from theme.
    /// Returns 0 for fullscreen layout.
    /// - Parameters:
    ///   - theme: The survey theme (optional).
    ///   - layout: The layout mode (optional, derived from theme if not provided).
    /// - Returns: The resolved corner radius.
    static func cardCornerRadius(from theme: SurveyTheme?, layout: String? = nil) -> CGFloat {
        let layoutMode = layout ?? theme?.layout ?? SurveyThemeDefaults.layout
        
        // Fullscreen layout ignores corner radius
        if layoutMode == "fullscreen" {
            return 0
        }
        
        guard let radius = theme?.cornerRadius, radius >= 0 else {
            return SurveyThemeDefaults.cornerRadius
        }
        // Clamp to reasonable bounds (0 - 50)
        return CGFloat(min(50, radius))
    }
    
    /// Resolves the button corner radius from theme.
    /// - Parameter theme: The survey theme (optional).
    /// - Returns: The resolved corner radius.
    static func buttonCornerRadius(from theme: SurveyTheme?) -> CGFloat {
        guard let radius = theme?.buttonCornerRadius, radius >= 0 else {
            return SurveyThemeDefaults.buttonCornerRadius
        }
        // Clamp to reasonable bounds (0 - 50)
        return CGFloat(min(50, radius))
    }
}

// MARK: - Layout Resolver

/// Resolves layout-related values from SurveyTheme.
enum ThemeLayoutResolver {
    
    /// Returns whether the survey should use fullscreen layout.
    /// - Parameter theme: The survey theme (optional).
    /// - Returns: True if fullscreen, false for popup.
    static func isFullscreen(from theme: SurveyTheme?) -> Bool {
        let layout = theme?.layout ?? SurveyThemeDefaults.layout
        return layout == "fullscreen"
    }
    
    /// Returns the content padding from theme.
    /// - Parameter theme: The survey theme (optional).
    /// - Returns: The content padding in points.
    static func contentPadding(from theme: SurveyTheme?) -> CGFloat {
        guard let padding = theme?.contentPadding, padding >= 0 else {
            return SurveyThemeDefaults.contentPadding
        }
        // Clamp to reasonable bounds (0 - 60)
        return CGFloat(min(60, padding))
    }
    
    /// Returns the text alignment from theme.
    /// - Parameter theme: The survey theme (optional).
    /// - Returns: The NSTextAlignment value.
    static func textAlignment(from theme: SurveyTheme?) -> NSTextAlignment {
        let align = theme?.textAlign ?? SurveyThemeDefaults.textAlign
        switch align {
        case "center":
            return .center
        default:
            return .natural
        }
    }
}

// MARK: - Display Settings Resolver

/// Resolves display settings from SurveyTheme.
enum ThemeDisplayResolver {
    
    /// Returns the delay in seconds before showing the survey.
    /// - Parameter theme: The survey theme (optional).
    /// - Returns: The delay in seconds (0-30).
    static func delaySeconds(from theme: SurveyTheme?) -> Int {
        guard let delay = theme?.delaySeconds, delay >= 0 else {
            return SurveyThemeDefaults.delaySeconds
        }
        // Clamp to 0-30 seconds
        return min(30, delay)
    }
    
    /// Returns whether the close button should be shown.
    /// - Parameter theme: The survey theme (optional).
    /// - Returns: True if close button should be visible.
    static func showCloseButton(from theme: SurveyTheme?) -> Bool {
        return theme?.showCloseButton ?? SurveyThemeDefaults.showCloseButton
    }
    
    /// Returns the entrance animation type.
    /// - Parameter theme: The survey theme (optional).
    /// - Returns: The EntranceAnimation value.
    static func entranceAnimation(from theme: SurveyTheme?) -> EntranceAnimation {
        return EntranceAnimation(from: theme?.entranceAnimation)
    }
    
    /// Returns the animation speed.
    /// - Parameter theme: The survey theme (optional).
    /// - Returns: The AnimationSpeed value.
    static func animationSpeed(from theme: SurveyTheme?) -> AnimationSpeed {
        return AnimationSpeed(from: theme?.animationSpeed)
    }
}
