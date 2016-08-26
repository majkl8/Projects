//
//  ITWStatsViewController.m
//  Stats
//
//  Created by Majkl on 12/05/14.
//  Copyright (c) 2014 Majkl. All rights reserved.
//

#import "ITWStatsViewController.h"
#import "ITWSportViewController.h"
#import "ITWEvent.h"
#import "ITWCustomViewController.h"
#import "ITWColor.h"
#import "ITWItemStore.h"

@interface ITWStatsViewController ()

@end

@implementation ITWStatsViewController

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
        navItem.title = @"Add Theme";
        
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[ITWItemStore sharedStore] openDatabase];
    
    self.events = [[[ITWItemStore sharedStore] loadEvents] mutableCopy];
    
    [[ITWItemStore sharedStore] closeDatabase];

    self.allStats = [[NSArray alloc] initWithObjects:@"Sports", @"Home", @"Compulsive Disorders", @"Add Custom Stat", nil];
    
    self.allSports = [[NSArray alloc] initWithObjects:@"Football", @"Basketball", @"Tennis", @"Volleyball", @"Hockey", @"Waterpolo", @"Baseball", @"Cricket", @"Snooker", @"Rugby", nil];
    
    self.allHome = [[NSArray alloc] initWithObjects:@"Electronics", @"Tools", @"Furniture", @"Creatures", nil];
    
    self.allCompulsive = [[NSArray alloc] initWithObjects:@"Weird Behaviours", @"Black Listed", @"White Listed", nil];

    self.tempArray = [[NSMutableArray alloc] init];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.allStats count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
    }
    
    cell.textLabel.text = [self.allStats objectAtIndex:indexPath.row];

    cell.contentView.backgroundColor = self.setBackgroundColor;
    
    cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ITWSportViewController *svc = [[ITWSportViewController alloc] init];
    
    svc.event = self.event;
    
    ITWCustomViewController *cvc = [[ITWCustomViewController alloc] init];
    
    cvc.event = self.event;
    
    switch (indexPath.row)
    {
        case 0:
            //[self presentViewController:navRegularController animated:NO completion:nil];
            [self.navigationController pushViewController:svc animated:YES];
            [self.tempArray removeAllObjects];
            [self.tempArray addObjectsFromArray:self.allSports];
            break;
        case 1:
            //[self presentViewController:navRegularController animated:NO completion:nil];
            [self.navigationController pushViewController:svc animated:YES];
            [self.tempArray removeAllObjects];
            [self.tempArray addObjectsFromArray:self.allHome];
            break;
        case 2:
            //[self presentViewController:navRegularController animated:NO completion:nil];
            [self.navigationController pushViewController:svc animated:YES];
            [self.tempArray removeAllObjects];
            [self.tempArray addObjectsFromArray:self.allCompulsive];
            break;
        case 3:
            //[self presentViewController:navCustomController animated:NO completion:nil];
            [self.navigationController pushViewController:cvc animated:YES];
            
    }
    
    svc.tempArray = self.tempArray;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:self.tempArray forKey:@"self.tempArray"];
    [userDefaults synchronize];
    
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = self.setBackgroundColor;
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.event.eventKey forKey:@"event.eventKey"];
    [coder encodeObject:self.event.subjectName forKey:@"event.subjectName"];
    
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
