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
    
    private lazy var dataProvider: TagProvider = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let provider = TagProvider(with: appDelegate.persistentContainer,
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
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return dataProvider.fetchedResultsController.fetchedObjects?.count ?? 0
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
}

extension TagTableViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }
}

extension TagTableViewController {
    @IBAction func addNewTagClicked(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "New Tag.", message: "Create a new tag.", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Enter a tag name."
            textField.addTarget(self, action: #selector(type(of: self).textChanged(_:)), for: .editingChanged)
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
        
        alertActionToEnable = UIAlertAction(title: "Craete", style: .default) {_ in
            guard let name = alert.textFields?.first?.text, !name.isEmpty else { return }
            self.dataProvider.addTag(name: name, context: self.dataProvider.persistentContainer.viewContext)
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
