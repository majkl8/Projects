//
//  ViewController.swift
//  Weather
//
//  Created by Majkl on 28/11/15.
//  Copyright © 2015 Majkl. All rights reserved.
//

import UIKit

class WeatherDataViewController : UIViewController {
    
    var check : Bool = false
    
    let queue : NSOperationQueue = {
        let queue = NSOperationQueue()
        queue.qualityOfService = .Background
        queue.maxConcurrentOperationCount = 1
        
        return queue
    }()
    
    @IBOutlet weak var locationTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Add City"
        
        let navigationBar = navigationController!.navigationBar
        navigationBar.tintColor = UIColor.blueColor()
        
        let rightButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(WeatherDataViewController.done))
        
        navigationItem.rightBarButtonItem = rightButton
    }

    func done () {
        
        if let city = locationTextField.text where city.characters.count > 0 {
            
            let operation = WeatherLoadOperation()
            
            operation.location = city
            operation.completionHandler = { temp, icon, weather in
                dispatch_async(dispatch_get_main_queue()) {
                    if temp == 999.9 {
                        
                        let alert = UIAlertController(title: "Error", message: "City doesn't exist!", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                        
                    } else {
                        
                        let location = Temperature()
                        location.city = city
                        location.temperature = 0.0
                        
                        let locations = TempManager.shared.allLocations
                        
                        if (!TempManager.shared.exists(locations, city: city)) {
                            
                            TempManager.shared.addLocation(location)
                            TempManager.shared.save()
                            
                            self.navigationController!.popViewControllerAnimated(true)
                            
                        } else {
                            
                            let alert2 = UIAlertController(title: "Error", message: "City already exists!", preferredStyle: UIAlertControllerStyle.Alert)
                            alert2.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                            self.presentViewController(alert2, animated: true, completion: nil)
                        }
                    }
                }
            }
            queue.addOperation(operation)
        } else {
            
            let animation = CABasicAnimation(keyPath: "position")
            animation.duration = 0.07
            animation.repeatCount = 4
            animation.fromValue = NSValue(CGPoint: CGPointMake(locationTextField.center.x, locationTextField.center.y - 7))
            animation.toValue = NSValue(CGPoint: CGPointMake(locationTextField.center.x, locationTextField.center.y + 7))
            locationTextField.layer.addAnimation(animation, forKey: "position")
        }
    }
}
