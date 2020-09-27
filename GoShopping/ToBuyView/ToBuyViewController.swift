//
//  ToBuyViewController.swift
//  GoShopping
//
//  Created by Juntao Qiu on 26/9/20.
//  Copyright © 2020 Juntao Qiu. All rights reserved.
//

import UIKit
import CoreData

private let reuseIdentifier = "ToBuyTableViewCell"

class ToBuyViewController: UIViewController, NSFetchedResultsControllerDelegate {
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "ToBuyTableViewCell", bundle: nil), forCellReuseIdentifier: reuseIdentifier)
    }
    
    private lazy var toBuyDataProvider: ToBuysProvider = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let provider = ToBuysProvider(with: appDelegate.persistentContainer,
                                      fetchedResultsControllerDelegate: self)
        return provider
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        self.updateBadge()
    }
}

extension ToBuyViewController: UITableViewDataSource {
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = toBuyDataProvider.fetchedResultsController.fetchedObjects?.count ?? 0
        
        if(count == 0) {
            self.tableView.emptyState(label: NSLocalizedString("to.buy.empty.hint.message", comment: "to.buy.empty.hint.message"), image: "icons8-basket")
        } else {
            self.tableView.restore()
        }
        
        return count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection
        section: Int) -> String? {
        return NSLocalizedString("to.buy.items", comment: "to.buy.items")
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToBuyTableViewCell", for: indexPath) as! ToBuyTableViewCell
        let item = toBuyDataProvider.fetchedResultsController.object(at: indexPath)
        cell.configure(with: item)
        return cell
    }

}

extension ToBuyViewController: UITableViewDelegate {
    
}
