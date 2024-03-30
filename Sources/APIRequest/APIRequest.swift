import Combine
import Foundation

public enum APIMethod: String {
    case GET, POST, UPDATE, DELETE, PUT
}

@available(iOS 15.0.0, *)
public protocol APIRequest: AnyObject {
    associatedtype Response: Codable

    var method: APIMethod { get }
    var baseURL: String { get }
    var path: String { get }
    var parameters: [String: String] { get }
    var body: Any? { get }
    var headers: [String: String] { get }
    var timeOut: TimeInterval { get }
    var skipSSL: Bool { get }
    var encodeURL: Bool { get }

    func makeRequest() -> AnyPublisher<Self.Response, APIError>
}

// MARK: - Default values

@available(iOS 15.0.0, *)
public extension APIRequest {
    var parameters: [String: String] { return [:] }
    var body: Any? { return nil }
    var headers: [String: String] { ["Content-Type": "application/json"] }
    var timeOut: TimeInterval { return 60 }
    var skipSSL: Bool { false }
    var encodeURL: Bool { true }
    
    @discardableResult
    func makeRequest() -> AnyPublisher<Self.Response, APIError> {
        return APISession().request(self)
    }
}

// MARK: - Generate request

@available(iOS 15.0.0, *)
extension APIRequest {
    var request: URLRequest {
        var baseUrl = baseURL
        while baseUrl.last == "/" {
            baseUrl.removeLast()
        }
        guard var url = URL(string: baseUrl) else {
            fatalError("Impossible to form base URL")
        }

        var path = path
        if !path.isEmpty {
            if path.first != "/" {
                path = "/" + path
            }
            url.appendPathComponent(path)
        }

        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            fatalError("Impossible to create URLComponent from \(url)")
        }

        if !parameters.isEmpty {
            components.queryItems = parameters.map { URLQueryItem(name: $0, value: $1) }
        }
        
        var urlString = ""
        if encodeURL {
            urlString = components.url?.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        } else {
            urlString = components.url?.absoluteString ?? ""
        }

        guard let finalUrl = URL(string: urlString) else {
            fatalError("Unable to retrieve final URL")
        }

        var request = URLRequest(url: finalUrl)
        request.httpMethod = method.rawValue
        if let body {
            switch body {
            case let dic as Dictionary<String, Any>:
                request.httpBody = try? JSONSerialization.data(withJSONObject: dic, options: [])
            case let object as Encodable:
                request.httpBody = try? JSONEncoder().encode(object)
            case let data as Data:
                request.httpBody = data
            default: fatalError("Body type not valid")
            }
        }
        request.allHTTPHeaderFields = headers
        request.timeoutInterval = timeOut

        return request
    }
}
