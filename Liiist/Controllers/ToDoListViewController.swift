//
//  ViewController.swift
//  Liiist
//
//  Created by 滕施男 on 20/2/19.
//  Copyright © 2019 BetterTeng. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class ToDoListViewController: SwipeTableViewController {

    let realm = try! Realm()
    var toDoItems: Results<Item>?
    var selectedCategory: Category? { didSet {loadItems()}}
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
       
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        guard let hexColour = selectedCategory?.colour else {fatalError("There's no value for the selectedCategory's colour property...")}
        
        updateNavigationBar(withHexCode: hexColour)
        
        title = selectedCategory?.name
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        updateNavigationBar(withHexCode: "1D9BF6")
    }
    
    // MARK: Update navigation bar
    func updateNavigationBar(withHexCode colourHexCod: String) -> Void {
        
        guard let navi = navigationController?.navigationBar else {fatalError("Navigation controller does not exist...")}
        guard let navBarColour = UIColor(hexString: colourHexCod) else {fatalError("Cannot get the colour...")}
        
        searchBar.barTintColor = navBarColour
        
        navi.barTintColor = navBarColour
        navi.tintColor = ContrastColorOf(navBarColour, returnFlat: true)
        navi.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: ContrastColorOf(navBarColour, returnFlat: true)]
    }
    
    // MARK: - TableView data source methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return toDoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = toDoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            cell.accessoryType = item.done ? .checkmark : .none
            if let colour = UIColor(hexString: selectedCategory!.colour)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(toDoItems!.count) / CGFloat(2)) {
                cell.backgroundColor = colour
                cell.textLabel?.textColor = ContrastColorOf(colour, returnFlat: true)
            }
        } else {
            cell.textLabel?.text = "No items added yet..."
            cell.backgroundColor = UIColor(hexString: "1D9BF6")
        }

        return cell
    }

    // MARK: - TableView delegate method
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = toDoItems?[indexPath.row] {
            do {
                try realm.write {
                    item.done = !item.done
                }
            } catch {
                print("Erorr saving done status: \(error)")
            }
        }
        
        tableView.reloadData()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - Add new items...
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var localAlertTextField = UITextField()

        let alert = UIAlertController(title: "Add new item ", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) { (action) in

            // What will happen when user click the Add button
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = localAlertTextField.text!
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                    }
                } catch {
                    print("Error saving new items: \(error)")
                }
            }
            
            self.tableView.reloadData()
        }

        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item..."
            localAlertTextField = alertTextField
        }

        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Data manipulation methods
    func loadItems() -> Void {
        
        toDoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)

        tableView.reloadData()
    }
    
    // MARK: - Delete data using swipe gesture
    override func updataModel(at indexPath: IndexPath) {    // 注意：这里的indexPath的值是superclass传过来的（editActionsForRowAt这个method）
        
        if let itemForDeletion = self.toDoItems?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(itemForDeletion)
                }
            } catch {
                print("Error deleting a category: \(error)")
            }
        }
    }

}

// MARK: - Search bar methods
extension ToDoListViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        loadItems()
        
        toDoItems = toDoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        
        tableView.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        if searchBar.text?.count == 0 {
            loadItems()

            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }

}

