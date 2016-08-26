//
//  TableTableViewController.swift
//  Weather
//
//  Created by Majkl on 29/11/15.
//  Copyright © 2015 Majkl. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate {
    
    var timer : NSTimer?
    
    var index : Int?
    
    var filteredTemp = [Temperature]()
    var resultSearchController = UISearchController()
    
    var location : Temperature?
    
    let queue : NSOperationQueue = {
        let queue = NSOperationQueue()
        queue.qualityOfService = .Background
        queue.maxConcurrentOperationCount = 1
        
        return queue
    }()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.resultSearchController.loadViewIfNeeded()
        
        self.resultSearchController = ({
            
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            controller.searchBar.barStyle = UIBarStyle.Black
            controller.searchBar.barTintColor = UIColor.whiteColor()
            controller.searchBar.backgroundColor = UIColor.clearColor()
            self.tableView.tableHeaderView = controller.searchBar
            self.tableView.contentOffset = CGPointMake(0, CGRectGetHeight(controller.searchBar.frame));
            
            return controller
            
        })()
        
        tableView.reloadData()
        
        loadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.resultSearchController.active {
            return self.filteredTemp.count
        } else {
            return TempManager.shared.allLocations.count
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let textCellIdentifier = "CellIdentifier"
        let cell = tableView.dequeueReusableCellWithIdentifier(textCellIdentifier, forIndexPath: indexPath) as UITableViewCell
        
        if self.resultSearchController.active {
            
            location = filteredTemp[indexPath.row]
            
        } else {
        
            location = TempManager.shared.allLocations[indexPath.row]
        }
        
        cell.textLabel?.text = location!.city

        cell.detailTextLabel?.text = "Current: " + (NSString(format: "%.1f", location!.temperature) as String) + "°C " + "Min: " + (NSString(format: "%.1f", location!.tempMin) as String) + "°C " + "Max: " + (NSString(format: "%.1f", location!.tempMax) as String) + "°C"

        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
    
            let location = TempManager.shared.allLocations[indexPath.row]
            TempManager.shared.removeLocation(location)
            TempManager.shared.save()
            
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
    
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

        let location = TempManager.shared.allLocations[fromIndexPath.row]

        TempManager.shared.locations!.removeAtIndex(fromIndexPath.row)
        TempManager.shared.locations!.insert(location, atIndex: toIndexPath.row)
        TempManager.shared.save()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? ViewController {
            let indexPath = tableView.indexPathForCell(sender as! UITableViewCell)!
            
            if self.resultSearchController.active {
                
                if let location : Temperature = filteredTemp[indexPath.row] {
                    vc.location = location.city
                    vc.locationData = location
                    self.resultSearchController.active = false
                }
                
            } else {
            
                if let location : Temperature = TempManager.shared.allLocations[indexPath.row] {
                    vc.location = location.city
                    vc.locationData = location
                    self.resultSearchController.active = false
                }
            }
        }
    }
    
    func loadData () {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        for location in TempManager.shared.allLocations {
            self.addOperationForCity(location.city)
        }
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
    
    func addOperationForCity (city: String) {
        
        for (index, location) in TempManager.shared.allLocations.enumerate() {
            if city == location.city {
                self.index = index
            }
        }

        let indexPath = NSIndexPath(forRow: index!, inSection: 0)
        self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        
        let operation = WeatherLoadOperation()
        operation.location = city
        operation.completionHandler = { temp, icon, weather in
            dispatch_async(dispatch_get_main_queue()) {
                self.refreshCellForCity(city, temp: temp)
            }
        }
        queue.addOperation(operation)
    }
    
    func refreshCellForCity (city: String, temp: Double) {
        for (index, location) in TempManager.shared.allLocations.enumerate() {
            if city == location.city {
                self.index = index
            }
        }
        
        let location = TempManager.shared.allLocations[index!]
        location.temperature = temp
        
        if location.tempMin > temp {
            location.tempMin = temp
            location.dateMin = NSDate()
            TempManager.shared.save()
        }
        
        if location.tempMax < temp {
            location.tempMax = temp
            location.dateMax = NSDate()
            TempManager.shared.save()
        }
        
        let indexPath = NSIndexPath(forRow: index!, inSection: 0)
        
        self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        
    }
    
    @IBAction func startEditing(sender: UIBarButtonItem) {
        self.editing = !self.editing
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if motion == .MotionShake {
            loadData()
        }
    }
    
    func filterContentForSearchText(searchText: String) {
        self.filteredTemp = TempManager.shared.locations!.filter({( location: Temperature ) -> Bool in
            let stringMatch = location.city.rangeOfString(searchText)
            return stringMatch != nil
        })
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        filteredTemp.removeAll(keepCapacity: false)
        
        let searchText = searchController.searchBar.text
        filterContentForSearchText(searchText!)
        
        self.tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {

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
