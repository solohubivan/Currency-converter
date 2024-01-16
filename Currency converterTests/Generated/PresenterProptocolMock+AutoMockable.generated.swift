// Generated using Sourcery 2.1.3 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import UIKit
@testable import Currency_converter

class PresenterProptocolMockMock: PresenterProptocolMock {
    var activeCurrencies: [CurrencyViewModel] = []

    //MARK: - getActiveCurrenciesCount

    var getActiveCurrenciesCountCallsCount = 0
    var getActiveCurrenciesCountCalled: Bool {
        return getActiveCurrenciesCountCallsCount > 0
    }
    var getActiveCurrenciesCountReturnValue: Int!
    var getActiveCurrenciesCountClosure: (() -> Int)?

    func getActiveCurrenciesCount() -> Int {
        getActiveCurrenciesCountCallsCount += 1
        return getActiveCurrenciesCountClosure.map({ $0() }) ?? getActiveCurrenciesCountReturnValue
    }

    //MARK: - removeActiveCurrencies

    var removeActiveCurrenciesAtCallsCount = 0
    var removeActiveCurrenciesAtCalled: Bool {
        return removeActiveCurrenciesAtCallsCount > 0
    }
    var removeActiveCurrenciesAtReceivedIndex: Int?
    var removeActiveCurrenciesAtReceivedInvocations: [Int] = []
    var removeActiveCurrenciesAtClosure: ((Int) -> Void)?

    func removeActiveCurrencies(at index: Int) {
        removeActiveCurrenciesAtCallsCount += 1
        removeActiveCurrenciesAtReceivedIndex = index
        removeActiveCurrenciesAtReceivedInvocations.append(index)
        removeActiveCurrenciesAtClosure?(index)
    }

}
