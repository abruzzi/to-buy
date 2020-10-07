//
//  CustomShareViewController.swift
//  GoShoppingShare
//
//  Created by Juntao Qiu on 6/10/20.
//  Copyright © 2020 Juntao Qiu. All rights reserved.
//

import UIKit
import Social
import MobileCoreServices
import CoreData

protocol ShareSelectViewControllerDelegate: class {
    func selected(category: String)
}

class CustomShareViewController: UITableViewController {
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var categoryName: UILabel!
    
    @IBOutlet weak var categorySelector: UITableViewCell!
    
    var category: Int!
    
    let store = CoreDataStack.store
    
    private lazy var toBuyManager: ToBuyManager = {
        return ToBuyManager(store.viewContext)
    }()
    
    override func viewDidLoad() {
        let attachments = (extensionContext?.inputItems.first as? NSExtensionItem)?.attachments ?? []
        image.layer.cornerRadius = 4.0
        
        let contentTypeImage = kUTTypeData as String
        
        for provider in attachments {
            print("provider: \(provider)")
            if provider.isImage {
                provider.loadItem(forTypeIdentifier: contentTypeImage, options: nil, completionHandler: { (data, error) in
                    guard error == nil else { return }

                    if let url = data as? URL,
                       let imageData = try? Data(contentsOf: url) {
                        
                        DispatchQueue.main.async {
                            self.image.image = UIImage(data: imageData)
                        }
                    } else {
                      fatalError("Impossible to save image")
                    }
                })
            }
            
//            if provider.isText {
//                provider.loadItem(forTypeIdentifier: contentTypeImage, options: nil, completionHandler: { (data, error) in
//                    guard error == nil else { return }
//
//                    if let url = data as? URL,
//                       let imageData = try? Data(contentsOf: url) {
//                        
//                        DispatchQueue.main.async {
//                            self.image.image = UIImage(data: imageData)
//                        }
//                    } else {
//                      fatalError("Impossible to save image")
//                    }
//                })
//            }
        }
        
        self.view.backgroundColor = UIColor(named: "BGColor")
        setupNavBar()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        categorySelector.addGestureRecognizer(tap)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        let vc = CategoryTableView()
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // 2: Set the title and the navigation items
    private func setupNavBar() {
        self.navigationItem.title = NSLocalizedString("share.extension.message.title", comment: "share.extension.message.title")

        let itemCancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelAction))
        self.navigationItem.setLeftBarButton(itemCancel, animated: false)

        let itemDone = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneAction))
        self.navigationItem.setRightBarButton(itemDone, animated: false)
    }

    // 3: Define the actions for the navigation items
    @objc private func cancelAction () {
        let error = NSError(domain: "com.icodeit.GoShoppingShare", code: 0, userInfo: [NSLocalizedDescriptionKey: "An error description"])
        extensionContext?.cancelRequest(withError: error)
    }

    @objc private func doneAction() {
        let imageData = self.image.image?.pngData() ?? UIImage(systemName: "doc")!.pngData()
        let name = textView.text ?? ""
        toBuyManager.initToBuyItem(name: name, category: category, image: imageData!, supermarket: "")
        
        extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }
}

extension CustomShareViewController: ShareSelectViewControllerDelegate {
    
    func selected(category: String) {
        categoryName.text = category
        switch category {
        case categoryTitles[0]:
            self.category = 0
        case categoryTitles[1]:
            self.category = 1
        case categoryTitles[2]:
            self.category = 2
        case categoryTitles[3]:
            self.category = 3
        default:
            self.category = 3
        }
    }
}


extension NSItemProvider {
    
    var isImage: Bool {
        return hasItemConformingToTypeIdentifier(kUTTypeData as String)
    }
    
    var isText: Bool {
        return hasItemConformingToTypeIdentifier(kUTTypeText as String)
    }

}
