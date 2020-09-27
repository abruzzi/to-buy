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

extension UITableView {
    func emptyState (label: String, image: String) {
        let emptyView = EmptyList(frame: CGRect(x: self.center.x, y: self.center.y, width: self.bounds.size.width, height: self.bounds.size.height), label: label, image: image)
        self.backgroundView = emptyView
        self.separatorStyle = .none
    }
    
    func restore () {
        self.backgroundView = nil
        self.separatorStyle = .singleLine
    }
}

extension ToBuyTableViewController: HistoryDelegate {
    func historyCountChanged(_ hisotryManager: HistoryManager, count: Int) {
        DispatchQueue.main.async {
            self.historyCountLabel.text = String(count)
        }
    }
    
    func mostRecentSnapshotsChanged(_ historyManager: HistoryManager, images: [UIImage]) {
        DispatchQueue.main.async {
            if(images.count == 4) {
                self.firstImageSnapshot.image = images[0]
                self.secondImageSnapshot.image = images[1]
                self.thirdImageSnapshot.image = images[2]
                self.forthImageSnapshot.image = images[3]
            }
            
        }
    }
}

class ToBuyTableViewController: UITableViewController {
    
    let searchController = UISearchController(searchResultsController: nil)
    
    let historyManager = HistoryManager(UIApplication.shared.delegate as! AppDelegate)
    
    private lazy var toBuyDataProvider: ToBuysProvider = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let provider = ToBuysProvider(with: appDelegate.persistentContainer,
                                      fetchedResultsControllerDelegate: self)
        return provider
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        historyManager.fetchToBuyHistory()
        self.updateBadge()
    }
    
    @IBOutlet weak var buttonShare: UIBarButtonItem!
    @IBOutlet weak var headerViewContainer: UIView!
    @IBOutlet weak var historyCountLabel: UILabel!
    
    @IBOutlet weak var firstImageSnapshot: UIImageView!
    @IBOutlet weak var secondImageSnapshot: UIImageView!
    @IBOutlet weak var thirdImageSnapshot: UIImageView!
    @IBOutlet weak var forthImageSnapshot: UIImageView!
    
    @IBAction func shareToBuys(_ sender: UIBarButtonItem) {
        let path = exportToUrl()
        
        let activity = UIActivityViewController(
            activityItems: ["Share your tobuys with your friend now", path],
            applicationActivities: nil
        )
        activity.popoverPresentationController?.barButtonItem = sender
        present(activity, animated: true, completion: nil)
    }
    
    let categories = ["All", "Remaining", "Shared with me"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search for buy items"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        searchController.searchBar.scopeButtonTitles = categories
        searchController.searchBar.delegate = self
        
        headerViewContainer.layer.cornerRadius = 4
        historyCountLabel.layer.cornerRadius = 4
        historyCountLabel.layer.masksToBounds = true
        
        firstImageSnapshot.layer.cornerRadius = 4.0
        secondImageSnapshot.layer.cornerRadius = 4.0
        thirdImageSnapshot.layer.cornerRadius = 4.0
        forthImageSnapshot.layer.cornerRadius = 4.0
        
        
        historyManager.historyDelegate = self
        tableView.register(UINib(nibName: "ToBuyTableViewCell", bundle: nil), forCellReuseIdentifier: reuseIdentifier)
    }
    
    func filterContentForSearchText(_ searchText: String,
                                    category: String) {
        let keywords = NSPredicate(format: "name CONTAINS[c] %@", searchText)
        let isNotDelayedPredicate = NSPredicate(format: "isDelayed = false")
        let isForeignPredicate = NSPredicate(format: "isForeign = true")
        let isCompletedPredicate = NSPredicate(format: "isCompleted = false")
        
        var predicate:NSPredicate
        
        switch category {
        case "All":
            predicate = NSCompoundPredicate(andPredicateWithSubpredicates: searchText.isEmpty ? [isNotDelayedPredicate] : [keywords, isNotDelayedPredicate])
        case "Remaining":
            predicate = NSCompoundPredicate(andPredicateWithSubpredicates: searchText.isEmpty ? [isNotDelayedPredicate, isCompletedPredicate] : [keywords, isNotDelayedPredicate, isCompletedPredicate])
        case "Shared with me":
            predicate = NSCompoundPredicate(andPredicateWithSubpredicates: searchText.isEmpty ? [isNotDelayedPredicate, isForeignPredicate] : [keywords, isNotDelayedPredicate, isForeignPredicate])
        default:
            predicate = NSCompoundPredicate(andPredicateWithSubpredicates: searchText.isEmpty ? [isNotDelayedPredicate] : [keywords, isNotDelayedPredicate])
        }
        
        toBuyDataProvider.fetchedResultsController.fetchRequest.predicate = predicate
        
        do {
            try toBuyDataProvider.fetchedResultsController.performFetch()
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } catch let err {
            print(err)
        }
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let item = toBuyDataProvider.fetchedResultsController.object(at: indexPath)
        if(!item.isCompleted) {
            let later = laterAction(at: indexPath)
            let complete = completeAction(at: indexPath)
            return UISwipeActionsConfiguration(actions: [complete, later])
        } else {
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = deleteAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [delete])
    }
    
    func completeAction(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: NSLocalizedString("action.complete.title", comment: "action.complete.title")) { (_, view, completion) in
            self.toBuyDataProvider.markAsCompleted(at: indexPath)
            completion(true)
        }
        action.image = UIImage(systemName: "checkmark")
        action.backgroundColor = .systemGreen
        return action
    }
    
    func laterAction(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: NSLocalizedString("action.delay.title", comment: "action.delay.title")) { (_, view, completion) in
            self.toBuyDataProvider.markAsDelayed(at: indexPath)
            completion(true)
        }
        action.image = UIImage(systemName: "clock")
        action.backgroundColor = .systemOrange
        return action
    }
    
    func pushItemIntoHistory(item: ToBuys) {
        return historyManager.pushIntoToBuyHistory(item: item)
    }
    
    func deleteAction(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: NSLocalizedString("action.delete.title", comment: "action.delete.title")) { (_, view, completion) in
            let item = self.toBuyDataProvider.fetchedResultsController.object(at: indexPath)
            self.pushItemIntoHistory(item: item)
            self.toBuyDataProvider.deleteToBuyItem(at: indexPath)
            completion(true)
        }
        action.image = UIImage(systemName: "delete.right")
        action.backgroundColor = .systemRed
        return action
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        var count = 0
        if let sections = toBuyDataProvider.fetchedResultsController.sections {
            count = sections.count
        }
        
        print("number of sections \(count)")
        
        if(count == 0) {
            self.tableView.emptyState(label: NSLocalizedString("to.buy.empty.hint.message", comment: "to.buy.empty.hint.message"), image: "icons8-basket")
        } else {
            self.tableView.restore()
        }
        
        return count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = toBuyDataProvider.fetchedResultsController.sections {
            let currentSection = sections[section]
            return currentSection.numberOfObjects
        }
        
        return 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection
        section: Int) -> String? {
        if let sections = toBuyDataProvider.fetchedResultsController.sections {
            let currentSection = sections[section]
            return currentSection.name.isEmpty ? NSLocalizedString("to.buy.items", comment: "to.buy.items")  : currentSection.name
        }
        return nil
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToBuyTableViewCell", for: indexPath) as! ToBuyTableViewCell
        let item = toBuyDataProvider.fetchedResultsController.object(at: indexPath)
        cell.configure(with: item)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let item = toBuyDataProvider.fetchedResultsController.object(at: indexPath)
        
        return UIContextMenuConfiguration(identifier: item.name as NSCopying?, previewProvider: {
            let view = ItemPreviewViewController(itemName: item.name!, image: item.image!)
            return view
        }){ _ in
            let delayAction = UIAction(
                title: NSLocalizedString("action.delay.title", comment: "action.delay.title"),
                image: UIImage(systemName: "clock")) { _ in
                    self.toBuyDataProvider.markAsDelayed(at: indexPath)
            }
            
            let completeAction = UIAction(
                title: NSLocalizedString("action.complete.title", comment: "action.complete.title"),
                image: UIImage(systemName: "checkmark")) { _ in
                    self.toBuyDataProvider.markAsCompleted(at: indexPath)
            }
            
            let deleteAction = UIAction(
                title: NSLocalizedString("action.delete.title", comment: "action.delete.title"),
                image: UIImage(systemName: "delete.right"),
                attributes: .destructive) { _ in
                    let item = self.toBuyDataProvider.fetchedResultsController.object(at: indexPath)
                    self.pushItemIntoHistory(item: item)
                    self.toBuyDataProvider.deleteToBuyItem(at: indexPath)
            }
            
            if(item.isCompleted) {
                return UIMenu(title: "", children: [deleteAction])
            } else {
                return UIMenu(title: "", children: [delayAction, completeAction, deleteAction])
            }
        }
    }
}

extension ToBuyTableViewController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
    let searchBar = searchController.searchBar
    filterContentForSearchText(searchBar.text!, category: searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex])
  }
}

extension ToBuyTableViewController: UISearchBarDelegate {
  func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
    filterContentForSearchText(searchBar.text!, category: searchBar.scopeButtonTitles![selectedScope])
  }
}


extension ToBuyTableViewController: NSFetchedResultsControllerDelegate {
    // 1
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, sectionIndexTitleForSectionName sectionName: String) -> String? {
        print("section name: \(sectionName)")
        return sectionName
    }
    
    // 2
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        print("section changed \(type) - \(sectionInfo)")
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
        case .update:
            tableView.reloadSections(IndexSet(integer: sectionIndex), with: .automatic)
        case .move:
            break
        @unknown default:
            fatalError("unknown \(type)")
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        print("didchange anObject: \(anObject)")
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else {
                return
            }
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .delete:
            guard let indexPath = indexPath else {
                return
            }
            tableView.deleteRows(at: [indexPath], with: .automatic)
        case .update:
            guard let indexPath = indexPath else {
                return
            }
            tableView.reloadRows(at: [indexPath], with: .automatic)
        case .move:
            guard let indexPath = indexPath else {
                return
            }
            guard let newIndexPath = newIndexPath else {
                return
            }
            tableView.moveRow(at: indexPath, to: newIndexPath)
        @unknown default:
            fatalError("unknown \(type)")
        }
    }
    
    // 5
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
        self.updateBadge()
    }
}

