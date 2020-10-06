//
//  HistoryTableViewController.swift
//  GoShopping
//
//  Created by Juntao Qiu on 28/9/20.
//  Copyright © 2020 Juntao Qiu. All rights reserved.
//

import UIKit
import CoreData

private let reuseIdentifier = "ToBuyTableViewCell"

class HistoryTableViewController: UITableViewController {
    let store = CoreDataStack.store
    
    private lazy var toBuyManger: ToBuyManager = {
        return ToBuyManager(store.viewContext)
    }()
    
    private lazy var dataProvider: ToBuyHistoryProvider = {
        let provider = ToBuyHistoryProvider(with: store.viewContext,
                                      fetchedResultsControllerDelegate: self)
        return provider
    }()
    
    @IBOutlet weak var clearAllButton: UIBarButtonItem!
    
    @IBAction func clearAllHistory(_ sender: UIBarButtonItem) {

        let alert = UIAlertController(title: "Warnning", message: "Are you sure you want to clean up all the shopping history", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("message.hint.clean.history.ok", comment: "message.hint.clean.history.ok"), style: .destructive, handler: { action in
            self.dataProvider.cleanupAllHistory()
            self.tableView.reloadData()
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("message.hint.clean.history.cancel", comment: "message.hint.clean.history.cancel"), style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        clearAllButton.isEnabled = dataProvider.fetchedResultsController.fetchedObjects?.count != 0
        
        tableView.register(UINib(nibName: "ToBuyTableViewCell", bundle: nil), forCellReuseIdentifier: reuseIdentifier)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        var count = 0
        if let sections = dataProvider.fetchedResultsController.sections {
            count = sections.count
        }
        
        if(count == 0) {
            self.tableView.emptyState(label: NSLocalizedString("history.empty.hint.message", comment: "history.empty.hint.message"), image: "icons8-historic_ship")
        } else {
            self.tableView.restore()
        }
        
        return count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = dataProvider.fetchedResultsController.sections {
            let currentSection = sections[section]
            return currentSection.numberOfObjects
        }
        
        return 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection
        section: Int) -> String? {
        if let sections = dataProvider.fetchedResultsController.sections {
            let currentSection = sections[section]
            
            return currentSection.name.isEmpty ? NSLocalizedString("to.buy.items", comment: "to.buy.items")  : currentSection.name
        }
        return nil
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToBuyTableViewCell", for: indexPath) as! ToBuyTableViewCell
        let item = dataProvider.fetchedResultsController.object(at: indexPath)
        cell.configure(with: item)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = restoreAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [delete])
    }
    
    func restoreAction(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: NSLocalizedString("action.delete.title", comment: "action.delete.title")) { (_, view, completion) in
            let item = self.dataProvider.fetchedResultsController.object(at: indexPath)
            
            if(!self.toBuyManger.isAlreadyExistInToBuyList(name: item.name!)) {
                self.toBuyManger.initToBuyItem(name: item.name!, category: Int(item.category), image: item.image!, supermarket: item.supermarket!)
                self.dataProvider.deleteHistoryItem(at: indexPath)
            }
            
            completion(true)
        }
        action.image = UIImage(systemName: "backward")
        action.backgroundColor = .systemGreen
        return action
    }
    
}

extension HistoryTableViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        clearAllButton.isEnabled = dataProvider.fetchedResultsController.fetchedObjects?.count != 0
        
        tableView.reloadData()
    }
}
