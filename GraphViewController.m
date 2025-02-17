//
//  GraphViewController.m
//  FuelBuddy
//
//  Created by surabhi on 25/01/16.
//  Copyright © 2016 Oraganization. All rights reserved.
//

#import "GraphViewController.h"
#import "FSLineChart.h"
#import "UIColor+FSPalette.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CoreGraphics.h>


@interface GraphViewController ()

@end
 static GADMasterViewController *shared;

@implementation GraphViewController
@synthesize isPresented;
- (void)viewDidLoad {
    [super viewDidLoad];
    isPresented =YES;
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeLeft];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    [self.tabBarController.tabBar setHidden:YES];
    AppDelegate *App = [AppDelegate sharedAppDelegate];
    App.tabbutton.hidden=YES;
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [self colorFromHexString:@"#2c2c2c"];
    [self.view addSubview:[self chart3]];
    
    self.navigationController.navigationBar.tintColor =[UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor] , NSFontAttributeName: [UIFont fontWithName:@"Helvetica-Light" size:18.0] }];
    self.title = self.titlestring;
    UIImage *buttonImage = [UIImage imageNamed:@"nav_back"];
    
    UIButton *Button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [Button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    
    Button.frame = CGRectMake(0.0, 0.0, buttonImage.size.width,buttonImage.size.height);
    
    UIBarButtonItem *BarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:Button];
    
    [Button addTarget:self action:@selector(backbuttonclick) forControlEvents:UIControlEventTouchUpInside];
    
    [self.navigationItem setLeftBarButtonItem:BarButtonItem];
  
}

-(void)backbuttonclick
{   isPresented = YES;
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated
{
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED < 90000
- (NSUInteger)supportedInterfaceOrientations
#else
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
#endif
{
    return UIInterfaceOrientationMaskLandscape;
}

-(BOOL)shouldAutorotate{
    return YES;
}

-(FSLineChart*)chart3 {
   
    FSLineChart* lineChart;
    if([UIScreen mainScreen].bounds.size.height > 320)
    {
   lineChart = [[FSLineChart alloc] initWithFrame:CGRectMake(60, [UIScreen mainScreen].bounds.size.height/2-125, [UIScreen mainScreen].bounds.size.width-100, [UIScreen mainScreen].bounds.size.height-120)];
    }
    else
    {
        lineChart = [[FSLineChart alloc] initWithFrame:CGRectMake(60, [UIScreen mainScreen].bounds.size.height/2-100, [UIScreen mainScreen].bounds.size.width-100, [UIScreen mainScreen].bounds.size.height-100)];
    }
     self.yaxislabel.transform = CGAffineTransformMakeRotation((- M_PI)/2);
    self.yaxislabel.textColor = [UIColor whiteColor];
    self.xaxislabel.textColor = [UIColor whiteColor];
    self.yaxislabel.text = self.yaxisstring;
    lineChart.verticalGridStep = 10;
     lineChart.horizontalGridStep = (int)self.yaxis.count;
    if(self.yaxis.count > 5)
    {
        lineChart.horizontalGridStep = 4;
    }
    else
    {
    lineChart.horizontalGridStep = (int)self.yaxis.count;
    }
    // 151,187,205,0.2
    //lineChart.color = [UIColor colorWithRed:151.0f/255.0f green:187.0f/255.0f blue:205.0f/255.0f alpha:1.0f];
   // lineChart.color = [UIColor lightGrayColor];
    lineChart.color= [self colorFromHexString:@"#ECB40B"];

    lineChart.fillColor = [lineChart.color colorWithAlphaComponent:0.7];
    //lineChart.fillColor = [self colorFromHexString:@"#ECB40B"];
    //lineChart.alpha = 0.5;
    lineChart.axisColor = [UIColor lightGrayColor];
    lineChart.innerGridColor = [UIColor lightGrayColor];
    lineChart.innerGridLineWidth = 0.2;
    //NSUInteger item = self.yaxis.count
    lineChart.labelForIndex = ^(NSUInteger item) {
        
        //NSLog(@"item %lu",(unsigned long)item);
        return self.yaxis[item];
        
    };
    
    lineChart.labelForValue = ^(CGFloat value) {
        return [NSString stringWithFormat:@"%.02f", value];
    };
    
    [lineChart setChartData:self.xaxis];
    
    
    return lineChart;
}

-(UIColor *)colorFromHexString:(NSString *)hexString
{
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

@end
