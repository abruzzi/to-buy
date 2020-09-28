//
//  TagProvider.swift
//  GoShopping
//
//  Created by Juntao Qiu on 17/9/20.
//  Copyright © 2020 Juntao Qiu. All rights reserved.
//

import Foundation
import CoreData

class TagProvider {
    private(set) var viewContext: NSManagedObjectContext
    
    private weak var fetchedResultsControllerDelegate: NSFetchedResultsControllerDelegate?
    
    init(with viewContext: NSManagedObjectContext,
         fetchedResultsControllerDelegate: NSFetchedResultsControllerDelegate?) {
        self.viewContext = viewContext
        self.fetchedResultsControllerDelegate = fetchedResultsControllerDelegate
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController<Tag> = {
        let fetchRequest: NSFetchRequest<Tag> = Tag.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                    managedObjectContext: viewContext,
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
    
    func numberOfTags(with tagName: String) -> Int {
        let fetchRequest: NSFetchRequest<Tag> = Tag.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", tagName)
        
        let number = try? viewContext.count(for: fetchRequest)
        return number ?? 0
    }
    
    func addTag(name: String, shouldSave: Bool = true) {
        let fetchRequest: NSFetchRequest<Tag> = Tag.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name = %@", name)
        
        let number = try? viewContext.count(for: fetchRequest)
        
        if((number ?? 0) > 0) {
            return
        }
        
        viewContext.performAndWait {
            let item = Tag(context: viewContext)
            item.uuid = UUID()
            item.name = name
            
            if shouldSave {
                viewContext.save(with: .addTag)
            }
        }
    }
    
    func deleteTag(at indexPath: IndexPath, shouldSave: Bool = true) {
        viewContext.performAndWait {
            viewContext.delete(fetchedResultsController.object(at: indexPath))
            if shouldSave {
                viewContext.save(with: .deleteTag)
            }
        }
    }

}
