//
//  CategoryViewController.swift
//  todoey using core data
//
//  Created by Devang Pawar on 08/06/20.
//  Copyright © 2020 Devang Pawar. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {
    var categories = [Category]()
    // swiftlint:disable force_cast
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    // swiftlint:enable force_cast
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
    }
    // MARK: - add category button
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "add category", message: "Add new category", preferredStyle: .alert)
        let action = UIAlertAction(title: "Done", style: .default) { _ in
            let newCategory = Category(context: self.context)
            newCategory.title = textField.text!
            self.categories.append(newCategory)
            self.saveData()
        }
        alert.addTextField { (insideTextField) in
            textField = insideTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}
// MARK: - save and load data
extension CategoryViewController {
    func saveData() {
        do {
            try context.save()
        } catch {
            print("Error Saving Data \(error)")
        }
        tableView.reloadData()
    }
    func loadData(with givenPredicate: NSPredicate? = nil) {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        if let predicate = givenPredicate {
            request.predicate = predicate
        }
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        do {
            categories = try context.fetch(request)
        } catch {
            print("Error fetching data \(error)")
        }
        tableView.reloadData()
    }
}
// MARK: - search delegate
extension CategoryViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        loadData(with: predicate)
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
// MARK: - tableview delegate
extension CategoryViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toItemView", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? ItemViewController {
            if  let indexPath = tableView.indexPathForSelectedRow {
                destinationVC.selectedCategory = categories[indexPath.row]
            }
        }
    }
    // swiftlint:disable line_length
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            context.delete(categories[indexPath.row])
            categories.remove(at: indexPath.row)
            saveData()
        }
    }
    // swiftlint:enable line_length
}
// MARK: - tableview data sources
extension CategoryViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        categories.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath)
        cell.textLabel?.text = categories[indexPath.row].title
        return cell
    }
}
