//
//  HistoryCell.swift
//  GoShopping
//
//  Created by Juntao Qiu on 26/9/20.
//  Copyright © 2020 Juntao Qiu. All rights reserved.
//

import UIKit

class HistoryCell: UITableViewHeaderFooterView {

    @IBOutlet weak var historyLabel: UILabel!
    @IBOutlet weak var historyCountLabel: CountLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        historyLabel.text = "History"
    }
    
    func configure(count: Int) {
        historyCountLabel.layer.masksToBounds = true
        historyCountLabel.layer.cornerRadius = 4
        historyCountLabel.text = String(count)
    }
}

class CountLabel: UILabel {
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: 5, left: 5, bottom: 0, right: 5)
        super.drawText(in: rect.inset(by: insets))
    }
}
