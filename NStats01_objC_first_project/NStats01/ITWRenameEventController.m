//
//  ITWRenameEventController.m
//  NStats01
//
//  Created by Majkl on 23/07/14.
//  Copyright (c) 2014 Majkl. All rights reserved.
//

#import "ITWRenameEventController.h"
#import "ITWEvent.h"
#import "ITWItemStore.h"
#import "ITWLoadViewController.h"
#import "ITWRenameSubjectController.h"
#import "ITWColor.h"

@interface ITWRenameEventController ()

@end

@implementation ITWRenameEventController

+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder
{
    return [[self alloc] init];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UINavigationItem *navItem = self.navigationItem;
        navItem.title = @"Update Event";
        
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

    [[ITWItemStore sharedStore] openDatabase];
        
    self.sArray = [[[ITWItemStore sharedStore] loadSubjects:self.event.eventKey] mutableCopy];
    self.events = [[[ITWItemStore sharedStore] loadEvents] mutableCopy];
        
    [[ITWItemStore sharedStore] closeDatabase];
    
    self.eventNameLabel.delegate = self;
    self.locationNameLabel.delegate = self;
    
    self.eventNameLabel.text = self.event.eventName;
    self.locationNameLabel.text = self.event.eventLocation;
        
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:self.event.eventDate];
        
    self.dateCreatedPicker.date = date;
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"myColor"]) {
        
        self.setBackgroundColor = [UIColor whiteColor];
        
    } else {
        
        NSData *colorData = [[NSUserDefaults standardUserDefaults] objectForKey:@"myColor"];
        self.setBackgroundColor = [NSKeyedUnarchiver unarchiveObjectWithData:colorData];
    }
    
    self.view.backgroundColor = self.setBackgroundColor;
    
    self.scrollview.scrollEnabled = YES;
    self.scrollview.contentSize = CGSizeMake(320, 620);
    
    self.changeEvent = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
    self.changeEvent.text = @"Change Event Info";
    [self.changeEvent setTextColor:[UIColor blackColor]];
    [self.changeEvent setBackgroundColor:[UIColor lightTextColor]];
    //[self.changeEvent setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleFootnote]];
    self.changeEvent.textAlignment = NSTextAlignmentCenter;
    [self.scrollview addSubview:self.changeEvent];
    
    self.renameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 120, 320, 20)];
    self.renameLabel.text = @"Rename Subject:";
    [self.renameLabel setTextColor:[UIColor blackColor]];
    [self.renameLabel setBackgroundColor:[UIColor lightTextColor]];
    //[self.renameLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleFootnote]];
    self.renameLabel.textAlignment = NSTextAlignmentCenter;
    [self.scrollview addSubview:self.renameLabel];
    
    self.dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 305, 320, 20)];
    self.dateLabel.text = @"Change Event Date";
    [self.dateLabel setTextColor:[UIColor blackColor]];
    [self.dateLabel setBackgroundColor:[UIColor lightTextColor]];
    //[self.dateLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleFootnote]];
    self.dateLabel.textAlignment = NSTextAlignmentCenter;
    [self.scrollview addSubview:self.dateLabel];
    
    [self preferredContentSizeChanged:nil];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [[ITWItemStore sharedStore] openDatabase];
    
    self.sArray = [[[ITWItemStore sharedStore] loadSubjects:self.event.eventKey] mutableCopy];
    self.events = [[[ITWItemStore sharedStore] loadEvents] mutableCopy];
    
    [[ITWItemStore sharedStore] closeDatabase];
    
    self.eventNameLabel.delegate = self;
    self.locationNameLabel.delegate = self;
    
    self.eventNameLabel.text = self.event.eventName;
    self.locationNameLabel.text = self.event.eventLocation;
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:self.event.eventDate];
    
    self.dateCreatedPicker.date = date;
    
    [self.subjectTable reloadData];
    
    [self preferredContentSizeChanged:nil];

}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.sArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
    
    if (cell == nil)  {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
    }
    
    cell.textLabel.text = [self.sArray objectAtIndex:indexPath.row];
    
    cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    
    tableView.backgroundColor = self.setBackgroundColor;

    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = self.setBackgroundColor;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    self.event.subjectName = [self.sArray objectAtIndex:indexPath.row];
    
    self.event.eventName = self.eventNameLabel.text;
    self.event.eventLocation = self.locationNameLabel.text;
    self.event.eventDate = [self.dateCreatedPicker.date timeIntervalSince1970];
    
    ITWRenameSubjectController *rsvc = [[ITWRenameSubjectController alloc] init];
    
    [self.navigationController pushViewController:rsvc animated:YES];
    
    rsvc.event = self.event;
    
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
    [[ITWItemStore sharedStore] updateEvent:self.event.eventKey eventName:self.eventNameLabel.text eventLocation:self.locationNameLabel.text eventDate:[self.dateCreatedPicker.date timeIntervalSince1970] dateModified:[d2 timeIntervalSince1970]];
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
    [coder encodeObject:self.eventNameLabel.text forKey:@"eventNameLabel"];
    [coder encodeObject:self.locationNameLabel.text forKey:@"locationNameLabel"];
    
    if (!self.dateCreatedPicker.date) {
        self.dateCreatedPicker.date = [NSDate date];
    }
    
    [coder encodeObject:self.dateCreatedPicker.date forKey:@"dateCreatedPicker"];
    
    [super encodeRestorableStateWithCoder:coder];
    
    NSDate *d2 = [NSDate date];
    
    [[ITWItemStore sharedStore] openDatabase];
    [[ITWItemStore sharedStore] updateEvent:self.event.eventKey eventName:self.eventNameLabel.text eventLocation:self.locationNameLabel.text eventDate:[self.dateCreatedPicker.date timeIntervalSince1970] dateModified:[d2 timeIntervalSince1970]];
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
    
    NSString *eventNameLabel = [coder decodeObjectForKey:@"eventNameLabel"];
    self.eventNameLabel.text = eventNameLabel;
    
    NSString *locationNameLabel = [coder decodeObjectForKey:@"locationNameLabel"];
    self.locationNameLabel.text = locationNameLabel;
    
    NSDate *dateCreatedPicker = [coder decodeObjectForKey:@"dateCreatedPicker"];
    self.dateCreatedPicker.date = dateCreatedPicker;
    
    [super decodeRestorableStateWithCoder:coder];
    
    [[ITWItemStore sharedStore] openDatabase];
    
    self.sArray = [[[ITWItemStore sharedStore] loadSubjects:self.event.eventKey] mutableCopy];

    [[ITWItemStore sharedStore] closeDatabase];
}

- (void)preferredContentSizeChanged:(NSNotification *)notification
{
    [self.subjectTable reloadData];
    
    UIFont *font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    
    self.eventNameLabel.font = font;
    self.locationNameLabel.font = font;
    self.eventLabel.font = font;
    self.locationLabel.font = font;
    
    UIFont *font1 = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    
    self.changeEvent.font = font1;
    self.renameLabel.font = font1;
    self.dateLabel.font = font1;
}

- (void)dealloc
{
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter removeObserver:self];
}


@end
