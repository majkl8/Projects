//
//  ITWSportViewController.h
//  Stats
//
//  Created by Majkl on 13/05/14.
//  Copyright (c) 2014 Majkl. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ITWEvent;

@interface ITWSportViewController : UITableViewController <UIViewControllerRestoration>

@property (nonatomic, strong) NSMutableArray *tempArray;
@property (nonatomic, strong) NSMutableArray *tempArray2;

@property (nonatomic, strong) NSArray *allFootball;
@property (nonatomic, strong) NSArray *allBasketball;
@property (nonatomic, strong) NSArray *allTennis;
@property (nonatomic, strong) NSArray *allVolleyball;
@property (nonatomic, strong) NSArray *allHockey;
@property (nonatomic, strong) NSArray *allWaterpolo;
@property (nonatomic, strong) NSArray *allBaseball;
@property (nonatomic, strong) NSArray *allCricket;
@property (nonatomic, strong) NSArray *allSnooker;
@property (nonatomic, strong) NSArray *allRugby;

@property (nonatomic, strong) NSArray *allElectronics;
@property (nonatomic, strong) NSArray *allTools;
@property (nonatomic, strong) NSArray *allFurniture;
@property (nonatomic, strong) NSArray *allCreatures;

@property (nonatomic, strong) NSArray *allWeird;
@property (nonatomic, strong) NSArray *allBlack;
@property (nonatomic, strong) NSArray *allWhite;

@property (nonatomic, strong) ITWEvent *event;
@property (nonatomic, strong) NSArray *events;

@property (nonatomic) UIColor *setBackgroundColor;

@end
