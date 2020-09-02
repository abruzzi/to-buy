//
//  BaseTabBarController.swift
//  GoShopping
//
//  Created by Juntao Qiu on 1/9/20.
//  Copyright © 2020 Juntao Qiu. All rights reserved.
//

import UIKit

class BaseTabBarController: UITabBarController {
    var selected:Dictionary<Int, Item> = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
