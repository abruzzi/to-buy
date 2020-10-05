//
//  ShoppingCollectionViewController.swift
//  GoShopping
//
//  Created by Juntao Qiu on 31/8/20.
//  Copyright © 2020 Juntao Qiu. All rights reserved.
//

import UIKit
import CoreData

private let reuseIdentifier = "ItemCell"

extension ShoppingCollectionViewController {
    func emptyState () {
        let emptyView = UIView(frame: self.collectionView.frame)
        emptyView.backgroundColor = UIColor(named: "BGColor")
        
        let label = UILabel()
        label.textColor = UIColor(named: "FontColor")
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = searchText
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: 13.0)
        label.textAlignment = .center
        
        let hint = UILabel()
        hint.textColor = UIColor(named: "FontColor")
        hint.translatesAutoresizingMaskIntoConstraints = false
        hint.text = NSLocalizedString("message.hint.add.new", comment: "message.hint.add.new")
        hint.font = UIFont.boldSystemFont(ofSize: 14.0)
        hint.textAlignment = .center
        
        let width = self.calculateWidth()
        let imageView = UIImageView(frame: .zero)
        imageView.frame = CGRect(x: 0, y: 0, width: width, height: width)
        
        imageView.layer.cornerRadius = 4
        imageView.layer.borderWidth = 2
        imageView.layer.backgroundColor = UIColor(named: "BrandColor")?.cgColor
        imageView.layer.borderColor = UIColor(named: "BrandColor")?.cgColor
        imageView.layer.opacity = 0.2
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.image = UIImage(named: "icons8-ingredients")
        
        emptyView.addSubview(imageView)
        emptyView.addSubview(label)
        emptyView.addSubview(hint)
        
        imageView.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
        
        imageView.topAnchor.constraint(equalTo: emptyView.topAnchor, constant: 174).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: width).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: width).isActive = true
        
        label.centerXAnchor.constraint(equalTo: imageView.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).isActive = true
        label.widthAnchor.constraint(equalToConstant: width - 16).isActive = true
        
        hint.centerXAnchor.constraint(equalTo: imageView.centerXAnchor).isActive = true
        hint.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8).isActive = true
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(editNewItem))
        emptyView.addGestureRecognizer(singleTap)
        
        self.collectionView.backgroundView = emptyView
    }
    
    //Action
    @objc func editNewItem() {
        self.dataProvider.addCanBuy(name: self.searchText, image: (UIImage(named: "icons8-crystal_ball")?.pngData())!, shouldSave: false) { canBuyItem in
            let viewController = self.storyboard?.instantiateViewController(identifier: "EditingTableViewController")
                as? EditingTableViewController
            viewController!.item = canBuyItem
            
            self.navigationController?.pushViewController(viewController!, animated: true)
        }
    }
    
    func restore () {
        self.collectionView.backgroundView = nil
    }
}

class ShoppingCollectionViewController: UICollectionViewController {
    let store = CoreDataStack.store
    
    let searchController = UISearchController(searchResultsController: nil)
    lazy var toBuyManager: ToBuyManager = {
        return ToBuyManager(store.viewContext)
    }()
    
    let categoryTitles = [
        NSLocalizedString("category.food.title", comment: "category.food.title"),
        NSLocalizedString("category.essentials.title", comment: "category.essentials.title"),
        NSLocalizedString("category.health.title", comment: "category.health.title"),
        NSLocalizedString("category.others.title", comment: "category.others.title")
    ]
    
    private lazy var dataProvider: CanBuysProvider = {
        let provider = CanBuysProvider(with: store.viewContext,
                                       fetchedResultsControllerDelegate: self)
        return provider
    }()
    
    func setupSearchBar () {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder =  NSLocalizedString("searchbar.placeholder", comment: "searchbar.placeholder")
        searchController.searchBar.delegate = self
        searchController.delegate = self
        navigationItem.searchController = searchController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupSearchBar()
        
        definesPresentationContext = true
        collectionView.allowsMultipleSelection = true
        collectionView.keyboardDismissMode = .onDrag
        collectionView.automaticallyAdjustsScrollIndicatorInsets = false
        
        collectionView.register(UINib(nibName: "ItemCellView", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        
        self.setupGrid()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.refreshView()
    }
    
    func refreshView () {
        self.collectionView.reloadData()
        self.updateSelections()
        self.updateBadge()
    }
    
    func updateSelections() {
        let allToBuys: [ToBuyItem] = toBuyManager.fetchAllToBuyItems()
        
        let sections = dataProvider.fetchedResultsController.sections?.count ?? 0
        
        for section in 0..<sections {
            let itemsInSection = dataProvider.fetchedResultsController.sections?[section].numberOfObjects ?? 0
            for index in 0..<itemsInSection {
                let indexPath = IndexPath(row: index, section: section)
                let item = dataProvider.fetchedResultsController.object(at: indexPath)
                
                let exist = allToBuys.contains { (toBuy: ToBuyItem) in
                    return toBuy.name == item.name && (!toBuy.isCompleted || toBuy.isDelayed)
                }
                
                if(exist) {
                    self.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
                } else {
                    self.collectionView.deselectItem(at: indexPath, animated: false)
                }
            }
        }
    }
    
    func setupGrid() {
        let flow = collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        
        flow.minimumInteritemSpacing = CGFloat(cellMargin)
        flow.minimumLineSpacing = CGFloat(cellMargin)
    }
    
    var searchText: String = ""
    
    func filterContentForSearchText(_ searchText: String) {
        self.searchText = searchText
        
        let predicate = NSPredicate(format: "name CONTAINS[c] %@", searchText)
        
        dataProvider.fetchedResultsController.fetchRequest.predicate = searchText.isEmpty ? nil : predicate
        
        do {
            try dataProvider.fetchedResultsController.performFetch()
        } catch let err {
            print(err)
        }
        
        collectionView.reloadData()
    }
    
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        let count = dataProvider.fetchedResultsController.sections?.count ?? 0
        
        if(count == 0) {
            self.emptyState()
        } else {
            self.restore()
        }
        
        return count
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = dataProvider.fetchedResultsController.sections?[section].numberOfObjects {
            return count
        }
        
        return 0;
    }    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = UICollectionViewCell()
        let data = dataProvider.fetchedResultsController.object(at: indexPath)
        
        if let itemCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? ItemCellView {
            itemCell.configure(with: data.name!, image: UIImage(data: data.image!)!)
            cell = itemCell
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let data = dataProvider.fetchedResultsController.object(at: indexPath)
        
        if(data.createdAt == nil) {
            let viewController = self.storyboard?.instantiateViewController(identifier: "EditingTableViewController")
                as? EditingTableViewController
            viewController!.item = data
            self.navigationController?.pushViewController(viewController!, animated: true)
        } else {
            if(!toBuyManager.isAlreadyExistInToBuyList(name: data.name!)) {
                toBuyManager.initToBuyItem(name: data.name!, category: Int(data.category), image: data.image!, supermarket: data.supermarket!)
            }
        }
        updateBadge()
    }
    
    private func updateBadge() {
        let tabbar = self.tabBarController as? BaseTabBarController
        tabbar?.updateBadge()
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let data = dataProvider.fetchedResultsController.object(at: indexPath)
        if(toBuyManager.isAlreadyExistInToBuyList(name: data.name!)) {
            toBuyManager.deleteItemByNameFromToBuys(name: data.name!)
        }
        updateBadge()
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionHeader", for: indexPath) as! SectionHeader
        let data = dataProvider.fetchedResultsController.object(at: indexPath)
        
        let count = dataProvider.fetchedResultsController.sections?[indexPath.section].numberOfObjects ?? 0
        if(count > 0) {
            let title = categoryTitles[Int(data.category)]
            sectionHeader.configure(with: title)
        } else {
            let title = categoryTitles[3]
            sectionHeader.configure(with: title)
        }
        
        return sectionHeader
    }
    
    override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let data = dataProvider.fetchedResultsController.object(at: indexPath)
        
        return UIContextMenuConfiguration(identifier: data.name! as NSString, previewProvider: {
            let view = ItemPreviewViewController(itemName: data.name!, image: data.image!)
            return view
        }) { _ in
            let editAction = UIAction(
                title: NSLocalizedString("action.editCanBuyItem.title", comment: "action.editCanBuyItem.title"),
                image: UIImage(systemName: "square.and.pencil")) { _ in
                let viewController = self.storyboard?.instantiateViewController(identifier: "EditingTableViewController")
                    as? EditingTableViewController
                viewController!.item = data

                self.navigationController?.pushViewController(viewController!, animated: true)
            }
            
            let deleteAction = UIAction(
                title: NSLocalizedString("action.deleteFromToBuyList.title", comment: "action.deleteFromToBuyList.title"),
                image: UIImage(systemName: "trash"),
                attributes: .destructive) { _ in
                self.dataProvider.deleteCanBuy(at: indexPath)
            }
            
            return UIMenu(title: "", children: [editAction, deleteAction])
        }
    }
    
    var estimateWidth = 80.0
    var cellMargin = 10.0
    
    private let sectionInsets = UIEdgeInsets(top: 20.0,
                                             left: 16.0,
                                             bottom: 20.0,
                                             right: 16.0)
}

extension ShoppingCollectionViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        filterContentForSearchText(searchBar.text!)
    }
}

extension ShoppingCollectionViewController: UISearchControllerDelegate {
    func didDismissSearchController(_ searchController: UISearchController) {
        self.refreshView()
    }
}

extension ShoppingCollectionViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        dataProvider.fetchedResultsController.fetchRequest.predicate = nil
        
        do {
            try dataProvider.fetchedResultsController.performFetch()
        } catch let err {
            print(err)
        }
    }
}

extension ShoppingCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    //1
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let widthPerItem = calculateWidth()
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    //3
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    // 4
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    
    func estimatedCellsPerRow() -> Int {
        let estimatedWidth = CGFloat(estimateWidth)
        let cellCount = floor(CGFloat(self.view.frame.width / estimatedWidth))
        
        return Int(cellCount)
    }
    
    func calculateWidth() -> CGFloat {
        var itemsPerRow: Int
        
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            itemsPerRow = 5
        case .pad:
            itemsPerRow = 10
        default:
            itemsPerRow = 5
        }
        
        let paddingSpace = (sectionInsets.left) * CGFloat(itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / CGFloat(itemsPerRow)
        return widthPerItem
    }
}

extension ShoppingCollectionViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.refreshView()
    }
}
