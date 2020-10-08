//
//  TagTableViewController.swift
//  GoShopping
//
//  Created by Juntao Qiu on 17/9/20.
//  Copyright © 2020 Juntao Qiu. All rights reserved.
//

import UIKit
import CoreData

private let reuseIdentifier = "tagCell"

class TagTableViewController: UITableViewController {
    private var alertActionToEnable: UIAlertAction!
    
    let store = CoreDataStack.store
    
    private lazy var dataProvider: TagProvider = {
        let provider = TagProvider(with: store.viewContext,
                                      fetchedResultsControllerDelegate: self)
        return provider
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "TagCell", bundle: nil), forCellReuseIdentifier: reuseIdentifier)
        
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = dataProvider.fetchedResultsController.fetchedObjects?.count ?? 0
        if(count == 0) {
            self.tableView.emptyState(label: NSLocalizedString("tag.empty.hint.message", comment: "tag.empty.hint.message"), image: "icons8-price_tag")
        } else {
            self.tableView.restore()
        }
        
        return count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! TagCell
        let item = dataProvider.fetchedResultsController.object(at: indexPath)
        
        cell.tagTextLabel.text = item.name
        
        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            dataProvider.deleteTag(at: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection
        section: Int) -> String? {
        return NSLocalizedString("tag.table.header.message", comment: "tag.table.header.message")
    }
}

extension TagTableViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }
}

extension TagTableViewController {
    @IBAction func addNewTagClicked(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Create a new tag", message: "You can put a supermarket name here", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Name"
            textField.addTarget(self, action: #selector(type(of: self).textChanged(_:)), for: .editingChanged)
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        addActionSheetForiPad(actionSheet: alert)
        present(alert, animated: true, completion: nil)
        
        alertActionToEnable = UIAlertAction(title: "Create", style: .default) {_ in
            guard let name = alert.textFields?.first?.text, !name.isEmpty else { return }
            self.dataProvider.addTag(name: name)
        }
        alertActionToEnable.isEnabled = false
        alert.addAction(alertActionToEnable!)
    }
    
    @objc
    func textChanged(_ sender: UITextField) {
        // Check that tagName.count > 1 to make sure the tag displays well (text width > height) with TagLabel.
        guard let tagName = sender.text, tagName.count > 1 else {
            alertActionToEnable.isEnabled = false
            return
        }
        let numberOfTags = dataProvider.numberOfTags(with: tagName)
        alertActionToEnable.isEnabled = (numberOfTags == 0)
    }
}
