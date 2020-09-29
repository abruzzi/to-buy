//
//  ToBuyManager.swift
//  GoShopping
//
//  Created by Juntao Qiu on 27/9/20.
//  Copyright © 2020 Juntao Qiu. All rights reserved.
//

import Foundation

import UIKit
import CoreData

struct ToBuyItem: Codable {
    var name: String
    var category: Int
    var priority: Int
    var supermarket: String
    var image: Data?
    var isCompleted: Bool
    var isForeign: Bool
    var isDelayed: Bool
    var createdAt: Date
    
    func getImage() -> UIImage? {
        if let data = image {
            return UIImage(data: data)
        }
        return nil
    }
}

protocol ToBuyListDelegate {
    func toBuyItemCountChanged(_ toBuyManager: ToBuyManager, count: Int)
    func delayedItemCountChanged(_ toBuyManager: ToBuyManager, count: Int)
}

class ToBuyManager {
    private let entityName = "ToBuy"
    private(set) var viewContext: NSManagedObjectContext
    
    var delegate: ToBuyListDelegate!
    
    init(_ viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
    }
    
    func importToBuys (from url: URL) {
        guard
            let data = try? Data(contentsOf: url),
            let toBuys = try? JSONDecoder().decode([ToBuyItem].self, from: data)
          else { return }
        
        // skip existing ones
        toBuys.forEach { toBuy in
            if (!isAlreadyExistInToBuyList(name: toBuy.name)) {
                initToBuyItem(name: toBuy.name, category: toBuy.category, image: toBuy.image!, supermarket: toBuy.supermarket, isForeign: true)
            }
        }
    }

    func exportToUrl() -> URL? {
        let allToBuys = allRemainingToBuys()

        guard let encoded = try? JSONEncoder().encode(allToBuys) else {
            return nil
        }
        
        let documents = FileManager.default.urls(
          for: .documentDirectory,
          in: .userDomainMask
        ).first
        
        guard let path = documents?.appendingPathComponent("/\(UUID()).tblr") else {
            return nil
        }
        
        do {
            try encoded.write(to: path, options: .atomicWrite)
            return path
        } catch {
            print(error)
            return nil
        }
    }

    func initToBuyItem(name: String, category: Int, image: Data, supermarket: String, isForeign: Bool = false) {
        let entity = NSEntityDescription.entity(forEntityName: entityName, in: viewContext)!
        let item = NSManagedObject(entity: entity, insertInto: viewContext)
        
        item.setValue(name, forKeyPath: "name")
        item.setValue(category, forKey: "category")
        item.setValue(image, forKey: "image")
        item.setValue(supermarket, forKey: "supermarket")
        item.setValue(Date(), forKeyPath: "createdAt")
        item.setValue(false, forKey: "isCompleted")
        item.setValue(false, forKey: "isDelayed")
        item.setValue(isForeign, forKey: "isForeign")
        item.setValue(0, forKey: "priority")
        
        do {
            try viewContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }

    func deleteItemByNameFromToBuys(name: String) {
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: entityName)
        fetchRequest.predicate = NSPredicate(format: "name = %@", name)
        
        do {
            let result = try viewContext.fetch(fetchRequest)
            if(result.count > 0) {
                let obj = result[0] as! NSManagedObject
                viewContext.delete(obj)
                do {
                    try viewContext.save()
                } catch {
                    print(error)
                }
            }
        }catch let error as NSError {
            print("Could not delete value. \(error), \(error.userInfo)")
        }
    }

    func isAlreadyExistInToBuyList(name: String) -> Bool {
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: entityName)
        
        let namePredicate = NSPredicate(format: "name = %@", name)
        let completedPredicate = NSPredicate(format: "isCompleted = %d", false)
        
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [namePredicate, completedPredicate])
        
        do {
            let result = try viewContext.fetch(fetchRequest)
            return result.count != 0
        }catch let error as NSError {
            print("Could not fetch value. \(error), \(error.userInfo)")
        }
        
        return false
    }

    func allRemainingToBuys() -> [ToBuyItem] {
        var toBuyList: [NSManagedObject] = []
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
        
        let sortDescriptorCreatedAt = NSSortDescriptor(key: "createdAt", ascending: false)
        let sortDescriptorSupermarket = NSSortDescriptor(key: "supermarket", ascending: true)

        fetchRequest.sortDescriptors = [sortDescriptorSupermarket, sortDescriptorCreatedAt]
        let completedPredicate = NSPredicate(format: "isCompleted = %d", false)
        fetchRequest.predicate = completedPredicate
        
        do {
            toBuyList = try viewContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        let allItems: [ToBuyItem] = toBuyList.map { (nsobj: NSManagedObject) in
            return ToBuyItem(name: nsobj.value(forKey: "name") as! String,
                             category: nsobj.value(forKey: "category") as! Int,
                             priority: nsobj.value(forKey: "priority") as! Int,
                             supermarket: nsobj.value(forKey: "supermarket") as! String,
                             image: nsobj.value(forKey: "image") as? Data,
                             isCompleted: (nsobj.value(forKey: "isCompleted") as! Bool),
                             isForeign: (nsobj.value(forKey: "isForeign") as! Bool),
                             isDelayed: (nsobj.value(forKey: "isDelayed") as! Bool),
                             createdAt: (nsobj.value(forKey: "createdAt") as! Date))
        }
        
        return allItems
    }

    func fetchAllToBuyItems() -> [ToBuyItem] {
        var toBuyList: [NSManagedObject] = []
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
        
        let sortDescriptorCreatedAt = NSSortDescriptor(key: "createdAt", ascending: false)
        let sortDescriptorSupermarket = NSSortDescriptor(key: "supermarket", ascending: true)

        fetchRequest.sortDescriptors = [sortDescriptorSupermarket, sortDescriptorCreatedAt]
        
        do {
            toBuyList = try viewContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        let allItems: [ToBuyItem] = toBuyList.map { (nsobj: NSManagedObject) in
            return ToBuyItem(name: nsobj.value(forKey: "name") as! String,
                             category: nsobj.value(forKey: "category") as! Int,
                             priority: nsobj.value(forKey: "priority") as! Int,
                             supermarket: nsobj.value(forKey: "supermarket") as! String,
                             image: nsobj.value(forKey: "image") as? Data,
                             isCompleted: (nsobj.value(forKey: "isCompleted") as! Bool),
                             isForeign: (nsobj.value(forKey: "isForeign") as! Bool),
                             isDelayed: (nsobj.value(forKey: "isDelayed") as! Bool),
                             createdAt: (nsobj.value(forKey: "createdAt") as! Date))
        }
        
        let toBuyItems = allItems.filter { !$0.isCompleted && !$0.isDelayed }
        let delayedItems = allItems.filter { $0.isDelayed }
        
        if let delegate = delegate {
            delegate.toBuyItemCountChanged(self, count: toBuyItems.count)
            delegate.delayedItemCountChanged(self, count: delayedItems.count)
        }

        return allItems
    }

    // DO NOT CALL IT DIRECTLY - internal use only
    func deleteAllToBuys(){
        let request = NSBatchDeleteRequest(fetchRequest: NSFetchRequest<NSFetchRequestResult>(entityName: entityName))
        do {
            try viewContext.execute(request)
        }
        catch {
            print(error)
        }
    }
}
