//
//  WeatherLoadOperation.swift
//  Weather
//
//  Created by Majkl on 30/11/15.
//  Copyright © 2015 Majkl. All rights reserved.
//

import Foundation
import Alamofire

class WeatherLoadOperation: NSOperation {
    
    var location : String = ""
    var units : String = "metric"
    
    var url : String = "http://api.openweathermap.org/data/2.5/weather"
    var appID : String = ""

    // Called when completed with parsed temperature as double, parsed weather icon and any object JSON
    var completionHandler : ((Double, WeatherIcon, AnyObject) -> Void)?
    
    override func main () -> Void {
        
        let parameters = ["q": location , "units": units , "appid" : appID]
        
        Alamofire.request(.GET, url, parameters: parameters).responseJSON { response in
            if let JSON = response.result.value {
                
                let code = JSON["cod"]! as? String
                
                if code != "404" {
                    
                    let weather = JSON["main"]!
                
                    let description = JSON["weather"]!![0]["description"] as! String
                
                    var icon : WeatherIcon = .Sunny
                
                    if description.containsString("cloud") {
                        icon = .Cloudy
                    }
                    else if description.containsString("fog") {
                        icon = .Fog
                    }
                    else if description.containsString("drizzle") {
                        icon = .Showers
                    }
                    else if description.containsString("rain") {
                        icon = .Rain
                    }
                    else if description.containsString("snow") {
                        icon = .Sunny
                    }
                    else if description.containsString("thunder") {
                        icon = .Thunder
                    }
                
                    let temperature = weather as! [String : AnyObject]
                
                    if let temp = temperature["temp"] as? NSNumber {
                    
                        if let completionHandler = self.completionHandler {
                            completionHandler(temp.doubleValue, icon, weather!)
                        }
                    }
                    
                } else {
                    
                    let icon : WeatherIcon = .Empty
                    
                    let weather = ["temp" : 999.9]
                    
                    if let completionHandler = self.completionHandler {
                        completionHandler(999.9, icon, weather)
                    }
                }
            }
        }
    }
}