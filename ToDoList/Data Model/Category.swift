//
//  Category.swift
//  ToDoList
//
//  Created by Sidany Walker on 11/7/20.
//

import Foundation
import RealmSwift

class Category: Object {
    //dynamic is what's called a declaration modifier, it tells the runtime to use the dynamic dispatch over the standard which is a static dispatch and this allows the property name to be monitored for change for runtime while your app is running. That means if the user changes the value of name i.e while the app is running, that allows realm to dynamically update those changes in the database. (Obj C language)
    
    @objc dynamic var name: String = ""
    @objc dynamic var color: String = ""
    //constant 'items' is going to hold a list of item objects and initialize it as an empty list (the forward relationship):
    let items = List<Item>()
    
    
}
