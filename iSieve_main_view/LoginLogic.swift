//
//  LoginLogic.swift
//  iSieve
//
//  Created by Marty Mcfly on 25/08/2016.
//  Copyright © 2016 Marty Mcfly. All rights reserved.
//

import Foundation
import CoreData

class LoginLogic {
    
    var managedObjectContext: NSManagedObjectContext?
    
    init(moc: NSManagedObjectContext){
        self.managedObjectContext = moc
        //insertNewUser("tester123", password: "pass")
    }
    
    func Login(username: String, password: String) -> Bool {
        if isRegistered(username) {
            if let pwdInKeychain = KeychainWrapper.defaultKeychainWrapper().stringForKey(username, withAccessibility: KeychainItemAccessibility.Always) {
                if pwdInKeychain == password {
                    return true
                }
            }
        }
        /*managedObjectContext?.performBlockAndWait {
            verified = User.verifyCredentials(username, password: password, inManagedObjectContext: self.managedObjectContext!)
        }
        
        return verified*/
        
        return false
    }
    
    func LoginWithTouchID(username: String) -> Bool {
        if KeychainWrapper.defaultKeychainWrapper().stringForKey(username, withAccessibility: KeychainItemAccessibility.Always) != nil {
                return true
        }
        return false
    }
    
    func Register(username: String, password: String) -> Bool {
        if !isRegistered(username) {
            let saveSuccessful: Bool = KeychainWrapper.defaultKeychainWrapper().setString(password, forKey: username, withAccessibility: KeychainItemAccessibility.Always)
            if saveSuccessful {
                insertNewUser(username, password: "")
                return true
            }
            return false
        }
        
        return false
    }
    
    private func isRegistered(username: String) -> Bool {
        var exist = false
        managedObjectContext?.performBlockAndWait {
            exist = User.doesUsernameExist(username, inManagedObjectContext: self.managedObjectContext!)
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
