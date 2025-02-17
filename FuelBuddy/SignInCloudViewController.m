//
//  SignInCloudViewController.m
//  FuelBuddy
//
//  Created by Swapnil on 14/09/17.
//  Copyright © 2017 Oraganization. All rights reserved.
//

#import "SignInCloudViewController.h"
#import "AppDelegate.h"
#import "commonMethods.h"
#import "WebServiceURL's.h"
#import "SettingsViewController.h"
#import "Loc_Table.h"
#import "T_Fuelcons.h"
#import "T_Trip.h"
#import "Services_Table.h"
#import "Veh_Table.h"
#import "LoggedInVC.h"
#import "Friends_Table.h"

@interface SignInCloudViewController ()
{
    NSMutableDictionary *dataDictionary;
    //BOOL flagStatus;
    NSString *personName;
}
@end

@implementation SignInCloudViewController

#pragma mark VIEW CONTROLLER METHODS

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.transparentView.hidden = YES;
    
    self.navigationController.navigationBar.barTintColor = [self colorFromHexString:@"#0098AB"];
    self.navigationController.navigationBar.tintColor =[UIColor whiteColor];
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.topItem.title= NSLocalizedString(@"sign_in", @"Sign In");
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor] , NSFontAttributeName: [UIFont fontWithName:@"Helvetica-Light" size:18.0] }];
    self.view.backgroundColor = [self colorFromHexString:@"#2c2c2c"];
    self.iunderstandView.backgroundColor = [self colorFromHexString:@"#2c2c2c"];

    BOOL cameFromOnBoard = [[NSUserDefaults standardUserDefaults] boolForKey:@"cameFromOnBoardScreen"];

    if(!cameFromOnBoard){

        UIImage *buttonImage = [UIImage imageNamed:@"nav_back"];

        UIButton *Button = [UIButton buttonWithType:UIButtonTypeCustom];

        [Button setBackgroundImage:buttonImage forState:UIControlStateNormal];

        Button.frame = CGRectMake(0.0, 0.0, buttonImage.size.width,buttonImage.size.height);

        UIBarButtonItem *BarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:Button];

        [Button addTarget:self action:@selector(backbuttonclick) forControlEvents:UIControlEventTouchUpInside];

        [self.navigationItem setLeftBarButtonItem:BarButtonItem];


        self.checkYes.hidden = YES;
    }else{

        self.checkYes.hidden = NO;
    }

    UIImage *rightButtonImage = [UIImage imageNamed:@"ic_info_outline.png"];
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightButton setBackgroundImage:rightButtonImage forState:UIControlStateNormal];
    rightButton.frame = CGRectMake(0.0, 0.0, rightButtonImage.size.width,rightButtonImage.size.height);
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    [rightButton addTarget:self action:@selector(rightButtonclick) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setRightBarButtonItem:rightBarButtonItem];
    
     //ENH_54 making sync free nikhil
    // NSMutableAttributedString *termsOfService = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"t_and_c",@"I agree to Simply Auto's Terms of Service and Privacy Policy.")];
     //New_8 changesDone
   //  [termsOfService addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range: [[termsOfService string] rangeOfString:NSLocalizedString(@"t_and_c",@"I agree to Simply Auto's Terms of Service and Privacy Policy.")]];
    //"pattern1"="Terms of Service"
   //  [termsOfService addAttribute:NSLinkAttributeName
  //   value:@"http://www.simplyauto.app/Terms2.html"
  //   range:[[termsOfService string] rangeOfString:NSLocalizedString(@"pattern1",@"Terms of Service")]];
     //New_8 changesDone
  //   [termsOfService addAttribute:NSLinkAttributeName
  //   value:@"http://www.simplyauto.app/policy.html"
   //  range:[[termsOfService string] rangeOfString:NSLocalizedString(@"pattern2",@"Privacy Policy")]];
     
   //  NSDictionary *linkAttributes = @{NSForegroundColorAttributeName: [self colorFromHexString:@"#FFCA1D"],
  //   NSUnderlineColorAttributeName: [self colorFromHexString:@"#FFCA1D"],
   //  NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
    
  //   self.termsText.linkTextAttributes = linkAttributes;
  //   self.termsText.attributedText = termsOfService;
   //  self.termsText.delegate = self;
    self.cloudImageView.image = [UIImage imageNamed:@"Cloud-Solution3.png"];
   // self.checkYes.selected = YES;
  //  [self.checkYes setImage:[UIImage imageNamed:@"check"] forState:UIControlStateSelected];
    //New_8 changesDone
  //  self.headingLabel.text = NSLocalizedString(@"sync_sign_in_you_can", @"After signing in you can");
    self.label1.text = NSLocalizedString(@"sync_sign_in_1", @"Instantly back up data on the cloud");
    self.label2.text = NSLocalizedString(@"sync_sign_in_2", @"Access your data on www.simplyauto.app*");
    self.label3.text = NSLocalizedString(@"sync_sign_in_3", @"Sync across multiple devices");
    self.label4.text = NSLocalizedString(@"sync_sign_in_4", @"Sync data with multiple drivers*");
    self.label5.text = NSLocalizedString(@"sync_sign_in_5", @"Instantly backup receipts on the cloud*");
    self.label6.text = NSLocalizedString(@"sync_sign_in_footnote", @"* Available in the pro version only");
    
    [GIDSignIn sharedInstance].clientID = [FIRApp defaultApp].options.clientID;
    [GIDSignIn sharedInstance].delegate = self;
    [GIDSignIn sharedInstance].presentingViewController = self;
    
//    NSString *fcmToken = [[FIRInstanceID instanceID] token];
//    NSLog(@"fcmtoken : %@", fcmToken);
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dismissVC)
                                                 name:@"dismissSignInVC"
                                               object:nil];
    

}

-(void)viewWillDisappear:(BOOL)animated{
    
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"flagStatus"] isEqualToString:@"1"]){
    
        [[NSNotificationCenter defaultCenter] postNotificationName:@"dismissHelpVC" object:nil];
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"flagStatus"];
    }
}

//-(void)viewWillAppear:(BOOL)animated{
//   
//    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
//    
//}


- (void)dismissVC{
    
    
    [self dismissViewControllerAnimated:NO completion:^{
        
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:@"dismissSignInVC"
                                                      object:nil];
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    

}


- (void)viewDidAppear:(BOOL)animated{
    
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    //NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    //NSLog(@"emailID : %@", [def objectForKey:@"UserEmail"]);
    //NSLog(@"androidID : %@", [def objectForKey:@"UserDeviceId"]);
    
}

#pragma mark Textview METHODS
- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
//    if ([[URL scheme] isEqualToString:@"username"]) {
//        NSString *username = [URL host];
//        // do something with this username
//        // ...
//        return NO;
//    }
    return YES; // let the system open this URL
}

#pragma mark GENERAL METHODS

#if __IPHONE_OS_VERSION_MAX_ALLOWED < 90000
- (NSUInteger)supportedInterfaceOrientations
#else
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
#endif
{
    return UIInterfaceOrientationMaskPortrait;
}

-(BOOL)shouldAutorotate {
    return NO;
}

-(void)backbuttonclick
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)rightButtonclick
{
    self.transparentView.hidden = NO;
    self.dontWantBtnOt.hidden = YES;
    [self.iWantBtnOt setTitle:NSLocalizedString(@"ok", @"OK") forState:UIControlStateNormal];
}

-(UIColor *)colorFromHexString:(NSString *)hexString
{
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

- (void)showAlert: (NSString *)title message: (NSString *)message{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"OK") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {


        LoggedInVC *loggedIn = (LoggedInVC *)[self.storyboard instantiateViewControllerWithIdentifier:@"loggedInScreen"];
        loggedIn.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:loggedIn animated:YES completion:nil];
  
    }];
    
    [alertController addAction:okAction];
    
    [self.loadingView removeFromSuperview];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)showTermAlert: (NSString *)title message:(NSString *)message{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"OK") style:UIAlertActionStyleCancel handler:nil];
    
    //    UIAlertAction *canel = [UIAlertAction actionWithTitle:NSLocalizedString(@"no", @"No") style:UIAlertActionStyleDefault handler:nil];
    
    [alert addAction:ok];
    //[alert addAction:canel];
    [self presentViewController:alert animated:YES completion:nil];
    
}

- (void)startActivitySpinner: (NSString *)labelText {
    // [[self driveService] setAuthorizer:auth];
    
    
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    if(app.result.width == 320)
    {
        self.loadingView = [[UIView alloc]initWithFrame:CGRectMake(120, 200, 80, 80)];
    }
    else
    {
        self.loadingView = [[UIView alloc]initWithFrame:CGRectMake(150, 200, 80, 80)];
    }
    self.loadingView.backgroundColor = [UIColor colorWithWhite:0. alpha:0.6];
    self.loadingView.layer.cornerRadius = 5;
    
    UIActivityIndicatorView *activityView=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityView.center = CGPointMake(_loadingView.frame.size.width / 2.0, 35);
    
    [activityView startAnimating];
    
//    if(flagStatus == false){
//        [activityView stopAnimating];
//    }
    activityView.tag = 100;
    [self.loadingView addSubview:activityView];
    
    UILabel* lblLoading = [[UILabel alloc]initWithFrame:CGRectMake(0, 48, 80, 30)];
    lblLoading.text = labelText;
    lblLoading.textColor = [UIColor whiteColor];
    lblLoading.font = [UIFont fontWithName:lblLoading.font.fontName size:13];
    lblLoading.textAlignment = NSTextAlignmentCenter;
    
    [self.loadingView addSubview:lblLoading];
    [self.view addSubview:self.loadingView];
    
    
}


#pragma mark SIGN IN

- (IBAction)signInPressed:(id)sender {

     [[GIDSignIn sharedInstance] signIn];
}

- (IBAction)signInButtonPressed:(UIButton *)sender {

     [[GIDSignIn sharedInstance] signIn];
}

- (IBAction)checkedButton:(UIButton *)sender {

    self.transparentView.hidden = NO;
    self.dontWantBtnOt.hidden = NO;
    //TODO localization
    [self.iWantBtnOt setTitle:@"I want to Sign In" forState:UIControlStateNormal];
    [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"infoClicked"];


}


-(void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error{
    
    [self startActivitySpinner:NSLocalizedString(@"pb_connecting", @"Signing In..")];
    if(error == nil){
        
        GIDAuthentication *authentication = user.authentication;
        FIRAuthCredential *credential = [FIRGoogleAuthProvider credentialWithIDToken:authentication.idToken    accessToken:authentication.accessToken];

        [[FIRAuth auth] signInWithCredential:credential
                                  completion:^(FIRAuthDataResult * _Nullable authResult,
                                               NSError * _Nullable error) {
            if (error) {
                // ...
                return;
            }
            // User successfully signed in. Get user data from the FIRUser object
            if (authResult == nil) { return; }
            FIRUser *user = authResult.user;
            if(user){


                NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
                //                NSString *providerId = user.providerID;
                //                NSString *uid = user.uid;
                NSString *email = user.email;
                personName = user.displayName;
                //                NSLog(@"Provider ID : %@", providerId);
                //                NSLog(@"uID : %@", uid);
                //                NSLog(@"email ID : %@", email);
                //                NSLog(@"name : %@", user.displayName);
                //
                [def setObject:user.email forKey:@"UserEmail"];
                [def setObject:user.displayName forKey:@"UserName"];

                [def setBool:YES forKey:@"signInStatus"];

                // self.signInButton.enabled = NO;
                [self getName:user.displayName email:email];

            }
            else {
                NSLog(@"%@", error.localizedDescription);
                [self.loadingView removeFromSuperview];
            }
            // ...
        }];

//        [[FIRAuth auth] signInWithCredential:credential completion:^(FIRUser * _Nullable user, NSError * _Nullable error) {
//
//
//        }];
    }else{
 //put something here to show the error
        
          [self showAlert:@"Failed to log in." message:error.localizedDescription];
           
        
         [self.loadingView removeFromSuperview];
    }
  
    
}

- (void)getName: (NSString *)name email: (NSString *)emailID{
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    //__block fcmToken;
    [[FIRInstanceID instanceID] instanceIDWithHandler:^(FIRInstanceIDResult * _Nullable result,
                                                        NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Error fetching remote instance ID: %@", error);
        } else {
            NSString *fcmToken = result.token;
            NSLog(@"Remote instance ID token: %@", result.token);

            NSString *deviceID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
            // NSLog(@"device ID = %@", deviceID);

            [def setObject:fcmToken forKey:@"UserRegId"];
            [def setObject:deviceID forKey:@"UserDeviceId"];

            NSString *urlString = kProfileScript;
            NSURL *url = [NSURL URLWithString:urlString];

            NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
            NSURLSession *session = [NSURLSession sessionWithConfiguration:config];

            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
            [request setHTTPMethod:@"POST"];

            NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
            [dictionary setValue:emailID forKey:@"email"];
            [dictionary setValue:deviceID forKey:@"androidId"];
            [dictionary setValue:name forKey:@"personName"];
            [dictionary setValue:fcmToken forKey:@"regId"];

            //ENH_54 4june2018 nikhil
            if(![[NSUserDefaults standardUserDefaults] boolForKey:@"isSubscribed"] && ![[NSUserDefaults standardUserDefaults] boolForKey:@"isAdDisabled"]){

                [dictionary setValue:@0 forKey:@"pro_status"];

            }else if(![[NSUserDefaults standardUserDefaults] boolForKey:@"isSubscribed"] && [[NSUserDefaults standardUserDefaults] boolForKey:@"isAdDisabled"]){

                [dictionary setValue:@1 forKey:@"pro_status"];

            }else if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isSubscribed"]){

                [dictionary setValue:@2 forKey:@"pro_status"];

            }

            NSError *err;
            NSData *postData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:&err];

            [request setHTTPBody:postData];

            NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {


                dataDictionary = [[NSMutableDictionary alloc] init];
                if(data){
                    dataDictionary = [NSJSONSerialization JSONObjectWithData:data
                                                                     options:kNilOptions
                                                                       error:&error];
                }


                //NSLog(@"Response Data Dictionary:- %@",dataDictionary);

                if([[dataDictionary objectForKey:@"message"] isEqualToString:@"Success"] && [[dataDictionary objectForKey:@"success"]  isEqual: @1]){

                    [self performSelectorOnMainThread:@selector(receivedData:) withObject:dataDictionary waitUntilDone:YES];
                }else{

                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self showTermAlert:NSLocalizedString(@"failed",@"Failed") message:NSLocalizedString(@"sign_in_failed",@"Sign In failed, please try again later")];
                        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"UserEmail"];
                        // self.signInButton.enabled = YES;
                        [self.loadingView removeFromSuperview];
                    });

                }

            }];
            [dataTask resume];
        }
    }];

    //NSString *fcmToken = [[FIRInstanceID instanceID] token];
   // NSLog(@"fcmtoken : %@", fcmToken);
    
    

    
}

//new_7 june2018 nikhil friends should sync after signing again!
- (void)receivedData: (NSDictionary *)data{
    
    //Requested_by_user will come in data, make use of this for add drivers count 4jun2018
    //NSLog(@"received data : %@", data);
    
    //TODO check for no_friends_found
    [self saveToFriendTable:data];
    //New_8 changesDone
    NSString *loggedInDesc = NSLocalizedString(@"loggedInLabel", @"All your data will always be backed up on cloud\nYou can also access your data by going to www.simplyauto.app");
    NSString *welcomeMsg = NSLocalizedString(@"logInAlert", @"You have successfully signed in");
    
    [self showAlert:welcomeMsg message:loggedInDesc];
}

-(void)saveToFriendTable: (NSDictionary *)data{
    
    //NSLog(@"jsonData:- %@",data);
    NSArray *allEmails = [data objectForKey:@"all_friends_emails"];
    NSArray *allNames = [data objectForKey:@"all_friends_names"];
    NSArray *allStatus = [data objectForKey:@"all_status"];
    NSArray *allRequestedByUser = [data objectForKey:@"requested_by_user"];
    
    
    NSManagedObjectContext *context = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSError *err;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Friends_Table"];
    NSArray *datavalue = [context executeFetchRequest:request error:&err];
    //NSLog(@"friend is there? ::%@",datavalue);
    
    for(Friends_Table *delRecord in datavalue){
        
        [context deleteObject:delRecord];
        
    }
    if ([context hasChanges])
    {
        BOOL saved = [context save:&err];
        if (!saved) {
            // do some real error handling
            //CLSLog(@“Could not save Data due to %@“, error);
        }
        [[CoreDataController sharedInstance] saveMasterContext];
    }
    
    for(int i=0;i<allNames.count;i++){
        
        Friends_Table *friendData = [NSEntityDescription insertNewObjectForEntityForName:@"Friends_Table" inManagedObjectContext:context];
    
        friendData.name = [allNames objectAtIndex:i];
        friendData.email = [allEmails objectAtIndex:i];
        if([[allStatus objectAtIndex:i] isEqualToString:@"confirmed"]){
            friendData.status = @"confirm";
        }else if([[allStatus objectAtIndex:i] isEqualToString:@"request sent"]){
            friendData.status = @"request sent";
        }else if([[allStatus objectAtIndex:i] isEqualToString:@"request received"]){
            friendData.status = @"request";
        }
        friendData.requested_by_me = [[allRequestedByUser objectAtIndex:i] stringValue];
    
    }
        if ([context hasChanges])
        {
            BOOL saved = [context save:&err];
            if (!saved) {
                // do some real error handling
                //CLSLog(@“Could not save Data due to %@“, error);
            }
            [[CoreDataController sharedInstance] saveMasterContext];
        }
    
}

- (IBAction)dontWantPressed:(UIButton *)sender {

        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"signInDone"];
        [self dismissViewControllerAnimated:NO completion:nil];

}

- (IBAction)iWantPressed:(UIButton *)sender {

        self.transparentView.hidden = YES;

}
@end
