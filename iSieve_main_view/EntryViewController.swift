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
    @IBOutlet weak var Entry_Password: HideShowPasswordTextField!
    @IBOutlet weak var TopLabel: UILabel!
    @IBOutlet weak var Bottom_Constraint: NSLayoutConstraint!
    


    @IBAction func OKBtnTapped(sender: UIButton) {
        EntryTitle = Entry_Title.text ?? ""
        Username = Entry_Username.text ?? ""
        URL = Entry_URL.text ?? ""
        Password = Entry_Password.text ?? ""
        
        //Store user details here. Probably need to move this to a model class #SpaghettiCode..
        ManagedObjectContext.performBlock {
            if self.entryToDisplay == "New Entry" {
                PasswordEntries.insertNewPasswordEntry(self.sessionID!, username: self.Username, password: self.Password, title: self.EntryTitle, url: self.URL, inManagedObjectContext: self.ManagedObjectContext)
                do{
                    try self.ManagedObjectContext.save()
                } catch let error {
                    print("Core Data Error: \(error)")
                }
            }
            else {
                PasswordEntries.modifyPasswordEntry(self.entryToDisplay!, user: self.sessionID!, username: self.Username, password: self.Password, title: self.EntryTitle, url: self.URL, inManagedObjectContext: self.ManagedObjectContext)
                do{
                    try self.ManagedObjectContext.save()
                } catch let error {
                    print("Core Data Error: \(error)")
                }
            }
        }

        
        performSegueWithIdentifier(Storyboard.ViewEntriesSegue, sender: "OKBtnTapped")
    }

    
    @IBAction func CancelBtnTapped(sender: UIButton) {
        performSegueWithIdentifier(Storyboard.ViewEntriesSegue, sender: "CnlBtnTapped")
    }
    
    func keyboardWillShow(notification:NSNotification) {
        adjustingHeight(true, notification: notification, bottomConstraint: Bottom_Constraint)
    }
    
    func keyboardWillHide(notification:NSNotification) {
        adjustingHeight(false, notification: notification, bottomConstraint: Bottom_Constraint)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EntryViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EntryViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        setupPasswordTextField()
        updateFields()
    }
    
    override func viewDidLayoutSubviews() {
        customiseTextFields(Entry_Title)
        customiseTextFields(Entry_URL)
        customiseTextFields(Entry_Username)
        customiseTextFields(Entry_Password)
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
    
    private func updateFields() {
        if entryToDisplay != "New Entry" {
            TopLabel.text = "View/Modify Entry"
            ManagedObjectContext.performBlockAndWait {
                if let passwordEntry = PasswordEntries.getPasswordEntry(self.entryToDisplay!, inManagedObjectContext: self.ManagedObjectContext) {
                    self.Entry_Title.text = passwordEntry.title
                    self.Entry_URL.text = passwordEntry.url
                    self.Entry_Username.text = passwordEntry.username
                    self.Entry_Password.text = passwordEntry.password
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
            if let allentriesvc = segue.destinationViewController.contentViewController as? AllEntriesTableViewController{
                allentriesvc.sessionID = sessionID!
            }
        }
    }
   
}

// MARK: UITextFieldDelegate
extension EntryViewController: UITextFieldDelegate {
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, textField string: String) -> Bool {
        return Entry_Password.textField(textField, shouldChangeCharactersInRange: range, replacementString: string)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        Entry_Password.textFieldDidEndEditing(textField)
    }
}

// MARK: HideShowPasswordTextFieldDelegate
// Implementing this delegate is entirely optional.
// It's useful when you want to show the user that their password is valid.
extension EntryViewController: HideShowPasswordTextFieldDelegate {
    func isValidPassword(password: String) -> Bool {
        return password.characters.count > 7
    }
}

// MARK: Private helpers
extension EntryViewController {
    private func setupPasswordTextField() {
        Entry_Password.passwordDelegate = self
        Entry_Password.delegate = self
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

extension UIViewController {
    func adjustingHeight(show:Bool, notification:NSNotification, bottomConstraint:NSLayoutConstraint) {
        var userInfo = notification.userInfo!
        let keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
        let animationDurarion = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSTimeInterval
        let changeInHeight = (CGRectGetHeight(keyboardFrame) + 40) * (show ? 1 : -1)
        UIView.animateWithDuration(animationDurarion, animations: { () -> Void in
            bottomConstraint.constant += changeInHeight
        })
        
    }
}


