//
//  EditingViewController.swift
//  GoShopping
//
//  Created by Juntao Qiu on 6/9/20.
//  Copyright © 2020 Juntao Qiu. All rights reserved.
//

import UIKit

class EditingViewController: UIViewController {
    var item: Item!
    
    @IBOutlet weak var itemNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        itemNameLabel.text = item.name
    }
}
