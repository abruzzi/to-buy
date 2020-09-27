////
////  ToBuyManager.swift
////  GoShopping
////
////  Created by Juntao Qiu on 27/9/20.
////  Copyright © 2020 Juntao Qiu. All rights reserved.
////
//
//import Foundation
//
//import UIKit
//import CoreData
//
//struct ToBuyItem: Codable {
//    var name: String
//    var category: Int
//    var priority: Int
//    var supermarket: String
//    var image: Data?
//    var isCompleted: Bool
//    var isForeign: Bool
//    var isDelayed: Bool
//    var createdAt: Date
//    
//    func getImage() -> UIImage? {
//        if let data = image {
//            return UIImage(data: data)
//        }
//        return nil
//    }
//}
//
//func exportToUrl() -> URL? {
//    let allToBuys = allRemainingToBuys()
//
//    guard let encoded = try? JSONEncoder().encode(allToBuys) else {
//        return nil
//    }
//    
//    let documents = FileManager.default.urls(
//      for: .documentDirectory,
//      in: .userDomainMask
//    ).first
//    
//    guard let path = documents?.appendingPathComponent("/\(UUID()).tblr") else {
//        return nil
//    }
//    
//    do {
//        try encoded.write(to: path, options: .atomicWrite)
//        return path
//    } catch {
//        print(error)
//        return nil
//    }
//}
//
//class ToBuyManager {
//    private let entityName = ""
//    
//    func importToBuys (from url: URL) {
//        guard
//            let data = try? Data(contentsOf: url),
//            let toBuys = try? JSONDecoder().decode([ToBuyItem].self, from: data)
//          else { return }
//        
//        // skip existing ones
//        toBuys.forEach { toBuy in
//            if (!isAlreadyExistInToBuyList(name: toBuy.name)) {
//                initToBuyItem(name: toBuy.name, category: toBuy.category, image: toBuy.image!, supermarket: toBuy.supermarket, isForeign: true)
//            }
//        }
//    }
//
//    func initToBuyItem(name: String, category: Int, image: Data, supermarket: String, isForeign: Bool = false) {
//        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
//            return
//        }
//        
//        let managedContext = appDelegate.persistentContainer.viewContext
//        let entity = NSEntityDescription.entity(forEntityName: "ToBuys", in: managedContext)!
//        let item = NSManagedObject(entity: entity, insertInto: managedContext)
//        
//        item.setValue(name, forKeyPath: "name")
//        item.setValue(category, forKey: "category")
//        item.setValue(image, forKey: "image")
//        item.setValue(supermarket, forKey: "supermarket")
//        item.setValue(Date(), forKeyPath: "createdAt")
//        item.setValue(false, forKey: "isCompleted")
//        item.setValue(false, forKey: "isDelayed")
//        item.setValue(isForeign, forKey: "isForeign")
//        item.setValue(0, forKey: "priority")
//        
//        do {
//            try managedContext.save()
//        } catch let error as NSError {
//            print("Could not save. \(error), \(error.userInfo)")
//        }
//    }
//
//    func deleteItemByNameFromToBuys(name: String) {
//        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
//            return
//        }
//        
//        let managedContext = appDelegate.persistentContainer.viewContext
//        
//        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "ToBuys")
//        fetchRequest.predicate = NSPredicate(format: "name = %@", name)
//        
//        do {
//            let result = try managedContext.fetch(fetchRequest)
//            if(result.count > 0) {
//                let obj = result[0] as! NSManagedObject
//                managedContext.delete(obj)
//                do {
//                    try managedContext.save()
//                } catch {
//                    print(error)
//                }
//            }
//        }catch let error as NSError {
//            print("Could not delete value. \(error), \(error.userInfo)")
//        }
//    }
//
//    func isAlreadyExistInToBuyList(name: String) -> Bool {
//        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
//            return false
//        }
//        
//        let managedContext = appDelegate.persistentContainer.viewContext
//        
//        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "ToBuys")
//        
//        let namePredicate = NSPredicate(format: "name = %@", name)
//        let completedPredicate = NSPredicate(format: "isCompleted = %d", false)
//        
//        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [namePredicate, completedPredicate])
//        
//        do {
//            let result = try managedContext.fetch(fetchRequest)
//            return result.count != 0
//        }catch let error as NSError {
//            print("Could not fetch value. \(error), \(error.userInfo)")
//        }
//        
//        return false
//    }
//
//    func allRemainingToBuys() -> [ToBuyItem] {
//        var toBuyList: [NSManagedObject] = []
//        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
//            return []
//        }
//        
//        let managedContext = appDelegate.persistentContainer.viewContext
//        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ToBuys")
//        
//        let sortDescriptorCreatedAt = NSSortDescriptor(key: "createdAt", ascending: false)
//        let sortDescriptorSupermarket = NSSortDescriptor(key: "supermarket", ascending: true)
//
//        fetchRequest.sortDescriptors = [sortDescriptorSupermarket, sortDescriptorCreatedAt]
//        let completedPredicate = NSPredicate(format: "isCompleted = %d", false)
//        fetchRequest.predicate = completedPredicate
//        
//        do {
//            toBuyList = try managedContext.fetch(fetchRequest)
//        } catch let error as NSError {
//            print("Could not fetch. \(error), \(error.userInfo)")
//        }
//        
//        let allItems: [ToBuyItem] = toBuyList.map { (nsobj: NSManagedObject) in
//            return ToBuyItem(name: nsobj.value(forKey: "name") as! String,
//                             category: nsobj.value(forKey: "category") as! Int,
//                             priority: nsobj.value(forKey: "priority") as! Int,
//                             supermarket: nsobj.value(forKey: "supermarket") as! String,
//                             image: nsobj.value(forKey: "image") as? Data,
//                             isCompleted: (nsobj.value(forKey: "isCompleted") as! Bool),
//                             isForeign: (nsobj.value(forKey: "isForeign") as! Bool),
//                             isDelayed: (nsobj.value(forKey: "isDelayed") as! Bool),
//                             createdAt: (nsobj.value(forKey: "createdAt") as! Date))
//        }
//        
//        return allItems
//    }
//
//    func fetchAllToBuyItems() -> [ToBuyItem] {
//        var toBuyList: [NSManagedObject] = []
//        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
//            return []
//        }
//        
//        let managedContext = appDelegate.persistentContainer.viewContext
//        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ToBuys")
//        
//        let sortDescriptorCreatedAt = NSSortDescriptor(key: "createdAt", ascending: false)
//        let sortDescriptorSupermarket = NSSortDescriptor(key: "supermarket", ascending: true)
//
//        fetchRequest.sortDescriptors = [sortDescriptorSupermarket, sortDescriptorCreatedAt]
//        
//        do {
//            toBuyList = try managedContext.fetch(fetchRequest)
//        } catch let error as NSError {
//            print("Could not fetch. \(error), \(error.userInfo)")
//        }
//        
//        let allItems: [ToBuyItem] = toBuyList.map { (nsobj: NSManagedObject) in
//            return ToBuyItem(name: nsobj.value(forKey: "name") as! String,
//                             category: nsobj.value(forKey: "category") as! Int,
//                             priority: nsobj.value(forKey: "priority") as! Int,
//                             supermarket: nsobj.value(forKey: "supermarket") as! String,
//                             image: nsobj.value(forKey: "image") as? Data,
//                             isCompleted: (nsobj.value(forKey: "isCompleted") as! Bool),
//                             isForeign: (nsobj.value(forKey: "isForeign") as! Bool),
//                             isDelayed: (nsobj.value(forKey: "isDelayed") as! Bool),
//                             createdAt: (nsobj.value(forKey: "createdAt") as! Date))
//        }
//        
//        return allItems
//    }
//
//    func updateRecordFor(name: String, dict: Dictionary<String, Any>) {
//        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
//            return
//        }
//        
//        let managedContext = appDelegate.persistentContainer.viewContext
//        
//        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "ToBuys")
//        fetchRequest.predicate = NSPredicate(format: "name = %@", name)
//        
//        do {
//            let result = try managedContext.fetch(fetchRequest)
//            let obj = result[0] as! NSManagedObject
//            
//            dict.forEach { (key, value) in
//                obj.setValue(value, forKey: key)
//            }
//            
//            do {
//                try managedContext.save()
//            } catch {
//                print(error)
//            }
//        }catch let error as NSError {
//            print("Could not update value. \(error), \(error.userInfo)")
//        }
//    }
//
//    func updateRecordFor(name: String, key: String, value: Any) {
//        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
//            return
//        }
//        
//        let managedContext = appDelegate.persistentContainer.viewContext
//        
//        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "ToBuys")
//        fetchRequest.predicate = NSPredicate(format: "name = %@", name)
//        
//        do {
//            let result = try managedContext.fetch(fetchRequest)
//            let obj = result[0] as! NSManagedObject
//            obj.setValue(value, forKey: key)
//            do {
//                try managedContext.save()
//            } catch {
//                print(error)
//            }
//        }catch let error as NSError {
//            print("Could not update value. \(error), \(error.userInfo)")
//        }
//    }
//
//    func deleteAllToBuys(){
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        let managedContext = appDelegate.persistentContainer.viewContext
//        let DelAllReqVar = NSBatchDeleteRequest(fetchRequest: NSFetchRequest<NSFetchRequestResult>(entityName: "ToBuys"))
//        do {
//            try managedContext.execute(DelAllReqVar)
//        }
//        catch {
//            print(error)
//        }
//    }
//
//
//}
