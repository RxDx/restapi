import XCTest
@testable import RestApi

final class RestApiTests: XCTestCase {
    
    class URLSessionMock: URLSessionProtocol {
        var urlSessionCalled = false
        func data(for request: URLRequest, delegate: URLSessionTaskDelegate?) async throws -> (Data, URLResponse) {
            urlSessionCalled = true
            var dataResponse = Data()
            switch request.httpMethod {
            case "GET":
                if request.url?.absoluteString == "/" {
                    dataResponse = try JSONEncoder().encode(["Success"])
                } else {
                    dataResponse = try JSONEncoder().encode("Success")
                }
            case .none, .some(_):
                dataResponse = try JSONEncoder().encode("Success")
            }
            return (dataResponse, URLResponse())
        }
    }
    
    func testRequestWithDebugShouldReturnSuccess() async throws {
        let sut = RestApi(debug: true, urlSession: URLSessionMock())
        let response: String = try await sut.get(resourceId: "0")
        XCTAssertEqual(response, "Success")
    }
    
    func testRequestWithHeaderShouldReturnSuccess() async throws {
        let sut = RestApi(header: ["key": "value"], urlSession: URLSessionMock())
        let response: String = try await sut.get(resourceId: "0")
        XCTAssertEqual(response, "Success")
    }
    
    func testRequestWithRequestHeaderShouldReturnSuccess() async throws {
        let sut = RestApi(urlSession: URLSessionMock())
        let response: String = try await sut.get(resourceId: "0", header: ["key": "value"])
        XCTAssertEqual(response, "Success")
    }
    
    func testRequestWithUrlShouldReturnSuccess() async throws {
        let sut = RestApi(urlSession: URLSessionMock())
        let response: String = try await sut.get(url: "", resourceId: "420")
        XCTAssertEqual(response, "Success")
    }
    
    func testRequestWithSuffixShouldReturnSuccess() async throws {
        let sut = RestApi(urlSession: URLSessionMock())
        let response: String = try await sut.get(resourceId: "420", suffix: "")
        XCTAssertEqual(response, "Success")
    }
    
    func testRequestWithPathShouldReturnSuccess() async throws {
        let sut = RestApi(urlSession: URLSessionMock())
        let response: String = try await sut.get(path: "", resourceId: "420")
        XCTAssertEqual(response, "Success")
    }
    
    func testRequestWithParamsShouldReturnSuccess() async throws {
        let sut = RestApi(urlSession: URLSessionMock())
        let response: String = try await sut.get(resourceId: "420", params: ["key": "value"])
        XCTAssertEqual(response, "Success")
    }
    
    func testGetShouldReturnSuccess() async throws {
        let sut = RestApi(urlSession: URLSessionMock())
        let response: [String] = try await sut.get()
        XCTAssertEqual(response, ["Success"])
    }
    
    func testGetWithResourceIdShouldReturnSuccess() async throws {
        let sut = RestApi(urlSession: URLSessionMock())
        let response: String = try await sut.get(resourceId: "0")
        XCTAssertEqual(response, "Success")
    }
    
    func testPostWithResourceShouldReturnSuccess() async throws {
        let sut = RestApi(urlSession: URLSessionMock())
        let response: String? = try await sut.post(resource: "")
        XCTAssertEqual(response, "Success")
    }
    
    func testPostWithResourceShouldReturn() async throws {
        let urlSession = URLSessionMock()
        let sut = RestApi(urlSession: urlSession)
        try await sut.post(resource: "")
        XCTAssertEqual(urlSession.urlSessionCalled, true)
    }
    
    func testPostWithPayloadShouldReturnSuccess() async throws {
        let sut = RestApi(urlSession: URLSessionMock())
        let response: String? = try await sut.post(payload: ["key": "value"])
        XCTAssertEqual(response, "Success")
    }
    
    func testPostWithPayloadShouldReturn() async throws {
        let urlSession = URLSessionMock()
        let sut = RestApi(urlSession: urlSession)
        try await sut.post(payload: ["key": "value"])
        XCTAssertEqual(urlSession.urlSessionCalled, true)
    }
    
    func testPutWithResourceShouldReturnSuccess() async throws {
        let sut = RestApi(urlSession: URLSessionMock())
        let response: String? = try await sut.put(resourceId: "0", resource: "")
        XCTAssertEqual(response, "Success")
    }
    
    func testPutWithResourceShouldReturn() async throws {
        let urlSession = URLSessionMock()
        let sut = RestApi(urlSession: urlSession)
        try await sut.put(resourceId: "0", resource: "")
        XCTAssertEqual(urlSession.urlSessionCalled, true)
    }
    
    func testPutWithPayloadShouldReturnSuccess() async throws {
        let sut = RestApi(urlSession: URLSessionMock())
        let response: String? = try await sut.put(resourceId: "0", payload: ["key": "value"])
        XCTAssertEqual(response, "Success")
    }
    
    func testPutWithPayloadShouldReturn() async throws {
        let urlSession = URLSessionMock()
        let sut = RestApi(urlSession: urlSession)
        try await sut.put(resourceId: "0", payload: ["key": "value"])
        XCTAssertEqual(urlSession.urlSessionCalled, true)
    }
    
    func testPatchWithResourceShouldReturnSuccess() async throws {
        let sut = RestApi(urlSession: URLSessionMock())
        let response: String? = try await sut.patch(resourceId: "0", resource: "")
        XCTAssertEqual(response, "Success")
    }
    
    func testPatchWithResourceShouldReturn() async throws {
        let urlSession = URLSessionMock()
        let sut = RestApi(urlSession: urlSession)
        try await sut.patch(resourceId: "0", resource: "")
        XCTAssertEqual(urlSession.urlSessionCalled, true)
    }
    
    func testPatchWithPayloadShouldReturnSuccess() async throws {
        let sut = RestApi(urlSession: URLSessionMock())
        let response: String? = try await sut.patch(resourceId: "0", payload: ["key": "value"])
        XCTAssertEqual(response, "Success")
    }
    
    func testPatchWithPayloadShouldReturn() async throws {
        let urlSession = URLSessionMock()
        let sut = RestApi(urlSession: urlSession)
        try await sut.patch(resourceId: "0", payload: ["key": "value"])
        XCTAssertEqual(urlSession.urlSessionCalled, true)
    }
    
    func testDeleteShouldReturnSuccess() async throws {
        let sut = RestApi(urlSession: URLSessionMock())
        let response: String? = try await sut.delete(resourceId: "0")
        XCTAssertEqual(response, "Success")
    }
    
    func testDeleteShouldReturn() async throws {
        let urlSession = URLSessionMock()
        let sut = RestApi(urlSession: urlSession)
        try await sut.delete(resourceId: "0")
        XCTAssertEqual(urlSession.urlSessionCalled, true)
    }
}
