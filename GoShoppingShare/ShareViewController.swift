//
//  ShareViewController.swift
//  GoShoppingShare
//
//  Created by Juntao Qiu on 5/10/20.
//  Copyright © 2020 Juntao Qiu. All rights reserved.
//

import UIKit
import Social
import MobileCoreServices
import CoreData

protocol ShareSelectViewControllerDelegate: class {
    func selected(category: String)
}

let categoryTitles = [
    NSLocalizedString("category.food.title", comment: "category.food.title"),
    NSLocalizedString("category.essentials.title", comment: "category.essentials.title"),
    NSLocalizedString("category.health.title", comment: "category.health.title"),
    NSLocalizedString("category.others.title", comment: "category.others.title")
]

class ShareViewController: SLComposeServiceViewController {
    let store = CoreDataStack.store
    
    private lazy var toBuyManager: ToBuyManager = {
        return ToBuyManager(store.viewContext)
    }()
    
    private var name: String = ""
    private var category: Int = 0
    private var categoryName: String = "Other"
    private var image: Data?
    
    override func viewDidLoad() {
        let attachments = (extensionContext?.inputItems.first as? NSExtensionItem)?.attachments ?? []
        
        let contentTypeText = kUTTypeText as String
        let contentTypeImage = kUTTypeData as String
        
        for provider in attachments {
            print("provider: \(provider)")
            if provider.isImage {
                provider.loadItem(forTypeIdentifier: contentTypeImage, options: nil, completionHandler: { (data, error) in
                    guard error == nil else { return }

                    if let url = data as? URL,
                       let imageData = try? Data(contentsOf: url) {
                        print(imageData)
                        self.image = imageData
                    } else {
                      fatalError("Impossible to save image")
                    }
                })
            }
            
            if provider.isText {
                provider.loadItem(forTypeIdentifier: contentTypeText, options: nil, completionHandler: { (data, error) in
                    guard error == nil else { return }
                    let text = data as! String
                    self.name = text
                    _ = self.isContentValid()
                })
            }
        }
    }
    
    override func isContentValid() -> Bool {
        if name.count == 0 {
            if !contentText.isEmpty {
                return true
            } else {
                return false
            }
        }
        
        if image != nil {
            return true
        }
        
        return true
    }

    override func didSelectPost() {
        let imageData = self.image ?? UIImage(systemName: "doc")!.pngData()
        
        toBuyManager.initToBuyItem(name: contentText!, category: category, image: imageData!, supermarket: "")
        
        extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
    }

    override func configurationItems() -> [Any]! {
        let item = SLComposeSheetConfigurationItem()
        item?.title = "Category"
        item?.value = categoryName
        item?.tapHandler = {
            let vc = CategoryTableView()
            vc.delegate = self
            self.pushConfigurationViewController(vc)
        }
        return [item!]
    }

}

extension ShareViewController: ShareSelectViewControllerDelegate {

    
    func selected(category: String) {
        categoryName = category
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
        reloadConfigurationItems()
        popConfigurationViewController()
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
