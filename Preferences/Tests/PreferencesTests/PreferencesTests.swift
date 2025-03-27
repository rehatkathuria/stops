import XCTest
@testable import Preferences

final class PreferencesTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Preferences().text, "Hello, World!")
    }
}
