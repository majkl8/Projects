//
//  SettingsViewController.swift
//  UTemp
//
//  Created by Majkl on 07/02/16.
//  Copyright © 2016 Majkl. All rights reserved.
//

import UIKit

class AlarmViewController: UIViewController {

    var location = String()
    var minTemp = Double()
    var maxTemp = Double()
    var flag = Double()

    let manager = DataManager.shared
    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var minLabel: UILabel!
    @IBOutlet weak var maxLabel: UILabel!
    
    @IBOutlet weak var minSlider: UISlider!
    @IBOutlet weak var maxSlider: UISlider!
    
    @IBOutlet weak var switcher: UISwitch!
    @IBOutlet weak var refreshSwitch: UISwitch!
    
    weak var delegate: AlarmViewControllerProtocol?
    
    @IBAction func switchAlarm (sender: UISwitch) {
        
        if !sender.on {
            flag = 2
            minSlider.enabled = false
            maxSlider.enabled = false
            
        } else {
            flag = 1
            minSlider.enabled = true
            maxSlider.enabled = true
        }
    }
    
    @IBAction func minSliderChanged(sender: UISlider) {
        
        let value = Double(sender.value)
        minLabel.text = NSString(format: "%.1f", value) as String + " °C"
        minTemp = value
    }
    
    @IBAction func maxSliderChanged(sender: UISlider) {
        
        let value = Double(sender.value)
        maxLabel.text = NSString(format: "%.1f", value) as String + " °C"
        maxTemp = value
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if flag == 2 {
            switcher.setOn(false, animated: false)
            minSlider.enabled = false
            maxSlider.enabled = false
        } else {
            switcher.setOn(true, animated: false)
            minSlider.enabled = true
            maxSlider.enabled = true
        }

        locationLabel.text = location
        minLabel.text = NSString(format: "%.1f", minTemp) as String + " °C"
        maxLabel.text = NSString(format: "%.1f", maxTemp) as String + " °C"
        minSlider.value = Float(minTemp)
        maxSlider.value = Float(maxTemp)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

        
    }
    
    override func viewWillDisappear(animated : Bool) {
        super.viewWillDisappear(animated)
        
        if (self.isMovingFromParentViewController()) {

            manager.updateSetting(location, min: minTemp, max: maxTemp, flag: flag, completion: { (result) in
                
                if result == 1 {
                    
                    self.delegate!.dismissAlarmViewController()
                    
                }
            })
        }
    }
}
