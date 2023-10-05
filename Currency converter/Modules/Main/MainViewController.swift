//
//  MainViewController.swift
//  Currency converter
//
//  Created by Ivan Solohub on 15.09.2023.
//

import UIKit
import Reachability

protocol MainViewProtocol: AnyObject {
    func updateUI(with currencyData: CurrencyData)
}


class MainViewController: UIViewController {
    
    @IBOutlet weak private var mainTitleLabel: UILabel!
    @IBOutlet weak private var currencyShowView: UIView!
    @IBOutlet weak private var sellBuyModeSegmntContrl: UISegmentedControl!
    @IBOutlet weak private var currencyInfoTableView: UITableView!
    @IBOutlet weak private var addCurrencyButton: UIButton!
    @IBOutlet weak private var updatedInfoLabel: UILabel!
    
    private var presenter: MainVCPresenterProtocol!
    
    private var currencies = ["UAH", "USD", "EUR"]
    private var currencyValues: [Double] = []
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = MainVCPresenter(view: self)
        checkInternetConnectionAndGetData()
        
        setupUI()
    }
    
    //MARK: - Setup UI
    
    private func setupUI() {
        setupMainTitleLabel()
        setupCurrencyShowView()
        setupSwitchModeSegmentedControl()
   //     setupCurrencyInfoTableView()
        setupAddCurrencyButton()
        setupUpdateInfoLabel()
    }
    
    private func setupMainTitleLabel() {
        mainTitleLabel.text = R.string.localizable.currency_converter()
        mainTitleLabel.font = R.font.latoExtraBold(size: 24)
        mainTitleLabel.textColor = .white
    }
    
    private func setupCurrencyShowView() {
        currencyShowView.layer.cornerRadius = 10
        currencyShowView.backgroundColor = .white
        
        currencyShowView.applyShadow(opacity: 0.2, offset: CGSize(width: .zero, height: 5), radius: 2, cornerRadius: 10)
    }
    
    private func setupSwitchModeSegmentedControl() {
        sellBuyModeSegmntContrl.setTitle(R.string.localizable.sell(), forSegmentAt: .zero)
        sellBuyModeSegmntContrl.setTitle(R.string.localizable.buy(), forSegmentAt: 1)
        sellBuyModeSegmntContrl.backgroundColor = .white
        sellBuyModeSegmntContrl.selectedSegmentTintColor = UIColor.hex007AFF
        let normalTextAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.hex003166,
            .font: R.font.latoRegular(size: 18)!
        ]
        sellBuyModeSegmntContrl.setTitleTextAttributes(normalTextAttributes, for: .normal)
        
        let selectedTextAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white,
            .font: R.font.latoRegular(size: 18)!
        ]
        sellBuyModeSegmntContrl.setTitleTextAttributes(selectedTextAttributes, for: .selected)
    }
    
    private func setupCurrencyInfoTableView() {
        currencyInfoTableView.dataSource = self
        currencyInfoTableView.delegate = self
        currencyInfoTableView.separatorColor = .clear
        currencyInfoTableView.register(UINib(nibName: "CurrencyValueTableViewCell", bundle: nil), forCellReuseIdentifier: "CurrencyValuesTableViewCell")
    }
    
    private func setupAddCurrencyButton() {
        addCurrencyButton.setAttributedTitle(presenter.createTitleNameForButton(text: R.string.localizable.add_currency(), textSize: 13), for: .normal)
    }
    
    private func setupUpdateInfoLabel() {
        updatedInfoLabel.font = R.font.latoRegular(size: 12)
        updatedInfoLabel.textColor = UIColor.hex575757
    }
    
    //MARK: - Private Methods
    
    private func checkInternetConnectionAndGetData() {
        let reachability = try! Reachability()
        if reachability.connection == .wifi || reachability.connection == .cellular {
            
            presenter.getCurrencyData()
        } else {
            showNoInternetAlert()
        }
    }
    
    private func showNoInternetAlert() {
        let alertController = UIAlertController(
            title: R.string.localizable.no_internet_connection(),
            message: R.string.localizable.please_allow_this_app_to_internet_access(),
            preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: R.string.localizable.use_offline(), style: .cancel, handler: nil)
        let settingsAction = UIAlertAction(title: R.string.localizable.settings(), style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL)
                }
            }
        
        alertController.addAction(cancelAction)
        alertController.addAction(settingsAction)

        present(alertController, animated: true, completion: nil)
    }
   /*
    private func convertCurrency(fromCurrency: String, toCurrency: String, amount: Double) -> Double? {
        guard let fromRate = activeCurrencies[fromCurrency],
              let toRate = activeCurrencies[toCurrency] else {
            return nil
        }

        return (amount / Double(fromRate)) * Double(toRate)
    }
    */
}

extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currencies.count
    }
 
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CurrencyValuesTableViewCell", for: indexPath) as! CurrencyValueTableViewCell
        
        let currencyName = currencies[indexPath.row]
        cell.currencyNameLabel.attributedText = presenter.createTitleNameForCurrencyLabel(text: currencyName)
        
    //    let currencyValue = currencyValues[indexPath.row]
        
    //    let viewModel = CurrencyCellViewModel(currencyName: presenter.createTitleNameForCurrencyLabel(text: currencyName), currencyValue: currencyValue)
    //    cell.configureCell(with: viewModel)
        
        return cell
    }
}

extension MainViewController: MainViewProtocol {
    func updateUI(with currencyData: CurrencyData) {
        
        for currency in currencies {
            if let exchangeRate = currencyData.conversion_rates[currency] {
                currencyValues.append(exchangeRate)
            }
        }

        updatedInfoLabel.text = presenter.configureLastUpdatedLabel()
        setupCurrencyInfoTableView()
        currencyInfoTableView.reloadData()
    }
}

extension MainViewController {
    private enum Constants {
        
    }
}
