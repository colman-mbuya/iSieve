//
//  User+CoreDataProperties.swift
//  iSieve_main_view
//
//  Created by Marty Mcfly on 10/10/2016.
//  Copyright © 2016 Marty Mcfly. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension User {

    @NSManaged var username: String?
    @NSManaged var password: String?
    @NSManaged var unique_id: NSNumber?
    @NSManaged var password_entries: NSSet?

}
