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
    @IBOutlet weak var itemImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        self.layer.cornerRadius = 4.0
        self.layer.masksToBounds = true
    }
    
    override var isSelected: Bool {
        didSet {
            if self.isSelected {
                self.contentView.backgroundColor = UIColor(named: "BrandColor")
            } else {
                self.contentView.backgroundColor = UIColor(named: "CardColor")
            }
        }
      }

    func configure(with itemName: String, image: String) {
        itemNameLabel.text = itemName
        itemImage.image = UIImage(named: image)
    }
}
