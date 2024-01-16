//
//  MainPresenterPublicTests.swift
//  MainPresenterPublicTests
//
//  Created by Ivan Solohub on 02.01.2024.
//

import XCTest
@testable import Currency_converter

final class MainPresenterPublicTests: XCTestCase {

    private var viewMock: MainViewProtocolMock!
    private var presenter: MainPresenter!
//    private var mockPresenter: PresenterProptocolMock!

    override func setUp() {
        super.setUp()
        viewMock = MainViewProtocolMock()
        presenter = MainPresenter(view: viewMock)
 //       mockPresenter = PresenterProptocolMockMock()
    }

    override func tearDown() {
        viewMock = nil
        presenter = nil
 //       mockPresenter = nil
        super.tearDown()
    }

    func testGetCurrencyDataOfflineMode() {
        presenter.getCurrencyData(offlineMode: true)
        XCTAssertTrue(viewMock.reloadDataCurrencyInfoTableCalled)
        XCTAssertTrue(viewMock.updateUIWithCalled)
    }

    func testCreateShareText() {
        let currencyNames = ["USD", "EUR"]
        let currencyValues = [1.0, 0.9]

        let expectedString = "USD: 1.00\nEUR: 0.90\n"

        let resultString = presenter.createShareText(currencyNames: currencyNames, currencyValues: currencyValues)

        XCTAssertEqual(resultString, expectedString)
    }

    func testGetActiveCurrenciesCount() {
        let mockPresenter = PresenterProptocolMockMock()
        mockPresenter.activeCurrencies = [
            CurrencyViewModel(name: "USD", sellRate: 1.0, buyRate: 1.0),
            CurrencyViewModel(name: "EUR", sellRate: 0.9, buyRate: 0.85)
        ]

        mockPresenter.getActiveCurrenciesCountReturnValue = mockPresenter.activeCurrencies.count
        let count = mockPresenter.getActiveCurrenciesCount()

        XCTAssertEqual(count, 2)
    }

    func testRemoveActiveCurrency() {
        let mockPresenter = PresenterProptocolMockMock()
        mockPresenter.activeCurrencies = [
            CurrencyViewModel(name: "USD", sellRate: 1.0, buyRate: 1.0),
            CurrencyViewModel(name: "EUR", sellRate: 0.9, buyRate: 0.85)
        ]

        mockPresenter.getActiveCurrenciesCountReturnValue = mockPresenter.activeCurrencies.count

        mockPresenter.getActiveCurrenciesCountClosure = {
            return mockPresenter.getActiveCurrenciesCountReturnValue
        }

        XCTAssertEqual(mockPresenter.getActiveCurrenciesCount(), 2)

        mockPresenter.removeActiveCurrencies(at: 0)
        XCTAssertEqual(mockPresenter.getActiveCurrenciesCount(), 1)

//        let remainingCurrency = mockPresenter.activeCurrencies.first
//        XCTAssertEqual(remainingCurrency?.name, "EUR")
//        XCTAssertEqual(remainingCurrency?.sellRate, 0.9)
//        XCTAssertEqual(remainingCurrency?.buyRate, 0.85)
    }

    func testRemoveActiveCurrencyCallsViewMethods() {

    }

/*
    func testConfigureLastUpdatedLabel() {
        let testDate = "Mon, 01 Jan 2024 12:00:00 GMT"
        presenter.currencyData.timeLastUpdateUtc = testDate

        let result = presenter.configureLastUpdatedLabel()

        let expectedOutput = "last_updated \n01 Jan 2024 12:00 PM"
        XCTAssertEqual(result, expectedOutput)
    }

    func testGetCurrencyDataOnlineMode() {

    }

    func testGetActiveCurrenciesCount() {
        let initialCurrencies = [
            CurrencyViewModel(name: "USD", sellRate: 1.0, buyRate: 1.0, calculatedResult: nil),
            CurrencyViewModel(name: "EUR", sellRate: 1.0, buyRate: 1.0, calculatedResult: nil)
        ]
        
        presenter.allCurrenciesData = initialCurrencies
        
        XCTAssertTrue(presenter.getActiveCurrencies().isEmpty)
        XCTAssertEqual(presenter.getActiveCurrenciesCount(), 0)

        presenter.addCurrency("USD")
        presenter.addCurrency("EUR")

        XCTAssertEqual(presenter.getActiveCurrenciesCount(), 2)
    }
 */
}
