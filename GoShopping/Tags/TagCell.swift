//
//  TagCell.swift
//  GoShopping
//
//  Created by Juntao Qiu on 17/9/20.
//  Copyright © 2020 Juntao Qiu. All rights reserved.
//

import UIKit

class TagCell: UITableViewCell {

    @IBOutlet weak var tagTextLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        tagTextLabel.text = ""
        
        
        let unselected = UIView(frame: bounds)
        unselected.backgroundColor = UIColor(named: "BGColor")
        self.backgroundView = unselected

        let selected = UIView(frame: bounds)
        selected.backgroundColor = UIColor(named: "CardColor")
        self.selectedBackgroundView = selected
    }
    
}
