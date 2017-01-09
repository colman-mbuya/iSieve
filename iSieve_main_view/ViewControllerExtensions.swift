//
//  ViewControllerExtensions.swift
//  iSieve
//
//  Created by Marty Mcfly on 09/01/2017.
//  Copyright © 2017 Marty Mcfly. All rights reserved.
//

extension UIViewController {
    var contentViewController: UIViewController {
        if let navcon = self as? UINavigationController {
            return navcon.visibleViewController ?? self
        } else {
            return self
        }
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

extension UIViewController {
    func showPopupAlertMessage(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}


