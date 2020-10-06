//
//  CustomShareNavigationController.swift
//  GoShoppingShare
//
//  Created by Juntao Qiu on 6/10/20.
//  Copyright © 2020 Juntao Qiu. All rights reserved.
//

import UIKit

@objc(CustomShareNavigationController)
class CustomShareNavigationController: UINavigationController {

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        // 2: set the ViewControllers
        self.setViewControllers([CustomShareViewController()], animated: false)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
