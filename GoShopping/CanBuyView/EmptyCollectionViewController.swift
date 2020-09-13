//
//  AViewController.swift
//  GoShopping
//
//  Created by Juntao Qiu on 13/9/20.
//  Copyright © 2020 Juntao Qiu. All rights reserved.
//

import UIKit
import CoreData

class EmptyCollectionViewController: UIViewController, NSFetchedResultsControllerDelegate {
    
    var label: String!
    var image: String!
    
    private lazy var dataProvider: CanBuysProvider = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let provider = CanBuysProvider(with: appDelegate.persistentContainer,
                                      fetchedResultsControllerDelegate: self)
        return provider
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let label = UILabel()
        label.textColor = UIColor(named: "FontColor")
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = self.label
        label.textAlignment = .center
        
        let imageView = UIImageView(frame: .zero)
        imageView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.backgroundColor = UIColor(named: "blue")
        imageView.image = UIImage(named: self.image)
        
        self.view.addSubview(imageView)
        self.view.addSubview(label)
        
        imageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10).isActive = true
        label.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(editNewItem))
        self.view.addGestureRecognizer(singleTap)
    }
    

    
    //Action
    @objc func editNewItem() {
        print("about to edit")
        let context = dataProvider.persistentContainer.viewContext
        dataProvider.addCanBuy(in: context, name: label, image: image) { canBuyItem in            
            let viewController = self.storyboard?.instantiateViewController(identifier: "EditingTableViewController")
                as? EditingTableViewController
            viewController!.item = canBuyItem

            self.navigationController?.pushViewController(viewController!, animated: true)
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
