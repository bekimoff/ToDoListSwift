//
//  ViewController.swift
//  MyApp
//
//  Created by Bethany Ekimoff on 6/17/15.
//  Copyright (c) 2015 Bethany Ekimoff. All rights reserved.
//

import UIKit

class AddToDoViewController: UIViewController {
    
    var toDoItem: ToDoItem?
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

    @IBOutlet var textfield : UITextField!
    @IBOutlet var doneButton : UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if sender as? NSObject != self.doneButton{
            return
        }
        if !self.textfield.text.isEmpty{
            ToDoItem.createInManagedObjectContext(self.managedObjectContext!, name: self.textfield.text)
        }
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }


}

