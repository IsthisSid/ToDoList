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
    
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")

    //appdelegate is a class it is not an object so how do we do this? we need to get the object of appdelegate. Use Singleton. Tap into UIApplication.shared and this is a singleton APP instance. In this shared UIApplication object there is something called delegate and this is the delegate object of the APPdelegate -- downcast using as! and now we have access to our appdelegate as an object:
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        loadItems()
   
    }

//Mark - Tableview Datasource Methods
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
    
    
//Mark - TableView Delegate Methods (the ones that gets fired whenever we click on any cell in the TableView)
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done

        saveItems() //called when we toggle the checkmark so that's why the above line of code is commented out
        
        tableView.deselectRow(at: indexPath, animated: true)
        // flashes grey briefly and looks nicer when selecting an item instead of staying grey
    }
    
    
//Mark - Add New Items
 //go to Main.storyboard and add a bar button item' then link IBAction here:
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New ToDo Item", message: "", preferredStyle: .alert) //the .alert is default
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            //what will happen once the user clicks the add item button on our UIalert
            
            
            let newItem = Item(context: self.context)
            newItem.title = textField.text!
            newItem.done = false
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
    
    
 //Mark - Model Manipulation Methods
    
    func saveItems() {
      
        do {
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
        
        
        //this line of code below will populate those items added to the table:
        self.tableView.reloadData()
            }
    
//    func loadItems() {
//        if let data = try? Data(contentsOf: dataFilePath!) {
//            let decoder = PropertyListDecoder()
//            do {
//                itemArray = try decoder.decode([Item].self, from: data)
//            } catch {
//                print("Error decoding item array, \(error)")
//            }
//        }
//    }
}

