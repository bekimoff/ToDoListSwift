//
//  ToDoItem.swift
//  ToDoListApp
//
//  Created by Bethany Ekimoff on 6/17/15.
//  Copyright (c) 2015 Bethany Ekimoff. All rights reserved.
//

import Foundation
import CoreData

@objc(ToDoItem)class ToDoItem: NSManagedObject {

    @NSManaged var itemName: String
    var name: String {
        get {
            return itemName
        }
        set {
            itemName = newValue
        }
    }
    @NSManaged var creationDate: NSDate
    @NSManaged var completed: NSNumber
    var isCompleted: Bool {
        get {
            return Bool(completed)
        }
        set {
            completed = NSNumber(bool: newValue)
        }
    }
    
    class func createInManagedObjectContext(moc: NSManagedObjectContext, name: String) -> ToDoItem {
        let newItem = NSEntityDescription.insertNewObjectForEntityForName("ToDoItem", inManagedObjectContext: moc) as! ToDoItem
        newItem.itemName = name
        newItem.completed = 0
        
        return newItem
    }
    
}
