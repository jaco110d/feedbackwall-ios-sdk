import UIKit

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

// MARK: - Theme Font Factory

/// Factory for creating themed fonts based on SurveyTheme configuration.
/// Provides a centralized way to generate fonts with the correct family and size.
enum ThemeFontFactory {
    
    // MARK: - Default Sizes
    
    /// Default font size for titles.
    static let defaultTitleSize: CGFloat = 22.0
    
    /// Default font size for body text (description, questions, answers).
    static let defaultBodySize: CGFloat = 16.0
    
    /// Default font size for button titles.
    static let defaultButtonSize: CGFloat = 17.0
    
    // MARK: - Font Creation
    
    /// Creates a title font based on the theme configuration.
    /// - Parameters:
    ///   - theme: The survey theme (optional).
    ///   - weight: The font weight. Defaults to `.bold`.
    /// - Returns: A configured UIFont.
    static func titleFont(from theme: SurveyTheme?, weight: UIFont.Weight = .bold) -> UIFont {
        let size = validatedSize(theme?.titleFontSize, default: defaultTitleSize)
        return makeFont(family: theme?.fontFamily, size: size, weight: weight)
    }
    
    /// Creates a body font based on the theme configuration.
    /// Used for description labels, question text, and answer options.
    /// - Parameters:
    ///   - theme: The survey theme (optional).
    ///   - weight: The font weight. Defaults to `.regular`.
    /// - Returns: A configured UIFont.
    static func bodyFont(from theme: SurveyTheme?, weight: UIFont.Weight = .regular) -> UIFont {
        let size = validatedSize(theme?.bodyFontSize, default: defaultBodySize)
        return makeFont(family: theme?.fontFamily, size: size, weight: weight)
    }
    
    /// Creates a button font based on the theme configuration.
    /// - Parameters:
    ///   - theme: The survey theme (optional).
    ///   - weight: The font weight. Defaults to `.semibold`.
    /// - Returns: A configured UIFont.
    static func buttonFont(from theme: SurveyTheme?, weight: UIFont.Weight = .semibold) -> UIFont {
        let size = validatedSize(theme?.buttonFontSize, default: defaultButtonSize)
        return makeFont(family: theme?.fontFamily, size: size, weight: weight)
    }
    
    /// Creates a question text font based on the theme configuration.
    /// Uses body size with semibold weight.
    /// - Parameter theme: The survey theme (optional).
    /// - Returns: A configured UIFont.
    static func questionFont(from theme: SurveyTheme?) -> UIFont {
        let size = validatedSize(theme?.bodyFontSize, default: defaultBodySize)
        return makeFont(family: theme?.fontFamily, size: size, weight: .semibold)
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
            // Use rounded system font design
            if let descriptor = baseFont.fontDescriptor.withDesign(.rounded) {
                return UIFont(descriptor: descriptor, size: size)
            }
            Logger.warning("Failed to create rounded font, using system font")
            return baseFont
            
        case "serif":
            // Use serif system font design
            if let descriptor = baseFont.fontDescriptor.withDesign(.serif) {
                return UIFont(descriptor: descriptor, size: size)
            }
            Logger.warning("Failed to create serif font, using system font")
            return baseFont
            
        case "monospaced":
            // Use monospaced system font design
            if let descriptor = baseFont.fontDescriptor.withDesign(.monospaced) {
                return UIFont(descriptor: descriptor, size: size)
            }
            Logger.warning("Failed to create monospaced font, using system font")
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
    
    // MARK: - Default Colors
    
    /// Default primary color (system blue).
    static var defaultPrimaryColor: UIColor { .systemBlue }
    
    /// Default background color for the survey card.
    static var defaultBackgroundColor: UIColor { .systemBackground }
    
    /// Default text color for labels.
    static var defaultTextColor: UIColor { .label }
    
    /// Default secondary text color.
    static var defaultSecondaryTextColor: UIColor { .secondaryLabel }
    
    /// Default button text color.
    static var defaultButtonTextColor: UIColor { .white }
    
    // MARK: - Color Resolution
    
    /// Resolves the primary color from theme.
    /// - Parameter theme: The survey theme (optional).
    /// - Returns: The resolved primary UIColor.
    static func primaryColor(from theme: SurveyTheme?) -> UIColor {
        guard let hex = theme?.primaryColorHex else {
            return defaultPrimaryColor
        }
        
        guard let color = UIColor(hex: hex) else {
            Logger.warning("Failed to parse primaryColorHex '\(hex)', using default")
            return defaultPrimaryColor
        }
        
        return color
    }
    
    /// Resolves the background color from theme.
    /// - Parameter theme: The survey theme (optional).
    /// - Returns: The resolved background UIColor.
    static func backgroundColor(from theme: SurveyTheme?) -> UIColor {
        guard let hex = theme?.backgroundColorHex else {
            return defaultBackgroundColor
        }
        
        guard let color = UIColor(hex: hex) else {
            Logger.warning("Failed to parse backgroundColorHex '\(hex)', using default")
            return defaultBackgroundColor
        }
        
        return color
    }
    
    /// Resolves the text color from theme.
    /// - Parameter theme: The survey theme (optional).
    /// - Returns: The resolved text UIColor.
    static func textColor(from theme: SurveyTheme?) -> UIColor {
        guard let hex = theme?.textColorHex else {
            return defaultTextColor
        }
        
        guard let color = UIColor(hex: hex) else {
            Logger.warning("Failed to parse textColorHex '\(hex)', using default")
            return defaultTextColor
        }
        
        return color
    }
    
    /// Resolves the button text color from theme.
    /// Falls back to white if primary color is dark, black otherwise.
    /// - Parameter theme: The survey theme (optional).
    /// - Returns: The resolved button text UIColor.
    static func buttonTextColor(from theme: SurveyTheme?) -> UIColor {
        if let hex = theme?.buttonTextColorHex, let color = UIColor(hex: hex) {
            return color
        }
        
        // Auto-determine based on primary color luminance
        let primary = primaryColor(from: theme)
        return primary.isDark ? .white : .black
    }
}

// MARK: - Corner Radius Resolver

/// Resolves corner radius values from SurveyTheme with safe fallbacks.
enum ThemeCornerRadiusResolver {
    
    // MARK: - Default Values
    
    /// Default corner radius for the main card.
    static let defaultCardRadius: CGFloat = 16.0
    
    /// Default corner radius for buttons.
    static let defaultButtonRadius: CGFloat = 12.0
    
    // MARK: - Resolution
    
    /// Resolves the card corner radius from theme.
    /// - Parameter theme: The survey theme (optional).
    /// - Returns: The resolved corner radius.
    static func cardCornerRadius(from theme: SurveyTheme?) -> CGFloat {
        guard let radius = theme?.cornerRadius, radius >= 0 else {
            return defaultCardRadius
        }
        // Clamp to reasonable bounds (0 - 50)
        return CGFloat(min(50, radius))
    }
    
    /// Resolves the button corner radius from theme.
    /// - Parameter theme: The survey theme (optional).
    /// - Returns: The resolved corner radius.
    static func buttonCornerRadius(from theme: SurveyTheme?) -> CGFloat {
        guard let radius = theme?.buttonCornerRadius, radius >= 0 else {
            return defaultButtonRadius
        }
        // Clamp to reasonable bounds (0 - 50)
        return CGFloat(min(50, radius))
    }
}

