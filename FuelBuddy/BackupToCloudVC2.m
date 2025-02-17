//
//  BackupToCloudVC2.m
//  FuelBuddy
//
//  Created by Swapnil on 19/11/17.
//  Copyright © 2017 Oraganization. All rights reserved.
//

#import "BackupToCloudVC2.h"

@interface BackupToCloudVC2 ()

@end

@implementation BackupToCloudVC2

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationController.navigationBar.barTintColor = [self colorFromHexString:@"#0098AB"];
    self.navigationController.navigationBar.tintColor =[UIColor whiteColor];
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.topItem.title = @"Backup To Cloud";
    
    //self.navigationController.navigationBar.topItem.prompt = [def objectForKey:@"UserEmail"];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor] , NSFontAttributeName: [UIFont fontWithName:@"Helvetica-Light" size:18.0] }];
    self.view.backgroundColor = [self colorFromHexString:@"#2c2c2c"];
    UIImage *buttonImage = [UIImage imageNamed:@"nav_back"];
    
    UIButton *Button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [Button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    
    Button.frame = CGRectMake(0.0, 0.0, buttonImage.size.width,buttonImage.size.height);
    
    UIBarButtonItem *BarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:Button];
    
    [Button addTarget:self action:@selector(backbuttonclick) forControlEvents:UIControlEventTouchUpInside];
    
    //[self.navigationItem setLeftBarButtonItem:BarButtonItem];
    
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Got it", @"Got it")
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(dismissViews)];
    [self.navigationItem setRightBarButtonItem:rightBarButton];
    
    self.imgView.image = [UIImage imageNamed:@"Deregister_iOS.png"];
    
    self.labelDesc.text = NSLocalizedString(@"sync_help_deregister_msg", @"desc label");
}


- (void)dismissViews{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"dismissOnGotIt" object:nil];
    [self backbuttonclick];
}

-(BOOL)shouldAutorotate {
    return NO;
}

-(void)backbuttonclick
{
    
    
    [self dismissViewControllerAnimated:YES completion:nil];
    //    //[self dismissViewControllerAnimated:YES completion:nil];
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
