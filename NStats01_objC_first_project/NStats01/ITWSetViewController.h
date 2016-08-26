//
//  ITWSetViewController.h
//  Stats
//
//  Created by Majkl on 14/05/14.
//  Copyright (c) 2014 Majkl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ITWSetViewController : UIViewController <UIViewControllerRestoration>

@property (nonatomic, weak) IBOutlet UISlider *redSlider1;
@property (nonatomic, weak) IBOutlet UISlider *greenSlider1;
@property (nonatomic, weak) IBOutlet UISlider *blueSlider1;

@property (nonatomic) UIColor *setBackgroundColor;

@property (strong, nonatomic) UILabel *colorLabel;
@property (strong, nonatomic) UILabel *redLabel;
@property (strong, nonatomic) UILabel *greenLabel;
@property (strong, nonatomic) UILabel *blueLabel;

@end
