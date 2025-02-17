//
//  OnboardViewController.m
//  FuelBuddy
//
//  Created by Nikhil on 19/04/19.
//  Copyright © 2019 Oraganization. All rights reserved.
//

#import "OnboardViewController.h"
#import "SignInCloudViewController.h"

@interface OnboardViewController ()

@end

@implementation OnboardViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height + 37);
    
    self.backGroundImage.image = [UIImage imageNamed:_backImageString];
    self.iconImage.image = [UIImage imageNamed:_iconImageString];
    self.infoLabel.text = _labelString;

    NSString *getStarted = NSLocalizedString(@"lets_get_stared", @"LET'S GET STARTED");

    if([getStarted isEqualToString:_buttonString]){

        [self.getStartedButton setBackgroundColor: [UIColor colorWithRed:255/255 green:255/255 blue:255/255 alpha:.3]];
    }else{

        [self.getStartedButton setBackgroundColor: UIColor.clearColor];
    }

    [self.getStartedButton setTitle:_buttonString forState: UIControlStateNormal];

}

-(BOOL)shouldAutorotate{

    return NO;
}

- (IBAction)getStartedPressed:(UIButton *)sender {

    SignInCloudViewController *signIn = (SignInCloudViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"cloudSignIn"];
    signIn.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:signIn animated:NO completion:nil];

    [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"cameFromOnBoardScreen"];

}
@end
