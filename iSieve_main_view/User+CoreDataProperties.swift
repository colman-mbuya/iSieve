//
//  User+CoreDataProperties.swift
//  iSieve
//
//  Created by Marty Mcfly on 30/12/2016.
//  Copyright © 2016 Marty Mcfly. All rights reserved.
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension User {
    @NSManaged public var username: String?
    @NSManaged public var unique_id: String?
    @NSManaged public var password: String?
    @NSManaged public var password_entries: NSSet?

}

// MARK: Generated accessors for password_entries
extension User {

    @objc(addPassword_entriesObject:)
    @NSManaged public func addToPassword_entries(_ value: PasswordEntries)

    @objc(removePassword_entriesObject:)
    @NSManaged public func removeFromPassword_entries(_ value: PasswordEntries)

    @objc(addPassword_entries:)
    @NSManaged public func addToPassword_entries(_ values: NSSet)

    @objc(removePassword_entries:)
    @NSManaged public func removeFromPassword_entries(_ values: NSSet)

}
