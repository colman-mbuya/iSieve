//
//  LoginLogic.swift
//  iSieve
//
//  This is essentially the Login model in the Login MVC. The username is currently stored in a CoreData password. The password is stored in the keychain with the username as the key
//
//  Created by Marty Mcfly on 25/08/2016.
//  Copyright © 2016 Marty Mcfly. All rights reserved.
//

import Foundation
import CoreData

class LoginLogic {
    
    let keychainAccessibility = KeychainItemAccessibility.Always //Keychain accessibility specifier to be used when accessing the keychain. Set to kSecAttrAccessibleAlways
    var managedObjectContext: NSManagedObjectContext? //The managed object context to be used for Core Data
    
    //MARK: init the managed object context object
    init(moc: NSManagedObjectContext){
        self.managedObjectContext = moc
    }
    
    //MARK: Public Functions
    // Returns true if valid credentials are entered. Otherwise, it returns false
    func verifyCredentials(username: String, password: String) -> Bool {
        if isRegistered(username) { //Username exists in Core Data. Check password
            if let pwdInKeychain = KeychainWrapper.defaultKeychainWrapper().stringForKey(username, withAccessibility: keychainAccessibility) {
                if pwdInKeychain == password {
                    return true
                }
            }
        }
        return false
    }
    
    //Checks if username exists in the keychain and in Core Data DB
    func verifyUsername(username: String) -> Bool {
        if KeychainWrapper.defaultKeychainWrapper().stringForKey(username, withAccessibility: keychainAccessibility) != nil && isRegistered(username) {
                return true
        }
        return false
    }
    
    //Checks if user to be registered already exists. If not, adds user and returns true. Otherwise returns false
    func registerNewUser(username: String, password: String) -> Bool {
        if !isRegistered(username) {
            // First try insert new username:password pair in the keychain
            let saveSuccessful: Bool = KeychainWrapper.defaultKeychainWrapper().setString(password, forKey: username, withAccessibility: KeychainItemAccessibility.Always)
            if saveSuccessful { //then, insert the username (but not the password) in the Core Data db.
                insertNewUser(username, password: "")
                return true
            }
            return false
        }
        return false
    }
}

//MARK: Private helper functions to interact with Core Data DB
extension LoginLogic {
    //Check if username exists in the Core Data DB
    private func isRegistered(username: String) -> Bool {
        var exist = false
        managedObjectContext?.performBlockAndWait {
            exist = User.doesUsernameExist(username, inManagedObjectContext: self.managedObjectContext!)
        }
        
        return exist
    }
    
    //Add a new user to the DB
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

