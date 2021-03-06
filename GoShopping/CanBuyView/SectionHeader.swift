//
//  SectionHeader.swift
//  GoShopping
//
//  Created by Juntao Qiu on 1/9/20.
//  Copyright © 2020 Juntao Qiu. All rights reserved.
//

import UIKit

class SectionHeader: UICollectionReusableView {
    @IBOutlet weak var categoryTitleLabel: UILabel!
    
    func configure(with categoryTitle: String) {
        categoryTitleLabel.text = categoryTitle
    }
}
