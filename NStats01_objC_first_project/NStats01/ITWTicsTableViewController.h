//
//  ITWTicsTableViewController.h
//  Stats
//
//  Created by Majkl on 21/05/14.
//  Copyright (c) 2014 Majkl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>

@class ITWEvent;

@interface ITWTicsTableViewController : UITableViewController <UIAlertViewDelegate, UIViewControllerRestoration>

@property (nonatomic, strong) NSMutableArray *tempArray2;
@property (nonatomic, strong) NSMutableArray *tempArray3;
@property (nonatomic, strong) NSMutableArray *tempArray4a;
@property (nonatomic, strong) NSMutableArray *tempArray4b;

@property (nonatomic, strong) NSMutableDictionary *sDict2;
@property (nonatomic) UIColor *setBackgroundColor;

@property (nonatomic, strong) ITWEvent *event;
@property (nonatomic, strong) NSArray *events;

@end
