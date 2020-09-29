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
    
    @IBOutlet weak var priorityDotView: UIView!
    @IBOutlet weak var toBuyItemLabel: UILabel!
    @IBOutlet weak var toBuyItemImage: UIImageView!
    @IBOutlet weak var toBuyItemCategory: UILabel!
    @IBOutlet weak var supermarket: UILabel!
    @IBOutlet weak var createdAtLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        priorityDotView.layer.cornerRadius = 3
    }

    func configure(with toBuyHistoryItem: ToBuyHistory) {
        let styledItemName: NSMutableAttributedString =  NSMutableAttributedString(string: toBuyHistoryItem.name!)
        toBuyItemLabel.attributedText = styledItemName

        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "MMM dd HH:mm"
        
        createdAtLabel.text = dateFormatterGet.string(from: toBuyHistoryItem.createdAt!)
        
        toBuyItemCategory.text = categoryTitles[Int(toBuyHistoryItem.category)]
        
        toBuyItemImage.image = UIImage(data: toBuyHistoryItem.image!)
        toBuyItemImage.layer.cornerRadius = 4.0
        toBuyItemImage.layer.masksToBounds = true
        
        
        supermarket.text = toBuyHistoryItem.supermarket

        priorityDotView.layer.opacity = 0
        createdAtLabel.layer.opacity = 0.7
        toBuyItemCategory.layer.opacity = 0.7
        toBuyItemLabel.layer.opacity = 0.7
        supermarket.layer.opacity = 0.7
        toBuyItemImage.layer.opacity = 0.7
    }
    
    func configure(with toBuy: ToBuy) {
        self.contentView.backgroundColor =  toBuy.isCompleted ? UIColor(named: "ListCellBGColor") : UIColor(named: "BGColor")
        let styledItemName: NSMutableAttributedString =  NSMutableAttributedString(string: toBuy.name!)

        if(toBuy.isCompleted) {
            styledItemName.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, styledItemName.length))
        }

        toBuyItemLabel.attributedText = styledItemName

        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "MMM dd HH:mm"
        
        createdAtLabel.text = dateFormatterGet.string(from: toBuy.createdAt!)
        
        toBuyItemCategory.text = categoryTitles[Int(toBuy.category)]
        
        toBuyItemImage.image = UIImage(data: toBuy.image!)
        toBuyItemImage.layer.cornerRadius = 4.0
        toBuyItemImage.layer.masksToBounds = true
        
        
        supermarket.text = toBuy.supermarket
        priorityDotView.layer.opacity = toBuy.priority > 0 ? 1.0 : 0.0
        
        if(toBuy.isCompleted) {
            createdAtLabel.layer.opacity = 0.5
            toBuyItemCategory.layer.opacity = 0.5
            toBuyItemLabel.layer.opacity = 0.5
            supermarket.layer.opacity = 0.5
            toBuyItemImage.layer.opacity = 0.3
        } else {
            createdAtLabel.layer.opacity = 1
            toBuyItemCategory.layer.opacity = 1
            toBuyItemLabel.layer.opacity = 1
            supermarket.layer.opacity = 1
            toBuyItemImage.layer.opacity = 1
        }
    }
}
