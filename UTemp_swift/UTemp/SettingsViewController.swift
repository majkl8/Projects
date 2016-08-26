//
//  SettingsViewController.swift
//  UTemp
//
//  Created by Majkl on 09/02/16.
//  Copyright © 2016 Majkl. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var manager = DataManager.shared
    
    var refreshFlag = Double()
    var h = Int()
    var m = Int()
    var s = Int()
    
    @IBOutlet weak var refreshSwitch: UISwitch!
    
    @IBOutlet weak var picker1: UIPickerView!
    @IBOutlet weak var picker2: UIPickerView!
    @IBOutlet weak var picker3: UIPickerView!

    
    @IBAction func switchRefreshed(sender: UISwitch) {
        
        if !sender.on {
            refreshFlag = 2
            
            picker1.selectRow(0, inComponent: 0, animated: true)
            picker2.selectRow(0, inComponent: 0, animated: true)
            picker3.selectRow(0, inComponent: 0, animated: true)
            
            picker1.userInteractionEnabled = false
            picker2.userInteractionEnabled = false
            picker3.userInteractionEnabled = false
            
            h = 0
            m = 0
            s = 0
            
        } else {
            refreshFlag = 1
            picker1.userInteractionEnabled = true
            picker2.userInteractionEnabled = true
            picker3.userInteractionEnabled = true
        }
    }
    
    var hours = ["00", "01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23"]
    var minutes = ["00", "01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31", "32", "33", "34", "35", "36", "37", "38", "39", "40", "41", "42", "43", "44", "45", "46", "47", "48", "49", "50", "51", "52", "53", "54", "55", "56", "57", "58", "59"]
    var seconds = ["00", "01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31", "32", "33", "34", "35", "36", "37", "38", "39", "40", "41", "42", "43", "44", "45", "46", "47", "48", "49", "50", "51", "52", "53", "54", "55", "56", "57", "58", "59"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Settings"
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let refresh = Refresh.MR_findFirst()
        
        if refresh.refreshFlag != nil {
        
            refreshFlag = refresh.refreshFlag as! Double
            h = Int(refresh.hours!)
            m = Int(refresh.minutes!)
            s = Int(refresh.seconds!)
            
            picker1.selectRow(h, inComponent: 0, animated: true)
            picker2.selectRow(m, inComponent: 0, animated: true)
            picker3.selectRow(s, inComponent: 0, animated: true)
            
        } else {
        
            manager.addRefresh(2, hours: 0, minutes: 0, seconds: 0)
            refreshFlag = 2
        }
        
        if refreshFlag == 2 {
            
            refreshSwitch.setOn(false, animated: false)
            picker1.userInteractionEnabled = false
            picker2.userInteractionEnabled = false
            picker3.userInteractionEnabled = false
            
            
        } else {
            
            refreshSwitch.setOn(true, animated: false)
            picker1.userInteractionEnabled = true
            picker2.userInteractionEnabled = true
            picker3.userInteractionEnabled = true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    override func viewWillDisappear(animated : Bool) {
        super.viewWillDisappear(animated)
        
        let refresh = Refresh.MR_findFirst()
        
        if refresh.refreshFlag != nil {
            
            let sum1 = Int(refresh.hours!) + Int(refresh.minutes!) + Int(refresh.seconds!)
            let sum2 = h + m + s
            
            if (refreshFlag != Double(refresh.refreshFlag!) || sum1 != sum2) {
                
                if refreshFlag == 2 || (refreshFlag == 1 && sum2 > 0) {
                
                    let alert = UIAlertController(title: "Alert", message: "Settings have changed! Auto-refresh can only be performed on Current Screen." , preferredStyle: UIAlertControllerStyle.Alert)
                
                    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
                        UIAlertAction in
                        self.manager.updateRefresh(self.refreshFlag, hours: self.h, minutes: self.m, seconds: self.s)
                    }
                    alert.addAction(okAction)
                    self.presentViewController(alert, animated: true, completion: nil)
                
                } else {
                
                    let alert = UIAlertController(title: "Alert", message: "Auto-refresh timer cannot be zero!" , preferredStyle: UIAlertControllerStyle.Alert)
                
                    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
                        UIAlertAction in
                }
                    alert.addAction(okAction)
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    func numberOfComponentsInPickerView(PickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if (pickerView.tag == 0) {
            
            return hours.count * 1000
            
        } else if (pickerView.tag == 1){
            
            return minutes.count * 1000
            
        } else {
            
            return seconds.count * 1000
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if (pickerView.tag == 0) {
            
            return (hours[row % hours.count])
            
        } else if (pickerView.tag == 1){
            
            return (minutes[row % minutes.count])
            
        } else {
            return (seconds[row % seconds.count])
            
        }
    }
    
    func pickerView(pickerView: UIPickerView, let didSelectRow row: Int, inComponent component: Int) {
        
        if (pickerView.tag == 0) {
            
            h = row % hours.count
            
        } else if (pickerView.tag == 1){
            
            m = row % minutes.count

        } else {
            
            s = row % seconds.count
        }
    }
}
