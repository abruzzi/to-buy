//
//  ToBuyTableViewController.swift
//  GoShopping
//
//  Created by Juntao Qiu on 1/9/20.
//  Copyright © 2020 Juntao Qiu. All rights reserved.
//

import UIKit
import CoreData
import CoreSpotlight
import MobileCoreServices
import LinkPresentation

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
        let placeholder = UIImage(named: "placeholdertext.fill")
        DispatchQueue.main.async {
            if(images.count == 4) {
                self.firstImageSnapshot.image = images[0]
                self.secondImageSnapshot.image = images[1]
                self.thirdImageSnapshot.image = images[2]
                self.forthImageSnapshot.image = images[3]
            } else {
                self.firstImageSnapshot.image = placeholder
                self.secondImageSnapshot.image = placeholder
                self.thirdImageSnapshot.image = placeholder
                self.forthImageSnapshot.image = placeholder
            }
        }
    }
}

class ToBuyTableViewController: UITableViewController {
    let store = CoreDataStack.store
    
    let searchController = UISearchController(searchResultsController: nil)
    
    private lazy var historyManager: HistoryManager = {
        return HistoryManager(store.viewContext)
    }()
    
    private lazy var toBuyManager: ToBuyManager = {
        return ToBuyManager(store.viewContext)
    }()
    
    private lazy var dataProvider: ToBuysProvider = {
        let provider = ToBuysProvider(with: store.viewContext,
                                      fetchedResultsControllerDelegate: self)
        return provider
    }()
    
    private func updateBadge() {
        let tabbar = self.tabBarController as? BaseTabBarController
        tabbar?.updateBadge()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        historyManager.fetchToBuyHistory()
        tableView.reloadData()
        self.updateBadge()
    }
    
    @IBOutlet weak var buttonShare: UIBarButtonItem!
    @IBOutlet weak var headerViewContainer: UIView!
    @IBOutlet weak var historyCountLabel: UILabel!
    
    @IBOutlet weak var firstImageSnapshot: UIImageView!
    @IBOutlet weak var secondImageSnapshot: UIImageView!
    @IBOutlet weak var thirdImageSnapshot: UIImageView!
    @IBOutlet weak var forthImageSnapshot: UIImageView!
    
    func getMetadataForSharing(title: String, url: URL, fileName: String, fileType: String) -> LPLinkMetadata {
        let linkMetaData = LPLinkMetadata()
        let path = Bundle.main.path(forResource: fileName, ofType: fileType)
        linkMetaData.iconProvider = NSItemProvider(contentsOf: URL(fileURLWithPath: path ?? ""))
        linkMetaData.originalURL = url
        linkMetaData.title = title
        return linkMetaData
    }
    
    @IBAction func shareToBuys(_ sender: UIBarButtonItem) {
        let path = toBuyManager.exportToUrl()
        
        let metaData = getMetadataForSharing(title: NSLocalizedString("share.message.title", comment: "share.message.title"), url: path!, fileName: "icon_76pt@2x", fileType: "png")

        let metadataItemSource = LinkPresentationItemSource(metaData: metaData)
        let activity = UIActivityViewController(
            activityItems: [metadataItemSource],
            applicationActivities: nil
        )
        activity.popoverPresentationController?.barButtonItem = sender
        present(activity, animated: true, completion: nil)
    }
    
    
    //MARK: Setup Searchable Content for our app
    
    func setupSearchableContent() {
        var searchableItems = [CSSearchableItem]()
        
        let toBuyItems: [ToBuy] = dataProvider.fetchedResultsController.fetchedObjects ?? []
        
        print(toBuyItems)
        
        for (_, toBuyItem) in toBuyItems.enumerated() {
            let searchableItemAttributeSet = CSSearchableItemAttributeSet.init()
            searchableItemAttributeSet.title = "\(toBuyItem.name!) · \(toBuyItem.supermarket!)"
            searchableItemAttributeSet.thumbnailData = toBuyItem.image
            searchableItemAttributeSet.contentType = kUTTypeText as String
            
            var kws = [String]()
            
            kws.append(toBuyItem.name!)
            kws.append(toBuyItem.supermarket!)
            
            searchableItemAttributeSet.keywords = kws

            let uniq = "\(Bundle.main.bundleIdentifier!).\(toBuyItem.name!)"
            let searchableItem = CSSearchableItem.init(uniqueIdentifier: uniq, domainIdentifier: "To Buy", attributeSet: searchableItemAttributeSet)
            
            searchableItems.append(searchableItem)
        }
        
        CSSearchableIndex.default().indexSearchableItems(searchableItems) { (error) in
            if error != nil {
                print(error?.localizedDescription ?? "Spotlight search API error")
            }
        }
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
        
        // spotlight indexing
        setupSearchableContent()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        headerViewContainer.addGestureRecognizer(tap)

        tableView.register(UINib(nibName: "ToBuyTableViewCell", bundle: nil), forCellReuseIdentifier: reuseIdentifier)
    }

    @IBAction func addNewItem(_ sender: UIBarButtonItem) {
        let viewController = self.storyboard?.instantiateViewController(identifier: "CanBuyCollectionView")
            as? ShoppingCollectionViewController
        
        viewController?.modalPresentationStyle = .popover
        self.present(viewController!, animated: true)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        let viewController = self.storyboard?.instantiateViewController(identifier: "HistoryTableViewController")
            as? HistoryTableViewController
        self.navigationController?.pushViewController(viewController!, animated: true)
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
        
        dataProvider.fetchedResultsController.fetchRequest.predicate = predicate
        
        do {
            try dataProvider.fetchedResultsController.performFetch()
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } catch let err {
            print(err)
        }
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let item = dataProvider.fetchedResultsController.object(at: indexPath)
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
            self.dataProvider.markAsCompleted(at: indexPath)
            completion(true)
        }
        action.image = UIImage(systemName: "checkmark")
        action.backgroundColor = .systemGreen
        return action
    }
    
    func laterAction(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: NSLocalizedString("action.delay.title", comment: "action.delay.title")) { (_, view, completion) in
            self.dataProvider.markAsDelayed(at: indexPath)
            completion(true)
        }
        action.image = UIImage(systemName: "clock")
        action.backgroundColor = .systemOrange
        return action
    }
    
    func pushItemIntoHistory(item: ToBuy) {
        return historyManager.pushIntoToBuyHistory(item: item)
    }
    
    func deleteAction(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: NSLocalizedString("action.delete.title", comment: "action.delete.title")) { (_, view, completion) in
            let item = self.dataProvider.fetchedResultsController.object(at: indexPath)
            self.pushItemIntoHistory(item: item)
            self.dataProvider.deleteToBuyItem(at: indexPath)
            completion(true)
        }
        action.image = UIImage(systemName: "delete.right")
        action.backgroundColor = .systemRed
        return action
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        var count = 0
        if let sections = dataProvider.fetchedResultsController.sections {
            count = sections.count
        }
        
        if(count == 0) {
            self.tableView.emptyState(label: NSLocalizedString("to.buy.empty.hint.message", comment: "to.buy.empty.hint.message"), image: "icons8-basket")
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
    
    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let item = dataProvider.fetchedResultsController.object(at: indexPath)
        
        return UIContextMenuConfiguration(identifier: item.name as NSCopying?, previewProvider: {
            let view = ItemPreviewViewController(itemName: item.name!, image: item.image!)
            return view
        }){ _ in
            let liftPriorityAction = UIAction(
                title: NSLocalizedString("action.priority.title", comment: "action.priority.title"),
                image: UIImage(systemName: "chevron.up.circle")) { _ in
                    self.dataProvider.markAsImportant(at: indexPath)
            }
            
            let downgradeAction = UIAction(
                title: NSLocalizedString("action.downgrade.title", comment: "action.downgrade.title"),
                image: UIImage(systemName: "chevron.down.circle")) { _ in
                    self.dataProvider.markAsNormal(at: indexPath)
            }
            
            let delayAction = UIAction(
                title: NSLocalizedString("action.delay.title", comment: "action.delay.title"),
                image: UIImage(systemName: "clock")) { _ in
                    self.dataProvider.markAsDelayed(at: indexPath)
            }
            
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
                    self.pushItemIntoHistory(item: item)
                    self.dataProvider.deleteToBuyItem(at: indexPath)
            }
            
            if(item.isCompleted) {
                return UIMenu(title: "", children: [deleteAction])
            } else {
                return UIMenu(title: "", children: [
                                item.priority > 0 ? downgradeAction : liftPriorityAction,
                                delayAction,
                                completeAction,
                                deleteAction])
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
        return sectionName
    }
    
    // 2
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
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

