//
//  ITWActionViewController.h
//  Stats
//
//  Created by Majkl on 25/05/14.
//  Copyright (c) 2014 Majkl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ITWItemCell.h"

@class ITWEvent;

@interface ITWActionViewController : UITableViewController <UITextFieldDelegate, ITWItemCellDelegate, UIViewControllerRestoration>

@property (nonatomic, strong) NSMutableArray *tempArray3;
@property (nonatomic, strong) NSMutableArray *tempArray4;
@property (nonatomic, strong) NSMutableArray *tempArray5;

@property (nonatomic, strong) NSMutableArray *section;

@property (nonatomic, strong) NSMutableDictionary *sDict1;
@property (nonatomic, strong) NSMutableDictionary *sDict2;

@property (nonatomic) UIColor *setBackgroundColor;

@property (nonatomic, strong) ITWEvent *event;
@property (nonatomic, strong) NSArray *events;

@property (nonatomic, copy) void (^dismissBlock)(void);

@end
