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
        var toBuyList: [NSManagedObject] = []
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
          return
        }

        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ToBuys")

        do {
          toBuyList = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
          print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        let allItems = toBuyList.map { nsobj in
            return ToBuyItem(name: nsobj.value(forKey: "name") as! String,
                             image: nsobj.value(forKey: "image") as! String,
                             isCompleted: (nsobj.value(forKey: "isCompleted") as! Bool),
                             isDelayed: (nsobj.value(forKey: "isDelayed") as! Bool))
        }
        
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
    
    func updateRecordFor(name: String, key: String, value: Any) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
          return
        }

        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "ToBuys")
        fetchRequest.predicate = NSPredicate(format: "name = %@", name)
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            let obj = result[0] as! NSManagedObject
            obj.setValue(value, forKey: key)
            do {
                try managedContext.save()
            } catch {
                print(error)
            }
        }catch let error as NSError {
          print("Could not update value. \(error), \(error.userInfo)")
        }
    }
    
    func delete(name: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
          return
        }

        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "ToBuys")
        fetchRequest.predicate = NSPredicate(format: "name = %@", name)
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            let obj = result[0] as! NSManagedObject
            managedContext.delete(obj)
            do {
                try managedContext.save()
            } catch {
                print(error)
            }
        }catch let error as NSError {
          print("Could not delete value. \(error), \(error.userInfo)")
        }
    }
    
    func completeAction(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: "Complete") { (_, view, completion) in
            let item = self.toBuyItems[indexPath.row]
            self.markAsCompleted(name: item.name)
            self.refreshToBuyList()
            self.tableView.reloadData()
            completion(true)
        }
        action.image = UIImage(systemName: "stopwatch")
        action.backgroundColor = .systemGreen
        return action
    }
    
    func laterAction(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: "Later") { (_, view, completion) in
            let item = self.toBuyItems[indexPath.row]
            self.markAsDelayed(name: item.name)
            self.refreshToBuyList()
            self.tableView.reloadData()
            completion(true)
        }
        action.image = UIImage(systemName: "clock")
        action.backgroundColor = .systemOrange
        return action
    }
    
    func deleteAction(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: "Delete") { (_, view, completion) in
            let item = self.completedItems[indexPath.row]
            self.delete(name: item.name)
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
            return "要买的"
        case 1:
            return "买到的"
        default:
            return "-"
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToBuyTableViewCell", for: indexPath) as! ToBuyTableViewCell
        
        let item = (indexPath.section == 0) ? toBuyItems[indexPath.row] : completedItems[indexPath.row]
        cell.configure(with: item.name, image: item.image)
        
        return cell
    }
}

struct ToBuyItem {
    var name: String
    var image: String
    var isCompleted: Bool
    var isDelayed: Bool
}
