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
    private lazy var dataProvider: ToBuysProvider = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let provider = ToBuysProvider(with: appDelegate.persistentContainer,
                                   fetchedResultsControllerDelegate: self)
        return provider
    }()
    
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
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataProvider.fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection
                                section: Int) -> String? {
        let text = NSLocalizedString("could.not.found.now", comment: "could.not.found.now")
        return text
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
                    self.dataProvider.deleteToBuyItem(at: indexPath)
            }

            return UIMenu(title: "", children: [completeAction, deleteAction])
        }
    }
}

extension DelayedTableViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
        self.updateBadge()
    }
}
