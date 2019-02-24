//
//  CategoryViewController.swift
//  Liiist
//
//  Created by 滕施男 on 23/2/19.
//  Copyright © 2019 BetterTeng. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    var categories: Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
    }
    
    // MARK: - Data manipulation methods
    func save(category: Category) -> Void {
        
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Error saving data: \(error)")
        }
        
        self.tableView.reloadData()
    }
    
    func loadCategories() -> Void {
        
        categories = realm.objects(Category.self)

        tableView.reloadData()
    }
    
    // MARK: - Delete data using swipe gesture
    override func updataModel(at indexPath: IndexPath) {    // 注意：这里的indexPath的值是superclass传过来的（editActionsForRowAt这个method）
        
        if let categoryForDeletion = self.categories?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(categoryForDeletion)
                }
            } catch {
                print("Error deleting a category: \(error)")
            }
        }
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let category = categories?[indexPath.row] {
            cell.textLabel?.text = category.name
            
            guard let categoryColour = UIColor(hexString: category.colour) else {fatalError()}
            cell.backgroundColor = categoryColour
            cell.textLabel?.textColor = ContrastColorOf(categoryColour, returnFlat: true)
        }
        
        
        
        return cell
    }
    
    // MARK: - TableView delegate method
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationVC = segue.destination as! ToDoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }
    
    // MARK: - Add new entry method
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var localAlertTextField = UITextField()
        
        let alert = UIAlertController(title: "Add new category ", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            
            // What will happen when user click the Add button
            let newCategory = Category()
            newCategory.name = localAlertTextField.text!
            newCategory.colour = UIColor.randomFlat.hexValue()
            
            self.save(category: newCategory)
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new category..."
            localAlertTextField = alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
}
