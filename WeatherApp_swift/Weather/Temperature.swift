//
//  Temperature.swift
//  Weather
//
//  Created by Majkl on 28/11/15.
//  Copyright © 2015 Majkl. All rights reserved.
//

import Foundation

func ==(lhs: Temperature, rhs: Temperature) -> Bool {
    return lhs.city == rhs.city
}

struct TempConstants {
    static var formatter : NSDateFormatter {
        let format = NSDateFormatter()
        format.dateStyle = .MediumStyle
        
        return format
    }
}

class Temperature {
    var city : String
    var temperature : Double
    var tempMin : Double
    var tempMax : Double
    var dateMin : NSDate = NSDate()
    var dateMax : NSDate = NSDate()
    
    init (city: String, temperature: Double, tempMin : Double, tempMax: Double) {
        self.city = city
        self.temperature = temperature
        self.tempMin = tempMin
        self.tempMax = tempMax
    }
    
    init() {
        city = ""
        temperature = 0.0
        tempMin = 999.9
        tempMax = -999.9
    }
    
    init (dictionary: [String : AnyObject]) {
        self.city = dictionary["city"] as! String
        self.temperature = dictionary["temperature"] as! Double
        self.tempMin = dictionary["tempMin"] as! Double
        self.tempMax = dictionary["tempMax"] as! Double
        self.dateMin = TempConstants.formatter.dateFromString(dictionary["dateMin"] as! String)!
        self.dateMax = TempConstants.formatter.dateFromString(dictionary["dateMax"] as! String)!
    }
    
    func toDictionary () -> [String : AnyObject] {
        return ["city" : self.city, "temperature" : self.temperature, "tempMin" : self.tempMin, "tempMax" : self.tempMax, "dateMin" : TempConstants.formatter.stringFromDate(self.dateMin), "dateMax" : TempConstants.formatter.stringFromDate(self.dateMax)]
    }
}
