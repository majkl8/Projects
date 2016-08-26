//
//  ITWItemCell.m
//  Stats
//
//  Created by Majkl on 30/05/14.
//  Copyright (c) 2014 Majkl. All rights reserved.
//

#import "ITWItemCell.h"

@interface ITWItemCell ()

@end

@implementation ITWItemCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.valueLabel.delegate = self;
}

- (id)initWithDelegate:(id)parent reuseIdentifier:(NSString *)reuseIdentifier
{
    
    if (self = [self initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        self = (ITWItemCell*)[[[NSBundle mainBundle] loadNibNamed:@"ITWItemCell" owner:nil options:nil] lastObject];
    }
    
    //If you want any delegate methods and if cell have delegate protocol defined
    self.delegate = parent;
    
    //return cell
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (IBAction)stepperCounter:(UIStepper *)sender
{
    [self.delegate stepperPressed:self];
}

- (IBAction)resetCounter:(UIButton *)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning!" message:@"Do you want to reset the counter?" delegate:self cancelButtonTitle:@"Cancel"otherButtonTitles:@"OK", nil];
    
    [alert show];
}

- (IBAction)renameStatName:(id)sender
{
    [self.delegate renameStat:self];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.delegate resetPressed:self];
    
    if (buttonIndex == [alertView cancelButtonIndex]) {
        alertView = nil;
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string length] == 0 && range.length > 0)
    {
        textField.text = [textField.text stringByReplacingCharactersInRange:range withString:string];
        return NO;
    }
    
    NSCharacterSet *nonNumberSet = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet];
    if ([string stringByTrimmingCharactersInSet:nonNumberSet].length > 0)return YES;
    
    return NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self.delegate textEdited:self];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //hide the keyboard
    [textField resignFirstResponder];
    
    //return NO or YES, it doesn't matter
    return YES;
}

- (void)willTransitionToState:(UITableViewCellStateMask)state
{
    [super willTransitionToState:state];
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
    
        if (state & UITableViewCellStateShowingDeleteConfirmationMask) {
            self.valueLabel.hidden = YES;
        } else {
            self.valueLabel.hidden = NO;
        }
        
    } else {
        
        self.valueLabel.hidden = NO;
    }
}

@end
