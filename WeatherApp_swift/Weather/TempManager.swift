//
//  TempManager.swift
//  Weather
//
//  Created by Majkl on 28/11/15.
//  Copyright © 2015 Majkl. All rights reserved.
//

import Foundation

class TempManager : NSObject {

    static let shared = TempManager()
    
    var locations : [Temperature]?

    var allLocations : [Temperature] {
        if locations == nil {
            loadAllLocations()
        }
        return locations!
    }
    
    func addLocation (temp : Temperature) {
        if locations == nil {
            loadAllLocations()
        }
        
        locations!.append(temp)
    }

    func save () {
        guard let locations = locations else {
            return
        }
        
        var serializedLocations = [AnyObject]()
        
        for location in locations {
            serializedLocations.append(location.toDictionary())
        }
        
        NSUserDefaults.standardUserDefaults().setObject(serializedLocations, forKey: "AllLocations")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func loadAllLocations () {
        self.locations = loadLocations()
    }
    
    private func loadLocations () -> [Temperature] {
        let serializedLocations = NSUserDefaults.standardUserDefaults().objectForKey("AllLocations")
        
        var locations = [Temperature]()
        
        if let serializedLocations = serializedLocations as? [[String : AnyObject]] {
            for location in serializedLocations {
                let newLocation = Temperature(dictionary: location)
                
                locations.append(newLocation)
            }
        }
        return locations
    }
    
    func removeLocation(location: Temperature) {
        for (index, value) in locations!.enumerate() {
            if location == value {
                locations?.removeAtIndex(index)
            }
        }
    }
    
    func exists(locations: [Temperature], city: String) -> Bool {
        if locations.count > 0 {
            for location in locations {
                if location.city == city {
                    return true
                }
            }
        }
        return false
    }
}


