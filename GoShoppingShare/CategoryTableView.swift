//
//  CategoryTableView.swift
//  GoShoppingShare
//
//  Created by Juntao Qiu on 5/10/20.
//  Copyright © 2020 Juntao Qiu. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class CategoryTableView: UITableViewController {
    weak var delegate: ShareSelectViewControllerDelegate?
    let reuseIdentifier = "categoryCell"
 
    let categoryTitles = [
        NSLocalizedString("category.food.title", comment: "category.food.title"),
        NSLocalizedString("category.essentials.title", comment: "category.essentials.title"),
        NSLocalizedString("category.health.title", comment: "category.health.title"),
        NSLocalizedString("category.others.title", comment: "category.others.title")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        title = "Select Category"

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return categoryTitles.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        cell.textLabel?.text = categoryTitles[indexPath.row]

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let delegate = delegate {
            delegate.selected(category: categoryTitles[indexPath.row])
        }
    }
}
