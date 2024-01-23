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

    override func setUp() {
        super.setUp()
        viewMock = MainViewProtocolMock()
        presenter = MainPresenter(view: viewMock)
    }

    override func tearDown() {
        viewMock = nil
        presenter = nil
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
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
        UserDefaultsManager.shared.saveAllCurrenciesData([CurrencyViewModel(name: "USD", sellRate: 1.0, buyRate: 1.0)])

        let sut = MainPresenter(view: viewMock)
        sut.getCurrencyData(offlineMode: true)

        XCTAssertEqual(sut.getActiveCurrenciesCount(), 0)

        sut.addCurrency("USD")

        XCTAssertEqual(sut.getActiveCurrenciesCount(), 1)
    }

    func testRemoveActiveCurrency1() {
        let currencies = CurrencyViewModel(name: "EUR", sellRate: 0.9, buyRate: 0.8)
        UserDefaultsManager.shared.saveBaseCurrencies([currencies])

        let sut = MainPresenter(view: viewMock)
        sut.getCurrencyData(offlineMode: true)

        sut.removeActiveCurrencies(at: 0)
        XCTAssertEqual(sut.getActiveCurrenciesCount(), 0)
    }

    func testRemoveActiveCurrency2() {
        let currencies = [CurrencyViewModel(name: "EUR", sellRate: 0.9, buyRate: 0.8),
                          CurrencyViewModel(name: "GBP", sellRate: 1.5, buyRate: 1.4),
                          CurrencyViewModel(name: "CAD", sellRate: 2.0, buyRate: 1.9)]
        UserDefaultsManager.shared.saveBaseCurrencies(currencies)

        let sut = MainPresenter(view: viewMock)
        sut.getCurrencyData(offlineMode: true)

        sut.removeActiveCurrencies(at: 1)
        XCTAssertEqual(sut.getActiveCurrenciesCount(), 2)
    }

    func testRemoveActiveCurrencyCallsViewMethods() {
        let currencies = [CurrencyViewModel(name: "EUR", sellRate: 0.9, buyRate: 0.8),
                          CurrencyViewModel(name: "GBP", sellRate: 1.5, buyRate: 1.4),
                          CurrencyViewModel(name: "CAD", sellRate: 2.0, buyRate: 1.9)]
        UserDefaultsManager.shared.saveBaseCurrencies(currencies)
        presenter.getCurrencyData(offlineMode: true)
        XCTAssertTrue(viewMock.reloadDataCurrencyInfoTableCalled)
    }

    func testGetAllCurrenciesData() {
        let testCurrencies = [
            CurrencyViewModel(name: "USD", sellRate: 1.0, buyRate: 1.0),
            CurrencyViewModel(name: "EUR", sellRate: 0.9, buyRate: 0.8),
            CurrencyViewModel(name: "GBP", sellRate: 1.5, buyRate: 1.4)
        ]

        UserDefaultsManager.shared.saveAllCurrenciesData(testCurrencies)
        presenter.getCurrencyData(offlineMode: true)

        let resultCurrencies = presenter.getAllCurrenciesData()
        XCTAssertEqual(resultCurrencies, testCurrencies)
    }

    func testUpdateCurrencyValues() {

        UserDefaultsManager.shared.saveBaseCurrencies([CurrencyViewModel(name: "USD", sellRate: 1.0, buyRate: 1.0)])
        presenter.getCurrencyData(offlineMode: true)

        presenter.addCurrency("USD")

        presenter.setConvertingMode(.sell)

        let inputValue = "2.0"
        let inputIndexUSD = presenter.getActiveCurrencies().firstIndex { $0.name == "USD" } ?? 0
        presenter.updateCurrencyValues(inputValue: inputValue, atIndex: inputIndexUSD)

        let updatedCurrencies = presenter.getActiveCurrencies()

        if let usdCurrency = updatedCurrencies.first(where: { $0.name == "USD" }) {
            XCTAssertEqual(usdCurrency.calculatedResult, 2.0)
        }
    }
}
