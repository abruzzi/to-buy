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

    func createCanBuy(name: String,
                      category: Int,
                      image: Data,
                      supermarket: String) {
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
