//
//  DetailTableViewController.swift
//  UTemp
//
//  Created by Majkl on 03/02/16.
//  Copyright © 2016 Majkl. All rights reserved.
//

import UIKit

class DetailTableViewController: UITableViewController {
    
    lazy var dateFormatter : NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .MediumStyle
        formatter.timeStyle = .MediumStyle
        
        return formatter
    }()
    
    var measurements : [Measurement]?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let measurement = measurements![0]
        let date = measurement.dateAdded
        
        let titleDate = dateFormatter.stringFromDate(date!)
        
        self.title = titleDate
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return measurements!.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let textCellIdentifier = "CellIdentifier"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(textCellIdentifier, forIndexPath: indexPath) as UITableViewCell
        
        let measurement = measurements![indexPath.row]
  
        cell.textLabel?.text = measurement.location
        cell.detailTextLabel!.text = NSString(format: "%.1f", measurement.temperature! as Double) as String + " °C"
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}