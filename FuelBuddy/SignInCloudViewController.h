//
//  SignInCloudViewController.h
//  FuelBuddy
//
//  Created by Swapnil on 14/09/17.
//  Copyright © 2017 Oraganization. All rights reserved.
//

#import <UIKit/UIKit.h>
@import Firebase;
@import GoogleSignIn;

//GIDSignInUIDelegate,
@interface SignInCloudViewController : UIViewController <GIDSignInDelegate, FIRMessagingDelegate, NSURLSessionTaskDelegate, NSURLSessionDelegate, UITextViewDelegate>
@property (strong, nonatomic) IBOutlet UIButton *dontWantBtnOt;
@property (strong, nonatomic) IBOutlet UIButton *iWantBtnOt;
- (IBAction)dontWantPressed:(UIButton *)sender;
- (IBAction)iWantPressed:(UIButton *)sender;


@property (strong, nonatomic) IBOutlet UIView *transparentView;

@property (strong, nonatomic) IBOutlet UIView *iunderstandView;

@property (strong, nonatomic) IBOutlet UIButton *signInBtnOt;
@property (weak, nonatomic) IBOutlet GIDSignInButton *signInButton;
- (IBAction)signInPressed:(id)sender;
- (IBAction)signInButtonPressed:(UIButton *)sender;

- (IBAction)checkedButton:(UIButton *)sender;

@property (strong, nonatomic) IBOutlet UIImageView *cloudImageView;


- (void)getName: (NSString *)name email: (NSString *)emailID;
@property (nonatomic,retain)UIView *loadingView;
//@property (weak, nonatomic) IBOutlet UITextView *termsText;
@property (weak, nonatomic) IBOutlet UIButton *checkYes;
//@property (weak, nonatomic) IBOutlet UILabel *headingLabel;
@property (weak, nonatomic) IBOutlet UILabel *label1;
@property (weak, nonatomic) IBOutlet UILabel *label2;
@property (weak, nonatomic) IBOutlet UILabel *label3;
@property (weak, nonatomic) IBOutlet UILabel *label4;
@property (weak, nonatomic) IBOutlet UILabel *label5;
@property (weak, nonatomic) IBOutlet UILabel *label6;


@end
