//
//  ITWRenameSubjectController.h
//  NStats01
//
//  Created by Majkl on 24/07/14.
//  Copyright (c) 2014 Majkl. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ITWEvent;

@interface ITWRenameSubjectController : UIViewController <UITextFieldDelegate, UIViewControllerRestoration>

@property (weak, nonatomic) IBOutlet UITextField *subjectNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *subjectLabel;

@property (nonatomic) UIColor *setBackgroundColor;

@property (nonatomic, strong) ITWEvent *event;
@property (nonatomic, strong) NSArray *events;

@end
