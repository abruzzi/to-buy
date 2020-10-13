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
    private(set) var viewContext: NSManagedObjectContext
    
    private weak var fetchedResultsControllerDelegate: NSFetchedResultsControllerDelegate?
    
    init(with viewContext: NSManagedObjectContext,
         fetchedResultsControllerDelegate: NSFetchedResultsControllerDelegate?) {
        self.viewContext = viewContext
        self.fetchedResultsControllerDelegate = fetchedResultsControllerDelegate
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController<CanBuy> = {
        let fetchRequest: NSFetchRequest<CanBuy> = CanBuy.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "category", ascending: true)]
        
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                    managedObjectContext: viewContext,
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
    
    func ensureFirstElementExist() {
        let fetchRequest: NSFetchRequest<CanBuy> = CanBuy.fetchRequest()
        let predicate = NSPredicate(format: "category = %d", -1)
        
        fetchRequest.predicate = predicate

        let number = try? viewContext.count(for: fetchRequest)
        if number == 0 {
            viewContext.performAndWait {
                let item = CanBuy(context: self.viewContext)
                
                item.name = ""
                item.image = placeHolderImage?.pngData()
                item.category = -1
                item.createdAt = Date()
                
                self.viewContext.save(with: .addCanBuyItem)
            }
        }
    }
    
    func addCanBuy(name: String, image: Data, shouldSave: Bool = true, completionHandler: ((_ canBuyItem: CanBuy) -> Void)? = nil) {
        viewContext.perform {
            let item = CanBuy(context: self.viewContext)
            item.name = name
            item.image = image
            item.category = 3

            if shouldSave {
                item.createdAt = Date()
                self.viewContext.save(with: .addCanBuyItem)
            }
            completionHandler?(item)
        }
    }

    func deleteCanBuy(at indexPath: IndexPath, shouldSave: Bool = true) {
        viewContext.performAndWait {
            viewContext.delete(fetchedResultsController.object(at: indexPath))
            if shouldSave {
                viewContext.save(with: .deleteCanBuyItem)
            }
        }
    }
}
