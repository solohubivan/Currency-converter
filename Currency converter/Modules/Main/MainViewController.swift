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
    func updateTableInfo(with values: [Double])
    
    func reloadDataCurrencyInfoTable()
}


class MainViewController: UIViewController {
    
    @IBOutlet weak private var mainTitleLabel: UILabel!
    @IBOutlet weak private var currencyShowView: UIView!
    @IBOutlet weak private var sellBuyModeSegmntContrl: UISegmentedControl!
    @IBOutlet weak private var currencyInfoTableView: UITableView!
    @IBOutlet weak private var addCurrencyButton: UIButton!
    @IBOutlet weak private var updatedInfoLabel: UILabel!
    
    private var presenter: MainVCPresenterProtocol!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = MainPresenter(view: self)
        
        checkInternetConnectionAndGetData()
        
        setupUI()
    }
    
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
        mainTitleLabel.text = R.string.localizable.currency_converter()
        mainTitleLabel.font = R.font.latoExtraBold(size: 24)
        mainTitleLabel.textColor = .white
    }
    
    private func setupCurrencyShowView() {
        currencyShowView.layer.cornerRadius = Constants.viewCornerRadius
        currencyShowView.backgroundColor = .white
        
        currencyShowView.applyShadow(opacity: Constants.viewShadowOpacity, offset: CGSize(width: .zero, height: Constants.viewShadowHeight), radius: Constants.viewShadowRadius, cornerRadius: Constants.viewCornerRadius)
    }
    
    private func setupSwitchModeSegmentedControl() {
        sellBuyModeSegmntContrl.setTitle(R.string.localizable.sell(), forSegmentAt: .zero)
        sellBuyModeSegmntContrl.setTitle(R.string.localizable.buy(), forSegmentAt: Constants.firstSegment)
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
        currencyInfoTableView.register(UINib(nibName: Constants.currencyInfoTableNibName, bundle: nil), forCellReuseIdentifier: Constants.currencyValuesCellIdentifier)
    }
    
    private func setupAddCurrencyButton() {
        addCurrencyButton.setAttributedTitle(presenter.createTitleNameForButton(text: R.string.localizable.add_currency(), textSize: 13), for: .normal)
    }
    
    @IBAction func presentCurrencyListVC(_ sender: Any) {
        let currencyListVC = CurrencyListViewController()
        currencyListVC.presenter = self.presenter
        currencyListVC.modalPresentationStyle = .formSheet
        present(currencyListVC, animated: true)
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
    

}

extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return presenter.getActiveCurrenciesForTable().count
    }
 
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.currencyValuesCellIdentifier, for: indexPath) as! CurrencyValueTableViewCell
        
        let currencyName = presenter.getActiveCurrenciesForTable()[indexPath.row]
        cell.currencyNameLabel.attributedText = presenter.createTitleNameForCurrencyLabel(text: currencyName)

        cell.cellIndex = indexPath.row
        
        cell.textFieldValueChanged = { [weak self] newValue in
            guard let self = self else { return }
            self.presenter.updateCalculatedCurencyValue(with: newValue, at: cell.cellIndex)
        }
        
        return cell
    }
}

extension MainViewController: MainViewProtocol {
    func updateUI(with currencyData: CurrencyData) {

        updatedInfoLabel.text = presenter.configureLastUpdatedLabel()
    }
    
    func updateTableInfo(with values: [Double]) {
        for (index, value) in values.enumerated() {
            if let cell = currencyInfoTableView.cellForRow(at: IndexPath(row: index, section: .zero)) as? CurrencyValueTableViewCell {
                cell.currencyValueTF.text = String(value)
            }
        }
    }
    
    func reloadDataCurrencyInfoTable() {
        currencyInfoTableView.reloadData()
    }
}

extension MainViewController {
    private enum Constants {
        static let currencyValuesCellIdentifier: String = "CurrencyValuesTableViewCell"
        static let currencyInfoTableNibName: String = "CurrencyValueTableViewCell"
        
        static let viewCornerRadius: CGFloat = 10
        
        static let firstSegment: Int = 1
        
        static let viewShadowOpacity: Float = 0.2
        static let viewShadowHeight: CGFloat = 5
        static let viewShadowRadius: CGFloat = 2
    }
}
