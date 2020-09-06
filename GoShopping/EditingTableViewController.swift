//
//  EditingTableViewController.swift
//  GoShopping
//
//  Created by Juntao Qiu on 6/9/20.
//  Copyright © 2020 Juntao Qiu. All rights reserved.
//

import UIKit

class EditingTableViewController: UITableViewController {
    var item: CanBuyItem!
    var category: String!
    
    let categories = [
        "食物/饮料",
        "生活必须",
        "健康护理",
        "其他"
    ]
    
    @IBAction func saveButtonClickHandler(_ sender: UIButton) {
        updateCanBuyItem(name: item.name, dict: ["name": itemNameTextField.text ?? "", "supermarket": supermarketTextField.text ?? ""])
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onSegmentChange(_ sender: UISegmentedControl) {
        category = categories[segmentCategory.selectedSegmentIndex]
    }
    
    @IBOutlet weak var segmentCategory: UISegmentedControl!
    @IBOutlet weak var itemNameTextField: UITextField!
    @IBOutlet weak var supermarketTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        itemNameTextField.text = item.name
        supermarketTextField.text = item.supermarket
    }

}
