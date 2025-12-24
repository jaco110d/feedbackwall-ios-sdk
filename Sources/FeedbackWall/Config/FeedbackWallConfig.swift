import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// Configuration container for the FeedbackWall SDK.
/// Holds API credentials and device metadata used for all SDK operations.
public struct FeedbackWallConfig {
    
    // MARK: - Properties
    
    /// The API key used for authenticating requests with the FeedbackWall backend.
    public let apiKey: String
    
    /// The base URL of the FeedbackWall backend.
    public let baseURL: URL
    
    /// The current app version (bundle short version string).
    public let appVersion: String
    
    /// The platform identifier (always "iOS" for this SDK).
    public let platform: String = "iOS"
    
    /// The platform with OS version (e.g., "iOS 17.0").
    public let platformVersion: String
    
    /// The device's current locale identifier (e.g., "da-DK").
    public let deviceLocale: String
    
    /// The device model identifier (e.g., "iPhone14,2").
    public let deviceModel: String?
    
    // MARK: - Initialization
    
    /// Creates a new FeedbackWall configuration.
    /// - Parameters:
    ///   - apiKey: The API key for backend authentication.
    ///   - baseURL: The base URL of the FeedbackWall backend.
    public init(apiKey: String, baseURL: URL) {
        self.apiKey = apiKey
        self.baseURL = baseURL
        self.appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
        self.deviceLocale = Locale.current.identifier
        
        #if canImport(UIKit)
        let osVersion = ProcessInfo.processInfo.operatingSystemVersion
        self.platformVersion = "iOS \(osVersion.majorVersion).\(osVersion.minorVersion)"
        
        var systemInfo = utsname()
        uname(&systemInfo)
        self.deviceModel = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                String(validatingUTF8: $0)
            }
        }
        #else
        let osVersion = ProcessInfo.processInfo.operatingSystemVersion
        self.platformVersion = "macOS \(osVersion.majorVersion).\(osVersion.minorVersion)"
        self.deviceModel = nil
        #endif
    }
}

