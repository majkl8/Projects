//
//  ITWActionViewController.m
//  Stats
//
//  Created by Majkl on 25/05/14.
//  Copyright (c) 2014 Majkl. All rights reserved.
//

#import "ITWActionViewController.h"
#import "ITWFirstViewController.h"
#import "ITWItemCell.h"
#import "ITWSubjectViewController.h"
#import "ITWItemStore.h"
#import "ITWEvent.h"
#import "ITWColor.h"
#import "ITWRenameStatController.h"

@interface ITWActionViewController ()

@property (nonatomic, strong) UIToolbar *toolbar;

@end

@implementation ITWActionViewController

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

        navItem.rightBarButtonItem = self.editButtonItem;
        
        self.restorationIdentifier = NSStringFromClass([self class]);
        self.restorationClass = [self class];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferredContentSizeChanged:) name:UIContentSizeCategoryDidChangeNotification object:nil];

    return self;
}

- (void)back:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:self.dismissBlock];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[ITWItemStore sharedStore] openDatabase];
    
    self.events = [[[ITWItemStore sharedStore] loadEvents] mutableCopy];
    
    [[ITWItemStore sharedStore] closeDatabase];

    self.tableView.scrollEnabled = YES;
    
    // Load the NIB file
    UINib *nib = [UINib nibWithNibName:@"ITWItemCell" bundle:nil];
    
    // Register this NIB, which contains the cell
    [self.tableView registerNib:nib forCellReuseIdentifier:@"ITWItemCell"];
    
    UINavigationItem *navItem = self.navigationItem;
    navItem.title = self.event.eventName;
    
    int a = self.event.eventDate;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    [dateFormatter setDateFormat:@"dd.MM.yyyy"];
    
    NSDate *conversationDate = [NSDate dateWithTimeIntervalSince1970:a];
    NSString *conversationDateString = [dateFormatter stringFromDate:conversationDate];
    
    NSString *concat = [NSString stringWithFormat:@"%@ (%@)", self.event.eventLocation, conversationDateString];
    
    navItem.prompt = concat;
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"myColor"]) {
        
        self.setBackgroundColor = [UIColor whiteColor];
        
    } else {
        
        NSData *colorData = [[NSUserDefaults standardUserDefaults] objectForKey:@"myColor"];
        self.setBackgroundColor = [NSKeyedUnarchiver unarchiveObjectWithData:colorData];
        
    }
    self.view.backgroundColor = self.setBackgroundColor;
    
    self.tableView.restorationIdentifier = @"ITWActionViewControllerTableView";
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.tempArray5 count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSString *sectionTitle = [self.tempArray5 objectAtIndex:section];
    NSArray *sectionStats = [self.sDict2 objectForKey:sectionTitle];
    return [sectionStats count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.tempArray5 objectAtIndex:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ITWItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ITWItemCell" forIndexPath:indexPath];
    
    if (cell == nil) {
        
        cell = [[ITWItemCell alloc] initWithDelegate:self reuseIdentifier:@"ITWItemCell"];
    }

    NSString *sectionTitle = [self.tempArray5 objectAtIndex:indexPath.section];
    
    NSDictionary *sectionStats = [self.sDict2 objectForKey:sectionTitle];
    
    NSArray *statsArray = [sectionStats allKeys];
    
    NSString *statKey = [statsArray objectAtIndex:indexPath.row];
    
    NSArray *valuesArray = [sectionStats allValues];
    
    NSString *statValue = [valuesArray objectAtIndex:indexPath.row];
    
    cell.subName = sectionTitle;
    cell.statLabel.text = statKey;
    cell.valueLabel.text = statValue;
    cell.stepper.value = [statValue intValue];
    
    cell.delegate = self;
    
    cell.statLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    cell.valueLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];

    return cell;
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = self.setBackgroundColor;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65;
}

- (void)stepperPressed:(ITWItemCell *)cell
{
    [cell.valueLabel setText:[NSString stringWithFormat:@"%0.f", cell.stepper.value]];
    
    [[self.sDict2 objectForKey:cell.subName] setObject:cell.valueLabel.text forKey:cell.statLabel.text];
    
    NSDate *d1 = [NSDate date];
    
    [[ITWItemStore sharedStore] openDatabase];
    [[ITWItemStore sharedStore] updateStats:self.event.eventKey subjectName:cell.subName statName:cell.statLabel.text statValue:[cell.valueLabel.text intValue] dateModified:[d1 timeIntervalSince1970]];
    [[ITWItemStore sharedStore] closeDatabase];
    
}

- (void)resetPressed:(ITWItemCell *)cell
{
    cell.stepper.value = 0;
    [cell.valueLabel setText:[NSString stringWithFormat:@"%0.f", cell.stepper.value]];
    
    [[self.sDict2 objectForKey:cell.subName] setObject:cell.valueLabel.text forKey:cell.statLabel.text];
    
    NSDate *d1 = [NSDate date];

    [[ITWItemStore sharedStore] openDatabase];
    [[ITWItemStore sharedStore] updateStats:self.event.eventKey subjectName:cell.subName statName:cell.statLabel.text statValue:[cell.valueLabel.text intValue] dateModified:[d1 timeIntervalSince1970]];
    [[ITWItemStore sharedStore] closeDatabase];
}

- (void)textEdited:(ITWItemCell *)cell
{
    cell.stepper.value = [cell.valueLabel.text intValue];
    
    [[self.sDict2 objectForKey:cell.subName] setObject:cell.valueLabel.text forKey:cell.statLabel.text];
    
    NSDate *d1 = [NSDate date];
    
    [[ITWItemStore sharedStore] openDatabase];
    [[ITWItemStore sharedStore] updateStats:self.event.eventKey subjectName:cell.subName statName:cell.statLabel.text statValue:[cell.valueLabel.text intValue] dateModified:[d1 timeIntervalSince1970]];
    [[ITWItemStore sharedStore] closeDatabase];

}

- (void)renameStat:(ITWItemCell *)cell
{
    ITWRenameStatController *rvc = [[ITWRenameStatController alloc] init];
    
    self.event.subjectName = cell.subName;
    self.event.customStat = cell.statLabel.text;
    
    rvc.event = self.event;
    
    [self.navigationController pushViewController:rvc animated:YES];

}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //hide the keyboard
    [textField resignFirstResponder];
    
    //return NO or YES, it doesn't matter
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[self tableView] setEditing:YES animated:YES];
    
    // If the table view is asking to commit a delete command...
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        NSString *sectionTitle = [self.tempArray5 objectAtIndex:indexPath.section];
        NSDictionary *sectionStats = [self.sDict2 objectForKey:sectionTitle];
        NSArray *statsArray = [sectionStats allKeys];
        NSString *statKey = [statsArray objectAtIndex:indexPath.row];
        
        [[self.sDict2 objectForKey:sectionTitle] removeObjectForKey:statKey];
        
        if ([[self.sDict2 objectForKey:sectionTitle] count] == 0) {
            [[ITWItemStore sharedStore] openDatabase];
            [[ITWItemStore sharedStore] deleteStat:self.event.eventKey subjectName:sectionTitle statName:statKey];
            [[ITWItemStore sharedStore] deleteSubject:self.event.eventKey subjectName:sectionTitle];
            [[ITWItemStore sharedStore] closeDatabase];
            [tableView beginUpdates];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
            [self.tempArray5 removeObjectAtIndex:indexPath.section];
            [tableView endUpdates];
        } else {
            [[ITWItemStore sharedStore] openDatabase];
            [[ITWItemStore sharedStore] deleteStat:self.event.eventKey subjectName:sectionTitle statName:statKey];
            [[ITWItemStore sharedStore] closeDatabase];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
        [tableView reloadData];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[ITWItemStore sharedStore] openDatabase];
    self.sDict2 = [[ITWItemStore sharedStore] loadStatsAndValues:self.event.eventKey];
    [[ITWItemStore sharedStore] closeDatabase];
    
    self.tempArray5 = [[self.sDict2 allKeys] mutableCopy];
    
    //Initialize the toolbar
    self.toolbar = [[UIToolbar alloc] init];
    self.toolbar.barStyle = UIBarStyleDefault;
    
    //Set the toolbar to fit the width of the app.
    [self.toolbar sizeToFit];
    
    //Caclulate the height of the toolbar
    CGFloat toolbarHeight = [self.toolbar frame].size.height;
    
    //Get the bounds of the parent view
    CGRect rootViewBounds = self.parentViewController.view.bounds;
    
    //Get the height of the parent view.
    CGFloat rootViewHeight = CGRectGetHeight(rootViewBounds);
    
    //Get the width of the parent view,
    CGFloat rootViewWidth = CGRectGetWidth(rootViewBounds);
    
    //Create a rectangle for the toolbar
    CGRect rectArea = CGRectMake(0, rootViewHeight - toolbarHeight, rootViewWidth, toolbarHeight);
    
    //Reposition and resize the receiver
    [self.toolbar setFrame:rectArea];
    
    //Create a button
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(save:)];
    UIBarButtonItem *addStatButton = [[UIBarButtonItem alloc] initWithTitle:@"Add Subject" style:UIBarButtonItemStyleBordered target:self action:@selector(addSubject:)];
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    [self.toolbar setItems:[NSArray arrayWithObjects:addStatButton,flexibleSpace,saveButton,nil]];
    
    //Add the toolbar as a subview to the navigation controller.
    [self.navigationController.view addSubview:self.toolbar];
    
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 44)];
    footer.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = footer;
    
    [self preferredContentSizeChanged:nil];
    
    [[self tableView] reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.toolbar.hidden = YES;
    
    [self.tempArray3 removeAllObjects];
}

- (void)save:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"You are leaving this page!" message:@"Do you want to save the data?" delegate:self cancelButtonTitle:@"Cancel"otherButtonTitles:@"OK", nil];
    
    [alert show];
}

- (void)addSubject:(id)sender
{
    ITWSubjectViewController *svc = [[ITWSubjectViewController alloc] init];
    
    [self.navigationController pushViewController:svc animated:YES];

    svc.event = self.event;
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == [alertView cancelButtonIndex]) {
        alertView = nil;
    } else {
        ITWFirstViewController *fvc = [[ITWFirstViewController alloc] init];
        
        [self.navigationController pushViewController:fvc animated:YES];
    }
}

- (BOOL)findAndResignFirstResponder:(UIView *)stView
{
    if (stView.isFirstResponder) {
        [stView resignFirstResponder];
        return YES;
    }
    
    for (UIView *subView in stView.subviews) {
        if ([self findAndResignFirstResponder:subView]) {
            return YES;
        }
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self findAndResignFirstResponder:self.view];
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.event.eventKey forKey:@"event.eventKey"];
    [coder encodeObject:self.event.subjectName forKey:@"event.subjectName"];
    [coder encodeObject:self.event.eventName forKey:@"event.eventName"];
    [coder encodeObject:self.event.eventLocation forKey:@"event.eventLocation"];
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:self.event.eventDate];
    
    [coder encodeObject:date forKey:@"event.eventDate"];
    
    [coder encodeObject:self.tempArray3 forKey:@"self.tempArray3"];
    
    [coder encodeObject:self.sDict2 forKey:@"self.sDict2"];
    
    [coder encodeBool:self.isEditing forKey:@"TableViewIsEditing"];
    
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
    
    NSString *eventName = [coder decodeObjectForKey:@"event.eventName"];
    
    self.event.eventName = eventName;
    
    NSString *eventLocation = [coder decodeObjectForKey:@"event.eventLocation"];
    
    self.event.eventLocation = eventLocation;
    
    NSDate *date = [coder decodeObjectForKey:@"event.eventDate"];
    
    self.event.eventDate = [date timeIntervalSince1970];
    
    NSMutableArray *tArray3 = [coder decodeObjectForKey:@"self.tempArray3"];
    
    self.tempArray3 = tArray3;
    
    NSMutableDictionary *dict2 = [coder decodeObjectForKey:@"self.sDict2"];
    
    self.sDict2 = dict2;
    
    self.tempArray5 = [[self.sDict2 allKeys] mutableCopy];
    
    self.editing = [coder decodeBoolForKey:@"TableViewIsEditing"];
    
    [super decodeRestorableStateWithCoder:coder];

    UINavigationItem *navItem = self.navigationItem;
    navItem.title = self.event.eventName;
    
    int a = self.event.eventDate;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    [dateFormatter setDateFormat:@"dd.MM.yyyy"];
    
    NSDate *conversationDate = [NSDate dateWithTimeIntervalSince1970:a];
    NSString *conversationDateString = [dateFormatter stringFromDate:conversationDate];
    
    NSString *concat = [NSString stringWithFormat:@"%@ (%@)", self.event.eventLocation, conversationDateString];
    
    navItem.prompt = concat;

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

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    
    //header.textLabel.textColor = [UIColor redColor];
    header.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    CGRect headerFrame = header.frame;
    header.textLabel.frame = headerFrame;
    header.textLabel.textAlignment = NSTextAlignmentCenter;
}


@end
