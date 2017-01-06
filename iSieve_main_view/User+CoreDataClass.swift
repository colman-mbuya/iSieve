//
//  User+CoreDataClass.swift
//  iSieve
//
//  Created by Marty Mcfly on 29/12/2016.
//  Copyright © 2016 Marty Mcfly. All rights reserved.
//

import Foundation
import CoreData

@objc(User)
public class User: NSManagedObject {
    class func insertNewUser(username: String, password: String, inManagedObjectContext context: NSManagedObjectContext) {
        print("in INU")
        if let user = NSEntityDescription.insertNewObjectForEntityForName("User", inManagedObjectContext: context) as? User {
            print("in let")
            user.username = username
            user.password = password
            let uuid = NSUUID().UUIDString
            user.unique_id = uuid
            print(uuid)
            print("Inserted\(user.username):\(user.password) UUID \(uuid)")
        }
    }
    
    class func doesUsernameExist(username: String, inManagedObjectContext context: NSManagedObjectContext) -> Bool {
        let request = NSFetchRequest(entityName: "User")
        request.predicate = NSPredicate(format: "username = %@", username)
        
        if let user = ((try? context.executeFetchRequest(request))?.first as? User) {
            print("User object returned \(user.username)")
            return true
        }
        
        return false
    }
    
    class func verifyCredentials(username: String, password: String, inManagedObjectContext context: NSManagedObjectContext) -> Bool {
        let request = NSFetchRequest(entityName: "User")
        request.predicate = NSPredicate(format: "username = %@ AND password = %@", username, password)
        
        if ((try? context.executeFetchRequest(request))?.first as? User) != nil {
            return true
        }
        
        return false
    }
    
    class func getPasswordEntries(username: String, inManagedObjectContext context: NSManagedObjectContext) -> [PasswordEntries]? {
        let request = NSFetchRequest(entityName: "User")
        request.predicate = NSPredicate(format: "username = %@", username)
        
        if let user = ((try? context.executeFetchRequest(request))?.first as? User) {
            return user.password_entries?.allObjects as? [PasswordEntries]
        }
        
        return nil
    }
    
}
