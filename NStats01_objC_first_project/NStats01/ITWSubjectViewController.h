//
//  ITWSubjectViewController.h
//  Stats
//
//  Created by Majkl on 11/05/14.
//  Copyright (c) 2014 Majkl. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ITWEvent;

@interface ITWSubjectViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIViewControllerRestoration>

@property (weak, nonatomic) IBOutlet UITextField *subjectNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *subjectLabel;
@property (weak, nonatomic) IBOutlet UILabel *addStatLabel;

@property (strong, nonatomic) UILabel *addSubjectLabel;
@property (strong, nonatomic) UILabel *pickSubjectLabel;

@property (nonatomic) UIColor *setBackgroundColor;

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) ITWEvent *event;
@property (nonatomic, strong) NSArray *events;

@property (nonatomic, strong) NSMutableArray *sArray;

- (IBAction)addStats:(id)sender;

@end
