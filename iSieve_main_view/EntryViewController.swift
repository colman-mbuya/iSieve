//
//  EntryViewController.swift
//  iSieve_main_view
//
//  Allows a user to enter a new password entry. Also Displays a selected entry and allows a user to edit it
//
//  Created by Marty Mcfly on 13/09/2016.
//  Copyright © 2016 Marty Mcfly. All rights reserved.
//

import UIKit
import CoreData

class EntryViewController: UIViewController {
    
    //Constants declared in the storyboard for this view
    private struct Storyboard {
        static let viewEntriesSegue = "viewEntriesSegue"
    }
    
    private var managedObjectContext: NSManagedObjectContext = ((UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext)!
    
    private var entryTitle = "", entryUsername = "", entryURL = "", entryPassword = ""
    
    //The password entry to display. This is set in the segue prep to this VC
    var entryToDisplay: String? = ""
    
    //The sessionID; to be set after successful authentication. Currently this will be the username
    var sessionID: String {
        get {
            if let returnValue = NSUserDefaults.standardUserDefaults().objectForKey("sessionID") as? String {
                return returnValue
            } else {
                return "Invalid Session" //Default value
            }
        }
        set {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: "sessionID")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }

    //MARK: - Storyboard outlets
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: HideShowPasswordTextField!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    //MARK: - VC Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EntryViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EntryViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        setupPasswordTextField()
        updateFields()
    }
    
    override func viewDidLayoutSubviews() {
        customiseTextFields(titleTextField)
        customiseTextFields(urlTextField)
        customiseTextFields(usernameTextField)
        customiseTextFields(passwordTextField)
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    //MARK: - Button Tapped Methods
    //Stores a new or modifies an existing password entry and segues to allentryvc
    @IBAction func OKBtnTapped(sender: UIButton) {
        entryTitle = titleTextField.text ?? ""
        entryUsername = usernameTextField.text ?? ""
        entryURL = urlTextField.text ?? ""
        entryPassword = passwordTextField.text ?? ""
        
        //Store/modify entry in core data. Probably need to move this to a logic (model) class ..
        managedObjectContext.performBlock {
            //New entry
            if self.entryToDisplay == "New Entry" {
                PasswordEntries.insertNewPasswordEntry(self.sessionID, username: self.entryUsername, password: self.entryPassword, title: self.entryTitle, url: self.entryURL, inManagedObjectContext: self.managedObjectContext)
                do{
                    try self.managedObjectContext.save()
                } catch let error {
                    print("Core Data Error: \(error)")
                }
            }
            else { //Modifying existing entry
                PasswordEntries.modifyPasswordEntry(self.entryToDisplay!, user: self.sessionID, username: self.entryUsername, password: self.entryPassword, title: self.entryTitle, url: self.entryURL, inManagedObjectContext: self.managedObjectContext)
                do{
                    try self.managedObjectContext.save()
                } catch let error {
                    print("Core Data Error: \(error)")
                }
            }
        }

        //Segue to allentryvc
        performSegueWithIdentifier(Storyboard.viewEntriesSegue, sender: "OKBtnTapped")
    }

    
    @IBAction func CancelBtnTapped(sender: UIButton) {
        performSegueWithIdentifier(Storyboard.viewEntriesSegue, sender: "CnlBtnTapped")
    }

    //I cant remember what this function was for....
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Storyboard.viewEntriesSegue {
            if let allentriesvc = segue.destinationViewController.contentViewController as? AllEntriesTableViewController{
                allentriesvc.sessionID = sessionID
            }
        }
    }
   
}

// MARK: UITextFieldDelegate
extension EntryViewController: UITextFieldDelegate {
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, textField string: String) -> Bool {
        return passwordTextField.textField(textField, shouldChangeCharactersInRange: range, replacementString: string)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        passwordTextField.textFieldDidEndEditing(textField)
    }
}

// MARK: HideShowPasswordTextFieldDelegate
// Implementing this delegate is entirely optional.
// It's useful when you want to show the user that their password is valid.
extension EntryViewController: HideShowPasswordTextFieldDelegate {
    func isValidPassword(password: String) -> Bool {
        return true
    }
}

// MARK: Private helper functions
extension EntryViewController {
    private func setupPasswordTextField() {
        passwordTextField.passwordDelegate = self
        passwordTextField.delegate = self
        /*PasswordTextField.borderStyle = .None
         PasswordTextField.clearButtonMode = .WhileEditing
         PasswordTextField.layer.borderWidth = 0.5
         PasswordTextField.layer.borderColor = UIColor(red: 220/255.0, green: 220/255.0, blue: 220/255.0, alpha: 1.0).CGColor
         PasswordTextField.borderStyle = UITextBorderStyle.None
         PasswordTextField.clipsToBounds = true
         PasswordTextField.layer.cornerRadius = 0
         
         PasswordTextField.rightView?.tintColor = UIColor(red: 0.204, green: 0.624, blue: 0.847, alpha: 1)
         
         
         // left view hack to add padding
         PasswordTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 3))
         PasswordTextField.leftViewMode = .Always*/
    }
}

// keyboard functions
extension EntryViewController {
    func keyboardWillShow(notification:NSNotification) {
        adjustingHeight(true, notification: notification, bottomConstraint: bottomConstraint)
    }
    
    func keyboardWillHide(notification:NSNotification) {
        adjustingHeight(false, notification: notification, bottomConstraint: bottomConstraint)
    }
}

// Private helper function to setup and populate the fields in the view
extension EntryViewController {
    private func updateFields() {
        if entryToDisplay != "New Entry" {
            topLabel.text = "View/Modify Entry"
            managedObjectContext.performBlockAndWait {
                if let passwordEntry = PasswordEntries.getPasswordEntry(self.entryToDisplay!, inManagedObjectContext: self.managedObjectContext) {
                    self.titleTextField.text = passwordEntry.title
                    self.urlTextField.text = passwordEntry.url
                    self.usernameTextField.text = passwordEntry.username
                    self.passwordTextField.text = passwordEntry.password
                }
            }
        }
        else {
            topLabel.text = "New Entry"
        }
    }
}




