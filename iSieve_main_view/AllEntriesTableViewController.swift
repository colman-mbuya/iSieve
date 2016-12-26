//
//  AllEntriesTableViewController.swift
//  iSieve_main_view
//
//  Created by Marty Mcfly on 13/09/2016.
//  Copyright © 2016 Marty Mcfly. All rights reserved.
//

import UIKit

class AllEntriesTableViewController: UITableViewController {
    
    var data = ["Apple", "Apricot", "Banana", "Blueberry", "Cantaloupe", "Cherry",
                "Clementine", "Coconut", "Cranberry", "Fig", "Grape", "Grapefruit",
                "Kiwi fruit", "Lemon", "Lime", "Lychee", "Mandarine", "Mango",
                "Melon", "Nectarine", "Olive", "Orange", "Papaya", "Peach",
                "Pear", "Pineapple", "Raspberry", "Strawberry"]
    var sessionID: String = ""
    
    private struct Storyboard {
        static let cellIdentifier = "Entries"
        static let EntrySegue = "viewEntrySegue"
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.separatorColor = UIColor.orangeColor()
        
        let add = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(AllEntriesTableViewController.addTapped(_:)))

        self.navigationItem.rightBarButtonItems = [add]
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.title = sessionID
        print(sessionID)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.cellIdentifier, forIndexPath: indexPath)

        // Configure the cell...
        cell.textLabel?.text = data[indexPath.row]
        return cell
    }
    
    func addTapped(sender: UIBarButtonItem){
        print("buttontapped")
        performSegueWithIdentifier(Storyboard.EntrySegue, sender: "New Entry")
    }

    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
 

    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            //Delete from the model here
            data.removeAtIndex(indexPath.row)
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Storyboard.EntrySegue{
            let destinationvc = segue.destinationViewController
            if let entryvc = destinationvc as? EntryViewController{
                if let selectedCell = sender as? UITableViewCell {
                    entryvc.entryToDisplay = selectedCell.textLabel?.text ?? "Nothing"
                }
                if let addButton = sender as? String {
                        entryvc.entryToDisplay = addButton
                }
            }
        }
        
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

}
