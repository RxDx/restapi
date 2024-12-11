import Foundation
import Testing
@testable import RestApi

struct RestApiTests {
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

    @Test func requestWithDebugShouldReturnSuccess() async throws {
        let sut = RestApi(debug: true, urlSession: URLSessionMock())
        let response: String = try await sut.get(resourceId: "0")
        #expect(response == "Success")
    }
    
    @Test func requestWithHeaderShouldReturnSuccess() async throws {
        let sut = RestApi(header: ["key": "value"], urlSession: URLSessionMock())
        let response: String = try await sut.get(resourceId: "0")
        #expect(response == "Success")
    }
    
    @Test func requestWithRequestHeaderShouldReturnSuccess() async throws {
        let sut = RestApi(urlSession: URLSessionMock())
        let response: String = try await sut.get(resourceId: "0", header: ["key": "value"])
        #expect(response == "Success")
    }
    
    @Test func requestWithUrlShouldReturnSuccess() async throws {
        let sut = RestApi(urlSession: URLSessionMock())
        let response: String = try await sut.get(url: "", resourceId: "420")
        #expect(response == "Success")
    }
    
    @Test func requestWithSuffixShouldReturnSuccess() async throws {
        let sut = RestApi(urlSession: URLSessionMock())
        let response: String = try await sut.get(resourceId: "420", suffix: "")
        #expect(response == "Success")
    }
    
    @Test func requestWithPathShouldReturnSuccess() async throws {
        let sut = RestApi(urlSession: URLSessionMock())
        let response: String = try await sut.get(path: "", resourceId: "420")
        #expect(response == "Success")
    }
    
    @Test func requestWithParamsShouldReturnSuccess() async throws {
        let sut = RestApi(urlSession: URLSessionMock())
        let response: String = try await sut.get(resourceId: "420", params: ["key": "value"])
        #expect(response == "Success")
    }
    
    @Test func getShouldReturnSuccess() async throws {
        let sut = RestApi(urlSession: URLSessionMock())
        let response: [String] = try await sut.get()
        #expect(response == ["Success"])
    }
    
    @Test func getWithResourceIdShouldReturnSuccess() async throws {
        let sut = RestApi(urlSession: URLSessionMock())
        let response: String = try await sut.get(resourceId: "0")
        #expect(response == "Success")
    }
    
    @Test func postWithResourceShouldReturnSuccess() async throws {
        let sut = RestApi(urlSession: URLSessionMock())
        let response: String? = try await sut.post(resource: "")
        #expect(response == "Success")
    }
    
    @Test func postWithResourceShouldReturn() async throws {
        let urlSession = URLSessionMock()
        let sut = RestApi(urlSession: urlSession)
        try await sut.post(resource: "")
        #expect(urlSession.urlSessionCalled)
    }
    
    @Test func postWithPayloadShouldReturnSuccess() async throws {
        let sut = RestApi(urlSession: URLSessionMock())
        let response: String? = try await sut.post(payload: ["key": "value"])
        #expect(response == "Success")
    }
    
    @Test func postWithPayloadShouldReturn() async throws {
        let urlSession = URLSessionMock()
        let sut = RestApi(urlSession: urlSession)
        try await sut.post(payload: ["key": "value"])
        #expect(urlSession.urlSessionCalled)
    }
    
    @Test func putWithResourceShouldReturnSuccess() async throws {
        let sut = RestApi(urlSession: URLSessionMock())
        let response: String? = try await sut.put(resourceId: "0", resource: "")
        #expect(response == "Success")
    }
    
    @Test func putWithResourceShouldReturn() async throws {
        let urlSession = URLSessionMock()
        let sut = RestApi(urlSession: urlSession)
        try await sut.put(resourceId: "0", resource: "")
        #expect(urlSession.urlSessionCalled)
    }
    
    @Test func putWithPayloadShouldReturnSuccess() async throws {
        let sut = RestApi(urlSession: URLSessionMock())
        let response: String? = try await sut.put(resourceId: "0", payload: ["key": "value"])
        #expect(response == "Success")
    }
    
    @Test func putWithPayloadShouldReturn() async throws {
        let urlSession = URLSessionMock()
        let sut = RestApi(urlSession: urlSession)
        try await sut.put(resourceId: "0", payload: ["key": "value"])
        #expect(urlSession.urlSessionCalled)
    }
    
    @Test func patchWithResourceShouldReturnSuccess() async throws {
        let sut = RestApi(urlSession: URLSessionMock())
        let response: String? = try await sut.patch(resourceId: "0", resource: "")
        #expect(response == "Success")
    }
    
    @Test func patchWithResourceShouldReturn() async throws {
        let urlSession = URLSessionMock()
        let sut = RestApi(urlSession: urlSession)
        try await sut.patch(resourceId: "0", resource: "")
        #expect(urlSession.urlSessionCalled)
    }
    
    @Test func patchWithPayloadShouldReturnSuccess() async throws {
        let sut = RestApi(urlSession: URLSessionMock())
        let response: String? = try await sut.patch(resourceId: "0", payload: ["key": "value"])
        #expect(response == "Success")
    }
    
    @Test func patchWithPayloadShouldReturn() async throws {
        let urlSession = URLSessionMock()
        let sut = RestApi(urlSession: urlSession)
        try await sut.patch(resourceId: "0", payload: ["key": "value"])
        #expect(urlSession.urlSessionCalled)
    }
    
    @Test func deleteShouldReturnSuccess() async throws {
        let sut = RestApi(urlSession: URLSessionMock())
        let response: String? = try await sut.delete(resourceId: "0")
        #expect(response == "Success")
    }
    
    @Test func testDeleteShouldReturn() async throws {
        let urlSession = URLSessionMock()
        let sut = RestApi(urlSession: urlSession)
        try await sut.delete(resourceId: "0")
        #expect(urlSession.urlSessionCalled)
    }
}
