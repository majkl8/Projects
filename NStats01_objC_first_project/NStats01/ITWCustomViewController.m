//
//  ITWCustomViewController.m
//  NStats01
//
//  Created by Majkl on 16/07/14.
//  Copyright (c) 2014 Majkl. All rights reserved.
//

#import "ITWCustomViewController.h"
#import "ITWStatsViewController.h"
#import "ITWItemStore.h"
#import "ITWEvent.h"
#import "ITWActionViewController.h"
#import "ITWColor.h"
#import "ITWItemStore.h"

@interface ITWCustomViewController ()

@end

@implementation ITWCustomViewController

+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder
{
    return [[self alloc] init];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UINavigationItem *navItem = self.navigationItem;
        navItem.title = @"Add Custom Stat";
        
        UIBarButtonItem *doneBarItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(done:)];
        
        self.navigationItem.rightBarButtonItem = doneBarItem;
        
        self.restorationIdentifier = NSStringFromClass([self class]);
        self.restorationClass = [self class];
        
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferredContentSizeChanged:) name:UIContentSizeCategoryDidChangeNotification object:nil];

    return self;
}

- (void)back:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)done:(id)sender
{
    if (self.customStatField.text && self.customStatField.text.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Warning!" message: @"Please enter Custom Stat!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        [alert show];

    } else {
    
        self.sDict2 = [[NSMutableDictionary alloc] init];
    
        NSDate *d1 = [NSDate date];
    
        [[ITWItemStore sharedStore] openDatabase];
    
        [[ITWItemStore sharedStore] addToStats:self.event.eventKey subjectName:self.event.subjectName statName:self.customStatField.text statValue:0 dateCreated:[d1 timeIntervalSince1970] dateModified:[d1 timeIntervalSince1970]];
    
        self.sDict2 = [[ITWItemStore sharedStore] loadStatsAndValues:self.event.eventKey];
    
        [[ITWItemStore sharedStore] closeDatabase];
    
        ITWActionViewController *avc = [[ITWActionViewController alloc] init];
        
        [self.navigationController pushViewController:avc animated:YES];
        
        avc.event = self.event;
        avc.sDict2 = self.sDict2;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [[ITWItemStore sharedStore] openDatabase];
    
    self.events = [[[ITWItemStore sharedStore] loadEvents] mutableCopy];
    
    [[ITWItemStore sharedStore] closeDatabase];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    
    [self.view addGestureRecognizer:gestureRecognizer];
    
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

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.event.eventKey forKey:@"event.eventKey"];
    [coder encodeObject:self.event.subjectName forKey:@"event.subjectName"];
    [coder encodeObject:self.customStatField.text forKey:@"customStatField"];
    
    [super encodeRestorableStateWithCoder:coder];
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
    
    self.customStatField.text = customStatField;
    
    [super decodeRestorableStateWithCoder:coder];
    
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

- (void)preferredContentSizeChanged:(NSNotification *)notification
{
    UIFont *font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    
    self.customStatField.font = font;
}

- (void)dealloc
{
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter removeObserver:self];
}


@end
