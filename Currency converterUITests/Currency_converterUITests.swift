//
//  Currency_converterUITests.swift
//  Currency converterUITests
//
//  Created by Ivan Solohub on 23.01.2024.
//

import XCTest

final class CurrencyConverterUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
        super.tearDown()
    }

    func testCurrencyListTitleLabel() throws {
        app.buttons["Add Currency"].tap()

        let mainLabel = app.staticTexts["currencyListVCTitleLabel"]
        let expectedText = "Currency"

        XCTAssertEqual(mainLabel.label, expectedText)
    }

    func testExchangeRateInfoMessageLabel() throws {
        app.buttons["exchangeRateVCButton"].tap()

        let infoLabel = app.staticTexts["exchangeRateVCInfoLabel"]
        let expectedText = "Currency exchange rates are available from 01.12.2014"

        XCTAssertEqual(infoLabel.label, expectedText)
    }

    func testExchangeRateTFExist() throws {
        app.buttons["exchangeRateVCButton"].tap()
        XCTAssertTrue(app.textFields["exchangeRatesTF"].exists)
    }

    func testMainVCObjectsExists() throws {
        XCTAssertTrue(app.staticTexts["mainTitleLabel"].exists)
        XCTAssertTrue(app.staticTexts["mainLastUpdatedLabel"].exists)
        XCTAssertTrue(app.buttons["shareButton"].exists)
    }
}
