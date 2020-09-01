//
//  ShoppingCollectionViewController.swift
//  GoShopping
//
//  Created by Juntao Qiu on 31/8/20.
//  Copyright © 2020 Juntao Qiu. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class ShoppingCollectionViewController: UICollectionViewController {
    private var filteredRecords: [Record]!
    
    struct Config {
        static let defaultPadding: CGFloat = 2.0
        static let numberOfItemsPerRow: CGFloat = 3.0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Apple..."
        navigationItem.searchController = searchController
        
        definesPresentationContext = true
    
        let viewWidth = collectionView.frame.width
        print(viewWidth)
        let itemWidth = (viewWidth - Config.defaultPadding) / Config.numberOfItemsPerRow
        print(itemWidth)
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        
        filteredRecords = records
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
        
        if let itemCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? ItemCell {
            let data = filteredRecords[indexPath.section].items[indexPath.row]
            itemCell.configure(with: data.name, image: data.image)
            cell = itemCell
        }
    
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let itemCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? ItemCell
        
        itemCell?.backgroundColor = .green
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionHeader", for: indexPath) as! SectionHeader
        
        let obj = filteredRecords[indexPath.section]
        sectionHeader.configure(with: obj.category, categoryIcon: obj.image) 
        
        return sectionHeader
    }
    
}

extension ShoppingCollectionViewController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
    let searchBar = searchController.searchBar
    filterContentForSearchText(searchBar.text!)
  }
}
