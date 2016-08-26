//
//  TemperatureLoadOperation.swift
//  UTemp
//
//  Created by Majkl on 29/01/16.
//  Copyright © 2016 Majkl. All rights reserved.
//

import UIKit
import Alamofire
import SWXMLHash

class TemperatureLoadOperation: NSOperation {
    
    var url : String = "http://miskulin.com/temperature.xml"
    
    var completionHandler : ((Int16, AnyObject) -> Void)?
    
    var measurements = [String : AnyObject]()
    
    let manager = DataManager.shared
    
    override func main () -> Void {
        
        Alamofire.request(.GET, url).responseString { response in
            if let data = response.result.value {
                
                self.measurements.removeAll()
                let date = NSDate()
                var location = String()
                
                let xml = SWXMLHash.parse(data)
                
                for elem in xml["data"]["var"] {
                    
                    if (elem["name"].element!.text! == "c1000.air00_iw02") {
                        location = "Zunanja temperatura"
                    } else if (elem["name"].element!.text! == "c1000.op00_temperature_0") {
                        location = "Veliki hodnik"
                    } else if (elem["name"].element!.text! == "c1000.op01_temperature_0") {
                        location = "Soba za goste"
                    } else if (elem["name"].element!.text! == "c1000.op02_temperature_0") {
                        location = "Pralnica"
                    } else if (elem["name"].element!.text! == "c9904.op00_temperature_0") {
                        location = "Timova soba"
                    } else if (elem["name"].element!.text! == "c9904.op01_temperature_0") {
                        location = "Spalnica"
                    } else if (elem["name"].element!.text! == "c9904.op02_temperature_0") {
                        location = "Kuhinja"
                    } else if (elem["name"].element!.text! == "c9904.op03_temperature_0") {
                        location = "Janova soba"
                    } else if (elem["name"].element!.text! == "c9904.op04_temperature_0") {
                        location = "Dnevna soba"
                    } else if (elem["name"].element!.text! == "c9904.op05_temperature_0") {
                        location = "Jedilnica"
                    } else if (elem["name"].element!.text! == "c9904.ts00_temperature_0") {
                        location = "Zimski vrt"
                    } else if (elem["name"].element!.text! == "c9904.ts01_temperature_0") {
                        location = "Podstrešje"
                    } else if (elem["name"].element!.text! == "c9904.c1000_temp_bojler_dej") {
                        location = "Bojler"
                    } else {
                        location = elem["name"].element!.text!
                    }
                    
                    let temperature = Double(elem["value"].element!.text!)!/10
                    
                    self.measurements[location] = temperature
                    
                    self.manager.addMeasurement(location, temperature: temperature , dateAdded: date)
                }
                
                if let completionHandler = self.completionHandler {
                    completionHandler(1, self.measurements)
                }
            } else {
                
                let error = response.result.error
                
                if let completionHandler = self.completionHandler {
                    completionHandler(999, error!.localizedDescription)
                }
            }
        }

    }
}
