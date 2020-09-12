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

class ShoppingCollectionViewController: UICollectionViewController {
    let searchController = UISearchController(searchResultsController: nil)
    
    let categoryTitles = [
        NSLocalizedString("category.food.title", comment: "category.food.title"),
        NSLocalizedString("category.essentials.title", comment: "category.essentials.title"),
        NSLocalizedString("category.health.title", comment: "category.health.title"),
        NSLocalizedString("category.others.title", comment: "category.others.title")
    ]
    
    
    private lazy var dataProvider: CanBuysProvider = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let provider = CanBuysProvider(with: appDelegate.persistentContainer,
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
        let allToBuys: [ToBuyItem] = fetchAllToBuyItems()
        
        let sections = dataProvider.fetchedResultsController.sections?.count ?? 1
        for section in 0...sections - 1 {
            let itemsInSection = dataProvider.fetchedResultsController.sections?[section].numberOfObjects ?? 1
            for index in 0...itemsInSection-1 {
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
    
    func filterContentForSearchText(_ searchText: String) {
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
        return dataProvider.fetchedResultsController.sections?.count ?? 0
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
            itemCell.configure(with: data.name!, image: data.image!)
            cell = itemCell
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let data = dataProvider.fetchedResultsController.object(at: indexPath)

        if(isNewItemInApp(name: data.name!)) {
            let viewController = self.storyboard?.instantiateViewController(identifier: "EditingTableViewController")
                as? EditingTableViewController
            viewController!.item = data
            self.navigationController?.pushViewController(viewController!, animated: true)
        } else {
            if(!isAlreadyExistInToBuyList(name: data.name!)) {
                saveToBuyItem(name: data.name!, category: Int(data.category), image: data.image!, supermarket: data.supermarket!)
            }
        }
        updateBadge()
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let data = dataProvider.fetchedResultsController.object(at: indexPath)
        if(isAlreadyExistInToBuyList(name: data.name!)) {
            deleteItemByNameFromToBuys(name: data.name!)
        }
        updateBadge()
    }

    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionHeader", for: indexPath) as! SectionHeader
        let data = dataProvider.fetchedResultsController.object(at: indexPath)
        
        let count = dataProvider.fetchedResultsController.sections?[indexPath.section].numberOfObjects ?? 0
        if(count > 0) {
            let title = categoryTitles[Int(data.category)]
            sectionHeader.configure(with: title, image: UIImage(named: data.image!)!)
        } else {
            let title = categoryTitles[3]
            sectionHeader.configure(with: title, image: UIImage(named: "icons8-autism")!)
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
                image: UIImage(systemName: "pencil")) { _ in
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
    var cellMargin = 8.0
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
        
        collectionView.reloadData()
    }
}

extension ShoppingCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.calculateWidth()
        return CGSize(width: width, height: width)
    }
    
    func calculateWidth() -> CGFloat {
        let estimatedWidth = CGFloat(estimateWidth)
        let cellCount = floor(CGFloat(self.view.frame.width / estimatedWidth))
        
        let margin = CGFloat(cellMargin * 2)
        let width = (self.view.frame.width - CGFloat(cellMargin) * (cellCount - 1) - margin) / cellCount
        
        return width
    }
}

extension UIViewController {
    func updateBadge() {
        let allItems = fetchAllToBuyItems()
        let toBuyItems = allItems.filter { !$0.isCompleted && !$0.isDelayed }
        let delayedItems = allItems.filter { $0.isDelayed }
        
        if let items = self.tabBarController?.tabBar.items as NSArray? {
            let toBuyTab = items.object(at: 1) as! UITabBarItem
            let delayedTab = items.object(at: 2) as! UITabBarItem
            toBuyTab.badgeValue = toBuyItems.count == 0 ? nil : String(toBuyItems.count)
            delayedTab.badgeValue = delayedItems.count == 0 ? nil : String(delayedItems.count)
        }
    }
}

extension ShoppingCollectionViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.refreshView()
    }
}
