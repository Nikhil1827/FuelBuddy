//
//  SubscriptionTermsViewController.m
//  FuelBuddy
//
//  Created by Nikhil on 18/01/19.
//  Copyright © 2019 Oraganization. All rights reserved.
//

#import "SubscriptionTermsViewController.h"
#import "FaqViewController.h"
#import "GoProViewController.h"

@interface SubscriptionTermsViewController ()

@end

@implementation SubscriptionTermsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [self colorFromHexString:@"#2c2c2c"];
    self.navigationController.navigationBar.barTintColor = [self colorFromHexString:@"#0098AB"];
    self.navigationController.navigationBar.tintColor =[UIColor whiteColor];
    self.navigationItem.title=NSLocalizedString(@"subterms", @"Subscription Terms");

    double period = [[NSUserDefaults standardUserDefaults] doubleForKey:@"subscriptionPeriod"];

    NSString *termString2;
    if(period == 1){

        termString2   = [NSString stringWithFormat:NSLocalizedString(@"subterms2", @"- Subscribe to Simply Auto Platinum. This subscription will be charged %@ per year."),[[NSUserDefaults standardUserDefaults] objectForKey:@"priceLocale"]];
    }else if(period == 2){

        termString2 = [NSString stringWithFormat:NSLocalizedString(@"subterms7", @"- Subscribe to Simply Auto Platinum. This subscription will be charged %@ per month."),[[NSUserDefaults standardUserDefaults] objectForKey:@"priceLocale"]];
    }
    
//    NSString *termString2 = [NSString stringWithFormat:NSLocalizedString(@"subterms2", @"- Subscribe to Simply Auto Platinum. This subscription will be charged %@ per year."),[[NSUserDefaults standardUserDefaults] objectForKey:@"priceLocale"]];
    NSString *termString3 = NSLocalizedString(@"subterms3", @"- Subscription automatically renews unless auto-renew is turned off at least 24-hours and The account will be charged for renewal before the end of the current period.");
    NSString *termString4 = NSLocalizedString(@"subterms4", @"- Subscriptions may be managed by the user and auto-renewal may be turned off by going to the user's Account Settings after purchase.");
    NSString *termString5 = NSLocalizedString(@"subterms5", @"- SPayment will be charged to iTunes Account at confirmation of purchase.");
    NSString *termString6 = NSLocalizedString(@"subterms6", @"- The account will be charged for renewal within 24-hours prior to the end of the current period."); 
    self.firstLabel.text = termString2;
    self.secondlabel.text = termString3;
    self.thirdLabel.text = termString4;
    self.fourthLabel.text = termString5;
    self.fifthlabel.text = termString6;
    
    self.firstLabel.textColor = self.secondlabel.textColor = self.thirdLabel.textColor = self.fourthLabel.textColor = [UIColor whiteColor];
    
    self.cancelBTOT.layer.cornerRadius = 5;
    self.cancelBTOT.clipsToBounds = YES;
    self.cancelBTOT.layer.masksToBounds = YES;
    self.cancelBTOT.backgroundColor = [self colorFromHexString:@"#0098AB"];
    self.okBTOT.layer.cornerRadius = 5;
    self.okBTOT.clipsToBounds = YES;
    self.okBTOT.layer.masksToBounds = YES;
    self.okBTOT.backgroundColor = [self colorFromHexString:@"#0098AB"];
    
}

-(UIColor *)colorFromHexString:(NSString *)hexString
{
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

- (IBAction)termPressed:(UIButton *)sender {
    
    FaqViewController *faq = (FaqViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"faq"];
    faq.urlstring = @"http://www.simplyauto.app/Terms2.html";
    faq.navtitle = NSLocalizedString(@"pattern1", @"Terms of Service");
    faq.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController pushViewController:faq animated:YES];
}

- (IBAction)privacyPressed:(UIButton *)sender {
    
    FaqViewController *faq = (FaqViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"faq"];
    faq.urlstring = @"http://www.simplyauto.app/policy.html";
    faq.navtitle = NSLocalizedString(@"pattern2", @"Privacy Policy");
    faq.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController pushViewController:faq animated:YES];
}
- (IBAction)okPressed:(UIButton *)sender {
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"setCallMethod"];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancelPressed:(UIButton *)sender {
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hideHUD"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"setCallMethod"];
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
