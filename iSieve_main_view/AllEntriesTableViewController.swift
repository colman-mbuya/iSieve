//
//  AllEntriesTableViewController.swift
//  iSieve_main_view
//
//  Created by Marty Mcfly on 13/09/2016.
//  Copyright © 2016 Marty Mcfly. All rights reserved.
//

import UIKit
import CoreData

class AllEntriesTableViewController: CoreDataTableViewController {
    
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
            updateTable()
        }
    }
    
    var moc = ((UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext)!
    
    private struct Storyboard {
        static let cellIdentifier = "Entries"
        static let EntrySegue = "viewEntrySegue"
    }
    
    @IBOutlet weak var menuButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.separatorColor = UIColor.orangeColor()
        
        let add = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(AllEntriesTableViewController.addTapped(_:)))
        self.navigationItem.hidesBackButton = true

        self.navigationItem.rightBarButtonItems = [add]
        
        updateTable()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.title = sessionID
        print(sessionID)
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            self.revealViewController().rearViewRevealWidth = 150
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

/*    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
*/
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.cellIdentifier, forIndexPath: indexPath)
        
        // Configure the cell...
        if let passwordEntry = fetchedResultsController?.objectAtIndexPath(indexPath) as? PasswordEntries {
            var entryTitle: String?
            var entryID: String?
            passwordEntry.managedObjectContext?.performBlockAndWait {
                // it's easy to forget to do this on the proper queue
                entryTitle = passwordEntry.title
                entryID = passwordEntry.unique_id
                // we're not assuming the context is a main queue context
                // so we'll grab the screenName and return to the main queue
                // to do the cell.textLabel?.text setting
            }
            cell.textLabel?.text = entryTitle
            cell.detailTextLabel?.text = entryID
        }
        return cell
    }
    
    func addTapped(sender: UIBarButtonItem) {
        performSegueWithIdentifier(Storyboard.EntrySegue, sender: "New Entry")
    }

    
    // Override to support conditional editing of the table view.
/*    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
 */

    
    // Override this to support deletion of entries by swiping.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            //Delete from the model here
            //data.removeAtIndex(indexPath.row)
            if let cell = tableView.cellForRowAtIndexPath(indexPath) {
                print("in if let cell")
                if let uniqueID = cell.detailTextLabel?.text {
                    print("in if let uniqueID")
                    moc.performBlockAndWait {
                        PasswordEntries.deletePasswordEntry(uniqueID, inManagedObjectContext: self.moc)
                        do{
                            try self.moc.save()
                        } catch let error {
                            print("Core Data Error: \(error)")
                        }
                    }
                }
                updateTable()
            }
            
            // Delete the row from the data source
            //tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    
    private func updateTable() {
        print("in updateTable")
        printDatabaseStatistics()
        if sessionID.characters.count > 0 {
            print("ID: \(sessionID)")
            let request = NSFetchRequest(entityName: "PasswordEntries")
            request.predicate = NSPredicate(format: "owner.username = %@", sessionID)
            request.sortDescriptors = [NSSortDescriptor(
                key: "title",
                ascending: true,
                selector: #selector(NSString.localizedCaseInsensitiveCompare(_:))
                )]
            fetchedResultsController = NSFetchedResultsController(
                fetchRequest: request,
                managedObjectContext: moc,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
        } else {
            fetchedResultsController = nil
        }

    }
    
    private func printDatabaseStatistics() {
        moc.performBlock {
            if let entriesCount = (try? self.moc.countForFetchRequest(NSFetchRequest(entityName: "PasswordEntries"))){
                print("\(entriesCount) Passwords")
            }
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
            //let destinationvc = segue.destinationViewController
            if let entryvc = segue.destinationViewController.contentViewController as? EntryViewController{
                entryvc.sessionID = self.sessionID ?? "Nothing"
                if let selectedCell = sender as? UITableViewCell {
                    entryvc.entryToDisplay = selectedCell.detailTextLabel?.text ?? "Nothing"
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
