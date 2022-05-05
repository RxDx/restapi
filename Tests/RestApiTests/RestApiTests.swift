import XCTest
@testable import RestApi

final class RestApiTests: XCTestCase {
    
    class URLSessionMock: URLSessionProtocol {
        func data(for request: URLRequest, delegate: URLSessionTaskDelegate?) async throws -> (Data, URLResponse) {
            let successData = try JSONEncoder().encode("Success")
            return (successData, URLResponse())
        }
        func data(for request: URLRequest) async throws -> (Data, URLResponse) {
            try await data(for: request, delegate: nil)
        }
    }
    
    func testGetShouldReturnSuccess() async throws {
        let response = try await RestApi<String>(urlSession: URLSessionMock()).get(resourceId: "420")
        XCTAssertEqual(response, "Success")
    }
}
