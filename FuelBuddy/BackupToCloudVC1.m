//
//  BackupToCloudVC1.m
//  FuelBuddy
//
//  Created by Swapnil on 19/11/17.
//  Copyright © 2017 Oraganization. All rights reserved.
//

#import "BackupToCloudVC1.h"
#import "BackupToCloudVC2.h"

@interface BackupToCloudVC1 ()

@end

@implementation BackupToCloudVC1

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
    
    [self.navigationItem setLeftBarButtonItem:BarButtonItem];
    
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Next", @"Next")
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(goToNextScreen)];
    [self.navigationItem setRightBarButtonItem:rightBarButton];
    
    self.descLabel.text = NSLocalizedString(@"backupCloudText", @"desc label");
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dismissView)
                                                 name:@"dismissOnGotIt"
                                               object:nil];
}





- (void)goToNextScreen{
    
    BackupToCloudVC2 *backupCloud2 = (BackupToCloudVC2 *)[self.storyboard instantiateViewControllerWithIdentifier:@"backupCloud2"];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        backupCloud2.modalPresentationStyle = UIModalPresentationFullScreen;
        [self.navigationController pushViewController:backupCloud2 animated:YES];
        
    });
}

-(BOOL)shouldAutorotate {
    return NO;
}


- (void)dismissView{
    
    
    [self.navigationController dismissViewControllerAnimated:NO completion:^{
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:@"dismissOnGotIt"
                                                      object:nil];
    }];
    
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
