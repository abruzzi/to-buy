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
    var image: String
    var items: [Item]
}

struct Item: Hashable, Codable, Identifiable {
    let id = UUID()
    var name: String
    var image: String
    var attrs: [String: String]
}
