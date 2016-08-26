//
//  Refresh+CoreDataProperties.swift
//  
//
//  Created by Majkl on 11/02/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Refresh {

    @NSManaged var refreshFlag: NSNumber?
    @NSManaged var hours: NSNumber?
    @NSManaged var minutes: NSNumber?
    @NSManaged var seconds: NSNumber?

}
