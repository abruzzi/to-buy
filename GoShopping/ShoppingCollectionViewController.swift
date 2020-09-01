//
//  ShoppingCollectionViewController.swift
//  GoShopping
//
//  Created by Juntao Qiu on 31/8/20.
//  Copyright © 2020 Juntao Qiu. All rights reserved.
//

import UIKit

private let reuseIdentifier = "ItemCell"

class ShoppingCollectionViewController: UICollectionViewController {
    private var filteredRecords: [Record]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        filteredRecords = records

        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "豆腐..."
        navigationItem.searchController = searchController

        definesPresentationContext = true

        collectionView.register(UINib(nibName: "ItemCellView", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        self.setupGrid()
        
        collectionView.allowsMultipleSelection = true
    }

    func setupGrid() {
        let flow = collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        
        flow.minimumInteritemSpacing = CGFloat(cellMargin)
        flow.minimumLineSpacing = CGFloat(cellMargin)
    }

    func filterContentForSearchText(_ searchText: String) {
        if(searchText.isEmpty) {
            filteredRecords = records
        } else {
            filteredRecords = records.map { (record: Record) in
                var r = record
                let items = record.items.filter { (record: Item) -> Bool in
                    return record.name.lowercased().contains(searchText.lowercased())
                }
                r.items = items
                return r
            }

            filteredRecords = filteredRecords.filter { (record: Record) in
                record.items.count > 0
            }
        }
      collectionView.reloadData()
    }
    
    let searchController = UISearchController(searchResultsController: nil)

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return filteredRecords.count
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredRecords[section].items.count
    }    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = UICollectionViewCell()
        
        if let itemCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? ItemCellView {
            let data = filteredRecords[indexPath.section].items[indexPath.row]
            itemCell.configure(with: data.name)
            cell = itemCell
        }
    
        return cell
    }

    var selected:Dictionary<Int, Item> = [:]
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let data = filteredRecords[indexPath.section].items[indexPath.row]
        print("selected: \(data.name)")
        selected[data.id] = data
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let data = filteredRecords[indexPath.section].items[indexPath.row]
        print("de-selected: \(data.name)")
        selected.removeValue(forKey: data.id)
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionHeader", for: indexPath) as! SectionHeader
        
        let obj = filteredRecords[indexPath.section]
        sectionHeader.configure(with: obj.category, categoryIcon: obj.image) 
        
        return sectionHeader
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
