//
//  ITWRenameSubjectController.m
//  NStats01
//
//  Created by Majkl on 24/07/14.
//  Copyright (c) 2014 Majkl. All rights reserved.
//

#import "ITWRenameSubjectController.h"
#import "ITWRenameEventController.h"
#import "ITWEvent.h"
#import "ITWItemStore.h"
#import "ITWColor.h"

@interface ITWRenameSubjectController ()

@end

@implementation ITWRenameSubjectController

+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder
{
    return [[self alloc] init];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UINavigationItem *navItem = self.navigationItem;
        navItem.title = @"Rename Subject";
        
        self.restorationIdentifier = NSStringFromClass([self class]);
        self.restorationClass = [self class];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferredContentSizeChanged:) name:UIContentSizeCategoryDidChangeNotification object:nil];

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    
    [self.view addGestureRecognizer:gestureRecognizer];

    [[ITWItemStore sharedStore] openDatabase];
    
    self.events = [[[ITWItemStore sharedStore] loadEvents] mutableCopy];
    
    [[ITWItemStore sharedStore] closeDatabase];
    
    self.subjectNameLabel.delegate = self;
    
    self.subjectNameLabel.text = self.event.subjectName;
    
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

    [[ITWItemStore sharedStore] updateSubject:self.event.eventKey subjectName:self.event.subjectName newSubjectName:self.subjectNameLabel.text dateModified:[d2 timeIntervalSince1970]];
    [[ITWItemStore sharedStore] updateSubjectInStats:self.event.eventKey subjectName:self.event.subjectName newSubjectName:self.subjectNameLabel.text dateModified:[d2 timeIntervalSince1970]];
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
    [coder encodeObject:self.subjectNameLabel.text forKey:@"subjectNameLabel"];

    [super encodeRestorableStateWithCoder:coder];
    
    NSDate *d2 = [NSDate date];
    
    [[ITWItemStore sharedStore] openDatabase];
    [[ITWItemStore sharedStore] updateSubject:self.event.eventKey subjectName:self.event.subjectName newSubjectName:self.subjectNameLabel.text dateModified:[d2 timeIntervalSince1970]];
    [[ITWItemStore sharedStore] updateSubjectInStats:self.event.eventKey subjectName:self.event.subjectName newSubjectName:self.subjectNameLabel.text dateModified:[d2 timeIntervalSince1970]];
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

    NSString *subjectNameLabel = [coder decodeObjectForKey:@"subjectNameLabel"];
    self.subjectNameLabel.text = subjectNameLabel;
    
    self.event.subjectName = self.subjectNameLabel.text;

    [super decodeRestorableStateWithCoder:coder];
}

- (void)preferredContentSizeChanged:(NSNotification *)notification
{
    UIFont *font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    
    self.subjectNameLabel.font = font;
    self.subjectLabel.font = font;
}

- (void)dealloc
{
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter removeObserver:self];
}


@end
