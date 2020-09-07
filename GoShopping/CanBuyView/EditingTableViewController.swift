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
        NSLocalizedString("category.food.title", comment: "category.others.title"),
        NSLocalizedString("category.essentials.title", comment: "category.others.title"),
        NSLocalizedString("category.health.title", comment: "category.others.title"),
        NSLocalizedString("category.others.title", comment: "category.others.title"),
    ]
    
    @IBAction func saveButtonClickHandler(_ sender: UIButton) {
        let categoryName = NSLocalizedString("category.others.title", comment: "category.others.title")
        if(isNewItemInApp(name: item.name)) {
            let newItem = CanBuyItem(name: itemNameTextField.text ?? "", category: categoryName, image: "icons8-autism", supermarket: supermarketTextField.text ?? "")
            saveCanBuyItem(canBuyItem: newItem)
        } else {
            updateCanBuyItem(name: item.name, dict: ["name": itemNameTextField.text ?? "", "supermarket": supermarketTextField.text ?? ""])
        }
        
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
