//
//  ITWRenameStatController.m
//  NStats01
//
//  Created by Majkl on 09/08/14.
//  Copyright (c) 2014 Majkl. All rights reserved.
//

#import "ITWRenameStatController.h"
#import "ITWActionViewController.h"
#import "ITWItemStore.h"
#import "ITWEvent.h"

@interface ITWRenameStatController ()

@end

@implementation ITWRenameStatController

+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder
{
    return [[self alloc] init];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UINavigationItem *navItem = self.navigationItem;
        navItem.title = @"Rename Stat";
        
        self.restorationIdentifier = NSStringFromClass([self class]);
        self.restorationClass = [self class];

    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferredContentSizeChanged:) name:UIContentSizeCategoryDidChangeNotification object:nil];

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[ITWItemStore sharedStore] openDatabase];
    
    self.events = [[[ITWItemStore sharedStore] loadEvents] mutableCopy];
    
    [[ITWItemStore sharedStore] closeDatabase];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    
    [self.view addGestureRecognizer:gestureRecognizer];

    self.statNameLabel.delegate = self;
    
    self.statNameLabel.text = self.event.customStat;
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"myColor"]) {
        
        self.setBackgroundColor = [UIColor whiteColor];
        
    } else {
        
        NSData *colorData = [[NSUserDefaults standardUserDefaults] objectForKey:@"myColor"];
        self.setBackgroundColor = [NSKeyedUnarchiver unarchiveObjectWithData:colorData];
    }
    self.view.backgroundColor = self.setBackgroundColor;
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

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    NSDate *d2 = [NSDate date];
    
    [[ITWItemStore sharedStore] openDatabase];
    
    [[ITWItemStore sharedStore] updateStatName:self.event.eventKey subjectName:self.event.subjectName newStatName:self.statNameLabel.text statName:self.event.customStat dateModified:[d2 timeIntervalSince1970]];
    
    [[ITWItemStore sharedStore] closeDatabase];
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
    [coder encodeObject:self.event.eventKey forKey:@"event.eventKey"];
    [coder encodeObject:self.event.subjectName forKey:@"event.subjectName"];
    [coder encodeObject:self.statNameLabel.text forKey:@"customStatField"];
    
    [super encodeRestorableStateWithCoder:coder];
    
    NSDate *d2 = [NSDate date];
    
    [[ITWItemStore sharedStore] openDatabase];
    
    [[ITWItemStore sharedStore] updateStatName:self.event.eventKey subjectName:self.event.subjectName newStatName:self.statNameLabel.text statName:self.event.customStat dateModified:[d2 timeIntervalSince1970]];
    
    [[ITWItemStore sharedStore] closeDatabase];

}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    NSString *eventKey = [coder decodeObjectForKey:@"event.eventKey"];
    
    for (ITWEvent *event in self.events) {
        if ([eventKey isEqualToString:event.eventKey]) {
            self.event = event;
            break;
        }
    }
    
    NSString *subjectName = [coder decodeObjectForKey:@"event.subjectName"];
    
    self.event.subjectName = subjectName;
    
    NSString *customStatField = [coder decodeObjectForKey:@"customStatField"];
    
    self.statNameLabel.text = customStatField;
    
    [super decodeRestorableStateWithCoder:coder];
}

- (void)preferredContentSizeChanged:(NSNotification *)notification
{
    UIFont *font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    
    self.statNameLabel.font = font;
    self.statLabel.font = font;
}

- (void)dealloc
{
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter removeObserver:self];
}


@end
