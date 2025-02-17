//
//  OnboardViewController.h
//  FuelBuddy
//
//  Created by Nikhil on 19/04/19.
//  Copyright © 2019 Oraganization. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OnboardViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIImageView *backGroundImage;
@property (strong, nonatomic) IBOutlet UIImageView *iconImage;
@property (strong, nonatomic) IBOutlet UILabel *infoLabel;
@property (strong, nonatomic) IBOutlet UIButton *getStartedButton;

@property NSString *backImageString;
@property NSString *iconImageString;
@property NSString *labelString;
@property NSString *buttonString;
@property NSUInteger valueIndex;


- (IBAction)getStartedPressed:(UIButton *)sender;

@end


