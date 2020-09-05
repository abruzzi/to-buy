//
//  ShoppingCollectionViewController.swift
//  GoShopping
//
//  Created by Juntao Qiu on 31/8/20.
//  Copyright © 2020 Juntao Qiu. All rights reserved.
//

import UIKit
import SwiftUI
import CoreData

private let reuseIdentifier = "ItemCell"

class ShoppingCollectionViewController: UICollectionViewController {
    private var toBuyItems: [ToBuyItem]!
    private var filteredRecords: [Record]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        filteredRecords = tabBarController. .records

        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "豆腐..."
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
//        self.deleteAllData()
    }
    
    func refreshToBuyList() {
        var toBuyList: [NSManagedObject] = []
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
          return
        }

        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ToBuys")

        do {
          toBuyList = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
          print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        let allItems: [ToBuyItem] = toBuyList.map { (nsobj: NSManagedObject) in
            var item:ToBuyItem = ToBuyItem(name: nsobj.value(forKey: "name") as! String,
                             category: nsobj.value(forKey: "category") as! String,
                             isCompleted: (nsobj.value(forKey: "isCompleted") as! Bool),
                             isDelayed: (nsobj.value(forKey: "isDelayed") as! Bool))
            
            let record = fetcher.records.first { $0.category == item.category }
            let result = record!.items.first { $0.name == item.name }
            item.image = result?.image
            item.attrs = result?.attrs
            
            return item
        }
        toBuyItems = allItems.filter { !$0.isCompleted && !$0.isDelayed }
    }
    
    func setupGrid() {
        let flow = collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        
        flow.minimumInteritemSpacing = CGFloat(cellMargin)
        flow.minimumLineSpacing = CGFloat(cellMargin)
    }

    func filterContentForSearchText(_ searchText: String) {
        if(searchText.isEmpty) {
            filteredRecords = fetcher.records
        } else {
            filteredRecords = fetcher.records.map { (record: Record) in
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
            itemCell.configure(with: data.name, image: data.image)
            cell = itemCell
        }
    
        return cell
    }
    
    func delete(name: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
          return
        }

        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "ToBuys")
        fetchRequest.predicate = NSPredicate(format: "name = %@", name)
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            if(result.count > 0) {
                let obj = result[0] as! NSManagedObject
                managedContext.delete(obj)
                do {
                    try managedContext.save()
                } catch {
                    print(error)
                }
            }
        }catch let error as NSError {
          print("Could not delete value. \(error), \(error.userInfo)")
        }
    }

    func save(name: String, category: String) {
      guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
        return
      }

      let managedContext = appDelegate.persistentContainer.viewContext
      let entity = NSEntityDescription.entity(forEntityName: "ToBuys", in: managedContext)!
      let item = NSManagedObject(entity: entity, insertInto: managedContext)
        
        item.setValue(name, forKeyPath: "name")
        item.setValue(category, forKey: "category")
        item.setValue(Date(), forKeyPath: "createdAt")
        item.setValue(false, forKey: "isCompleted")
        item.setValue(false, forKey: "isDelayed")

      do {
        try managedContext.save()
      } catch let error as NSError {
        print("Could not save. \(error), \(error.userInfo)")
      }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let data = filteredRecords[indexPath.section].items[indexPath.row]
        let category = filteredRecords[indexPath.section].category
        self.save(name: data.name, category: category)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let data = filteredRecords[indexPath.section].items[indexPath.row]
        self.delete(name: data.name)
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionHeader", for: indexPath) as! SectionHeader
        
        let obj = filteredRecords[indexPath.section]
        sectionHeader.configure(with: obj.category, image: UIImage(named: obj.image)!)
        
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
