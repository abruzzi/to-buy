//
//  ToBuyTableViewController.swift
//  GoShopping
//
//  Created by Juntao Qiu on 1/9/20.
//  Copyright © 2020 Juntao Qiu. All rights reserved.
//

import UIKit
import CoreData

private let reuseIdentifier = "ToBuyTableViewCell"

class ToBuyTableViewController: UITableViewController {
    private var toBuyItems: [ToBuyItem]!
    private var completedItems: [ToBuyItem]!
    
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      self.refreshToBuyList()
      self.tableView.reloadData()
    }
    
    func refreshToBuyList() {
        let allItems = fetchAllToBuyItems()
        toBuyItems = allItems.filter { !$0.isCompleted && !$0.isDelayed }
        completedItems = allItems.filter { $0.isCompleted }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "ToBuyTableViewCell", bundle: nil), forCellReuseIdentifier: reuseIdentifier)
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        
        leftSwipe.direction = .left
        rightSwipe.direction = .right
        
        self.view.addGestureRecognizer(leftSwipe)
        self.view.addGestureRecognizer(rightSwipe)
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if(indexPath.section == 0) {
            let complete = completeAction(at: indexPath)
            return UISwipeActionsConfiguration(actions: [complete])
        } else {
            return nil
        }        
    }
    
     override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
         if(indexPath.section == 0) {
             let later = laterAction(at: indexPath)
             return UISwipeActionsConfiguration(actions: [later])
         } else {
            let delete = deleteAction(at: indexPath)
            return UISwipeActionsConfiguration(actions: [delete])
        }
     }

    func markAsCompleted(name: String) {
        updateRecordFor(name: name, key: "isCompleted", value: true)
    }
    
    func markAsDelayed(name: String) {
        updateRecordFor(name: name, key: "isDelayed", value: true)
    }

    func completeAction(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: NSLocalizedString("action.complete.title", comment: "action.complete.title")) { (_, view, completion) in
            let item = self.toBuyItems[indexPath.row]
            self.markAsCompleted(name: item.name)
            self.updateBadge()
            self.refreshToBuyList()
            self.tableView.reloadData()
            completion(true)
        }
        action.image = UIImage(systemName: "stopwatch")
        action.backgroundColor = .systemGreen
        return action
    }
    
    func laterAction(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: NSLocalizedString("action.delay.title", comment: "action.delay.title")) { (_, view, completion) in
            let item = self.toBuyItems[indexPath.row]
            self.markAsDelayed(name: item.name)
            self.updateBadge()
            self.refreshToBuyList()
            self.tableView.reloadData()
            completion(true)
        }
        action.image = UIImage(systemName: "clock")
        action.backgroundColor = .systemOrange
        return action
    }
    
    func deleteAction(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: NSLocalizedString("action.delete.title", comment: "action.delete.title")) { (_, view, completion) in
            let item = self.completedItems[indexPath.row]
            deleteItemByName(name: item.name)
            self.updateBadge()
            self.refreshToBuyList()
            self.tableView.reloadData()
            completion(true)
        }
        action.image = UIImage(systemName: "delete.right")
        action.backgroundColor = .systemRed
        return action
    }
 
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch (section) {
            case 0:
                return toBuyItems.count
            case 1:
                return completedItems.count
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection
                                section: Int) -> String? {
        switch section {
        case 0:
            return NSLocalizedString("to.buy.items", comment: "to.buy.items")
        case 1:
            return NSLocalizedString("purchased.items", comment: "purchased.items")
        default:
            return "-"
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToBuyTableViewCell", for: indexPath) as! ToBuyTableViewCell
        
        let item = (indexPath.section == 0) ? toBuyItems[indexPath.row] : completedItems[indexPath.row]
        cell.configure(with: item)
        
        return cell
    }
}
