//
//  ToBuyHistoryProvider.swift
//  GoShopping
//
//  Created by Juntao Qiu on 28/9/20.
//  Copyright © 2020 Juntao Qiu. All rights reserved.
//

import Foundation
import CoreData

class ToBuyHistoryProvider {
    private(set) var viewContext: NSManagedObjectContext
    
    private weak var fetchedResultsControllerDelegate: NSFetchedResultsControllerDelegate?
    
    init(with viewContext: NSManagedObjectContext,
         fetchedResultsControllerDelegate: NSFetchedResultsControllerDelegate?) {
        self.viewContext = viewContext
        self.fetchedResultsControllerDelegate = fetchedResultsControllerDelegate
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController<ToBuyHistory> = {
        let fetchRequest: NSFetchRequest<ToBuyHistory> = ToBuyHistory.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                    managedObjectContext: viewContext,
                                                    sectionNameKeyPath: "formattedCreatedAt", cacheName: nil)
        controller.delegate = fetchedResultsControllerDelegate
        
        do {
            try controller.performFetch()
        } catch {
            let nserror = error as NSError
            fatalError("###\(#function): Failed to performFetch: \(nserror), \(nserror.userInfo)")
        }
        
        return controller
    }()
    
    func deleteHistoryItem(at indexPath: IndexPath, shouldSave: Bool = true) {
        viewContext.performAndWait {
            viewContext.delete(fetchedResultsController.object(at: indexPath))
            if shouldSave {
                viewContext.save(with: .deleteHistoryItem)
            }
        }
    }
    
    func cleanupAllHistory() {
        if let historyItems = fetchedResultsController.fetchedObjects {
            viewContext.performAndWait {
                historyItems.forEach { item in
                    viewContext.delete(item)
                }
                viewContext.save(with: .deleteHistoryItem)
            }
        }
    }

}
