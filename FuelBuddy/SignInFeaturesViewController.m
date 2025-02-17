//
//  SignInFeaturesViewController.m
//  FuelBuddy
//
//  Created by Nikhil on 23/04/19.
//  Copyright © 2019 Oraganization. All rights reserved.
//

#import "SignInFeaturesViewController.h"

@interface SignInFeaturesViewController ()

@end

@implementation SignInFeaturesViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [self colorFromHexString:@"#2c2c2c"];
    self.imageView.image = [UIImage imageNamed:_backImageString];
    self.label1.text = _labelString;

}

-(UIColor *)colorFromHexString:(NSString *)hexString
{
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
