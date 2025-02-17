//
//  ResyncVC.h
//  FuelBuddy
//
//  Created by Swapnil on 12/11/17.
//  Copyright © 2017 Oraganization. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ResyncVC : UIViewController

@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UILabel *resyncLabel;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet UILabel *descLabel2;
@property (weak, nonatomic) IBOutlet UIButton *checkYes;
@property (weak, nonatomic) IBOutlet UIButton *checkNo;
- (IBAction)checkYesPressed:(id)sender;
- (IBAction)checkNoPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *labelYes;
@property (weak, nonatomic) IBOutlet UILabel *labelNo;
@property (weak, nonatomic) IBOutlet UIButton *buttonOk;
@property (weak, nonatomic) IBOutlet UIButton *buttonCancel;
- (IBAction)buttonOkPressed:(id)sender;
- (IBAction)buttonCancelPressed:(id)sender;

- (void)fullUpload;

@property (nonatomic, copy) void (^onDismiss)(UIViewController *sender, NSString* message);
@property (nonatomic, copy) void (^onDeregisterDismiss)(UIViewController *sender, NSString* message);
@property (nonatomic, retain)UIView *loadingView;

@property (nonatomic, strong) UIViewController *fromViewController;


@end
