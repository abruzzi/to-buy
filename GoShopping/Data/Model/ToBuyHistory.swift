//
//  ToBuyHistory.swift
//  GoShopping
//
//  Created by Juntao Qiu on 28/9/20.
//  Copyright © 2020 Juntao Qiu. All rights reserved.
//

import Foundation
import CoreData

class ToBuyHistory: NSManagedObject {
    @objc var formattedCreatedAt: String {
        get {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy MMM dd"
            return dateFormatter.string(from: self.createdAt!)
        }
    }
}
