//
//  TableViewController.swift
//  MyApp
//
//  Created by Bethany Ekimoff on 6/17/15.
//  Copyright (c) 2015 Bethany Ekimoff. All rights reserved.
//

import UIKit
import CoreData
import LocalAuthentication



@objc(ToDoListTableViewController) class ToDoListTableViewController: UITableViewController {

    @IBAction func unwindToList(segue:UIStoryboardSegue){
        var source: AddToDoViewController = segue.sourceViewController as! AddToDoViewController
        fetchLog()
        save()
        self.tableView.reloadData()
        
    }
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var toDoItems: NSMutableArray = []
    var items = [ToDoItem]()
   
    
    override func viewDidLoad(){
        fetchLog()
        if(items.count==0){
            loadInitialData()
        }
        super.viewDidLoad()
        authenticateUser()
    }
    
    @IBAction func logout(sender : UIBarButtonItem) {
        
        authenticateUser()

    }
    
    func loadInitialData(){
        
        if let moc = self.managedObjectContext {

            var items = [
                ("Buy Milk"),
                ("Feed Cats"),
                ("Make Dinner")
            ]
        
            for item in items {
                // Create an individual item
                ToDoItem.createInManagedObjectContext(moc, name: item)
            }
        }
        
        fetchLog()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.toDoItems.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let CellIndentifier: NSString = "ListPrototypeCell"
        
        var cell : UITableViewCell = tableView.dequeueReusableCellWithIdentifier(CellIndentifier as String) as! UITableViewCell
        
        var todoitem: ToDoItem = self.toDoItems.objectAtIndex(indexPath.row) as! ToDoItem
        
        cell.textLabel?.text = todoitem.itemName as String
        
        if todoitem.isCompleted{
            
            cell.accessoryType = .Checkmark
            
        }
            
        else{
            
            cell.accessoryType = .None
            
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
        var tappedItem: ToDoItem = self.toDoItems.objectAtIndex(indexPath.row) as! ToDoItem
        tappedItem.isCompleted = !tappedItem.isCompleted
        tableView.reloadData()
        
        let itemToUpdate = items[indexPath.row]
        itemToUpdate.setValue(tappedItem.isCompleted, forKey: "completed")
        save()

    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            // Find the LogItem object the user is trying to delete
            let itemToDelete = items[indexPath.row]
            
            // Delete it from the managedObjectContext
            managedObjectContext?.deleteObject(itemToDelete)
            
            // Refresh the table view to indicate that it's deleted
            self.fetchLog()
            
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            
            save()
        }
    }
    
    func save() {
        var error : NSError?
        if(managedObjectContext!.save(&error) ) {
            println(error?.localizedDescription)
        }
    }
    
    func fetchLog() {
        let fetchRequest = NSFetchRequest(entityName: "ToDoItem")
        
        // Create a sort descriptor object that sorts on the "title"
        // property of the Core Data object
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
        
        // Set the list of sort descriptors in the fetch request,
        // so it includes the sort descriptor
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [ToDoItem] {
            items = fetchResults
        }
        
        self.toDoItems = NSMutableArray(array:items)
    }
    
    func login(password: String) {
        if password == "password" {
            self.fetchLog()
        } else {
            self.showPasswordAlert()
        }
    }
    
    func showPasswordAlert() {
        let alertController : UIAlertController = UIAlertController(title:"TouchID Not Found" , message: "Please enter password", preferredStyle: .Alert)
        
        let doneAction : UIAlertAction = UIAlertAction(title: "Done", style: .Default) { (action) -> Void in
            let passwordTextField = alertController.textFields![0] as! UITextField
            self.login(passwordTextField.text)
        }
        doneAction.enabled = false
        
        alertController.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "Password"
            textField.secureTextEntry = true
            
            NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: textField, queue: NSOperationQueue.mainQueue(), usingBlock: { (notification) -> Void in
                doneAction.enabled = textField.text != ""
            })
        }
        
        alertController.addAction(doneAction)
        self.presentViewController(alertController, animated: true) {
            // Nothing to do here
        }

    }

    
    func authenticateUser() {
        let context : LAContext = LAContext()
        
        var error : NSError?
        var myLocalizedReasonString : NSString = "Authentication is required"
        
        if context.canEvaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, localizedReason: myLocalizedReasonString as String, reply: { (success : Bool, evaluationError : NSError?) -> Void in
                if success {
                    NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                        self.fetchLog()
                    })
                }
                else {
                    // Authentification failed
                    println(evaluationError?.localizedDescription)
                    
                    switch evaluationError!.code {
                    case LAError.SystemCancel.rawValue:
                        println("Authentication cancelled by the system")
                    case LAError.UserCancel.rawValue:
                        println("Authentication cancelled by the user")
                    case LAError.UserFallback.rawValue:
                        println("User wants to use a password")
                        // We show the alert view in the main thread (always update the UI in the main thread)
                        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                            self.showPasswordAlert()
                        })
                    default:
                        println("Authentication failed")
                        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                            self.showPasswordAlert()
                        })
                    }
                }
            })
        }
        else {
            switch error!.code {
            case LAError.TouchIDNotEnrolled.rawValue:
                println("TouchID not enrolled")
            case LAError.PasscodeNotSet.rawValue:
                println("Passcode not set")
            default:
                println("TouchID not available")
            }
            self.showPasswordAlert()
        }

    }

}









