//
//  EntryViewController.swift
//  iSieve_main_view
//
//  Created by Marty Mcfly on 13/09/2016.
//  Copyright © 2016 Marty Mcfly. All rights reserved.
//

import UIKit

class EntryViewController: UIViewController {
    
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
        // Need to fix this to display some sort of error on non matching password
        else{
            Password = ""
        }
        
        print(EntryTitle)
        print(Username)
        print(URL)
        print(Password)
    }

    
    @IBAction func CancelBtnTapped(sender: UIButton) {
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
