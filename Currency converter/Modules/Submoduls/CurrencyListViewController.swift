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
    
    var presenter: MainVCPresenterProtocol?
    
    private var defaultCurrencies = ["UAH", "USD", "EUR"]
    private var currenciesList = [String]()
    private var sections = ["Popular"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1)
        
        setupUI()
    }
    
    //MARK: - Setup UI
    
    private func setupUI() {
        setupTitleLabel()
        setupBackToMainVCButton()
        setupCurrencyListTable()
    }
    
    private func setupTitleLabel() {
        titleLabel.text = "Currency"
        titleLabel.font = R.font.sfProTextSemibold(size: 17)
    }
    
    private func setupBackToMainVCButton() {
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: R.font.sfProTextRegular(size: 17)!,
            .foregroundColor: UIColor.systemBlue
        ]
        
        backToMainVCButton.setAttributedTitle(NSAttributedString(string: "Converter", attributes: attributes), for: .normal)
    }
    
    @IBAction func presentMainVC(_ sender: Any) {
        let mainVC = MainViewController()
        mainVC.modalPresentationStyle = .fullScreen
        present(mainVC, animated: false)
    }
    
    private func setupCurrencyListTable() {
        currencyListTable.dataSource = self
        currencyListTable.delegate = self
        currencyListTable.register(UITableViewCell.self, forCellReuseIdentifier: "CurrenciesListTableViewCell")
        
        currencyListTable.backgroundColor = .clear
        
        currenciesList = defaultCurrencies
        currenciesList = presenter!.getCurrenciesListData()
        currenciesList.sort()
        configureSections()
        currencyListTable.reloadData()
    }
    
    private func configureSections() {
        for currency in currenciesList {
            let firstLetter = String(currency.prefix(1))
            if !sections.contains(firstLetter) {
                sections.append(firstLetter)
            }
        }
    }
    
    
}

extension CurrencyListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return defaultCurrencies.count
        } else {
            let sectionLetter = sections[section]
            return currenciesList.filter { String($0.prefix(1)) == sectionLetter }.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CurrenciesListTableViewCell", for: indexPath)
        
        if indexPath.section == 0 {
            cell.textLabel?.text = defaultCurrencies[indexPath.row]
        } else {
            let sectionLetter = sections[indexPath.section]
            let filteredCurrencies = currenciesList.filter { String($0.prefix(1)) == sectionLetter }
            cell.textLabel?.text = filteredCurrencies[indexPath.row]
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCurrency = currenciesList[indexPath.row]
        
        print("Choose currency is: \(selectedCurrency)")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.font = R.font.latoSemiBold(size: 17)
            header.textLabel?.textColor = UIColor.hex003166
            header.textLabel?.text = sections[section].capitalized
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48.0
    }
   
}
