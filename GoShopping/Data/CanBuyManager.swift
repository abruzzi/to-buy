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

struct CanBuyItem {
    var name: String
    var category: Int
    var image: Data?
    var supermarket: String
    
    func getImage() -> UIImage? {
        if let data = image {
            return UIImage(data: data)
        }
        return nil
    }
}

class CanBuyManager {
    private let entityName = "CanBuy"
    private var appDelegate: AppDelegate!
    
    init(_ appDelegate: AppDelegate) {
        self.appDelegate = appDelegate
    }
    
    func saveAllCanBuyItem(canBuyItems: [CanBuyItem]) {
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: entityName, in: managedContext)!
        canBuyItems.forEach { canBuyItem in
            let item = NSManagedObject(entity: entity, insertInto: managedContext)
            
            item.setValue(canBuyItem.name, forKeyPath: "name")
            item.setValue(canBuyItem.category, forKey: "category")
            item.setValue(canBuyItem.image, forKeyPath: "image")
            item.setValue(Date(), forKeyPath: "createdAt")
            item.setValue(canBuyItem.supermarket, forKeyPath: "supermarket")
        }
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }

    func deleteItemByNameFromCanBuys(name: String) {
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: entityName)
        fetchRequest.predicate = NSPredicate(format: "name = %@", name)
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            if(result.count > 0) {
                let obj = result[0] as! NSManagedObject
                managedContext.delete(obj)
                do {
                    try managedContext.save()
                } catch {
                    print(error)
                }
            }
        }catch let error as NSError {
            print("Could not delete value. \(error), \(error.userInfo)")
        }
    }

    func saveCanBuyItem(canBuyItem: CanBuyItem) {
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: entityName, in: managedContext)!
        let item = NSManagedObject(entity: entity, insertInto: managedContext)
        
        item.setValue(canBuyItem.name, forKeyPath: "name")
        item.setValue(canBuyItem.category, forKey: "category")
        item.setValue(canBuyItem.image, forKeyPath: "image")
        item.setValue(Date(), forKeyPath: "createdAt")
        item.setValue(canBuyItem.supermarket, forKeyPath: "supermarket")
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }

    func isNewItemInApp(name: String) -> Bool{
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: entityName)
        fetchRequest.predicate = NSPredicate(format: "name = %@", name)
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            return result.count == 0
        }catch let error as NSError {
            print("Could not fetch value. \(error), \(error.userInfo)")
        }
        
        return false
    }

    func updateCanBuyItem(name: String, dict: Dictionary<String, Any>) {
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: entityName)
        fetchRequest.predicate = NSPredicate(format: "name = %@", name)
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            let obj = result[0] as! NSManagedObject
            
            dict.forEach { (key, value) in
                obj.setValue(value, forKey: key)
            }
            
            do {
                try managedContext.save()
            } catch {
                print(error)
            }
        }catch let error as NSError {
            print("Could not update value. \(error), \(error.userInfo)")
        }
    }

    func fetchAllCanBuyList() -> [CanBuyItem] {
        var toBuyList: [NSManagedObject] = []

        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
        
        let sortDescriptor = NSSortDescriptor(key: "category", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            toBuyList = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        let allItems: [CanBuyItem] = toBuyList.map { (nsobj: NSManagedObject) in
            return CanBuyItem(name: nsobj.value(forKey: "name") as! String,
                              category: nsobj.value(forKey: "category") as! Int,
                              image: nsobj.value(forKey: "image") as? Data,
                              supermarket: nsobj.value(forKey: "supermarket") as! String)
        }
        
        return allItems
    }

    func deleteAllCanBuys(){
        let managedContext = appDelegate.persistentContainer.viewContext
        let DelAllReqVar = NSBatchDeleteRequest(fetchRequest: NSFetchRequest<NSFetchRequestResult>(entityName: entityName))
        do {
            try managedContext.execute(DelAllReqVar)
        }
        catch {
            print(error)
        }
    }


    func allCanBuyList() -> [[CanBuyItem]]{
        let canBuyList = fetchAllCanBuyList()
        
        return [
            canBuyList.filter {$0.category == 0},
            canBuyList.filter {$0.category == 1},
            canBuyList.filter {$0.category == 2},
            canBuyList.filter {$0.category == 3}
        ]
    }

}
