//
//  ViewController.swift
//  Practice1LoginPage
//
//  Created by Marty Mcfly on 25/08/2016.
//  Copyright © 2016 Marty Mcfly. All rights reserved.
//

import UIKit
import CoreData
import LocalAuthentication

class LoginViewController: UIViewController {

    //Struct to define constants declared in the storyboard for this VC
    private struct Storyboard {
        static let loginRegisteredSegue = "login_register"
        static let usernameTextFieldPlaceholder = "Username"
        static let passwordTextFieldPlaceholder = "Password"
        static let loginButtonTitle = "Login"
        static let registerButtonTitle = "Register"
        static let touchIDButtonTag = 7
    }
    
    //Text Field Outlets
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: HideShowPasswordTextField!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint! // Had to delete this from the storyboard. Need to probably redo the constraints for this view at some point
    
    //Creating new LoginLogic object to authenticate/register users
    private var loginLogic = LoginLogic(moc: ((UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext)!)
    
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
    
    //MARK: VC Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()

        usernameTextField.delegate = self
        if sessionID.characters.count > 0 {
            usernameTextField.text = sessionID
        }
        addIconsToTextFields(usernameTextField) //Adding icons to the left
        addIconsToTextFields(passwordTextField) //of these fields
        setupPasswordTextField()                //Setup password text field with show & hide button
    }
    
    override func viewDidLayoutSubviews() {
        customiseTextFields(usernameTextField) //Show only the bottom border + other stylistic changes.
        customiseTextFields(passwordTextField) //This didn't work properly when I had it in viewDidLoad()
    }
    
    //Button Action method for the Login, register and TouchID buttons
    @IBAction func ButtonTouched(sender: UIButton) {
        let Username = usernameTextField.text
        let Password = passwordTextField.text
        var message: String = ""
        var title : String = ""
        
        //TouchID button tapped. TouchID login will only work if a valid (already registered) username has been entered.
        if sender.tag == Storyboard.touchIDButtonTag {
            if Username!.isEmpty {
                title = "Alert"
                message = "Enter a username"
                showPopupAlertMessage(title, message: message)
            }
            else {
                let context = LAContext();
                var error:NSError?
                let reason:String = "Please authenticate using TouchID.";
                
                if (context.canEvaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, error: &error))  
                {
                    context.evaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, localizedReason: reason, reply: { (success, error) -> Void in
                        if (success) {
                            if !self.loginLogic.verifyUsername(Username!) {
                                title = "Error"
                                message = "Incorrect username"
                                self.showPopupAlertMessage(title, message: message)
                            }
                            else{
                                self.sessionID = Username!
                                self.performSegueWithIdentifier(Storyboard.loginRegisteredSegue, sender: self.sessionID)
                            }
                        }
                        else    //TouchID failed
                        {
                            print("Error received: %d", error!);
                            switch error!.code {
                                case LAError.AuthenticationFailed.rawValue:
                                    message = "Authentication Failed"
                                case LAError.UserCancel.rawValue:
                                    message = ""
                                case LAError.SystemCancel.rawValue:
                                    message = "The system canceled!"
                                case LAError.UserFallback.rawValue:
                                    message = ""
                                default:
                                    message = "Something went wrong"
                            }
                            if !message.isEmpty{
                                title = "Error"
                                self.showPopupAlertMessage(title, message: message)
                            }

                        }
                    });
                }
                else {  //Device not able to do TouchID
                    switch error!.code {
                        case LAError.TouchIDNotAvailable.rawValue:
                            message = "No Touch ID on device"
                        case LAError.TouchIDNotEnrolled.rawValue:
                            message = "No fingers enrolled"
                        case LAError.PasscodeNotSet.rawValue:
                            message = "No passcode set"
                        default:
                            message = "Something went wrong getting local auth"
                    }
                    title = "Error"
                    self.showPopupAlertMessage(title, message: message)
                }
            }
        }
        else { //Login or Register Button Tapped
            if Username!.isEmpty || Password!.isEmpty {
                title = "Alert"
                message = "Enter a username and/or password"
                self.showPopupAlertMessage(title, message: message)
            }
            else {
                if sender.currentTitle == Storyboard.loginButtonTitle {
                    //Once web services are implemented, spinner will probably be activated here
                    if !loginLogic.verifyCredentials(Username!, password: Password!) {
                        title = "Error"
                        message = "Username/Password Incorrect"
                        self.showPopupAlertMessage(title, message: message)
                    }
                    else { //Valid credentials entered. Set sessionID and segue to main view
                        sessionID = Username!
                        performSegueWithIdentifier(Storyboard.loginRegisteredSegue, sender: sessionID)
                    }
                }
                else if sender.currentTitle == Storyboard.registerButtonTitle {
                    //Once web services are implemented, spinner will probably be activated here
                    //Try register user. If one already exists, return false
                    if !loginLogic.registerNewUser(Username!, password: Password!) {
                        title = "Error"
                        message = "Username already exists"
                        self.showPopupAlertMessage(title, message: message)
                    }
                    else{ //User succesfully registered. Set sessionID and segue to main view
                        sessionID = Username!
                        performSegueWithIdentifier(Storyboard.loginRegisteredSegue, sender: sessionID)
                    }
                }
            }
        }
        
    }
}

// MARK: UITextFieldDelegate
extension LoginViewController: UITextFieldDelegate {
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, textField string: String) -> Bool {
        return passwordTextField.textField(textField, shouldChangeCharactersInRange: range, replacementString: string)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        passwordTextField.textFieldDidEndEditing(textField)
    }
}

// MARK: Password policy
// Not currently used. You can set the password policy in the below function. Probably need to call it from somewhere.
extension LoginViewController: HideShowPasswordTextFieldDelegate {
    func isValidPassword(password: String) -> Bool {
        return password.characters.count > 7
    }
}

// MARK: Private helpers to setup the username and password fields
extension LoginViewController {
    //Set hideShowPassword field delegate to self
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
    
    //Setup the icons to the left of the username and password field
    private func addIconsToTextFields(textField: UITextField) {
        let imageView = UIImageView();
        var image: UIImage
        if textField.placeholder == Storyboard.usernameTextFieldPlaceholder {
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
}

//MARK: Keyboard helper functions
extension LoginViewController {
    private func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    private func keyboardWillShow(notification:NSNotification) {
        adjustingHeight(true, notification: notification, bottomConstraint: bottomConstraint)
    }
    
    private func keyboardWillHide(notification:NSNotification) {
        adjustingHeight(false, notification: notification, bottomConstraint: bottomConstraint)
    }
}



