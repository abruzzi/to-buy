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
    @IBOutlet weak var categoryIconImage: UIImageView!
    
    func configure(with categoryTitle: String, image: UIImage) {
        categoryTitleLabel.text = categoryTitle
        categoryIconImage.image = image
    }
}
