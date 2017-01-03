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
    @IBOutlet weak var Bottom_Constraint: NSLayoutConstraint!


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
    
    func keyboardWillShow(notification:NSNotification) {
        adjustingHeight(true, notification: notification)
    }
    
    func keyboardWillHide(notification:NSNotification) {
        adjustingHeight(false, notification: notification)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)

        updateFields()
    }
    
    override func viewDidLayoutSubviews() {
        customiseTextFields(Entry_Title)
        customiseTextFields(Entry_URL)
        customiseTextFields(Entry_Username)
        customiseTextFields(Entry_Password)
        customiseTextFields(Entry_Repeat)
    }
    
    private func customiseTextFields(textField: UITextField) {
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderWidth = width
        border.borderColor = UIColor.orangeColor().CGColor
        
        border.frame = CGRect(x: 0, y: textField.frame.size.height - width, width:  textField.frame.size.width, height: textField.frame.size.height)
        
        textField.borderStyle = UITextBorderStyle.None
        textField.layer.addSublayer(border)
        textField.layer.masksToBounds = true

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }

    func adjustingHeight(show:Bool, notification:NSNotification) {
        // 1
        var userInfo = notification.userInfo!
        // 2
        let keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
        // 3
        let animationDurarion = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSTimeInterval
        // 4
        let changeInHeight = (CGRectGetHeight(keyboardFrame) + 40) * (show ? 1 : -1)
        //5
        UIView.animateWithDuration(animationDurarion, animations: { () -> Void in
            self.Bottom_Constraint.constant += changeInHeight
        })
        
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
