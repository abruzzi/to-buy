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
        
        let unselected = UIView(frame: bounds)
        unselected.backgroundColor = UIColor(named: "CardColor")
        self.backgroundView = unselected

        let selected = UIView(frame: bounds)
        selected.backgroundColor = UIColor(named: "BrandColor")
        self.selectedBackgroundView = selected
    }
    
    override func layoutSubviews() {
        self.layer.cornerRadius = 4.0
        self.layer.masksToBounds = true
    }

    func configure(with itemName: String, image: String) {
        itemNameLabel.text = itemName
        itemImage.image = UIImage(named: image)
    }
}
