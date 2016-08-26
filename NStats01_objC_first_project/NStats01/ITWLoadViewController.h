//
//  ITWLoadViewController.h
//  Stats
//
//  Created by Majkl on 11/05/14.
//  Copyright (c) 2014 Majkl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ITWLoadViewController : UITableViewController <UIViewControllerRestoration>

@property (nonatomic, strong) NSArray *events;
@property (nonatomic, strong) NSMutableDictionary *sDict2;

@property (nonatomic) UIColor *setBackgroundColor;
@property (nonatomic, strong) UIButton *button;

@end
