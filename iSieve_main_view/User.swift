//
//  User.swift
//  iSieve_main_view
//
//  Created by Marty Mcfly on 10/10/2016.
//  Copyright © 2016 Marty Mcfly. All rights reserved.
//

import Foundation
import CoreData


class User: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
    class func insertNewUser(username: String, password: String, inManagedObjectContext context: NSManagedObjectContext) {
        if let user = NSEntityDescription.insertNewObjectForEntityForName("User", inManagedObjectContext: context) as? User {
            print("Inserting \(username):\(password)")
            user.username = username
            user.password = password
        }
    }
    
    class func doesUsernameExist(username: String, inManagedObjectContext context: NSManagedObjectContext) -> Bool {
        let request = NSFetchRequest(entityName: "User")
        request.predicate = NSPredicate(format: "username = %@", username)
        
        if ((try? context.executeFetchRequest(request))?.first as? User) != nil {
            return true
        }
        
        return false
    }

}
