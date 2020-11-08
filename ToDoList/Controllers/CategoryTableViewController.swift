//
//  CategoryTableViewController.swift
//  ToDoList
//
//  Created by Sidany Walker on 11/7/20.
//

import UIKit
import RealmSwift

class CategoryTableViewController: SwipeTableViewController {
    //initialize a new access point to our realm database
    let realm = try! Realm()
    //collectiontype Results of Category Object optional so we can be safe
    var categories: Results<Category>?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()
        
    }
//MARK: - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //Nil Coalescing operator :
        return categories?.count ?? 1
    }
    

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //go into our super class:
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        cell.textLabel?.text = categories?[indexPath.row].name ?? "No Categories Added Yet"
         
        return cell
    }
    
//MARK: - Tableview Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ToDoListViewController
        
        //grab category from selected cell:
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories?[indexPath.row] 
        }
    }
    
    
//MARK: - Data Manipulation Methods
    //commiting changes to our realm
    func save(category: Category) {
        do {
            try realm.write {
            realm.add(category)
            }
        } catch {
            print("Error saving category \(error)")
        }
        
        tableView.reloadData()
    }

    //Set the property categories to look inside our realm and fetch all of our objects that belong to the category type
    func loadCategories() {
        
         categories = realm.objects(Category.self)

        tableView.reloadData()
        }
    
 //MARK: - Delete Data From Swipe
    
override func updateModel(at indexPath: IndexPath) {
    
    if let categoryForDeletion = self.categories?[indexPath.row] {
        do {
            try self.realm.write {
            self.realm.delete(categoryForDeletion)
                    }
                    } catch {
                        print("Error deleting category \(error)")
                    }
                }
}
    
//MARK: - Add New Categories
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
    
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
         
            let newCategory = Category()
            newCategory.name = textField.text!
            
        
            
            self.save(category: newCategory)
        }
        alert.addAction(action)
        
        alert.addTextField { (field) in
            textField = field
            textField.placeholder = "Add a new category"
        }
        
        present(alert, animated: true, completion: nil)
    }
  
  

    

}


