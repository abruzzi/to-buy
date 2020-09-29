//
//  CanBuysProvider.swift
//  GoShopping
//
//  Created by Juntao Qiu on 11/9/20.
//  Copyright © 2020 Juntao Qiu. All rights reserved.
//

import Foundation
import CoreData

class ToBuysProvider {
    private(set) var viewContext: NSManagedObjectContext
    private weak var fetchedResultsControllerDelegate: NSFetchedResultsControllerDelegate?
    
    init(with viewContext: NSManagedObjectContext,
         fetchedResultsControllerDelegate: NSFetchedResultsControllerDelegate?) {
        self.viewContext = viewContext
        self.fetchedResultsControllerDelegate = fetchedResultsControllerDelegate
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController<ToBuy> = {
        let fetchRequest: NSFetchRequest<ToBuy> = ToBuy.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "supermarket", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "isDelayed = %d", false)
        
        
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                    managedObjectContext: viewContext,
                                                    sectionNameKeyPath: "supermarket", cacheName: nil)
        controller.delegate = fetchedResultsControllerDelegate
        
        do {
            try controller.performFetch()
        } catch {
            let nserror = error as NSError
            fatalError("###\(#function): Failed to performFetch: \(nserror), \(nserror.userInfo)")
        }
        
        return controller
    }()
    
    func addToBuyItem(canBuyItem: ToBuy, shouldSave: Bool = true) {
        viewContext.performAndWait {
            let item = ToBuy(context: viewContext)
            item.name = canBuyItem.name
            item.category = canBuyItem.category
            item.image = canBuyItem.image
            item.createdAt = Date()
            item.supermarket = canBuyItem.supermarket
            
            if shouldSave {
                viewContext.save(with: .addToBuyItem)
            }
        }
    }

    func markAsDelayed(at indexPath: IndexPath, shouldSave: Bool = true) {
        viewContext.performAndWait {
            let item = fetchedResultsController.object(at: indexPath)
            item.isDelayed = true
            item.isCompleted = false
            if shouldSave {
                viewContext.save(with: .markAsDelayed)
            }
        }
    }
    
    func markAsImportant(at indexPath: IndexPath, shouldSave: Bool = true) {
        viewContext.performAndWait {
            let item = fetchedResultsController.object(at: indexPath)
            item.priority = item.priority + 1
            if shouldSave {
                viewContext.save(with: .markAsImportant)
            }
        }
    }
    
    func markAsNormal(at indexPath: IndexPath, shouldSave: Bool = true) {
        viewContext.performAndWait {
            let item = fetchedResultsController.object(at: indexPath)
            item.priority = 0
            if shouldSave {
                viewContext.save(with: .markAsImportant)
            }
        }
    }
    
    func markAsCompleted(at indexPath: IndexPath, shouldSave: Bool = true) {
        viewContext.performAndWait {
            let item = fetchedResultsController.object(at: indexPath)
            item.isDelayed = false
            item.isCompleted = true
            if shouldSave {
                viewContext.save(with: .markAsCompleted)
            }
        }
    }
    
    func deleteToBuyItem(at indexPath: IndexPath, shouldSave: Bool = true) {
        viewContext.performAndWait {
            viewContext.delete(fetchedResultsController.object(at: indexPath))
            if shouldSave {
                viewContext.save(with: .deleteToBuyItem)
            }
        }
    }
}
