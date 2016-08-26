//
//  ITWFirstViewController.m
//  Stats
//
//  Created by Majkl on 10/05/14.
//  Copyright (c) 2014 Majkl. All rights reserved.
//

#import "ITWFirstViewController.h"
#import "ITWNewViewController.h"
#import "ITWLoadViewController.h"
#import "ITWSetViewController.h"
#import "ITWItemStore.h"
#import "ITWColor.h"

@interface ITWFirstViewController ()

@end

@implementation ITWFirstViewController

+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder
{
    return [[self alloc] init];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        UINavigationItem *navItem = self.navigationItem;
        navItem.title = @"Manage Events";
        
        self.restorationIdentifier = NSStringFromClass([self class]);
        self.restorationClass = [self class];
    }
    
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(updateFonts) name:UIContentSizeCategoryDidChangeNotification object:nil];
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"myColor"]) {
        
        self.setBackgroundColor = [UIColor whiteColor];
        
    } else {
        
        NSData *colorData = [[NSUserDefaults standardUserDefaults] objectForKey:@"myColor"];
        self.setBackgroundColor = [NSKeyedUnarchiver unarchiveObjectWithData:colorData];
    }
    self.view.backgroundColor = self.setBackgroundColor;
    
    [self.navigationItem setHidesBackButton:YES animated:YES];
    
    [self updateFonts];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)newObservation:(id)sender
{
    ITWNewViewController *nvc = [[ITWNewViewController alloc] init];
    
    [self.navigationController pushViewController:nvc animated:YES];

}

- (IBAction)loadObservation:(id)sender
{
    ITWLoadViewController *lvc = [[ITWLoadViewController alloc] init];
    
    [self.navigationController pushViewController:lvc animated:YES];
}

- (IBAction)syncEvent:(id)sender
{
    
}

- (IBAction)settings:(id)sender
{
    ITWSetViewController *svc = [[ITWSetViewController alloc] init];
    
    [self.navigationController pushViewController:svc animated:YES];

}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super encodeRestorableStateWithCoder:coder];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super decodeRestorableStateWithCoder:coder];
}

- (void)updateFonts
{
    UIFont *font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    
    self.nObs.font = font;
    self.lObs.font = font;
    self.sett.font = font;
}

- (void)dealloc
{
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter removeObserver:self];
}

@end
