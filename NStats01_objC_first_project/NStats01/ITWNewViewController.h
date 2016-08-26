//
//  ITWNewViewController.h
//  Stats
//
//  Created by Majkl on 10/05/14.
//  Copyright (c) 2014 Majkl. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ITWEvent;

@interface ITWNewViewController : UIViewController <UITextFieldDelegate, UIViewControllerRestoration>

@property (weak, nonatomic) IBOutlet UITextField *eventNameLabel;
@property (weak, nonatomic) IBOutlet UITextField *locationNameLabel;
@property (strong, nonatomic) IBOutlet UIDatePicker *dateCreatedPicker;
@property (strong, nonatomic) NSString *key;
@property (nonatomic) UIColor *setBackgroundColor;

@property (weak, nonatomic) IBOutlet UILabel *eventLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;

@property (strong, nonatomic) UILabel *addNewLabel;
@property (strong, nonatomic) UILabel *dateLabel;

@property (nonatomic, strong) ITWEvent *event;

@end
