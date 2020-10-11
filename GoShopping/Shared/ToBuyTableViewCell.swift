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
    
    @IBOutlet weak var delayedDotView: UIView!
    @IBOutlet weak var priorityDotView: UIView!
    @IBOutlet weak var toBuyItemLabel: UILabel!
    @IBOutlet weak var toBuyItemImage: UIImageView!
    @IBOutlet weak var toBuyItemCategory: UILabel!
    @IBOutlet weak var supermarket: UILabel!
    @IBOutlet weak var createdAtLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    private func formatDate(_ date: Date) -> String {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "MMM dd HH:mm"
        
        return dateFormatterGet.string(from: date)
    }
    
    func configure(with toBuyHistoryItem: ToBuyHistory) {
        guard toBuyHistoryItem.name != nil else {
            return
        }
        let styledItemName: NSMutableAttributedString =  NSMutableAttributedString(string: toBuyHistoryItem.name!)
        toBuyItemLabel.attributedText = styledItemName

        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "MMM dd HH:mm"
        
        createdAtLabel.text = formatDate(toBuyHistoryItem.createdAt!)
        
        toBuyItemCategory.text = categoryTitles[Int(toBuyHistoryItem.category)]
        
        if let image = toBuyHistoryItem.image {
            toBuyItemImage.image = UIImage(data: image)
        } else {
            toBuyItemImage.image = UIImage(named: "crystal_ball")
        }
        
        toBuyItemImage.layer.cornerRadius = 4.0
        toBuyItemImage.layer.masksToBounds = true
        
        
        supermarket.text = toBuyHistoryItem.supermarket

        priorityDotView.layer.opacity = 0
        delayedDotView.layer.opacity = 0
        createdAtLabel.layer.opacity = 0.7
        toBuyItemCategory.layer.opacity = 0.7
        toBuyItemLabel.layer.opacity = 0.7
        supermarket.layer.opacity = 0.7
        toBuyItemImage.layer.opacity = 0.7
    }
    
    func configure(with toBuy: ToBuy) {
        guard let name = toBuy.name, !name.isEmpty else {
            return
        }
        
        self.contentView.backgroundColor =  toBuy.isCompleted ? UIColor(named: "ListCellBGColor") : UIColor(named: "BGColor")
        let styledItemName: NSMutableAttributedString =  NSMutableAttributedString(string: toBuy.name!)

        if(toBuy.isCompleted) {
            styledItemName.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, styledItemName.length))
        }

        toBuyItemLabel.attributedText = styledItemName
        
        createdAtLabel.text = formatDate(toBuy.createdAt!)
        
        toBuyItemCategory.text = categoryTitles[Int(toBuy.category)]
        
        if let image = toBuy.image {
            toBuyItemImage.image = UIImage(data: image)
        } else {
            toBuyItemImage.image = UIImage(named: "crystal_ball")
        }
        
        toBuyItemImage.layer.cornerRadius = 4.0
        toBuyItemImage.layer.masksToBounds = true
        
        
        supermarket.text = toBuy.supermarket
        let gradient = toBuy.priority == 0 ? 0.0 : Float(Double(toBuy.priority) / 5.0)
        priorityDotView.layer.opacity = gradient
        delayedDotView.layer.cornerRadius = 3.0
        delayedDotView.layer.opacity = toBuy.isDelayed ? 1.0 : 0.0
        
        if(toBuy.isCompleted) {
            createdAtLabel.layer.opacity = 0.5
            toBuyItemCategory.layer.opacity = 0.5
            toBuyItemLabel.layer.opacity = 0.5
            supermarket.layer.opacity = 0.5
            toBuyItemImage.layer.opacity = 0.3
            priorityDotView.layer.opacity = 0
            delayedDotView.layer.opacity = 0
        } else {
            createdAtLabel.layer.opacity = 1
            toBuyItemCategory.layer.opacity = 1
            toBuyItemLabel.layer.opacity = 1
            supermarket.layer.opacity = 1
            toBuyItemImage.layer.opacity = 1
        }
    }
}
