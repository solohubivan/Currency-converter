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
    
    private let defaultCurrencies = ["UAH", "USD", "EUR"]
    private var currencies: [String] = []
    
    var activeCurrencies: [String: Double] = [:]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = MainVCPresenter(view: self)
        checkInternetConnectionAndGetData()
        
        currencies = defaultCurrencies
        
        setupUI()
    }
   /*
    private func getCurrencyDefaultValues() {
        for currency in currencies {
            if let exchangeRate = currencyData.conversion_rates[currency] {
                activeCurrencies[currency] = exchangeRate
            }
        }
        print(activeCurrencies)
    }
*/
    //MARK: - Setup UI
    
    private func setupUI() {
        setupMainTitleLabel()
        setupCurrencyShowView()
        setupSwitchModeSegmentedControl()
        setupCurrencyInfoTableView()
        setupAddCurrencyButton()
        setupUpdateInfoLabel()
    }
    
    private func setupMainTitleLabel() {
        mainTitleLabel.text = "Currency Converter"
        mainTitleLabel.font = R.font.latoExtraBold(size: 24)
        mainTitleLabel.textColor = .white
    }
    
    private func setupCurrencyShowView() {
        currencyShowView.layer.cornerRadius = 10
        currencyShowView.backgroundColor = .white
        
        currencyShowView.applyShadow(opacity: 0.2, offset: CGSize(width: .zero, height: 5), radius: 2, cornerRadius: 10)
    }
    
    private func setupSwitchModeSegmentedControl() {
        sellBuyModeSegmntContrl.setTitle("Sell", forSegmentAt: 0)
        sellBuyModeSegmntContrl.setTitle("Buy", forSegmentAt: 1)
        sellBuyModeSegmntContrl.backgroundColor = .white
        sellBuyModeSegmntContrl.selectedSegmentTintColor = UIColor(red: 0, green: 0.478, blue: 1, alpha: 1)
        
        let normalTextAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(red: 0, green: 0.191, blue: 0.4, alpha: 1),
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
        currencyInfoTableView.isHidden = false
        currencyInfoTableView.dataSource = self
        currencyInfoTableView.delegate = self
        currencyInfoTableView.separatorColor = .clear
        currencyInfoTableView.register(UINib(nibName: "CurrencyValueTableViewCell", bundle: nil), forCellReuseIdentifier: "CurrencyValuesTableViewCell")
    }
    
    private func setupAddCurrencyButton() {
        addCurrencyButton.setAttributedTitle(presenter.createTitleNameForButton(text: "Add Currency", textSize: 13), for: .normal)
    }
    
    private func setupUpdateInfoLabel() {
        updatedInfoLabel.font = R.font.latoRegular(size: 12)
        updatedInfoLabel.textColor = UIColor(red: 0.342, green: 0.342, blue: 0.342, alpha: 1)
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
            title: "No internet connection",
            message: "Please allow this app to internet access",
            preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: "Use Offline", style: .cancel, handler: nil)
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL)
                }
            }
        
        alertController.addAction(cancelAction)
        alertController.addAction(settingsAction)

        present(alertController, animated: true, completion: nil)
    }
}

extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currencies.count
    }
 
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CurrencyValuesTableViewCell", for: indexPath) as! CurrencyValueTableViewCell
        
        let currencyName = currencies[indexPath.row]
        cell.currencyNameLabel.attributedText = cell.createTitleNameForLabel(text: currencyName)

        return cell
    }
}

extension MainViewController: MainViewProtocol {
    func updateUI(with currencyData: CurrencyData) {
        
        updatedInfoLabel.text = presenter.configureLastUpdatedLabel()
        
        
        
   //     getCurrencyDefaultValues()
        
    }
}

extension MainViewController {
    private enum Constants {
        
    }
}
