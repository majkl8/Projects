//
//  Measurement+CoreDataProperties.swift
//  
//
//  Created by Majkl on 01/02/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Measurement {

    @NSManaged var dateAdded: NSDate?
    @NSManaged var location: String?
    @NSManaged var temperature: NSNumber?

}
