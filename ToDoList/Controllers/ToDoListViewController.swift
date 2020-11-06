//
//  ViewController.swift
//  ToDoList
//
//  Created by Sidany Walker on 11/4/20.
//

import UIKit

class ToDoListViewController: UITableViewController {
//remember to change the superclass to UITableViewController since that is what we are using in our Main.storyboard
    
    var itemArray = [Item]()
    //the Array that will contain the content for our cells (from the 'class Item' created) when displayed (note this is var not let (changing it from being immutable to mutable) because we will be appending items to this array

    //We use NSCoder to encode and decode our data to a prespecified filepath and our code converted our array of items into a .plist file where we can save and retrieve from:
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    
    //data persistance using UserDefaults:
    //let defaults = UserDefaults.standard // commenting out because we are using Items.plist instead
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadItems()
//  print(dataFilePath) // commented out for now but we would use this to retrieve the filepath on debug

//remember this is a hard key so make sure it's correctly typed and that it exists in our info.plist(review sandbox)// otherwise, to prevent crash, we can just write an if let and make optional:
//        if let items = defaults.array(forKey: "ToDoListArray") as? [Item] {
//           itemArray = items
//      } // commented out because we are using NSCoder
   
    }

//Mark - Tableview Datasource Methods
//first data source to add is the number of rows
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
        //that will create three cells for us in the tableview see array above
        
    }
    
//second data source delegate method is cellForRow that figures out how we should display each of the cells:
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //Use the indentifier we used for 'Prototype Cells' in Main.storyboard which in this case was 'ToDoItemCell':
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        let item = itemArray[indexPath.row]
        
        //Set the textlabel that will be in every single cell and we are going to set its text property. We will set it to equal the items in our itemarray at the indexpath that we are currently populating.row(so the current row of the current index path):
        cell.textLabel?.text = item.title// .title here because we created the new class Item
        
        //Use the ternary operator to have a more elegant line of code: value = condition ? valueIfTrue : valueIfFalse
        cell.accessoryType = item.done ? .checkmark : .none
        // this line of code reads "set the cell's accessoryType depending on whether the item.done is true. if it is true, set it to item .checkmark and if it is not true set it to .none
        
//the ternary operator is more elegant than this if/else statement below that does the same thing:
//        if item.done == true {
//            cell.accessoryType = .checkmark
//        } else {
//            cell.accessoryType = .none
//        }
        
        //This cellForRow method expects an output so 'return cell'. Now that cell that's been created using our reuse prototype cell and that has been populated with text for the current row is now returned to the table view and displayed as a row:
        return cell
    }
    
//Now we want to be able to select these cells (have it printed in the debug counsel) and then be able to give it a check mark everytime each cell is clicked on and uncheck it when clicked again. We need some tableview delegate methods:
    
    
//Mark - TableView Delegate Methods (the ones that gets fired whenever we click on any cell in the TableView)
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print(itemArray[indexPath.row]) // prints the item in the array into the debug whenever we select a cell
        
        //sorts out the toggling(sets out our done properties):
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
// the above line of code is more elegant (because we are using the '!' naught operator) than the if/else below / left it here for reference
//        if itemArray[indexPath.row].done == false {
//            itemArray[indexPath.row].done = true
//        } else {
//            itemArray[indexPath.row].done = false
//        }

        //now go to main.storyboard and go to 'accessory' in attribute inspector and select 'checkmark' just to give you an idea, but for now, set it back to none so it doesn't appear on default. Here's the code:
        //tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark

        //but now we need an if statement otherwise they all appeared check: (update: we removed the lines of code below here because we have set new rules for the checkmark shown above)
//        if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
//            tableView.cellForRow(at: indexPath)?.accessoryType = .none
//        } else {
//            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
//        }
        
        //forces the tableview to call its datasource methods again so that it reloads the data that's meant to be inside:
        //tableView.reloadData()
        saveItems() //called when we toggle the checkmark so that's why the above line of code is commented out
        
        tableView.deselectRow(at: indexPath, animated: true) // flashes grey briefly and looks nicer when selecting an item instead of staying grey
    }
    
    
//Mark - Add New Items
 //go to Main.storyboard and add a bar button item' then link IBAction here:
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
    //For a popup/UI alert to show when addbutton is pressed and have a textfield in the alert so that we can write in a to do list item and append it to the end of our item array:
        
        //this var textfield has the entire scope of the IBAction func addButtonPressed:
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New ToDo Item", message: "", preferredStyle: .alert) //the .alert is default
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            //what will happen once the user clicks the add item button on our UIalert
            
            let newItem = Item()
            newItem.title = textField.text!
            
            //because we are inside a closure, the 'in' keyword, we have to specify self to tell the compiler explicitly where this itemarray exists in the current class:
            self.itemArray.append(newItem)// instead of using .append(textField.text!) b/c we created that new class Item
            
            //force unwrap(!) b/c the text property of a text field is never going to equal nil even if it's empty it's going to be set to an empty string
            
            self.saveItems() //called when we add an item using the alert controller
           
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
        //don't use userdefaults for big pieces of data, we have better tools, such as NSCoder. Print filepath, go to that plist we created and we can see that our Encoder has encoded our properties into a dictionary and the individual properties still conform to all the basic datatypes:
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(itemArray)
            try data.write(to: dataFilePath!)
        } catch {
            print("Error encoding item array, \(error)")
        }
        
        
        //save the updated item array to our user defaults with this line of code:
        //self.defaults.set(self.itemArray, forKey: "ToDoListArray")
        //you always need a key to retrieve the item then you can add a datatype anywhere and grab it with this key
        
        //this line of code below will populate those items added to the table:
        self.tableView.reloadData()
            }
    
    func loadItems() {
        if let data = try? Data(contentsOf: dataFilePath!) {
            let decoder = PropertyListDecoder()
            do {
                itemArray = try decoder.decode([Item].self, from: data)
            } catch {
                print("Error decoding item array, \(error)")
            }
        }
    }
}

