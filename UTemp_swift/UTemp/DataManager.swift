//
//  DataManager.swift
//  UTemp
//
//  Created by Majkl on 30/01/16.
//  Copyright © 2016 Majkl. All rights reserved.
//

import UIKit
import MagicalRecord

class DataManager: NSObject {
    
    static let shared = DataManager()
    
    var measurements : [Measurement]?
    
    var allMeasurements : [Measurement] {
        if measurements == nil {
            loadAllMeasurements()
        }
        return measurements!
    }
    
    func addMeasurement (location: String, temperature: Double, dateAdded: NSDate) {
        
        if measurements == nil {
            loadAllMeasurements()
        }
        
        MagicalRecord.saveWithBlock ({ context in
            let measurement = Measurement.MR_createEntityInContext(context)
            measurement.location = location
            measurement.temperature = temperature
            measurement.dateAdded = dateAdded
            
            }, completion: { success, error in
                NSNotificationCenter.defaultCenter().postNotificationName("NewMeasurement", object: nil)
                
                self.loadAllMeasurements()
        })
    }
    
    func addSetting (location: String, min: Double, max: Double, flag: Double) {
        
        MagicalRecord.saveWithBlock ({ context in
            let setting = Setting.MR_createEntityInContext(context)
            setting.location = location
            setting.minTemp = min
            setting.maxTemp = max
            setting.flag = flag
            
            }, completion: { success, error in
                NSNotificationCenter.defaultCenter().postNotificationName("NewSetting", object: nil)
        })
    }
    
    func updateSetting (location: String, min: Double, max: Double, flag: Double, completion: (result: Int) -> Void) {
        
        MagicalRecord.saveWithBlock ({ context in
            let setting = Setting.MR_findFirstByAttribute("location", withValue: location)
            setting.minTemp = min
            setting.maxTemp = max
            setting.flag = flag
            }, completion: { success, error in
                NSNotificationCenter.defaultCenter().postNotificationName("UpdateSetting", object: nil)
                completion(result: 1)
        })
    }
    
    func addRefresh (refreshFlag: Double, hours: Int, minutes: Int, seconds: Int) {
        
        MagicalRecord.saveWithBlock ({ context in
            let refresh = Refresh.MR_createEntityInContext(context)
            refresh.refreshFlag = refreshFlag
            refresh.hours = hours
            refresh.minutes = minutes
            refresh.seconds = seconds
            
            }, completion: { success, error in
                NSNotificationCenter.defaultCenter().postNotificationName("NewRefresh", object: nil)
        })
    }

    func updateRefresh (refreshFlag: Double, hours: Int, minutes: Int, seconds: Int) {
        
        MagicalRecord.saveWithBlock ({ context in
            let refresh = Refresh.MR_findFirst()
            refresh.refreshFlag = refreshFlag
            refresh.hours = hours
            refresh.minutes = minutes
            refresh.seconds = seconds
            
            }, completion: { success, error in
                NSNotificationCenter.defaultCenter().postNotificationName("UpdateRefresh", object: nil)
        })
    }
    
    func loadAllMeasurements() {
        self.measurements = loadMeasurements()
    }
    
    private func loadMeasurements () -> [Measurement] {
        var measurements = [Measurement]()
        
        if let allMeasurements = Measurement.MR_findAll() as? [Measurement] {
            measurements = allMeasurements
        }
        return measurements
    }
    
    func removeMeasurement(measurement: Measurement) {
        for (index, value) in measurements!.enumerate() {
            if measurement == value {
                measurements?.removeAtIndex(index)
            }
        }
    }
}
