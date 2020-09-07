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
    private var canBuyItems: [[CanBuyItem]]!
    let categoryTitles = [
        NSLocalizedString("category.food.title", comment: "category.food.title"),
        NSLocalizedString("category.essentials.title", comment: "category.essentials.title"),
        NSLocalizedString("category.health.title", comment: "category.health.title"),
        NSLocalizedString("category.others.title", comment: "category.others.title")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        canBuyItems = allCanBuyList()
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder =  NSLocalizedString("searchbar.placeholder", comment: "searchbar.placeholder")
        navigationItem.searchController = searchController
        
        definesPresentationContext = true
        
        collectionView.register(UINib(nibName: "ItemCellView", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        self.setupGrid()
        
        collectionView.allowsMultipleSelection = true
        collectionView.keyboardDismissMode = .onDrag
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        
        leftSwipe.direction = .left
        rightSwipe.direction = .right
        
        self.view.addGestureRecognizer(leftSwipe)
        self.view.addGestureRecognizer(rightSwipe)
        
    }
    
    func allCanBuyList() -> [[CanBuyItem]]{
        let canBuyList = fetchAllCanBuyList()
        
        return [
            canBuyList.filter {$0.category == 0},
            canBuyList.filter {$0.category == 1},
            canBuyList.filter {$0.category == 2},
            canBuyList.filter {$0.category == 3}
        ]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        canBuyItems = allCanBuyList()
        self.updateBadge()
    }
    
    func setupGrid() {
        let flow = collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        
        flow.minimumInteritemSpacing = CGFloat(cellMargin)
        flow.minimumLineSpacing = CGFloat(cellMargin)
    }
    
    func filterContentForSearchText(_ searchText: String) {
        if(searchText.isEmpty) {
            canBuyItems = allCanBuyList()
        } else {
            canBuyItems = allCanBuyList().map { (array: [CanBuyItem]) in
                let items = array.filter { (item: CanBuyItem) -> Bool in
                    return item.name.lowercased().contains(searchText.lowercased())
                }
                return items
            }
            
            canBuyItems = canBuyItems.filter { (array: [CanBuyItem]) in
                array.count > 0
            }
            
            if(canBuyItems.count == 0) {
//                let categoryTitle = NSLocalizedString("category.unknown.section.header", comment: "category.unknown.section.header")
                canBuyItems = [[
                    CanBuyItem(name: searchText, category: 3, image: "icons8-autism", supermarket: "")
                    ]]
            }
        }
        collectionView.reloadData()
    }
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return canBuyItems.count
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return canBuyItems[section].count
    }    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = UICollectionViewCell()
        let data = canBuyItems[indexPath.section][indexPath.row]
        
        if let itemCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? ItemCellView {
            itemCell.configure(with: data.name, image: data.image)
            cell = itemCell
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let data = canBuyItems[indexPath.section][indexPath.row]
        
        if(isAlreadyExistInToBuyList(name: data.name)){
            self.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
        } else {
            self.collectionView.deselectItem(at: indexPath, animated: false)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let data = canBuyItems[indexPath.section][indexPath.row]
        
        if(isNewItemInApp(name: data.name)) {
            let viewController = self.storyboard?.instantiateViewController(identifier: "EditingTableViewController")
                as? EditingTableViewController
            viewController!.item = data
            self.navigationController?.pushViewController(viewController!, animated: true)
        } else {
            if(!isAlreadyExistInToBuyList(name: data.name)) {
                saveToBuyItem(name: data.name, category: data.category, image: data.image, supermarket: data.supermarket)
            }
        }
        updateBadge()
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let data = canBuyItems[indexPath.section][indexPath.row]
        if(isAlreadyExistInToBuyList(name: data.name)) {
            deleteItemByName(name: data.name)
        }
        updateBadge()
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionHeader", for: indexPath) as! SectionHeader
        
        let obj = canBuyItems[indexPath.section]
        
        if(obj.count > 0) {
            let title = categoryTitles[obj[0].category]
            sectionHeader.configure(with: title, image: UIImage(named: obj[0].image)!)
        } else {
//            let categoryTitle = NSLocalizedString("category.others.title", comment: "category.others.title")
            let title = categoryTitles[3]
            sectionHeader.configure(with: title, image: UIImage(named: "icons8-autism")!)
        }
        
        return sectionHeader
    }
    
    override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let data = canBuyItems[indexPath.section][indexPath.row]
        return UIContextMenuConfiguration(identifier: data.name as NSString, previewProvider: nil) { _ in
            let editAction = UIAction(
                title: NSLocalizedString("action.editCanBuyItem.title", comment: "action.editCanBuyItem.title"),
                image: UIImage(systemName: "pencil")) { _ in
                    let viewController = self.storyboard?.instantiateViewController(identifier: "EditingTableViewController")
                        as? EditingTableViewController
                    viewController!.item = data
                    self.navigationController?.pushViewController(viewController!, animated: true)
            }
            
            return UIMenu(title: "", children: [editAction])
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

extension UIViewController {
    @objc func handleSwipes(_ sender:UISwipeGestureRecognizer) {
        if sender.direction == .left {
            let current = self.tabBarController!.viewControllers![self.tabBarController!.selectedIndex]
            let next = self.tabBarController!.viewControllers![self.tabBarController!.selectedIndex+1]
            UIView.transition(from: current.view, to: next.view, duration: 0.3, options: UIView.AnimationOptions.transitionCrossDissolve) { (finished: Bool) in
                self.tabBarController!.selectedIndex += 1
            }
        }
        if sender.direction == .right {
            self.tabBarController!.selectedIndex -= 1
        }
    }
}
