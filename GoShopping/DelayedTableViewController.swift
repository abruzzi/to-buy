//
//  DelayedTableViewController.swift
//  GoShopping
//
//  Created by Juntao Qiu on 2/9/20.
//  Copyright © 2020 Juntao Qiu. All rights reserved.
//

import UIKit
import CoreData

private let reuseIdentifier = "ToBuyTableViewCell"

class DelayedTableViewController: UITableViewController {
    private var delayedItems: [ToBuyItem]!
    
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
        
        let allItems: [ToBuyItem] = toBuyList.map { (nsobj: NSManagedObject) in
            var item:ToBuyItem = ToBuyItem(name: nsobj.value(forKey: "name") as! String,
                             category: nsobj.value(forKey: "category") as! String,
                             isCompleted: (nsobj.value(forKey: "isCompleted") as! Bool),
                             isDelayed: (nsobj.value(forKey: "isDelayed") as! Bool))
            
            let record = fetcher.records.first { $0.category == item.category }
            let result = record!.items.first { $0.name == item.name }
            item.image = result?.image
            item.attrs = result?.attrs
            
            return item
        }
        
        delayedItems = allItems.filter { $0.isDelayed }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "ToBuyTableViewCell", bundle: nil), forCellReuseIdentifier: reuseIdentifier)
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let complete = completeAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [complete])
    }
    
    func markAsCompleted(name: String) {
        updateRecordFor(name: name, dict: ["isCompleted": true, "isDelayed": false])
    }
    
    func updateRecordFor(name: String, dict: Dictionary<String, Any>) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
          return
        }

        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "ToBuys")
        fetchRequest.predicate = NSPredicate(format: "name = %@", name)
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            let obj = result[0] as! NSManagedObject
            
            dict.forEach { (key, value) in
                obj.setValue(value, forKey: key)
            }
            
            do {
                try managedContext.save()
            } catch {
                print(error)
            }
        }catch let error as NSError {
          print("Could not update value. \(error), \(error.userInfo)")
        }
    }
    
    func completeAction(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: "Complete") { (_, view, completion) in
            let item = self.delayedItems[indexPath.row]
            self.markAsCompleted(name: item.name)
            self.refreshToBuyList()
            self.tableView.reloadData()
            completion(true)
        }
        action.image = UIImage(systemName: "stopwatch")
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
        return "暂时没找到的"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToBuyTableViewCell", for: indexPath) as! ToBuyTableViewCell
        let item = delayedItems[indexPath.row]

        cell.configure(with: item)

        return cell
    }
}
