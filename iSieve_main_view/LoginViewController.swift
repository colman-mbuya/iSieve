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
        static let UsernameTextFieldPlaceholder = "Username"
        static let PasswordTextFieldPlaceholder = "Password"
    }
    @IBOutlet weak var UsernameTextField: UITextField!
    @IBOutlet weak var PasswordTextField: HideShowPasswordTextField!
    @IBOutlet weak var BottomConstraint: NSLayoutConstraint!
    //@IBOutlet weak var TouchIDButton: UIButton!
  
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

        UsernameTextField.delegate = self
        if sessionID.characters.count > 0{
            UsernameTextField.text = sessionID
        }
        addIconsToTextFields(UsernameTextField)
        addIconsToTextFields(PasswordTextField)
        //setupTouchIDButton()
        setupPasswordTextField()
    }
    
    override func viewDidLayoutSubviews() {
        customiseTextFields(UsernameTextField)
        customiseTextFields(PasswordTextField)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func keyboardWillShow(notification:NSNotification) {
        adjustingHeight(true, notification: notification, bottomConstraint: BottomConstraint)
    }
    
    func keyboardWillHide(notification:NSNotification) {
        adjustingHeight(false, notification: notification, bottomConstraint: BottomConstraint)
    }
    
    /*private func setupTouchIDButton() {
        let size = CGSize(width: 40, height: 40)
        var resizedImage: UIImage = UIImage(named: "ItunesArtwork.png")!
        if let image = UIImage(named: "ItunesArtwork.png") {
            resizedImage = imageWithImage(image, scaledToSize: size)
        }
        
        TouchIDButton.setImage(resizedImage, forState: UIControlState.Normal)
    }*/
    
    private func imageWithImage(image:UIImage, scaledToSize newSize:CGSize) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        image.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    private func addIconsToTextFields(textField: UITextField) {
        let imageView = UIImageView();
        var image: UIImage
        if textField.placeholder == Storyboard.UsernameTextFieldPlaceholder {
            image = UIImage(named: "usernameIcon.png")!
        }
        else {
            image = UIImage(named: "passwordIcon.png")!
        }
        
        imageView.image = image;
        
        let leftView = UIView()
        leftView.addSubview(imageView)
        
        leftView.frame = CGRect(x: 0, y: 0, width: 30, height: 40)
        imageView.frame = CGRect(x: 0, y: 10, width: 20, height: 20)

        //view.addSubview(leftView)
        textField.leftViewMode = UITextFieldViewMode.Always
        textField.leftView = leftView;
        
    }
    
    @IBAction func ButtonTouched(sender: UIButton) {
        let Username = UsernameTextField.text
        let Password = PasswordTextField.text
        
        if Username!.isEmpty || Password!.isEmpty {
            let alert = UIAlertController(title: "Alert", message: "Enter a username and/or password", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            //StatusLabel.textColor = UIColor.orangeColor()
            //StatusLabel.text = "Enter a username and/or password"
        }
        else {
            //StatusLabel.textColor = UIColor.orangeColor()
            if sender.currentTitle == "Login" {
                //Once web services are implemented, spinner will probably be activated here
                if !loginLogic.Login(Username!, password: Password!) {
                    let alert = UIAlertController(title: "Alert", message: "Username/Password Incorrect", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                    //StatusLabel.text = "Username/Password Incorrect"
                }
                else{
                    
                    sessionID = Username!
                    performSegueWithIdentifier(Storyboard.LoginRegisteredSegue, sender: sessionID)
                }
            }
            else if sender.currentTitle == "Register" {
                //Once web services are implemented, spinner will probably be activated here
                if !loginLogic.Register(Username!, password: Password!) {
                    let alert = UIAlertController(title: "Alert", message: "Username already exists", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                    //StatusLabel.text = ""
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


