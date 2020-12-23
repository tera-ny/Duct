import XCTest
@testable import Duct

final class DuctTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Duct().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
