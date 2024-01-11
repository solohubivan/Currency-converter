// Generated using Sourcery 2.1.3 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import UIKit
@testable import Currency_converter

class MainViewProtocolMock: MainViewProtocol {

    //MARK: - updateUI

    var updateUIWithCallsCount = 0
    var updateUIWithCalled: Bool {
        return updateUIWithCallsCount > 0
    }
    var updateUIWithReceivedCurrencyData: CurrencyData?
    var updateUIWithReceivedInvocations: [CurrencyData] = []
    var updateUIWithClosure: ((CurrencyData) -> Void)?

    func updateUI(with currencyData: CurrencyData) {
        updateUIWithCallsCount += 1
        updateUIWithReceivedCurrencyData = currencyData
        updateUIWithReceivedInvocations.append(currencyData)
        updateUIWithClosure?(currencyData)
    }

    //MARK: - reloadDataCurrencyInfoTable

    var reloadDataCurrencyInfoTableCallsCount = 0
    var reloadDataCurrencyInfoTableCalled: Bool {
        return reloadDataCurrencyInfoTableCallsCount > 0
    }
    var reloadDataCurrencyInfoTableClosure: (() -> Void)?

    func reloadDataCurrencyInfoTable() {
        reloadDataCurrencyInfoTableCallsCount += 1
        reloadDataCurrencyInfoTableClosure?()
    }

    //MARK: - updateTableHeight

    var updateTableHeightCallsCount = 0
    var updateTableHeightCalled: Bool {
        return updateTableHeightCallsCount > 0
    }
    var updateTableHeightClosure: (() -> Void)?

    func updateTableHeight() {
        updateTableHeightCallsCount += 1
        updateTableHeightClosure?()
    }

}
