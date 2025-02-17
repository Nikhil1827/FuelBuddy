//
//  SignInFeaturesViewController.h
//  FuelBuddy
//
//  Created by Nikhil on 23/04/19.
//  Copyright © 2019 Oraganization. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignInFeaturesViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UILabel *label1;

@property NSString *backImageString;
@property NSString *labelString;
@property NSUInteger valueIndex;

@end

