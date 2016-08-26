//
//  ViewController.swift
//  ProtoQR
//
//  Created by Majkl on 27/02/16.
//  Copyright © 2016 Majkl. All rights reserved.
//

import UIKit

class GenerateViewController: UIViewController {
    
    @IBOutlet weak var ItemTextField: UITextField!
    @IBOutlet weak var PriceTextField: UITextField!
    @IBOutlet weak var QuantityTextField: UITextField!
    
    @IBOutlet weak var imgQRCode: UIImageView!
    @IBOutlet weak var btnAction: UIButton!
    @IBOutlet weak var slider: UISlider!
    
    var qrcodeImage: CIImage!
    
    var uuid = String()
    var jsonText = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Generate QR"
        
        slider.hidden = true
        ItemTextField.hidden = false
        PriceTextField.hidden = false
        QuantityTextField.hidden = false
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @IBAction func performButtonAction(sender: AnyObject) {
        
        if qrcodeImage == nil {
            if ItemTextField.text == "" || PriceTextField.text == "" || QuantityTextField.text == "" {
                return
            }
            
            uuid = NSUUID().UUIDString
            
            let jsonObject: [String: AnyObject] = [
            "uuid" : uuid,
            "item" : ItemTextField.text!,
            "price" : PriceTextField.text!,
            "quantity" : QuantityTextField.text!
            ]
            
            do {
                let jsonData = try NSJSONSerialization.dataWithJSONObject(jsonObject, options: NSJSONWritingOptions.PrettyPrinted)

                jsonText = String(data: jsonData, encoding: NSASCIIStringEncoding)!
                
                print(jsonText)
                
            } catch let error as NSError {
                print(error)
            }
            
            let data = jsonText.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
            
            
            let filter = CIFilter(name: "CIQRCodeGenerator")
            
            filter!.setValue(data, forKey: "inputMessage")
            filter!.setValue("Q", forKey: "inputCorrectionLevel")
            
            let transform = CGAffineTransformMakeScale(10, 10)
            
            if let output = filter!.outputImage?.imageByApplyingTransform(transform) {
                qrcodeImage = output
            }
            
            imgQRCode.image = UIImage(CIImage: qrcodeImage)
    
            ItemTextField.resignFirstResponder()
            
            btnAction.setTitle("Clear", forState: UIControlState.Normal)
            
            
        } else {
            
            imgQRCode.image = nil
            qrcodeImage = nil
            btnAction.setTitle("Generate", forState: UIControlState.Normal)
            ItemTextField.text = ""
            PriceTextField.text = ""
            QuantityTextField.text = ""
            uuid = ""
        }
        
        ItemTextField.enabled = !ItemTextField.enabled
        PriceTextField.enabled = !PriceTextField.enabled
        QuantityTextField.enabled = !QuantityTextField.enabled
        slider.hidden = !slider.hidden
    }
    
    @IBAction func changeImageViewScale(sender: AnyObject) {
        
        imgQRCode.transform = CGAffineTransformMakeScale(CGFloat(slider.value), CGFloat(slider.value))
    }
    
    func displayQRCodeImage() {
        
        let scaleX = imgQRCode.frame.size.width / qrcodeImage.extent.size.width
        let scaleY = imgQRCode.frame.size.height / qrcodeImage.extent.size.height
        
        let transformedImage = qrcodeImage.imageByApplyingTransform(CGAffineTransformMakeScale(scaleX, scaleY))
        
        imgQRCode.image = UIImage(CIImage: transformedImage)
    
    }
}

