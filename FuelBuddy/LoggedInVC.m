//
//  LoggedInVC.m
//  FuelBuddy
//
//  Created by Swapnil on 12/11/17.
//  Copyright © 2017 Oraganization. All rights reserved.
//

#import "LoggedInVC.h"
#import "ResyncVC.h"
#import "AppDelegate.h"
#import "CloudHelpTableVC.h"
#import "SlideOutVC.h"
#import "WebServiceURL's.h"
#import "commonMethods.h"
#import "Reachability.h"
#import "Friends_Table.h"
#import "Veh_Table.h"
#import "T_Fuelcons.h"
#import "T_Trip.h"
#import "Services_Table.h"
#import "AddDriverTableViewCell.h"
#import "AddDriverViewController.h"
#import "MBProgressHUD.h"
#import "FullSyncViewController.h"
#import "SSZipArchive.h"
#import "QNSURLConnection.h"
#import "GoProViewController.h"

@import MobileCoreServices;
@interface LoggedInVC ()
{
    NSArray *tableViewContents;
    NSMutableDictionary *dataDictionary;
    BOOL deletedFriend;
    BOOL vehicleFound;
}
@end

@implementation LoggedInVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    self.navigationController.navigationBar.barTintColor = [self colorFromHexString:@"#0098AB"];
    self.navigationController.navigationBar.tintColor =[UIColor whiteColor];
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.topItem.title= [def objectForKey:@"UserName"];
    
    //self.navigationController.navigationBar.topItem.prompt = [def objectForKey:@"UserEmail"];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor] , NSFontAttributeName: [UIFont fontWithName:@"Helvetica-Light" size:18.0] }];
    self.view.backgroundColor = [self colorFromHexString:@"#2c2c2c"];
    //top , left, bottom, right
    UIImage *buttonImage = [[UIImage imageNamed:@"nav_back"] resizableImageWithCapInsets:UIEdgeInsetsMake(20,10,10,10)];
    UIButton *Button = [UIButton buttonWithType:UIButtonTypeCustom];
    [Button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    Button.frame = CGRectMake(0.0, 10.0, buttonImage.size.width+4,buttonImage.size.height+4);
    UIBarButtonItem *BarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:Button];
    [Button addTarget:self action:@selector(backbuttonclick) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setLeftBarButtonItem:BarButtonItem];
    
    self.lastSyncLabel.textColor = [UIColor whiteColor];
    
    BOOL proUser = [[NSUserDefaults standardUserDefaults] boolForKey:@"isAdDisabled"];
    
    if(!proUser){
        self.proLabel.text = NSLocalizedString(@"receipt_pro_only", @"*Receipt images are not backed up in the free version");
    }else{
        self.proLabel.hidden = YES;
    }
    
    //ADD DRIVER SCENE 19april
    //Nikhil adding driver tableView view properties
    self.addDriverTableView.backgroundColor = [self colorFromHexString:@"#2c2c2c"];
    self.addDriverTableView.separatorColor = [UIColor darkGrayColor]; //[self colorFromHexString:@"#2c2c2c"];
    self.addDriverTableView.delegate = self;
    self.addDriverTableView.dataSource = self;
    [self fetchDrivers];
    [self.addDriverTableView reloadData];
    //[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"doSignIn"];
    deletedFriend = NO;
    
}

- (void)dismissAfterDeregister{
    
    [self.navigationController dismissViewControllerAnimated:NO completion:^{
        
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:@"dismissAfterDeregister"
                                                      object:nil];
    }];
}


- (void)updateTS{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd-MMM-yyyy HH:mm"];
    
    NSDate *date = [[NSUserDefaults standardUserDefaults] objectForKey:@"localTimeStamp"];
    NSString *dateString = [formatter stringFromDate:date];
    
    //NSLog(@"dateString : %@", dateString);
    dispatch_async(dispatch_get_main_queue(), ^{
       if([[NSUserDefaults standardUserDefaults] objectForKey:@"localTimeStamp"] != nil){
        
          self.lastSyncLabel.text = dateString;
       } else {
        
          self.lastSyncLabel.text = @"";
       }
     
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"timeStamp"
                                                  object:nil];
    });
}


- (void)goToSlideOutScreen{
    
    [[NSUserDefaults standardUserDefaults] setObject:@"yes" forKey:@"slideOutOn"];
    SlideOutVC *slideVC = (SlideOutVC *)[self.storyboard instantiateViewControllerWithIdentifier:@"slideOut"];
    //slideVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:slideVC animated:NO completion:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self fetchDrivers];
    [self.addDriverTableView reloadData];
    
    UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *buttonBg;
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    if([def boolForKey:@"redRequest"]){
        
        buttonBg = [UIImage imageNamed:@"tab_more_redActive"];
        
    }else{
        
        buttonBg = [UIImage imageNamed:@"tab_more_active"];//
    }
    //CGRectMake(CGFloat x, CGFloat y, CGFloat width, CGFloat height)
    //top , left, bottom, right
    
    [moreButton setBackgroundImage:buttonBg forState:UIControlStateNormal];
    [moreButton addTarget:self action:@selector(goToSlideOutScreen) forControlEvents:(UIControlEvents)UIControlEventTouchUpInside];
    
    NSLayoutConstraint * widthConstraint = [moreButton.widthAnchor constraintEqualToConstant:36];
    NSLayoutConstraint * HeightConstraint =[moreButton.heightAnchor constraintEqualToConstant:32];
    [widthConstraint setActive:YES];
    [HeightConstraint setActive:YES];
    
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:moreButton];
    
    [self.navigationItem setRightBarButtonItem:rightBarButton];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateTS)
                                                 name:@"timeStamp"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dismissAfterDeregister)
                                                 name:@"dismissAfterDeregister"
                                               object:nil];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd-MMM-yyyy HH:mm"];
    
    NSDate *date = [[NSUserDefaults standardUserDefaults] objectForKey:@"localTimeStamp"];
    NSString *dateString = [formatter stringFromDate:date];

   // NSLog(@"dateString : %@", dateString);
    
    if(dateString != nil){
    
        self.lastSyncLabel.text = dateString;
    } else {
        
        self.lastSyncLabel.text = @"";
    }
    //nikhil driver page come back should not sign in
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"doSignIn"]){
        [self startActivitySpinner:NSLocalizedString(@"pb_connecting", @"Signing In..")];
        
    }
    
}

- (void)viewDidAppear:(BOOL)animated{
    //nikhil driver page come back should not sign in
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"doSignIn"]){
      [self checkNetworkForCloudStorage];
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    if(![[def objectForKey:@"slideOutOn"] isEqualToString:@"yes"]){
    
        [def setObject:@"1" forKey:@"flagStatus"];
        
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"dismissSignInVC" object:nil];
}

- (void)checkNetworkForCloudStorage{
    
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    
    if(networkStatus == NotReachable){
        
        [self.loadingView removeFromSuperview];
        [self showAlertAndDismiss:@"Failed to Sign in" message:@"Please check your internet connection and try again later"];
    } else {
        
        [self callProfileScript];
    }
}

- (void)showAlertAndDismiss: (NSString *)title message:(NSString *)message{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"OK") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
    
}


- (void)callProfileScript{
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:[def objectForKey:@"UserEmail"] forKey:@"email"];
    [dictionary setValue:[def objectForKey:@"UserDeviceId"] forKey:@"androidId"];
    [dictionary setValue:[def objectForKey:@"UserName"] forKey:@"personName"];
    [dictionary setValue:[def objectForKey:@"UserRegId"] forKey:@"regId"];
    
    //5june2018 nikhil
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"isSubscribed"] && ![[NSUserDefaults standardUserDefaults] boolForKey:@"isAdDisabled"]){
        
        [dictionary setValue:@0 forKey:@"pro_status"];
        
    }else if(![[NSUserDefaults standardUserDefaults] boolForKey:@"isSubscribed"] && [[NSUserDefaults standardUserDefaults] boolForKey:@"isAdDisabled"]){
        
        [dictionary setValue:@1 forKey:@"pro_status"];
        
    }else if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isSubscribed"]){
        
        [dictionary setValue:@2 forKey:@"pro_status"];
        
    }
    
    //NSLog(@"sent dictionary:- %@",dictionary);
    
    NSString *urlString = kProfileScript;
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    
    NSError *err;
    NSData *postData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:&err];
    
    [request setHTTPBody:postData];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        dataDictionary = [[NSMutableDictionary alloc] init];
        if(data != nil){

            dataDictionary = [NSJSONSerialization JSONObjectWithData:data
                                                             options:kNilOptions
                                                               error:&error];

            //NSLog(@"Response Data Dictionary:- %@",dataDictionary);

            if([[dataDictionary objectForKey:@"message"] isEqualToString:@"Success"] && [[dataDictionary objectForKey:@"success"]  isEqual: @1]){

                [self performSelectorOnMainThread:@selector(receivedData:) withObject:dataDictionary waitUntilDone:YES];
            }else{

                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.loadingView removeFromSuperview];
                    [self showSignInFailedAlert:NSLocalizedString(@"failed",@"Failed")  message:NSLocalizedString(@"sign_in_failed",@"Sign In failed, please try again later")];
                    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"UserEmail"];
                    //NSLog(@"Sign In Failed due to Error:- %@", error.localizedDescription);
                });
                
            }
        }else{

            dispatch_async(dispatch_get_main_queue(), ^{
                [self.loadingView removeFromSuperview];
            });
            [self showSignInFailedAlert:NSLocalizedString(@"failed",@"Failed")  message:NSLocalizedString(@"sign_in_failed",@"Sign In failed, please try again later")];
            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"UserEmail"];
            //NSLog(@"Sign In Failed due to Error:- %@", error.localizedDescription);
        }

        
    }];
    [dataTask resume];
    
}


- (void)receivedData: (NSData *)data{
    
   // NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
   // NSLog(@"received data : %@", data);
    //NSString *welcomeMsg = [NSString stringWithFormat:@"You have successfully signed in, %@", [def objectForKey:@"UserName"]];
    [self.loadingView removeFromSuperview];
    //[self showAlert:welcomeMsg message:@""];
    
    [self checkForTimeStamp:data];
}


- (void)checkForTimeStamp: (NSData *)response{
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd-MMM-yyyy HH:mm"];
    [formatter setLocale:[NSLocale currentLocale]];
    NSTimeInterval dateTime = [[[dataDictionary valueForKey:@"sync_ts"] objectAtIndex:0] doubleValue];
    
    NSDate *dateFromServer = [NSDate dateWithTimeIntervalSince1970:dateTime];
    NSLog(@"server date : %@", dateFromServer);
    
   // NSLog(@"sync_ts : %@", [[dataDictionary valueForKey:@"sync_ts"] objectAtIndex:0]);

    NSTimeInterval dateTime1 = [[[dataDictionary valueForKey:@"sync_ts"] objectAtIndex:1] doubleValue];

    NSDate *dateFromServer1 = [NSDate dateWithTimeIntervalSince1970:dateTime1/1000];

    NSDate *localTimeStamp = [def objectForKey:@"localTimeStamp"];

    NSTimeInterval secondsInEightHours = 3 * 60;
    NSDate *localTimeDate = [localTimeStamp dateByAddingTimeInterval:secondsInEightHours];
    NSLog(@"localTimeDate : %@", localTimeDate);
    //BUG_165 12june2018 nikhil add 2minsbuffer to localtimestamp
   // NSLog(@"ts from phone : %@", localTimeStamp);
    
    int tsFactor = [[[dataDictionary valueForKey:@"sync_ts"] objectAtIndex:0] intValue];
    [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"signInDone"];

    NSString *log_date = [self getMaxLogDate];

    if(tsFactor == 0){
        
        //User signs in first time and there is no data on cloud, so full upload phone data on server in background
        [self performSelectorInBackground:@selector(uploadDataInBg) withObject:nil];

        BOOL cameFromOnBoard = [[NSUserDefaults standardUserDefaults] boolForKey:@"cameFromOnBoardScreen"];

        if(cameFromOnBoard){

            [self dismissViewControllerAnimated:NO completion:nil];
        }

    }
    
    if([def objectForKey:@"localTimeStamp"] == nil && tsFactor > 0){
        
        //User signs in first time or signs in after deregister, and data exists on cloud for that email
        [def setObject:@"detectedDataFirstTime" forKey:@"resyncPopup"];
        ResyncVC *resync = (ResyncVC *)[self.storyboard instantiateViewControllerWithIdentifier:@"resyncScreen"];
        resync.fromViewController = self;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(textForSpinner:)
                                                     name:@"downloadFinish"
                                                   object:nil];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(textForSpinner:)
                                                     name:@"downloadStarted"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(textForSpinner:)
                                                     name:@"settingsFinish"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(textForSpinner:)
                                                     name:@"vehicleFinish"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(textForSpinner:)
                                                     name:@"logFinish"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(textForSpinner:)
                                                     name:@"upload"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(textForSpinner:)
                                                     name:@"uploadFinish"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(textForSpinner:)
                                                     name:@"failError"
                                                   object:nil];
        
        resync.onDeregisterDismiss = ^(UIViewController *sender, NSString *message) {
            
            [self deregisterPopup];
        };
        
        resync.onDismiss = ^(UIViewController *sender, NSString *message) {
            
        };
        
        dispatch_async(dispatch_get_main_queue(), ^{

            [self presentViewController:resync animated:YES completion:nil];
            
        });
    }

    if([dateFromServer compare:localTimeDate] == NSOrderedDescending){

        NSLog(@"server date : %@", dateFromServer1);
        NSLog(@"log_date : %@", log_date);

        //    //if cloud max log date is less than phone max log date
        //    //else if cloud max log date is 0 and phone max log date > 0
        //    //else if phone max log date < cloud max log date
        //    else {...}

        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"dd-MMM-yyyy HH:mm"];
        NSString *dateFromServer1String = [formatter stringFromDate:dateFromServer1];

       // NSString *logDateString = [formatter stringFromDate:log_date];

       // NSDate *dateFSInFormat = [formatter dateFromString:dateFromServer1String];

        //NSLog(@"converted serverdate : %@", dateFSInFormat);

        NSMutableDictionary *stringNDateArray = [[NSMutableDictionary alloc] init];

        //ithun
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:@"dd-MMM-yyyy HH:mm"];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];

        NSDate *startTime = [dateFormatter dateFromString:dateFromServer1String];
        NSDate *endTime = [dateFormatter dateFromString:log_date];
        //itha
        NSLog(@"startTime : %@", startTime);
        NSLog(@"log_date : %@", log_date);

        //[startTime earlierDate:endTime]
        if(startTime > 0 && [endTime compare: startTime] == NSOrderedDescending){

            //Older data available on cloud
            [stringNDateArray setObject:@"OlderData" forKey:@"data"];
            [stringNDateArray setObject:dateFromServer1 forKey:@"dateFromServer1"];
            [def setObject:stringNDateArray forKey:@"resyncPopup1"];

        }else if (startTime == 0 && endTime > 0){

            //No data exists on cloud
            [stringNDateArray setObject:@"NoDataExists" forKey:@"data"];
            [def setObject:stringNDateArray forKey:@"resyncPopup1"];
        }else if ([startTime compare: endTime] == NSOrderedDescending){

            //Newer data exists on cloud
            [stringNDateArray setObject:@"NewerData" forKey:@"data"];
            [stringNDateArray setObject:dateFromServer1 forKey:@"dateFromServer1"];
            [def setObject:stringNDateArray forKey:@"resyncPopup1"];
        }else{

            //Server time stamp is greater than phones time stamp
            [stringNDateArray setObject:@"detectedData" forKey:@"data"];
            [def setObject:stringNDateArray forKey:@"resyncPopup1"];
        }

        ResyncVC *resync = (ResyncVC *)[self.storyboard instantiateViewControllerWithIdentifier:@"resyncScreen"];
        resync.fromViewController = self;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(textForSpinner:)
                                                     name:@"downloadFinish"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(textForSpinner:)
                                                     name:@"downloadStarted"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(textForSpinner:)
                                                     name:@"settingsFinish"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(textForSpinner:)
                                                     name:@"vehicleFinish"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(textForSpinner:)
                                                     name:@"logFinish"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(textForSpinner:)
                                                     name:@"upload"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(textForSpinner:)
                                                     name:@"uploadFinish"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(textForSpinner:)
                                                     name:@"failError"
                                                   object:nil];
        
        resync.onDeregisterDismiss = ^(UIViewController *sender, NSString *message) {
            
            [self deregisterPopup];
        };
        
        resync.onDismiss = ^(UIViewController *sender, NSString *message) {
            
        };
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:resync animated:YES completion:nil];
            
        });
    }
    
}

-(NSString *)getMaxLogDate{

    //getlastrecord from log and then get its NSDate
    NSArray *allValuesArray = [[NSMutableArray alloc]init];
    allValuesArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"SortedLog"];

    NSLog(@"allValuesArray:- %@",allValuesArray);
    NSString *log_date = [[NSString alloc] init];
    if(allValuesArray.count>0){

        NSDictionary *lastDict = [[NSDictionary alloc] initWithDictionary:allValuesArray.lastObject];
        id log_dateValue = [lastDict valueForKey:@"date"];
//        if ([log_dateValue isKindOfClass:[NSDate class]]) {
//            log_date = (NSDate *)log_dateValue;
//        } else {
//            NSLog(@"Something is wrong");
            log_date = log_dateValue;
//        }
        NSLog(@"log_date:- %@",log_date);
    }

    return log_date;
}

- (void)uploadDataInBg{
    
    UIApplication *app = [UIApplication sharedApplication];
    __block UIBackgroundTaskIdentifier bgTask;
    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        
        [app endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    
    ResyncVC *resync = [[ResyncVC alloc] init];
    [resync fullUpload];
        
    });
}

-(BOOL)shouldAutorotate {
    return NO;
}

-(void)backbuttonclick
{
     [self.navigationController dismissViewControllerAnimated:YES completion:nil];

}

-(void)downldbuttonclick{
    
    FullSyncViewController *fullSyncView = [self.storyboard instantiateViewControllerWithIdentifier:@"fullSyncRequest"];
    fullSyncView.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController pushViewController:fullSyncView animated:YES];
     
}

-(UIColor *)colorFromHexString:(NSString *)hexString
{
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)startActivitySpinner: (NSString *)labelText {
    // [[self driveService] setAuthorizer:auth];

    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.loadingView = [[UIView alloc]initWithFrame:CGRectMake(app.result.width/2-50, app.result.height/2-50, 100, 100)];
    self.loadingView.backgroundColor = [UIColor colorWithWhite:0. alpha:0.6];
    self.loadingView.layer.cornerRadius = 5;
    
    UIActivityIndicatorView *activityView=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityView.center = CGPointMake(_loadingView.frame.size.width / 2.0, 35);
    
    [activityView startAnimating];

    activityView.tag = 100;
    [self.loadingView addSubview:activityView];

    UILabel* lblLoading = [[UILabel alloc]initWithFrame:CGRectMake(3, 48, 100, 50)];
    lblLoading.text = labelText;
    lblLoading.numberOfLines = 2;
    lblLoading.textColor = [UIColor whiteColor];
    lblLoading.font = [UIFont fontWithName:lblLoading.font.fontName size:13];
    lblLoading.textAlignment = NSTextAlignmentCenter;
    
    [self.loadingView addSubview:lblLoading];
    [self.view addSubview:self.loadingView];
    
}

//#pragma mark Table View datasource methods
//
//-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    
//    return tableViewContents.count;
//}
//
//-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
//    if(cell == nil){
//        
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
//    }
//    
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
//    cell.accessoryType =  UITableViewCellAccessoryDisclosureIndicator;
//    cell.backgroundColor=[UIColor clearColor];
//    cell.textLabel.text = [tableViewContents objectAtIndex:indexPath.row];
//    cell.textLabel.textColor = [UIColor whiteColor];
//
//    return cell;
//}
//
//-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    
//    if(indexPath.row == 0){
//        
//        ResyncVC *resync = (ResyncVC *)[self.storyboard instantiateViewControllerWithIdentifier:@"resyncScreen"];
//        
//        resync.onDismiss = ^(UIViewController *sender, NSString* message)
//        {
//            // Do your stuff after dismissing the modal view controller
//            //NSLog(@"Modal dissmissed");
//            
//            //[self startActivitySpinner:@"Downloading"];
//            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                
////                [[NSNotificationCenter defaultCenter] addObserver:self
////                                                         selector:@selector(textForSpinner:)
////                                                             name:@"callSpinner"
////                                                           object:nil];
//            });
//            
//            
//            
//            
//        };
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self presentViewController:resync animated:YES completion:nil];
//        });
//        
//    }
//    
//    if(indexPath.row == 1){
//        
//        CloudHelpTableVC *cloudHelp = (CloudHelpTableVC *)[self.storyboard instantiateViewControllerWithIdentifier:@"cloudHelpTableVC"];
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self presentViewController:cloudHelp animated:YES completion:nil];
//        });
//    }
//    
//    if(indexPath.row == 2){
//        
//        
//    }
//}


- (void)textForSpinner: (NSNotification *)notification{
    
    //NIKHIL BUG_147
    AppDelegate *app = [[AppDelegate alloc]init];
    UIView *topView = app.topView;
    [[topView viewWithTag:101] removeFromSuperview];
    
    
//    if([[notification name] isEqualToString:@"downloadStarted"]){
//        [resync.loadingView removeFromSuperview];
//
//        [self startActivitySpinner:@"Downloading from cloud"];
//
//    }
//
    if([[notification name] isEqualToString:@"downloadFinish"]){
        
        [self.loadingView removeFromSuperview];
        //[[NSNotificationCenter defaultCenter] removeObserver:self name:@"downloadStarted" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"downloadFinish" object:nil];
        [self startActivitySpinner:@"Downloading Settings"];
    }
    
    if([[notification name] isEqualToString:@"settingsFinish"]){
        
        [self.loadingView removeFromSuperview];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"settingsFinish" object:nil];
        [self startActivitySpinner:@"Downloading Vehicles"];
        
    }
    
    if([[notification name] isEqualToString:@"vehicleFinish"]){
        
        [self.loadingView removeFromSuperview];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"vehicleFinish" object:nil];
        [self startActivitySpinner:@"Downloading Log"];
        
    }
    
    if([[notification name] isEqualToString:@"logFinish"]){
        
        [self.loadingView removeFromSuperview];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"logFinish" object:nil];
        
        NSDate *date = [[NSDate alloc] init];
        //NSLog(@"localTS : %@", date);
        [[NSUserDefaults standardUserDefaults] setObject:date forKey:@"localTimeStamp"];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"timeStamp"
                                                            object:nil];
        
        [self showAlert:@"Data downloaded successfully" message:@""];
        
    }
    
    if([[notification name] isEqualToString:@"upload"]){
        
        [self startActivitySpinner:@"Uploading to cloud.."];
        
    }
    
    if([[notification name] isEqualToString:@"uploadFinish"]){
        
        [self.loadingView removeFromSuperview];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"upload" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"uploadFinish" object:nil];
        [self showAlert:@"Phone data backed up to cloud" message:@""];
        
    }
    
   if([[notification name] isEqualToString:@"failError"]){
        
        [self.loadingView removeFromSuperview];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"upload" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"failError" object:nil];
        //NIKHIL BUG_149
       NSString *message =  [notification.userInfo objectForKey:@"message"];
       //!= nil ? [notification.userInfo objectForKey:@"message"] : @"Failed to upload all data";
        [self showAlert:NSLocalizedString(@"failed",@"Failed") message:message];
        
    }
    
}

- (void)showAlert: (NSString *)title message:(NSString *)message{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"OK") style:UIAlertActionStyleCancel handler:nil];
    
//    UIAlertAction *canel = [UIAlertAction actionWithTitle:NSLocalizedString(@"no", @"No") style:UIAlertActionStyleDefault handler:nil];
    
    [alert addAction:ok];
    //[alert addAction:canel];
    [self presentViewController:alert animated:YES completion:nil];
    
}

- (void)showSignInFailedAlert: (NSString *)title message:(NSString *)message{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"OK") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action)
                         {
                             [self dismissViewControllerAnimated:NO completion:^{
                                 
                                 [self viewWillDisappear:NO];
                             }];
                         }];
    
    
    
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
    
}

#pragma mark Deregister 

- (void)deregisterPopup{
    
    NSString *title = NSLocalizedString(@"sync_deregister_title", @"Deregister from sync");
    NSString *message = NSLocalizedString(@"deregistermsg", @"Do you want to deregister from Sync? You will need to Sign in again to send and receive data from server");
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"yes", @"Yes")
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
                                        
                                        //NIKHIL BUG_147 script sent to background thread
                                        [self startActivitySpinner:@"Deregistering..."];
                                        UIApplication *app = [UIApplication sharedApplication];
                                        __block UIBackgroundTaskIdentifier bgTask;
                                        bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
                                                             
                                                [app endBackgroundTask:bgTask];
                                                bgTask = UIBackgroundTaskInvalid;
                                        }];
                                                         
                                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                                        [self callDeleteProfileScript];
                                                             
                                                });
                                                         //      [self callDeleteProfileScript];
                                }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"Cancel")
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             
                                                         }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
}

- (void)callDeleteProfileScript{
    
    //[self startActivitySpinner:@"Deregister"];
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    //NSMutableDictionary *syncDictionary = [[NSMutableDictionary alloc] init];
    
    NSError *err;
    [dictionary setValue:[def objectForKey:@"UserDeviceId"] forKey:@"androidId"];
    
    NSData *postData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:&err];
    
    commonMethods *common = [[commonMethods alloc] init];
    [def setBool:YES forKey:@"updateTimeStamp"];
    [common saveToCloud:postData urlString:kDeleteProfileScript success:^(NSDictionary *responseDict) {
        
        if([[responseDict objectForKey:@"success"] intValue] == 1){
            
            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"UserEmail"];
            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"localTimeStamp"];
            self.lastSyncLabel.text = @"";
            [[NSNotificationCenter defaultCenter] postNotificationName:@"timeStamp"
                                                                object:nil];
            
            
            //NIKHIL BUG_147
            dispatch_async(dispatch_get_main_queue(), ^{
                [self alertForDeregister:@"Successfully deregistered" message:@""];
                
            });
            //NSLog(@"Successfully deregistered from sync");
        } else {
            //NSLog(@"Error while deregistering");
        }
    } failure:^(NSError *error) {
        
        //NSLog(@"Error while deregistering");
    }];
}

- (void)alertForDeregister: (NSString *)title message: (NSString *)message{
    //NIKHIL BUG_147
      [self.loadingView removeFromSuperview];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"OK") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"dismissAfterDeregister"
                                                            object:nil];
        //        [[NSNotificationCenter defaultCenter] postNotificationName:@"dismissSlideOut"
        //                                                            object:nil];
        [self dismissViewControllerAnimated:NO completion:^{
            
            [self viewWillDisappear:NO];
        }];
    }];
    
    //    UIAlertAction *canel = [UIAlertAction actionWithTitle:NSLocalizedString(@"no", @"No") style:UIAlertActionStyleDefault handler:nil];
    
    [alert addAction:ok];
    //[alert addAction:canel];
    [self presentViewController:alert animated:YES completion:nil];
}

//ADD DRIVER SCENE
#pragma mark All Driver Methods New_7
#pragma mark TableView Delegate Datasource Methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.friendsArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 72;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    AddDriverTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[AddDriverTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"] ;
        
    }
    
    //NIKHIL show contents of cell
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    NSDictionary *dictionary = [[NSDictionary alloc]init];
    //NSLog(@"friendsArray is ::%@",self.friendsArray);
    dictionary = [self.friendsArray objectAtIndex:indexPath.row];
   if(![[dictionary objectForKey:@"Name"] isEqual:@""] || [dictionary objectForKey:@"Name"] != nil){
       cell.nameLabel.text = [dictionary objectForKey:@"Name"];
       cell.cellImageView.hidden= YES;
       cell.requestedLabel.hidden = YES;
        //check the status again
       if([[dictionary objectForKey:@"Status"] isEqual:@"request sent"]){
     
           //cell.cellImageView.hidden= YES;
           cell.requestedLabel.hidden = NO;
           cell.requestedLabel.text = NSLocalizedString(@"requested", @"Requested");
           [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
           cell.userInteractionEnabled = false;
       }else if([[dictionary objectForKey:@"Status"] isEqual:@"request"]){
           //cell.requestedLabel.hidden = YES;
           cell.cellImageView.hidden= NO;
           cell.cellImageView.image = [UIImage imageNamed:@"ic_confirm_friend.png"];
       }else if([[dictionary objectForKey:@"Status"] isEqual:@"confirm"]){
           //cell.requestedLabel.hidden = YES;
           cell.cellImageView.hidden= NO;
           //cell.cellImageView.image = [UIImage imageNamed:@"ic_full_sync_with_friend.png"];
           cell.cellImageView.image = [UIImage imageNamed:@"transfery.png"];
       }
    }
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    AddDriverTableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    NSMutableDictionary *friend = [[NSMutableDictionary alloc]init];
    friend = [self.friendsArray objectAtIndex:indexPath.row];
   
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setObject:[friend objectForKey:@"Email"] forKey:@"friendEmail"];
    [def setObject:[friend objectForKey:@"Name"] forKey:@"friendName"];
    
    if([[friend valueForKey:@"Status"] isEqual:@"request"]){
        
//        //allowing to confirm drivers to more than 3 / 4june2018
//        NSLog(@"friends Array:- %@",self.friendsArray);
//        int drivers = 0;
//        for(NSDictionary *dict in self.friendsArray){
//
//            if([[dict objectForKey:@"Status"] isEqualToString:@"confirm"]){
//                drivers++;
//            }
//
//        }
//
//        if(drivers < 3){
        
            cell.cellImageView.image = [UIImage imageNamed:@"ic_full_sync_with_friend.png"];
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeIndeterminate;
            hud.offset = CGPointMake(0,85);
            AppDelegate *App = [AppDelegate sharedAppDelegate];
            if(App.result.height == 480) {
                hud.offset = CGPointMake(0,120);
            }
            hud.label.text = @"Confirming..";
            hud.label.textColor = [self colorFromHexString:@"#FFCA1D"];
            hud.bezelView.backgroundColor = [UIColor clearColor];
            hud.bezelView.alpha =0.6;
            
            if([self checkForNetwork]){
                [self performSelectorInBackground:@selector(confirmFriendRequest) withObject:nil];
            }
//        }else{
//
//            [self showAlert:@"Oops!" message:@"You cannot add more than three drivers yet!"];
//
//        }
        
    }else if([[friend valueForKey:@"Status"] isEqual:@"confirm"]){
        
        //Send Full Sync Request
        //Do you want to send a request to sync all your data with Mrigaen?
        NSString *alerTitle = @"Send Full Sync Request";
        NSString *message = [NSString stringWithFormat:@"Do you want to send a request to sync all your data with %@?",[def objectForKey:@"friendName"]];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alerTitle
                                                                                 message:message
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"OK")
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             // NSLog(@"For Sharing data with friend");
                                                             MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                                                             hud.mode = MBProgressHUDModeIndeterminate;
                                                             hud.offset = CGPointMake(0,85);
                                                             AppDelegate *App = [AppDelegate sharedAppDelegate];
                                                             if(App.result.height == 480) {
                                                                 hud.offset = CGPointMake(0,120);
                                                             }
                                                             hud.label.text =  @"Requesting..";
                                                             hud.label.textColor = [self colorFromHexString:@"#FFCA1D"];
                                                             hud.bezelView.backgroundColor = [UIColor clearColor];
                                                             hud.bezelView.alpha =0.6;
                                                             if([self checkForNetwork]){
                                                                 [self performSelectorInBackground:@selector(createCSVfiles) withObject:nil];
                                                             }
                                                             
                                                         }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"Cancel")
                                                               style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction * _Nonnull action) {
                                                                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                             }];
        
        [alertController addAction:cancelAction];
        [alertController addAction:okAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
        
     }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
   
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
    dictionary = [self.friendsArray objectAtIndex:indexPath.row];
    //NSLog(@"dictionary is:- %@",dictionary);
    NSString *confirmed = @"confirm";
    if([[dictionary objectForKey:@"Status"] isEqualToString:confirmed]){
        //if comfirmed friend then only allow edit
        return YES;
    }else{
        return NO;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
    dictionary = [self.friendsArray objectAtIndex:indexPath.row];
   
    
    if(editingStyle == UITableViewCellEditingStyleDelete){
        
        NSString *title = @"Delete Driver";
        NSString *prefix = @"Are you sure you want to delete ";
        NSString *message = [prefix stringByAppendingString:[dictionary objectForKey:@"Name"]];
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                                 message:message
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"delete", @"Delete")
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             
                                            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                                            hud.mode = MBProgressHUDModeIndeterminate;
                                            hud.offset = CGPointMake(0,85);
                                            AppDelegate *App = [AppDelegate sharedAppDelegate];
                                            if(App.result.height == 480) {
                                                hud.offset = CGPointMake(0,120);
                                             }
                                            hud.label.text =  @"Deleting..";
                                            hud.label.textColor = [self colorFromHexString:@"#FFCA1D"];
                                            hud.bezelView.backgroundColor = [UIColor clearColor];
                                            hud.bezelView.alpha =0.6;
                                            
                                            [self callDeleteFriendScript:dictionary];
                                                if(deletedFriend){
                                                    [self.friendsArray removeObjectAtIndex:indexPath.row];
                                                    [self.addDriverTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                                                    [tableView reloadData];
                                                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                }else{
                                                    [self showAlert:@"Deleted Failed" message:@"Could not delete Driver, please try again!"];
                                                }
                                          }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"Cancel")
                                                               style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction * _Nonnull action) {
                                                                 
                                                             }];
        
        [alertController addAction:cancelAction];
        [alertController addAction:okAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
       
    }
    
}

-(void)fetchDrivers{
    
    self.friendsArray =[[NSMutableArray alloc]init];
    
    NSManagedObjectContext *contex = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSFetchRequest *requset=[[NSFetchRequest alloc] initWithEntityName:@"Friends_Table"];
    NSError *err;
    NSArray *data=[contex executeFetchRequest:requset error:&err];
    
    for(Friends_Table *friend in data)
    {
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
        if(friend.name != nil){
            [dictionary setObject:friend.name forKey:@"Name"];
        }else{
            [dictionary setObject:@"" forKey:@"Name"];
        }
        if(friend.email != nil){
            [dictionary setObject:friend.email forKey:@"Email"];
        }else{
            [dictionary setObject:@"" forKey:@"Email"];
        }
        if(friend.status != nil){
            [dictionary setObject:friend.status forKey:@"Status"];
        }else{
            [dictionary setObject:@"" forKey:@"Status"];
        }
        if(friend.requested_by_me != nil){
            [dictionary setObject:friend.requested_by_me forKey:@"requested_by_me"];
        }else{
            [dictionary setObject:@"" forKey:@"requested_by_me"];
        }
      
        [self.friendsArray addObject:dictionary];
    }
    
    
}

//ADD DRIVER SCENE


#pragma mark Add Driver Methods New_7
- (IBAction)addDriverButtonClicked:(id)sender {
    
    //Making sync free 30may2018 nikhil
    BOOL proUser = [[NSUserDefaults standardUserDefaults] boolForKey:@"isAdDisabled"];
    if(!proUser){
        
        [self goProAlertBox];
     
    }else{
         
         //restricting drivers to 3 only
         //NSLog(@"friends Array:- %@",self.friendsArray);
         int requestedByMe = 0;
         for(NSDictionary *dict in self.friendsArray){
             
             if([[dict objectForKey:@"Status"] isEqualToString:@"confirm"] && [[dict objectForKey:@"requested_by_me"] isEqualToString:@"1"]){
                 requestedByMe++;
             }
             
         }
        //ENH_58 Nikhil 25july2018 add unlimited drivers
        if([[NSUserDefaults standardUserDefaults] boolForKey:@"isSubscribed"]){
            
            AddDriverViewController *addDriverVC = [self.storyboard instantiateViewControllerWithIdentifier:@"addDriverScreen"];
            addDriverVC.modalPresentationStyle = UIModalPresentationFullScreen;
            [self.navigationController pushViewController:addDriverVC animated:YES];
            
        }else if(requestedByMe < 3){
             
             AddDriverViewController *addDriverVC = [self.storyboard instantiateViewControllerWithIdentifier:@"addDriverScreen"];
             addDriverVC.modalPresentationStyle = UIModalPresentationFullScreen;
             [self.navigationController pushViewController:addDriverVC animated:YES];
        }else{
             //"go_pro_for_unltd_drivers"="To add unlimited drivers please upgrade to Platinum membership."
             [self showAlert:NSLocalizedString(@"go_pro_unltd_drivers_title", @"Add Unlimited Drivers") message:NSLocalizedString(@"go_pro_for_unltd_drivers", @"To add unlimited drivers please upgrade to Platinum membership.")];
             
         }
    }
    
}

//Added to ask user to GoPro 30may2018 nikhil
- (void)goProAlertBox{
    
    NSString *title = NSLocalizedString(@"sync_help1_go_pro_to_sync", @"This feature is available as a part of the Pro version");
    NSString *message = @"";
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:title
                                          message:message
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"cancel", @"Cancel action")
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       
                                   }];
    
    //NSString *go_pro_btn = @"Go Pro";
    UIAlertAction *goproAction = [UIAlertAction
                                  actionWithTitle:NSLocalizedString(@"go_pro_btn", @"Ok action")
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction *action)
                                  {
                                      GoProViewController *gopro = (GoProViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"gopro"];
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          gopro.modalPresentationStyle = UIModalPresentationFullScreen;
                                          [self presentViewController:gopro animated:YES completion:nil];
                                      });
                                  }];
    
    
    [alertController addAction:goproAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
    
}

-(void)editFriendRecord: (NSMutableDictionary *)friendDict{
    
    NSManagedObjectContext *contex = [[CoreDataController sharedInstance] backgroundManagedObjectContext];
    NSError *err;
    NSString *comparestring = [NSString stringWithFormat:@"%@",[friendDict objectForKey:@"friendEmail"]];
    
    
    NSFetchRequest *request=[[NSFetchRequest alloc] initWithEntityName:@"Friends_Table"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"email==%@",comparestring];
    [request setPredicate:predicate];
    
    NSArray *datavalue=[contex executeFetchRequest:request error:&err];
    Friends_Table *updRecord = [datavalue firstObject];
    //NSLog(@"updRecord is ::%@",updRecord);
    
    updRecord.name = [friendDict objectForKey:@"friendName"];
    updRecord.email = [friendDict objectForKey:@"friendEmail"];
    updRecord.status = [friendDict objectForKey:@"action"];
    
    //NSLog(@"status is::%@",updRecord.status);
    if ([contex hasChanges])
    {
        BOOL saved = [contex save:&err];
        if (!saved) {
            // do some real error handling
            //CLSLog(@“Could not save Data due to %@“, error);
        }
        [[CoreDataController sharedInstance] saveBackgroundContext];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [[CoreDataController sharedInstance] saveMasterContext];
    });
    
}

- (BOOL)checkForNetwork{
    
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    
    if(networkStatus == NotReachable){
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [self showAlertAndDismiss:@"Failed to Search" message:@"Please check your internet connection and try again later"];
        });
        return NO;
    } else {
        
        return YES;
        
    }
}

-(void)confirmFriendRequest{
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *parametersDictionary = [[NSMutableDictionary alloc] init];
    
    [parametersDictionary setObject:[def objectForKey:@"UserEmail"] forKey:@"email2"];
    [parametersDictionary setObject:[def objectForKey:@"UserName"] forKey:@"name2"];
    [parametersDictionary setObject:[def objectForKey:@"friendEmail"] forKey:@"email1"];
    [parametersDictionary setObject:[def objectForKey:@"friendName"] forKey:@"name1"];
    [parametersDictionary setObject:[def objectForKey:@"UserDeviceId"] forKey:@"androidId"];
    
    NSError *err;
    NSData *postDataArray = [NSJSONSerialization dataWithJSONObject:parametersDictionary options:NSJSONWritingPrettyPrinted error:&err];
    
    commonMethods *common = [[commonMethods alloc]init];
    [def setBool:NO forKey:@"updateTimeStamp"];
    [common saveToCloud:postDataArray urlString:kConfirmFriendRequestScript success:^(NSDictionary *responseDict) {
        
        //NSLog(@"ResponseDict is : %@", responseDict);
        
        if([[responseDict valueForKey:@"success"]  isEqual: @1]){
           
            NSMutableDictionary *confirmDict = [[NSMutableDictionary alloc]init];
            [confirmDict setObject:[def objectForKey:@"friendEmail"] forKey:@"friendEmail"];
            [confirmDict setObject:[def objectForKey:@"friendName"] forKey:@"friendName"];
            [confirmDict setObject:@"confirm" forKey:@"action"];
            [self editFriendRecord: confirmDict];
            //Do any additional things if needed
            [self fetchDrivers];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.addDriverTableView reloadData];
                NSString *message = [[def objectForKey:@"friendName"] stringByAppendingString:@" is confirmed as a Driver"];
                [self showAlert:@"Driver confirmed" message:message];
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
           
                
            
        }else{
           
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.addDriverTableView reloadData]; 
                [self showAlert:NSLocalizedString(@"failed",@"Failed") message:NSLocalizedString(@"failed_confirm_driver",@"Failed to confirm as driver")];
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
            
            
        }
        
    } failure:^(NSError *error) {
        
        //NSLog(@"friend request failed");
    }];
    

}

#pragma mark Delete Driver Methods New_7
-(void)callDeleteFriendScript:(NSMutableDictionary *)friendToDelete{
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setObject:[def objectForKey:@"UserName"] forKey:@"name1"];
    [dictionary setObject:[def objectForKey:@"UserEmail"] forKey:@"email1"];
    [dictionary setObject:[friendToDelete objectForKey:@"Name"] forKey:@"name2"];
    [dictionary setObject:[friendToDelete objectForKey:@"Email"] forKey:@"email2"];
    [dictionary setObject:[def objectForKey:@"UserDeviceId"] forKey:@"androidId"];
    
    NSError *err;
    
    NSData *postData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:&err];
    
    commonMethods *common = [[commonMethods alloc] init];
    [def setBool:NO forKey:@"updateTimeStamp"];
    [common saveToCloud:postData urlString:kFriendDeleteScript success:^(NSDictionary *responseDict) {
        
        if([[responseDict objectForKey:@"success"] intValue] == 1){
            
              [self deleteRecord:friendToDelete];
              deletedFriend = YES;
            
        } else {
            
            deletedFriend = NO;
            //NSLog(@"Error while deleting");
            
        }
    } failure:^(NSError *error) {
        
       // NSLog(@"Error while deleting friend");
        deletedFriend = NO;
    }];
}

-(void)deleteRecord:(NSMutableDictionary *)deleteFriend{
    
    NSManagedObjectContext *context = [[CoreDataController sharedInstance] backgroundManagedObjectContext];
    NSError *error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Friends_Table"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"email == %@",[deleteFriend objectForKey:@"Email"]];
    NSError *err;
    [fetchRequest setPredicate:predicate];
    
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    Friends_Table *friendData = [fetchedObjects firstObject];
    
    if(friendData != nil){
        
        [context deleteObject:friendData];
        //NSLog(@"deleted from friends table.. ");
    }
    
   if ([context hasChanges])
    {
        BOOL saved = [context save:&err];
        if (!saved) {
            // do some real error handling
            //CLSLog(@“Could not save Data due to %@“, error);
        }
        [[CoreDataController sharedInstance] saveBackgroundContext];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [[CoreDataController sharedInstance] saveMasterContext];
    });
    
}

#pragma mark creating .csv files New_7 

-(void)createCSVfiles{
    
    [self prepareVehicleFile];
    if(vehicleFound){
        
         [self prepareFillUpsFile];
         [self prepareServiceFile];
         [self prepareTripFile];
         [self addToZipFile];
        
        
        //create zip file here
        
    }else{
        
        [self showAlert:@"No Vehicle Found" message:@"You should have atleast one vehicle to continue"];
        
    }
  
}

////Create Vehicle CSV
-(void)prepareVehicleFile
{
    NSString* str= [self exportvehCSV];
    NSString *noVehicle = @"noVehicle";
    if(str != noVehicle){
         NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    
         NSString *filePath = [documentsPath stringByAppendingPathComponent:@"Vehicles.csv"];
         BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
         NSError *error;
    
         if (fileExists)    //Does file exist?
         {
             if (![[NSFileManager defaultManager] removeItemAtPath:filePath error:&error])   //Delete it
             {
                 //NSLog(@"Delete file error: %@", error);
             }
         }
        
        vehicleFound = YES;
        [str writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:NULL];
    
    }else{
        
        vehicleFound = NO;
    }
}

- (NSString *)exportvehCSV
{
    
    NSMutableArray *results = [[NSMutableArray alloc] init];
    NSManagedObjectContext *contex = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSFetchRequest *requset1=[[NSFetchRequest alloc] initWithEntityName:@"Veh_Table"];
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"iD"
                                                                    ascending:YES];
    NSError *err1;
    NSArray *sortDescriptors1 = [[NSArray alloc] initWithObjects:sortDescriptor1, nil];
    [requset1 setSortDescriptors:sortDescriptors1];
    
    NSArray *vehicle=[contex executeFetchRequest:requset1 error:&err1];
    NSString *noVehicle = @"noVehicle";
    if(vehicle != nil){
    
        NSString *firstrow = @"Row ID,Make,Model,Fuel Type,Year,Lic#,Vin,Insurance#,Notes,Picture Path,Vehicle ID,Other Specs";
        [results addObject:firstrow];
        int vehid =0;
        for(Veh_Table *veh in vehicle)
        {
            vehid++;
            //NSString *picture = @"";
            //NSString *vehicleid = [NSString stringWithFormat:@"%@ %@",veh.make,veh.model];
            //NSLog(@"vehid id......%@.....",veh.vehid);
            //Swapnil ENH_30
            [results addObject:[NSString stringWithFormat:@"%d,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@",vehid,veh.make,veh.model,veh.fuel_type,veh.year,veh.lic,veh.vin,veh.insuranceNo,veh.notes,veh.picture,veh.vehid,veh.customSpecs]];
        }
    
       // NSLog(@"firstRow = %@", results);
    
        NSString *resultString = [results componentsJoinedByString:@"\n"];
        resultString =  [resultString stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
        //NSLog(@"result value %@",vehid)
        return resultString;
    }else{
        return noVehicle;
    }
    
}


//Create Fuel_Log CSV
-(void) prepareFillUpsFile
{
    NSString* str= [self exportfillupCSV];

    //Swapnil ENH_24
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"Fuel_Log.csv"];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    NSError *error;
    
    if (fileExists)    //Does file exist?
    {
        if (![[NSFileManager defaultManager] removeItemAtPath:filePath error:&error])   //Delete it
        {
            //NSLog(@"Delete file error: %@", error);
        }
    }
    
    [str writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:NULL];
    
    
}

//Get fillup data csv
- (NSString *)exportfillupCSV
{
    NSMutableArray *results = [[NSMutableArray alloc] init];
    NSManagedObjectContext *contex = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSError *err;
    NSFetchRequest *requset=[[NSFetchRequest alloc] initWithEntityName:@"T_Fuelcons"];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"odo"
                                                                   ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [requset setSortDescriptors:sortDescriptors];
    
    NSArray *fuel=[contex executeFetchRequest:requset error:&err];
    
    NSFetchRequest *requset1=[[NSFetchRequest alloc] initWithEntityName:@"Veh_Table"];
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"iD"
                                                                    ascending:YES];
    NSError *err1;
    NSArray *sortDescriptors1 = [[NSArray alloc] initWithObjects:sortDescriptor1, nil];
    [requset1 setSortDescriptors:sortDescriptors1];
    
    NSArray *vehicle=[contex executeFetchRequest:requset1 error:&err1];
    
    ////Row ID 0,Vehicle ID 1,Odometer 2,Qty 3,Partial Tank 4,Missed Fill Up 5,Total Cost 6,Distance Travelled 7,Eff 8,Octane 9,Fuel Brand 10,Filling Station 11,Notes 12,Day 13,Month 14,Year 15,Receipt Path 16,Latitude 17,Longitude 18,Record Type 19,Record Desc 20
    
    NSString *firstrow = @"Row ID (For System Use),Vehicle ID,Odometer,Qty,Partial Tank,Missed Previous Fill up,Total Cost,Distance Travelled,Eff,Octane,Fuel Brand,Filling Station,Notes,Day,Month,Year,Receipt Path,Latitude,Longitude,Record Type,Record Desc";
    [results addObject:firstrow];
    NSDateFormatter *formater=[[NSDateFormatter alloc] init];
    [formater setDateFormat:@"dd/MM/yyyy"];
    
    //fuelid = 0;
    for (T_Fuelcons * fuelrecord in fuel) {
        
        NSString *vehid = fuelrecord.vehid;
        [formater setDateFormat:@"dd"];
        NSString *day = [formater stringFromDate:fuelrecord.stringDate];
        [formater setDateFormat:@"MM"];
        NSString *month = [formater stringFromDate:fuelrecord.stringDate];
        
        [formater setDateFormat:@"yyyy"];
        NSString *year = [formater stringFromDate:fuelrecord.stringDate];
        for(Veh_Table *veh in vehicle)
        {
            if([[veh.iD stringValue] isEqualToString:vehid])
            {
                vehid = veh.vehid;
                break;
            }
        }
        fuelrecord.receipt = nil;
        //fuelid = fuelid +1;
        NSArray *array1 = [[[NSUserDefaults standardUserDefaults]objectForKey:@"con_unit"] componentsSeparatedByString:@" "];
        NSString *string1 = [array1 firstObject];
        NSString *eff;
        if ([string1 containsString:@"100"])
        {
            eff = [NSString stringWithFormat:@"%.2f",100/[fuelrecord.cons floatValue]];
        }
        else
        {
            eff =[NSString stringWithFormat:@"%.2f",[fuelrecord.cons floatValue]];
        }
        
        [results addObject:[NSString stringWithFormat:@"%d,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@",[fuelrecord.iD intValue], vehid, fuelrecord.odo, fuelrecord.qty,[fuelrecord.pfill stringValue],[fuelrecord.mfill stringValue],[fuelrecord.cost stringValue],[fuelrecord.dist stringValue],fuelrecord.cons,[fuelrecord.octane stringValue],fuelrecord.fuelBrand,fuelrecord.fillStation,fuelrecord.notes,day,month,year,fuelrecord.receipt,fuelrecord.latitude,fuelrecord.longitude,[fuelrecord.type stringValue],fuelrecord.serviceType]];
    }

    NSString *resultString = [results componentsJoinedByString:@"\n"];
    resultString =  [resultString stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
    //NSLog(@"result for Both Logs %@",resultString);
    return resultString;
}

//Create Service CSV
-(void) prepareServiceFile
{
    NSString* str= [self exportserviceCSV];
    
    // Writing
    
    //Swapnil ENH_24
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"Services.csv"];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    NSError *error;
    
    if (fileExists)    //Does file exist?
    {
        if (![[NSFileManager defaultManager] removeItemAtPath:filePath error:&error])   //Delete it
        {
            //NSLog(@"Delete file error: %@", error);
        }
    }
    
    [str writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:NULL];
    
    
    
}


//Get service data for csv
-(NSString *) exportserviceCSV
{
    NSMutableArray *results = [[NSMutableArray alloc] init];
    NSManagedObjectContext *contex = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSError *err;
    
    NSFetchRequest *requset=[[NSFetchRequest alloc] initWithEntityName:@"Services_Table"];
    
    //BUG_48
    // NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type==1 OR type==2"];
    // [requset setPredicate:predicate];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"iD"
                                                                   ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [requset setSortDescriptors:sortDescriptors];
    
    
    NSArray *servicearray=[contex executeFetchRequest:requset error:&err];
    
    
    NSFetchRequest *requset1=[[NSFetchRequest alloc] initWithEntityName:@"Veh_Table"];
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"iD"
                                                                    ascending:YES];
    NSError *err1;
    NSArray *sortDescriptors1 = [[NSArray alloc] initWithObjects:sortDescriptor1, nil];
    [requset1 setSortDescriptors:sortDescriptors1];
    
    NSArray *vehicle=[contex executeFetchRequest:requset1 error:&err1];
    NSString *firstrow = @"Row ID,Vehicle ID,Record Type,Service Name,Recurring,Due Miles,Due Days,Last Odo,Last Date";
    [results addObject:firstrow];
    NSDateFormatter *formater=[[NSDateFormatter alloc] init];
    [formater setDateFormat:@"dd/MM/yyyy"];
    
    //Swapnil NEW_6
    //int serviceid=0;
    
    for (Services_Table *service in servicearray)
    {
        
        NSString *vehid = service.vehid;
        //NSLog(@"vehicle id in service....%@....",vehid);
        
        for(Veh_Table *veh in vehicle)
        {
            //NSLog(@"vehicle id in vehicle...%@....",[veh.iD stringValue]);
            if([[veh.iD stringValue] isEqualToString:vehid])
            {
                vehid = veh.vehid;
                break;
            }
        }
        
        //Swapnil NEW_6
        //serviceid = serviceid +1;
        
        NSString *lastdate = [formater stringFromDate:service.lastDate];
        // NSLog(@"lastdate is %@", lastdate);
        
        
        NSTimeInterval unixTimeStamp = 0;
        
        if (!(lastdate == nil || [lastdate isEqualToString:@"01/01/1970"]))
        {
            
            NSDate *date = [formater dateFromString:lastdate];
            unixTimeStamp = [date timeIntervalSince1970] * 1000;
            
        }
        //  NSLog(@"timestamp is %f", unixTimeStamp);
        
        [results addObject:[NSString stringWithFormat:@"%d,%@,%@,%@,%@,%@,%@,%@,%f",[service.iD intValue],vehid,service.type,service.serviceName,service.recurring,service.dueMiles,service.dueDays,service.lastOdo,unixTimeStamp]];
    }
    
    NSString *resultString = [results componentsJoinedByString:@"\n"];
    //   NSLog(@"resultString is : %@", resultString);
    resultString =  [resultString stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
    //NSLog(@"result for service %@",resultString);
    return resultString;
}

//Create Trip CSV
-(void) prepareTripFile
{
    NSString* str= [self exportTripCSV];
    
    // Writing
    
    //Swapnil ENH_24
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"Trip_Log.csv"];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    NSError *error;
    
    if (fileExists)    //Does file exist?
    {
        if (![[NSFileManager defaultManager] removeItemAtPath:filePath error:&error])   //Delete it
        {
            // NSLog(@"Delete file error: %@", error);
        }
    }
    
    [str writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:NULL];
    
}

//Get Trip data for csv
-(NSString *) exportTripCSV
{
    NSMutableArray *results = [[NSMutableArray alloc] init];
    NSManagedObjectContext *contex = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSError *err;
    
    NSFetchRequest *requset=[[NSFetchRequest alloc] initWithEntityName:@"T_Trip"];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"iD"
                                                                   ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [requset setSortDescriptors:sortDescriptors];
    
    
    
    NSArray *tripArray=[contex executeFetchRequest:requset error:&err];
    
    
    NSFetchRequest *requset1=[[NSFetchRequest alloc] initWithEntityName:@"Veh_Table"];
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"iD"
                                                                    ascending:YES];
    NSError *err1;
    NSArray *sortDescriptors1 = [[NSArray alloc] initWithObjects:sortDescriptor1, nil];
    [requset1 setSortDescriptors:sortDescriptors1];
    
    NSArray *vehicle=[contex executeFetchRequest:requset1 error:&err1];
    NSString *firstrow = @"Row ID,Vehicle ID,Departure Odo,Arrival Odo,Departure Loc,Arrival Loc,Departure Day,Departure Month,Departure Year,Departure Hour,Departure Min,Arrival Day, Arrival Month, Arrival Year, Arrival Hour, Arrival Min, Parking,Toll,Tax Ded,Notes,Departure Latitude,Departure Longitude,Arrival Latitiude,Arrival Longitude,Trip Type"; //21-25
  
    [results addObject:firstrow];
    NSDateFormatter *formater=[[NSDateFormatter alloc] init];
    [formater setDateFormat:@"dd/MM/yyyy"];
    //int tripId=0;
    for (T_Trip *tripRec in tripArray)
    {
        
        NSString *vehid = tripRec.vehId;
        //NSLog(@"vehicle id in service....%@....",vehid);
        
        for(Veh_Table *veh in vehicle)
        {
            //NSLog(@"vehicle id in vehicle...%@....",[veh.iD stringValue]);
            if([[veh.iD stringValue] isEqualToString:vehid])
            {
                vehid = veh.vehid;
                break;
            }
        }
        
        //NSString *lastdate = [formater stringFromDate:tripRec.depDate];
        
        NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSInteger depDay = [gregorianCalendar component:NSCalendarUnitDay fromDate:tripRec.depDate];
        NSInteger depMonth = [gregorianCalendar component:NSCalendarUnitMonth fromDate:tripRec.depDate];
        NSInteger depYear = [gregorianCalendar component:NSCalendarUnitYear fromDate:tripRec.depDate];
        NSInteger depHour = [gregorianCalendar component:NSCalendarUnitHour fromDate:tripRec.depDate];
        NSInteger depMin = [gregorianCalendar component:NSCalendarUnitMinute fromDate:tripRec.depDate];
        //   NSInteger depSec = [gregorianCalendar component:NSCalendarUnitSecond fromDate:tripRec.depDate];
        
        NSInteger arrDay = [gregorianCalendar component:NSCalendarUnitDay fromDate:tripRec.arrDate];
        NSInteger arrMonth = [gregorianCalendar component:NSCalendarUnitMonth fromDate:tripRec.arrDate];
        NSInteger arrYear = [gregorianCalendar component:NSCalendarUnitYear fromDate:tripRec.arrDate];
        NSInteger arrHour = [gregorianCalendar component:NSCalendarUnitHour fromDate:tripRec.arrDate];
        NSInteger arrMin = [gregorianCalendar component:NSCalendarUnitMinute fromDate:tripRec.arrDate];
        
        //NSString *firstrow = @"Row ID,Vehicle ID,Departure Odo,Arrival Odo,Departure Loc,Arrival Loc,Departure Day,Departure Month,Departure Year,Departure Hour,Departure Min,Arrival Day, Arrival Month, Arrival Year, Arrival Hour, Arrival Min, Parking,Toll,Tax Ded,Notes,Departure Latitude,Departure Longitude,Arrival Latitiude,Arrival Longitude,Trip Type"; //21-25
        
        [results addObject:[NSString stringWithFormat:@"%d,%@,%f,%f,%@,%@,%ld,%ld,%ld,%ld,%ld,%ld,%ld,%ld,%ld,%ld,%@,%@,%@,%@,%@,%@,%@,%@,%@",[tripRec.iD intValue],vehid,[tripRec.depOdo floatValue],[tripRec.arrOdo floatValue],tripRec.depLocn, tripRec.arrLocn,(long)depDay,(long)depMonth,(long)depYear,(long)depHour,(long)depMin,(long)arrDay,(long)arrMonth,(long)arrYear,(long)arrHour,(long)arrMin,tripRec.parkingAmt,tripRec.tollAmt,tripRec.taxDedn, tripRec.notes,tripRec.depLatitude,tripRec.depLongitude,tripRec.arrLatitude,tripRec.arrLongitude, tripRec.tripType ]];
    }
    
    NSString *resultString = [results componentsJoinedByString:@"\n"];
    // NSLog(@"resultString is : %@", resultString);
    resultString =  [resultString stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
    //NSLog(@"result for Trip %@",resultString);
    return resultString;
}


-(void)addToZipFile{
    
    //Creating name for zip file
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSString *userEmail = [def objectForKey:@"UserEmail"];
    //NSLog(@"userEmail :-%@",userEmail);
    
    userEmail = [[userEmail stringByReplacingOccurrencesOfString:@"@" withString:@"at"] stringByReplacingOccurrencesOfString:@"." withString:@"dot"];
    //NSLog(@"userEmail :-%@",userEmail);
    
    
    //Creating a zip file
    //Zip
    
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    
    NSString *vehFilePath = [documentsPath stringByAppendingPathComponent:@"Vehicles.csv"];
    NSString *fuelFilePath = [documentsPath stringByAppendingPathComponent:@"Fuel_Log.csv"];
    NSString *serFilePath = [documentsPath stringByAppendingPathComponent:@"Services.csv"];
    NSString *tripFilePath = [documentsPath stringByAppendingPathComponent:@"Trip_Log.csv"];
    
    //Adding files to zip file
    NSArray *filePaths = [[NSArray alloc]initWithObjects:vehFilePath,fuelFilePath,serFilePath,tripFilePath, nil];
    NSString *zipPath = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.zip",userEmail]];
   // [SSZipArchive createZipFileAtPath:zipPath
     //                        withContentsOfDirectory:filePath];
    [SSZipArchive createZipFileAtPath:zipPath withFilesAtPaths:filePaths];
    
    NSError *error;
    [[NSFileManager defaultManager] removeItemAtPath:vehFilePath error:&error];
    [[NSFileManager defaultManager] removeItemAtPath:fuelFilePath error:&error];
    [[NSFileManager defaultManager] removeItemAtPath:serFilePath error:&error];
    [[NSFileManager defaultManager] removeItemAtPath:tripFilePath error:&error];

    
    //Call full sync script
    NSMutableDictionary *parametersDictionary = [[NSMutableDictionary alloc] init];
    [parametersDictionary setObject:[def objectForKey:@"UserName"] forKey:@"name"];
    [parametersDictionary setObject:[def objectForKey:@"friendEmail"] forKey:@"friend_email"];
  
   
    NSString *boundary = [self generateBoundaryString];
    
    // configure the request
    NSURL *url = [NSURL URLWithString:kFullSyncRequestScript];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"POST"];
    
    // set content type
    
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    NSString *fieldName = @"zip_file";

    // create body
    
    NSData *httpBody = [self createBodyWithBoundary:boundary parameters:parametersDictionary paths:@[zipPath] fieldName:fieldName];
    
    //call session
    NSURLSession *session = [NSURLSession sharedSession];  // use sharedSession or create your own
    
    NSURLSessionTask *task = [session uploadTaskWithRequest:request fromData:httpBody completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"error = %@", error);
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(),^{
            NSError *error;
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [[NSFileManager defaultManager] removeItemAtPath:zipPath error:&error];
        });
    }];
    [task resume];
    
    
}

- (NSData *)createBodyWithBoundary:(NSString *)boundary
                        parameters:(NSDictionary *)parameters
                             paths:(NSArray *)paths
                         fieldName:(NSString *)fieldName {
    NSMutableData *httpBody = [NSMutableData data];
    
    // add params (all params are strings)
    
    [parameters enumerateKeysAndObjectsUsingBlock:^(NSString *parameterKey, NSString *parameterValue, BOOL *stop) {
        [httpBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", parameterKey] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"%@\r\n", parameterValue] dataUsingEncoding:NSUTF8StringEncoding]];
    }];
    
    // add zip data
    
    for (NSString *path in paths) {
        NSString *filename  = [path lastPathComponent];
        NSData   *data      = [NSData dataWithContentsOfFile:path];
        NSString *mimetype  = [self mimeTypeForPath:path];
        
        [httpBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", fieldName, filename] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", mimetype] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:data];
        [httpBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    
    [httpBody appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    return httpBody;
}

- (NSString *)mimeTypeForPath:(NSString *)path {
    // get a mime type for an extension using MobileCoreServices.framework
    
    CFStringRef extension = (__bridge CFStringRef)[path pathExtension];
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, extension, NULL);
    assert(UTI != NULL);
    
    NSString *mimetype = CFBridgingRelease(UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType));
    assert(mimetype != NULL);
    
    CFRelease(UTI);
    
    return mimetype;
}

- (NSString *)generateBoundaryString {
    return [NSString stringWithFormat:@"Boundary-%@", [[NSUUID UUID] UUIDString]];
}

@end
