//
//  CanBuysProvider.swift
//  GoShopping
//
//  Created by Juntao Qiu on 11/9/20.
//  Copyright © 2020 Juntao Qiu. All rights reserved.
//

import Foundation
import CoreData

class CanBuysProvider {
    private(set) var persistentContainer: NSPersistentContainer
    private weak var fetchedResultsControllerDelegate: NSFetchedResultsControllerDelegate?
    
    init(with persistentContainer: NSPersistentContainer,
         fetchedResultsControllerDelegate: NSFetchedResultsControllerDelegate?) {
        self.persistentContainer = persistentContainer
        self.fetchedResultsControllerDelegate = fetchedResultsControllerDelegate
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController<CanBuys> = {
        let fetchRequest: NSFetchRequest<CanBuys> = CanBuys.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "category", ascending: true), NSSortDescriptor(key: "createdAt", ascending: false)]
        
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                    managedObjectContext: persistentContainer.viewContext,
                                                    sectionNameKeyPath: "category", cacheName: nil)
        controller.delegate = fetchedResultsControllerDelegate
        
        do {
            try controller.performFetch()
        } catch {
            let nserror = error as NSError
            fatalError("###\(#function): Failed to performFetch: \(nserror), \(nserror.userInfo)")
        }
        
        return controller
    }()

//    func group(_ result : [CanBuys])-> [[CanBuys]] {
//        let dict: [Int: [CanBuys]] = Dictionary(grouping: result) { Int($0.category) }
//        return dict
//            .sorted(by: {$0.key < $1.key})
//            .map {$0.value}
//        
//    }
//
//
//    func groupedCanBuyItems() ->  [[CanBuys]] {
//        let fetchRequest: NSFetchRequest<CanBuys> = CanBuys.fetchRequest()
//        let itemsArray = try? group(persistentContainer.viewContext.fetch(fetchRequest))
//        return itemsArray ?? [[]]
//    }
//    
//    func numberOfSections () -> Int {
//        let fetchRequest: NSFetchRequest<CanBuys> = CanBuys.fetchRequest()
//        let count = try? group(persistentContainer.viewContext.fetch(fetchRequest)).count
//        
//        return count ?? 0
//    }
//    
    
    func addCanBuy(canBuyItem: CanBuys, context: NSManagedObjectContext, shouldSave: Bool = true) {
        context.performAndWait {
            let item = CanBuys(context: context)
            item.name = canBuyItem.name
            item.category = canBuyItem.category
            item.image = canBuyItem.image
            item.createdAt = Date()
            item.supermarket = canBuyItem.supermarket
            
            if shouldSave {
                context.save(with: .addCanBuyItem)
            }
        }
    }
    
    func deleteCanBuy(at indexPath: IndexPath, shouldSave: Bool = true) {
        let context = fetchedResultsController.managedObjectContext
        context.performAndWait {
            context.delete(fetchedResultsController.object(at: indexPath))
            if shouldSave {
                context.save(with: .deleteCanBuyItem)
            }
        }
    }
}
