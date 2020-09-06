//
//  EditingTableViewController.swift
//  GoShopping
//
//  Created by Juntao Qiu on 6/9/20.
//  Copyright © 2020 Juntao Qiu. All rights reserved.
//

import UIKit

class EditingTableViewController: UITableViewController {
    var item: Item!
    var category: String!
    
    let categories = [
        "食物/饮料",
        "生活必须",
        "健康护理",
        "其他"
    ]
    
    @IBAction func saveButtonClickHandler(_ sender: UIButton) {
        print(itemNameTextField.text)
        print(supermarketTextField.text)
    }
    
    @IBOutlet weak var itemCategoryPicker: UIPickerView!
    @IBOutlet weak var itemNameTextField: UITextField!
    @IBOutlet weak var supermarketTextField: UITextField!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        itemNameTextField.text = item.name
        itemCategoryPicker.dataSource = self
        itemCategoryPicker.delegate = self
        categoryLabel.text = category
        let supermarket = item.attrs["supermarket"]
        supermarketTextField.text = supermarket
    }
    
    
}

extension EditingTableViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent: Int) -> Int {
        return categories.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        categoryLabel.text = categories[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categories[row]
    }
}
