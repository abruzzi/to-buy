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
    private var toBuyItems: [ToBuyItem]!
    private var canBuyItems: [Record]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        canBuyItems = appDelegate.records
//        var canBuyItems: [CanBuyItem] = []
//        filteredRecords.forEach {record in
//            record.items.forEach { item in
//                canBuyItems.append(CanBuyItem(name: item.name, category: record.category, image: item.image, supermarket: ((item.attrs["supermarket"] != nil) ? item.attrs["supermarket"]: "")!))
//            }
//        }
//        print(canBuyItems)
//        saveAllCanBuyItem(canBuyItems: canBuyItems)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "冰淇淋🍦..."
        navigationItem.searchController = searchController
        
        definesPresentationContext = true
        
        collectionView.register(UINib(nibName: "ItemCellView", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        self.setupGrid()
        
        collectionView.allowsMultipleSelection = true
        collectionView.keyboardDismissMode = .onDrag
    }
    
    
    func deleteAllData(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let DelAllReqVar = NSBatchDeleteRequest(fetchRequest: NSFetchRequest<NSFetchRequestResult>(entityName: "ToBuys"))
        do {
            try managedContext.execute(DelAllReqVar)
        }
        catch {
            print(error)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.refreshToBuyList()
        self.updateBadge()
        //        self.deleteAllData()
    }
    
    func refreshToBuyList() {
        let allItems = fetchAllToBuyList()
        toBuyItems = allItems.filter { !$0.isCompleted && !$0.isDelayed }
    }
    
    func setupGrid() {
        let flow = collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        
        flow.minimumInteritemSpacing = CGFloat(cellMargin)
        flow.minimumLineSpacing = CGFloat(cellMargin)
    }
    
    func filterContentForSearchText(_ searchText: String) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        if(searchText.isEmpty) {
            canBuyItems = appDelegate.records
        } else {
            canBuyItems = appDelegate.records.map { (record: Record) in
                var r = record
                let items = record.items.filter { (record: Item) -> Bool in
                    return record.name.lowercased().contains(searchText.lowercased())
                }
                r.items = items
                return r
            }
            
            canBuyItems = canBuyItems.filter { (record: Record) in
                record.items.count > 0
            }
        }
        collectionView.reloadData()
    }
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return canBuyItems.count
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return canBuyItems[section].items.count
    }    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = UICollectionViewCell()
        let data = canBuyItems[indexPath.section].items[indexPath.row]
        
        if let itemCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? ItemCellView {
            itemCell.configure(with: data.name, image: data.image)
            cell = itemCell
        }
        
        //        cell.isSelected = isAlreadyExist(name: data.name)
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let data = canBuyItems[indexPath.section].items[indexPath.row]
        let category = canBuyItems[indexPath.section].category
        if(!isAlreadyExist(name: data.name)) {
            save(name: data.name, category: category)
        }
        updateBadge()
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let data = canBuyItems[indexPath.section].items[indexPath.row]
        if(isAlreadyExist(name: data.name)) {
            deleteItemByName(name: data.name)
        }
        updateBadge()
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionHeader", for: indexPath) as! SectionHeader
        
        let obj = canBuyItems[indexPath.section]
        sectionHeader.configure(with: obj.category, image: UIImage(named: obj.image)!)
        
        return sectionHeader
    }
    
    override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let category = canBuyItems[indexPath.section].category
        let data = canBuyItems[indexPath.section].items[indexPath.row]
        return UIContextMenuConfiguration(identifier: data.name as NSString, previewProvider: nil) { _ in
            
            let addAction = UIAction(
                title: "Add to list",
                image: UIImage(systemName: "plus")) { _ in
                    save(name: data.name, category: category)
                    self.updateBadge()
            }
            
            let editAction = UIAction(
                title: "Edit",
                image: UIImage(systemName: "pencil")) { _ in
                    let viewController = self.storyboard?.instantiateViewController(identifier: "EditingTableViewController")
                        as? EditingTableViewController
                    viewController!.item = data
                    viewController!.category = category
                    self.navigationController?.pushViewController(viewController!, animated: true)
            }
            
            let deleteAction = UIAction(
                title: "Delete",
                image: UIImage(systemName: "trash"),
                attributes: .destructive) { _ in
                    deleteItemByName(name: data.name)
                    self.updateBadge()
            }
            
            
            
            return UIMenu(title: "", children: [addAction, editAction, deleteAction])
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

extension ShoppingCollectionViewController {
    func updateBadge() {
        let allItems = fetchAllToBuyList()
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
