//
//  ITWFirstViewController.h
//  Stats
//
//  Created by Majkl on 10/05/14.
//  Copyright (c) 2014 Majkl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ITWFirstViewController : UIViewController <UIViewControllerRestoration>

@property (weak, nonatomic) IBOutlet UILabel *nObs;
@property (weak, nonatomic) IBOutlet UILabel *lObs;
@property (weak, nonatomic) IBOutlet UILabel *sett;

- (IBAction)newObservation:(id)sender;

- (IBAction)loadObservation:(id)sender;

- (IBAction)settings:(id)sender;

@property (nonatomic) UIColor *setBackgroundColor;

@end
