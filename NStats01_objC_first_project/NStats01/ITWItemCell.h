//
//  ITWItemCell.h
//  Stats
//
//  Created by Majkl on 30/05/14.
//  Copyright (c) 2014 Majkl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class ITWItemCell;

@protocol ITWItemCellDelegate

- (void)stepperPressed:(ITWItemCell *)cell;
- (void)resetPressed:(ITWItemCell *)cell;
- (void)textEdited:(ITWItemCell *)cell;
- (void)renameStat:(ITWItemCell *)cell;

@end

@interface ITWItemCell : UITableViewCell <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *statLabel;
@property (weak, nonatomic) IBOutlet UITextField *valueLabel;

@property (weak, nonatomic) IBOutlet UIStepper *stepper;

@property (weak, nonatomic) NSString *subName;
@property (nonatomic, assign) id <ITWItemCellDelegate> delegate;

- (id)initWithDelegate:(id)parent reuseIdentifier:(NSString *)reuseIdentifier;

@end
