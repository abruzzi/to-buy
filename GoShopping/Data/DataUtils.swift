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
    var category: Int
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

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    let toBuyManager = ToBuyManager(appDelegate)
    let canBuyManager = CanBuyManager(appDelegate)
    
    toBuyManager.deleteAllToBuys() // clean up user's selection for avoading any poetential conflicts
    canBuyManager.deleteAllCanBuys() // clean up dictionary
    
    var canBuyItems: [CanBuyItem] = []
    records.forEach {record in
        record.items.forEach { (item: Item) in
            canBuyItems.append(
                CanBuyItem(
                    name: item.name,
                    category: record.category,
                    image: UIImage(named: item.image)?.pngData(),
                    supermarket: ((item.attrs["supermarket"] != nil) ? item.attrs["supermarket"]: "")!))
        }
    }

    canBuyManager.saveAllCanBuyItem(canBuyItems: canBuyItems)
}
