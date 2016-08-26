//
//  ITWRenameStatController.h
//  NStats01
//
//  Created by Majkl on 09/08/14.
//  Copyright (c) 2014 Majkl. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ITWEvent;

@interface ITWRenameStatController : UIViewController <UITextFieldDelegate, UIViewControllerRestoration>

@property (weak, nonatomic) IBOutlet UITextField *statNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *statLabel;

@property (nonatomic, strong) NSMutableDictionary *sDict2;

@property (nonatomic) UIColor *setBackgroundColor;

@property (nonatomic, strong) ITWEvent *event;
@property (nonatomic, strong) NSArray *events;

@end
