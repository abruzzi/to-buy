//
//  SceneDelegate.swift
//  GoShopping
//
//  Created by Juntao Qiu on 31/8/20.
//  Copyright © 2020 Juntao Qiu. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    let store = CoreDataStack.store
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        store.saveContext()
    }
    
    func refreshToBuyList(url: URL) {
        guard
            let navigationController = self.window?.rootViewController as? UINavigationController,
            let toBuyTableViewController = navigationController.viewControllers.first as? ToBuyTableViewController
            else { return }
        
        toBuyTableViewController.tableView.reloadData()
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        let url = URLContexts.first?.url
        let toBuyManager = ToBuyManager(store.viewContext)
        guard url!.pathExtension == "tblr" else { return  }
        
        let allToBuys = toBuyManager.allRemainingToBuys()

        let title = NSLocalizedString("message.hint.merge.shared.title", comment: "message.hint.merge.shared.title")
        let message = NSLocalizedString("message.hint.merge.shared.subtitle", comment: "message.hint.merge.shared.subtitle")
        
        if(allToBuys.count > 0) {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("message.hint.merge.shared.ok", comment: "message.hint.merge.shared.ok"), style: .destructive, handler: { action in
                toBuyManager.importToBuys(from: url!)
                self.refreshToBuyList(url: url!)
            }))
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("message.hint.merge.shared.cancel", comment: "message.hint.merge.shared.cancel"), style: .cancel, handler: nil))
            
            window?.rootViewController!.present(alert, animated: true)
        } else {
            toBuyManager.importToBuys(from: url!)
            self.refreshToBuyList(url: url!)
        }
    }
}

