//
//  CurrencyListViewController.swift
//  Currency converter
//
//  Created by Ivan Solohub on 13.10.2023.
//

import UIKit
import InstantSearchVoiceOverlay
import Speech

class CurrencyListViewController: UIViewController, VoiceOverlayDelegate {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backToMainVCButton: UIButton!
    @IBOutlet weak var currencyListTable: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!

    var presenter: MainVCPresenterProtocol?

    private var currenciesList = [String]()
    private let popularCurrencies = ["UAH", "USD", "EUR"]
    private var sections = ["\(R.string.localizable.popular())"]

    private var searchingCurrencies = [String]()
    private var searching = false

    private let voiceOverlay = VoiceOverlayController()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.hexF5F5F5

        setupUI()
    }

    // MARK: - Setup UI

    private func setupUI() {
        setupTitleLabel()
        setupBackToMainVCButton()
        setupCurrencyListTable()
        setupSearchBar()
    }

    private func setupTitleLabel() {
        titleLabel.text = R.string.localizable.currency()
        titleLabel.font = R.font.sfProTextSemibold(size: 17)
    }

    private func setupSearchBar() {
        searchBar.delegate = self
        searchBar.barTintColor = UIColor.hexF5F5F5

        if let textField = searchBar.value(forKey: "searchField") as? UITextField {
            textField.overrideUserInterfaceStyle = .light
        }

        searchBar.showsBookmarkButton = true
        searchBar.setImage(UIImage(systemName: "mic.fill"), for: .bookmark, state: .normal)
    }

    private func setupBackToMainVCButton() {

        let attributes: [NSAttributedString.Key: Any] = [
            .font: R.font.sfProTextRegular(size: 17)!,
            .foregroundColor: UIColor.systemBlue
        ]

        let attributedTitle = NSAttributedString(string: R.string.localizable.converter(), attributes: attributes)
        backToMainVCButton.setAttributedTitle(attributedTitle, for: .normal)
    }

    @IBAction func presentMainVC(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    private func setupCurrencyListTable() {
        currencyListTable.dataSource = self
        currencyListTable.delegate = self
        currencyListTable.register(UITableViewCell.self, forCellReuseIdentifier: Constants.currencyListTableCellId)

        currencyListTable.backgroundColor = .clear
        currencyListTable.overrideUserInterfaceStyle = .light

        currenciesList = presenter!.getAllCurrenciesData().map { $0.name }
        currenciesList.sort()
        configureSections()
        currencyListTable.reloadData()
    }

    // MARK: - Private Methods

    private func configureSections() {
        sections = ["\(R.string.localizable.popular())"]
            for currency in currenciesList where !popularCurrencies.contains(currency) {
                let firstLetter = String(currency.prefix(1))
                if !sections.contains(firstLetter) {
                    sections.append(firstLetter)
                }
            }
    }

    private func configureCellsNames(for currencyCode: String) -> String {
        if let currencyName = currencyDescriptions[currencyCode] {
                return "\(currencyCode) - \(currencyName)"
            } else {
                return currencyCode
            }
    }

    private func showMessage(for indexPath: IndexPath, currencyCode: String) {
        if let currencyName = currencyDescriptions[currencyCode] {
            showInformation("\(R.string.localizable.added()): \(currencyName)")
        } else {
            showInformation("\(R.string.localizable.added()): \(currencyCode)")
        }

    }

    private func showInformation(_ message: String) {
        let alertController = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        present(alertController, animated: true, completion: nil)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            alertController.dismiss(animated: true, completion: nil)
        }
    }
}

// MARK: - Extensions

extension CurrencyListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching {
            return searchingCurrencies.count
        } else {
            if section == .zero {
                return popularCurrencies.count
            } else {
                let sectionLetter = sections[section]
                return currenciesList.filter { String($0.prefix(Constants.one)) == sectionLetter }.count
            }
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.currencyListTableCellId, for: indexPath)

        if searching {
            if indexPath.row < searchingCurrencies.count {
                cell.textLabel?.text = configureCellsNames(for: searchingCurrencies[indexPath.row])
            }
        } else {
            if indexPath.section == .zero {
                let currencyCode = popularCurrencies[indexPath.row]
                cell.textLabel?.text = configureCellsNames(for: currencyCode)
            } else {
                let sectionLetter = sections[indexPath.section]
                let filteredCurrencies = currenciesList.filter { String($0.prefix(Constants.one)) == sectionLetter }
                let currencyCode = filteredCurrencies[indexPath.row]
                cell.textLabel?.text = configureCellsNames(for: currencyCode)
            }
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let currencyCode: String
        let sectionLetter = sections[indexPath.section]
        let filteredCurrencies = currenciesList.filter { String($0.prefix(Constants.one)) == sectionLetter }

        if searching {
            currencyCode = searchingCurrencies[indexPath.row]
            presenter?.addCurrency(currencyCode)
            showMessage(for: indexPath, currencyCode: currencyCode)
        } else {
            if indexPath.section == .zero {
                currencyCode = popularCurrencies[indexPath.row]
                presenter?.addCurrency(currencyCode)
                showMessage(for: indexPath, currencyCode: currencyCode)
            } else {
                currencyCode = filteredCurrencies[indexPath.row]
                presenter?.addCurrency(currencyCode)
                showMessage(for: indexPath, currencyCode: currencyCode)
            }
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return searching ? Constants.one : sections.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return searching ? nil : sections[section]
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.font = R.font.latoSemiBold(size: 17)
            header.textLabel?.textColor = UIColor.hex003166
            header.textLabel?.text = sections[section].capitalized
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Constants.sectionHeaderHeight
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.tableRowHegiht
    }
}

extension CurrencyListViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            searching = false
        } else {
            searchingCurrencies = currenciesList.filter { currency in
                let currencyLowercased = currency.lowercased()
                let searchTextLowercased = searchText.lowercased()
                let matchesCurrency = currencyLowercased.contains(searchTextLowercased)

                let description = currencyDescriptions[currency]?.lowercased()
                let descriptionMatches = description?.contains(searchTextLowercased) ?? false

                return matchesCurrency || descriptionMatches
            }
            searching = true
        }
        currencyListTable.reloadData()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            searchBar.resignFirstResponder()
    }

    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        voiceOverlay.delegate = self
        voiceOverlay.settings.autoStop = true
        voiceOverlay.settings.autoStopTimeout = 1

        voiceOverlay.start(on: self, textHandler: { text, final, _ in

            if final {
                print("FinalText: \(text)")
                DispatchQueue.main.async {
                    self.searchBar.text = text
                    self.searchBar(searchBar, textDidChange: text)
                }
            }
        }, errorHandler: { _ in

        })
    }

    func recording(text: String?, final: Bool?, error: Error?) {

    }

}

extension CurrencyListViewController {
    private enum Constants {
        static let sectionHeaderHeight: CGFloat = 40.0
        static let tableRowHegiht: CGFloat = 48.0
        static let currencyListTableCellId: String = "CurrenciesListTableViewCell"
        static let one: Int = 1
    }
}
