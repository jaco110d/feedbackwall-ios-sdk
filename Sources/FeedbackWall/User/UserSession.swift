import Foundation

/// Thread-safe container for user identification data.
/// Stores userId and traits after `FeedbackWall.identify()` is called.
final class UserSession {
    
    // MARK: - Singleton
    
    static let shared = UserSession()
    
    // MARK: - Properties
    
    private let lock = NSLock()
    
    private var _userId: String?
    private var _traits: [String: Any]?
    
    /// The identified user's ID, if set.
    var userId: String? {
        lock.lock()
        defer { lock.unlock() }
        return _userId
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
    
    /// Clears the current user session.
    func reset() {
        lock.lock()
        defer { lock.unlock() }
        _userId = nil
        _traits = nil
    }
}

