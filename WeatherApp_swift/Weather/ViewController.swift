//
//  ViewController.swift
//  Weather
//
//  Created by Majkl on 07/11/15.
//  Copyright © 2015 Majkl. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController {
    
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var weatherIconView: WeatherIconView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var miniumTempLabel: UILabel!
    @IBOutlet weak var maximumTempLabel: UILabel!
    
    var location : String = ""
    var timer : NSTimer?
    
    let queue : NSOperationQueue = {
        let queue = NSOperationQueue()
        queue.qualityOfService = .Background
        queue.maxConcurrentOperationCount = 2
        
        return queue
    }()
    
    var locationData = Temperature()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.cityLabel.text = location.capitalizedString
        
//        timer = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: "loadData", userInfo: nil, repeats: true)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        loadData()
    }
    
    override func viewWillDisappear(animated : Bool) {
        super.viewWillDisappear(animated)
        
        if (self.isMovingFromParentViewController()){
            self.backgroundImageView.image = nil
        }
    }

    func loadData () {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            let operation = WeatherLoadOperation()
            operation.location = location
        
            operation.completionHandler = { temp, icon, weather in
                dispatch_async(dispatch_get_main_queue()) {
                        
                    self.numberLabel.text = String(format: "%.1f°C", temp)
                    self.weatherIconView.iconType = icon
                    self.miniumTempLabel.text = "Min: " + (NSString(format: "%.1f", self.locationData.tempMin) as String) + "°C " + "recorded on " + TempConstants.formatter.stringFromDate(self.locationData.dateMin)
                    self.maximumTempLabel.text = "Max: " + (NSString(format: "%.1f", self.locationData.tempMax) as String) + "°C " + "recorded on " + TempConstants.formatter.stringFromDate(self.locationData.dateMax)
                }
            }
        
            queue.addOperation(operation)
            
            let flickrOperation = FlickrImageOperation()
            flickrOperation.location = location
            flickrOperation.completionHandler = { image in
                if let image = image {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.backgroundImageView.image = image
                        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    }
                }
            }
            queue.addOperation(flickrOperation)
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if motion == .MotionShake {
            loadData()
        }
    }

    func cleanUpTimer () {
        if let timer = timer {
            timer.invalidate()
            self.timer = nil
        }
    }
    
    deinit {
        cleanUpTimer()
    }
}
