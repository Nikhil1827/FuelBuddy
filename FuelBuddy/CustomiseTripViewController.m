//
//  CustomiseTripViewController.m
//  FuelBuddy
//
//  Created by Nikhil on 16/07/18.
//  Copyright © 2018 Oraganization. All rights reserved.
//

#import "CustomiseTripViewController.h"

@interface CustomiseTripViewController ()

@end

@implementation CustomiseTripViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.barTintColor = [self colorFromHexString:@"#0098AB"];
    self.navigationController.navigationBar.tintColor =[UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor] , NSFontAttributeName: [UIFont fontWithName:@"Helvetica-Light" size:18.0] }];
    self.view.backgroundColor = [self colorFromHexString:@"#2c2c2c"];
    
    self.navigationItem.title = @"Customize Add trip Screen";
    
    UIImage *buttonImage = [[UIImage imageNamed:@"nav_back"] resizableImageWithCapInsets:UIEdgeInsetsMake(20,10,10,10)];
    UIButton *Button = [UIButton buttonWithType:UIButtonTypeCustom];
    [Button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    Button.frame = CGRectMake(0.0, 10.0, buttonImage.size.width+4,buttonImage.size.height+4);
    UIBarButtonItem *BarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:Button];
    [Button addTarget:self action:@selector(backbuttonclick) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setLeftBarButtonItem:BarButtonItem];
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    if([def boolForKey:@"showTripOdo"]){
        [self.checkYes setImage:[UIImage imageNamed:@"check"] forState:UIControlStateSelected];
        [self.checkYes setSelected:YES];
    }else{
        [self.checkYes setImage:[UIImage imageNamed:@"uncheck"] forState:UIControlStateNormal];
        [self.checkYes setSelected:NO];
    }
}

-(void)backbuttonclick
{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    if([self.checkYes isSelected]){
        [def setBool:YES forKey:@"showTripOdo"];
    }else{
        [def setBool:NO forKey:@"showTripOdo"];
    }
    [self.navigationController popViewControllerAnimated:YES];// completion:nil];
}

-(UIColor *)colorFromHexString:(NSString *)hexString
{
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

- (IBAction)checkClicked:(UIButton *)sender {
    
    if(sender.selected == YES){
        sender.selected = NO;
        
    }else{
        
        sender.selected = YES;
    }
    [self.checkYes setImage:[UIImage imageNamed:@"check"] forState:UIControlStateSelected];
    [self.checkYes setImage:[UIImage imageNamed:@"uncheck"] forState:UIControlStateNormal];
}
@end
