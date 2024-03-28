@testable import APIRequest
import XCTest
import Combine

@available(iOS 15.0.0, *)
final class APIRequestTests: XCTestCase {
    
    private let baseURL = "https://api.jikan.moe"
    private let path = "/v4/top/anime"
    private let fullURL = "https://api.jikan.moe/v4/top/anime"
    
    private var anyCancellable: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        anyCancellable = []
    }
    
    override func tearDown() {
        super.tearDown()
        anyCancellable = nil
    }
    
    func test_getResponse() throws {
        let expectation = XCTestExpectation(description: "Get API response")

        APITestRequest(method: .GET)
            .makeRequest()
            .sink { error in
                expectation.fulfill()
            } receiveValue: { data in
                XCTAssertTrue(true)
            }.store(in: &anyCancellable)

        wait(for: [expectation], timeout: 5.0)
    }
    
    func test_getError() {
        let expectation = XCTestExpectation(description: "Get API response")
        
        APITestRequestError()
            .makeRequest()
            .sink { error in
                switch error {
                case .finished: break
                case .failure(let error):
                    let statusCode = APIError.DefaultErrorStatusCode.parseData.rawValue
                    XCTAssert(error.statusCode == statusCode)
                }
                expectation.fulfill()
            } receiveValue: { _ in }
            .store(in: &anyCancellable)

        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func test_request_method() {
        let methodGet = APITestRequest(method: .GET).request.httpMethod
        let methodPost = APITestRequest(method: .POST).request.httpMethod
        let methodUpdate = APITestRequest(method: .UPDATE).request.httpMethod
        let methodDelete = APITestRequest(method: .DELETE).request.httpMethod
        let methodPut = APITestRequest(method: .PUT).request.httpMethod
        
        XCTAssertTrue(methodGet == APIMethod.GET.rawValue)
        XCTAssertTrue(methodPost == APIMethod.POST.rawValue)
        XCTAssertTrue(methodUpdate == APIMethod.UPDATE.rawValue)
        XCTAssertTrue(methodDelete == APIMethod.DELETE.rawValue)
        XCTAssertTrue(methodPut == APIMethod.PUT.rawValue)
    }
    
    func test_request_URL() throws {
        let requestWithNormalURL = APITestRequest(
            method: .GET,
            baseURL: baseURL,
            path: path
        ).request.url?.absoluteString
        
        let requestWithoutPath = APITestRequest(
            method: .GET,
            baseURL: baseURL,
            path: ""
        ).request.url?.absoluteString
        
        let requestWithFinalBar = APITestRequest(
            method: .GET,
            baseURL: baseURL + "/",
            path: path
        ).request.url?.absoluteString
        
        let requestWithPathFinalBar = APITestRequest(
            method: .GET,
            baseURL: baseURL + "/",
            path: path + "/"
        ).request.url?.absoluteString
        
        let requestWithoutPathBar = APITestRequest(
            method: .GET,
            baseURL: baseURL + "/",
            path: "v4/top/anime"
        ).request.url?.absoluteString
        
        XCTAssertTrue(requestWithNormalURL == fullURL)
        XCTAssertTrue(requestWithoutPath == baseURL)
        XCTAssertTrue(requestWithFinalBar == fullURL)
        XCTAssertTrue(requestWithPathFinalBar == fullURL + "/")
        XCTAssertTrue(requestWithoutPathBar == fullURL)
    }
    
    func test_request_parameters() {
        let requestNormal = APITestRequest(
            method: .GET,
            parameters: ["Some": "Parameter"]
        ).request.url?.absoluteString
        
        let requestParamSpaceEncoded = APITestRequest(
            method: .GET,
            parameters: ["Some": "Parameter space"],
            encodeURL: true
        ).request.url?.absoluteString
        
        let requestParamSpaceNotEncoded = APITestRequest(
            method: .GET,
            parameters: ["Some": "Parameter space"],
            encodeURL: false
        ).request.url?.absoluteString
        
        XCTAssertTrue(requestNormal == fullURL + "?Some=Parameter")
        XCTAssertTrue(requestParamSpaceEncoded == fullURL + "?Some=Parameter%2520space")
        XCTAssertTrue(requestParamSpaceNotEncoded == fullURL + "?Some=Parameter%20space")
    }
    
    func test_request_body() {
        let normalBody = APITestRequest(
            method: .GET,
            body: ["Some": "Value", "Int": 0]
        ).request.httpBody
        
        let objectBody = APITestRequest(
            method: .GET,
            body: ObjectBody(some: "value", integer: 0)
        ).request.httpBody
        
        let typeBody = APITestRequest(
            method: .GET,
            body: "Some value"
        ).request.httpBody
        
        XCTAssertNotNil(normalBody)
        XCTAssertNotNil(objectBody)
        XCTAssertNotNil(typeBody)
    }
    
    func test_request_header() {
        let dic = ["some": "header"]
        let header = APITestRequest(
            method: .GET,
            headers: dic
        ).request.allHTTPHeaderFields
        
        XCTAssertTrue(header == dic)
    }
    
    func test_request_timeOut() {
        let timeOut = APITestRequest(
            method: .GET,
            timeOut: 30
        ).request.timeoutInterval
        
        XCTAssertTrue(timeOut == 30)
    }
}

@available(iOS 15.0.0, *)
extension APIRequestTests {
    struct ObjectBody: Encodable {
        let some: String
        let integer: Int
    }
    
    class APITestRequest: APIRequest {
        typealias Response = Data
        let method: APIMethod
        let baseURL: String
        let path: String
        let parameters: [String: String]
        let body: Any?
        let headers: [String: String]
        let timeOut: TimeInterval
        let encodeURL: Bool
        let skipSSL: Bool
        
        init(
            method: APIMethod,
            baseURL: String = "https://api.jikan.moe",
            path: String = "/v4/top/anime",
            parameters: [String: String] = [:],
            body: Any? = nil,
            headers: [String: String] = [:],
            timeOut: TimeInterval = 60,
            encodeURL: Bool = true,
            skipSSL: Bool = true
        ) {
            self.method = method
            self.baseURL = baseURL
            self.path = path
            self.parameters = parameters
            self.body = body
            self.headers = headers
            self.timeOut = timeOut
            self.encodeURL = encodeURL
            self.skipSSL = skipSSL
        }
    }
    
    class APITestRequestError: APIRequest {
        typealias Response = String
        var method: APIMethod { .GET }
        var baseURL: String { "https://api.jikan.moe" }
        var path: String { "/v4/top/anime" }
    }
}
