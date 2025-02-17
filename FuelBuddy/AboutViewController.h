//
//  AboutViewController.h
//  FuelBuddy
//
//  Created by surabhi on 07/01/16.
//  Copyright © 2016 Oraganization. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "GADMasterViewController.h"
@interface AboutViewController : UIViewController <MFMailComposeViewControllerDelegate,GADBannerViewDelegate>


@property (weak, nonatomic) IBOutlet UIButton *fbButton;
@property (weak, nonatomic) IBOutlet UILabel *versionlabel;


@property (weak, nonatomic) IBOutlet UIButton *twitterButton;

- (IBAction)fuelbuddyclick:(id)sender;
- (IBAction)supportclick:(id)sender;
- (IBAction)customiseclick:(id)sender;
- (IBAction)faqclick:(id)sender;
- (IBAction)fbclick:(id)sender;
- (IBAction)policyClick:(id)sender;
- (IBAction)termsClick:(id)sender;
- (IBAction)twitterclick:(id)sender;
- (IBAction)mobifolioclick:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *bottomLabel;
@property (weak, nonatomic) IBOutlet UIButton *privacyButton;
- (IBAction)sendConsoleButtonPressed:(id)sender;

@end
