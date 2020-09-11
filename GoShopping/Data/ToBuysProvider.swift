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
    private(set) var persistentContainer: NSPersistentContainer
    private weak var fetchedResultsControllerDelegate: NSFetchedResultsControllerDelegate?
    
    init(with persistentContainer: NSPersistentContainer,
         fetchedResultsControllerDelegate: NSFetchedResultsControllerDelegate?) {
        self.persistentContainer = persistentContainer
        self.fetchedResultsControllerDelegate = fetchedResultsControllerDelegate
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController<ToBuys> = {
        let fetchRequest: NSFetchRequest<ToBuys> = ToBuys.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        fetchRequest.predicate = NSPredicate(format: "isDelayed = %d", true)
        
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                    managedObjectContext: persistentContainer.viewContext,
                                                    sectionNameKeyPath: nil, cacheName: nil)
        controller.delegate = fetchedResultsControllerDelegate
        
        do {
            try controller.performFetch()
        } catch {
            let nserror = error as NSError
            fatalError("###\(#function): Failed to performFetch: \(nserror), \(nserror.userInfo)")
        }
        
        return controller
    }()
    
//    lazy var delayedToBuysFRC: NSFetchedResultsController<ToBuys> = {
//        let fetchRequest: NSFetchRequest<ToBuys> = ToBuys.fetchRequest()
//        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
//        fetchRequest.predicate = NSPredicate(format: "isDelayed == %@", true)
//
//        let controller = NSFetchedResultsController(fetchRequest: fetchRequest,
//                                                    managedObjectContext: persistentContainer.viewContext,
//                                                    sectionNameKeyPath: nil, cacheName: nil)
//        controller.delegate = fetchedResultsControllerDelegate
//
//        do {
//            try controller.performFetch()
//        } catch {
//            let nserror = error as NSError
//            fatalError("###\(#function): Failed to performFetch: \(nserror), \(nserror.userInfo)")
//        }
//
//        return controller
//    }()
    
    func numberOfDelayed() -> Int {
        let fetchRequest: NSFetchRequest<ToBuys> = ToBuys.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isDelayed == %@", true)
        
        let number = try? persistentContainer.viewContext.count(for: fetchRequest)
        return number ?? 0
    }
    
    func numberOfCompleted() -> Int {
        let fetchRequest: NSFetchRequest<ToBuys> = ToBuys.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isCompleted == %@", true)
        
        let number = try? persistentContainer.viewContext.count(for: fetchRequest)
        return number ?? 0
    }
    
    func addToBuyItem(canBuyItem: ToBuys, context: NSManagedObjectContext, shouldSave: Bool = true) {
        context.performAndWait {
            let item = ToBuys(context: context)
            item.name = canBuyItem.name
            item.category = canBuyItem.category
            item.image = canBuyItem.image
            item.createdAt = Date()
            item.supermarket = canBuyItem.supermarket
            
            if shouldSave {
                context.save(with: .addToBuyItem)
            }
        }
    }
    
    func markAsCompleted(at indexPath: IndexPath, shouldSave: Bool = true) {
        let context = fetchedResultsController.managedObjectContext
        context.performAndWait {
            let item = fetchedResultsController.object(at: indexPath)
            item.isDelayed = false
            item.isCompleted = true
            if shouldSave {
                context.save(with: .markAsCompleted)
            }
        }
    }
    
    func deleteToBuyItem(at indexPath: IndexPath, shouldSave: Bool = true) {
        let context = fetchedResultsController.managedObjectContext
        context.performAndWait {
            context.delete(fetchedResultsController.object(at: indexPath))
            if shouldSave {
                context.save(with: .deleteToBuyItem)
            }
        }
    }
}
