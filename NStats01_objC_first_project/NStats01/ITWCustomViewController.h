//
//  ITWCustomViewController.h
//  NStats01
//
//  Created by Majkl on 16/07/14.
//  Copyright (c) 2014 Majkl. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ITWEvent;

@interface ITWCustomViewController : UIViewController <UIViewControllerRestoration>

@property (weak, nonatomic) IBOutlet UITextField *customStatField;

@property (nonatomic, strong) NSMutableDictionary *sDict2;
@property (nonatomic) UIColor *setBackgroundColor;

@property (nonatomic, strong) ITWEvent *event;
@property (nonatomic, strong) NSArray *events;

@end
