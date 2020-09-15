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
        
        toBuyItemImage.image = UIImage(data: toBuy.image!) // getImageOf(itemName: toBuy.name!, fallbackImageName: toBuy.image!)
        toBuyItemImage.layer.cornerRadius = 4.0
        toBuyItemImage.layer.masksToBounds = true
        
        
        supermarket.text = toBuy.supermarket
        
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
