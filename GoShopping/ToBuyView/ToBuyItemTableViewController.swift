//
//  ToBuyItemTableViewController.swift
//  GoShopping
//
//  Created by Juntao Qiu on 9/10/20.
//  Copyright © 2020 Juntao Qiu. All rights reserved.
//

import UIKit

class ToBuyItemTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let store = CoreDataStack.store
    
    var item: ToBuy!
    var category: String!
    
    let categories = [
        NSLocalizedString("category.food.title", comment: "category.others.title"),
        NSLocalizedString("category.essentials.title", comment: "category.others.title"),
        NSLocalizedString("category.health.title", comment: "category.others.title"),
        NSLocalizedString("category.others.title", comment: "category.others.title"),
    ]
    
    private lazy var canBuyManger: CanBuyManager = {
        return CanBuyManager(store.viewContext)
    }()
    
    
    private lazy var dataProvider: TagProvider = {
        let provider = TagProvider(with: store.viewContext,
                                   fetchedResultsControllerDelegate: nil)
        return provider
    }()
    
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var supermarketTextField: SearchTextField!
    @IBOutlet weak var prioritySlider: UISlider!
    
    @IBAction func saveButtonClickHandler(_ sender: UIBarButtonItem) {
        let category = segmentCategory.selectedSegmentIndex
        let priority = prioritySlider.value
        let context = item.managedObjectContext!
        
        context.performAndWait {
            item.name = itemNameTextField.text
            item.category = Int16(category)
            item.priority = Int16(priority.rounded())
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
        
        if(saveToCanBuyList) {
            var image: Data?
            
            if(itemImage.image?.size.width ?? 100 > 600) {
                image = UIImage(named: "icons8-crystal_ball")?.pngData()
            } else {
                image = itemImage.image?.resize(toTargetSize: CGSize(width: 600, height: 600)).pngData()
            }

            canBuyManger.createCanBuy(
                name: itemNameTextField.text ?? "",
                category: Int(category),
                image: image!,
                supermarket: supermarketTextField.text ?? ""
            )
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onPriorityChange(_ sender: UISlider) {
        print(sender.value)
    }
    
    @IBAction func onSegmentChange(_ sender: UISegmentedControl) {
        category = categories[segmentCategory.selectedSegmentIndex]
    }
    
    @IBOutlet weak var segmentCategory: UISegmentedControl!
    @IBOutlet weak var itemNameTextField: UITextField!
    //    @IBOutlet weak var supermarketTextField: UITextField!
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setToolbarHidden(true, animated: false)
    }
    
    @IBOutlet weak var saveForLaterSwitch: UISwitch!
    
    @IBAction func onSwitchChange(_ sender: UISwitch) {
        saveToCanBuyList = sender.isOn
    }
    
    private var saveToCanBuyList: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.keyboardDismissMode = .onDrag
        itemNameTextField.text = item.name
        supermarketTextField.text = item.supermarket
        segmentCategory.selectedSegmentIndex = Int(item.category)
        prioritySlider.value = Float(item.priority)
        saveForLaterSwitch.isOn = saveToCanBuyList
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        itemImage.image = UIImage(data: item.image!)
        itemImage.layer.cornerRadius = 4.0
        itemImage.layer.masksToBounds = true
        itemImage.addGestureRecognizer(singleTap)
        
        let options = dataProvider.fetchedResultsController.fetchedObjects?.map { tag in
            return tag.name
        } ?? []
        
        supermarketTextField.filterStrings(options.compactMap { $0 })
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
