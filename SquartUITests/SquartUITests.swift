import XCTest

final class SquartUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLandingScreenShowsPrimaryActions() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.staticTexts["Squart"].waitForExistence(timeout: 4))
        XCTAssertTrue(app.buttons["Start Game"].exists)
        XCTAssertTrue(app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "Daily Challenge")).firstMatch.exists)
    }
}
