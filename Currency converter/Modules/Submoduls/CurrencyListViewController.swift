//
//  CurrencyListViewController.swift
//  Currency converter
//
//  Created by Ivan Solohub on 13.10.2023.
//

import UIKit

class CurrencyListViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backToMainVCButton: UIButton!
    @IBOutlet weak var currencyListTable: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!

    
    var presenter: MainVCPresenterProtocol?
    
    private var currenciesList = [String]()
    private var sections = ["\(R.string.localizable.popular())"]

    private var searchingCurrencies = [String]()
    private var searching = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.hexF5F5F5
        
        setupUI()
    }
    
    //MARK: - Setup UI
    
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
        
        searchBar.showsBookmarkButton = true
        searchBar.setImage(UIImage(systemName: "mic.fill"), for: .bookmark, state: .normal)
    }
    
    private func setupBackToMainVCButton() {
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: R.font.sfProTextRegular(size: 17)!,
            .foregroundColor: UIColor.systemBlue
        ]
        
        backToMainVCButton.setAttributedTitle(NSAttributedString(string: R.string.localizable.converter(), attributes: attributes), for: .normal)
    }
    
    @IBAction func presentMainVC(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Private Methods
    
    private func setupCurrencyListTable() {
        currencyListTable.dataSource = self
        currencyListTable.delegate = self
        currencyListTable.register(UITableViewCell.self, forCellReuseIdentifier: Constants.currencyListTableCellIdentifier)
        
        currencyListTable.backgroundColor = .clear
        
        currenciesList = presenter!.getCurrenciesListData()
        currenciesList.sort()
        configureSections()
        currencyListTable.reloadData()
    }
    
    private func configureSections() {
        for currency in currenciesList {
            let firstLetter = String(currency.prefix(Constants.one))
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
            showMessage("Added: \(currencyName)")
        } else {
            showMessage("Added \(currencyCode)")
        }
        
    }

    private func showMessage(_ message: String) {
        let alertController = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        present(alertController, animated: true, completion: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            alertController.dismiss(animated: true, completion: nil)
        }
    }
}

extension CurrencyListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching {
            return searchingCurrencies.count
        } else {
            if section == .zero {
                return presenter!.getDefaultCurrencies().count
            } else {
                let sectionLetter = sections[section]
                return currenciesList.filter { String($0.prefix(Constants.one)) == sectionLetter }.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.currencyListTableCellIdentifier, for: indexPath)
        
        if searching {
            if indexPath.row < searchingCurrencies.count {
                cell.textLabel?.text = configureCellsNames(for: searchingCurrencies[indexPath.row])
            }
        } else {
            if indexPath.section == .zero {
                let currencyCode = presenter!.getDefaultCurrencies()[indexPath.row]
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
        
        if searching {
            let currencyCode = searchingCurrencies[indexPath.row]
            presenter?.addCurrency(currencyCode)
            showMessage(for: indexPath, currencyCode: currencyCode)
        } else {
            let sectionLetter = sections[indexPath.section]
            let filteredCurrencies = currenciesList.filter { String($0.prefix(Constants.one)) == sectionLetter }
                
            if indexPath.section == .zero {
                let currencyCode = presenter!.getDefaultCurrencies()[indexPath.row]
                presenter?.addCurrency(currencyCode)
                showMessage(for: indexPath, currencyCode: currencyCode)
            } else {
                let currencyCode = filteredCurrencies[indexPath.row]
                presenter?.addCurrency(currencyCode)
                showMessage(for: indexPath, currencyCode: currencyCode)
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return searching ? 1 : sections.count
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
                return currency.lowercased().contains(searchText.lowercased()) || currencyDescriptions[currency]?.lowercased().contains(searchText.lowercased()) ?? false
            }
            searching = true
        }
        currencyListTable.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            searchBar.resignFirstResponder()
        }

}

extension CurrencyListViewController {
    private enum Constants {
        static let sectionHeaderHeight: CGFloat = 40.0
        static let tableRowHegiht: CGFloat = 48.0
        static let currencyListTableCellIdentifier: String = "CurrenciesListTableViewCell"
        static let one: Int = 1
    }
}
