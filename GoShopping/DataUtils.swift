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

struct ToBuyItem {
    var name: String
    var category: String
    var image: String?
    var attrs: [String: String]?
    var isCompleted: Bool
    var isDelayed: Bool
}

func save(name: String, category: String) {
  guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
    return
  }

  let managedContext = appDelegate.persistentContainer.viewContext
  let entity = NSEntityDescription.entity(forEntityName: "ToBuys", in: managedContext)!
  let item = NSManagedObject(entity: entity, insertInto: managedContext)
    
    item.setValue(name, forKeyPath: "name")
    item.setValue(category, forKey: "category")
    item.setValue(Date(), forKeyPath: "createdAt")
    item.setValue(false, forKey: "isCompleted")
    item.setValue(false, forKey: "isDelayed")

  do {
    try managedContext.save()
  } catch let error as NSError {
    print("Could not save. \(error), \(error.userInfo)")
  }
}

func deleteItemByName(name: String) {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
      return
    }

    let managedContext = appDelegate.persistentContainer.viewContext
    
    let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "ToBuys")
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

func isAlreadyExist(name: String) -> Bool{
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
       return false
     }

     let managedContext = appDelegate.persistentContainer.viewContext
     
     let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "ToBuys")
     fetchRequest.predicate = NSPredicate(format: "name = %@", name)
     
     do {
        let result = try managedContext.fetch(fetchRequest)
        return result.count != 0
     }catch let error as NSError {
       print("Could not delete value. \(error), \(error.userInfo)")
     }
    
    return false
}

func fetchAllToBuyList() -> [ToBuyItem] {
    var toBuyList: [NSManagedObject] = []
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
      return []
    }

    let managedContext = appDelegate.persistentContainer.viewContext
    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ToBuys")

    do {
      toBuyList = try managedContext.fetch(fetchRequest)
    } catch let error as NSError {
      print("Could not fetch. \(error), \(error.userInfo)")
    }
    
    let allItems: [ToBuyItem] = toBuyList.map { (nsobj: NSManagedObject) in
        var item:ToBuyItem = ToBuyItem(name: nsobj.value(forKey: "name") as! String,
                         category: nsobj.value(forKey: "category") as! String,
                         isCompleted: (nsobj.value(forKey: "isCompleted") as! Bool),
                         isDelayed: (nsobj.value(forKey: "isDelayed") as! Bool))
        
        let record = appDelegate.records.first { $0.category == item.category }
        
        if let result = record?.items.first(where: { $0.name == item.name }) {
            item.image = result.image
            item.attrs = result.attrs
        }
        
        return item
    }
    
    return allItems
}

func updateRecordFor(name: String, dict: Dictionary<String, Any>) {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
      return
    }

    let managedContext = appDelegate.persistentContainer.viewContext
    
    let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "ToBuys")
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

func updateRecordFor(name: String, key: String, value: Any) {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
      return
    }

    let managedContext = appDelegate.persistentContainer.viewContext
    
    let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "ToBuys")
    fetchRequest.predicate = NSPredicate(format: "name = %@", name)
    
    do {
        let result = try managedContext.fetch(fetchRequest)
        let obj = result[0] as! NSManagedObject
        obj.setValue(value, forKey: key)
        do {
            try managedContext.save()
        } catch {
            print(error)
        }
    }catch let error as NSError {
      print("Could not update value. \(error), \(error.userInfo)")
    }
}
