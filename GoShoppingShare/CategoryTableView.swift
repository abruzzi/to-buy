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

let categoryTitles = [
    NSLocalizedString("category.food.title", comment: "category.food.title"),
    NSLocalizedString("category.essentials.title", comment: "category.essentials.title"),
    NSLocalizedString("category.health.title", comment: "category.health.title"),
    NSLocalizedString("category.others.title", comment: "category.others.title")
]

class CategoryTableView: UIViewController, UITableViewDelegate, UITableViewDataSource {
    weak var delegate: ShareSelectViewControllerDelegate?
    let reuseIdentifier = "categoryCell"
    
    var tableView: UITableView = UITableView(frame: .zero, style: .insetGrouped)
    
    var safeArea: UILayoutGuide!
    
    override func loadView() {
      super.loadView()
      safeArea = view.layoutMarginsGuide
      setupTableView()
    }

    func setupTableView () {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: safeArea.topAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        title = "Select Category"

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryTitles.count
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        cell.textLabel?.text = categoryTitles[indexPath.row]

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let delegate = delegate {
            delegate.selected(category: categoryTitles[indexPath.row])
        }
    }
}
