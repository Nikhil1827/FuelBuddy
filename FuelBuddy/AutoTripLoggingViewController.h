//
//  AutoTripLoggingViewController.h
//  FuelBuddy
//
//  Created by Nikhil on 29/10/18.
//  Copyright © 2018 Oraganization. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationManager.h"

@interface AutoTripLoggingViewController : UIViewController <UITextViewDelegate ,UIPickerViewDataSource,UIPickerViewDelegate>
@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (strong, nonatomic) IBOutlet UILabel *AutoTripSwitchLabel;
@property (strong, nonatomic) IBOutlet UISwitch *autoSwitch;
@property (strong, nonatomic) IBOutlet UIButton *checkYes;
@property (strong, nonatomic) IBOutlet UITextView *termsText;
@property (strong, nonatomic) IBOutlet UILabel *defaultTripType;
@property (strong, nonatomic) IBOutlet UILabel *weekDays;
@property (strong, nonatomic) IBOutlet UILabel *tripType;
@property (strong, nonatomic) IBOutlet UILabel *weekEnds;
@property (strong, nonatomic) IBOutlet UIButton *weekEndButtonOutLet;
@property (strong, nonatomic) IBOutlet UILabel *weekEndsTripType;
@property (strong, nonatomic) IBOutlet UIButton *doNotYes;
@property (strong, nonatomic) IBOutlet UILabel *doNotLabel;
@property (strong, nonatomic) IBOutlet UIButton *viewEditButtonLabel;
@property (strong, nonatomic) IBOutlet UILabel *FreetripsLabel;
@property (strong, nonatomic) IBOutlet UILabel *freeTripsCountLabel;
@property (strong, nonatomic) IBOutlet UIButton *upgradeButtonLabel;
@property (strong, nonatomic) IBOutlet UILabel *unlimitedLabel;
@property (strong,nonatomic) LocationManager * shareModel;
@property (nonatomic,retain)UIPickerView *picker;
@property (nonatomic,retain)UIButton *setbutton;
@property (nonatomic,retain)NSMutableArray *tripTypeArray;
@property (nonatomic,retain)NSString *weekDaytripType,*weekEndTripType;

- (IBAction)autoSwitchClicked:(UISwitch *)sender;
- (IBAction)checkedButton:(UIButton *)sender;
- (IBAction)tripTypeClicked:(UIButton *)sender;
- (IBAction)weenEndsTripTypeClicked:(UIButton *)sender;
- (IBAction)doNotDetectClicked:(UIButton *)sender;
- (IBAction)viewEditClicked:(UIButton *)sender;
- (IBAction)upgradeButtonClicked:(UIButton *)sender;
@end
