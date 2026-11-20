//  ForecastFlowUITests.swift
//
//  End-to-end check on the simulator: postal code -> Apple geocoding -> Core ML forecast -> screen.
//
//  Needs network access for Apple's geocoder. Screenshots are attached to the test result
//  (kept even on success) so the screens can be reviewed without running the app by hand.

import XCTest

/// Drives the real app like a user would.
final class ForecastFlowUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    /// Searches for a postal code and checks the neighbourhood, ranks and patrol plan appear.
    @MainActor
    func testPostalCodeShowsForecast() {
        let app: XCUIApplication = XCUIApplication()
        app.launch()

        let field: XCUIElement = app.textFields["Postal code or neighbourhood"]
        XCTAssertTrue(field.waitForExistence(timeout: 10))
        field.tap()
        field.clearAndType("M6A 2T9")  // Yorkdale Shopping Centre
        app.buttons["Show forecast"].tap()

        XCTAssertTrue(app.staticTexts["Yorkdale-Glen Park (31)"].waitForExistence(timeout: 30))
        attachScreenshot(of: app, named: "1-summary")

        app.swipeUp()
        attachScreenshot(of: app, named: "2-chart")
        app.swipeUp()
        XCTAssertTrue(app.staticTexts["Patrol plan"].exists || app.staticTexts["PATROL PLAN"].exists)
        attachScreenshot(of: app, named: "3-patrol-plan")
    }

    private func attachScreenshot(of app: XCUIApplication, named name: String) {
        let attachment: XCTAttachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}

private extension XCUIElement {
    // The field starts with a sample value, so delete it before typing.
    func clearAndType(_ text: String) {
        let existing: String = value as? String ?? ""
        typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: existing.count) + text)
    }
}
