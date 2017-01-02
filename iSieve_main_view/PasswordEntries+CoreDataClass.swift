//
//  PasswordEntries+CoreDataClass.swift
//  iSieve
//
//  Created by Marty Mcfly on 30/12/2016.
//  Copyright © 2016 Marty Mcfly. All rights reserved.
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData

@objc(PasswordEntries)
public class PasswordEntries: NSManagedObject {
    class func insertNewPasswordEntry(user: String, username: String, password: String, title: String, url: String, inManagedObjectContext context: NSManagedObjectContext) {
        if let passwordEntry = NSEntityDescription.insertNewObjectForEntityForName("PasswordEntries", inManagedObjectContext: context) as? PasswordEntries {
            passwordEntry.username = username
            passwordEntry.password = password
            passwordEntry.title = title
            passwordEntry.url = url
            let uuid = NSUUID().UUIDString
            passwordEntry.unique_id = uuid
            let request = NSFetchRequest(entityName: "User")
            request.predicate = NSPredicate(format: "username = %@", user)
        
            if let userDBEntry = ((try? context.executeFetchRequest(request))?.first as? User) {
                print("User object returned \(userDBEntry.username)")
                passwordEntry.owner = userDBEntry
            }
            
            print("Inserted username \(passwordEntry.username) to owner \(passwordEntry.owner?.username)")
        }
    }
    
    class func deletePasswordEntry(uniqueID: String) {
        // to do
    }
    
    class func getPasswordEntry(uniqueID: String, inManagedObjectContext context: NSManagedObjectContext) -> PasswordEntries? {
        let request = NSFetchRequest(entityName: "PasswordEntries")
        request.predicate = NSPredicate(format: "unique_id = %@", uniqueID)
        
        if let PasswordEntry = ((try? context.executeFetchRequest(request))?.first as? PasswordEntries) {
            print("User object returned \(PasswordEntry.title)")
            return PasswordEntry
        }
        
        return nil
    }

}
