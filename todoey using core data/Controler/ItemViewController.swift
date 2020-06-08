//
//  ViewController.swift
//  todoey using core data
//
//  Created by Devang Pawar on 08/06/20.
//  Copyright © 2020 Devang Pawar. All rights reserved.
//

import UIKit
import CoreData

class ItemViewController: UITableViewController {
    var items = [Item]()
    // swiftlint:disable force_cast
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    // swiftlint:enable force_cast
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
    }
    @IBAction func addItemPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "add item", message: "Add new Item", preferredStyle: .alert)
        let action = UIAlertAction(title: "Done", style: .default) { (_) in
            let newItem = Item(context: self.context)
            newItem.name = textField.text!
            newItem.done = false
            self.items.append(newItem)
            self.saveData()
        }
        alert.addTextField { ( alertTextField ) in
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}
// MARK: - saving

extension ItemViewController {
    func saveData() {
        do {
            try context.save()
        } catch {
            print("error saving dat \(error)")
        }
        tableView.reloadData()
    }
    func loadData() {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        do {
            items = try context.fetch(request)
        } catch {
            print("error fetching data \(error)")
        }
        tableView.reloadData()
    }
}
// MARK: - tableview creation
extension ItemViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath)
        cell.textLabel?.text = items[indexPath.row].name
        cell.accessoryType = items[indexPath.row].done ? .checkmark : .none
        return cell
    }
}
// MARK: tableview delegate
extension ItemViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        items[indexPath.row].done = !items[indexPath.row].done
        saveData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
