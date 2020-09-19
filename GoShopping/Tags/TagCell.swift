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
    @IBOutlet weak var colorLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tagTextLabel.text = ""
        
        
        let unselected = UIView(frame: bounds)
        unselected.backgroundColor = UIColor(named: "BGColor")
        self.backgroundView = unselected
        
        let selected = UIView(frame: bounds)
        selected.backgroundColor = UIColor(named: "CardColor")
        self.selectedBackgroundView = selected
    }
    
    func configure(name: String) {
        let color = generateColorFor(text: name)
        colorLabel.text = ""
        colorLabel.backgroundColor = color
    }
}

func generateColorFor(text: String) -> UIColor{
    var hash = 0
    let colorConstant = 131
    let maxSafeValue = Int.max / colorConstant
    
    for char in text.unicodeScalars{
        if hash > maxSafeValue {
            hash = hash / colorConstant
        }
        hash = Int(char.value) + ((hash << 5) - hash)
    }
    
    let finalHash = abs(hash) % (256*256*256);
    
    let color = UIColor(red: CGFloat((finalHash & 0xFF0000) >> 16) / 255.0, green: CGFloat((finalHash & 0xFF00) >> 8) / 255.0, blue: CGFloat((finalHash & 0xFF)) / 255.0, alpha: 1.0)
    
    return color
}
