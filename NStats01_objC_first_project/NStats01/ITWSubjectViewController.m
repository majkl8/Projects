//
//  ITWSubjectViewController.m
//  Stats
//
//  Created by Majkl on 11/05/14.
//  Copyright (c) 2014 Majkl. All rights reserved.
//

#import "ITWSubjectViewController.h"
#import "ITWNewViewController.h"
#import "ITWStatsViewController.h"
#import "ITWItemStore.h"
#import "ITWEvent.h"
#import "ITWActionViewController.h"
#import "ITWColor.h"

@interface ITWSubjectViewController ()

@end

@implementation ITWSubjectViewController

+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder
{
    return [[self alloc] init];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UINavigationItem *navItem = self.navigationItem;
        navItem.title = @"Add Subject";
        
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
    
    self.sArray = [[[ITWItemStore sharedStore] loadSubjects:self.event.eventKey] mutableCopy];
    self.events = [[[ITWItemStore sharedStore] loadEvents] mutableCopy];
    
    [[ITWItemStore sharedStore] closeDatabase];
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"myColor"]) {
        
        self.setBackgroundColor = [UIColor whiteColor];
        
    } else {
        
        NSData *colorData = [[NSUserDefaults standardUserDefaults] objectForKey:@"myColor"];
        self.setBackgroundColor = [NSKeyedUnarchiver unarchiveObjectWithData:colorData];
    }

    self.view.backgroundColor = self.setBackgroundColor;
    self.tableView.backgroundColor = self.setBackgroundColor;
    self.tableView.backgroundView = nil;
    
    self.addSubjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 64, 320, 20)];
    self.addSubjectLabel.text = @"Add New Subject";
    [self.addSubjectLabel setTextColor:[UIColor blackColor]];
    [self.addSubjectLabel setBackgroundColor:[UIColor lightTextColor]];
    self.addSubjectLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.addSubjectLabel];
    
    if ([self.sArray count] > 0) {
        self.pickSubjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 210, 320, 20)];
        self.pickSubjectLabel.text = @"Or Pick Existing One:";
        [self.pickSubjectLabel setTextColor:[UIColor blackColor]];
        [self.pickSubjectLabel setBackgroundColor:[UIColor lightTextColor]];
        self.pickSubjectLabel.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:self.pickSubjectLabel];
    }

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

- (IBAction)addStats:(id)sender
{
    if (self.subjectNameLabel.text && self.subjectNameLabel.text.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Warning!" message: @"Please enter Subject's name!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        [alert show];
    
    } else {
        
        ITWStatsViewController *svc = [[ITWStatsViewController alloc] init];
        
        [self.navigationController pushViewController:svc animated:YES];
    
        NSDate *d1 = [NSDate date];
    
        self.event.subjectName = self.subjectNameLabel.text;
        self.event.subjectDate = [d1 timeIntervalSince1970];
    
        [[ITWItemStore sharedStore] openDatabase];
        [[ITWItemStore sharedStore] addToSubject:self.event.eventKey subjectName:self.event.subjectName dateCreated:self.event.subjectDate dateModified:self.event.subjectDate];
        [[ITWItemStore sharedStore] closeDatabase];
    
        svc.event = self.event;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.sArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Create an instance of UITableViewCell, with default appearance
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
    
    if (cell == nil)  {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
    
    }
    
    cell.textLabel.text = [self.sArray objectAtIndex:indexPath.row];
    
    cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    
    return cell;

}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = self.setBackgroundColor;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    self.subjectNameLabel.text = [self.sArray objectAtIndex:indexPath.row];
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.event.eventKey forKey:@"event.eventKey"];
    [coder encodeObject:self.subjectNameLabel.text forKey:@"subjectNameLabel"];
    
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
    
    NSString *subjectNameLabel = [coder decodeObjectForKey:@"subjectNameLabel"];
    
    self.subjectNameLabel.text = subjectNameLabel;
    self.event.subjectName = self.subjectNameLabel.text;
    
    [super decodeRestorableStateWithCoder:coder];
    
    [[ITWItemStore sharedStore] openDatabase];
    
    self.sArray = [[[ITWItemStore sharedStore] loadSubjects:self.event.eventKey] mutableCopy];
    
    [[ITWItemStore sharedStore] closeDatabase];
}

- (void)preferredContentSizeChanged:(NSNotification *)notification
{
    [self.tableView reloadData];
    
    UIFont *font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    
    self.subjectLabel.font = font;
    self.subjectNameLabel.font = font;
    self.addStatLabel.font = font;
    
    UIFont *font1 = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    
    self.addSubjectLabel.font = font1;
    self.pickSubjectLabel.font = font1;
}

- (void)dealloc
{
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter removeObserver:self];
}


@end
