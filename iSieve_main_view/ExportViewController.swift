//
//  ExportViewController.swift
//  iSieve
//
//  Created by Marty Mcfly on 06/01/2017.
//  Copyright © 2017 Marty Mcfly. All rights reserved.
//

import UIKit
import MessageUI
import CoreData

class ExportViewController: UIViewController, MFMailComposeViewControllerDelegate{
    @IBOutlet weak var menuButton: UIBarButtonItem!
    var moc: NSManagedObjectContext = ((UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext)!
    
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

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func ExportButtonTapped(sender: UIButton) {
        if( MFMailComposeViewController.canSendMail() ) {
            let mailComposer = MFMailComposeViewController()
            mailComposer.mailComposeDelegate = self
            
            //Set the subject and message of the email
            mailComposer.setSubject("Subject")
            mailComposer.setMessageBody("body text", isHTML: false)
            
            let CSVFile = exportDatabaseToFile()
            
            if !CSVFile.isEmpty {
                if let dir = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first {
                    if let path = NSURL(fileURLWithPath: dir).URLByAppendingPathComponent(CSVFile) {
                        do {
                            let fileText = try NSString(contentsOfURL: path, encoding: NSUTF8StringEncoding)
                            print("Attaching \(fileText)")
                            let fileData = fileText.dataUsingEncoding(NSUTF8StringEncoding)
                            mailComposer.addAttachmentData(fileData!, mimeType: "text/txt", fileName: "Database.csv")
                            self.presentViewController(mailComposer, animated: true, completion: nil)
                        } catch {
                            print("something went wrong reading and attaching the file")
                        }

                    }
                }

            }

        }
    }
    
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    private func exportDatabaseToFile() -> String {
        let file = "Database.csv"
        let text = createCSV() //just a text
        
        if let dir = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first {
            if let path = NSURL(fileURLWithPath: dir).URLByAppendingPathComponent(file) {
                //writing
                do {
                    try text.writeToURL(path, atomically: false, encoding: NSUTF8StringEncoding)
                }
                catch {
                    return ""
                }
                
                //reading
                /*do {
                    let text2 = try NSString(contentsOfURL: path, encoding: NSUTF8StringEncoding)
                    print("Read: \(text2)")
                }
                catch {
                    return ""
                }*/
            }
            
            
        }
        
        return file
    }
    
    private func createCSV() -> String {
        var passwordEntries: [PasswordEntries]? = nil
        var csvData = "sep = , \nTitle, Url, Username, Password\n"
        moc.performBlockAndWait {
            passwordEntries = User.getPasswordEntries(self.sessionID, inManagedObjectContext: self.moc)
            if passwordEntries != nil {
                for entry in passwordEntries! {
                    csvData.appendContentsOf("\(entry.title!), \(entry.url!), \(entry.username!), \(entry.password!)\n")
                }
            }
        }
        print("CSV" + csvData)
        return csvData
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
