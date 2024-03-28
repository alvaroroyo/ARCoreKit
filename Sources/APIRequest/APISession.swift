import Combine
import Foundation

@available(iOS 15.0.0, *)
public final class APISession: NSObject, URLSessionDelegate {
    public func urlSession(_: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        // Trust the certificate even if not valid
        let urlCredential = URLCredential(trust: challenge.protectionSpace.serverTrust!)

        completionHandler(.useCredential, urlCredential)
    }
    
    public func request<Request: APIRequest>(_ request: Request) -> AnyPublisher<Request.Response, APIError> {
        let urlRequest = request.request
        let urlStr = urlRequest.url!.absoluteString
        var urlSession: URLSession
        if request.skipSSL {
            urlSession = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
        } else {
            urlSession = URLSession.shared
        }
        
        return urlSession.dataTaskPublisher(for: urlRequest)
            .tryMap { data, response in
                guard let response = response as? HTTPURLResponse else {
                    throw APIError.unknow(urlStr)
                }
                
                let statusCode = response.statusCode
                switch statusCode {
                case 200 ..< 300:
                    if Request.Response.self == Data.self, let data = data as? Request.Response {
                        return data
                    }

                    do {
                        let model = try JSONDecoder().decode(Request.Response.self, from: data)
                        return model
                    } catch {
                        throw APIError.parseData(urlStr, error: error)
                    }
                default:
                    let error = APIError(url: urlStr, statusCode: statusCode, data: data, message: "Service error")
                    throw error
                }
            }.mapError { error in
                guard let error = error as? APIError else {
                    return APIError.unknow("")
                }
                return error
            }.eraseToAnyPublisher()
    }
}
