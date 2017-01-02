//
//  EntryViewController.swift
//  iSieve_main_view
//
//  Created by Marty Mcfly on 13/09/2016.
//  Copyright © 2016 Marty Mcfly. All rights reserved.
//

import UIKit
import CoreData

class EntryViewController: UIViewController {
    
    
    private struct Storyboard {
        static let ViewEntriesSegue = "viewEntriesSegue"
    }
    
    var ManagedObjectContext: NSManagedObjectContext = ((UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext)!
    
    private var EntryTitle = "", Username = "", URL = "", Password = ""
    var entryToDisplay: String? = ""
    var sessionID: String? = ""
    
    @IBOutlet weak var Entry_Title: UITextField!
    @IBOutlet weak var Entry_Username: UITextField!
    @IBOutlet weak var Entry_URL: UITextField!
    @IBOutlet weak var Entry_Password: UITextField!
    @IBOutlet weak var Entry_Repeat: UITextField!
    @IBOutlet weak var TopLabel: UILabel!

    @IBAction func OKBtnTapped(sender: UIButton) {
        EntryTitle = Entry_Title.text ?? ""
        Username = Entry_Username.text ?? ""
        URL = Entry_URL.text ?? ""
        let pwd = Entry_Password.text ?? ""
        let rpt = Entry_Repeat.text ?? ""
        if pwd == rpt {
            Password = pwd
        }
        // To do: Need to fix this to display some sort of error on non matching password
        else{
            Password = ""
        }
        
        print(EntryTitle)
        print(Username)
        print(URL)
        print(Password)
        
        //Store user details here. Probably need to move this to a model class #SpaghettiCode..
        ManagedObjectContext.performBlock {
        PasswordEntries.insertNewPasswordEntry(self.sessionID!, username: self.Username, password: self.Password, title: self.EntryTitle, url: self.URL, inManagedObjectContext: self.ManagedObjectContext)
            do{
                try self.ManagedObjectContext.save()
            } catch let error {
                print("Core Data Error: \(error)")
            }
        }

        
        performSegueWithIdentifier(Storyboard.ViewEntriesSegue, sender: "OKBtnTapped")
    }

    
    @IBAction func CancelBtnTapped(sender: UIButton) {
        performSegueWithIdentifier(Storyboard.ViewEntriesSegue, sender: "CnlBtnTapped")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        updateFields()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func updateFields() {
        if entryToDisplay != "New Entry" {
            TopLabel.text = "View/Modify Entry"
            ManagedObjectContext.performBlockAndWait {
                if let passwordEntry = PasswordEntries.getPasswordEntry(self.entryToDisplay!, inManagedObjectContext: self.ManagedObjectContext) {
                    self.Entry_Title.text = passwordEntry.title
                    self.Entry_URL.text = passwordEntry.url
                    self.Entry_Username.text = passwordEntry.username
                    self.Entry_Password.text = passwordEntry.password
                    self.Entry_Repeat.text = passwordEntry.password
                }
            }
        }
        else {
            TopLabel.text = "New Entry"
        }
    }

    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Storyboard.ViewEntriesSegue {
            let destinationvc = segue.destinationViewController
            if let allentriesvc = destinationvc as? AllEntriesTableViewController{
                allentriesvc.sessionID = sessionID!
            }
        }
    }
   
}
