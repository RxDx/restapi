import XCTest
@testable import RestApi

final class RestApiTests: XCTestCase {
    
    class URLSessionMock: URLSessionProtocol {
        func data(for request: URLRequest, delegate: URLSessionTaskDelegate?) async throws -> (Data, URLResponse) {
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
    
    func testGetRequestWithDebugShouldReturnSuccess() async throws {
        let sut = RestApi<String>(debug: true, urlSession: URLSessionMock())
        let response = try await sut.get(resourceId: "420")
        XCTAssertEqual(response, "Success")
    }
    
    func testPostRequestWithDebugShouldReturnSuccess() async throws {
        let sut = RestApi<String>(debug: true, urlSession: URLSessionMock())
        let response = try await sut.post(resource: "")
        XCTAssertEqual(response, "Success")
    }
    
    func testRequestWithHeaderShouldReturnSuccess() async throws {
        let sut = RestApi<String>(header: ["key": "value"], urlSession: URLSessionMock())
        let response = try await sut.get(resourceId: "420")
        XCTAssertEqual(response, "Success")
    }
    
    func testRequestWithUrlShouldReturnSuccess() async throws {
        let sut = RestApi<String>(urlSession: URLSessionMock())
        let response = try await sut.get(url: "", resourceId: "420")
        XCTAssertEqual(response, "Success")
    }
    
    func testRequestWithSuffixShouldReturnSuccess() async throws {
        let sut = RestApi<String>(urlSession: URLSessionMock())
        let response = try await sut.get(resourceId: "420", suffix: "")
        XCTAssertEqual(response, "Success")
    }
    
    func testRequestWithPathShouldReturnSuccess() async throws {
        let sut = RestApi<String>(urlSession: URLSessionMock())
        let response = try await sut.get(path: "", resourceId: "420")
        XCTAssertEqual(response, "Success")
    }
    
    func testRequestWithParamsShouldReturnSuccess() async throws {
        let sut = RestApi<String>(urlSession: URLSessionMock())
        let response = try await sut.get(resourceId: "420", params: ["key": "value"])
        XCTAssertEqual(response, "Success")
    }
    
    func testGetShouldReturnSuccess() async throws {
        let sut = RestApi<String>(urlSession: URLSessionMock())
        let response = try await sut.get()
        XCTAssertEqual(response, ["Success"])
    }
    
    func testGetWithHeaderShouldReturnSuccess() async throws {
        let sut = RestApi<String>(urlSession: URLSessionMock())
        let response = try await sut.get(header: ["key": "value"])
        XCTAssertEqual(response, ["Success"])
    }
    
    func testGetWithResourceIdShouldReturnSuccess() async throws {
        let sut = RestApi<String>(urlSession: URLSessionMock())
        let response = try await sut.get(resourceId: "420")
        XCTAssertEqual(response, "Success")
    }
    
    func testGetWithResourceIdAndHeaderShouldReturnSuccess() async throws {
        let sut = RestApi<String>(urlSession: URLSessionMock())
        let response = try await sut.get(resourceId: "420", header: ["key": "value"])
        XCTAssertEqual(response, "Success")
    }
    
    func testPostWithResourceShouldReturnSuccess() async throws {
        let sut = RestApi<String>(urlSession: URLSessionMock())
        let response = try await sut.post(resource: "")
        XCTAssertEqual(response, "Success")
    }
    
    func testPostWithResourceAndHeaderShouldReturnSuccess() async throws {
        let sut = RestApi<String>(urlSession: URLSessionMock())
        let response = try await sut.post(resource: "", header: ["key": "value"])
        XCTAssertEqual(response, "Success")
    }
    
    func testPostWithPayloadShouldReturnSuccess() async throws {
        let sut = RestApi<String>(urlSession: URLSessionMock())
        let response = try await sut.post(payload: ["key": "value"])
        XCTAssertEqual(response, "Success")
    }
    
    func testPostWithPayloadAndHeaderShouldReturnSuccess() async throws {
        let sut = RestApi<String>(urlSession: URLSessionMock())
        let response = try await sut.post(payload: ["key": "value"], header: ["key": "value"])
        XCTAssertEqual(response, "Success")
    }
    
    func testPutWithResourceShouldReturnSuccess() async throws {
        let sut = RestApi<String>(urlSession: URLSessionMock())
        let response = try await sut.put(resourceId: "420", resource: "")
        XCTAssertEqual(response, "Success")
    }
    
    func testPutWithResourceAndHeaderShouldReturnSuccess() async throws {
        let sut = RestApi<String>(urlSession: URLSessionMock())
        let response = try await sut.put(resourceId: "420", resource: "", header: ["key": "value"])
        XCTAssertEqual(response, "Success")
    }
    
    func testPutWithPayloadShouldReturnSuccess() async throws {
        let sut = RestApi<String>(urlSession: URLSessionMock())
        let response = try await sut.put(resourceId: "420", payload: ["key": "value"])
        XCTAssertEqual(response, "Success")
    }
    
    func testPutWithPayloadAndHeaderShouldReturnSuccess() async throws {
        let sut = RestApi<String>(urlSession: URLSessionMock())
        let response = try await sut.put(resourceId: "420", payload: ["key": "value"], header: ["key": "value"])
        XCTAssertEqual(response, "Success")
    }
    
    func testPatchWithResourceShouldReturnSuccess() async throws {
        let sut = RestApi<String>(urlSession: URLSessionMock())
        let response = try await sut.patch(resourceId: "420", resource: "")
        XCTAssertEqual(response, "Success")
    }
    
    func testPatchWithResourceAndHeaderShouldReturnSuccess() async throws {
        let sut = RestApi<String>(urlSession: URLSessionMock())
        let response = try await sut.patch(resourceId: "420", resource: "", header: ["key": "value"])
        XCTAssertEqual(response, "Success")
    }
    
    func testPatchWithPayloadShouldReturnSuccess() async throws {
        let sut = RestApi<String>(urlSession: URLSessionMock())
        let response = try await sut.patch(resourceId: "420", payload: ["key": "value"])
        XCTAssertEqual(response, "Success")
    }
    
    func testPatchWithPayloadAndHeaderShouldReturnSuccess() async throws {
        let sut = RestApi<String>(urlSession: URLSessionMock())
        let response = try await sut.patch(resourceId: "420", payload: ["key": "value"], header: ["key": "value"])
        XCTAssertEqual(response, "Success")
    }
    
    func testDeleteShouldReturnSuccess() async throws {
        let sut = RestApi<String>(urlSession: URLSessionMock())
        let response = try await sut.delete(resourceId: "420")
        XCTAssertEqual(response, "Success")
    }
    
    func testDeleteWithHeaderShouldReturnSuccess() async throws {
        let sut = RestApi<String>(urlSession: URLSessionMock())
        let response = try await sut.delete(resourceId: "420", header: ["key": "value"])
        XCTAssertEqual(response, "Success")
    }
}
