//
//  EmptyList.swift
//  GoShopping
//
//  Created by Juntao Qiu on 13/9/20.
//  Copyright © 2020 Juntao Qiu. All rights reserved.
//

import UIKit
import CoreData

class EmptyCanBuyCollection: UIView, NSFetchedResultsControllerDelegate {
    
    private var label: String!
    private var image: String!
    
    private lazy var dataProvider: CanBuysProvider = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let provider = CanBuysProvider(with: appDelegate.persistentContainer,
                                      fetchedResultsControllerDelegate: self)
        return provider
    }()
    
    init(frame: CGRect, label: String, image: String) {
        super.init(frame: frame)
        
        self.label = label
        self.image = image
        
        
        let label = UILabel()
        label.textColor = UIColor(named: "FontColor")
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = self.label
        label.textAlignment = .center
        
        let imageView = UIImageView(frame: .zero)
        imageView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.backgroundColor = UIColor(named: "blue")
        imageView.image = UIImage(named: self.image)
        
        self.addSubview(imageView)
        self.addSubview(label)
        
        imageView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10).isActive = true
        label.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(editNewItem))
        self.addGestureRecognizer(singleTap)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //Action
    @objc func editNewItem() {
        print("about to edit")
        let context = dataProvider.persistentContainer.viewContext
        dataProvider.addCanBuy(in: context, name: label, image: image) { canBuyItem in
            let storyboard = UIStoryboard(name: "main", bundle: nil)
            let viewController = storyboard.instantiateViewController(identifier: "EditingTableViewController")
                as? EditingTableViewController
            viewController!.item = canBuyItem

//            self.navigationController?.pushViewController(viewController!, animated: true)
        }
//        let imagePicker = UIImagePickerController()
//        imagePicker.delegate = self
//
//        //MARK: i18n
//        let actionSheet = UIAlertController(title: "Choose photo", message: "", preferredStyle: .actionSheet)
//
//        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action: UIAlertAction) in
//            imagePicker.sourceType = .photoLibrary
//            self.present(imagePicker, animated: true, completion: nil)
//        }))
//
//        actionSheet.addAction(UIAlertAction(title: "Carema", style: .default, handler: { (action: UIAlertAction) in
//
//            if UIImagePickerController.isSourceTypeAvailable(.camera) {
//                imagePicker.sourceType = .camera
//                self.present(imagePicker, animated: true, completion: nil)
//            }
//
//        }))
//
//        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//
//        self.present(actionSheet, animated: true, completion: nil)
    }
}
