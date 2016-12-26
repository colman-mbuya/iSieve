//
//  LoginLogic.swift
//  Practice1LoginPage
//
//  Created by Marty Mcfly on 25/08/2016.
//  Copyright © 2016 Marty Mcfly. All rights reserved.
//

import Foundation
import CoreData

class LoginLogic {
    private var testUsername = "Tester"
    private var testPassword = "Secure"
    
    var managedObjectContext: NSManagedObjectContext?
    
    init(moc: NSManagedObjectContext){
        self.managedObjectContext = moc
    }
    
    func Login(username: String, password: String) -> Bool {
        if username == testUsername && password == testPassword {
            //Do session init here
            return true
        }
        return false
    }
    
    func Register(username: String, password: String) -> Bool {
        if !isRegistered(username) {
            insertNewUser(username, password: password)
            return true
        }
        
        //Do registration here
        return false
    }
    
    private func isRegistered(username: String) -> Bool {
        var exist = false
        managedObjectContext?.performBlock {
            exist = User.doesUsernameExist(username, inManagedObjectContext: self.managedObjectContext!)
            do{
                try self.managedObjectContext?.save()
            } catch let error {
                print("Core Data Error: \(error)")
            }
        }
        
        return exist
    }
    
    private func insertNewUser(username: String, password: String) {
        managedObjectContext?.performBlock {
            User.insertNewUser(username, password: password, inManagedObjectContext: self.managedObjectContext!)
            do{
                try self.managedObjectContext?.save()
            } catch let error {
                print("Core Data Error: \(error)")
            }
        }
    }
}
