//
//  ITWRenameEventController.h
//  NStats01
//
//  Created by Majkl on 23/07/14.
//  Copyright (c) 2014 Majkl. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ITWEvent;

@interface ITWRenameEventController : UIViewController <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UIViewControllerRestoration, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *eventNameLabel;
@property (weak, nonatomic) IBOutlet UITextField *locationNameLabel;
@property (strong, nonatomic) IBOutlet UIDatePicker *dateCreatedPicker;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollview;
@property (strong, nonatomic) IBOutlet UITableView *subjectTable;

@property (weak, nonatomic) IBOutlet UILabel *eventLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;

@property (strong, nonatomic) UILabel *changeEvent;
@property (strong, nonatomic) UILabel *renameLabel;
@property (strong, nonatomic) UILabel *dateLabel;

@property (nonatomic) UIColor *setBackgroundColor;
@property (nonatomic, strong) NSArray *events;

@property (nonatomic, strong) ITWEvent *event;

@property (nonatomic, strong) NSMutableArray *sArray;

@end
