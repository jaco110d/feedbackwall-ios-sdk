import Foundation

/// Thread-safe container for user identification data.
/// Stores userId and traits after `FeedbackWall.identify()` is called.
/// Automatically generates a persistent anonymous ID for users who haven't been identified.
final class UserSession {
    
    // MARK: - Singleton
    
    static let shared = UserSession()
    
    // MARK: - Constants
    
    private let anonymousIdKey = "feedbackwall_anonymous_id"
    
    // MARK: - Properties
    
    private let lock = NSLock()
    
    private var _userId: String?
    private var _traits: [String: Any]?
    
    /// The identified user's ID, if set via `identify()`.
    var identifiedUserId: String? {
        lock.lock()
        defer { lock.unlock() }
        return _userId
    }
    
    /// The effective user ID to use for API calls.
    /// Returns the identified user ID if set, otherwise falls back to the anonymous device ID.
    var userId: String {
        lock.lock()
        defer { lock.unlock() }
        return _userId ?? anonymousId
    }
    
    /// A persistent anonymous device ID.
    /// Generated once and stored in UserDefaults for the lifetime of the app installation.
    var anonymousId: String {
        if let existingId = UserDefaults.standard.string(forKey: anonymousIdKey) {
            return existingId
        }
        let newId = "anon_\(UUID().uuidString)"
        UserDefaults.standard.set(newId, forKey: anonymousIdKey)
        return newId
    }
    
    /// The identified user's traits, if set.
    var traits: [String: Any]? {
        lock.lock()
        defer { lock.unlock() }
        return _traits
    }
    
    // MARK: - Initialization
    
    private init() {}
    
    // MARK: - Methods
    
    /// Sets the current user identification.
    /// - Parameters:
    ///   - userId: The user's unique identifier.
    ///   - traits: Optional dictionary of user traits/properties.
    func identify(userId: String, traits: [String: Any]?) {
        lock.lock()
        defer { lock.unlock() }
        _userId = userId
        _traits = traits
    }
    
    /// Clears the current user session (identified user only).
    /// The anonymous ID persists across resets.
    func reset() {
        lock.lock()
        defer { lock.unlock() }
        _userId = nil
        _traits = nil
    }
}

