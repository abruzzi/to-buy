//
//  BaseTabBarController.swift
//  GoShopping
//
//  Created by Juntao Qiu on 1/9/20.
//  Copyright © 2020 Juntao Qiu. All rights reserved.
//

import UIKit

class BaseTabBarController: UITabBarController {
    let toBuyManager = ToBuyManager(AppDelegate.viewContext)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.selectedIndex = 1
        
        toBuyManager.delegate = self

        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 12)], for: .selected)
    }
    
    func updateBadge() {
        toBuyManager.fetchAllToBuyItems()
    }
}

extension BaseTabBarController: ToBuyListDelegate {

    func toBuyItemCountChanged(_ toBuyManager: ToBuyManager, count: Int) {
        if let items = tabBar.items as NSArray? {
            let toBuyTab = items.object(at: 1) as! UITabBarItem
            toBuyTab.badgeValue = count == 0 ? nil : String(count)
        }
    }
    
    func delayedItemCountChanged(_ toBuyManager: ToBuyManager, count: Int) {
        if let items = tabBar.items as NSArray? {
            let delayedTab = items.object(at: 2) as! UITabBarItem
            delayedTab.badgeValue = count == 0 ? nil : String(count)
        }
    }
    
    
}
