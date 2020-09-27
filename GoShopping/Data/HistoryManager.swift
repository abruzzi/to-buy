//
//  HistoryManager.swift
//  GoShopping
//
//  Created by Juntao Qiu on 27/9/20.
//  Copyright © 2020 Juntao Qiu. All rights reserved.
//

import UIKit
import CoreData

protocol HistoryDelegate {
    func historyCountChanged(_ hisotryManager: HistoryManager, count: Int)
    func mostRecentSnapshotsChanged(_ historyManager: HistoryManager, images: [UIImage])
}

class HistoryManager {
    private let entityName = "ToBuyHistory"
    
    private var appDelegate: AppDelegate!
    var historyDelegate: HistoryDelegate!
    
    init(_ appDelegate: AppDelegate) {
        self.appDelegate = appDelegate
    }
    
    func fetchToBuyHistory() {
        let count = totalInToBuyHistory()
        let images = getMostRecentImageSnapshots() ?? []
        
        if let delegate = historyDelegate {
            delegate.historyCountChanged(self, count: count)
            delegate.mostRecentSnapshotsChanged(self, images: images)
        }
    }
    
    func pushIntoToBuyHistory(item tobuy: ToBuys) {
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "ToBuyHistory", in: managedContext)!
        let item = NSManagedObject(entity: entity, insertInto: managedContext)
        
        item.setValue(UUID(), forKey: "uuid")
        item.setValue(tobuy.name, forKeyPath: "name")
        item.setValue(tobuy.category, forKey: "category")
        item.setValue(tobuy.image, forKey: "image")
        item.setValue(tobuy.supermarket, forKey: "supermarket")
        item.setValue(Date(), forKeyPath: "createdAt")
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
        let count = totalInToBuyHistory()
        let images = getMostRecentImageSnapshots() ?? []
        
        if let delegate = historyDelegate {
            delegate.historyCountChanged(self, count: count)
            delegate.mostRecentSnapshotsChanged(self, images: images)
        }
        
    }

    func totalInToBuyHistory() -> Int {
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ToBuyHistory")
        
        do {
            let result = try managedContext.count(for: fetchRequest)
            return result
        }catch let error as NSError {
            print("Could not fetch value. \(error), \(error.userInfo)")
        }
        
        return 0
    }

    func cleanupAllHistory() {
        let managedContext = appDelegate.persistentContainer.viewContext
        let request = NSBatchDeleteRequest(fetchRequest: NSFetchRequest<NSFetchRequestResult>(entityName: "ToBuyHistory"))
        do {
            try managedContext.execute(request)
        }
        catch {
            print(error)
        }
    }
    
    func getMostRecentImageSnapshots() -> [UIImage]? {
        var mostRecentToBuyItems: [NSManagedObject] = []
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ToBuyHistory")
        
        let sortDescriptorCreatedAt = NSSortDescriptor(key: "createdAt", ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptorCreatedAt]
        fetchRequest.fetchLimit = 4
        
        do {
            mostRecentToBuyItems = try managedContext.fetch(fetchRequest)
        }catch let error as NSError {
            print("Could not fetch value. \(error), \(error.userInfo)")
        }
        
        return mostRecentToBuyItems.map { (nsobj: NSManagedObject) in
            let data = nsobj.value(forKey: "image") as! Data
            return UIImage(data: data)!
        }
    }
}
