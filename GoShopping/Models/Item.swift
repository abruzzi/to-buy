//
//  Item.swift
//  GoShopping
//
//  Created by Juntao Qiu on 1/9/20.
//  Copyright © 2020 Juntao Qiu. All rights reserved.
//

import Foundation
import UIKit

struct Record: Hashable, Codable {
    var category: String
    fileprivate var categoryIcon: String
    var items: [Item]
}

struct Item: Hashable, Codable, Identifiable {
    var id: Int
    var name: String
    fileprivate var icon: String
}

extension Item {
    var image: UIImage {
        return UIImage(systemName: icon)!
    }
}

extension Record {
    var image: UIImage {
        return UIImage(systemName: categoryIcon)!
    }
}
