//
//  CurrentTableViewController.swift
//  UTemp
//
//  Created by Majkl on 29/01/16.
//  Copyright © 2016 Majkl. All rights reserved.
//

import UIKit
import Alamofire

@objc protocol AlarmViewControllerProtocol {
    func dismissAlarmViewController()
}

class CurrentTableViewController: UITableViewController, AlarmViewControllerProtocol {
    
    let queue : NSOperationQueue = {
        let queue = NSOperationQueue()
        queue.qualityOfService = .Background
        queue.maxConcurrentOperationCount = 1
        
        return queue
    }()
    
    var oldMeasurements = [String : AnyObject]()
    var measurements = [String : AnyObject]()
    var keysArray = [String]()
    
    let manager = DataManager.shared
    
    //var sum = Double()
    var sum = Int()
    
    //var naviLabel = UILabel()
    
    var autoRefresh : Bool =  false
    
    var h = Int()
    var m = Int()
    var s = Int()
    
    var timer : NSTimer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Current"
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CurrentTableViewController.updateRefresh(_:)), name:"UpdateRefresh", object: nil)
        
        fetchData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        checkAutoRefresh()
        
        if autoRefresh == true {
            startTimer()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    // MARK: - Fetching data
    
    func fetchData() {
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        measurements.removeAll()
        keysArray.removeAll()
        
        let operation = TemperatureLoadOperation()
        
        operation.completionHandler = { flag, info in
            dispatch_async(dispatch_get_main_queue()) {
                
                if flag == 1 {
                    
                    self.measurements = info as! [String : AnyObject]
                    self.keysArray = Array(self.measurements.keys)
                    self.tableView.reloadData()
                    
                } else {
                    
                    let alert = UIAlertController(title: "Error", message: info as? String, preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            }
        }
        queue.addOperation(operation)
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {

        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return keysArray.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let textCellIdentifier = "CellIdentifier"
        let cell = tableView.dequeueReusableCellWithIdentifier(textCellIdentifier, forIndexPath: indexPath) as UITableViewCell
        
        let key = keysArray[indexPath.row] as String
        let value = measurements[key] as! Double
        
        cell.textLabel?.text = key
        cell.detailTextLabel?.text = NSString(format: "%.1f", value) as String + " °C"
        
        if oldMeasurements.count > 0 {
            
            let oldValue = oldMeasurements[key] as! Double
            
            if (oldValue < value) {
                cell.detailTextLabel!.textColor = UIColor.redColor()
            } else  if (oldValue > value) {
                cell.detailTextLabel!.textColor = UIColor.blueColor()
            } else {
                cell.detailTextLabel!.textColor = UIColor.lightGrayColor()
            }
        }
        
        let setting = Setting.MR_findFirstByAttribute("location", withValue: key)
        
        if setting.location != nil {
            if setting.flag == 2 {
                
                cell.tintColor = UIColor.whiteColor()
                cell.accessoryType = .Checkmark
                
            } else {
                
                cell.tintColor = UIColor.blueColor()
                cell.accessoryType = .Checkmark
            }
            
        } else {
            
            cell.tintColor = UIColor.whiteColor()
            cell.accessoryType = .Checkmark
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: Motion support for Data refresh
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if motion == .MotionShake {
            
            if measurements.count > 0 {
                oldMeasurements = measurements
            }
            
            fetchData()
        }
    }
    
    func dismissAlarmViewController() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.tableView.reloadData()
        })
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let avc = segue.destinationViewController as? AlarmViewController {
            
            avc.delegate = self
            
            let indexPath = tableView.indexPathForCell(sender as! UITableViewCell)!
            
            let location = keysArray[indexPath.row] as String
            
            let temperature = measurements[location] as! Double
            
            let setting = Setting.MR_findFirstByAttribute("location", withValue: location)
            
            if setting.location != nil {

                avc.location = location
                avc.minTemp = setting.minTemp as! Double
                avc.maxTemp = setting.maxTemp as! Double
                avc.flag = setting.flag as! Double
    
            } else {
                
                manager.addSetting(location, min: temperature, max: temperature, flag: 2)
                
                avc.location = location
                avc.minTemp = temperature
                avc.maxTemp = temperature
                avc.flag = 2
            }
        }
    }
    
    func updateRefresh(notification: NSNotification) {
        
        checkAutoRefresh()
        
        if autoRefresh == true {
            startTimer()
        }
    }
    
    func checkAutoRefresh() {
        
        cleanUpTimer()

        let refresh = Refresh.MR_findFirst()
        
        if refresh.refreshFlag != nil {
            
            if refresh.refreshFlag == 1 {
                
                sum = 0
                
                h = Int(refresh.hours!) * 60 * 60
                m = Int(refresh.minutes!) * 60
                s = Int(refresh.seconds!)
                
                sum = h + m + s + 1
                
                autoRefresh = true
                
            } else {
                
                sum = -1
                
                navigationItem.prompt = "Auto-refresh is Off"
                
                autoRefresh = false
            }
        }
    }
    
    func startTimer() {
        
        if timer == nil {
            
            timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(CurrentTableViewController.update), userInfo: nil, repeats: true)
            
        } else {
            cleanUpTimer()
        }
    }
    
    func update() {
        
        if sum > 0 {
            
            sum = sum - 1
            
            let sumD = Double(sum)
            
            let hours = UInt(floor(sumD / 3600))
            let minutes = UInt(floor(sumD - (Double(hours) * 3600)) / 60)
            let seconds = (((sumD - (Double(hours) * 3600)) / 60) - Double(minutes)) * 60
            
            navigationItem.prompt = NSString(format: "Auto-refresh in %02d:%02d:%02.0f", hours, minutes, seconds) as String
        }
        
        if sum == 0 {
            fetchData()
            checkAutoRefresh()
            startTimer()
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
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
