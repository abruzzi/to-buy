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

let placeHolderImage = UIImage(named: "icons8-crystal_ball")
let defaultCategory = Int16(3)

let store = CoreDataStack.store

func setupDatabaseItems() {
    let canBuyManager = CanBuyManager(store.viewContext)
    canBuyManager.ensureFirstElementExist()
}

let appTransactionAuthorName = "To Buy"

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
    case updateToBuyItem = "update to buy item"
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
