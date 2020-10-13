//
//  CanBuyManager.swift
//  GoShopping
//
//  Created by Juntao Qiu on 27/9/20.
//  Copyright © 2020 Juntao Qiu. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class CanBuyManager {
    private let entityName = "CanBuy"
    private(set) var viewContext: NSManagedObjectContext
    
    init(_ viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
    }

    func findExistInCanBuyList(name: String, category: Int) -> CanBuy? {
        let fetchRequest:NSFetchRequest<CanBuy> = NSFetchRequest.init(entityName: entityName)
        
        let namePredicate = NSPredicate(format: "name = %@", name)
        let categoryPredicate = NSPredicate(format: "category = %d", category)
        
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [namePredicate, categoryPredicate])
        
        do {
            let result = try viewContext.fetch(fetchRequest)
            if(result.count > 0) {
                return result[0]
            }
            return nil
        }catch let error as NSError {
            print("Could not fetch value. \(error), \(error.userInfo)")
        }
        
        return nil
    }
    
    func ensureFirstElementExist() {
        let fetchRequest: NSFetchRequest<CanBuy> = CanBuy.fetchRequest()
        let predicate = NSPredicate(format: "category = %d", -1)
        
        fetchRequest.predicate = predicate

        let items = try? viewContext.fetch(fetchRequest)
        
        if items?.count == 1 {
            return
        }
        
        // remove all of them and add one after
        if items?.count ?? 0 > 1 {
            viewContext.performAndWait {
                items?.forEach { item in
                    self.viewContext.delete(item)
                }
                self.viewContext.save(with: .addCanBuyItem)
            }
        }
        
        viewContext.performAndWait {
            let item = CanBuy(context: self.viewContext)
            
            item.name = ""
            item.image = placeHolderImage?.pngData()
            item.category = -1
            item.createdAt = Date()
            
            self.viewContext.save(with: .addCanBuyItem)
        }
    }
    
    func createCanBuy(name: String,
                      category: Int,
                      image: Data,
                      supermarket: String) {
        if let toBeUpdated = findExistInCanBuyList(name: name, category: category) {
            viewContext.perform {
                toBeUpdated.image = image
                toBeUpdated.supermarket = supermarket
                self.viewContext.save(with: .updateCanBuy)
            }
        } else {
            viewContext.perform {
                let item = CanBuy(context: self.viewContext)
                item.uuid = UUID()
                item.name = name
                item.image = image
                item.category = Int16(category)
                item.supermarket = supermarket
                item.createdAt = Date()

                self.viewContext.save(with: .addCanBuyItem)
            }
        }
    }
    
    func deleteAllCanBuys(){
        let request = NSBatchDeleteRequest(fetchRequest: NSFetchRequest<NSFetchRequestResult>(entityName: entityName))
        do {
            try viewContext.execute(request)
        }
        catch {
            print(error)
        }
    }
}
