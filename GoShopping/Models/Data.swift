//
//  Data.swift
//  GoShopping
//
//  Created by Juntao Qiu on 1/9/20.
//  Copyright © 2020 Juntao Qiu. All rights reserved.
//

import Foundation
/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Helpers for loading images and data.
*/

import UIKit
import SwiftUI

func loadFromURL<T: Decodable>(_ url: URL) -> T {
    let data: Data
    
    do {
        data = try Data(contentsOf: url)
    } catch {
        fatalError("Couldn't load \(url) from main bundle:\n\(error)")
    }
    
    do {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    } catch {
        fatalError("Couldn't parse \(url) as \(T.self):\n\(error)")
    }
}

let remoteCategoryUrl = "https://raw.githubusercontent.com/abruzzi/to-buy/master/GoShopping/Resources/category.json"
