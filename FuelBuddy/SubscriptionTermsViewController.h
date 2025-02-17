//
//  SubscriptionTermsViewController.h
//  FuelBuddy
//
//  Created by Nikhil on 18/01/19.
//  Copyright © 2019 Oraganization. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SubscriptionTermsViewController : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *firstLabel;
@property (strong, nonatomic) IBOutlet UILabel *secondlabel;
@property (strong, nonatomic) IBOutlet UILabel *fifthlabel;
@property (strong, nonatomic) IBOutlet UILabel *thirdLabel;
@property (strong, nonatomic) IBOutlet UILabel *fourthLabel;
@property (strong, nonatomic) IBOutlet UIButton *termBTOT;
@property (strong, nonatomic) IBOutlet UIButton *privacyBTOT;
@property (strong, nonatomic) IBOutlet UIButton *cancelBTOT;
@property (strong, nonatomic) IBOutlet UIButton *okBTOT;
- (IBAction)termPressed:(UIButton *)sender;
- (IBAction)privacyPressed:(UIButton *)sender;
- (IBAction)okPressed:(UIButton *)sender;
- (IBAction)cancelPressed:(UIButton *)sender;

@end

