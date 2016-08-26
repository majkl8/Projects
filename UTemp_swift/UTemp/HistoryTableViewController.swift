//
//  HistoryTableViewController.swift
//  UTemp
//
//  Created by Majkl on 29/01/16.
//  Copyright © 2016 Majkl. All rights reserved.
//

import UIKit
import MagicalRecord

class HistoryTableViewController: UITableViewController {
    
    lazy var dateFormatter : NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .MediumStyle
        
        return formatter
    }()
    
    lazy var timeFormatter : NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.timeStyle = .MediumStyle
        
        return formatter
    }()
    
    var dates : [String] = [String]()
    var times : [String] = [String]()
    var dateTimes : [String : [String]] = [String : [String]]()
    var objDates : [String : [NSDate]] = [String : [NSDate]]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "History"

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        loadMeasurements()
        tableView.reloadData()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func loadMeasurements () {
        dates.removeAll()
        times.removeAll()
        dateTimes.removeAll()
        
        let allMeasurements = DataManager.shared.allMeasurements.sort { $0.dateAdded!.compare($1.dateAdded!) == .OrderedDescending }

        for measurement in allMeasurements {
            let measurementDate = dateFormatter.stringFromDate(measurement.dateAdded!)
            let measurementTime = timeFormatter.stringFromDate(measurement.dateAdded!)
            
            if !dates.contains(measurementDate) {
                dates.append(measurementDate)
                
                dateTimes[measurementDate] = [String]()
                objDates[measurementDate] = [NSDate]()
            }
            
            if !times.contains(measurementTime) {
                times.append(measurementTime)
                
                dateTimes[measurementDate]?.append(measurementTime)
                objDates[measurementDate]?.append(measurement.dateAdded!)
            }
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return dates.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dateTimes[dates[section]]!.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let textCellIdentifier = "CellIdentifier"
        let cell = tableView.dequeueReusableCellWithIdentifier(textCellIdentifier, forIndexPath: indexPath) as UITableViewCell
        
        let hour = dateTimes[dates[indexPath.section]]![indexPath.row]
        
        cell.textLabel?.text = hour
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        let todayDate = dateFormatter.stringFromDate(NSDate())
        
        let calendar = NSCalendar.currentCalendar()
        let yesterdayDate = dateFormatter.stringFromDate(calendar.dateByAddingUnit(.Day, value: -1, toDate: NSDate(), options: [])!)
        
        if dates[section] == todayDate {
            return "Today"
        }
        else if dates[section] == yesterdayDate {
            return "Yesterday"
        }
        
        return dates[section]
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            
            let date = objDates[dates[indexPath.section]]![indexPath.row]
            
            MagicalRecord.saveWithBlock ({ context in
                
                Measurement.MR_deleteAllMatchingPredicate(NSPredicate(format: "dateAdded = %@", date), inContext: context)
                
                }, completion:{ (success, error) -> Void in
                    
                    DataManager.shared.measurements = nil
                    self.loadMeasurements()
                    self.tableView.reloadData()
            })
        }
    }
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let dvc = segue.destinationViewController as? DetailTableViewController {
            let indexPath = tableView.indexPathForCell(sender as! UITableViewCell)!
            
            let date = objDates[dates[indexPath.section]]![indexPath.row]
            
            let measurements = Measurement.MR_findAllWithPredicate(NSPredicate(format: "dateAdded = %@", date)) as! [Measurement]
            
            dvc.measurements = measurements
        }
    }
}
