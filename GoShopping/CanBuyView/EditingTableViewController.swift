//
//  EditingTableViewController.swift
//  GoShopping
//
//  Created by Juntao Qiu on 6/9/20.
//  Copyright © 2020 Juntao Qiu. All rights reserved.
//

import UIKit
import CoreData

class EditingTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var item: CanBuys!
    var category: String!
    
    let categories = [
        NSLocalizedString("category.food.title", comment: "category.others.title"),
        NSLocalizedString("category.essentials.title", comment: "category.others.title"),
        NSLocalizedString("category.health.title", comment: "category.others.title"),
        NSLocalizedString("category.others.title", comment: "category.others.title"),
    ]
    
    @IBOutlet weak var itemImage: UIImageView!
    
    @IBAction func saveButtonClickHandler(_ sender: UIBarButtonItem) {
          let category = segmentCategory.selectedSegmentIndex
          let context = item.managedObjectContext!
          context.performAndWait {
              item.name = itemNameTextField.text
              item.category = Int16(category)
              item.supermarket = supermarketTextField.text
              
              // the ones from camera
              if(itemImage.image?.size.width ?? 100 > 600) {
                  item.image = itemImage.image?.resize(toTargetSize: CGSize(width: 600, height: 600)).pngData()
              }
              
              item.createdAt = Date()
              
              context.save(with: .updateCanBuy)
          }
    
          self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onSegmentChange(_ sender: UISegmentedControl) {
        category = categories[segmentCategory.selectedSegmentIndex]
    }
    
    @IBOutlet weak var segmentCategory: UISegmentedControl!
    @IBOutlet weak var itemNameTextField: UITextField!
    @IBOutlet weak var supermarketTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.keyboardDismissMode = .onDrag
        itemNameTextField.text = item.name
        supermarketTextField.text = item.supermarket
        segmentCategory.selectedSegmentIndex = Int(item.category)
     

        let singleTap = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        itemImage.image = UIImage(data: item.image!) // getImageOf(itemName: item.name!, fallbackImageName: item.image!)
        itemImage.layer.cornerRadius = 4.0
        itemImage.layer.masksToBounds = true
        itemImage.addGestureRecognizer(singleTap)
    }


    //Action
    @objc func selectImage() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        //MARK: i18n
        let actionSheet = UIAlertController(title: "Choose photo", message: "", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action: UIAlertAction) in
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Carema", style: .default, handler: { (action: UIAlertAction) in
            
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                imagePicker.sourceType = .camera
                imagePicker.allowsEditing = true
                self.present(imagePicker, animated: true, completion: nil)
            }

        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        
        itemImage.image = image
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}
