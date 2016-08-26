//
//  ViewController.swift
//  Weather
//
//  Created by Majkl on 28/11/15.
//  Copyright © 2015 Majkl. All rights reserved.
//

import UIKit

enum WeatherIcon : String
{
    case Cloudy         = "cloudy"
    case Fog            = "fog"
    case Frost          = "frost"
    case Rain           = "rain"
    case Showers        = "showers"
    case Snowy          = "snowy"
    case SunRain        = "sun-rain"
    case PartlyCloudy   = "sunny-cloudy"
    case Sunny          = "sunny"
    case Thunder        = "thunder"
    case Empty          = "empty"
}

class WeatherIconView: UIView {
    
    var iconType : WeatherIcon = .Sunny {
        didSet {
            imageView.image = UIImage(named: iconType.rawValue)
        }
    }
    
    private var imageView : UIImageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView.image = UIImage(named: WeatherIcon.Sunny.rawValue)
        
        addSubview(imageView)
    }

    required init?(coder aDecoder: NSCoder) {

        super.init(coder: aDecoder)
        
        imageView.image = UIImage(named: WeatherIcon.Sunny.rawValue)
        
        addSubview(imageView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.frame = self.bounds
    }
}
