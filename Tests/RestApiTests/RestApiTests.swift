import XCTest
@testable import RestApi

final class RestApiTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(RestApi<String>().baseUrl, "")
    }
}
