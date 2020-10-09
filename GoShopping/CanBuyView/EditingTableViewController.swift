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
    
    let store = CoreDataStack.store
    
    var item: CanBuy!
    var category: String!
    
    let categories = [
        NSLocalizedString("category.food.title", comment: "category.others.title"),
        NSLocalizedString("category.essentials.title", comment: "category.others.title"),
        NSLocalizedString("category.health.title", comment: "category.others.title"),
        NSLocalizedString("category.others.title", comment: "category.others.title"),
    ]
    
    private lazy var dataProvider: TagProvider = {
        let provider = TagProvider(with: store.viewContext,
                                   fetchedResultsControllerDelegate: nil)
        return provider
    }()
    
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var supermarketTextField: SearchTextField!
    
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
        
        // also save tag
        if(!supermarketTextField.text!.isEmpty) {
            self.dataProvider.addTag(name: supermarketTextField.text!)
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onSegmentChange(_ sender: UISegmentedControl) {
        category = categories[segmentCategory.selectedSegmentIndex]
    }
    
    @IBOutlet weak var segmentCategory: UISegmentedControl!
    @IBOutlet weak var itemNameTextField: UITextField!
    //    @IBOutlet weak var supermarketTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.keyboardDismissMode = .onDrag
        itemNameTextField.text = item.name
        supermarketTextField.text = item.supermarket
        segmentCategory.selectedSegmentIndex = Int(item.category)
        
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        itemImage.image = UIImage(data: item.image!)
        itemImage.layer.cornerRadius = 4.0
        itemImage.layer.masksToBounds = true
        itemImage.addGestureRecognizer(singleTap)
        
        let options = dataProvider.fetchedResultsController.fetchedObjects?.map { tag in
            return tag.name
        } ?? []
        
        supermarketTextField.filterStrings(options.compactMap { $0 })
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc func keyboardWillChange(notification: NSNotification) {
        guard let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        
        if notification.name == UIResponder.keyboardWillChangeFrameNotification ||
            notification.name == UIResponder.keyboardWillShowNotification {
            view.frame.origin.y = -(keyboardRect.height)
        } else {
            view.frame.origin.y = 0
        }
    }
    
    //Action
    @objc func selectImage() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        let actionSheet = UIAlertController(title: NSLocalizedString( "dialog.image.picker.title", comment:  "dialog.image.picker.title"),
                                            message: NSLocalizedString( "dialog.image.picker.subtitle", comment:  "dialog.image.picker.subtitle"), preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: NSLocalizedString( "dialog.image.picker.photo", comment:  "dialog.image.picker.photo"), style: .default, handler: { (action: UIAlertAction) in
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: NSLocalizedString( "dialog.image.picker.carema", comment:  "dialog.image.picker.carema"), style: .default, handler: { (action: UIAlertAction) in
            
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                imagePicker.sourceType = .camera
                imagePicker.allowsEditing = true
                self.present(imagePicker, animated: true, completion: nil)
            }
            
        }))
        
        actionSheet.addAction(UIAlertAction(title: NSLocalizedString( "dialog.image.picker.cancel", comment:  "dialog.image.picker.cancel"), style: .cancel, handler: nil))
        
        addActionSheetForiPad(actionSheet: actionSheet)
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

extension UIViewController {
  public func addActionSheetForiPad(actionSheet: UIAlertController) {
    if let popoverPresentationController = actionSheet.popoverPresentationController {
      popoverPresentationController.sourceView = self.view
      popoverPresentationController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
      popoverPresentationController.permittedArrowDirections = []
    }
  }
}
