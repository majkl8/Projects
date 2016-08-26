//
//  Setting+CoreDataProperties.swift
//  
//
//  Created by Majkl on 07/02/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Setting {

    @NSManaged var flag: NSNumber?
    @NSManaged var minTemp: NSNumber?
    @NSManaged var maxTemp: NSNumber?
    @NSManaged var location: String?

}
