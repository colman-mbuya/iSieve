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
    @IBOutlet weak var PasswordTextField: UITextField!
    @IBOutlet weak var StatusLabel: UILabel!
  
    private var loginLogic = LoginLogic(moc: ((UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext)!)
    
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
                    let Session = Username
                    performSegueWithIdentifier(Storyboard.LoginRegisteredSegue, sender: Session)
                }
            }
            else if sender.currentTitle == "Register" {
                //Once web services are implemented, spinner will probably be activated here
                if !loginLogic.Register(Username!, password: Password!) {
                    StatusLabel.text = "Username already exists"
                }
                else{
                    //Create Account here
                    let Session = Username
                    performSegueWithIdentifier(Storyboard.LoginRegisteredSegue, sender: Session)
                }
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print("\(segue.identifier)")
        if segue.identifier == Storyboard.LoginRegisteredSegue {
            if let allentryvc = segue.destinationViewController.contentViewController as? AllEntriesTableViewController {
                if let sessionID = sender as? String {
                    print ("here \(sessionID)")
                    allentryvc.sessionID = sessionID ?? "Error"
                }
            }
        }
        
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

