//
//  ViewController.swift
//  todoey using core data
//
//  Created by Devang Pawar on 08/06/20.
//  Copyright © 2020 Devang Pawar. All rights reserved.
// swiftlint:disable line_length

import UIKit
import CoreData

class ItemViewController: UITableViewController {
    var selectedCategory: Category? {
        didSet {
            loadData()
        }
    }
    var items = [Item]()
    // swiftlint:disable force_cast
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    // swiftlint:enable force_cast
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    // MARK: - addbutton
    @IBAction func addItemPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "add item", message: "Add new Item", preferredStyle: .alert)
        let action = UIAlertAction(title: "Done", style: .default) { (_) in
            let newItem = Item(context: self.context)
            newItem.name = textField.text!
            newItem.done = false
            newItem.parentCategory = self.selectedCategory
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
// MARK: - searching
extension ItemViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        let predicate = NSPredicate(format: "name CONTAINS[cd] %@", searchBar.text!)
        let sort = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [sort]
        loadData(with: request, specialised: predicate)
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text!.isEmpty {
            loadData()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
// MARK: - saving and loading

extension ItemViewController {
    func saveData() {
        do {
            try context.save()
        } catch {
            print("error saving dat \(error)")
        }
        tableView.reloadData()
    }
    func loadData(with request: NSFetchRequest<Item> = Item.fetchRequest(), specialised givenPredicate: NSPredicate? = nil) {
        let categoryPredicate = NSPredicate(format: "parentCategory.title MATCHES %@", selectedCategory!.title!)
        if let specialPredicate = givenPredicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, specialPredicate])
        } else {
            request.predicate = categoryPredicate
        }
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
    // swiftlint:disable line_length
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            context.delete(items[indexPath.row])
            items.remove(at: indexPath.row)
            saveData()
        }
    }
}
