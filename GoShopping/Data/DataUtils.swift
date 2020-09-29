//
//  DataUtils.swift
//  GoShopping
//
//  Created by Juntao Qiu on 5/9/20.
//  Copyright © 2020 Juntao Qiu. All rights reserved.
//

import Foundation
import UIKit
import CoreData

func load<T: Decodable>(_ filename: String) -> T {
    let data: Data
    
    guard let file = Bundle.main.url(forResource: filename, withExtension: nil)
        else {
            fatalError("Couldn't find \(filename) in main bundle.")
    }
    
    do {
        data = try Data(contentsOf: file)
    } catch {
        fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
    }
    
    do {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    } catch {
        fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
    }
}

struct Record: Hashable, Codable {
    var category: Int
    var image: String
    var items: [Item]
}

struct Item: Hashable, Codable {
    var name: String
    var image: String
    var attrs: [String: String]
}

func resetAllDBItems(lang: String) {
    let records: [Record] = (lang.lowercased() == "en") ? load("category.json") :  load("category-cn.json")
    
    let toBuyManager = ToBuyManager(AppDelegate.viewContext)
    let canBuyManager = CanBuyManager(AppDelegate.viewContext)
    
    toBuyManager.deleteAllToBuys()
    canBuyManager.deleteAllCanBuys()
    
    records.forEach {record in
        record.items.forEach { (item: Item) in
            canBuyManager.createCanBuy(
                name: item.name,
                category: record.category,
                image: (UIImage(named: item.image)?.pngData())!,
                supermarket: ((item.attrs["supermarket"] != nil) ? item.attrs["supermarket"]: "")!)
        }
    }
}

let appTransactionAuthorName = "To Buy"

/**
 A convenience method for creating background contexts that specify the app as their transaction author.
 */
extension NSPersistentContainer {
    func backgroundContext() -> NSManagedObjectContext {
        let context = newBackgroundContext()
        context.transactionAuthor = appTransactionAuthorName
        return context
    }
}

// MARK: - Saving Contexts

/**
 Contextual information for handling Core Data context save errors.
 */
enum ContextSaveContextualInfo: String {
    case addCanBuyItem = "adding a can buy item"
    case updateCanBuy = "update can buy item"
    case deleteCanBuyItem = "deleting a can buy item"
    case addToBuyItem = "adding a to buy item"
    case deleteToBuyItem = "deleting a to buy item"
    case markAsCompleted = "mark as completed"
    case markAsDelayed = "mark as delayed"
    case markAsImportant = "mark as important item"
    case addTag = "adding a tag"
    case deleteTag = "deleting a tag"
    case deleteHistoryItem = "deleting a history item"
}

extension NSManagedObjectContext {
    
    /**
     Handles save error by presenting an alert.
     */
    private func handleSavingError(_ error: Error, contextualInfo: ContextSaveContextualInfo) {
        DispatchQueue.main.async {
            guard let window = UIApplication.shared.delegate?.window,
                let viewController = window?.rootViewController else { return }
            
            let message = "Failed to save the context when \(contextualInfo.rawValue)."
            
            // Append message to existing alert if present
            if let currentAlert = viewController.presentedViewController as? UIAlertController {
                currentAlert.message = (currentAlert.message ?? "") + "\n\n\(message)"
                return
            }
            
            // Otherwise present a new alert
            let alert = UIAlertController(title: "Core Data Saving Error", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))

            viewController.present(alert, animated: true)
        }
    }
    
    /**
     Save a context, or handle the save error (for example, when there data inconsistency or low memory).
     */
    func save(with contextualInfo: ContextSaveContextualInfo) {
        guard hasChanges else { return }
        do {
            try save()
        } catch {
            handleSavingError(error, contextualInfo: contextualInfo)
        }
    }
}
