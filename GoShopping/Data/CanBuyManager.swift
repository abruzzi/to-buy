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
    private(set) var viewContext: NSManagedObjectContext
    
    init(_ viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
    }
    
    func saveAllCanBuyItem(canBuyItems: [CanBuyItem]) {
        
        let entity = NSEntityDescription.entity(forEntityName: entityName, in: viewContext)!
        canBuyItems.forEach { canBuyItem in
            let item = NSManagedObject(entity: entity, insertInto: viewContext)
            
            item.setValue(canBuyItem.name, forKeyPath: "name")
            item.setValue(canBuyItem.category, forKey: "category")
            item.setValue(canBuyItem.image, forKeyPath: "image")
            item.setValue(Date(), forKeyPath: "createdAt")
            item.setValue(canBuyItem.supermarket, forKeyPath: "supermarket")
        }
        
        do {
            try viewContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }

    func deleteAllCanBuys(){
        let DelAllReqVar = NSBatchDeleteRequest(fetchRequest: NSFetchRequest<NSFetchRequestResult>(entityName: entityName))
        do {
            try viewContext.execute(DelAllReqVar)
        }
        catch {
            print(error)
        }
    }
}
