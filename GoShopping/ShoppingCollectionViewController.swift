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
//    let data = ["milk", "break", "tuna", "apple", "pear", "banana", "milk", "break", "tuna", "apple", "pear", "banana", "milk", "break", "tuna", "apple", "pear", "banana","milk", "break", "tuna", "apple", "pear", "banana"]
    
//    init() {
//        super.init(collectionViewLayout: ShoppingCollectionViewController.initLayout())
//    }
//
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//    }
//
//    static func initLayout() -> UICollectionViewCompositionalLayout {
//        return UICollectionViewCompositionalLayout { (number, env) ->
//            NSCollectionLayoutSection? in
//
//            let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
//            item.contentInsets.trailing = 1
//            item.contentInsets.leading = 1
//            item.contentInsets.bottom = 16
//
//            let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(200)), subitems: [item])
//
//            let section = NSCollectionLayoutSection(group: group)
//
//            section.orthogonalScrollingBehavior = .paging
//
//            return section
//        }
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // Uncomment the following line to preserve selection between presentations
//        // self.clearsSelectionOnViewWillAppear = false
//
//        // Register cell classes
//        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
//
//        // Do any additional setup after loading the view.
//    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    var layout: UICollectionViewFlowLayout!
    
    private func setupView() {
        if layout == nil {
            
        }
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return records.count
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return records[section].items.count
    }    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = UICollectionViewCell()
        
        if let itemCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? ItemCell {
            let data = records[indexPath.section].items[indexPath.row]
            itemCell.configure(with: data.name, image: data.image)
            cell = itemCell
        }
    
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("selected: \(records[indexPath.section].items[indexPath.row].name)")
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionHeader", for: indexPath) as! SectionHeader
        
        print(indexPath.section)
        print(records[indexPath.section])
        print(records[indexPath.section].category)
        
        sectionHeader.categoryTitle = records[indexPath.section].category
        
        return sectionHeader
    }
    
}
