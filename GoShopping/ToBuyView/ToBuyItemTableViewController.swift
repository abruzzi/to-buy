//
//  ToBuyItemTableViewController.swift
//  GoShopping
//
//  Created by Juntao Qiu on 9/10/20.
//  Copyright © 2020 Juntao Qiu. All rights reserved.
//

import UIKit

class ToBuyItemTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var delegate: MasterDetailDelegate?
    
    let store = CoreDataStack.store
    
    var item: ToBuy?
    var category: String!
    var priority: Int = 0
    
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
        guard let item = item else { return }
        let category = segmentCategory.selectedSegmentIndex
        
        item.name = itemNameTextField.text
        item.category = Int16(category)
        item.priority = Int16(priority)
        item.supermarket = supermarketTextField.text
        
        // the one from camera
        if(itemImage.image?.size.width ?? 100 > 600) {
            item.image = itemImage.image?.resize(toTargetSize: CGSize(width: 600, height: 600)).pngData()
        } else {
            item.image = placeHolderImage?.pngData()
        }
        
        delegate?.didUpdateToBuyItem(item: item)
        
        // also save tag
        if(!supermarketTextField.text!.isEmpty) {
            self.dataProvider.addTag(name: supermarketTextField.text!)
        }
        
        if(saveToCanBuyList) {
            var image: Data?
            
            if(itemImage.image?.size.width ?? 100 > 600) {
                image = itemImage.image?.resize(toTargetSize: CGSize(width: 600, height: 600)).pngData()
            } else {
                image = placeHolderImage?.pngData()
            }

            // TODO: if does exist, update. otherwise create
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
        let rounded = sender.value.rounded()
        sender.setValue(rounded, animated: false)
        priority = Int(rounded)
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
        itemNameTextField.text = item?.name ?? ""
        supermarketTextField.text = item?.supermarket ?? ""
        segmentCategory.selectedSegmentIndex = Int(item?.category ?? 3)
        prioritySlider.value = Float(item?.priority ?? 0)
        saveForLaterSwitch.isOn = saveToCanBuyList
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        
        if let data = item?.image {
            itemImage.image = UIImage(data: data)
        } else {
            itemImage.image = placeHolderImage
        }
        
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
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)

        if notification.name == UIResponder.keyboardWillHideNotification {
            tableView.contentInset = .zero
        } else {
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }

        tableView.scrollIndicatorInsets = tableView.contentInset
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
