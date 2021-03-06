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
        let placeholder = UIImage(named: "square")
        
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
    var alertActionToEnable: UIAlertAction!
    
    private lazy var historyManager: HistoryManager = {
        return HistoryManager(store.viewContext)
    }()
    
    private lazy var toBuyManager: ToBuyManager = {
        return ToBuyManager(store.viewContext)
    }()
    
    private let countLabel: UILabel = {
        let countLabel = UILabel(frame: CGRect.zero)
        countLabel.text = ""
        countLabel.textColor = UIColor(named: "FontColor")
        countLabel.font = UIFont.systemFont(ofSize: 13.0)
        countLabel.textAlignment = .center
        
        return countLabel
    }()
    
    private lazy var dataProvider: ToBuysProvider = {
        let provider = ToBuysProvider(with: store.viewContext,
                                      fetchedResultsControllerDelegate: self)
        return provider
    }()
    
    private func updateToBuyItemCount() {
        let title = NSLocalizedString("tobuy.nav.title", comment: "tobuy.nav.title")
        let itemNumber = dataProvider.fetchedResultsController.fetchedObjects?.count ?? 0
        
        countLabel.text = "\(itemNumber) \(title)"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setToolbarHidden(false, animated: false)
        historyManager.fetchToBuyHistory()
//        filterContentForSearchText("", category: "All")
        self.updateToBuyItemCount()
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
    
    let categories = [
        NSLocalizedString("tobuy.search.category.all", comment: "tobuy.search.category.all"),
        NSLocalizedString("tobuy.search.category.remaining", comment: "tobuy.search.category.remaining"),
        NSLocalizedString("tobuy.search.category.shared", comment: "tobuy.search.category.shared"),
    ]
    
    func setupHistorySection() {
        headerViewContainer.layer.cornerRadius = 4
        historyCountLabel.layer.cornerRadius = 4
        historyCountLabel.layer.masksToBounds = true
        
        firstImageSnapshot.layer.cornerRadius = 4.0
        secondImageSnapshot.layer.cornerRadius = 4.0
        thirdImageSnapshot.layer.cornerRadius = 4.0
        forthImageSnapshot.layer.cornerRadius = 4.0
        
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        
        //TODO: i18n
        searchController.searchBar.placeholder = NSLocalizedString("tobuy.search.placeholder", comment: "tobuy.search.placeholder")
        
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        searchController.searchBar.scopeButtonTitles = categories
        searchController.searchBar.delegate = self
        
        setupHistorySection()
        
        historyManager.historyDelegate = self
        
        // spotlight indexing
        setupSearchableContent()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        headerViewContainer.addGestureRecognizer(tap)

        tableView.register(UINib(nibName: "ToBuyTableViewCell", bundle: nil), forCellReuseIdentifier: reuseIdentifier)
        
        NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: nil, using: reload)
        
        initToolbar()
    }
    
    func initToolbar() {
        let labelItem = UIBarButtonItem.init(customView: countLabel)

        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target:nil, action:nil)
        
        let addFromCarema = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(selectImage))
        addFromCarema.tintColor = UIColor(named: "BrandColor")
        

        let addFromText = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(createItemFromText))
        addFromText.tintColor = UIColor(named: "BrandColor")
        
        toolbarItems = [addFromCarema, spacer, labelItem, spacer, addFromText]
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    func reload(nofitication: Notification) {
        filterContentForSearchText("", category:         NSLocalizedString("tobuy.search.category.all", comment: "tobuy.search.category.all"))
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
        let isForeignPredicate = NSPredicate(format: "isForeign = true")
        let isCompletedPredicate = NSPredicate(format: "isCompleted = false")
        
        var predicate:NSPredicate
        
        switch category {
        case NSLocalizedString("tobuy.search.category.all", comment: "tobuy.search.category.all"):
            predicate = NSCompoundPredicate(andPredicateWithSubpredicates: searchText.isEmpty ? [] : [keywords, ])
        case NSLocalizedString("tobuy.search.category.remaining", comment: "tobuy.search.category.remaining"):
            predicate = NSCompoundPredicate(andPredicateWithSubpredicates: searchText.isEmpty ? [isCompletedPredicate] : [keywords, isCompletedPredicate])
        case NSLocalizedString("tobuy.search.category.shared", comment: "tobuy.search.category.shared"):
            predicate = NSCompoundPredicate(andPredicateWithSubpredicates: searchText.isEmpty ? [isForeignPredicate] : [keywords, isForeignPredicate])
        default:
            predicate = NSCompoundPredicate(andPredicateWithSubpredicates: searchText.isEmpty ? [] : [keywords])
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
        
        guard let name = item.name, !name.isEmpty else {
            return nil
        }
        
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
            
            guard let name = item.name, !name.isEmpty else {
                return completion(false)
            }
            
            self.pushItemIntoHistory(item: item)
            self.dataProvider.deleteToBuyItem(at: indexPath)
            completion(true)
        }
        action.image = UIImage(systemName: "trash")
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
        
        guard let name = item.name, !name.isEmpty else { return nil }
        
        return UIContextMenuConfiguration(identifier: item.name as NSCopying?, previewProvider: {
            let view = ItemPreviewViewController(itemName: item.name!, image: item.image!)
            return view
        }){ _ in
            let editAction = UIAction(
                title: NSLocalizedString("action.editCanBuyItem.title", comment: "action.editCanBuyItem.title"),
                image: UIImage(systemName: "square.and.pencil")) { _ in
                let viewController = self.storyboard?.instantiateViewController(identifier: "ToBuyItemTableViewController")
                    as? ToBuyItemTableViewController
                
                if #available(iOS 14, *) {
                    let count = self.dataProvider.fetchedResultsController.fetchedObjects?.count ?? 0
                    viewController!.enableUpdateSupermarket = count > 1
                }
                
                viewController!.item = item

                self.navigationController?.pushViewController(viewController!, animated: true)
            }
            
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
                image: UIImage(systemName: "trash"),
                attributes: .destructive) { _ in
                    let item = self.dataProvider.fetchedResultsController.object(at: indexPath)
                    self.pushItemIntoHistory(item: item)
                    self.dataProvider.deleteToBuyItem(at: indexPath)
            }
            
            if(item.isCompleted) {
                return UIMenu(title: "", children: [deleteAction])
            } else {
                return UIMenu(title: "", children: [
                                editAction,
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
        
        let indexSet = IndexSet(integer: sectionIndex)

        switch type {
        case .insert:
            tableView.insertSections(indexSet, with: .automatic)
        case .delete:
            tableView.deleteSections(indexSet, with: .automatic)
        case .update:
            tableView.reloadSections(indexSet, with: .automatic)
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
            guard let indexPath = indexPath, let newIndexPath = newIndexPath else {
                return
            }
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        @unknown default:
            fatalError("unknown \(type)")
        }
    }
    
    // 5
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
        self.updateToBuyItemCount()
    }
}

extension ToBuyTableViewController {
    @objc func createItemFromText(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title:
                                        NSLocalizedString("alert.add.new.text.title", comment: "alert.add.new.text.title"),
                                      message: NSLocalizedString("alert.add.new.text.message", comment: "alert.add.new.text.message"), preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = NSLocalizedString("alert.add.new.text.field.name", comment: "alert.add.new.text.field.name")
            textField.addTarget(self, action: #selector(type(of: self).textChanged(_:)), for: .editingChanged)
        }
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("alert.add.new.text.action.cancel", comment: "alert.add.new.text.action.cancel"), style: .cancel, handler: nil))
        addActionSheetForiPad(actionSheet: alert)
        present(alert, animated: true, completion: nil)
        
        alertActionToEnable = UIAlertAction(title: NSLocalizedString("alert.add.new.text.action.create", comment: "alert.add.new.text.action.create"), style: .default) {_ in
            guard let name = alert.textFields?.first?.text, !name.isEmpty else { return }
            self.dataProvider.addToBuyByName(name: name)
        }
        
        alertActionToEnable.isEnabled = false
        alert.addAction(alertActionToEnable!)
    }
    
    @objc
    func textChanged(_ sender: UITextField) {
        guard let tagName = sender.text else {
            alertActionToEnable.isEnabled = false
            return
        }
        
        alertActionToEnable.isEnabled = (tagName.count > 0)
    }
}

extension ToBuyTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    //Action
    @objc func selectImage() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        let actionSheet = UIAlertController(title: NSLocalizedString( "dialog.image.picker.title", comment:  "dialog.image.picker.title"),
                                            message: NSLocalizedString( "dialog.image.picker.subtitle", comment:  "dialog.image.picker.subtitle"), preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: NSLocalizedString( "dialog.image.picker.photo", comment:  "dialog.image.picker.photo"), style: .default, handler: { (action: UIAlertAction) in
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: NSLocalizedString( "dialog.image.picker.carema", comment:  "dialog.image.picker.carema"), style: .default, handler: { (action: UIAlertAction) in
            
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                imagePicker.sourceType = .camera
                imagePicker.allowsEditing = true
                self.present(imagePicker, animated: true, completion: nil)
            }
            
        }))
        
        actionSheet.addAction(UIAlertAction(title: NSLocalizedString( "dialog.image.picker.cancel", comment:  "dialog.image.picker.cancel"), style: .cancel, handler: nil))
        
        addActionSheetForiPad(actionSheet: actionSheet)
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        
        self.dataProvider.addToBuyByImage(image: image?.pngData())

        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

