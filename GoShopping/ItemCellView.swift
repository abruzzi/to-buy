//
//  ItemCellView.swift
//  GoShopping
//
//  Created by Juntao Qiu on 1/9/20.
//  Copyright © 2020 Juntao Qiu. All rights reserved.
//

import UIKit

class ItemCellView: UICollectionViewCell {
    
    @IBOutlet weak var itemNameLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        self.layer.cornerRadius = 10.0
        self.layer.borderWidth = 2.0
        self.layer.borderColor = UIColor.clear.cgColor
        self.layer.masksToBounds = true
    }
    
//    override var isSelected: Bool {
//        didSet {
//            if self.isSelected {
//                self.contentView.backgroundColor = UIColor.darkGray
//            } else {
//                self.contentView.backgroundColor = UIColor.purple
//            }
//        }
//      }

    func configure(with itemName: String) {
        itemNameLabel.text = itemName
    }
}
