//
//  ITWLoadViewController.m
//  Stats
//
//  Created by Majkl on 11/05/14.
//  Copyright (c) 2014 Majkl. All rights reserved.
//

#import "ITWLoadViewController.h"
#import "ITWFirstViewController.h"
#import "ITWRenameEventController.h"
#import "ITWItemStore.h"
#import "ITWEvent.h"
#import "ITWActionViewController.h"
#import "ITWColor.h"

@interface ITWLoadViewController ()

@end

@implementation ITWLoadViewController

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
        navItem.title = @"Pick Event";
        
        navItem.rightBarButtonItem = self.editButtonItem;
        
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
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    
    [[ITWItemStore sharedStore] openDatabase];
    self.events = [[ITWItemStore sharedStore] loadEvents];
    
    [[ITWItemStore sharedStore] closeDatabase];
    
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
    
    [[ITWItemStore sharedStore] openDatabase];
    self.events = [[ITWItemStore sharedStore] loadEvents];
    [[ITWItemStore sharedStore] closeDatabase];
    
    [self.tableView reloadData];
    
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
    return [self.events count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Create an instance of UITableViewCell, with default appearance
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"UITableViewCell"];
    
    if (cell == nil)  {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"UITableViewCell"];
    }
    
    // Set the text on the cell with the description of the item that is at nth index of items, where n = row this cell will appear in on the tableView
    ITWEvent *event = self.events[indexPath.row];
    
    // Configure the cell with the ITWEvent
    cell.textLabel.text = event.eventName;
    
    int a = event.eventDate;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //[dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    [dateFormatter setDateFormat:@"dd.MM.yyyy"];
    NSDate *conversationDate = [NSDate dateWithTimeIntervalSince1970:a];
    NSString *conversationDateString = [dateFormatter stringFromDate:conversationDate];
    
    NSString *concat = [NSString stringWithFormat:@"%@ (%@)", event.eventLocation, conversationDateString];
    
    cell.detailTextLabel.text = concat;
    
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    
    cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    cell.detailTextLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];

    return cell;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    ITWRenameEventController *rvc = [[ITWRenameEventController alloc] init];
    
    [self.navigationController pushViewController:rvc animated:YES];

    rvc.event = self.events[indexPath.row];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = self.setBackgroundColor;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // If the table view is asking to commit a delete command...
    if (editingStyle == UITableViewCellEditingStyleDelete) {

        ITWEvent *event = self.events[indexPath.row];
        
        [[ITWItemStore sharedStore] removeEvent:event];
        
        [[ITWItemStore sharedStore] openDatabase];
        [[ITWItemStore sharedStore] deleteEvent:event.eventKey];
        [[ITWItemStore sharedStore] closeDatabase];
        
        // Also remove that row from the table view with an animation
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}


- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    [[ITWItemStore sharedStore] moveItemAtIndex:sourceIndexPath.row toIndex:destinationIndexPath.row];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ITWActionViewController *avc = [[ITWActionViewController alloc] init];
    
    [self.navigationController pushViewController:avc animated:YES];
    
    ITWEvent *event = self.events[indexPath.row];
    
    [[ITWItemStore sharedStore] openDatabase];
    self.sDict2 = [[ITWItemStore sharedStore] loadStatsAndValues:event.eventKey];
    [[ITWItemStore sharedStore] closeDatabase];
    
    avc.sDict2 = self.sDict2;
    avc.event = self.events[indexPath.row];
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
