//
//  ITWSetViewController.m
//  Stats
//
//  Created by Majkl on 14/05/14.
//  Copyright (c) 2014 Majkl. All rights reserved.
//

#import "ITWSetViewController.h"
#import "ITWFirstViewController.h"
#import "ITWColor.h"

@interface ITWSetViewController ()

@end

@implementation ITWSetViewController

+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder
{
    return [[self alloc] init];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UINavigationItem *navItem = self.navigationItem;
        navItem.title = @"Settings";

        self.restorationIdentifier = NSStringFromClass([self class]);
        self.restorationClass = [self class];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferredContentSizeChanged:) name:UIContentSizeCategoryDidChangeNotification object:nil];
    
    return self;
}

- (void)back:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:NO completion:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:self.setBackgroundColor];
    [[NSUserDefaults standardUserDefaults] setObject:colorData forKey:@"myColor"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"myColor"]) {
        
        self.setBackgroundColor = [UIColor whiteColor];
        
    } else {
        
        NSData *colorData = [[NSUserDefaults standardUserDefaults] objectForKey:@"myColor"];
        self.setBackgroundColor = [NSKeyedUnarchiver unarchiveObjectWithData:colorData];
    }

    UIColor *color1 = self.setBackgroundColor;
    
    // Get the RGB values out of the UIColor object
    CGFloat red1, green1, blue1;
    
    [color1 getRed:&red1 green:&green1 blue:&blue1 alpha:nil];
    
    // Set the initial slider values
    self.redSlider1.value = red1;
    self.greenSlider1.value = green1;
    self.blueSlider1.value = blue1;
    
    // Set the background color and text field value
    self.view.backgroundColor = color1;
    
    self.colorLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 64, 320, 20)];
    self.colorLabel.text = @"Set Background Color";
    [self.colorLabel setTextColor:[UIColor blackColor]];
    [self.colorLabel setBackgroundColor:[UIColor lightTextColor]];
    self.colorLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.colorLabel];
    
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

- (IBAction)changeBackGroundColor:(id)sender
{
    float red = self.redSlider1.value;
    float green = self.greenSlider1.value;
    float blue = self.blueSlider1.value;
    
    UIColor *newColor = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
    
    self.view.backgroundColor = newColor;
    self.setBackgroundColor = newColor;
}

- (void)preferredContentSizeChanged:(NSNotification *)notification
{
    UIFont *font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    
    self.redLabel.font = font;
    self.greenLabel.font = font;
    self.blueLabel.font = font;
    
    UIFont *font1 = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    
    self.colorLabel.font = font1;
}

- (void)dealloc
{
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter removeObserver:self];
}

@end
