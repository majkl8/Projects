//
//  ITWTicsTableViewController.m
//  Stats
//
//  Created by Majkl on 21/05/14.
//  Copyright (c) 2014 Majkl. All rights reserved.
//

#import "ITWTicsTableViewController.h"
#import "ITWSportViewController.h"
#import "ITWActionViewController.h"
#import "ITWNewViewController.h"
#import "ITWEvent.h"
#import "ITWItemStore.h"
#import "ITWColor.h"

@interface ITWTicsTableViewController ()

@end

@implementation ITWTicsTableViewController

+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder
{
    return [[self alloc] init];
}

- (instancetype)init
{
    // Call the superclass's designated initializer
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        UINavigationItem *navItem = self.navigationItem;
        navItem.title = @"Add Statistics";
        
        UIBarButtonItem *doneBarItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(done:)];

        //navItem.leftBarButtonItem = backBarItem;
        navItem.rightBarButtonItem = doneBarItem;
        
        self.restorationIdentifier = NSStringFromClass([self class]);
        self.restorationClass = [self class];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferredContentSizeChanged:) name:UIContentSizeCategoryDidChangeNotification object:nil];

    return self;
}

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    return [self init];
}

- (void)back:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];

    self.tempArray3 = [[NSMutableArray alloc] init];
    
    if (!self.tempArray4a) {
        self.tempArray4a = [[NSMutableArray alloc] init];
    }

    self.tempArray4b = [[NSMutableArray alloc] init];
    
    [[ITWItemStore sharedStore] openDatabase];
    
    self.events = [[[ITWItemStore sharedStore] loadEvents] mutableCopy];
    
    [[ITWItemStore sharedStore] closeDatabase];
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"myColor"]) {
        
        self.setBackgroundColor = [UIColor whiteColor];
        
    } else {
        
        NSData *colorData = [[NSUserDefaults standardUserDefaults] objectForKey:@"myColor"];
        self.setBackgroundColor = [NSKeyedUnarchiver unarchiveObjectWithData:colorData];
    }

    if (!self.tempArray2) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSMutableArray *defaultArray = [userDefaults objectForKey:@"self.tempArray2"];
        
        self.tempArray2 = defaultArray;
    }

    self.view.backgroundColor = self.setBackgroundColor;
}

- (void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    
    [self preferredContentSizeChanged:nil];
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.tempArray2 count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"UITableViewCell"];
    
    if (cell == nil)  {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"UITableViewCell"];
    }
    
    cell.textLabel.text = [self.tempArray2 objectAtIndex:indexPath.row];
    
    [[ITWItemStore sharedStore] openDatabase];
    
    if ([[ITWItemStore sharedStore] getStat:self.event.eventKey subjectName:self.event.subjectName statName:[self.tempArray2 objectAtIndex:indexPath.row]]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        
        if (![self.tempArray4a containsObject:cell.textLabel.text] && ![self.tempArray4b containsObject:cell.textLabel.text]) {
        
            [self.tempArray4a addObject:[self.tempArray2 objectAtIndex:indexPath.row]];
            [self.tempArray4b removeObject:[self.tempArray2 objectAtIndex:indexPath.row]];

        }
            
        NSString *value = [[ITWItemStore sharedStore] getStatValue:self.event.eventKey subjectName:self.event.subjectName statName:[self.tempArray2 objectAtIndex:indexPath.row]];
        
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Current value = %@", value];
        
    } else {

        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    [[ITWItemStore sharedStore] closeDatabase];
    
    if ([self.tempArray4a containsObject:cell.textLabel.text]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    
    return cell;
}

- (void)done:(id)sender
{
    self.sDict2 = [[NSMutableDictionary alloc] init];

    [[ITWItemStore sharedStore] openDatabase];
    
    for (int i = 0; i < [self.tempArray4a count]; i++) {
        
        NSString *sValue = [[ITWItemStore sharedStore] getStatValue:self.event.eventKey subjectName:self.event.subjectName statName:[self.tempArray4a objectAtIndex:i]];
        
        if (sValue == nil) {
            
            [self.tempArray3 addObject:[self.tempArray4a objectAtIndex:i]];
            
            NSDate *d1 = [NSDate date];
            
            [[ITWItemStore sharedStore] addToStats:self.event.eventKey subjectName:self.event.subjectName statName:[self.tempArray4a objectAtIndex:i] statValue:0 dateCreated:[d1 timeIntervalSince1970] dateModified:[d1 timeIntervalSince1970]];
            
        }
    }

    self.sDict2 = [[ITWItemStore sharedStore] loadStatsAndValues:self.event.eventKey];

    if ([self.tempArray4a count] == 0) {
    
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Warning!" message: @"Select Stat or go back and Select different Object or Theme" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    
        [alert show];
        
    } else {
        
        for (int i = 0; i < [self.tempArray4b count]; i++) {
            
            [[ITWItemStore sharedStore] deleteStat:self.event.eventKey subjectName:self.event.subjectName statName:[self.tempArray4b objectAtIndex:i]];
            
            if ([[self.sDict2 objectForKey:self.event.subjectName] objectForKey:[self.tempArray4b objectAtIndex:i]]) {
                [[self.sDict2 objectForKey:self.event.subjectName] removeObjectForKey:[self.tempArray4b objectAtIndex:i]];
            }
        }
        
    [[ITWItemStore sharedStore] closeDatabase];
        
    ITWActionViewController *avc = [[ITWActionViewController alloc] init];
        
    [self.navigationController pushViewController:avc animated:YES];
        
    avc.event = self.event;
    avc.tempArray3 = self.tempArray3;
    avc.sDict2 = self.sDict2;
    }
}
 
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        [self.tempArray4a removeObject:cell.textLabel.text];
        [self.tempArray4b addObject:cell.textLabel.text];
        
    } else if (cell.accessoryType == UITableViewCellAccessoryNone && ![self.tempArray4a containsObject:cell.textLabel.text]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        
        [self.tempArray4a addObject:cell.textLabel.text];
        [self.tempArray4b removeObject:cell.textLabel.text];
    }
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = self.setBackgroundColor;
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.event.eventKey forKey:@"event.eventKey"];
    [coder encodeObject:self.event.subjectName forKey:@"event.subjectName"];
    [coder encodeObject:self.tempArray4a forKey:@"self.tempArray4a"];
    
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
    
    NSMutableArray *array4a = [coder decodeObjectForKey:@"self.tempArray4a"];
    
    self.tempArray4a = array4a;
    
    [super decodeRestorableStateWithCoder:coder];
}

- (void)preferredContentSizeChanged:(NSNotification *)notification
{
    [self.tableView reloadData];
}

- (void)dealloc
{
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter removeObserver:self];
}

@end
