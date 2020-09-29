//
//  TagManager.swift
//  GoShopping
//
//  Created by Juntao Qiu on 29/9/20.
//  Copyright © 2020 Juntao Qiu. All rights reserved.
//

import Foundation
import CoreData

class TagManager {
    private let entityName = "Tag"
    private(set) var viewContext: NSManagedObjectContext
    
    init(_ viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
    }
    
    func deleteAllTags(){
        let request = NSBatchDeleteRequest(fetchRequest: NSFetchRequest<NSFetchRequestResult>(entityName: entityName))
        do {
            try viewContext.execute(request)
        }
        catch {
            print(error)
        }
    }
}
