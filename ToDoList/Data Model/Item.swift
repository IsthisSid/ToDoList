//
//  Item.swift
//  ToDoList
//
//  Created by Sidany Walker on 11/7/20.
//

import Foundation
import RealmSwift

class Item: Object {

    @objc dynamic var title : String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var dateCreated: Date?
    
    //our inverse relationship of 'Items':
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
    
}
