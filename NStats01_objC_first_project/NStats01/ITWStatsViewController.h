//
//  ITWStatsViewController.h
//  Stats
//
//  Created by Majkl on 12/05/14.
//  Copyright (c) 2014 Majkl. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ITWEvent;

@interface ITWStatsViewController : UITableViewController <UIViewControllerRestoration>

@property (nonatomic, strong) NSArray *allStats;
@property (nonatomic, strong) NSArray *allSports;
@property (nonatomic, strong) NSArray *allHome;
@property (nonatomic, strong) NSArray *allCompulsive;
@property (nonatomic, strong) NSMutableArray *tempArray;

@property (nonatomic, strong) ITWEvent *event;
@property (nonatomic, strong) NSArray *events;

@property (nonatomic) UIColor *setBackgroundColor;

@end
