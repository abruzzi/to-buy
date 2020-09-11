//
//  ToBuyTableViewCell.swift
//  GoShopping
//
//  Created by Juntao Qiu on 1/9/20.
//  Copyright © 2020 Juntao Qiu. All rights reserved.
//

import UIKit

class ToBuyTableViewCell: UITableViewCell {
    let categoryTitles = [
        NSLocalizedString("category.food.title", comment: "category.food.title"),
        NSLocalizedString("category.essentials.title", comment: "category.essentials.title"),
        NSLocalizedString("category.health.title", comment: "category.health.title"),
        NSLocalizedString("category.others.title", comment: "category.others.title")
    ]
    
    @IBOutlet weak var toBuyItemLabel: UILabel!
    @IBOutlet weak var toBuyItemImage: UIImageView!
    @IBOutlet weak var toBuyItemCategory: UILabel!
    @IBOutlet weak var supermarket: UILabel!
    @IBOutlet weak var createdAtLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(with toBuy: ToBuys) {
        let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: toBuy.name!)
        if(toBuy.isCompleted) {
            attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
        }
        toBuyItemLabel.layer.opacity = toBuy.isCompleted ? 0.5 : 1
        toBuyItemLabel.attributedText = attributeString

        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "MMM dd HH:mm"
        
        createdAtLabel.text = dateFormatterGet.string(from: toBuy.createdAt!)
        toBuyItemCategory.text = categoryTitles[Int(toBuy.category)]
        toBuyItemImage.image = getImageOf(itemName: toBuy.name!, fallbackImageName: toBuy.image!)
        toBuyItemImage.layer.cornerRadius = 4.0
        toBuyItemImage.layer.masksToBounds = true
        supermarket.text = toBuy.supermarket
    }
    
    func configure(with toBuyItem: ToBuyItem) {
        let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: toBuyItem.name)
        if(toBuyItem.isCompleted) {
            attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
        }
        toBuyItemLabel.layer.opacity = toBuyItem.isCompleted ? 0.5 : 1
        toBuyItemLabel.attributedText = attributeString

        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "MMM dd HH:mm"
        
        createdAtLabel.text = dateFormatterGet.string(from: toBuyItem.createdAt)
        toBuyItemCategory.text = categoryTitles[toBuyItem.category]
        toBuyItemImage.image = getImageOf(itemName: toBuyItem.name, fallbackImageName: toBuyItem.image)
        toBuyItemImage.layer.cornerRadius = 4.0
        toBuyItemImage.layer.masksToBounds = true
        supermarket.text = toBuyItem.supermarket
    }
}
