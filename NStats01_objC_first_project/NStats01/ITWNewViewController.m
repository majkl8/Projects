//
//  ITWNewViewController.m
//  Stats
//
//  Created by Majkl on 10/05/14.
//  Copyright (c) 2014 Majkl. All rights reserved.
//

#import "ITWNewViewController.h"
#import "ITWFirstViewController.h"
#import "ITWSubjectViewController.h"
#import "ITWEvent.h"
#import "ITWItemStore.h"
#import "ITWColor.h"

@interface ITWNewViewController ()

@end

@implementation ITWNewViewController

+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder
{
    return [[self alloc] init];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UINavigationItem *navItem = self.navigationItem;
        navItem.title = @"Event Information";
        
        UIBarButtonItem *doneBarItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(done:)];

        self.navigationItem.rightBarButtonItem = doneBarItem;
        
        self.restorationIdentifier = NSStringFromClass([self class]);
        self.restorationClass = [self class];
        
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferredContentSizeChanged:) name:UIContentSizeCategoryDidChangeNotification object:nil];
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.eventNameLabel.delegate = self;
    self.locationNameLabel.delegate = self;
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    
    [self.view addGestureRecognizer:gestureRecognizer];
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"myColor"]) {
        
        self.setBackgroundColor = [UIColor whiteColor];
        
    } else {
        
        NSData *colorData = [[NSUserDefaults standardUserDefaults] objectForKey:@"myColor"];
        self.setBackgroundColor = [NSKeyedUnarchiver unarchiveObjectWithData:colorData];
    }

    self.view.backgroundColor = self.setBackgroundColor;
    
    self.addNewLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 64, 320, 20)];
    self.addNewLabel.text = @"Add Event Data";
    [self.addNewLabel setTextColor:[UIColor blackColor]];
    [self.addNewLabel setBackgroundColor:[UIColor lightTextColor]];

    self.addNewLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.addNewLabel];
    
    self.dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 200, 320, 20)];
    self.dateLabel.text = @"Pick the Event Date";
    [self.dateLabel setTextColor:[UIColor blackColor]];
    [self.dateLabel setBackgroundColor:[UIColor lightTextColor]];

    self.dateLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.dateLabel];

    
    [self preferredContentSizeChanged:nil];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self preferredContentSizeChanged:nil];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)back:(id)sender
{   
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)done:(id)sender
{
    if ((self.eventNameLabel.text && self.eventNameLabel.text.length == 0) || (self.locationNameLabel.text && self.locationNameLabel.text.length == 0)) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Warning!" message: @"Please enter data in both text fields!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        [alert show];
        
    } else {
        
        [[ITWItemStore sharedStore] openDatabase];
        
        if (![[ITWItemStore sharedStore] getEvent:self.eventNameLabel.text eventLocation:self.locationNameLabel.text eventDate:[self.dateCreatedPicker.date timeIntervalSince1970]]) {
            
            ITWSubjectViewController *svc = [[ITWSubjectViewController alloc] init];
            
            [self.navigationController pushViewController:svc animated:YES];
            
            NSUUID *uuid = [[NSUUID alloc] init];
            self.key = [uuid UUIDString];
    
            NSDate *d2 = [NSDate date];
            NSDate *d3 = [NSDate date];
    
            ITWEvent *event1 = [[ITWEvent alloc] init];
    
            event1.eventKey = self.key;
            event1.eventName = self.eventNameLabel.text;
            event1.eventLocation = self.locationNameLabel.text;
            event1.eventDate = [self.dateCreatedPicker.date timeIntervalSince1970];
            event1.subjectName = nil;
            event1.subjectDate = 0;
            event1.customStat = nil;
    
            [[ITWItemStore sharedStore] addToEvent:event1.eventKey eventName:event1.eventName eventLocation:event1.eventLocation eventDate:event1.eventDate dateCreated:[d2 timeIntervalSince1970] dateModified:[d3 timeIntervalSince1970]];
    
            [[ITWItemStore sharedStore] closeDatabase];
        
            svc.event = event1;
            
        } else {
            
            [[ITWItemStore sharedStore] openDatabase];
            
            ITWSubjectViewController *svc = [[ITWSubjectViewController alloc] init];
            
            [self.navigationController pushViewController:svc animated:YES];
            
            ITWEvent *event1 = [[ITWEvent alloc] init];
            
            event1.eventKey = [[ITWItemStore sharedStore] getEventKey:self.eventNameLabel.text eventLocation:self.locationNameLabel.text eventDate:[self.dateCreatedPicker.date timeIntervalSince1970]];
            event1.eventName = self.eventNameLabel.text;
            event1.eventLocation = self.locationNameLabel.text;
            event1.eventDate = [self.dateCreatedPicker.date timeIntervalSince1970];
            event1.subjectName = nil;
            event1.subjectDate = 0;
            event1.customStat = nil;
            
            svc.event = event1;
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // Clear first responder
    [self.view endEditing:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //hide the keyboard
    [textField resignFirstResponder];
        
    //return NO or YES, it doesn't matter
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
}

- (void)hideKeyboard
{
    [self.view endEditing:NO];
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.eventNameLabel.text forKey:@"eventNameLabel"];
    [coder encodeObject:self.locationNameLabel.text forKey:@"locationNameLabel"];
    
    if (!self.dateCreatedPicker.date) {
        self.dateCreatedPicker.date = [NSDate date];
    }
    
    [coder encodeObject:self.dateCreatedPicker.date forKey:@"dateCreatedPicker"];

    [super encodeRestorableStateWithCoder:coder];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    NSString *eventNameLabel = [coder decodeObjectForKey:@"eventNameLabel"];
    self.eventNameLabel.text = eventNameLabel;
    
    NSString *locationNameLabel = [coder decodeObjectForKey:@"locationNameLabel"];
    self.locationNameLabel.text = locationNameLabel;
    
    NSDate *dateCreatedPicker = [coder decodeObjectForKey:@"dateCreatedPicker"];
    self.dateCreatedPicker.date = dateCreatedPicker;
    
    [super decodeRestorableStateWithCoder:coder];
}

- (void)preferredContentSizeChanged:(NSNotification *)notification
{
    UIFont *font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    
    self.eventLabel.font = font;
    self.locationLabel.font = font;
    self.eventNameLabel.font = font;
    self.locationNameLabel.font = font;
    
    UIFont *font1 = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    
    self.addNewLabel.font = font1;
    self.dateLabel.font = font1;
}

- (void)dealloc
{
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter removeObserver:self];
}


@end
