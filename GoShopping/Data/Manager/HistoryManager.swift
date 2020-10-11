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
    
    private(set) var viewContext: NSManagedObjectContext
    var historyDelegate: HistoryDelegate!
    
    init(_ viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
    }
    
    func fetchToBuyHistory() {
        let count = totalInToBuyHistory()
        let images = getMostRecentImageSnapshots() ?? []
        
        if let delegate = historyDelegate {
            delegate.historyCountChanged(self, count: count)
            delegate.mostRecentSnapshotsChanged(self, images: images)
        }
    }
    
    func pushIntoToBuyHistory(item tobuy: ToBuy) {
        let entity = NSEntityDescription.entity(forEntityName: entityName, in: viewContext)!
        let item = NSManagedObject(entity: entity, insertInto: viewContext)
        
        item.setValue(UUID(), forKey: "uuid")
        item.setValue(tobuy.name, forKeyPath: "name")
        item.setValue(tobuy.category, forKey: "category")
        item.setValue(tobuy.image, forKey: "image")
        item.setValue(tobuy.supermarket, forKey: "supermarket")
        item.setValue(Date(), forKeyPath: "createdAt")
        
        do {
            try viewContext.save()
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
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
        
        do {
            let result = try viewContext.count(for: fetchRequest)
            return result
        }catch let error as NSError {
            print("Could not fetch value. \(error), \(error.userInfo)")
        }
        
        return 0
    }

    func cleanupAllHistory() {
        let request = NSBatchDeleteRequest(fetchRequest: NSFetchRequest<NSFetchRequestResult>(entityName: entityName))
        do {
            try viewContext.execute(request)
        }
        catch {
            print(error)
        }
    }
    
    func getMostRecentImageSnapshots() -> [UIImage]? {
        var mostRecentToBuyItems: [NSManagedObject] = []
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
        
        let sortDescriptorCreatedAt = NSSortDescriptor(key: "createdAt", ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptorCreatedAt]
        fetchRequest.fetchLimit = 4
        
        do {
            mostRecentToBuyItems = try viewContext.fetch(fetchRequest)
        }catch let error as NSError {
            print("Could not fetch value. \(error), \(error.userInfo)")
        }
        
        return mostRecentToBuyItems.map { (nsobj: NSManagedObject) in
            if let data = nsobj.value(forKey: "image") as? Data {
                return UIImage(data: data) ?? placeHolderImage!
            } else {
                return placeHolderImage!
            }
        }
    }
}
