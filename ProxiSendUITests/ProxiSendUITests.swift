//
//  ProxiSendUITests.swift
//  ProxiSendUITests
//
//  Created by Jackson Currie on 16/02/2025.
//

import XCTest

final class ProxiSendUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {}
    
    @MainActor
    func testTextEditorInput() throws {
        let app = XCUIApplication()
        app.launch()

        let textEditor = app.textViews.element(boundBy: 0)
        XCTAssertTrue(textEditor.exists, "Text editor should be present")
        
        let placeholderText = app.staticTexts["Enter text"]
        XCTAssertTrue(placeholderText.exists, "Placeholder should be visible before typing")

        textEditor.tap()
        textEditor.typeText("Hello ProxiSend!")

        XCTAssertFalse(placeholderText.exists, "Placeholder should disappear after typing")
        XCTAssertEqual(textEditor.value as? String, "Hello ProxiSend!", "Text should match user input")
    }
    
    @MainActor
    func testInfoPopupDismissal() throws {
        let app = XCUIApplication()
        app.launch()

        let infoButton = app.buttons["info.circle"]
        XCTAssertTrue(infoButton.exists, "Info button should exist")

        infoButton.tap()

        let aboutPopup = app.alerts["About ProxiSend"]
        XCTAssertTrue(aboutPopup.exists, "Info popup should appear after tapping (i)")

        let okButton = aboutPopup.buttons["OK"]
        XCTAssertTrue(okButton.exists, "OK button should be visible")

        okButton.tap()

        XCTAssertFalse(aboutPopup.exists, "Info popup should close after tapping OK")
    }

    @MainActor
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
