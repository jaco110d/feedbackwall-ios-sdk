import Foundation

/// Network client for making HTTP requests to the FeedbackWall backend.
/// Configured with short timeouts to ensure the SDK never blocks the app.
final class NetworkClient {
    
    // MARK: - Types
    
    enum NetworkError: Error {
        case notConfigured
        case invalidURL
        case invalidResponse
        case httpError(statusCode: Int)
        case decodingError(Error)
        case networkError(Error)
    }
    
    // MARK: - Properties
    
    private let session: URLSession
    private var config: FeedbackWallConfig?
    
    // MARK: - Singleton
    
    static let shared = NetworkClient()
    
    // MARK: - Initialization
    
    private init() {
        let configuration = URLSessionConfiguration.default
        // Short timeouts as per PRD: max 1-2 seconds per request
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
    
    // MARK: - Public Methods
    
    /// Performs a POST request to the specified endpoint.
    /// - Parameters:
    ///   - endpoint: The API endpoint path (e.g., "/sdk/triggers/check").
    ///   - body: The request body to encode as JSON.
    /// - Returns: The decoded response.
    func post<T: Encodable, R: Decodable>(
        endpoint: String,
        body: T
    ) async -> Result<R, NetworkError> {
        guard let config = config else {
            Logger.error("NetworkClient not configured. Call FeedbackWall.configure() first.")
            return .failure(.notConfigured)
        }
        
        guard let url = URL(string: endpoint, relativeTo: config.baseURL) else {
            Logger.error("Invalid URL for endpoint: \(endpoint)")
            return .failure(.invalidURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(config.apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            Logger.error("Failed to encode request body: \(error)")
            return .failure(.networkError(error))
        }
        
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
    
    /// Performs a GET request to the specified endpoint.
    /// - Parameter endpoint: The API endpoint path.
    /// - Returns: The decoded response.
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
}

