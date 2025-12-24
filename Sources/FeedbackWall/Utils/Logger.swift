import Foundation
import os.log

/// Internal logger for the FeedbackWall SDK.
/// All logs are prefixed with [FeedbackWall] for easy filtering.
enum Logger {
    
    // MARK: - Log Levels
    
    enum Level: String {
        case debug = "DEBUG"
        case info = "INFO"
        case warning = "WARNING"
        case error = "ERROR"
    }
    
    // MARK: - Properties
    
    private static let subsystem = "com.feedbackwall.sdk"
    private static let osLog = OSLog(subsystem: subsystem, category: "FeedbackWall")
    
    /// Controls whether logging is enabled. Default is true in DEBUG builds.
    static var isEnabled: Bool = {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }()
    
    // MARK: - Logging Methods
    
    /// Logs a debug message.
    /// - Parameters:
    ///   - message: The message to log.
    ///   - file: The file where the log originated.
    ///   - function: The function where the log originated.
    ///   - line: The line number where the log originated.
    static func debug(
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(level: .debug, message: message, file: file, function: function, line: line)
    }
    
    /// Logs an info message.
    /// - Parameters:
    ///   - message: The message to log.
    ///   - file: The file where the log originated.
    ///   - function: The function where the log originated.
    ///   - line: The line number where the log originated.
    static func info(
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(level: .info, message: message, file: file, function: function, line: line)
    }
    
    /// Logs a warning message.
    /// - Parameters:
    ///   - message: The message to log.
    ///   - file: The file where the log originated.
    ///   - function: The function where the log originated.
    ///   - line: The line number where the log originated.
    static func warning(
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(level: .warning, message: message, file: file, function: function, line: line)
    }
    
    /// Logs an error message.
    /// - Parameters:
    ///   - message: The message to log.
    ///   - file: The file where the log originated.
    ///   - function: The function where the log originated.
    ///   - line: The line number where the log originated.
    static func error(
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(level: .error, message: message, file: file, function: function, line: line)
    }
    
    // MARK: - Private
    
    private static func log(
        level: Level,
        message: String,
        file: String,
        function: String,
        line: Int
    ) {
        guard isEnabled else { return }
        
        let fileName = (file as NSString).lastPathComponent
        let formattedMessage = "[FeedbackWall] [\(level.rawValue)] \(fileName):\(line) \(function) - \(message)"
        
        let osLogType: OSLogType
        switch level {
        case .debug:
            osLogType = .debug
        case .info:
            osLogType = .info
        case .warning:
            osLogType = .default
        case .error:
            osLogType = .error
        }
        
        os_log("%{public}@", log: osLog, type: osLogType, formattedMessage)
        
        #if DEBUG
        print(formattedMessage)
        #endif
    }
}

