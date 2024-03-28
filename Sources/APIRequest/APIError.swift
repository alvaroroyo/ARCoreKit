import Foundation

public struct APIError: Error {
    public var url: String
    public var statusCode: Int
    public var data: Data? = nil
    public var message: String
}

// MARK: - Default API errors
public extension APIError {
    enum DefaultErrorStatusCode: Int {
        case parseData = -1
        case unknow = -2
    }
    
    static func parseData(_ url: String, error: Error? = nil) -> APIError {
        .init(url: url, statusCode: DefaultErrorStatusCode.parseData.rawValue, message: "Parse data error: \(error?.localizedDescription ?? "")")
    }

    static func unknow(_ url: String) -> APIError {
        .init(url: url, statusCode: DefaultErrorStatusCode.unknow.rawValue, message: "Unknow error")
    }
}

// MARK: - Description
extension APIError: CustomStringConvertible {
    public var description: String {
        return #"""
        Url: \#(url)
        Status code: \#(statusCode)
        Message: \#(message)
        """#
    }
}
