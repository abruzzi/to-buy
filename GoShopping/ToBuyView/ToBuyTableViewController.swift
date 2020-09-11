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
      self.updateBadge()
    }
    
    func refreshToBuyList() {
        let allItems = fetchAllToBuyItems()
        toBuyItems = allItems.filter { !$0.isCompleted && !$0.isDelayed }
        completedItems = allItems.filter { $0.isCompleted }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "ToBuyTableViewCell", bundle: nil), forCellReuseIdentifier: reuseIdentifier)
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

    func completeItem (item: ToBuyItem) {
        self.markAsCompleted(name: item.name)
        self.updateBadge()
        self.refreshToBuyList()
        self.tableView.reloadData()
    }
    
    func completeAction(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: NSLocalizedString("action.complete.title", comment: "action.complete.title")) { (_, view, completion) in
            let item = self.toBuyItems[indexPath.row]
            self.completeItem(item: item)
            completion(true)
        }
        action.image = UIImage(systemName: "checkmark")
        action.backgroundColor = .systemGreen
        return action
    }
    
    func delayItem(item: ToBuyItem) {
        self.markAsDelayed(name: item.name)
        self.updateBadge()
        self.refreshToBuyList()
        self.tableView.reloadData()
    }
    
    func laterAction(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: NSLocalizedString("action.delay.title", comment: "action.delay.title")) { (_, view, completion) in
            let item = self.toBuyItems[indexPath.row]
            self.delayItem(item: item)
            completion(true)
        }
        action.image = UIImage(systemName: "clock")
        action.backgroundColor = .systemOrange
        return action
    }
    
    func deleteItem(item: ToBuyItem) {
        deleteItemByNameFromToBuys(name: item.name)
        self.updateBadge()
        self.refreshToBuyList()
        self.tableView.reloadData()
    }
    
    func deleteAction(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: NSLocalizedString("action.delete.title", comment: "action.delete.title")) { (_, view, completion) in
            let item = self.completedItems[indexPath.row]
            self.deleteItem(item: item)
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
    
    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let item = (indexPath.section == 0) ? toBuyItems[indexPath.row] : completedItems[indexPath.row]

        return UIContextMenuConfiguration(identifier: item.name as NSString, previewProvider: {
            let view = ItemPreviewViewController(itemName: item.name, image: item.image)
            return view
        }){ _ in
            let delayAction = UIAction(
                title: NSLocalizedString("action.delay.title", comment: "action.delay.title"),
                image: UIImage(systemName: "clock")) { _ in
                    self.delayItem(item: item)
            }
            
            let completeAction = UIAction(
                title: NSLocalizedString("action.complete.title", comment: "action.complete.title"),
                image: UIImage(systemName: "checkmark")) { _ in
                    self.completeItem(item: item)
            }
            
            let deleteAction = UIAction(
                title: NSLocalizedString("action.delete.title", comment: "action.delete.title"),
                image: UIImage(systemName: "delete.right"),
                attributes: .destructive) { _ in
                    self.deleteItem(item: item)
            }
            
            if(indexPath.section == 0) {
                return UIMenu(title: "", children: [delayAction, completeAction])
            } else {
                return UIMenu(title: "", children: [deleteAction])
            }
            
        }
    }
}
