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
    var supermarket: String
    var image: String
    var isCompleted: Bool
    var isDelayed: Bool
}

func saveToBuyItem(name: String, category: String, image: String, supermarket: String) {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
        return
    }
    
    let managedContext = appDelegate.persistentContainer.viewContext
    let entity = NSEntityDescription.entity(forEntityName: "ToBuys", in: managedContext)!
    let item = NSManagedObject(entity: entity, insertInto: managedContext)
    
    item.setValue(name, forKeyPath: "name")
    item.setValue(category, forKey: "category")
    item.setValue(image, forKey: "image")
    item.setValue(supermarket, forKey: "supermarket")
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

func isAlreadyExistInToBuyList(name: String) -> Bool{
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
        print("Could not fetch value. \(error), \(error.userInfo)")
    }
    
    return false
}

func fetchAllToBuyItems() -> [ToBuyItem] {
    var toBuyList: [NSManagedObject] = []
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
        return []
    }
    
    let managedContext = appDelegate.persistentContainer.viewContext
    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ToBuys")
    
    let sortDescriptorCreatedAt = NSSortDescriptor(key: "createdAt", ascending: false)
    let sortDescriptorSupermarket = NSSortDescriptor(key: "supermarket", ascending: true)

    fetchRequest.sortDescriptors = [sortDescriptorSupermarket, sortDescriptorCreatedAt]
    
    do {
        toBuyList = try managedContext.fetch(fetchRequest)
    } catch let error as NSError {
        print("Could not fetch. \(error), \(error.userInfo)")
    }
    
    let allItems: [ToBuyItem] = toBuyList.map { (nsobj: NSManagedObject) in
        return ToBuyItem(name: nsobj.value(forKey: "name") as! String,
                         category: nsobj.value(forKey: "category") as! String,
                         supermarket: nsobj.value(forKey: "supermarket") as! String,
                         image: nsobj.value(forKey: "image") as! String,
                         isCompleted: (nsobj.value(forKey: "isCompleted") as! Bool),
                         isDelayed: (nsobj.value(forKey: "isDelayed") as! Bool))
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

func deleteAllToBuys(){
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let managedContext = appDelegate.persistentContainer.viewContext
    let DelAllReqVar = NSBatchDeleteRequest(fetchRequest: NSFetchRequest<NSFetchRequestResult>(entityName: "ToBuys"))
    do {
        try managedContext.execute(DelAllReqVar)
    }
    catch {
        print(error)
    }
}

// can buy items

struct CanBuyItem {
    var name: String
    var category: String
    var image: String
    var supermarket: String
}

func saveAllCanBuyItem(canBuyItems: [CanBuyItem]) {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
        return
    }
    
    let managedContext = appDelegate.persistentContainer.viewContext
    let entity = NSEntityDescription.entity(forEntityName: "CanBuys", in: managedContext)!
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

func saveCanBuyItem(canBuyItem: CanBuyItem) {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
        return
    }
    
    let managedContext = appDelegate.persistentContainer.viewContext
    let entity = NSEntityDescription.entity(forEntityName: "CanBuys", in: managedContext)!
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
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
        return false
    }
    
    let managedContext = appDelegate.persistentContainer.viewContext
    
    let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "CanBuys")
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
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
        return
    }
    
    let managedContext = appDelegate.persistentContainer.viewContext
    
    let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "CanBuys")
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
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
        return []
    }
    
    let managedContext = appDelegate.persistentContainer.viewContext
    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CanBuys")
    
    let sortDescriptor = NSSortDescriptor(key: "category", ascending: true)
    fetchRequest.sortDescriptors = [sortDescriptor]
    
    do {
        toBuyList = try managedContext.fetch(fetchRequest)
    } catch let error as NSError {
        print("Could not fetch. \(error), \(error.userInfo)")
    }
    
    let allItems: [CanBuyItem] = toBuyList.map { (nsobj: NSManagedObject) in
        return CanBuyItem(name: nsobj.value(forKey: "name") as! String,
                          category: nsobj.value(forKey: "category") as! String,
                          image: nsobj.value(forKey: "image") as! String,
                          supermarket: nsobj.value(forKey: "supermarket") as! String)
    }
    
    return allItems
}

func deleteAllCanBuys(){
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let managedContext = appDelegate.persistentContainer.viewContext
    let DelAllReqVar = NSBatchDeleteRequest(fetchRequest: NSFetchRequest<NSFetchRequestResult>(entityName: "CanBuys"))
    do {
        try managedContext.execute(DelAllReqVar)
    }
    catch {
        print(error)
    }
}

func load<T: Decodable>(_ filename: String) -> T {
    let data: Data
    
    guard let file = Bundle.main.url(forResource: filename, withExtension: nil)
        else {
            fatalError("Couldn't find \(filename) in main bundle.")
    }
    
    do {
        data = try Data(contentsOf: file)
    } catch {
        fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
    }
    
    do {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    } catch {
        fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
    }
}

struct Record: Hashable, Codable {
    var category: String
    var image: String
    var items: [Item]
}

struct Item: Hashable, Codable, Identifiable {
    let id = UUID()
    var name: String
    var image: String
    var attrs: [String: String]
}

func resetAllDBItems(lang: String) {
    let records: [Record] = (lang.lowercased() == "en") ? load("category.json") :  load("category-cn.json")

    deleteAllToBuys() // clean up user's selection for avoading any poetential conflicts
    deleteAllCanBuys() // clean up dictionary
    
    func resetDatabaseForCategory() {
        
        var canBuyItems: [CanBuyItem] = []
        records.forEach {record in
            record.items.forEach { item in
                canBuyItems.append(CanBuyItem(name: item.name, category: record.category, image: item.image, supermarket: ((item.attrs["supermarket"] != nil) ? item.attrs["supermarket"]: "")!))
            }
        }

        saveAllCanBuyItem(canBuyItems: canBuyItems)
    }
    
    resetDatabaseForCategory()
}
