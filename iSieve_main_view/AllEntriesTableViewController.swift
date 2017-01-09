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
    //Constants declared in the storyboard for this VC
    private struct Storyboard {
        static let cellIdentifier = "Entries"
        static let entrySegue = "viewEntrySegue"
    }
    
    //The sessionID. Set when a user is authenticated
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
            //Every singe time the session is set, we update the table to reflect the new users password entries
            updateTable()
        }
    }
    
    //Managed Object Context object to be used for Core Data access
    var moc = ((UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext)!

    @IBOutlet weak var menuButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.separatorColor = UIColor.orangeColor()
        
        //Add the add (+) button to the view
        let add = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(AllEntriesTableViewController.addButtonTapped(_:)))
        self.navigationItem.hidesBackButton = true
        self.navigationItem.rightBarButtonItems = [add]
        
        //Populate the table with password entries for the logged in user
        updateTable()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.title = sessionID
        //Set up menu button
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            self.revealViewController().rearViewRevealWidth = 150
        }
    }
    
    //Ties with CoreDataTableViewController's fetchedResultController. Tl;dr, fetchedResultController will continously update the entries for the logged in user and the table will be updated with any new entries on calling updateTable(). Got this from the Stanford iOS course
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.cellIdentifier, forIndexPath: indexPath)
        
        //Get the entry to be displayed from fetchedResultsController
        if let passwordEntry = fetchedResultsController?.objectAtIndexPath(indexPath) as? PasswordEntries {
            var entryTitle: String?
            var entryID: String?
            passwordEntry.managedObjectContext?.performBlockAndWait {
                entryTitle = passwordEntry.title
                entryID = passwordEntry.unique_id
            }
            cell.textLabel?.text = entryTitle //The password entry title
            cell.detailTextLabel?.text = entryID //The password entry unique ID within the core data DB
        }
        return cell
    }
    
    @objc private func addButtonTapped(sender: UIBarButtonItem) {
        performSegueWithIdentifier(Storyboard.entrySegue, sender: "New Entry")
    }

    
    // Functionality for deletion of entries. Called when a user swipes left on an entry
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            if let cell = tableView.cellForRowAtIndexPath(indexPath) {
                if let uniqueID = cell.detailTextLabel?.text {
                    //I should probably move this when web services are implemented, so that it's not on the main queue
                    moc.performBlockAndWait {
                        PasswordEntries.deletePasswordEntry(uniqueID, inManagedObjectContext: self.moc)
                        do{
                            try self.moc.save()
                        } catch let error {
                            print("Core Data Error: \(error)")
                        }
                    }
                }
                //Update the table to reflect the new list of entries after deletion
                updateTable()
            }
        }
    }
    
    // MARK: - Navigation
    // Prepare the Entry VC to display a password entry or add a new password. Segue will happen when a user taps an entry or when they tap the add button. If the former, initialise entryvc's entryToDisplay variable with the entry's unique ID. If the latter, set entryToDisplay to sender param which will be a string.
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Storyboard.entrySegue {
            if let entryvc = segue.destinationViewController.contentViewController as? EntryViewController {
                entryvc.sessionID = self.sessionID ?? ""
                if let selectedCell = sender as? UITableViewCell {
                    entryvc.entryToDisplay = selectedCell.detailTextLabel?.text ?? ""
                }
                else if let addButton = sender as? String {
                        entryvc.entryToDisplay = addButton
                }
            }
        }
    }
    
}

//Private helper functions
extension AllEntriesTableViewController {
    //Update the table view to reflect the logged in user's password entries
    private func updateTable() {
        printDatabaseStatistics()
        if sessionID.characters.count > 0 {
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
    
    //Little helper functions to print how many password entries are in the db, for all users
    private func printDatabaseStatistics() {
        moc.performBlock {
            if let entriesCount = (try? self.moc.countForFetchRequest(NSFetchRequest(entityName: "PasswordEntries"))){
                print("\(entriesCount) Passwords")
            }
        }
    }
}
