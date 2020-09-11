//
//  DelayedTableViewController.swift
//  GoShopping
//
//  Created by Juntao Qiu on 2/9/20.
//  Copyright © 2020 Juntao Qiu. All rights reserved.
//

import UIKit
import CoreData
import SwiftUI

private let reuseIdentifier = "ToBuyTableViewCell"

class DelayedTableViewController: UITableViewController {
    private var delayedItems: [ToBuyItem]!
    
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      self.refreshToBuyList()
      self.tableView.reloadData()
      self.updateBadge()
    }
    
    func refreshToBuyList() {
        let allItems = fetchAllToBuyItems()
        delayedItems = allItems.filter { $0.isDelayed }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "ToBuyTableViewCell", bundle: nil), forCellReuseIdentifier: reuseIdentifier)
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = deleteAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [delete])
    }
    
    func deleteAction(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: NSLocalizedString("action.delete.title", comment: "action.delete.title")) { (_, view, completion) in
            let item = self.delayedItems[indexPath.row]
            deleteItemByNameFromToBuys(name: item.name)
            self.updateBadge()
            self.refreshToBuyList()
            self.tableView.reloadData()
            completion(true)
        }
        action.image = UIImage(systemName: "delete.right")
        action.backgroundColor = .systemRed
        return action
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let complete = completeAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [complete])
    }
    
    func markAsCompleted(name: String) {
        updateRecordFor(name: name, dict: ["isCompleted": true, "isDelayed": false])
        updateBadge()
    }
    
    func completeAction(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: "Complete") { (_, view, completion) in
            let item = self.delayedItems[indexPath.row]
            self.markAsCompleted(name: item.name)
            self.refreshToBuyList()
            self.tableView.reloadData()
            completion(true)
        }
        action.image = UIImage(systemName: "checkmark")
        action.backgroundColor = .systemGreen
        return action
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return delayedItems.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection
                                section: Int) -> String? {
        let text = NSLocalizedString("could.not.found.now", comment: "could.not.found.now")
        return text
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToBuyTableViewCell", for: indexPath) as! ToBuyTableViewCell
        let item = delayedItems[indexPath.row]

        cell.configure(with: item)

        return cell
    }
}
