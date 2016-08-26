//
//  ITWSportViewController.m
//  Stats
//
//  Created by Majkl on 13/05/14.
//  Copyright (c) 2014 Majkl. All rights reserved.
//

#import "ITWSportViewController.h"
#import "ITWFirstViewController.h"
#import "ITWStatsViewController.h"
#import "ITWTicsTableViewController.h"
#import "ITWEvent.h"
#import "ITWColor.h"
#import "ITWItemStore.h"

@interface ITWSportViewController ()

@end

@implementation ITWSportViewController

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
        navItem.title = @"Add Object";
        
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
    self.tableView.restorationIdentifier = @"ITWSportViewControllerTableView";
    
    [[ITWItemStore sharedStore] openDatabase];
    
    self.events = [[[ITWItemStore sharedStore] loadEvents] mutableCopy];
    
    [[ITWItemStore sharedStore] closeDatabase];
    
    if (!self.tempArray) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSMutableArray *defaultArray = [userDefaults objectForKey:@"self.tempArray"];
        
        self.tempArray = defaultArray;
    }
    
    self.tempArray2 = [[NSMutableArray alloc] init];
    
    self.allFootball = [[NSArray alloc] initWithObjects:@"Goals", @"Fauls", @"Shot Attempts", @"Passes", @"Assists", @"Saves", @"Yellow Cards", @"Red Cards", @"Outs", @"Free Shots", @"Misses", @"Corner Shots", @"Offsides", nil];
    
    self.allBasketball = [[NSArray alloc] initWithObjects:@"Points", @"Fauls", @"Passes", @"Assists", @"Free Throws", @"Blocks", @"Steals", @"Three points", @"Turnovers", @"Rebounds", nil];
    
    self.allTennis = [[NSArray alloc] initWithObjects:@"Double Faults", @"Aces", @"First Serve", @"Second Serve", @"Break Points", nil];
    
    self.allVolleyball = [[NSArray alloc] initWithObjects:@"Passes", @"Assists", @"Shots", @"Saves", @"Misses", @"Serves", @"Aces", nil];
    
    self.allHockey = [[NSArray alloc] initWithObjects:@"Goals", @"Fauls", @"Passes", @"Assists", @"Saves", @"Penalty minutes", @"Outs", @"Shot Attempts", @"Misses", @"Offsides", nil];
    
    self.allWaterpolo = [[NSArray alloc] initWithObjects:@"Goals", @"Fauls", @"Shot Attempts", @"Passes", @"Assists", @"Saves", @"Yellow Card", @"Red Card", @"Outs", @"Free Shots", @"Misses", @"Corner Shots", nil];
    
    self.allBaseball = [[NSArray alloc] initWithObjects:@"Homeruns", @"1st Base", @"2nd Base", @"3rd Base", @"Outs", @"Innings", nil];
    
    self.allCricket = [[NSArray alloc] initWithObjects:@"Homeruns", @"1st Base", @"2nd Base", @"3rd Base", @"Outs", @"Innings", nil];
    
    self.allSnooker = [[NSArray alloc] initWithObjects:@"Shots", @"Failures", nil];
    
    self.allRugby = [[NSArray alloc] initWithObjects:@"Goals", @"Fauls", @"Shot Attempts", @"Passes", @"Assists", @"Saves", nil];
    
    self.allElectronics = [[NSArray alloc] initWithObjects:@"TVs", @"Radios", @"Stereos", @"DVD Players", @"Gadgets", @"Mobile Phones", @"Computers", @"Monitors", nil];
    
    self.allTools = [[NSArray alloc] initWithObjects:@"Hammers", @"Nails", @"Shovels", @"Rakes", @"Scissors", @"Brooms", nil];
    
    self.allFurniture = [[NSArray alloc] initWithObjects:@"Chairs", @"Tables", @"Sofas", @"Closets", @"Deckchairs", @"Beds", nil];
    
    self.allCreatures = [[NSArray alloc] initWithObjects:@"Dogs", @"Cats", @"Mice", @"Parrots", @"Hamsters", @"Spiders", @"Snakes", nil];
    
    self.allWeird = [[NSArray alloc] initWithObjects:@"Counting Sheep", nil];
    
    self.allBlack = [[NSArray alloc] initWithObjects:@"Did Something Bad", @"Talked Behind Your Back", @"Didn't Return Money", @"Never Returned a Favour", nil];
    
    self.allWhite = [[NSArray alloc] initWithObjects:@"Did Something Good", @"Was Helpfull", @"Loned You Money", @"Did a Big Favour", @"Did a Small Favour", nil];
    
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.tempArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
    }
    
    cell.textLabel.text = [self.tempArray objectAtIndex:indexPath.row];

    cell.contentView.backgroundColor = self.setBackgroundColor;
    
    cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ITWTicsTableViewController *tvc = [[ITWTicsTableViewController alloc] init];

    [self.navigationController pushViewController:tvc animated:YES];
    
    tvc.event = self.event;
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (indexPath.row == 0 && [cell.textLabel.text isEqualToString:@"Football"]) {
        [self.tempArray2 removeAllObjects];
        [self.tempArray2 addObjectsFromArray:self.allFootball];
    } else if (indexPath.row == 0 && [cell.textLabel.text isEqualToString:@"Electronics"]) {
        [self.tempArray2 removeAllObjects];
        [self.tempArray2 addObjectsFromArray:self.allElectronics];
    } else if (indexPath.row == 0 && [cell.textLabel.text isEqualToString:@"Weird Behaviours"]) {
        [self.tempArray2 removeAllObjects];
        [self.tempArray2 addObjectsFromArray:self.allWeird];
    } else if (indexPath.row == 1 && [cell.textLabel.text isEqualToString:@"Basketball"]) {
        [self.tempArray2 removeAllObjects];
        [self.tempArray2 addObjectsFromArray:self.allBasketball];
    } else if (indexPath.row == 1 && [cell.textLabel.text isEqualToString:@"Tools"]) {
        [self.tempArray2 removeAllObjects];
        [self.tempArray2 addObjectsFromArray:self.allTools];
    } else if (indexPath.row == 1 && [cell.textLabel.text isEqualToString:@"Black Listed"]) {
        [self.tempArray2 removeAllObjects];
        [self.tempArray2 addObjectsFromArray:self.allBlack];
    } else if (indexPath.row == 2 && [cell.textLabel.text isEqualToString:@"Tennis"]) {
        [self.tempArray2 removeAllObjects];
        [self.tempArray2 addObjectsFromArray:self.allTennis];
    } else if (indexPath.row == 2 && [cell.textLabel.text isEqualToString:@"Furniture"]) {
        [self.tempArray2 removeAllObjects];
        [self.tempArray2 addObjectsFromArray:self.allFurniture];
    } else if (indexPath.row == 2 && [cell.textLabel.text isEqualToString:@"White Listed"]) {
        [self.tempArray2 removeAllObjects];
        [self.tempArray2 addObjectsFromArray:self.allWhite];
    } else if (indexPath.row == 3 && [cell.textLabel.text isEqualToString:@"Volleyball"]) {
        [self.tempArray2 removeAllObjects];
        [self.tempArray2 addObjectsFromArray:self.allVolleyball];
    } else if (indexPath.row == 3 && [cell.textLabel.text isEqualToString:@"Creatures"]) {
        [self.tempArray2 removeAllObjects];
        [self.tempArray2 addObjectsFromArray:self.allCreatures];
    } else if (indexPath.row == 4 && [cell.textLabel.text isEqualToString:@"Hockey"]) {
        [self.tempArray2 removeAllObjects];
        [self.tempArray2 addObjectsFromArray:self.allHockey];
    } else if (indexPath.row == 5 && [cell.textLabel.text isEqualToString:@"Waterpolo"]) {
        [self.tempArray2 removeAllObjects];
        [self.tempArray2 addObjectsFromArray:self.allWaterpolo];
    } else if (indexPath.row == 6 && [cell.textLabel.text isEqualToString:@"Baseball"]) {
        [self.tempArray2 removeAllObjects];
        [self.tempArray2 addObjectsFromArray:self.allBaseball];
    } else if (indexPath.row == 7 && [cell.textLabel.text isEqualToString:@"Cricket"]) {
        [self.tempArray2 removeAllObjects];
        [self.tempArray2 addObjectsFromArray:self.allCricket];
    } else if (indexPath.row == 8 && [cell.textLabel.text isEqualToString:@"Snooker"]) {
        [self.tempArray2 removeAllObjects];
        [self.tempArray2 addObjectsFromArray:self.allSnooker];
    } else if (indexPath.row == 9 && [cell.textLabel.text isEqualToString:@"Rugby"]) {
        [self.tempArray2 removeAllObjects];
        [self.tempArray2 addObjectsFromArray:self.allRugby];
    }
    
    tvc.tempArray2 = self.tempArray2;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:self.tempArray2 forKey:@"self.tempArray2"];
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