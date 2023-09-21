//
//  MainViewController.swift
//  Currency converter
//
//  Created by Ivan Solohub on 15.09.2023.
//

import UIKit

class MainViewController: UIViewController {
    
    @IBOutlet weak private var mainTitleLabel: UILabel!
    @IBOutlet weak private var currencyShowView: UIView!
    @IBOutlet weak private var sellBuyModeSegmntContrl: UISegmentedControl!
    @IBOutlet weak private var currencyInfoTableView: UITableView!
    @IBOutlet weak private var addCurrencyButton: UIButton!
    @IBOutlet weak private var updateInfoLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
     
    }
    
    private func setupUI() {
        setupMainTitleLabel()
        setupCurrencyShowView()
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
    
    private func sellBuyModeSegmContrl() {
        sellBuyModeSegmntContrl.setTitle("Sell", forSegmentAt: 0)
        sellBuyModeSegmntContrl.setTitle("Buy", forSegmentAt: 1)
    }
    
    private func setupCurrencyInfoTableView() {
 //       currencyInfoTableView.dataSource = self
 //       currencyInfoTableView.delegate = self
        currencyInfoTableView.separatorColor = .clear
   //     currencyInfoTableView.register(UINib(nibName: Constants.nibNameCustomCell, bundle: nil), forCellReuseIdentifier: Constants.cellIdentifier)
    }
    
    private func setupAddCurrencyButton() {
        
    }
    
    private func createTitleNameForButton() -> NSAttributedString {
        let attributedString = NSMutableAttributedString()
        
        let icon = NSTextAttachment()
        icon.image = UIImage(named: "plus.circle.fill")
        
        let textString = NSAttributedString(string: "Add currency")
        
        let attachmentString = NSAttributedString(attachment: icon)
        attributedString.append(attachmentString)
        attributedString.append(textString)
        
        return attributedString
    }
    
    private func setupUpdateInfoButton() {
        
    }
}
/*
extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        <#code#>
    }
    
    
}
*/
