import Foundation

/// Network client for making HTTP requests to the FeedbackWall backend.
/// Configured with short timeouts to ensure the SDK never blocks the app.
final class NetworkClient {
    
    // MARK: - Types
    
    enum NetworkError: LocalizedError {
        case notConfigured
        case invalidURL
        case invalidResponse
        case httpError(statusCode: Int)
        case decodingError(Error)
        case networkError(Error)
        
        var errorDescription: String? {
            switch self {
            case .notConfigured:
                return "FeedbackWall SDK not configured. Call FeedbackWall.configure() first."
            case .invalidURL:
                return "Invalid URL for network request."
            case .invalidResponse:
                return "Invalid response from server."
            case .httpError(let statusCode):
                return "HTTP error with status code: \(statusCode)"
            case .decodingError(let error):
                return "Failed to decode response: \(error.localizedDescription)"
            case .networkError(let error):
                return "Network request failed: \(error.localizedDescription)"
            }
        }
    }
    
    // MARK: - Properties
    
    private let session: URLSession
    private var config: FeedbackWallConfig?
    
    // MARK: - Singleton
    
    static let shared = NetworkClient()
    
    // MARK: - Initialization
    
    private init() {
        let configuration = URLSessionConfiguration.default
        // Short timeouts as per PRD: max 2 seconds per request
        configuration.timeoutIntervalForRequest = 2.0
        configuration.timeoutIntervalForResource = 4.0
        configuration.waitsForConnectivity = false
        
        self.session = URLSession(configuration: configuration)
    }
    
    // MARK: - Configuration
    
    /// Configures the network client with SDK configuration.
    /// - Parameter config: The SDK configuration.
    func configure(with config: FeedbackWallConfig) {
        self.config = config
    }
    
    // MARK: - Public Methods (Throwing Version)
    
    /// Performs a POST request to the specified path.
    /// - Parameters:
    ///   - path: The API endpoint path (e.g., "/api/sdk/triggers/check").
    ///   - body: The request body to encode as JSON.
    /// - Returns: The decoded response.
    /// - Throws: NetworkError if the request fails.
    func post<T: Decodable>(_ path: String, body: Encodable) async throws -> T {
        guard let config = config else {
            Logger.error("NetworkClient not configured. Call FeedbackWall.configure() first.")
            throw NetworkError.notConfigured
        }
        
        guard let url = URL(string: path, relativeTo: config.baseURL) else {
            Logger.error("Invalid URL for path: \(path)")
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(config.apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let encoder = JSONEncoder()
            request.httpBody = try encoder.encode(AnyEncodable(body))
        } catch {
            Logger.error("Failed to encode request body: \(error)")
            throw NetworkError.networkError(error)
        }
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                Logger.error("Invalid response type")
                throw NetworkError.invalidResponse
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                Logger.error("HTTP error: \(httpResponse.statusCode)")
                throw NetworkError.httpError(statusCode: httpResponse.statusCode)
            }
            
            do {
                let decoder = JSONDecoder()
                let decoded = try decoder.decode(T.self, from: data)
                return decoded
            } catch {
                Logger.error("Failed to decode response: \(error)")
                throw NetworkError.decodingError(error)
            }
        } catch let error as NetworkError {
            throw error
        } catch {
            Logger.error("Network request failed: \(error)")
            throw NetworkError.networkError(error)
        }
    }
    
    // MARK: - Public Methods (Result Version - for backward compatibility)
    
    /// Performs a POST request to the specified endpoint with Result-based error handling.
    /// - Parameters:
    ///   - endpoint: The API endpoint path (e.g., "/api/sdk/triggers/check").
    ///   - body: The request body to encode as JSON.
    /// - Returns: The decoded response wrapped in a Result.
    func post<T: Encodable, R: Decodable>(
        endpoint: String,
        body: T
    ) async -> Result<R, NetworkError> {
        do {
            let result: R = try await post(endpoint, body: body)
            return .success(result)
        } catch let error as NetworkError {
            return .failure(error)
        } catch {
            return .failure(.networkError(error))
        }
    }
    
    /// Performs a GET request to the specified endpoint.
    /// - Parameter endpoint: The API endpoint path.
    /// - Returns: The decoded response wrapped in a Result.
    func get<R: Decodable>(endpoint: String) async -> Result<R, NetworkError> {
        guard let config = config else {
            Logger.error("NetworkClient not configured. Call FeedbackWall.configure() first.")
            return .failure(.notConfigured)
        }
        
        guard let url = URL(string: endpoint, relativeTo: config.baseURL) else {
            Logger.error("Invalid URL for endpoint: \(endpoint)")
            return .failure(.invalidURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(config.apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                Logger.error("Invalid response type")
                return .failure(.invalidResponse)
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                Logger.error("HTTP error: \(httpResponse.statusCode)")
                return .failure(.httpError(statusCode: httpResponse.statusCode))
            }
            
            do {
                let decoded = try JSONDecoder().decode(R.self, from: data)
                return .success(decoded)
            } catch {
                Logger.error("Failed to decode response: \(error)")
                return .failure(.decodingError(error))
            }
        } catch {
            Logger.error("Network request failed: \(error)")
            return .failure(.networkError(error))
        }
    }
    
    // MARK: - Ping
    
    /// Sends a ping to the backend to verify SDK connection.
    /// This is a fire-and-forget operation that doesn't block the app.
    func ping() {
        guard let config = config else {
            Logger.error("NetworkClient not configured. Cannot send ping.")
            return
        }
        
        guard let url = URL(string: "/api/sdk/ping", relativeTo: config.baseURL) else {
            Logger.error("Invalid URL for ping endpoint")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(config.apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let pingRequest = PingRequest(
            platform: config.platformVersion,
            appVersion: config.appVersion,
            deviceLocale: config.deviceLocale,
            sdkVersion: "1.0.0"
        )
        
        do {
            let encoder = JSONEncoder()
            request.httpBody = try encoder.encode(pingRequest)
        } catch {
            Logger.error("Failed to encode ping request: \(error)")
            return
        }
        
        // Fire-and-forget: use Task to avoid blocking
        Task {
            do {
                let (_, response) = try await session.data(for: request)
                
                if let httpResponse = response as? HTTPURLResponse {
                    if (200...299).contains(httpResponse.statusCode) {
                        Logger.info("SDK ping successful")
                    } else {
                        Logger.warning("SDK ping returned status: \(httpResponse.statusCode)")
                    }
                }
            } catch {
                Logger.warning("SDK ping failed: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - Ping Request Model

/// Request body for the SDK ping endpoint.
private struct PingRequest: Encodable {
    let platform: String
    let appVersion: String
    let deviceLocale: String
    let sdkVersion: String
}

// MARK: - AnyEncodable Helper

/// Type-erased Encodable wrapper to allow using `Encodable` as a parameter type.
private struct AnyEncodable: Encodable {
    private let encode: (Encoder) throws -> Void
    
    init(_ wrapped: Encodable) {
        self.encode = wrapped.encode
    }
    
    func encode(to encoder: Encoder) throws {
        try encode(encoder)
    }
}
