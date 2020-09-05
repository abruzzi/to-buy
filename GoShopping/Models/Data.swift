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

let records: [Record] = load("category.json")

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

func downloadRemoteConfig(){
    let filemgr = FileManager.default
    let urls = filemgr.urls(for: .documentDirectory, in: .userDomainMask)
    if let url = URL(string: remoteCategoryUrl) {
       URLSession.shared.dataTask(with: url) { data, response, error in
          if let data = data {
              do {
//                 let res = try JSONDecoder().decode([Record].self, from: data)
//                print(res)
                if let url = urls.first {
                    var fileURL = url.appendingPathComponent("category")
                    fileURL = fileURL.appendingPathExtension("json")
                    print(fileURL)
                    
                    try data.write(to: fileURL, options: [.atomicWrite])
//                    let data = try JSONSerialization.data(withJSONObject: res, options: [.prettyPrinted])
//                    print(data)
//                    try data.write(to: fileURL, options: [.atomicWrite])
                }
              } catch let error {
                 print(error)
              }
           }
       }.resume()
    }
}

func writeToLocalFile() {
    let filemgr = FileManager.default
    let urls = filemgr.urls(for: .documentDirectory, in: .userDomainMask)
    
    if let url = urls.first {
        var fileURL = url.appendingPathComponent("category")
        fileURL = fileURL.appendingPathExtension("json")
        print(fileURL)
//        let data = try JSONSerialization.data(withJSONObject: content, options: [.prettyPrinted])
//        print(data)
//        try data.write(to: fileURL, options: [.atomicWrite])
    }

}

func download() {
    let url = URL(string: remoteCategoryUrl)!
    writeToLocalFile()
    let task = URLSession.shared.downloadTask(with: url) { localURL, urlResponse, error in

        
        if let localURL = localURL {
            print(localURL)
            if let string = try? String(contentsOf: localURL) {
                print(string)
            }
        }
    }

    task.resume()
}
