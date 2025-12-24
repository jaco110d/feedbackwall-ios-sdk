import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// FeedbackWall iOS SDK - Main entry point.
///
/// The FeedbackWall SDK allows you to display in-app surveys triggered at specific
/// points in your app. The SDK is designed to be non-intrusive and will never crash
/// your app, even if the backend is unavailable.
///
/// ## Usage
///
/// 1. Configure the SDK at app launch:
/// ```swift
/// FeedbackWall.configure(
///     apiKey: "your_api_key",
///     baseURL: URL(string: "https://your-backend.com")!
/// )
/// ```
///
/// 2. Optionally identify the user:
/// ```swift
/// FeedbackWall.identify(
///     userId: "user_123",
///     traits: ["plan": "premium"]
/// )
/// ```
///
/// 3. Trigger surveys at appropriate points:
/// ```swift
/// FeedbackWall.showIfAvailable(trigger: "onboarding_completed")
/// ```
///
public final class FeedbackWall {
    
    // MARK: - Properties
    
    /// The current SDK configuration, if configured.
    internal static var currentConfig: FeedbackWallConfig?
    
    /// Whether the SDK has been configured.
    public static var isConfigured: Bool {
        currentConfig != nil
    }
    
    // MARK: - Initialization
    
    /// Private initializer to prevent instantiation.
    private init() {}
    
    // MARK: - Public API
    
    /// Configures the FeedbackWall SDK. Must be called once at app launch.
    ///
    /// - Parameters:
    ///   - apiKey: Your FeedbackWall API key.
    ///   - baseURL: The base URL of the FeedbackWall backend.
    ///
    /// - Important: This method must be called before any other SDK methods.
    ///
    /// ## Example
    /// ```swift
    /// // In AppDelegate or SceneDelegate
    /// FeedbackWall.configure(
    ///     apiKey: "FW_PROD_xxx",
    ///     baseURL: URL(string: "https://feedbackwall.io")!
    /// )
    /// ```
    public static func configure(apiKey: String, baseURL: URL) {
        let config = FeedbackWallConfig(apiKey: apiKey, baseURL: baseURL)
        currentConfig = config
        NetworkClient.shared.configure(with: config)
        
        // Send ping to verify SDK connection
        NetworkClient.shared.ping()
        
        Logger.info("FeedbackWall SDK configured with baseURL: \(baseURL.absoluteString)")
    }
    
    /// Identifies the current user. Call this after login or when user information becomes available.
    ///
    /// - Parameters:
    ///   - userId: A unique identifier for the user.
    ///   - traits: Optional dictionary of user properties (e.g., plan, role, signup date).
    ///
    /// - Note: If not called, surveys will still work but without user-specific targeting.
    ///
    /// ## Example
    /// ```swift
    /// FeedbackWall.identify(
    ///     userId: "user_123",
    ///     traits: [
    ///         "plan": "premium",
    ///         "signupDate": "2024-01-15"
    ///     ]
    /// )
    /// ```
    public static func identify(userId: String, traits: [String: Any]? = nil) {
        UserSession.shared.identify(userId: userId, traits: traits)
        Logger.info("User identified: \(userId)")
    }
    
    /// Triggers a survey check for the specified trigger point.
    ///
    /// This method checks with the backend whether a survey should be shown for this trigger.
    /// If a survey is available and eligible, it will be presented modally.
    ///
    /// - Parameter trigger: The trigger identifier (e.g., "onboarding_completed", "purchase_made").
    ///
    /// - Important: This method is non-blocking and safe to call from the main thread.
    ///   If the backend is unavailable or an error occurs, nothing happens (fail-silent behavior).
    ///
    /// ## Example
    /// ```swift
    /// // After user completes onboarding
    /// FeedbackWall.showIfAvailable(trigger: "onboarding_completed")
    ///
    /// // After a purchase
    /// FeedbackWall.showIfAvailable(trigger: "purchase_completed")
    /// ```
    public static func showIfAvailable(trigger: String) {
        // Guard against crashes - SDK must never crash the host app
        do {
            try performShowIfAvailable(trigger: trigger)
        } catch {
            Logger.error("Unexpected error in showIfAvailable: \(error.localizedDescription)")
        }
    }
    
    /// Internal implementation of showIfAvailable that can throw.
    private static func performShowIfAvailable(trigger: String) throws {
        guard currentConfig != nil else {
            Logger.warning("FeedbackWall.showIfAvailable called before configure(). Ignoring trigger: \(trigger)")
            return
        }
        
        #if canImport(UIKit)
        SurveyManager.shared.handle(trigger: trigger)
        #else
        Logger.warning("FeedbackWall UI requires UIKit. Trigger ignored: \(trigger)")
        #endif
    }
    
    /// Checks if a survey is available for the given trigger without showing it.
    ///
    /// - Parameter trigger: The trigger identifier.
    /// - Returns: The available Survey, or nil if no survey should be shown.
    ///
    /// ## Example
    /// ```swift
    /// Task {
    ///     if let survey = await FeedbackWall.checkTrigger("feature_used") {
    ///         print("Survey available: \(survey.title)")
    ///     }
    /// }
    /// ```
    public static func checkTrigger(_ trigger: String) async -> Survey? {
        guard currentConfig != nil else {
            Logger.warning("FeedbackWall.checkTrigger called before configure(). Ignoring trigger: \(trigger)")
            return nil
        }
        
        return await SurveyManager.shared.checkTrigger(trigger)
    }
    
    /// Resets the SDK state, clearing user identification.
    ///
    /// Call this when the user logs out.
    public static func reset() {
        UserSession.shared.reset()
        Logger.info("FeedbackWall SDK reset")
    }
}
