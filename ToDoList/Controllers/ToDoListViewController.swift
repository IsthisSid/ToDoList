//
//  ViewController.swift
//  ToDoList
//
//  Created by Sidany Walker on 11/4/20.
//

import UIKit
import CoreData

class ToDoListViewController: UITableViewController {
    
    var itemArray = [Item]()
    
    //using didSet to specify what happens when a variable gets set with a new value
    var selectedCategory : Category? {
        didSet{
            loadItems()
        }
    }
    
    //appdelegate is a class it is not an object so how do we do this? we need to get the object of appdelegate. Use Singleton. Tap into UIApplication.shared and this is a singleton APP instance. In this shared UIApplication object there is something called delegate and this is the delegate object of the APPdelegate -- downcast using as! and now we have access to our appdelegate as an object:
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        //prints out the filepath to our debug to locate our SQLite file in which we open with a SQLite app. Open it to view items you added to our todolist app. This is our persistentContainer.
   
    }

//MARK: - Tableview Datasource Methods
    
//first data source to add is the number of rows
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
        
    }
    
//second data source delegate method is cellForRow that figures out how we should display each of the cells:
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //Use the indentifier we used for 'Prototype Cells' in Main.storyboard which in this case was 'ToDoItemCell':
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        let item = itemArray[indexPath.row]
        
        cell.textLabel?.text = item.title
        
        cell.accessoryType = item.done ? .checkmark : .none

        return cell
    }
    
//Now we want to be able to select these cells (have it printed in the debug counsel) and then be able to give it a check mark everytime each cell is clicked on and uncheck it when clicked again. We need some tableview delegate methods:
    
    
//MARK: - TableView Delegate Methods (the ones that gets fired whenever we click on any cell in the TableView)
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      
        //context.delete(itemArray[indexPath.row])
        //itemArray.remove(at: indexPath.row)
        
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        //toggles the done attribute to true or false
        
        saveItems()
        
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
            
            
            let newItem = Item(context: self.context)
            //The 'Item' table itself is a class. The table created is the 'Entity'. The properties in the table, the data in the table, i.e the columns, would be considered Attributes. Each row is 'NSManagedObject'. The context area is an intermediary area outside the persistentContainer, that you want to add/update/destroy. When you commit you 'try context.save()'
            newItem.title = textField.text!
            newItem.done = false
            newItem.parentCategory = self.selectedCategory
            self.itemArray.append(newItem)
            
            self.saveItems()
           
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
    //using context.save : how we can create, update, read and destroy data using context and how we can commit the current state of our context to our persistentcontainer

    func saveItems() {
        do {
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
        
        
        //this line of code below will populate those items added to the table:
        self.tableView.reloadData()
            }
    //with is ext param, request is intern parm, = Item.fetchRequest is default:
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
         
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)

        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }

        
        do {
        itemArray = try context.fetch(request)
            // the output for this method is going to be an array of items being stored in our persistent container, fetch it, then save into our itemArray
        } catch {
            print("Error fetching dat from context \(error)")
        }
        
        tableView.reloadData()
    }
    

    
}

//MARK: - Search bar methods

//code organization using extension
extension ToDoListViewController: UISearchBarDelegate {
    
    //query our database
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        //whatever we search from above fetch will be passed into this method and replaces that %@
        //check out NSPredicate cheat sheet online and see how the string is structured. Case and diacritic insensitive:
        
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        //the title should contain whatever is in the search bar
         
        
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        //the results should come back with the titles in ascending alphabetical order
         
        loadItems(with: request, predicate: predicate)

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
