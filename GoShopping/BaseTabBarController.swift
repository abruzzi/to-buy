//
//  BaseTabBarController.swift
//  GoShopping
//
//  Created by Juntao Qiu on 1/9/20.
//  Copyright © 2020 Juntao Qiu. All rights reserved.
//

import UIKit

class BaseTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

public class CategoryFetcher: ObservableObject {
    @Published var records = [Record]()
    let defaults = UserDefaults.standard
    
    init(){
        if(defaults.bool(forKey: "first-time")) {
            loadRemoteFile()
        } else {
            loadLocalFile()
        }
    }

    func loadRemoteFile(){
        let filemgr = FileManager.default
        let urls = filemgr.urls(for: .documentDirectory, in: .userDomainMask)
        if let url = URL(string: remoteCategoryUrl) {
           URLSession.shared.dataTask(with: url) { data, response, error in
              if let data = data {
                  do {
                    let decodedLists = try JSONDecoder().decode([Record].self, from: data)

                    if let url = urls.first {
                        var fileURL = url.appendingPathComponent("category")
                        fileURL = fileURL.appendingPathExtension("json")
                        try data.write(to: fileURL, options: [.atomicWrite])
                    }
                    
                    DispatchQueue.main.async {
                        self.records = decodedLists
                    }
                  } catch let error {
                     print(error)
                  }
               }
           }.resume()
        }
    }
    
    func loadLocalFile() {
        let filemgr = FileManager.default
        let urls = filemgr.urls(for: .documentDirectory, in: .userDomainMask)
        
        if let url = urls.first {
            var fileURL = url.appendingPathComponent("category")
            fileURL = fileURL.appendingPathExtension("json")
            let decodedLists: [Record] = loadFromURL(fileURL)
            DispatchQueue.main.async {
                self.records = decodedLists
            }
        }
    }
    
}
