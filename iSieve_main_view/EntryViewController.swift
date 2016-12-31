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
        PasswordEntries.insertNewPasswordEntry("tester123", username: self.Username, password: self.Password, title: self.EntryTitle, url: self.URL, inManagedObjectContext: self.ManagedObjectContext)
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

    
    
    var entryToDisplay = "Test" {
        didSet {
            updateTitle()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        updateTitle()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func updateTitle() {
        if Entry_Title != nil{
            Entry_Title.text = entryToDisplay
        }
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
    }
   
}
