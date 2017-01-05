//
//  ViewController.swift
//  Practice1LoginPage
//
//  Created by Marty Mcfly on 25/08/2016.
//  Copyright © 2016 Marty Mcfly. All rights reserved.
//

import UIKit
import CoreData

class LoginViewController: UIViewController {

    private struct Storyboard {
        static let LoginRegisteredSegue = "login_register"
    }
    @IBOutlet weak var UsernameTextField: UITextField!
    @IBOutlet weak var StatusLabel: UILabel!
    @IBOutlet weak var PasswordTextField: HideShowPasswordTextField!
  
    private var loginLogic = LoginLogic(moc: ((UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext)!)
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if sessionID.characters.count > 0{
            UsernameTextField.text = sessionID
        }
        setupPasswordTextField()
    }
    
    override func viewDidLayoutSubviews() {
        customiseTextFields(UsernameTextField)
        customiseTextFields(PasswordTextField)
    }
    
    @IBAction func ButtonTouched(sender: UIButton) {
        let Username = UsernameTextField.text
        let Password = PasswordTextField.text
        
        if Username!.isEmpty || Password!.isEmpty {
            StatusLabel.textColor = UIColor.orangeColor()
            StatusLabel.text = "Enter a username and/or password"
        }
        else {
            StatusLabel.textColor = UIColor.orangeColor()
            if sender.currentTitle == "Login" {
                //Once web services are implemented, spinner will probably be activated here
                if !loginLogic.Login(Username!, password: Password!) {
                    StatusLabel.text = "Username/Password Incorrect"
                }
                else{
                    
                    sessionID = Username!
                    performSegueWithIdentifier(Storyboard.LoginRegisteredSegue, sender: sessionID)
                }
            }
            else if sender.currentTitle == "Register" {
                //Once web services are implemented, spinner will probably be activated here
                if !loginLogic.Register(Username!, password: Password!) {
                    StatusLabel.text = "Username already exists"
                }
                else{
                    //Create Account here
                    sessionID = Username!
                    performSegueWithIdentifier(Storyboard.LoginRegisteredSegue, sender: sessionID)
                }
            }
        }
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        /*print("\(segue.identifier)")
        if segue.identifier == Storyboard.LoginRegisteredSegue {
            if let allentryvc = segue.destinationViewController.contentViewController as? AllEntriesTableViewController {
                if let sessionID = sender as? String {
                    print ("here \(sessionID)")
                    allentryvc.sessionID = sessionID ?? "Error"
                }
            }
        }*/
        
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
}

extension UIViewController {
    var contentViewController: UIViewController {
        if let navcon = self as? UINavigationController {
            return navcon.visibleViewController ?? self
        } else {
            return self
        }
    }
}

// MARK: UITextFieldDelegate
extension LoginViewController: UITextFieldDelegate {
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, textField string: String) -> Bool {
        return PasswordTextField.textField(textField, shouldChangeCharactersInRange: range, replacementString: string)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        PasswordTextField.textFieldDidEndEditing(textField)
    }
}

// MARK: HideShowPasswordTextFieldDelegate
// Implementing this delegate is entirely optional.
// It's useful when you want to show the user that their password is valid.
extension LoginViewController: HideShowPasswordTextFieldDelegate {
    func isValidPassword(password: String) -> Bool {
        return password.characters.count > 7
    }
}

// MARK: Private helpers
extension LoginViewController {
    private func setupPasswordTextField() {
        PasswordTextField.passwordDelegate = self
        PasswordTextField.delegate = self
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
    public func customiseTextFields(textField: UITextField) {
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderWidth = width
        border.borderColor = UIColor.orangeColor().CGColor
        
        border.frame = CGRect(x: 0, y: textField.frame.size.height - width, width:  textField.frame.size.width, height: textField.frame.size.height)
        
        textField.borderStyle = UITextBorderStyle.None
        textField.layer.addSublayer(border)
        textField.layer.masksToBounds = true
    }
}


