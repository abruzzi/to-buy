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
    private lazy var dataProvider: DelayedToBuysProvider = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let provider = DelayedToBuysProvider(with: appDelegate.persistentContainer,
                                   fetchedResultsControllerDelegate: self)
        return provider
    }()
    
    private let historyManager = HistoryManager(UIApplication.shared.delegate as! AppDelegate)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        historyManager.historyDelegate = self
        tableView.register(UINib(nibName: "ToBuyTableHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "toBuyTableHeaderView")
        tableView.register(UINib(nibName: "ToBuyTableViewCell", bundle: nil), forCellReuseIdentifier: reuseIdentifier)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        self.updateBadge()
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = deleteAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [delete])
    }

    func deleteAction(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: NSLocalizedString("action.delete.title", comment: "action.delete.title")) { (_, view, completion) in
            let item = self.dataProvider.fetchedResultsController.object(at: indexPath)
            self.historyManager.pushIntoToBuyHistory(item: item)
            self.dataProvider.deleteToBuyItem(at: indexPath)
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

    func completeAction(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: "Complete") { (_, view, completion) in
            self.dataProvider.markAsCompleted(at: indexPath)
            completion(true)
        }
        action.image = UIImage(systemName: "checkmark")
        action.backgroundColor = .systemGreen
        return action
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        var count = 0
        if let sections = dataProvider.fetchedResultsController.sections {
            count = sections.count
        }
        
        if(count == 0) {
            self.tableView.emptyState(label: NSLocalizedString("delayed.empty.hint.message", comment: "delayed.empty.hint.message"), image: "icons8-empty_jam_jar")
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
            return currentSection.name.isEmpty ? NSLocalizedString("could.not.found.now", comment: "could.not.found.now")  : currentSection.name
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToBuyTableViewCell", for: indexPath) as! ToBuyTableViewCell
        let item = dataProvider.fetchedResultsController.object(at: indexPath)

        cell.configure(with: item)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let data = dataProvider.fetchedResultsController.object(at: indexPath)

        return UIContextMenuConfiguration(identifier: data.name as NSCopying?, previewProvider: {
            let view = ItemPreviewViewController(itemName: data.name!, image: data.image!)
            return view
        }){ _ in
            let completeAction = UIAction(
                title: NSLocalizedString("action.complete.title", comment: "action.complete.title"),
                image: UIImage(systemName: "checkmark")) { _ in
                    self.dataProvider.markAsCompleted(at: indexPath)
            }

            let deleteAction = UIAction(
                title: NSLocalizedString("action.delete.title", comment: "action.delete.title"),
                image: UIImage(systemName: "delete.right"),
                attributes: .destructive) { _ in
                    let item = self.dataProvider.fetchedResultsController.object(at: indexPath)
                    self.historyManager.pushIntoToBuyHistory(item: item)
                    self.dataProvider.deleteToBuyItem(at: indexPath)
            }

            return UIMenu(title: "", children: [completeAction, deleteAction])
        }
    }
}

extension DelayedTableViewController: HistoryDelegate {
    func historyCountChanged(_ hisotryManager: HistoryManager, count: Int) {
        // print(count)
    }
    
    func mostRecentSnapshotsChanged(_ historyManager: HistoryManager, images: [UIImage]) {
        // print(images.count)
    }
}

extension DelayedTableViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
        self.updateBadge()
    }
}
