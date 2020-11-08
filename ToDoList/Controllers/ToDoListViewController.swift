//
//  ViewController.swift
//  ToDoList
//
//  Created by Sidany Walker on 11/4/20.
//

import UIKit
import RealmSwift
import ChameleonFramework

class ToDoListViewController: SwipeTableViewController {
    
    var toDoItems: Results<Item>?
    let realm = try! Realm()

    @IBOutlet weak var searchBar: UISearchBar!
    
    
    //using didSet to specify what happens when a variable gets set with a new value
    var selectedCategory : Category? {
        didSet{
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        //prints out the filepath to our debug to locate our SQLite file in which we open with a SQLite app. Open it to view items you added to our todolist app. This is our persistentContainer.
        
        tableView.separatorStyle = .none

    }
    
    //Gets called later than viewdidload right before the view is going to show up on screen.  Viewdidload -> navigation stack established -> viewwillappear -> user sees what's on screen
    override func viewWillAppear(_ animated: Bool) {
        if let colorHex = selectedCategory?.color {
            
            title = selectedCategory!.name
            
            guard let navBar = navigationController?.navigationBar else {fatalError("Navigation controller does not exist.")}
            
            if let navBarColor = UIColor(hexString: colorHex) {
                
                navBar.backgroundColor = navBarColor
                
                navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
                
                navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(navBarColor, returnFlat: true)]
                
                searchBar.backgroundColor = navBarColor
                
            }
        
        }
    }

//MARK: - Tableview Datasource Methods
    
//first data source to add is the number of rows
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toDoItems?.count ?? 1
        
    }
    
//second data source delegate method is cellForRow that figures out how we should display each of the cells:
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = toDoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            
            if let color = UIColor(hexString: selectedCategory!.color)?.darken(byPercentage:CGFloat(indexPath.row) / CGFloat(toDoItems!.count)) {
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }

            
            cell.accessoryType = item.done ? .checkmark : .none
        } else {
            cell.textLabel?.text = "No Items Added"
        }
      return cell
    }
    
//Now we want to be able to select these cells (have it printed in the debug counsel) and then be able to give it a check mark everytime each cell is clicked on and uncheck it when clicked again. We need some tableview delegate methods:
    
    
//MARK: - TableView Delegate Methods (the ones that gets fired whenever we click on any cell in the TableView)
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      //update and delete items in our realm database:
        if let item = toDoItems?[indexPath.row] {
            do {
            try realm.write {
                item.done = !item.done
            }
            } catch {
                print("Error saving done status \(error)")
            }
        }
        tableView.reloadData()

        tableView.deselectRow(at: indexPath, animated: true)
        // flashes grey briefly and looks nicer when selecting an item instead of staying grey
    }
    
    
//MARK: - Add New Items
    
 //go to Main.storyboard and add a bar button item' then link IBAction here:
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New ToDo Item", message: "", preferredStyle: .alert) //the .alert is default
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            //what will happen once the user clicks the add item button on our UIalert
        if let currentCategory = self.selectedCategory {
            do {
                try self.realm.write {
                    let newItem = Item()
                    newItem.title = textField.text!
                    newItem.dateCreated = Date()
                    currentCategory.items.append(newItem)
            }
            } catch {
                print("Error saving new items \(error)")
            }
            }
            
            self.tableView.reloadData()
        }
        
        //adding a textfield in our alert for the user to type in:
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create New Item"
            textField = alertTextField
        }
        
        alert.addAction(action)
            
        //show our alert:
        present(alert, animated: true, completion: nil)
                
        
    }
    
    
 //MARK: - Model Manipulation Methods

    func loadItems() {
        
        toDoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)

        tableView.reloadData()
    }
 
    override func updateModel(at indexPath: IndexPath) {
        if let item = toDoItems?[indexPath.row] {
            do {
                try realm.write {
                realm.delete(item)
            }
            } catch {
                print("Error deleting item \(error)")
            }
        }
    }
}

//MARK: - Search bar methods

//code organization using extension
extension ToDoListViewController: UISearchBarDelegate {

    //query our database
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        //check out NSPredicate cheat sheet online and see how the string is structured. Case and diacritic insensitive:
        toDoItems = toDoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        //the title should contain whatever is in the search bar
        //the results should come back by date created in ascending order
        
        tableView.reloadData()
    }

    //after clearing our search bar and reverts to original list to display:
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()

            //object that manages the execution of work items, threads:
            DispatchQueue.main.async {
                //running this method on the main Q
                searchBar.resignFirstResponder()
                //dismisses the keyboard and cursor b/c no longer editing
            }


        }
    }
}
