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
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(with toBuyItem: ToBuyItem) {
        toBuyItemLabel.text = toBuyItem.name
        toBuyItemCategory.text = categoryTitles[toBuyItem.category]
        toBuyItemImage.image = UIImage(named: toBuyItem.image)
        supermarket.text = toBuyItem.supermarket
    }
}
