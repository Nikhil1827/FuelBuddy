//
//  MainScreenViewController.m
//  FuelBuddy
//
//  Created by Nikhil on 17/09/18.
//  Copyright © 2018 Oraganization. All rights reserved.
//

#import "MainScreenViewController.h"
#import "AppDelegate.h"
#import "T_Fuelcons.h"
#import "T_Trip.h"
#import "Veh_Table.h"
#import "Services_Table.h"
#import "GoProViewController.h"
#import "commonMethods.h"
#import "WebServiceURL's.h"
#import "MBProgressHUD.h"
#import "LogViewController.h"
#import "ReportViewController.h"
#import "ReminderViewController.h"
#import "logMainTableViewCell.h"
#import "AddFillupViewController.h"
#import "ServiceViewController.h"
#import "AddExpenseViewController.h"
#import "AddTripViewController.h"
#import <Crashlytics/Crashlytics.h>
#import "AutoTripLoggingViewController.h"
#import "DashBoardViewController.h"
#import "PageViewController.h"
#import "PageHolderViewController.h"

@import Charts;

#define SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)


@interface MainScreenViewController (){
    
    UIScrollView *scrollview;
    NSMutableArray *allValuesArray, *fillUpArray, *serviceArray, *expenseArray, *tripArray;
    NSMutableArray *last30TripArray, *last30FillUpArray ,*last30ServiceArray, *last30ExpenseArray;
    double inCircleValue1, inCircleValue2, inCircleValue3;
    NSString *circleColor1, *circleColor2, *circleColor3;
    NSString *underlineLabelValue1, *underlineLabelValue2, *underlineLabelValue3;
    NSString *chartUnderLabel;
    LineChartView *chartView;
    //for Chart
    UIView *circleSection, *reminderSection;
    UIView *logSection;
    NSMutableArray *xDataPoints;
    NSMutableArray *yGraphValues;
    BOOL hideGraph;
    //reminders
    NSMutableArray *reminderKeys;
    NSMutableArray *reminderPercentages;
    NSMutableArray *reminderValues;
    NSMutableArray *avgfuelstat;
}
@property (nonatomic, strong) GADInterstitial *interstitial;
@property int selPickerRow;

@end

@implementation MainScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //showThreeLanguageChangeAlertOnce used same key to determine old user or new user

    NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
    //NSLog(@"%@",language);

    if(![[NSUserDefaults standardUserDefaults]boolForKey:@"showThreeLanguageChangeAlertOnce"] && allValuesArray.count>0){

        if([language containsString:@"es"]){

            NSString *title = @"Spanish Language Added";
            NSString *message = @"Thanks a lot for using Simply Auto. With this release we have added the Spanish language. Since your phone default is set to Spanish, you will see the app in Spanish. However, since you have been using the app since before this update, you might see some labels and fields that are missing. We request you to take a backup of your data by going to More > Google Drive Backup > Backup Then reinstalling the app, and then restoring your data from Google Drive.\nIf you have any questions, please contact us at support-ios@simplyauto.app.";
            [self showLanguageChangeAlertOnce:title:message];

        }else if([language containsString:@"fr"]){

            NSString *title = @"French Language Added";
            NSString *message = @"Thanks a lot for using Simply Auto. With this release we have added the French language. Since your phone default is set to French, you will see the app in French. However, since you have been using the app since before this update, you might see some labels and fields that are missing. We request you to take a backup of your data by going to More > Google Drive Backup > Backup Then reinstalling the app, and then restoring your data from Google Drive.\nIf you have any questions, please contact us at support-ios@simplyauto.app.";
            [self showLanguageChangeAlertOnce:title:message];

        }else if([language containsString:@"th"]){

            NSString *title = @"Thai Language Added";
            NSString *message = @"Thanks a lot for using Simply Auto. With this release we have added the Thai language. Since your phone default is set to Thai, you will see the app in Thai. However, since you have been using the app since before this update, you might see some labels and fields that are missing. We request you to take a backup of your data by going to More > Google Drive Backup > Backup Then reinstalling the app, and then restoring your data from Google Drive.\nIf you have any questions, please contact us at support-ios@simplyauto.app.";
            [self showLanguageChangeAlertOnce:title:message];

        }

    }

    if(![[NSUserDefaults standardUserDefaults]boolForKey:@"showThreeLanguageChangeAlertOnce"]){

        if([language containsString:@"en"]){

            PageHolderViewController *pageVC = (PageHolderViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"pageHolder"];
            pageVC.modalPresentationStyle = UIModalPresentationFullScreen;
            [self presentViewController:pageVC animated:YES completion:nil];

        }

    }

    [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"showThreeLanguageChangeAlertOnce"];

    self.interstitial = [self createAndLoadInterstitial];
    [self.tabBarController.tabBar setHidden:NO];
    AppDelegate* App = [AppDelegate sharedAppDelegate];
    App.tabbutton.hidden=NO;
    
    self.navigationController.navigationBar.barTintColor = [self colorFromHexString:@"#0098AB"];
    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"odovalue"];
    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"odofilter"];
    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"datevalue"];
    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"datefilter"];
    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"notefilter"];
    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"recordfilter"];
    self.navigationController.navigationBar.tintColor =[UIColor whiteColor];
    self.navigationController.navigationBar.tintColor =[UIColor whiteColor];
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.topItem.title= NSLocalizedString(@"Tab3Title", @"Dashboard");
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor] , NSFontAttributeName: [UIFont fontWithName:@"Helvetica-Light" size:18.0] }];
    self.view.backgroundColor = [self colorFromHexString:@"#2c2c2c"];
    
    self.vehImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.vehImageView.layer.borderWidth=0;
    self.vehImageView.layer.masksToBounds=YES;
    self.vehImageView.layer.cornerRadius = 21;
    
    
    self.vehNameLabel.text = [[NSUserDefaults standardUserDefaults]objectForKey:@"vehname"];
    if([[[NSUserDefaults standardUserDefaults]objectForKey:@"vehimage"]isEqualToString:@""])
    {
        self.vehImageView.image=[UIImage imageNamed:@"car4.jpg"];
    }
    
    else
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);

        NSString *urlstring = [paths firstObject];
        
        NSString *vehiclepic = [NSString stringWithFormat:@"%@/%@",urlstring,[[NSUserDefaults standardUserDefaults]objectForKey:@"vehimage"]];
        self.vehImageView.image =[UIImage imageWithContentsOfFile:vehiclepic];
    }
    
    self.detailsarray = [[NSMutableArray alloc] init];
    
    hideGraph = YES;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mainScreenRefreshData)
                                                 name:@"mainScreenRefreshData"
                                               object:nil];



   
}

- (GADInterstitial *)createAndLoadInterstitial{
    GADInterstitial *interstitial = [[GADInterstitial alloc] initWithAdUnitID:@"ca-app-pub-6674448976750697/6378475565"];
    interstitial.delegate = self;
    GADRequest *request = [GADRequest request];
    //request.testDevices = @[ @"976c958e3be08538281507a8eaeeda70" ];
    [interstitial loadRequest:request];
    return interstitial;
}

- (void)interstitialDidDismissScreen:(GADInterstitial *)interstitial {
    self.interstitial = [self createAndLoadInterstitial];
}

-(void)viewWillAppear:(BOOL)animated{
    
    self.vehNameLabel.text = [[NSUserDefaults standardUserDefaults]objectForKey:@"vehname"];
    if([[[NSUserDefaults standardUserDefaults]objectForKey:@"vehimage"]isEqualToString:@""])
    {
        self.vehImageView.image=[UIImage imageNamed:@"car4.jpg"];
    }
    
    else
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  
        NSString *urlstring = [paths firstObject];
        
        NSString *vehiclepic = [NSString stringWithFormat:@"%@/%@",urlstring,[[NSUserDefaults standardUserDefaults]objectForKey:@"vehimage"]];
        self.vehImageView.image =[UIImage imageWithContentsOfFile:vehiclepic];
    }
    
    circleColor1 = [[NSString alloc]init];
    circleColor2 = [[NSString alloc]init];
    circleColor3 = [[NSString alloc]init];
    circleColor1 = circleColor2 = circleColor3 = @"GreenColor";
    underlineLabelValue1 = [[NSString alloc]init];
    underlineLabelValue1 = NSLocalizedString(@"tax_deductions", @"Tax deductions");
    
    NSArray *array = [[[NSUserDefaults standardUserDefaults]objectForKey:@"curr_unit"] componentsSeparatedByString:@"-"];
    NSString *string = [array lastObject];
    self.curr = string;
    
    NSArray *array1 = [[[NSUserDefaults standardUserDefaults]objectForKey:@"con_unit"] componentsSeparatedByString:@" "];
    NSString *string1 = [array1 firstObject];
    self.con = string1;
    
    underlineLabelValue2 = [[NSString alloc]init];
    underlineLabelValue2 = [NSString stringWithFormat:@"Average\n%@",self.con];
    
    underlineLabelValue3 = [[NSString alloc]init];
    underlineLabelValue3 = NSLocalizedString(@"upcomings_dashboard", @"Upcoming reminders");
    
    self.detailsarray = [[NSMutableArray alloc] init];
    
    [self fetchdata];
    [self fetchAllValues];
    [self addScrollView];
    

}

- (void)showLanguageChangeAlertOnce:(NSString*)title :(NSString*)message  {
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:title
                                          message:message
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"ok", @"OK action")
                               style:UIAlertActionStyleDefault
                               handler:nil];
    
    
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
    
}

-(void)viewDidAppear:(BOOL)animated{

    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    
    if([[[NSUserDefaults standardUserDefaults]objectForKey:@"dist_unit"] isEqualToString:NSLocalizedString(@"disp_miles", @"Miles")])
    {
        self.dist = NSLocalizedString(@"mi", @"mi");
    }
    
    else
    {
        self.dist = NSLocalizedString(@"kms", @"km");
    }

    if([[[NSUserDefaults standardUserDefaults]objectForKey:@"vol_unit"] isEqualToString:NSLocalizedString(@"disp_kilowatt_hour", @"Kilowatt-Hour")]){

        self.vol = NSLocalizedString(@"kwh", @"kWh");

    } else if([[[NSUserDefaults standardUserDefaults]objectForKey:@"vol_unit"] isEqualToString:NSLocalizedString(@"disp_litre", @"Litre")])
    {
        self.vol = NSLocalizedString(@"ltr", @"Ltr");
        
    }
    
    else
    {
        self.vol = NSLocalizedString(@"gal", @"gal");
    }
    
    NSArray *array = [[[NSUserDefaults standardUserDefaults]objectForKey:@"curr_unit"] componentsSeparatedByString:@"-"];
    NSString *string = [array lastObject];
    self.curr = string;
    
    
    NSArray *array1 = [[[NSUserDefaults standardUserDefaults]objectForKey:@"con_unit"] componentsSeparatedByString:@" "];
    NSString *string1 = [array1 firstObject];
    self.con = string1;
    
    [self.logTableView reloadData];
    
    [self.tabBarController.tabBar setHidden:NO];
    AppDelegate *App = [AppDelegate sharedAppDelegate];
    App.tabbutton.hidden=NO;
    
  //  NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSDate *today = [[NSDate alloc] init];
    
    //Nikhil 04-Oct-2018
    //Ads
    
    BOOL proUser = [[NSUserDefaults standardUserDefaults] boolForKey:@"isAdDisabled"];
    
    if(!proUser){
        NSInteger gadCount = [def integerForKey:@"adCount"];
        if(gadCount >= 3 && [def objectForKey:@"firstTimeAd"] == nil){
            
            if(self.interstitial.isReady){
                [self.interstitial presentFromRootViewController:self];
            }
            gadCount = 0;
            [[NSUserDefaults standardUserDefaults] setInteger:gadCount forKey:@"adCount"];
            
            NSDateComponents *dateComponent = [[NSDateComponents alloc] init];
            [dateComponent setDay:3];
            NSDate *dateAfter3 = [[NSCalendar currentCalendar]
                                  dateByAddingComponents:dateComponent
                                  toDate:today options:0];
            [def setObject:dateAfter3 forKey:@"threeDayCount"];
            [def setObject:@"1" forKey:@"firstTimeAd"];
            
        } else if (gadCount >= 2 && [today timeIntervalSinceDate:[def objectForKey:@"threeDayCount"]] >= 3){
            
            if(self.interstitial.isReady){
                [self.interstitial presentFromRootViewController:self];
            }
            gadCount = 0;
            [[NSUserDefaults standardUserDefaults] setInteger:gadCount forKey:@"adCount"];
            NSDateComponents *dateComponent = [[NSDateComponents alloc] init];
            [dateComponent setDay:3];
            NSDate *dateAfter3 = [[NSCalendar currentCalendar]
                                  dateByAddingComponents:dateComponent
                                  toDate:today options:0];
            [def setObject:dateAfter3 forKey:@"threeDayCount"];
        }
    }
    
    if(![def boolForKey:@"showAutoOnce"] && tripArray.count > 0 && ![def boolForKey:@"autoTripSwitchOn"]){
        
        [self showAutoLogAlertOnce];
        [def setBool:YES forKey:@"showAutoOnce"];
        
    }else if([def integerForKey:@"appopenstatus"]>=5 && ![[[def objectForKey:@"rateappclick"]lowercaseString] isEqualToString:[NSLocalizedString(@"button_never", @"Never") lowercaseString]] && ![[[def objectForKey:@"rateappclick"]lowercaseString] isEqualToString:[NSLocalizedString(@"button_later", @"Later") lowercaseString]] && ![[[def objectForKey:@"rateappclick"]lowercaseString] isEqualToString:[NSLocalizedString(@"button_rate_app", @"Rate App") lowercaseString]]){
        
        [self ratealert];
        
    }else if ([def integerForKey:@"appopenstatus"]>=3 && [[[def objectForKey:@"rateappclick"]lowercaseString] isEqualToString:[NSLocalizedString(@"button_later", @"Later") lowercaseString]] && [today timeIntervalSinceDate:[def objectForKey:@"tenDayCount"]] >= 10){
        [self ratealert];
    
    }

    //To show receipt go pro pop up
    //Not PRo //signed in //more than 3 logs //has receipt in current fillup
    //BOOL proUser = [[NSUserDefaults standardUserDefaults] boolForKey:@"isAdDisabled"];
    NSString *userEmail = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserEmail"];

    bool cameFromAddFillUp = [def boolForKey:@"receiptPresent"];

    if(cameFromAddFillUp){

        //NSLog(@"Fillups:-%@",fillUpArray);
        if(!proUser){

            if(userEmail != nil && userEmail.length > 0){

                if(fillUpArray.count>2){

                    NSString *receiptString = [[fillUpArray firstObject] objectForKey:@"receipt"];
                    if(receiptString.length>0){

                        [self showReceiptGoProAlert];
                    }
                }
            }

        }
        [def setBool:NO forKey:@"receiptPresent"];
    }

    //Yes it is req over here
    commonMethods *common = [[commonMethods alloc] init];
    NSNumber *maxNumber = [common getMaxFuelID];

    if(maxNumber && ![maxNumber isEqualToNumber:@0]){

        [def setObject:maxNumber forKey:@"maxFuelID"];
    }

}

- (void)mainScreenRefreshData{

    [self viewDidLoad];
    [self viewWillAppear:YES];
    [self viewDidAppear:YES];

}

- (void)showReceiptGoProAlert{

    //TODO localization
    NSString *title = @"Upgrade to Backup Receipts";//NSLocalizedString(@"upgrade_to_backup_title", @"Upgrade to Backup Receipts");
    NSString *message = @"Your receipt images are not being backed up on cloud.\n\nPlease upgrade to backup your receipts on cloud.";//NSLocalizedString(@"upgrade_to_backup_msg", @"Your receipt images are not being backed up on cloud.\n\nPlease upgrade to backup your receipts on cloud.");

    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:title
                                          message:message
                                          preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"Cancel") style:UIAlertActionStyleDefault handler:nil];

    UIAlertAction *okAction = [UIAlertAction
                                     actionWithTitle:@"Go Pro"//NSLocalizedString(@"ok", @"OK")
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction *action)
                                     {

                                         GoProViewController *gopro = (GoProViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"gopro"];
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             gopro.modalPresentationStyle = UIModalPresentationFullScreen;
                                             [self presentViewController:gopro animated:YES completion:nil];
                                         });
                                     }];

    [alertController addAction:cancelAction];
    [alertController addAction:okAction];


    [self presentViewController:alertController animated:YES completion:nil];


}

- (void)showAutoLogAlertOnce{
    
    
    NSString *title = NSLocalizedString(@"auto_drive_detect_menu", @"Auto Trip Logging");
    NSString *message = NSLocalizedString(@"auto_drive_dialog_msg", @"Would you like Simply Auto to automatically log your trips so that you do not have to enter trips manually?");
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:title
                                          message:message
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"Cancel") style:UIAlertActionStyleDefault handler:nil];
    
    UIAlertAction *autoTripAction = [UIAlertAction
                                  actionWithTitle:NSLocalizedString(@"ok", @"OK")
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction *action)
                                  {
                                      AutoTripLoggingViewController *gopro = (AutoTripLoggingViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"autoTrip"];
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          gopro.modalPresentationStyle = UIModalPresentationFullScreen;
                                          [self presentViewController:gopro animated:YES completion:nil];
                                      });
                                  }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:autoTripAction];
    
    
    [self presentViewController:alertController animated:YES completion:nil];
    
    
}


#pragma mark iTunes Rating Prompt

-(void)ratealert {
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Review App"
                                          message:@"Now that you have been using Simply Auto since a while, could you please review the app?\nThis would mean a lot to us."
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:@"Review App"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   
                                   [[NSUserDefaults standardUserDefaults]setObject:@"Rate App" forKey:@"rateappclick"];
                                   [[NSUserDefaults standardUserDefaults]setInteger:0 forKey:@"appopenstatus"];
                                   NSString *iTunesLink = @"itms://itunes.apple.com/app/id893278325";
                                   iTunesLink = @"itms-apps://itunes.apple.com/app/id893278325?action=write-review";//@"itms-apps://itunes.apple.com/us/app/apple-store/id893278325?mt=8";
                                   [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];
                                   
                               }];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"button_later", @"Cancel action")
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       [[NSUserDefaults standardUserDefaults]setObject:@"Later" forKey:@"rateappclick"];
                                       [[NSUserDefaults standardUserDefaults]setInteger:0 forKey:@"appopenstatus"];
                                       NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
                                       
                                       [def setObject:nil forKey:@"tenDayCount"];
                                       
                                       NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                                       int addDaysCount = 10;
                                       NSDate *today = [[NSDate alloc] init];
                                       [dateFormat setDateFormat:@"dd-MMM-yyyy"];
                                       
                                       NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
                                       [dateComponents setDay:addDaysCount];
                                       
                                       NSDate *dateAfter10 = [[NSCalendar currentCalendar]
                                                              dateByAddingComponents:dateComponents
                                                              toDate:today options:0];
                                       
                                       if([def objectForKey:@"tenDayCount"] == nil){
                                           [def setObject:dateAfter10 forKey:@"tenDayCount"];
                                       }
                                   }];
    
    UIAlertAction *neverAction = [UIAlertAction
                                  actionWithTitle:NSLocalizedString(@"button_never", "Never")
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction *action)
                                  {
                                      [[NSUserDefaults standardUserDefaults]setObject:@"Never" forKey:@"rateappclick"];
                                      [[NSUserDefaults standardUserDefaults]setInteger:0 forKey:@"appopenstatus"];
                                  }];
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    [alertController addAction:neverAction];
    [self presentViewController:alertController animated:YES completion:nil];
    
}


-(void)viewDidDisappear:(BOOL)animated
{
    AppDelegate *App = [AppDelegate sharedAppDelegate];
    App.result = [[UIScreen mainScreen] bounds].size;
    [App.blurview removeFromSuperview];
    [App.tabbutton setImage:[UIImage imageNamed:@"tab_add_new"] forState:UIControlStateNormal];
    
    [App.expense removeFromSuperview];
    [App.trip removeFromSuperview];
    
    [App.services removeFromSuperview];
    [App.fillup removeFromSuperview];
    [App.expenselab removeFromSuperview];
    [App.filluplab removeFromSuperview];
    [App.serviceslab removeFromSuperview];
    [App.tripLab removeFromSuperview];
    App.services.selected=NO;
    
}

-(UIColor *)colorFromHexString:(NSString *)hexString
{
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

-(void)addScrollView{
    
    AppDelegate *app = [AppDelegate sharedAppDelegate];
    self.result = app.result;
    
    CGSize screenSize = [self checkIfiPhoneX];
    
    if (screenSize.height == 812.0f){
        scrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0,136, app.result.width,app.result.height)];
    }else{
        scrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0,116, app.result.width,app.result.height)];
    }
    
    scrollview.showsVerticalScrollIndicator=YES;
    scrollview.scrollEnabled=YES;
    scrollview.userInteractionEnabled=YES;
    
    if(hideGraph){
        
        if(reminderKeys.count > 0){
            
            if(reminderKeys.count == 2){
                
                scrollview.contentSize = CGSizeMake(app.result.width,app.result.height+236);
            }else if(reminderKeys.count == 1){
                
                scrollview.contentSize = CGSizeMake(app.result.width,app.result.height+206);
            }
            
        }else{
            
            scrollview.contentSize = CGSizeMake(app.result.width,app.result.height+30);
        }
        
    }else{
        
        if(reminderKeys.count > 0){
            
            if(reminderKeys.count == 2){
                
                scrollview.contentSize = CGSizeMake(app.result.width,app.result.height+376);
            }else if(reminderKeys.count == 1){
                
                scrollview.contentSize = CGSizeMake(app.result.width,app.result.height+316);
            }
            
        }else{
            
            scrollview.contentSize = CGSizeMake(app.result.width,app.result.height+178);
        }
        
    }
    
    [self.view addSubview:scrollview];
    scrollview.backgroundColor = [self colorFromHexString:@"#4c4b4b"];
    [circleSection removeFromSuperview];
    [reminderSection removeFromSuperview];
    [logSection removeFromSuperview];
    [self addCircelSectionView];
    [self addReminderSectionView];
    [self addLogSectionView];
}

-(void)addCircelSectionView{
    
    if(hideGraph){
        
        circleSection = [[UIView alloc]initWithFrame:CGRectMake(8,10, scrollview.frame.size.width-16, 140)];
    }else{
        
        circleSection = [[UIView alloc]initWithFrame:CGRectMake(8,10, scrollview.frame.size.width-16, 270)];
    }
    
    circleSection.backgroundColor = [self colorFromHexString:@"#2c2c2c"];
    circleSection.layer.cornerRadius = 10;
    [scrollview addSubview:circleSection];
    
    //first Circle
    UIView *firstCircle = [[UIView alloc]initWithFrame:CGRectMake(16, 16, 70, 70)];
    if([circleColor1 isEqualToString:@"GreenColor"]){
        
        firstCircle.backgroundColor = [self colorFromHexString:@"#6ac663"];
    }else if([circleColor1 isEqualToString:@"YellowColor"]){
        
        firstCircle.backgroundColor = [self colorFromHexString:@"#efbf00"];
    }else if([circleColor1 isEqualToString:@"RedColor"]){
        
        firstCircle.backgroundColor = [self colorFromHexString:@"#c63f11"];
    }
    
    firstCircle.layer.cornerRadius = 35;
    [circleSection addSubview:firstCircle];
    
    UILabel *circleLabel = [[UILabel alloc]initWithFrame:CGRectMake(firstCircle.frame.origin.x-12.5, firstCircle.frame.origin.y-12.5, 63, 63)];
    [circleLabel setBackgroundColor:[self colorFromHexString:@"#2c2c2c"]];
    circleLabel.layer.masksToBounds = YES;
    circleLabel.layer.cornerRadius = 31;
    [circleLabel setFont: [circleLabel.font fontWithSize: 13]];
    if(inCircleValue1 != 0){
        NSString *midString = [NSString stringWithFormat:@"%.2f",inCircleValue1];
        if([midString containsString:@".00"]){
            midString = [midString substringToIndex:midString.length-3];
        }
        circleLabel.text = midString;
    }else{
        
        circleLabel.text = @"n/a";
    }
    
    if([circleColor1 isEqualToString:@"GreenColor"]){
        
        circleLabel.textColor = [self colorFromHexString:@"#6ac663"];
    }else if([circleColor1 isEqualToString:@"YellowColor"]){
        
        circleLabel.textColor = [self colorFromHexString:@"#efbf00"];
    }else if([circleColor1 isEqualToString:@"RedColor"]){
        
        circleLabel.textColor = [self colorFromHexString:@"#c63f11"];
    }
    
    circleLabel.textAlignment = NSTextAlignmentCenter;
    [firstCircle addSubview:circleLabel];
    
    //first Under Label
    UILabel *firstUnderLabel = [[UILabel alloc]initWithFrame:CGRectMake(7 ,firstCircle.frame.size.height+10, firstCircle.frame.size.width+18, 50)];
    firstUnderLabel.numberOfLines = 2;
    firstUnderLabel.textColor = [UIColor whiteColor];
    [firstUnderLabel setFont: [firstUnderLabel.font fontWithSize: 12]];
    firstUnderLabel.text = underlineLabelValue1;
    firstUnderLabel.textAlignment = NSTextAlignmentCenter;
    [circleSection addSubview:firstUnderLabel];
    
    //second Circle
    UIView *secondCircle = [[UIView alloc]initWithFrame:CGRectMake(circleSection.frame.size.width/2-35, 16, 70, 70)];
    if([circleColor2 isEqualToString:@"GreenColor"]){
        
        secondCircle.backgroundColor = [self colorFromHexString:@"#6ac663"];
    }else if([circleColor2 isEqualToString:@"YellowColor"]){
        
        secondCircle.backgroundColor = [self colorFromHexString:@"#efbf00"];
    }else if([circleColor2 isEqualToString:@"RedColor"]){
        
        secondCircle.backgroundColor = [self colorFromHexString:@"#c63f11"];
    }
    secondCircle.layer.cornerRadius = 35;
    [circleSection addSubview:secondCircle];
    
    UILabel *circleLabel2 = [[UILabel alloc]initWithFrame:CGRectMake(secondCircle.frame.size.width/2-31.5, secondCircle.frame.origin.y-12.5, 63, 63)];
    [circleLabel2 setBackgroundColor:[self colorFromHexString:@"#2c2c2c"]];
    circleLabel2.layer.masksToBounds = YES;
    circleLabel2.layer.cornerRadius = 31;
    [circleLabel2 setFont: [circleLabel2.font fontWithSize: 13]];
    if(inCircleValue2 != 0){
        NSString *midString = [NSString stringWithFormat:@"%.2f",inCircleValue2];
        if([midString containsString:@".00"]){
            midString = [midString substringToIndex:midString.length-3];
        }
        circleLabel2.text = midString;
    }else{
        
        circleLabel2.text = @"n/a";
    }
    
    if([circleColor2 isEqualToString:@"GreenColor"]){
        
        circleLabel2.textColor = [self colorFromHexString:@"#6ac663"];
    }else if([circleColor2 isEqualToString:@"YellowColor"]){
        
        circleLabel2.textColor = [self colorFromHexString:@"#efbf00"];
    }else if([circleColor2 isEqualToString:@"RedColor"]){
        
        circleLabel2.textColor = [self colorFromHexString:@"#c63f11"];
    }
    
    circleLabel2.textAlignment = NSTextAlignmentCenter;
    [secondCircle addSubview:circleLabel2];
    
    //second Under Label
    UILabel *secondUnderLabel = [[UILabel alloc]initWithFrame:CGRectMake(circleSection.frame.size.width/2-44 ,secondCircle.frame.size.height+10, secondCircle.frame.size.width+18, 50)];
    secondUnderLabel.numberOfLines = 2;
    secondUnderLabel.textColor = [UIColor whiteColor];
    [secondUnderLabel setFont: [secondUnderLabel.font fontWithSize: 12]];
    secondUnderLabel.text = underlineLabelValue2;
    secondUnderLabel.textAlignment = NSTextAlignmentCenter;
    [circleSection addSubview:secondUnderLabel];
    
    //third Cirlce
    UIView *thirdCircle = [[UIView alloc]initWithFrame:CGRectMake(circleSection.frame.size.width-86, 16, 70, 70)];
    if([circleColor3 isEqualToString:@"GreenColor"]){
        
        thirdCircle.backgroundColor = [self colorFromHexString:@"#6ac663"];
    }else if([circleColor3 isEqualToString:@"YellowColor"]){
        
        thirdCircle.backgroundColor = [self colorFromHexString:@"#efbf00"];
    }else if([circleColor3 isEqualToString:@"RedColor"]){
        
        thirdCircle.backgroundColor = [self colorFromHexString:@"#c63f11"];
    }
    thirdCircle.layer.cornerRadius = 35;
    [circleSection addSubview:thirdCircle];

    UILabel *circleLabel3 = [[UILabel alloc]initWithFrame:CGRectMake(secondCircle.frame.size.width/2-31.5, thirdCircle.frame.origin.y-12.5, 63, 63)];
    [circleLabel3 setBackgroundColor:[self colorFromHexString:@"#2c2c2c"]];
    circleLabel3.layer.masksToBounds = YES;
    circleLabel3.layer.cornerRadius = 31;
    [circleLabel3 setFont: [circleLabel3.font fontWithSize: 13]];
    if(inCircleValue3 != 0){
        
        NSString *midString = [NSString stringWithFormat:@"%.2f",inCircleValue3];
        if([midString containsString:@".00"]){
            midString = [midString substringToIndex:midString.length-3];
        }
        circleLabel3.text = midString;
    }else{
        
        circleLabel3.text = @"0";
    }
    
    if([circleColor3 isEqualToString:@"GreenColor"]){
        
        circleLabel3.textColor = [self colorFromHexString:@"#6ac663"];
    }else if([circleColor3 isEqualToString:@"YellowColor"]){
        
        circleLabel3.textColor = [self colorFromHexString:@"#efbf00"];
    }else if([circleColor3 isEqualToString:@"RedColor"]){
        
        circleLabel3.textColor = [self colorFromHexString:@"#c63f11"];
    }
    circleLabel3.textAlignment = NSTextAlignmentCenter;
    [thirdCircle addSubview:circleLabel3];
    
    //third Under Label
    UILabel *thirdUnderLabel = [[UILabel alloc]initWithFrame:CGRectMake(circleSection.frame.size.width-95 ,thirdCircle.frame.size.height+10, thirdCircle.frame.size.width+18, 50)];
    thirdUnderLabel.numberOfLines = 2;
    thirdUnderLabel.textColor = [UIColor whiteColor];
    [thirdUnderLabel setFont: [thirdUnderLabel.font fontWithSize: 12]];
    thirdUnderLabel.text = underlineLabelValue3;
    thirdUnderLabel.textAlignment = NSTextAlignmentCenter;
    [circleSection addSubview:thirdUnderLabel];
    
    //Chart data
    chartView = [[LineChartView alloc]initWithFrame:CGRectMake(7, circleSection.frame.size.height/2, circleSection.frame.size.width-10, circleSection.frame.size.height/2-15)];
    chartView.backgroundColor = [UIColor clearColor];
    chartView.chartDescription.enabled = NO;
    chartView.drawGridBackgroundEnabled = NO;
    chartView.borderColor = [UIColor clearColor];
    chartView.dragEnabled = NO;
    chartView.drawBordersEnabled = NO;
    [chartView setExtraOffsetsWithLeft:2 top:2 right:2 bottom:2];
    
    chartView.pinchZoomEnabled = NO;
    chartView.drawGridBackgroundEnabled = NO;
    
    ChartXAxis *xAxis = chartView.xAxis;
    xAxis.drawGridLinesEnabled = NO;
    xAxis.axisLineColor = [self colorFromHexString:@"#444444"];
    xAxis.labelTextColor = UIColor.whiteColor;
    xAxis.drawAxisLineEnabled = NO;
    xAxis.axisRange = 1;
    xAxis.granularity = 1;
    xAxis.valueFormatter = self;
    xAxis.avoidFirstLastClippingEnabled = true;
    
    ChartYAxis *yAxis = chartView.leftAxis;
    yAxis.labelTextColor = UIColor.whiteColor;
    yAxis.drawAxisLineEnabled = NO;
     
    chartView.rightAxis.enabled = NO;
    chartView.legend.enabled = NO;
    
    chartView.tintColor = [UIColor yellowColor];
    
    NSArray *data = [[NSArray alloc]initWithArray:yGraphValues];
    NSMutableArray<ChartDataEntry *> *entries = [NSMutableArray new];
    
    NSInteger index = 0;
    for (NSNumber *value in data) {
        [entries addObject:[[ChartDataEntry alloc] initWithX:index y:[value doubleValue]]];
        index++;
    }
    
    LineChartDataSet *dataSet = [[LineChartDataSet alloc] initWithValues:entries label:@""];
    
    NSNumber *maximum=[yGraphValues valueForKeyPath:@"@max.doubleValue"];
    NSNumber *minimum=[yGraphValues valueForKeyPath:@"@min.doubleValue"];
    
    double max = [maximum doubleValue];
    double min = [minimum doubleValue];
    double threshold = (max - min) * 20 / 100;
    double greenThreshold = max - threshold;
    double redThreshold = min + threshold;
    
    NSMutableArray *colorArray = [[NSMutableArray alloc]init];
    for(int i=0;i<yGraphValues.count;i++){

        if([[yGraphValues objectAtIndex:i] doubleValue] >= greenThreshold){
            
            [colorArray addObject:[self colorFromHexString:@"#66bb6a"]];
        }else if([[yGraphValues objectAtIndex:i] doubleValue] <= redThreshold){
            
            [colorArray addObject:[self colorFromHexString:@"#dc4b40"]];
        }else{
            
            [colorArray addObject:[self colorFromHexString:@"#ffc105"]];
        }
    }
    
    dataSet.color = [self colorFromHexString:@"#ffc105"];
    dataSet.lineWidth = 1;
    dataSet.circleColors = colorArray;
    dataSet.circleHoleRadius = 0;
    dataSet.circleRadius = 4;
    dataSet.drawValuesEnabled = NO;
    dataSet.mode = LineChartModeHorizontalBezier;
    dataSet.highlightColor = UIColor.grayColor;
    dataSet.highlightLineWidth = 0.8;
    
    NSArray *gradientColors = @[
                                (id)[ChartColorTemplates colorFromString:@"#504e3b81"].CGColor,
                                (id)[ChartColorTemplates colorFromString:@"#ffffc105"].CGColor
                                ];
    CGGradientRef gradient = CGGradientCreateWithColors(nil, (CFArrayRef)gradientColors, nil);
    
    dataSet.fillAlpha = 1.f;
    dataSet.fill = [ChartFill fillWithLinearGradient:gradient angle:90.f];
    dataSet.drawFilledEnabled = YES;
    
    CGGradientRelease(gradient);
    
    if(!hideGraph){
    
        LineChartData *lineData = [[LineChartData alloc] initWithDataSet:dataSet];
        chartView.data = lineData;
        [circleSection addSubview:chartView];

    }
    
    
    UILabel *chartLabel = [[UILabel alloc]initWithFrame:CGRectMake(circleSection.frame.size.width/2-60, chartView.frame.origin.y+chartView.frame.size.height-12, 120, 30)];
    [chartLabel setFont: [chartLabel.font fontWithSize: 12]];
    chartLabel.text = chartUnderLabel;
    chartLabel.textColor = [UIColor whiteColor];
    chartLabel.textAlignment = NSTextAlignmentCenter;
    
    if(!hideGraph){
        
       [circleSection addSubview:chartLabel];
    }
    
}

-(void)addReminderSectionView{
    
    if(reminderKeys.count>0){
        
        if(reminderKeys.count == 1){
            
            reminderSection = [[UIView alloc]initWithFrame:CGRectMake(8,circleSection.frame.origin.y+ circleSection.frame.size.height+10, scrollview.frame.size.width-16, 150)];
        }else if(reminderKeys.count == 2){
            
            reminderSection = [[UIView alloc]initWithFrame:CGRectMake(8,circleSection.frame.origin.y+ circleSection.frame.size.height+10, scrollview.frame.size.width-16, 220)];
        }
        
        reminderSection.backgroundColor = [self colorFromHexString:@"#2c2c2c"];
        reminderSection.layer.cornerRadius = 10;
        [scrollview addSubview:reminderSection];
        
        UILabel *sectionTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(reminderSection.frame.size.width/2-80, 0, 160, 40)];
        sectionTitleLabel.text = NSLocalizedString(@"reminders",@"Reminders");
        sectionTitleLabel.textAlignment = NSTextAlignmentCenter;
        [sectionTitleLabel setFont: [sectionTitleLabel.font fontWithSize: 17]];
        sectionTitleLabel.textColor = [UIColor whiteColor];
        
        [reminderSection addSubview:sectionTitleLabel];
        
        UIView *reminderUnderline = [[UIView alloc]initWithFrame:CGRectMake(sectionTitleLabel.frame.size.width/2-50, sectionTitleLabel.frame.origin.y+sectionTitleLabel.frame.size.height-6, 100, 0.65)];
        reminderUnderline.backgroundColor = [self colorFromHexString:@"#6b6b6b"];
        
        [sectionTitleLabel addSubview:reminderUnderline];
        
        
        
        UIView *reminderCell1 = [[UIView alloc]initWithFrame:CGRectMake(0, reminderUnderline.frame.origin.y+2, reminderSection.frame.size.width, 72)];
        reminderCell1.backgroundColor = [UIColor clearColor];
        [reminderSection addSubview:reminderCell1];
        
        UILabel *serviceName1 = [[UILabel alloc]initWithFrame:CGRectMake(10, 6, reminderCell1.frame.size.width-30, 30)];
        serviceName1.backgroundColor = UIColor.clearColor;
        
        NSString *text1 = [reminderKeys firstObject];
        NSMutableAttributedString *attributedText1 = [[NSMutableAttributedString alloc] initWithString:text1];
        [attributedText1 addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:13.0] range:NSMakeRange(0, text1.length-2)];
        serviceName1.attributedText = attributedText1;
        [serviceName1 setFont: [serviceName1.font fontWithSize: 18]];
        serviceName1.textColor = UIColor.whiteColor;
        
        [reminderCell1 addSubview:serviceName1];
        
        UIProgressView *progressBar1 = [[UIProgressView alloc]initWithFrame:CGRectMake(10,reminderCell1.frame.size.height-14, reminderCell1.frame.size.width-20,8)];
        double percent1 = [[reminderPercentages firstObject] doubleValue];
        if(percent1 >= 100){
            
            progressBar1.progressTintColor = UIColor.redColor;
        }else{
            
            progressBar1.progressTintColor = [self colorFromHexString:@"#FFCC00"];
        }
        [progressBar1 setProgress:percent1/100];
        
        CGAffineTransform transform = CGAffineTransformMakeScale(1.0f, 1.5f);
        progressBar1.transform = transform;
        
        [reminderCell1 addSubview:progressBar1];
        
        UILabel *serviceDueLabel1 = [[UILabel alloc]initWithFrame:CGRectMake(10, progressBar1.frame.origin.y-30, progressBar1.frame.size.width, 40)];
        serviceDueLabel1.textColor = [UIColor whiteColor];
        NSString *showString1 = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"due_on", @"Due:"),[reminderValues firstObject]];
        serviceDueLabel1.text = showString1;
        serviceDueLabel1.textAlignment = NSTextAlignmentRight;
        [serviceDueLabel1 setFont: [serviceName1.font fontWithSize: 10]];
        [reminderCell1 addSubview:serviceDueLabel1];
        
        if(reminderKeys.count == 2){
            
            UIView *reminderCell2 = [[UIView alloc]initWithFrame:CGRectMake(0,reminderCell1.frame.origin.y+reminderCell1.frame.size.height+1, reminderSection.frame.size.width, reminderCell1.frame.size.height)];
            reminderCell2.backgroundColor = [UIColor clearColor];
            [reminderSection addSubview:reminderCell2];
            
            UILabel *serviceName2 = [[UILabel alloc]initWithFrame:CGRectMake(10, 6, reminderCell2.frame.size.width-30, 30)];
            serviceName2.backgroundColor = UIColor.clearColor;
            
            NSString *text2 = [reminderKeys lastObject];
            NSMutableAttributedString *attributedText2 = [[NSMutableAttributedString alloc] initWithString:text2];
            [attributedText2 addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:13.0] range:NSMakeRange(0, text2.length-2)];
            serviceName2.attributedText = attributedText2;
            [serviceName2 setFont: [serviceName2.font fontWithSize: 18]];
            serviceName2.textColor = UIColor.whiteColor;
            
            [reminderCell2 addSubview:serviceName2];
            
            UIProgressView *progressBar2 = [[UIProgressView alloc]initWithFrame:CGRectMake(10,reminderCell2.frame.size.height-14, reminderCell2.frame.size.width-20,8)];
            double percent2 = [[reminderPercentages lastObject] doubleValue];
            if(percent2 >= 100){
                progressBar2.progressTintColor = UIColor.redColor;
            }else{
                progressBar2.progressTintColor = [self colorFromHexString:@"#FFCC00"];
            }
            [progressBar2 setProgress:percent2/100];
            
            progressBar2.transform = transform;
            
            [reminderCell2 addSubview:progressBar2];
            
            UILabel *serviceDueLabel2 = [[UILabel alloc]initWithFrame:CGRectMake(10, progressBar2.frame.origin.y-30, progressBar2.frame.size.width, 40)];
            serviceDueLabel2.textColor = [UIColor whiteColor];
            NSString *showString2 = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"due_on", @"Due:"),[reminderValues lastObject]];
            serviceDueLabel2.text = showString2;
            serviceDueLabel2.textAlignment = NSTextAlignmentRight;
            [serviceDueLabel2 setFont: [serviceName2.font fontWithSize: 10]];
            [reminderCell2 addSubview:serviceDueLabel2];
        }
        
        UIButton *reminderShowAll = [[UIButton alloc]initWithFrame:CGRectMake(10, reminderSection.frame.size.height-40, 100, 30)];
        reminderShowAll.backgroundColor = [self colorFromHexString:@"#2c2c2c"];
        [reminderShowAll setTitle:NSLocalizedString(@"show_all", @"Show All") forState:UIControlStateNormal];
        reminderShowAll.titleLabel.font = [UIFont systemFontOfSize:15];
        [reminderShowAll addTarget:self action:@selector(reminderShowAllClicked) forControlEvents:UIControlEventTouchUpInside];
        [reminderSection addSubview:reminderShowAll];
    
    }else{
        
        reminderSection = [[UIView alloc]initWithFrame:CGRectMake(10,circleSection.frame.origin.y+ circleSection.frame.size.height+10, scrollview.frame.size.width-20,0)];
    }
    
}

-(void)addLogSectionView{
    
    if(self.detailsarray.count>0){
        
        if(reminderKeys.count == 0){
            
            if(self.detailsarray.count > 2){
                
                logSection = [[UIView alloc]initWithFrame:CGRectMake(8,reminderSection.frame.origin.y+ reminderSection.frame.size.height, scrollview.frame.size.width-16, 290)];
            }else if(self.detailsarray.count == 2){
                
                logSection = [[UIView alloc]initWithFrame:CGRectMake(8,reminderSection.frame.origin.y+ reminderSection.frame.size.height, scrollview.frame.size.width-16, 220)];
            }else if(self.detailsarray.count == 1){
                
                logSection = [[UIView alloc]initWithFrame:CGRectMake(8,reminderSection.frame.origin.y+ reminderSection.frame.size.height, scrollview.frame.size.width-16, 150)];
            }
            
        }else{
            
            if(self.detailsarray.count > 2){
                
                logSection = [[UIView alloc]initWithFrame:CGRectMake(8,reminderSection.frame.origin.y+ reminderSection.frame.size.height+10, scrollview.frame.size.width-16, 290)];
            }else if(self.detailsarray.count == 2){
                
                logSection = [[UIView alloc]initWithFrame:CGRectMake(8,reminderSection.frame.origin.y+ reminderSection.frame.size.height+10, scrollview.frame.size.width-16, 220)];
            }else if(self.detailsarray.count == 1){
                
                logSection = [[UIView alloc]initWithFrame:CGRectMake(8,reminderSection.frame.origin.y+ reminderSection.frame.size.height+10, scrollview.frame.size.width-16, 150)];
            }
        }
        
        logSection.backgroundColor = [self colorFromHexString:@"#2c2c2c"];
        logSection.layer.cornerRadius = 10;
        [scrollview addSubview:logSection];
        
        UILabel *sectionTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(logSection.frame.size.width/2-100,0, 200, 40)];
        sectionTitleLabel.text = NSLocalizedString(@"recent_log", @"Recent Log Entries");
        sectionTitleLabel.textAlignment = NSTextAlignmentCenter;
        [sectionTitleLabel setFont: [sectionTitleLabel.font fontWithSize: 17]];
        sectionTitleLabel.textColor = [UIColor whiteColor];
        
        [logSection addSubview:sectionTitleLabel];
        
        UIView *logEntriesUnderline = [[UIView alloc]initWithFrame:CGRectMake(sectionTitleLabel.frame.size.width/2-80, sectionTitleLabel.frame.origin.y+sectionTitleLabel.frame.size.height-6, 160, 0.65)];
        logEntriesUnderline.backgroundColor = [self colorFromHexString:@"#6b6b6b"];
        
        [sectionTitleLabel addSubview:logEntriesUnderline];
        
        if(self.detailsarray.count > 2){
            
            self.logTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, logEntriesUnderline.frame.origin.y+4, logSection.frame.size.width, logSection.frame.size.height-80) style:UITableViewStylePlain];
        }else if(self.detailsarray.count == 2){
            
            self.logTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, logEntriesUnderline.frame.origin.y+4, logSection.frame.size.width, 140) style:UITableViewStylePlain];
        }else if(self.detailsarray.count == 1){
            
            self.logTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, logEntriesUnderline.frame.origin.y+4, logSection.frame.size.width, 70) style:UITableViewStylePlain];
        }
        self.logTableView.delegate = self;
        self.logTableView.dataSource = self;
        self.logTableView.backgroundColor = [UIColor clearColor];
        self.logTableView.separatorColor = [UIColor clearColor];
        self.logTableView.scrollEnabled = NO;
        
        [logSection addSubview:self.logTableView];
        
        
        UIButton *logShowAll = [[UIButton alloc]initWithFrame:CGRectMake(logSection.frame.origin.x+6, logSection.frame.size.height-40, 100, 30)];
        logShowAll.backgroundColor = [self colorFromHexString:@"#2c2c2c"];
        [logShowAll setTitle:NSLocalizedString(@"show_all", @"Show All") forState:UIControlStateNormal];
        logShowAll.titleLabel.font = [UIFont systemFontOfSize:15];
        [logShowAll addTarget:self action:@selector(logShowAllClicked) forControlEvents:UIControlEventTouchUpInside];
        [logSection addSubview:logShowAll];
        
    }else{
        
        logSection = [[UIView alloc]initWithFrame:CGRectMake(8,reminderSection.frame.origin.y+ reminderSection.frame.size.height+10, scrollview.frame.size.width-16, 0)];
    }
    
    
}

-(void)reminderShowAllClicked{
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setBool:YES forKey:@"fromMainScreen"];
    ReminderViewController *reminderView =(ReminderViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"reminder"];
    reminderView.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:reminderView animated:YES completion:nil];
}

-(void)logShowAllClicked{
    
    LogViewController *logView =(LogViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"logVC"];
    logView.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:logView animated:YES completion:nil];
}

- (NSString *)stringForValue:(double)value
                        axis:(ChartAxisBase *)axis
{
    if (chartView.xAxis == axis) {
        return [xDataPoints objectAtIndex:value];
    }else{
        return 0;
    }
}

#pragma mark reminder Table viewmethods
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if(self.detailsarray.count == 1){
        
        return 1;
    }else if(self.detailsarray.count == 2){
        
        return 2;
    }else if(self.detailsarray.count > 2){
       
        return 3;
    }else{
        return 0;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 70;
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    logMainTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"logCell"];
    if (!cell) {
        
        [tableView registerNib:[UINib nibWithNibName:@"logTableViewCell" bundle:nil] forCellReuseIdentifier:@"logCell"];
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"logCell"];
        
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    NSDictionary *dictionary = [[NSDictionary alloc]init];
    dictionary = [self.detailsarray objectAtIndex:indexPath.row];
    //NSLog(@"dictionary %@",dictionary);
    if([[dictionary objectForKey:@"type"]integerValue]==0)
    {
        cell.date.text = [dictionary objectForKey:@"date"];
        
        NSString *str=[NSString stringWithFormat:@"%.2f",[[dictionary objectForKey:@"odo"]floatValue]];
        NSArray *arr=[[NSArray alloc]init];
        arr = [str componentsSeparatedByString:@"."];
        int temp=[[arr lastObject] intValue];
        // NSLog(@"temp value %@",arr);
        NSString *decimalval = [NSString stringWithFormat:@"%d",temp];
        //NSString *odo_short = @"Odo";
        
        if(temp==0)
        {
            
            cell.odo.text =  [NSString stringWithFormat:@"%@: %ld", NSLocalizedString(@"odo_short", @"Odo"), [[dictionary objectForKey:@"odo"] integerValue]];
        }
        else if(![[decimalval substringFromIndex:1]isEqualToString:@"0"])
        {
            cell.odo.text =  [NSString stringWithFormat:@"%@: %.2f", NSLocalizedString(@"odo_short", @"Odo: "),[[dictionary objectForKey:@"odo"] floatValue]];
        }
        
        else
        {
            cell.odo.text =  [NSString stringWithFormat:@"%@: %.1f", NSLocalizedString(@"odo_short", @"Odo: "), [[dictionary objectForKey:@"odo"] floatValue]];
        }
        
        
        NSString *str1=[NSString stringWithFormat:@"%.3f",[[dictionary objectForKey:@"qty"]floatValue]];
        NSMutableArray *arr1=[[NSMutableArray alloc]init];
        NSArray *arr2=[[NSArray alloc]init];
        
        arr2 = [str1 componentsSeparatedByString:@"."];
        // int temp1=[[arr1 lastObject] intValue];
        // NSLog(@"arr2 %@",arr2);
        NSString *decimalval1 = [NSString stringWithFormat:@"%@",[arr2 lastObject]];
        
        for(int i=0;i<decimalval1.length;i++)
        {
            [arr1 addObject:[NSString stringWithFormat:@"%c",[decimalval1 characterAtIndex:i]]];
        }
        //NSLog(@"array value %@",arr1);
        if([[dictionary objectForKey:@"partial"]integerValue]==1)
        {
            //Swapnil ENH_24
            if([[arr1 lastObject] intValue]==0 && [[arr1 objectAtIndex:1]intValue]==0 && [[arr1 firstObject]intValue]!=0)
            {
                cell.qty.text = [NSString stringWithFormat:@"%.1f %@ (P)",[[dictionary objectForKey:@"qty"]floatValue],self.vol];
            }
            
            else if([[arr1 lastObject] intValue]==0 && [[arr1 objectAtIndex:1]intValue]!=0)
            {
                cell.qty.text = [NSString stringWithFormat:@"%.2f %@ (P)",[[dictionary objectForKey:@"qty"] floatValue],self.vol];
            }
            
            else if([[arr1 firstObject] intValue]==0 && [[arr1 objectAtIndex:1]intValue]==0 && [[arr1 lastObject]intValue]==0)
            {
                
                cell.qty.text = [NSString stringWithFormat:@"%d %@ (P)",[[dictionary objectForKey:@"qty"]intValue],self.vol];
            }
            
            else
            {
                cell.qty.text = [NSString stringWithFormat:@"%.3f %@ (P)",[[dictionary objectForKey:@"qty"]floatValue],self.vol];
            }
        }
        
        else
        {
            if([[arr1 lastObject] intValue]==0 && [[arr1 objectAtIndex:1]intValue]==0 && [[arr1 firstObject] intValue]!=0)
            {
                cell.qty.text = [NSString stringWithFormat:@"%.1f %@",[[dictionary objectForKey:@"qty"]floatValue],self.vol];
            }
            
            else if([[arr1 lastObject] intValue]==0 && [[arr1 objectAtIndex:1]intValue]!=0)
            {
                cell.qty.text = [NSString stringWithFormat:@"%.2f %@",[[dictionary objectForKey:@"qty"] floatValue],self.vol];
            }
            
            
            else if([[arr1 firstObject] intValue]==0 && [[arr1 objectAtIndex:1]intValue]==0 && [[arr1 lastObject]intValue]==0)
            {
                
                cell.qty.text = [NSString stringWithFormat:@"%d %@",[[dictionary objectForKey:@"qty"]intValue],self.vol];
            }
            
            else
            {
                cell.qty.text = [NSString stringWithFormat:@"%.3f %@",[[dictionary objectForKey:@"qty"]floatValue],self.vol];
            }
        }
        if([dictionary objectForKey:@"dist"]!=NULL && ![[dictionary objectForKey:@"mfill"] isEqual:@1 ])
        {
            NSString *str=[NSString stringWithFormat:@"%.2f",[[dictionary objectForKey:@"dist"]floatValue]];
            NSArray *arr=[[NSArray alloc]init];
            arr = [str componentsSeparatedByString:@"."];
            int temp=[[arr lastObject] intValue];
            // NSLog(@"temp value %@",arr);
            NSString *decimalval = [NSString stringWithFormat:@"%d",temp];
            
            
            if(temp==0)
            {
                cell.dist.text = [NSString stringWithFormat:@"(+%@) %@",[dictionary objectForKey:@"dist"],self.dist];
            }
            else if(![[decimalval substringFromIndex:1]isEqualToString:@"0"])
            {
                cell.dist.text = [NSString stringWithFormat:@"(+%.2f) %@",[[dictionary objectForKey:@"dist"] floatValue],self.dist];
            }
            
            else
            {
                cell.dist.text = [NSString stringWithFormat:@"(+%.1f) %@",[[dictionary objectForKey:@"dist"] floatValue],self.dist];
            }
            
            
        }
        else if ([[dictionary objectForKey:@"mfill"] isEqual:@1 ])
        {
            cell.dist.text = NSLocalizedString(@"missed_fillup", @"Missed Fill Up");
            
        }
        
        else
        {
            cell.dist.text = NSLocalizedString(@"not_applicable", @"n/a");
        }
        if([dictionary objectForKey:@"eff"]!=NULL && ![[dictionary objectForKey:@"eff"] isEqualToString:@"0.00"])
        {
            NSString *str=[NSString stringWithFormat:@"%.2f",[[dictionary objectForKey:@"eff"]floatValue]];
            NSArray *arr=[[NSArray alloc]init];
            arr = [str componentsSeparatedByString:@"."];
            int temp=[[arr lastObject] intValue];
            // NSLog(@"temp value %@",arr);
            NSString *decimalval = [NSString stringWithFormat:@"%d",temp];
            
            
            if(temp==0)
            {
                cell.eff.text = [NSString stringWithFormat:@"%d %@",[[dictionary objectForKey:@"eff"]intValue],self.con];
            }
            else if(![[decimalval substringFromIndex:1]isEqualToString:@"0"])
            {
                cell.eff.text = [NSString stringWithFormat:@"%.2f %@",[[dictionary objectForKey:@"eff"]floatValue],self.con];
            }
            
            else
            {
                cell.eff.text = [NSString stringWithFormat:@"%.1f %@",[[dictionary objectForKey:@"eff"]floatValue],self.con];
            }
            
        }
        
        else
        {
            //NSString *not_applicable = @"n/a";
            cell.eff.text = NSLocalizedString(@"not_applicable", @"n/a");
        }
        
        // NSLog(@"value of cost %@",[dictionary objectForKey:@"cost"]);
        if([dictionary objectForKey:@"cost"]!=NULL && [[dictionary objectForKey:@"cost"]floatValue]!=0)
        {
            
            cell.price.text =[NSString stringWithFormat:@"%.2f %@",[[dictionary objectForKey:@"cost"]floatValue],self.curr];
        }
        else
        {
            //NSString *not_applicable = @"n/a";
            cell.price.text = NSLocalizedString(@"not_applicable", @"n/a");
        }
        cell.imageview.image = [UIImage imageNamed:@"fill_up_icon"];
        
        return cell;
    }
    
    
    else  if([[dictionary objectForKey:@"type"]integerValue]==1)
    {
        cell.date.text = [dictionary objectForKey:@"date"];
        
        NSString *str=[NSString stringWithFormat:@"%.2f",[[dictionary objectForKey:@"odo"]floatValue]];
        NSArray *arr=[[NSArray alloc]init];
        arr = [str componentsSeparatedByString:@"."];
        int temp=[[arr lastObject] intValue];
        // NSLog(@"temp value %@",arr);
        NSString *decimalval = [NSString stringWithFormat:@"%d",temp];
        //NSString *odo_short = @"Odo";
        
        if(temp==0)
        {
            cell.odo.text =  [NSString stringWithFormat:@"%@: %d", NSLocalizedString(@"odo_short", @"Odo: "), [[dictionary objectForKey:@"odo"]intValue]];
        }
        else if(![[decimalval substringFromIndex:1]isEqualToString:@"0"])
        {
            cell.odo.text =  [NSString stringWithFormat:@"%@: %.2f", NSLocalizedString(@"odo_short", @"Odo: ") ,[[dictionary objectForKey:@"odo"] floatValue]];
        }
        
        else
        {
            cell.odo.text =  [NSString stringWithFormat:@"%@: %.1f", NSLocalizedString(@"odo_short", @"Odo: ") , [[dictionary objectForKey:@"odo"] floatValue]];
        }
        
        
        if([dictionary objectForKey:@"cost"]!=NULL & [[dictionary objectForKey:@"cost"]floatValue]!=0)
        {
            cell.price.text =[NSString stringWithFormat:@"%.2f %@",[[dictionary objectForKey:@"cost"]floatValue],self.curr];
        }
        else
        {
            //NSString *not_applicable = @"n/a";
            cell.price.text = NSLocalizedString(@"not_applicable", @"n/a");
        }
        
        if([dictionary objectForKey:@"filling"]!=NULL)
        {
            cell.qty.text =[NSString stringWithFormat:@"%@",[dictionary objectForKey:@"filling"]];
        }
        cell.eff.text = @"";
        if(![[dictionary objectForKey:@"service"]isEqualToString:@"Fuel Record"])
        {
            cell.dist.text = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"service"]];
            // NSLog(@"called......");
        }
        cell.imageview.image = [UIImage imageNamed:@"service_icon"];
        return cell;
    }
    
    
    else if([[dictionary objectForKey:@"type"]integerValue]==2)
    {
        cell.date.text = [dictionary objectForKey:@"date"];
        NSString *str=[NSString stringWithFormat:@"%.2f",[[dictionary objectForKey:@"odo"]floatValue]];
        NSArray *arr=[[NSArray alloc]init];
        arr = [str componentsSeparatedByString:@"."];
        int temp=[[arr lastObject] intValue];
        // NSLog(@"temp value %@",arr);
        NSString *decimalval = [NSString stringWithFormat:@"%d",temp];
        //NSString *odo_short = @"Odo";
        
        if(temp==0)
        {
            cell.odo.text =  [NSString stringWithFormat:@"%@: %ld", NSLocalizedString(@"odo_short", @"Odo: "), [[dictionary objectForKey:@"odo"] longValue]];
        }
        else if(![[decimalval substringFromIndex:1]isEqualToString:@"0"])
        {
            cell.odo.text =  [NSString stringWithFormat:@"%@: %.2f",  NSLocalizedString(@"odo_short", @"Odo: "), [[dictionary objectForKey:@"odo"] floatValue]];
        }
        
        else
        {
            cell.odo.text =  [NSString stringWithFormat:@"%@: %.1f", NSLocalizedString(@"odo_short", @"Odo: ") , [[dictionary objectForKey:@"odo"] floatValue]];
        }
        
        if([dictionary objectForKey:@"cost"]!=NULL & [[dictionary objectForKey:@"cost"]floatValue]!=0)
        {
            cell.price.text =[NSString stringWithFormat:@"%.2f %@",[[dictionary objectForKey:@"cost"]floatValue],self.curr];
        }
        
        else
        {
            cell.price.text = NSLocalizedString(@"not_applicable", @"n/a");
        }
        
        cell.eff.text = @"";
        if([dictionary objectForKey:@"filling"]!=NULL)
        {
            cell.qty.text =[NSString stringWithFormat:@"%@",[dictionary objectForKey:@"filling"]];
        }
        
        if(![[dictionary objectForKey:@"service"]isEqualToString:@"Fuel Record"])
        {
            
            cell.dist.text = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"service"]];
            
        }
        cell.imageview.image = [UIImage imageNamed:@"expense_icon"];
        return cell;
    }
    
    else if([[dictionary objectForKey:@"type"] isEqual:@3])
    {
        
        
        cell.imageview.image = [UIImage imageNamed:@"trip_icon"];
        cell.odo.text =  [[[dictionary objectForKey:@"depLocn"] stringByAppendingString:@"-" ] stringByAppendingString:[dictionary objectForKey:@"arrLocn"]];
        cell.price.text =[NSString stringWithFormat:@"%.2f %@",[[dictionary objectForKey:@"cost"]floatValue],self.curr];
        cell.date.text = [dictionary objectForKey:@"date"];
        cell.qty.text = [dictionary objectForKey:@"tripType"];
        
        if ([[dictionary objectForKey:@"dist"] floatValue] == 0) {
            cell.dist.text = NSLocalizedString(@"in_progress", @"In Progress");
        }
        else
        {  cell.dist.text = [NSString stringWithFormat:@"(+%.1f) %@",[[dictionary objectForKey:@"dist"] floatValue],self.dist];
        }
        
        cell.eff.text = @"";
        
        
        
        return cell;
    }

    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSMutableDictionary *detail = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *copyDict = [[NSMutableDictionary alloc] init];
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setBool:YES forKey:@"editPageOpen"];

    if(indexPath.row < 3){
        
        copyDict = [self.detailsarray objectAtIndex:indexPath.row];
        detail = [copyDict mutableCopy];
        [detail setValue:[NSString stringWithFormat:@"%ld",(long)indexPath.row] forKey:@"valueindex"];
        if([[detail objectForKey:@"type"] integerValue]==0)
        {
            AddFillupViewController *add = (AddFillupViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"addfillup"];
            
            [[NSUserDefaults standardUserDefaults]setObject :detail forKey:@"editdetails"];
            dispatch_async(dispatch_get_main_queue(), ^{
                add.modalPresentationStyle = UIModalPresentationFullScreen;
                [self.navigationController presentViewController:add animated:YES completion:nil];
            });
            
        }
        
        else if([[detail objectForKey:@"type"] integerValue]==2)
        {
            AddExpenseViewController *add = (AddExpenseViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"expense"];
            [[NSUserDefaults standardUserDefaults]setObject:detail forKey:@"editdetails"];
            dispatch_async(dispatch_get_main_queue(), ^{
                add.modalPresentationStyle = UIModalPresentationFullScreen;
                [self presentViewController:add animated:YES completion:nil];
                
            });
        }
        
        else  if([[detail objectForKey:@"type"] integerValue]==1)
        {
            ServiceViewController *add = (ServiceViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"service"];
            [[NSUserDefaults standardUserDefaults]setObject:detail forKey:@"editdetails"];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                add.modalPresentationStyle = UIModalPresentationFullScreen;
                [self presentViewController:add animated:YES completion:nil];
                
            });
        }
        else  if([[detail objectForKey:@"type"] integerValue]==3)
        {
            AddTripViewController *add = (AddTripViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"AddTrip"];
            [[NSUserDefaults standardUserDefaults]setObject:detail forKey:@"editdetails"];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                add.modalPresentationStyle = UIModalPresentationFullScreen;
                [self presentViewController:add animated:YES completion:nil];
                
            });
        }
    }
    
}

#pragma mark Vehicle Picker methods

-(void)openselectpicker
{
    if(self.vehiclearray.count>0)
    {
        [self picker:@"Select Vehicle"];
    }
    
    else
    {
        
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:NSLocalizedString(@"no_veh_id", @"No Vehicle Found")
                                              message:@""
                                              preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"ok", @"OK action")
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       
                                   }];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)picker : (NSString *) string{
    
    [_picker removeFromSuperview];
    [_setbutton removeFromSuperview];
    _picker = [[UIPickerView alloc]init];
    AppDelegate *App = [AppDelegate sharedAppDelegate];
    _picker.frame = CGRectMake(App.result.width/2-130,App.result.height/2-220, 260, 270);
    _picker.backgroundColor=[UIColor grayColor];
    
    _picker.clipsToBounds=YES;
    _picker.delegate =self;
    _picker.dataSource=self;
    _picker.tag=-8;
    
    NSUserDefaults *setRowValue = [NSUserDefaults standardUserDefaults];
    int picRowId = (int)[setRowValue integerForKey:@"rowValue"];
    [_picker selectRow:picRowId inComponent:0 animated:NO];
    
    UIBezierPath *maskPath;
    maskPath = [UIBezierPath bezierPathWithRoundedRect:_picker.bounds
                                     byRoundingCorners:(UIRectCornerTopLeft|UIRectCornerTopRight)
                                           cornerRadii:CGSizeMake(5.0, 5.0)];
    
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.view.frame;
    maskLayer.path = maskPath.CGPath;
    _picker.layer.mask = maskLayer;
    
    [self.view addSubview:_picker];
    _setbutton =[[UIButton alloc]init];
    _setbutton.frame = CGRectMake(App.result.width/2-130,(App.result.height/2-220)+270, 260, 40);
    [_setbutton setBackgroundColor:[UIColor lightGrayColor]];
    [_setbutton setTitle:NSLocalizedString(@"set", @"Set") forState:UIControlStateNormal];
    [_setbutton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_setbutton addTarget:self action:@selector(donelabel) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_setbutton];
    
}



- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
     return  self.vehiclearray.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSDictionary *dictionary = [[NSDictionary alloc]init];
    dictionary = [self.vehiclearray objectAtIndex:row];
    return [NSString stringWithFormat:@"%@ %@",[dictionary objectForKey:@"Make"],[dictionary objectForKey:@"Model"]];
  
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    _selPickerRow = (int)[pickerView selectedRowInComponent:0];
    NSUserDefaults *setRowValue = [NSUserDefaults standardUserDefaults];
    [setRowValue setInteger:_selPickerRow forKey:@"rowValue"];
}

-(void)donelabel
{

    NSUserDefaults *def =[NSUserDefaults standardUserDefaults];
    [self.picker removeFromSuperview];
    [self.setbutton removeFromSuperview];
    NSDictionary *dictionary = [[NSDictionary alloc]init];
    dictionary = [self.vehiclearray objectAtIndex:[self.picker selectedRowInComponent:0]];
    [[NSUserDefaults standardUserDefaults]setObject:[dictionary objectForKey:@"Id"] forKey:@"fillupid"];
    [[NSUserDefaults standardUserDefaults]setObject:[NSString stringWithFormat:@"%@ %@",[dictionary objectForKey:@"Make"],[dictionary objectForKey:@"Model"]] forKey:@"fillupmake"];
    
    self.vehNameLabel.text = [NSString stringWithFormat:@"%@ %@",[dictionary objectForKey:@"Make"],[dictionary objectForKey:@"Model"]];
    
    [def setObject:[dictionary objectForKey:@"Id"] forKey:@"idvalue"];
    [def setObject:[NSString stringWithFormat:@"%@ %@",[dictionary objectForKey:@"Make"],[dictionary objectForKey:@"Model"]] forKey:@"vehname"];
    [def setObject:[NSString stringWithFormat:@"%@",[dictionary objectForKey:@"Id"]] forKey:@"fillupid"];
    [def setObject:[def objectForKey:@"fillupid"] forKey:@"oldFillupid"];

    [def setObject:[dictionary objectForKey:@"Picture"] forKey:@"vehimage"];
    if([[[NSUserDefaults standardUserDefaults]objectForKey:@"vehimage"]isEqualToString:@""])
    {
        self.vehImageView.image=[UIImage imageNamed:@"car4.jpg"];
    }
    
    else
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *urlstring = [paths firstObject];
        
        NSString *vehiclepic = [NSString stringWithFormat:@"%@/%@",urlstring,[[NSUserDefaults standardUserDefaults]objectForKey:@"vehimage"]];
        self.vehImageView.image =[UIImage imageWithContentsOfFile:vehiclepic];
    }
   
    self.detailsarray = [[NSMutableArray alloc] init];
    [self fetchdata];
    [self fetchAllValues];
    [self addScrollView];
}

-(void)fetchdata
{
    self.vehiclearray =[[NSMutableArray alloc]init];
    
    NSManagedObjectContext *context = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSFetchRequest *requset=[[NSFetchRequest alloc] initWithEntityName:@"Veh_Table"];
    NSError *err;
    NSArray *data=[context  executeFetchRequest:requset error:&err];
    for(Veh_Table *vehicle in data)
    {
        if(vehicle.make != nil && vehicle.model != nil){

            NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
            [dictionary setObject:vehicle.make forKey:@"Make"];
            [dictionary setObject:vehicle.model forKey:@"Model"];
            [dictionary setObject:vehicle.iD forKey:@"Id"];

            if(vehicle.picture!=nil)
            {
                [dictionary setObject:vehicle.picture forKey:@"Picture"];
            }
            else
            {

                [dictionary setObject:@"" forKey:@"Picture"];

            }
            if(vehicle.lic!=nil)
            {
                [dictionary setObject:vehicle.lic forKey:@"Lic"];
            }
            else
            {

                [dictionary setObject:@"" forKey:@"Lic"];
            }
            if(vehicle.vin!=nil)
            {
                [dictionary setObject:vehicle.vin forKey:@"Vin"];
            }
            else
            {
                [dictionary setObject:@"" forKey:@"Vic"];
            }
            if(vehicle.year!=nil)
            {
                [dictionary setObject:vehicle.year forKey:@"Year"];
            }
            else
            {

                [dictionary setObject:@"" forKey:@"Year"];
            }
            [self.vehiclearray addObject:dictionary];
        }

    }
    
}

-(void)fetchFromHereValue
{
    //NIKHIL BUG_156
    NSManagedObjectContext *context=[[CoreDataController sharedInstance] newManagedObjectContext];
    NSError *err;
    NSUserDefaults *Def =[NSUserDefaults standardUserDefaults];
    NSString *comparestring = [NSString stringWithFormat:@"%@",[Def objectForKey:@"fillupid"]];
    
    NSFetchRequest *requset=[[NSFetchRequest alloc] initWithEntityName:@"T_Fuelcons"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"vehid==%@",comparestring];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"odo"
                                                                   ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [requset setPredicate:predicate];
    [requset setSortDescriptors:sortDescriptors];
    
    
    NSArray *datavaluefilter = [[NSArray alloc]init];
    NSMutableArray *datavalue= [[NSMutableArray alloc]init];
    //NIKHIL BUG 156
    datavaluefilter =[context  executeFetchRequest:requset error:&err];
    NSDateFormatter *Uniformater=[[NSDateFormatter alloc] init];
    [Uniformater setDateFormat:@"dd MMM yyyy"];
    NSDateFormatter *formaterMON=[[NSDateFormatter alloc] init];
    [formaterMON setDateFormat:@"MMM"];
    
    datavalue = [[NSMutableArray alloc]initWithArray:datavaluefilter];
    
    NSString *distance;
    NSString *dist_unit,*vol_unit;
    
    if([[[NSUserDefaults standardUserDefaults]objectForKey:@"dist_unit"] isEqualToString:NSLocalizedString(@"disp_miles", @"Miles")])
    {
        dist_unit = NSLocalizedString(@"mi", @"mi");
    }
    
    else
    {
        dist_unit = NSLocalizedString(@"kms", @"km");
    }
    
    if([[[NSUserDefaults standardUserDefaults]objectForKey:@"vol_unit"] isEqualToString:NSLocalizedString(@"disp_kilowatt_hour", @"Kilowatt-Hour")]){

        vol_unit = NSLocalizedString(@"kwh", @"kWh");

    } else if([[[NSUserDefaults standardUserDefaults]objectForKey:@"vol_unit"] isEqualToString:NSLocalizedString(@"disp_litre", @"Litre")])
    {
        vol_unit = NSLocalizedString(@"ltr", @"Ltr");
        
    }
    
    else
    {
        vol_unit = NSLocalizedString(@"gal", @"gal");
    }
    
    T_Fuelcons *maxodo = [datavalue lastObject];
    T_Fuelcons *minodo = [datavalue firstObject];
    
    distance = [NSString stringWithFormat:@"%.2f",[maxodo.odo floatValue] - [minodo.odo floatValue]];
    
    NSArray *arr=[[NSArray alloc]init];
    arr = [distance componentsSeparatedByString:@"."];
    int temp=[[arr lastObject] intValue];
    NSString *decimalval = [NSString stringWithFormat:@"%d",temp];
    
    NSMutableArray *totalstat = [[NSMutableArray alloc]init];

    if(distance==NULL || [distance isEqualToString:@"0.00"])
    {
        [totalstat addObject :[NSString stringWithFormat:@"%@", NSLocalizedString(@"not_applicable", @"n/a")]];
    }
    
    else
    {
        if(temp==0)
        {
            [totalstat addObject:[NSString stringWithFormat:@"%ld %@",(long)[distance integerValue] ,dist_unit]];
        }
        else if(![[decimalval substringFromIndex:1]isEqualToString:@"0"])
        {
            [totalstat addObject:[NSString stringWithFormat:@"%.2f %@",[distance floatValue],dist_unit]];
        }
        
        else
        {
            [totalstat addObject:[NSString stringWithFormat:@"%.1f %@",[distance floatValue],dist_unit]];
        }
    }
    int fillupno=0;
    
    
    NSMutableArray *dataval = [[NSMutableArray alloc]init];
    NSMutableArray *services = [[NSMutableArray alloc]init];
    NSMutableArray *expense =[[NSMutableArray alloc]init];
    
    NSMutableArray *filluparray = [[NSMutableArray alloc]init];
    NSMutableArray *servicearray = [[NSMutableArray alloc]init];
    NSMutableArray *expensearray =[[NSMutableArray alloc]init];
    
    for(T_Fuelcons *fillup in datavalue)
    {
        if([fillup.type integerValue]==0)
        {
            [dataval addObject:fillup];
            [filluparray addObject:fillup];
        }
        
        if([fillup.type integerValue]==1)
        {
            [services addObject:fillup];
            [servicearray addObject:fillup];
        }
        
        if([fillup.type integerValue]==2)
        {
            [expense addObject:fillup];
            [expensearray addObject:fillup];
        }
    }
    
    fillupno = (int)dataval.count;
    float qty=0.0;
    float cost =0.0;
    float fuelcost =0.0;
    
    float servicecost = 0.0;
    float expenses =0.0;
    NSMutableArray *serviceno = [[NSMutableArray alloc]init];
    
    NSString *qtyval;
    float dist=0.0;
    int filluprecord = 0;
    int totalcostrecord =0;
    NSDateFormatter *formater=[[NSDateFormatter alloc] init];
    [formater setDateFormat:@"MMyyyy"];
    NSString *currentdate = [formater stringFromDate:[NSDate date]];
    int fillpermonth=0;
    NSMutableArray *montharray =[[NSMutableArray alloc]init];
    float costperdist =0.0, distpercost =0.0;
    float qtyeff =0.0, disteff=0.0;
    float pricepergal =0.0;
    
    
    NSDate *maxdate, *mindate;
    NSDateFormatter *formater1=[[NSDateFormatter alloc] init];
    [formater1 setDateFormat:@"dd/MM/yyyy"];
    for(T_Fuelcons *fillup in dataval)
    {
        if(fillup.cost != NULL && [fillup.cost floatValue]!=0)
        {
            mindate = fillup.stringDate;
            break;
        }
    }
    NSArray *datavalue1 = [[NSArray alloc]init];
    datavalue1 = [[dataval reverseObjectEnumerator]allObjects];
    for(T_Fuelcons *fillup in datavalue1)
    {
        if(fillup.cost != NULL && [fillup.cost floatValue]!=0)
        {
            maxdate = fillup.stringDate;
            break;
        }
    }
    
    NSCalendar *cal = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comp;
    if(mindate!=nil&&maxdate!=nil){
        comp = [cal components:NSCalendarUnitDay fromDate:mindate toDate:maxdate options:NSCalendarWrapComponents];
    }
    int qtyrecord=0;
    for(T_Fuelcons *fillup in dataval)
    {
        qty = qty + [fillup.qty floatValue];
        cost = cost + [fillup.cost floatValue];
        dist = dist + [fillup.dist floatValue];
        if([fillup.cost floatValue]!=0 && fillup.cost!=NULL)
        {
            pricepergal = pricepergal + [fillup.cost floatValue];
            qtyrecord = qtyrecord+1;
        }
        
        if([fillup.dist floatValue]!=0)
        {
            filluprecord =filluprecord+1;
        }
        
        if([fillup.cons floatValue]!=0 && fillup.cons!=NULL)
        {
            qtyeff = qtyeff + [fillup.qty floatValue];
            disteff = disteff + [fillup.dist floatValue];
        }
        
        if([fillup.qty floatValue] * [fillup.cost floatValue]!=0)
        {
            totalcostrecord =totalcostrecord+1;
        }
        if(![currentdate isEqualToString:[formater stringFromDate:fillup.stringDate]])
        {
            fuelcost = fuelcost +[fillup.cost floatValue];
            fillpermonth =fillpermonth + 1;
            if(![montharray containsObject:[formater stringFromDate:fillup.stringDate]])
            {
                if(fillup.stringDate != NULL){
                    [montharray addObject:[formater stringFromDate:fillup.stringDate]];
                }
            }
        }
        
        if([fillup.dist floatValue]!=0 && [fillup.cost floatValue]!=0 && [fillup.cons floatValue]!=0 && fillup.cons!=NULL && fillup.cost!=NULL && fillup.dist != NULL)
        {
            costperdist = costperdist + [fillup.cost floatValue];
            distpercost =distpercost + [fillup.dist floatValue];
        }
        
    }
    
    float servicecostval=0.0;
    float servicedist=0.0;
    
    NSDate *maxdate1, *mindate1;
    for(T_Fuelcons *fillup in services)
    {
        if(fillup.cost != NULL && [fillup.cost floatValue]!=0)
        {
            mindate1 = fillup.stringDate;
            break;
        }
    }
    NSArray *datavalue2 = [[NSArray alloc]init];
    datavalue2 = [[services reverseObjectEnumerator]allObjects];
    for(T_Fuelcons *fillup in datavalue2)
    {
        if(fillup.cost != NULL && [fillup.cost floatValue]!=0)
        {
            maxdate1 = fillup.stringDate;
            break;
        }
    }
    
    NSDateComponents *comp1;
    if(mindate1!=nil&&maxdate1!=nil){
        comp1 = [cal components:NSCalendarUnitDay fromDate:mindate1 toDate:maxdate1 options:NSCalendarWrapComponents];
    }
    for(T_Fuelcons *fillup in services)
    {
        servicecost = servicecost +[fillup.cost floatValue];
        NSArray *servicenumber = [fillup.serviceType componentsSeparatedByString:@","];
        for(NSString *serviceadd in servicenumber)
        {
            if(![serviceno containsObject:serviceadd])
            {
                [serviceno addObject:serviceadd];
            }
        }
        
        if([fillup.cost floatValue]!=0 && fillup.cost!=NULL)
        {
            servicecostval = servicecostval + [fillup.cost floatValue];
        }
        
    }
    
    T_Fuelcons *maxodoserv = [services lastObject];
    T_Fuelcons *minodoserv = [services firstObject];
    
    servicedist = [maxodoserv.odo floatValue]-[minodoserv.odo floatValue];
    float expcostval=0.0;
    float expdist=0.0;
    
    NSDate *maxdate2, *mindate2;
    for(T_Fuelcons *fillup in expense)
    {
        if(fillup.cost != NULL && [fillup.cost floatValue]!=0)
        {
            mindate2 = fillup.stringDate;
            break;
        }
    }
    NSArray *datavalue3 = [[NSArray alloc]init];
    datavalue3 = [[expense reverseObjectEnumerator]allObjects];
    for(T_Fuelcons *fillup in datavalue3)
    {
        if(fillup.cost != NULL && [fillup.cost floatValue]!=0)
        {
            maxdate2 = fillup.stringDate;
            break;
        }
    }
    
    NSDateComponents *comp2;
    if(mindate2!=nil&&maxdate2!=nil){
        comp2 = [cal components:NSCalendarUnitDay fromDate:mindate2 toDate:maxdate2 options:NSCalendarWrapComponents];
    }
    
    for(T_Fuelcons *fillup in expense)
    {
        expenses = expenses +[fillup.cost floatValue];
        
        if([fillup.cost floatValue]!=0 && fillup.cost!=NULL)
        {
            expcostval = expcostval + [fillup.cost floatValue];
        }
        
    }
    
    T_Fuelcons *maxodoexp = [expense lastObject];
    T_Fuelcons *minodoexp = [expense firstObject];
    
    expdist = [maxodoexp.odo floatValue]-[minodoexp.odo floatValue];
    
    NSString *str1=[NSString stringWithFormat:@"%.3f",qty];
    NSMutableArray *arr1=[[NSMutableArray alloc]init];
    NSArray *arr2=[[NSArray alloc]init];
    
    arr2 = [str1 componentsSeparatedByString:@"."];
    // int temp1=[[arr1 lastObject] intValue];
    // NSLog(@"arr2 %@",arr2);
    NSString *decimalval1 = [NSString stringWithFormat:@"%@",[arr2 lastObject]];
    
    for(int i=0;i<decimalval1.length;i++)
    {
        [arr1 addObject:[NSString stringWithFormat:@"%c",[decimalval1 characterAtIndex:i]]];
    }
    
    if(qty==0)
    {
        
        qtyval = NSLocalizedString(@"not_applicable", @"n/a");
    }
    
    else
    {
        //Swapnil ENH_24
        if([[arr1 lastObject] intValue]==0 && [[arr1 objectAtIndex:1]intValue]==0 && [[arr1 firstObject]intValue]!=0)
        {
            qtyval = [NSString stringWithFormat:@"%.1f %@",qty,vol_unit];
        }
        
        else if([[arr1 lastObject] intValue]==0 && [[arr1 objectAtIndex:1]intValue]!=0)
        {
            qtyval = [NSString stringWithFormat:@"%.2f %@",qty,vol_unit];
        }
        
        
        else if([[arr1 firstObject] intValue]==0 && [[arr1 objectAtIndex:1]intValue]==0 && [[arr1 lastObject]intValue]==0)
        {
            
            qtyval = [NSString stringWithFormat:@"%d %@",(int)ceilf(qty),vol_unit];
        }
        
        else
        {
            qtyval = [NSString stringWithFormat:@"%.3f %@",qty,vol_unit];
        }
    }
    
    NSString *curr_unit;
    
    NSArray *array = [[[NSUserDefaults standardUserDefaults]objectForKey:@"curr_unit"] componentsSeparatedByString:@"-"];
    NSString *string = [array lastObject];
    curr_unit = string;
    
    float dist_fact= 1;
    float vol_fact =1;
    
    //NSString *con_unit = [[NSUserDefaults standardUserDefaults]objectForKey:@"con_unit"];
    NSString *con_unit;
    NSArray *array1 = [[[NSUserDefaults standardUserDefaults]objectForKey:@"con_unit"] componentsSeparatedByString:@" "];
    NSString *string1 = [array1 firstObject];
    con_unit= string1;
    
    
    NSString *dist_unit1 =[[NSUserDefaults standardUserDefaults]objectForKey:@"dist_unit"];
    NSString *vol_unit1 = [[NSUserDefaults standardUserDefaults]objectForKey:@"vol_unit"];
    NSString *con_unit1 = [[NSUserDefaults standardUserDefaults]objectForKey:@"con_unit"];
    if([con_unit1 hasPrefix:@"m"] && [dist_unit1 isEqualToString:NSLocalizedString(@"disp_kilometers", @"Kilometers")])
    {
        dist_fact =0.621;
    }
    
    else if(![con_unit1 hasPrefix:@"m"] && [dist_unit1 isEqualToString:NSLocalizedString(@"disp_miles", @"Miles")])
    {
        dist_fact = 1.609;
    }
    
    if([con_unit1 isEqualToString:NSLocalizedString(@"disp_mpg_us", @"mpg (US)")])
    {
        if([vol_unit1 isEqualToString:NSLocalizedString(@"disp_litre", @"Litre")])
        {
            vol_fact=0.264;
        }
        else if ([vol_unit1 isEqualToString:NSLocalizedString(@"disp_gal_uk", @"Gallon (UK)")])
        {
            vol_fact = 1.201;
        }
    }
    
    else  if([con_unit1 isEqualToString:NSLocalizedString(@"disp_mpg_uk", @"mpg (UK)")])
    {
        if([vol_unit1 isEqualToString:NSLocalizedString(@"disp_litre", @"Litre")])
        {
            vol_fact=0.22;
        }
        else if ([vol_unit1 isEqualToString:NSLocalizedString(@"disp_gal_us", @"Gallon (US)")])
        {
            vol_fact = 0.833;
        }
    }
    
    else if([con_unit1 isEqualToString:NSLocalizedString(@"disp_lp100kms", @"L/100km")] || [con_unit1 isEqualToString:NSLocalizedString(@"disp_kmpl", @"km/L")])
    {
        if([vol_unit1 isEqualToString:NSLocalizedString(@"disp_gal_uk", @"Gallon (UK)")])
        {
            vol_fact= 4.546;
        }
        else if ([vol_unit1 isEqualToString:NSLocalizedString(@"disp_gal_us", @"Gallon (US)")])
        {
            vol_fact = 3.785;
        }
        
    }
    
    avgfuelstat = [[NSMutableArray alloc]init];
    if(disteff!=0)
    {
        
        float disteffperqty=0.0;
        disteffperqty = (disteff *dist_fact)/(qtyeff*vol_fact);
        NSString *str1=[NSString stringWithFormat:@"%.2f",disteffperqty];
        if([con_unit containsString:@"100"])
        {
            str1=[NSString stringWithFormat:@"%.2f",100/disteffperqty];
            
        }
        NSArray *arr2=[[NSArray alloc]init];
        arr2 = [str1 componentsSeparatedByString:@"."];
        
        //Average Fuel Efficiency
        if([con_unit containsString:@"100"])
        {
            [avgfuelstat addObject:[NSString stringWithFormat:@"%.2f %@",100/((disteff *dist_fact)/(qtyeff*vol_fact)),con_unit]];
            
        }
        //Average Fuel Efficiency
        else
        {
            
            [avgfuelstat addObject:[NSString stringWithFormat:@"%.2f %@",(disteff *dist_fact)/(qtyeff*vol_fact),con_unit]];
            
        }
    }
    //Average Fuel Efficiency
    else
    {
        [avgfuelstat addObject:[NSString stringWithFormat:@"n/a"]];
    }
    
    
}

-(void)fetchAllValues{
    
    LogViewController *LogVC = [[LogViewController alloc]init];
    [LogVC fetchallfillup];
    allValuesArray = [[NSMutableArray alloc]init];
    allValuesArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"SortedLog"];
    if(allValuesArray.count > 2){
        
        for(int i=0;i<3;i++){
            
            [self.detailsarray addObject:[allValuesArray objectAtIndex:i]];
        }
    }else{
        
        self.detailsarray = [allValuesArray mutableCopy];
    }
    fillUpArray = [[NSMutableArray alloc]init];
    serviceArray = [[NSMutableArray alloc]init];
    expenseArray = [[NSMutableArray alloc]init];
    tripArray = [[NSMutableArray alloc]init];
    
    for(NSArray *logData in allValuesArray){
        
        if([[logData valueForKey:@"type"] isEqual:@0]){
            
            [fillUpArray addObject:logData];
            
        }else if ([[logData valueForKey:@"type"] isEqual:@1]){
            
            [serviceArray addObject:logData];
            
        }else if ([[logData valueForKey:@"type"] isEqual:@2]){
            
            [expenseArray addObject:logData];
            
        }else if ([[logData valueForKey:@"type"] isEqual:@3]){
            
            [tripArray addObject:logData];
            
        }
            
    }
    
    [self fetchValueForSecondCircle];
    [self fetchValueForFirstCircle];
    [self fetchValueForThirdCircle];
    [self fetchValuesForGraph];
}

-(void)fetchValueForSecondCircle{
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSMutableArray *datavalue = [[NSMutableArray alloc]init];
    NSMutableArray *last45data = [[NSMutableArray alloc]init];
    BOOL effSet = NO;
    BOOL fuelCostSet = NO;
    BOOL fillUpsSet = NO;
    double currentEff = 0;
    if(fillUpArray.count>0){
        
        NSDateFormatter *formater=[[NSDateFormatter alloc] init];
        [formater setDateFormat:@"dd-MMM-yyyy"];
        
        //Last Month
        NSDate *today = [[NSDate alloc] init];
        NSCalendar *greg= [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *offsetComp = [[NSDateComponents alloc] init];
        [offsetComp setDay:-45];
        NSDate *last45thday = [greg dateByAddingComponents:offsetComp toDate:today options:0];
        NSString *startDate = [formater stringFromDate:last45thday];
        NSString *todaysDate = [formater stringFromDate:today];
        for(NSArray *fuelLog in fillUpArray)
        {
            if(([[formater dateFromString:startDate] compare:[formater dateFromString:[fuelLog valueForKey:@"date"]]] == NSOrderedAscending && [[formater dateFromString:todaysDate] compare:[formater dateFromString:[fuelLog valueForKey:@"date"]]] == NSOrderedDescending) || ([[formater dateFromString:startDate] compare:[formater dateFromString:[fuelLog valueForKey:@"date"]]] == NSOrderedSame) || ([[formater dateFromString:todaysDate] compare:[formater dateFromString:[fuelLog valueForKey:@"date"]]] == NSOrderedSame))
            {
                [datavalue addObject: fuelLog];
            }
        }
    }
        
    currentEff = 0;
    double fuelEff = 0;
    last45data = [[NSMutableArray alloc]initWithArray:datavalue];
    if(last45data.count>0){
        
        DashBoardViewController *dash = [[DashBoardViewController alloc] init];
        [dash fetchvalue:NSLocalizedString(@"graph_date_range_0", @"All Time")];
        
        [self fetchFromHereValue];
        
        for(NSArray *fuelData in fillUpArray){
            
            currentEff = [[fuelData valueForKey:@"eff"] doubleValue];
            fuelEff = fuelEff + currentEff;
            
        }
        
        if(avgfuelstat.count>0){
            
            fuelEff = [[avgfuelstat lastObject] doubleValue];
        }else{
            
            fuelEff = [[[def objectForKey:@"avgfuelstat"] lastObject] doubleValue];
        }
        
        circleColor2 = @"YellowColor";
        inCircleValue2 = fuelEff;
        underlineLabelValue2 = [NSString stringWithFormat:@"%@\n%@",NSLocalizedString(@"avg", @"Average"),self.con];
        effSet = YES;
        [def setInteger:1 forKey:@"inCircleValue2"];
    }
    
    if(fuelEff == 0){
        
        NSMutableArray *datavalue= [[NSMutableArray alloc]init];
        NSMutableArray *datavalue1 = [[NSMutableArray alloc]init];
        NSMutableArray *last60to30data = [[NSMutableArray alloc]init];
        NSMutableArray *last30data = [[NSMutableArray alloc]init];
        double fuelCostSum60 = 0;
        double currentCost = 0;
        if(fillUpArray.count>0){
            
            
            NSDateFormatter *formater=[[NSDateFormatter alloc] init];
            [formater setDateFormat:@"dd-MMM-yyyy"];
            
            //Last Month
            NSDate *today = [[NSDate alloc] init];
            NSCalendar *greg= [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            NSDateComponents *offsetComp = [[NSDateComponents alloc] init];
            [offsetComp setDay:-30];
            NSDate *last30thday = [greg dateByAddingComponents:offsetComp toDate:today options:0];
            
            
            NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
            [offsetComponents setDay:-60];
            NSDate *last60thday = [gregorian dateByAddingComponents:offsetComponents toDate:today options:0];
            
            NSString *startDate = [formater stringFromDate:last60thday];
            NSString *endDate = [formater stringFromDate:last30thday];
            NSString *todaysDate = [formater stringFromDate:today];
            
            for(NSArray *fuelLog in fillUpArray)
            {
                if(([[formater dateFromString:startDate] compare:[formater dateFromString:[fuelLog valueForKey:@"date"]]] == NSOrderedAscending && [[formater dateFromString:endDate] compare:[formater dateFromString:[fuelLog valueForKey:@"date"]]] == NSOrderedDescending) || ([[formater dateFromString:startDate] compare:[formater dateFromString:[fuelLog valueForKey:@"date"]]] == NSOrderedSame) || ([[formater dateFromString:endDate] compare:[formater dateFromString:[fuelLog valueForKey:@"date"]]] == NSOrderedSame))
                {
                    [datavalue addObject: fuelLog];
                }
            }
            
            last60to30data = [[NSMutableArray alloc]initWithArray:datavalue];
            if(last60to30data.count>0){
                
                
                for(NSArray *fuelData in last60to30data){
                    
                    currentCost = [[fuelData valueForKey:@"cost"] doubleValue];
                    fuelCostSum60 = fuelCostSum60 + currentCost;
                    
                }
                
            }
            
            for(NSArray *fuelLog in fillUpArray)
            {
                if(([[formater dateFromString:endDate] compare:[formater dateFromString:[fuelLog valueForKey:@"date"]]] == NSOrderedAscending && [[formater dateFromString:todaysDate] compare:[formater dateFromString:[fuelLog valueForKey:@"date"]]] == NSOrderedDescending) || ([[formater dateFromString:endDate] compare:[formater dateFromString:[fuelLog valueForKey:@"date"]]] == NSOrderedSame) || ([[formater dateFromString:todaysDate] compare:[formater dateFromString:[fuelLog valueForKey:@"date"]]] == NSOrderedSame))
                {
                    [datavalue1 addObject: fuelLog];
                }
            }
            
        }
        
        currentCost = 0;
        double fuelCostSum30 = 0;
        last30data = [[NSMutableArray alloc]initWithArray:datavalue1];
        if(last30data.count>0){
            
            
            for(NSArray *fuelData in last30data){
                
                currentCost = [[fuelData valueForKey:@"cost"] doubleValue];
                fuelCostSum30 = fuelCostSum30 + currentCost;
                
            }
            
        }
        
        if(last30data.count > 0 && fuelCostSum30 != 0){
            
            inCircleValue2 = fuelCostSum30;
            if(fuelCostSum60>0){
                
                double percentValue = fuelCostSum60*20/100;
                double minValue = fuelCostSum60 - percentValue;
                double maxValue = fuelCostSum60 + percentValue;
                
                if(fuelCostSum30 < minValue){
                    
                    circleColor2 = @"GreenColor";
                }else if(fuelCostSum30 > maxValue){
                    
                    circleColor2 = @"RedColor";
                }else{
                    
                    circleColor2 = @"YellowColor";
                }
            }else{
                
                circleColor2 = @"GreenColor";
            }
            
            underlineLabelValue2 = NSLocalizedString(@"fuel_cost_dashboard",@"Fuel cost in last 30 days");
            fuelCostSet = YES;
            [def setInteger:2 forKey:@"inCircleValue2"];
            
        }else if(last30data.count > 0 && fuelCostSum30 == 0){
            
            circleColor2 = @"YellowColor";
            inCircleValue2 = last30data.count;
            underlineLabelValue2 = NSLocalizedString(@"fill_ups_dashboard",@"Fill-ups in last 30 days");
            fillUpsSet = YES;
            [def setInteger:3 forKey:@"inCircleValue2"];
        }
        
    }
    if(tripArray.count > 0 && !effSet && !fuelCostSet && !fillUpsSet){
        
        NSMutableArray *datavalue3= [[NSMutableArray alloc]init];
        NSDateFormatter *formater=[[NSDateFormatter alloc] init];
        [formater setDateFormat:@"dd MM yyyy"];
        
        //Last Month
       // NSCalendar *calendar = [NSCalendar currentCalendar];
      //  NSDateComponents *components = [calendar components:NSCalendarUnitMonth|NSCalendarUnitDay fromDate:[NSDate date]];
        
        NSDate *today = [[NSDate alloc] init];
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
        [offsetComponents setDay:-30];
        NSDate *last30thday = [gregorian dateByAddingComponents:offsetComponents toDate:today options:0];
        
        //current year
       // NSDateFormatter *formater1=[[NSDateFormatter alloc] init];
       // [formater1 setDateFormat:@"yyyy"];
       // NSString *currentyear = [formater1 stringFromDate:[NSDate date]];
        
        //last year
        //NSDate *today1 = [[NSDate alloc] init];
        //NSCalendar *gregorian1 = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
       // NSDateComponents *offsetComponents1 = [[NSDateComponents alloc] init];
       // [offsetComponents1 setYear:-1];
       // NSDate *lastYear = [gregorian1 dateByAddingComponents:offsetComponents1 toDate:today1 options:0];
        
        
//        if(components.month!=12)
//        {
//            for(NSArray *tripLog in tripArray)
//            {
//                if((([last30thday compare:[tripLog valueForKey:@"arrDate"]] == NSOrderedAscending && [today compare:[tripLog valueForKey:@"arrDate"]] == NSOrderedDescending) || ([last30thday compare:[tripLog valueForKey:@"arrDate"]] == NSOrderedSame) || ([today compare:[tripLog valueForKey:@"arrDate"]] == NSOrderedSame)) && [[formater1 stringFromDate:[tripLog valueForKey:@"arrDate"]] isEqualToString:currentyear])
//                {
//                    [datavalue3 addObject: tripLog];
//                }
//            }
//
//        }
//
//        else
//        {
            for(NSArray *tripLog in tripArray)
            {
                if(([last30thday compare:[tripLog valueForKey:@"arrDate"]] == NSOrderedAscending && [today compare:[tripLog valueForKey:@"arrDate"]] == NSOrderedDescending) || ([last30thday compare:[tripLog valueForKey:@"arrDate"]] == NSOrderedSame) || ([today compare:[tripLog valueForKey:@"arrDate"]] == NSOrderedSame))  //&& [[formater1 stringFromDate:[tripLog valueForKey:@"arrDate"]] isEqualToString:[formater1 stringFromDate:lastYear]])
                {
                    [datavalue3 addObject: tripLog];
                }
            }
       // }
        
        last30TripArray = [[NSMutableArray alloc]initWithArray:datavalue3];
        double noOfTrips = 0;
        if(last30TripArray.count>0){
            
            noOfTrips = last30TripArray.count;
            circleColor2 = @"YellowColor";
            inCircleValue2 = noOfTrips;
            underlineLabelValue2 = NSLocalizedString(@"trips_dashboard",@"Trips in last 30 days");
            [def setInteger:4 forKey:@"inCircleValue2"];
        
        }else if(!effSet && !fuelCostSet && !fillUpsSet){
            
            circleColor2 = @"YellowColor";
            inCircleValue2 = 0;
            underlineLabelValue2 = [NSString stringWithFormat:@"Average\n%@",self.con];
        }
    }else if(!effSet && !fuelCostSet && !fillUpsSet){
        
        circleColor2 = @"YellowColor";
        inCircleValue2 = 0;
        underlineLabelValue2 = [NSString stringWithFormat:@"Average\n%@",self.con];
    }
    
}

-(void)fetchValueForFirstCircle{
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSInteger circleTwoValue = [def integerForKey:@"inCircleValue2"];
    NSMutableArray *datavalue= [[NSMutableArray alloc]init];
    NSMutableArray *datavalue1 = [[NSMutableArray alloc]init];
    BOOL taxSet = NO;
    BOOL fuelCostSet = NO;
    BOOL fillUpsSet = NO;
    double noOfTrips = 0;
    if(tripArray.count > 0){
        
        NSDateFormatter *formater=[[NSDateFormatter alloc] init];
        [formater setDateFormat:@"dd MM yyyy"];
        
        //Last Month
//        NSCalendar *calendar = [NSCalendar currentCalendar];
//        NSDateComponents *components = [calendar components:NSCalendarUnitMonth|NSCalendarUnitDay fromDate:[NSDate date]];
//
        NSDate *today = [[NSDate alloc] init];
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
        [offsetComponents setDay:-30];
        NSDate *last30thday = [gregorian dateByAddingComponents:offsetComponents toDate:today options:0];
        
//        //current year
//        NSDateFormatter *formater1=[[NSDateFormatter alloc] init];
//        [formater1 setDateFormat:@"yyyy"];
//        NSString *currentyear = [formater1 stringFromDate:[NSDate date]];
//
//        //last year
//        NSDate *today1 = [[NSDate alloc] init];
//        NSCalendar *gregorian1 = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
//        NSDateComponents *offsetComponents1 = [[NSDateComponents alloc] init];
//        [offsetComponents1 setYear:-1];
//        NSDate *lastYear = [gregorian1 dateByAddingComponents:offsetComponents1 toDate:today1 options:0];
        
        
//        if(components.month!=12)
//        {
            for(NSArray *tripLog in tripArray)
            {
                if((([last30thday compare:[tripLog valueForKey:@"arrDate"]] == NSOrderedAscending && [today compare:[tripLog valueForKey:@"arrDate"]] == NSOrderedDescending) || ([last30thday compare:[tripLog valueForKey:@"arrDate"]] == NSOrderedSame) || ([today compare:[tripLog valueForKey:@"arrDate"]] == NSOrderedSame))) //&& [[formater1 stringFromDate:[tripLog valueForKey:@"arrDate"]] isEqualToString:currentyear])
                {
                    [datavalue addObject: tripLog];
                }
            }
            
       // }
        
//        else
//        {
//            for(NSArray *tripLog in tripArray)
//            {
//                if((([last30thday compare:[tripLog valueForKey:@"arrDate"]] == NSOrderedAscending && [today compare:[tripLog valueForKey:@"arrDate"]] == NSOrderedDescending) || ([last30thday compare:[tripLog valueForKey:@"arrDate"]] == NSOrderedSame) || ([today compare:[tripLog valueForKey:@"arrDate"]] == NSOrderedSame)) && [[formater1 stringFromDate:[tripLog valueForKey:@"arrDate"]] isEqualToString:[formater1 stringFromDate:lastYear]])
//                {
//                    [datavalue addObject: tripLog];
//                }
//            }
//        }
    }
    
    last30TripArray = [[NSMutableArray alloc]initWithArray:datavalue];
    
    if(last30TripArray.count>0){
        
        double taxDedSum = 0;
        double currentTax = 0;
        for(NSArray *tripData in last30TripArray){
            
            currentTax = [[tripData valueForKey:@"cost"] doubleValue];
            taxDedSum = taxDedSum + currentTax;
            
        }
        if(taxDedSum != 0){
            
            inCircleValue1 = taxDedSum;
            circleColor1 = @"GreenColor";
            underlineLabelValue1 = NSLocalizedString(@"tax_ded_dashboard", @"Tax deductions in last 30 days");
            taxSet = YES;
            [def setInteger:1 forKey:@"inCircleValue1"];
        }else{
            
            noOfTrips = last30TripArray.count;
        }
        
        
   
    }else{
        
        NSMutableArray *last60to30data = [[NSMutableArray alloc]init];
        NSMutableArray *last30data = [[NSMutableArray alloc]init];
        double fuelCostSum60 = 0;
        double currentCost = 0;
        if(fillUpArray.count>0){
            
            
            NSDateFormatter *formater=[[NSDateFormatter alloc] init];
            [formater setDateFormat:@"dd-MMM-yyyy"];
            
            //Last Month
            NSDate *today = [[NSDate alloc] init];
            NSCalendar *greg= [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            NSDateComponents *offsetComp = [[NSDateComponents alloc] init];
            [offsetComp setDay:-30];
            NSDate *last30thday = [greg dateByAddingComponents:offsetComp toDate:today options:0];
            
            
            NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
            [offsetComponents setDay:-60];
            NSDate *last60thday = [gregorian dateByAddingComponents:offsetComponents toDate:today options:0];
            
            NSString *startDate = [formater stringFromDate:last60thday];
            NSString *endDate = [formater stringFromDate:last30thday];
            NSString *todaysDate = [formater stringFromDate:today];
            
            for(NSArray *fuelLog in fillUpArray)
            {
                if(([[formater dateFromString:startDate] compare:[formater dateFromString:[fuelLog valueForKey:@"date"]]] == NSOrderedAscending && [[formater dateFromString:endDate] compare:[formater dateFromString:[fuelLog valueForKey:@"date"]]] == NSOrderedDescending) || ([[formater dateFromString:startDate] compare:[formater dateFromString:[fuelLog valueForKey:@"date"]]] == NSOrderedSame) || ([[formater dateFromString:endDate] compare:[formater dateFromString:[fuelLog valueForKey:@"date"]]] == NSOrderedSame))
                {
                    [datavalue addObject: fuelLog];
                }
            }
            
            last60to30data = [[NSMutableArray alloc]initWithArray:datavalue];
            if(last60to30data.count>0){
                
                
                for(NSArray *fuelData in last60to30data){
                    
                    currentCost = [[fuelData valueForKey:@"cost"] doubleValue];
                    fuelCostSum60 = fuelCostSum60 + currentCost;
                    
                }
                
            }
            
            for(NSArray *fuelLog in fillUpArray)
            {
                if(([[formater dateFromString:endDate] compare:[formater dateFromString:[fuelLog valueForKey:@"date"]]] == NSOrderedAscending && [[formater dateFromString:todaysDate] compare:[formater dateFromString:[fuelLog valueForKey:@"date"]]] == NSOrderedDescending) || ([[formater dateFromString:endDate] compare:[formater dateFromString:[fuelLog valueForKey:@"date"]]] == NSOrderedSame) || ([[formater dateFromString:todaysDate] compare:[formater dateFromString:[fuelLog valueForKey:@"date"]]] == NSOrderedSame))
                {
                    [datavalue1 addObject: fuelLog];
                }
            }
            
        }
        
        currentCost = 0;
        double fuelCostSum30 = 0;
        last30data = [[NSMutableArray alloc]initWithArray:datavalue1];
        if(last30data.count>0){
            
            
            for(NSArray *fuelData in last30data){
                
                currentCost = [[fuelData valueForKey:@"cost"] doubleValue];
                fuelCostSum30 = fuelCostSum30 + currentCost;
                
            }
            
         }
        
        if(last30data.count > 0 && fuelCostSum30 != 0 && circleTwoValue != 2){
            
            inCircleValue1 = fuelCostSum30;
            double percentValue = fuelCostSum60*20/100;
            double minValue = fuelCostSum60 - percentValue;
            double maxValue = fuelCostSum60 + percentValue;
            
            if(fuelCostSum30 < minValue){
                
                circleColor1 = @"GreenColor";
            }else if(fuelCostSum30 > maxValue){
                
                circleColor1 = @"RedColor";
            }else{
                
                circleColor1 = @"YellowColor";
            }
            
            underlineLabelValue1 = NSLocalizedString(@"fuel_cost_dashboard",@"Fuel cost in last 30 days");
            fuelCostSet = YES;
            [def setInteger:2 forKey:@"inCircleValue1"];
            
        }else if(last30data.count > 0 && fuelCostSum30 == 0 && circleTwoValue != 3){
            
            circleColor1 = @"YellowColor";
            inCircleValue1 = last30data.count;
            underlineLabelValue1 = NSLocalizedString(@"fill_ups_dashboard",@"Fill-ups in last 30 days");
            fillUpsSet = YES;
            [def setInteger:3 forKey:@"inCircleValue1"];
        }
        
    }
    
    if(noOfTrips > 0 && !taxSet && !fuelCostSet && !fillUpsSet && circleTwoValue != 4){
        
        circleColor1 = @"YellowColor";
        inCircleValue1 = noOfTrips;
        underlineLabelValue1 = NSLocalizedString(@"trips_dashboard",@"Trips in last 30 days");
        [def setInteger:4 forKey:@"inCircleValue1"];
        
    }else if(!taxSet && !fuelCostSet && !fillUpsSet){
        
        circleColor1 = @"GreenColor";
        inCircleValue1 = 0;
        underlineLabelValue1 = NSLocalizedString(@"tax_deductions", @"Tax deductions");
    }
    
    
}

-(void)fetchValueForThirdCircle{
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSInteger circleTwoValue = [def integerForKey:@"inCircleValue2"];
    NSInteger circleOneValue = [def integerForKey:@"inCircleValue1"];
    int vehId = [[[NSUserDefaults standardUserDefaults] objectForKey:@"fillupid"] intValue];
    NSMutableDictionary *getDict = [[NSMutableDictionary alloc]init];;
    getDict = [self checkRemindersToSend:vehId];
    
    reminderKeys = [[NSMutableArray alloc] init];
    reminderPercentages = [[NSMutableArray alloc] init];
    reminderValues = [[NSMutableArray alloc] init];
    NSMutableArray *bigArray = [[NSMutableArray alloc]init];
    NSArray *keysArrays = [getDict allKeys];
    [bigArray addObject:[getDict allValues]];
    
    if(keysArrays.count>1 && bigArray.count>1){

        for(int i=0;i<2;i++){

            if([[[bigArray firstObject] objectAtIndex:i] valueForKey:@"percentage"] != nil && [[[bigArray firstObject] objectAtIndex:i] valueForKey:@"value"] != nil){
                
                [reminderKeys addObject:[keysArrays objectAtIndex:i]];
                [reminderPercentages addObject: [[[bigArray firstObject] objectAtIndex:i] valueForKey:@"percentage"]];
                [reminderValues addObject:[[[bigArray firstObject] objectAtIndex:i] valueForKey:@"value"]];
            }

        }
        
        if([[reminderPercentages objectAtIndex:0] doubleValue] < [[reminderPercentages objectAtIndex:1] doubleValue]){
            
            NSArray* reversedReminderKeys = [[reminderKeys reverseObjectEnumerator] allObjects];
            NSArray* reversedPercentages = [[reminderPercentages reverseObjectEnumerator] allObjects];
            NSArray* reversedReminderValues = [[reminderValues reverseObjectEnumerator] allObjects];
            reminderPercentages = [[NSMutableArray alloc] initWithArray:reversedPercentages];
            reminderKeys = [[NSMutableArray alloc] initWithArray:reversedReminderKeys];
            reminderValues = [[NSMutableArray alloc] initWithArray:reversedReminderValues];
            //NSLog(@"reminderKeys:- %@reminderPercentages:- %@reminderValues:- %@",reminderKeys,reminderPercentages,reminderValues);
        }
        
    }else if(keysArrays.count == 1 && bigArray.count == 1){
        
        [reminderKeys addObject:[keysArrays firstObject]];
        [reminderPercentages addObject: [[[bigArray firstObject] firstObject] valueForKey:@"percentage"]];
        [reminderValues addObject:[[[bigArray firstObject] firstObject] valueForKey:@"value"]];
    }
    
    int overdue = 0;
    int upcoming = 0;
    
    
    for(int i=0;i<reminderPercentages.count;i++){
        
        if([reminderPercentages[i] intValue] > 99){
            
            overdue = overdue + 1;
        
        }else if([reminderPercentages[i] intValue] > 75){
            
            upcoming = upcoming + 1;
        }
        
        
    }
    
    if(overdue > 0){
        
        inCircleValue3 = overdue;
        circleColor3 = @"RedColor";
        if(overdue > 1){
            underlineLabelValue3 = NSLocalizedString(@"overdues_dashboard", @"Overdue reminders");
        }else{
            underlineLabelValue3 = NSLocalizedString(@"overdue_dashboard", @"Overdue reminder");
        }
        
    }else if(upcoming > 0){
        
        inCircleValue3 = upcoming;
        circleColor3 = @"YellowColor";
        if(upcoming > 1){
            underlineLabelValue3 = NSLocalizedString(@"upcomings_dashboard", @"Upcoming reminders");
        }else{
            underlineLabelValue3 = NSLocalizedString(@"upcoming_dashboard", @"Upcoming reminder");
        }

    }else{
        
        if(serviceArray.count > 0){
            
            NSMutableArray *datavalue= [[NSMutableArray alloc]init];
            NSDateFormatter *formater=[[NSDateFormatter alloc] init];
            [formater setDateFormat:@"dd-MM-yyyy"];
            
            //Last Month
            //NSCalendar *calendar = [NSCalendar currentCalendar];
            //NSDateComponents *components = [calendar components:NSCalendarUnitMonth|NSCalendarUnitDay fromDate:[NSDate date]];
            
            NSDate *today = [[NSDate alloc] init];
            NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
            [offsetComponents setDay:-30];
            NSDate *last30thday = [gregorian dateByAddingComponents:offsetComponents toDate:today options:0];
            
            //current year
            //NSDateFormatter *formater1=[[NSDateFormatter alloc] init];
            //[formater1 setDateFormat:@"yyyy"];
            //NSString *currentyear = [formater1 stringFromDate:[NSDate date]];
            
            //last year
            //NSDate *today1 = [[NSDate alloc] init];
            ///NSCalendar *gregorian1 = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            //NSDateComponents *offsetComponents1 = [[NSDateComponents alloc] init];
            //[offsetComponents1 setYear:-1];
           // NSDate *lastyear = [gregorian1 dateByAddingComponents:offsetComponents1 toDate:today1 options:0];
           // NSString *lastYear = [formater1 stringFromDate:lastyear];
            NSString *startDate = [formater stringFromDate:last30thday];
            NSString *todaysDate = [formater stringFromDate:today];
            
//            if(components.month!=12)
//            {
                for(NSArray *serviceLog in serviceArray)
                {
                    if((([[formater dateFromString:startDate] compare:[formater dateFromString:[serviceLog valueForKey:@"date"]]] == NSOrderedAscending && [[formater dateFromString:todaysDate] compare:[formater dateFromString:[serviceLog valueForKey:@"date"]]] == NSOrderedDescending) || ([[formater dateFromString:startDate] compare:[formater dateFromString:[serviceLog valueForKey:@"date"]]] == NSOrderedSame) || ([[formater dateFromString:todaysDate] compare:[formater dateFromString:[serviceLog valueForKey:@"date"]]] == NSOrderedSame))) //&& [[formater1 stringFromDate:[formater dateFromString:[serviceLog valueForKey:@"date"]]] isEqualToString:currentyear])
                    {
                        [datavalue addObject: serviceLog];
                    }
                    
                }
                
//            }
//
//            else
//            {
//                for(NSArray *serviceLog in serviceArray)
//                {
//                    if((([[formater dateFromString:startDate] compare:[formater dateFromString:[serviceLog valueForKey:@"date"]]] == NSOrderedAscending && [[formater dateFromString:todaysDate] compare:[formater dateFromString:[serviceLog valueForKey:@"date"]]] == NSOrderedDescending) || ([[formater dateFromString:startDate] compare:[formater dateFromString:[serviceLog valueForKey:@"date"]]] == NSOrderedSame) || ([[formater dateFromString:todaysDate] compare:[formater dateFromString:[serviceLog valueForKey:@"date"]]] == NSOrderedSame)) && [[formater1 stringFromDate:[formater dateFromString:[serviceLog valueForKey:@"date"]]] isEqualToString:lastYear])
//                    {
//                        [datavalue addObject: serviceLog];
//                    }
//                }
//            }
            last30ServiceArray = [[NSMutableArray alloc]initWithArray:datavalue];
        }
        
        
        double noOfServices = 0;
        if(last30ServiceArray.count>0){
            
            noOfServices = last30ServiceArray.count;
            circleColor3 = @"YellowColor";
            inCircleValue3 = noOfServices;
            underlineLabelValue3 = NSLocalizedString(@"services_dashboard", @"Services in last 30 days");
            
        }else{
            
            if(expenseArray.count > 0){
                
                NSMutableArray *datavalue= [[NSMutableArray alloc]init];
                NSDateFormatter *formater=[[NSDateFormatter alloc] init];
                [formater setDateFormat:@"dd-MM-yyyy"];
                
                //Last Month
                //NSCalendar *calendar = [NSCalendar currentCalendar];
                //NSDateComponents *components = [calendar components:NSCalendarUnitMonth|NSCalendarUnitDay fromDate:[NSDate date]];
                
                NSDate *today = [[NSDate alloc] init];
                NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
                NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
                [offsetComponents setDay:-30];
                NSDate *last30thday = [gregorian dateByAddingComponents:offsetComponents toDate:today options:0];
                
                //current year
                //NSDateFormatter *formater1=[[NSDateFormatter alloc] init];
                //[formater1 setDateFormat:@"yyyy"];
                //NSString *currentyear = [formater1 stringFromDate:[NSDate date]];
                
                //last year
                //NSDate *today1 = [[NSDate alloc] init];
                //NSCalendar *gregorian1 = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
                //NSDateComponents *offsetComponents1 = [[NSDateComponents alloc] init];
                //[offsetComponents1 setYear:-1];
                //NSDate *lastyear = [gregorian1 dateByAddingComponents:offsetComponents1 toDate:today1 options:0];
               // NSString *lastYear = [formater1 stringFromDate:lastyear];
                NSString *startDate = [formater stringFromDate:last30thday];
                NSString *todaysDate = [formater stringFromDate:today];
                
//                if(components.month!=12)
//                {
                    for(NSArray *expenseLog in expenseArray)
                    {
                        if((([[formater dateFromString:startDate] compare:[formater dateFromString:[expenseLog valueForKey:@"date"]]] == NSOrderedAscending && [[formater dateFromString:todaysDate] compare:[formater dateFromString:[expenseLog valueForKey:@"date"]]] == NSOrderedDescending) || ([[formater dateFromString:startDate] compare:[formater dateFromString:[expenseLog valueForKey:@"date"]]] == NSOrderedSame) || ([[formater dateFromString:todaysDate] compare:[formater dateFromString:[expenseLog valueForKey:@"date"]]] == NSOrderedSame))) //&& [[formater1 stringFromDate:[formater dateFromString:[expenseLog valueForKey:@"date"]]] isEqualToString:currentyear])
                        {
                            [datavalue addObject: expenseLog];
                        }
                        
                    }
                    
//                }
//
//                else
//                {
//                    for(NSArray *expenseLog in expenseArray)
//                    {
//                        if((([[formater dateFromString:startDate] compare:[formater dateFromString:[expenseLog valueForKey:@"date"]]] == NSOrderedAscending && [[formater dateFromString:todaysDate] compare:[formater dateFromString:[expenseLog valueForKey:@"date"]]] == NSOrderedDescending) || ([[formater dateFromString:startDate] compare:[formater dateFromString:[expenseLog valueForKey:@"date"]]] == NSOrderedSame) || ([[formater dateFromString:todaysDate] compare:[formater dateFromString:[expenseLog valueForKey:@"date"]]] == NSOrderedSame)) && [[formater1 stringFromDate:[formater dateFromString:[expenseLog valueForKey:@"date"]]] isEqualToString:lastYear])
//                        {
//                            [datavalue addObject: expenseLog];
//                        }
//                    }
//                }
                last30ExpenseArray = [[NSMutableArray alloc]initWithArray:datavalue];
            }
            
            
            double noOfExpenses = 0;
            if(last30ExpenseArray.count>0){
                
                noOfExpenses = last30ExpenseArray.count;
                circleColor3 = @"YellowColor";
                inCircleValue3 = noOfExpenses;
                underlineLabelValue3 = NSLocalizedString(@"expenses_30_days", @"Expenses in last 30 days");
                
            }else{
                
                NSMutableArray *datavalue= [[NSMutableArray alloc]init];
                NSMutableArray *datavalue1 = [[NSMutableArray alloc]init];
                NSMutableArray *last60to30data = [[NSMutableArray alloc]init];
                NSMutableArray *last30data = [[NSMutableArray alloc]init];
                double fuelCostSum60 = 0;
                double currentCost = 0;
                BOOL fuelCostSet = NO;
                BOOL fillUpsSet = NO;
                if(fillUpArray.count>0 ){
                    
                    NSDateFormatter *formater=[[NSDateFormatter alloc] init];
                    [formater setDateFormat:@"dd-MMM-yyyy"];
                    
                    //Last Month
                    NSDate *today = [[NSDate alloc] init];
                    NSCalendar *greg= [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
                    NSDateComponents *offsetComp = [[NSDateComponents alloc] init];
                    [offsetComp setDay:-30];
                    NSDate *last30thday = [greg dateByAddingComponents:offsetComp toDate:today options:0];
                    
                    
                    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
                    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
                    [offsetComponents setDay:-60];
                    NSDate *last60thday = [gregorian dateByAddingComponents:offsetComponents toDate:today options:0];
                    
                    NSString *startDate = [formater stringFromDate:last60thday];
                    NSString *endDate = [formater stringFromDate:last30thday];
                    NSString *todaysDate = [formater stringFromDate:today];
                    
                    for(NSArray *fuelLog in fillUpArray)
                    {
                        if(([[formater dateFromString:startDate] compare:[formater dateFromString:[fuelLog valueForKey:@"date"]]] == NSOrderedAscending && [[formater dateFromString:endDate] compare:[formater dateFromString:[fuelLog valueForKey:@"date"]]] == NSOrderedDescending) || ([[formater dateFromString:startDate] compare:[formater dateFromString:[fuelLog valueForKey:@"date"]]] == NSOrderedSame) || ([[formater dateFromString:endDate] compare:[formater dateFromString:[fuelLog valueForKey:@"date"]]] == NSOrderedSame))
                        {
                            [datavalue addObject: fuelLog];
                        }
                    }
                    
                    last60to30data = [[NSMutableArray alloc]initWithArray:datavalue];
                    if(last60to30data.count>0){
                        
                        
                        for(NSArray *fuelData in last60to30data){
                            
                            currentCost = [[fuelData valueForKey:@"cost"] doubleValue];
                            fuelCostSum60 = fuelCostSum60 + currentCost;
                            
                        }
                        
                    }
                    
                    for(NSArray *fuelLog in fillUpArray)
                    {
                        if(([[formater dateFromString:endDate] compare:[formater dateFromString:[fuelLog valueForKey:@"date"]]] == NSOrderedAscending && [[formater dateFromString:todaysDate] compare:[formater dateFromString:[fuelLog valueForKey:@"date"]]] == NSOrderedDescending) || ([[formater dateFromString:endDate] compare:[formater dateFromString:[fuelLog valueForKey:@"date"]]] == NSOrderedSame) || ([[formater dateFromString:todaysDate] compare:[formater dateFromString:[fuelLog valueForKey:@"date"]]] == NSOrderedSame))
                        {
                            [datavalue1 addObject: fuelLog];
                        }
                    }
                }
                
                currentCost = 0;
                double fuelCostSum30 = 0;
                last30data = [[NSMutableArray alloc]initWithArray:datavalue1];
                if(last30data.count>0){
                    
                    
                    for(NSArray *fuelData in last30data){
                        
                        currentCost = [[fuelData valueForKey:@"cost"] doubleValue];
                        fuelCostSum30 = fuelCostSum30 + currentCost;
                        
                    }
                    
                }
                
                if(last30data.count > 0 && fuelCostSum30 != 0 && circleTwoValue != 2 && circleOneValue != 2){
                    
                    inCircleValue3 = fuelCostSum30;
                    if(fuelCostSum60>0){
                        
                        double percentValue = fuelCostSum60*20/100;
                        double minValue = fuelCostSum60 - percentValue;
                        double maxValue = fuelCostSum60 + percentValue;
                        
                        if(fuelCostSum30 < minValue){
                            
                            circleColor3 = @"GreenColor";
                        }else if(fuelCostSum30 > maxValue){
                            
                            circleColor3 = @"RedColor";
                        }else{
                            
                            circleColor3 = @"YellowColor";
                        }
                    }else{
                        
                        circleColor3 = @"GreenColor";
                    }
                    
                    
                    underlineLabelValue3 = NSLocalizedString(@"fuel_cost_dashboard",@"Fuel cost in last 30 days");
                    fuelCostSet = YES;
                    
                }else if(last30data.count > 0 && circleTwoValue != 3 && circleOneValue != 3){
                    
                    circleColor3 = @"YellowColor";
                    inCircleValue3 = last30data.count;
                    underlineLabelValue3 = NSLocalizedString(@"fill_ups_dashboard",@"Fill-ups in last 30 days");
                    fillUpsSet = YES;
                }
           
                if(tripArray.count > 0 && !fuelCostSet && !fillUpsSet && circleTwoValue != 4 && circleOneValue != 4){
                
                NSMutableArray *datavalue3= [[NSMutableArray alloc]init];
                NSDateFormatter *formater=[[NSDateFormatter alloc] init];
                [formater setDateFormat:@"dd MM yyyy"];
                
                //Last Month
//                NSCalendar *calendar = [NSCalendar currentCalendar];
//                NSDateComponents *components = [calendar components:NSCalendarUnitMonth|NSCalendarUnitDay fromDate:[NSDate date]];
                
                NSDate *today = [[NSDate alloc] init];
                NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
                NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
                [offsetComponents setDay:-30];
                NSDate *last30thday = [gregorian dateByAddingComponents:offsetComponents toDate:today options:0];
                
                //current year
//                NSDateFormatter *formater1=[[NSDateFormatter alloc] init];
//                [formater1 setDateFormat:@"yyyy"];
//                NSString *currentyear = [formater1 stringFromDate:[NSDate date]];
//
                //last year
//                NSDate *today1 = [[NSDate alloc] init];
//                NSCalendar *gregorian1 = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
//                NSDateComponents *offsetComponents1 = [[NSDateComponents alloc] init];
//                [offsetComponents1 setYear:-1];
//                NSDate *lastYear = [gregorian1 dateByAddingComponents:offsetComponents1 toDate:today1 options:0];
                
                
//                if(components.month!=12)
//                {
                    for(NSArray *tripLog in tripArray)
                    {
                        if((([last30thday compare:[tripLog valueForKey:@"arrDate"]] == NSOrderedAscending && [today compare:[tripLog valueForKey:@"arrDate"]] == NSOrderedDescending) || ([last30thday compare:[tripLog valueForKey:@"arrDate"]] == NSOrderedSame) || ([today compare:[tripLog valueForKey:@"arrDate"]] == NSOrderedSame))) //&& [[formater1 stringFromDate:[tripLog valueForKey:@"arrDate"]] isEqualToString:currentyear])
                        {
                            [datavalue3 addObject: tripLog];
                        }
                    }
                    
//                }
//
//                else
//                {
//                    for(NSArray *tripLog in tripArray)
//                    {
//                        if((([last30thday compare:[tripLog valueForKey:@"arrDate"]] == NSOrderedAscending && [today compare:[tripLog valueForKey:@"arrDate"]] == NSOrderedDescending) || ([last30thday compare:[tripLog valueForKey:@"arrDate"]] == NSOrderedSame) || ([today compare:[tripLog valueForKey:@"arrDate"]] == NSOrderedSame)) && [[formater1 stringFromDate:[tripLog valueForKey:@"arrDate"]] isEqualToString:[formater1 stringFromDate:lastYear]])
//                        {
//                            [datavalue3 addObject: tripLog];
//                        }
//                    }
//                }
                
                last30TripArray = [[NSMutableArray alloc]initWithArray:datavalue3];
                double noOfTrips = 0;
                if(last30TripArray.count>0){
                    
                    noOfTrips = last30TripArray.count;
                    circleColor3 = @"YellowColor";
                    inCircleValue3 = noOfTrips;
                    underlineLabelValue3 = NSLocalizedString(@"trips_dashboard",@"Trips in last 30 days");
                    
                }
                }else if(!fuelCostSet && !fillUpsSet && circleTwoValue != 4 && circleOneValue != 4){
                    
                    circleColor3 = @"GreenColor";
                    inCircleValue3 = 0;
                    underlineLabelValue3 = NSLocalizedString(@"upcomings_dashboard", @"Upcoming reminders");
                    
                }

            }
        }
        }
    
}

-(void)fetchValuesForGraph{
    
    NSMutableArray *datavalue = [[NSMutableArray alloc]init];
    NSMutableArray *last30data = [[NSMutableArray alloc]init];
    xDataPoints = [[NSMutableArray alloc]init];
    yGraphValues = [[NSMutableArray alloc]init];
    if(fillUpArray.count > 0){
        
        NSDateFormatter *formater=[[NSDateFormatter alloc] init];
        [formater setDateFormat:@"dd-MMM-yyyy"];
        
        //Last Month
        NSDate *today = [[NSDate alloc] init];
        NSCalendar *greg= [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *offsetComp = [[NSDateComponents alloc] init];
        [offsetComp setDay: -30];
        NSDate *last30thday = [greg dateByAddingComponents:offsetComp toDate:today options:0];
        NSString *startDate = [formater stringFromDate:last30thday];
        NSString *todaysDate = [formater stringFromDate:today];
        for(NSArray *fuelLog in fillUpArray)
        {
            if(([[formater dateFromString:startDate] compare:[formater dateFromString:[fuelLog valueForKey:@"date"]]] == NSOrderedAscending && [[formater dateFromString:todaysDate] compare:[formater dateFromString:[fuelLog valueForKey:@"date"]]] == NSOrderedDescending) || ([[formater dateFromString:startDate] compare:[formater dateFromString:[fuelLog valueForKey:@"date"]]] == NSOrderedSame) || ([[formater dateFromString:todaysDate] compare:[formater dateFromString:[fuelLog valueForKey:@"date"]]] == NSOrderedSame))
            {
                //NSLog(@"%@",fuelLog);
                [datavalue addObject: fuelLog];
            }else{

                //NSLog(@"%@",fuelLog);
            }
        }
    }
    
    last30data = [[NSMutableArray alloc]initWithArray:datavalue];
    if(last30data.count > 0){

        NSMutableArray *topFiveRecords = [[NSMutableArray alloc]init];
        if(last30data.count > 5){

            for(int i=0;i<5;i++){

                [topFiveRecords addObject:[last30data objectAtIndex:i]];
            }

        }else{

            topFiveRecords = [[NSMutableArray alloc]initWithArray:last30data];
        }
        NSArray* reversedArray = [[topFiveRecords reverseObjectEnumerator] allObjects];
        NSString *dateValue = [[NSString alloc] init];
        

//        if(reversedArray.count > 5){
//
//            for(int i=0;i<5;i++){
//
//                [topFiveRecords addObject:[reversedArray objectAtIndex:i]];
//            }
//
//        }else{
//
//            topFiveRecords = [[NSMutableArray alloc]initWithArray:reversedArray];
//        }

        if(reversedArray.count>0){
            
            for(NSArray *fuelData in reversedArray){
                
                dateValue = [[fuelData valueForKey:@"date"] substringToIndex:6];
                //CLSLog(@"dateValue for fillup value:-%@",dateValue);
               // CLS_LOG(@"dateValue for trip value:-%@",dateValue);
                if(dateValue){
                    [xDataPoints addObject:dateValue];
                    [yGraphValues addObject:[fuelData valueForKey:@"eff"]];
                }
                
            }
            if(yGraphValues.count>1){
                hideGraph = NO;
            }else{
                hideGraph = YES;
            }
            
            chartUnderLabel = self.con;
        }
        
    }else if(tripArray.count > 0){
        
        NSMutableArray *sortedTrip = [[NSMutableArray alloc]init];
        NSArray *highOdoArray = [ NSArray arrayWithArray:tripArray];
        
        highOdoArray = [highOdoArray sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {

            NSDate *d1 = obj1[@"arrDate"];
            NSDate *d2 = obj2[@"arrDate"];
            
                return [d1 compare:d2]; //ascending
        }];
        
        sortedTrip = [highOdoArray mutableCopy];
        NSMutableArray *topFiveTripRecords = [[NSMutableArray alloc]init];
        
        if(sortedTrip.count>0){
            
            if(sortedTrip.count > 5){
                
                for(int i=0;i<5;i++){
                    
                    [topFiveTripRecords addObject:[sortedTrip objectAtIndex:i]];
                }
                
            }else{
                
                topFiveTripRecords = [[NSMutableArray alloc]initWithArray:sortedTrip];
            }
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"dd-MMM-yyyy"];
                                     //tripArray
            for(NSArray *tripData in topFiveTripRecords){
                
                NSString *date = [[NSString alloc]init];
                date = [formatter stringFromDate:[tripData valueForKey:@"arrDate"]];
               // CLSLog(@"dateValue for trip value:-%@",date);
               // CLS_LOG(@"dateValue for trip value:-%@",date);
                if(date){
                    
                    [xDataPoints addObject:[date substringToIndex:6]];
                    [yGraphValues addObject:[tripData valueForKey:@"cost"]];
                }
                
            }
        }
        
        if(yGraphValues.count>1){
            hideGraph = NO;
        }else{
            hideGraph = YES;
        }
        chartUnderLabel = NSLocalizedString(@"tax_deductions", @"Tax deductions");
        
    }else{
        
        hideGraph = YES;
    }
}

-(NSMutableDictionary *)checkRemindersToSend:(int )vehID{
    
    NSManagedObjectContext *context = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSError *error;
    NSFetchRequest *vehreq = [[NSFetchRequest alloc] initWithEntityName:@"Services_Table"];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"dueMiles" ascending:NO];
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"dueDays" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor,sortDescriptor1, nil];
    [vehreq setSortDescriptors:sortDescriptors];
    NSArray *serviceArray = [context executeFetchRequest:vehreq error:&error];
    
    NSMutableArray *serviceRecordsArray = [[NSMutableArray alloc]init];
    NSMutableArray *percentArray = [[NSMutableArray alloc]init];
    NSMutableDictionary *toSendDict = [[NSMutableDictionary alloc]init];
    NSMutableDictionary *dataDict = [[NSMutableDictionary alloc]init];
    NSString *givenVehID = [NSString stringWithFormat:@"%d",vehID];
    float dueMiles;
    NSInteger dueDays;
    
    for(Services_Table *services in serviceArray){
        
        dueMiles = [services.dueMiles floatValue];
        dueDays = [services.dueDays integerValue];
        
        if([services.vehid isEqualToString:givenVehID] && (dueMiles > 0 || dueDays > 0)){
            
            [serviceRecordsArray addObject:services];
            
        }
    }
    
    NSMutableArray *topFiveRecords = [[NSMutableArray alloc]init];
    NSMutableArray *toSendFiveRecords = [[NSMutableArray alloc]init];
    if(serviceRecordsArray.count > 5){
        
        for(int i=0;i<5;i++){
            
            [topFiveRecords addObject:[serviceRecordsArray objectAtIndex:i]];
        }
        
    }else{
        
        topFiveRecords = serviceRecordsArray;
    }
    
    for(Services_Table *topfive in topFiveRecords){
        
        [toSendFiveRecords addObject:topfive];
    }
    
    percentArray = [self progressValue:toSendFiveRecords:vehID];
    
    NSString *unit;
    
    if([[[NSUserDefaults standardUserDefaults]objectForKey:@"dist_unit"] isEqualToString:NSLocalizedString(@"disp_miles", @"Miles")])
    {
        unit = NSLocalizedString(@"mi", @"mi");
    }
    
    else
    {
        unit = NSLocalizedString(@"kms", @"km");
    }
    
    NSMutableArray *singleArray = [[NSMutableArray alloc]init];
    for(int i=0;i<percentArray.count;i++){
        
        singleArray = [percentArray objectAtIndex:i];
        NSDateFormatter *formater=[[NSDateFormatter alloc] init];
        [formater setDateFormat:@"dd-MMM-yyyy"];
        NSDate *lastdate = [singleArray valueForKey:@"lastDate"];
        NSInteger dueDays =[[singleArray valueForKey:@"dueDays"] integerValue];
        NSDate* dueDate  = [lastdate dateByAddingTimeInterval:(24*3600)*dueDays];
        
        
        if([[singleArray valueForKey:@"dueMiles"] longValue] != 0 && [[singleArray valueForKey:@"dueDays"] longValue] != 0){
            
            [formater setDateFormat:@"MMM-dd-yyyy"];
            NSString *dateString = [formater stringFromDate:dueDate];
            NSString *toDateString = [NSString stringWithFormat:@"%ld%@ /%@", [[singleArray valueForKey:@"dueMiles"]integerValue] + [[singleArray valueForKey:@"lastOdo"]integerValue],unit,dateString];
            [toSendDict setObject:toDateString forKey:@"value"];
        }else if([[singleArray valueForKey:@"dueMiles"] longValue] == 0 && [[singleArray valueForKey:@"dueDays"] longValue] != 0){
            
            [formater setDateFormat:@"MMM-dd-yyyy"];
            NSString *dateString = [formater stringFromDate:dueDate];
            NSString *toDateString = [NSString stringWithFormat:@"%@",dateString];
            [toSendDict setObject:toDateString forKey:@"value"];
        }else if([[singleArray valueForKey:@"dueMiles"] longValue] != 0 && [[singleArray valueForKey:@"dueDays"] longValue] == 0){
            
            NSString *toDateString = [NSString stringWithFormat:@"%ld%@", [[singleArray valueForKey:@"dueMiles"]integerValue] + [[singleArray valueForKey:@"lastOdo"]integerValue],unit];
            [toSendDict setObject:toDateString forKey:@"value"];
        }
        
        NSString *percentage = [NSString stringWithFormat:@"%0.f",[[singleArray valueForKey:@"progress"]floatValue] *100];
        [toSendDict setObject:percentage forKey:@"percentage"];
        NSMutableDictionary *copyToSendDict = [[NSMutableDictionary alloc]initWithDictionary:toSendDict];
        [dataDict setObject:copyToSendDict forKey:[singleArray valueForKey:@"serviceName"]];
        
        [toSendDict removeAllObjects];
    }
    
    return dataDict;
}

-(NSMutableArray *)progressValue:(NSMutableArray *)topFiveArray :(int)vehID{
    
    NSMutableArray *sortArray = [[NSMutableArray alloc]init];
    NSMutableArray *toReturnSortedArray = [[NSMutableArray alloc]init];
    float maxOdo;
    for (int i=0;i<topFiveArray.count;i++){
        
        NSMutableDictionary *toSortdict = [[NSMutableDictionary alloc] init];
        NSMutableDictionary *sortedDict = [[NSMutableDictionary alloc] init];
        
        NSString *serviceName;
        toSortdict = [topFiveArray objectAtIndex:i];
        
        serviceName = [toSortdict valueForKey:@"serviceName"];
        [sortedDict setValue:serviceName forKey:@"serviceName"];
        [sortedDict setValue:[toSortdict valueForKey:@"dueDays"] forKey:@"dueDays"];
        [sortedDict setValue:[toSortdict valueForKey:@"dueMiles"] forKey:@"dueMiles"];
        [sortedDict setValue:[toSortdict valueForKey:@"lastOdo"] forKey:@"lastOdo"];
        [sortedDict setValue:[toSortdict valueForKey:@"lastDate"] forKey:@"lastDate"];
        
        NSArray *fuelLastRecord = [fillUpArray firstObject];
        NSArray *ServiceLastRecord = [serviceArray firstObject];
        float maxOdo1;
        float maxOdo2;
        
        maxOdo1 = [[fuelLastRecord valueForKey:@"odo"] floatValue];
        maxOdo2 = [[ServiceLastRecord valueForKey:@"odo"] floatValue];
        if(maxOdo1 > maxOdo2){
            maxOdo = maxOdo1;
        }else{
            maxOdo = maxOdo2;
        }
        
        NSDateFormatter *formater=[[NSDateFormatter alloc] init];
        [formater setDateFormat:@"dd-MMM-yyyy"];
        
        NSDate *lastdate = [toSortdict valueForKey:@"lastDate"];
        float lastMilesInt= [[toSortdict valueForKey:@"lastOdo"]integerValue];
        NSInteger dueDays =[[toSortdict valueForKey:@"dueDays"] integerValue];
        float dueMiles = [[toSortdict valueForKey:@"dueMiles"]integerValue];
        
        //for ProgressBar
        float y = 0.000f;
        float z = 0.000f;
        if (dueMiles > 0 || dueDays > 0 ) {
            
            float diffToday = maxOdo -lastMilesInt;
            
            NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            NSDateComponents *components = [gregorianCalendar components:NSCalendarUnitDay
                                                                fromDate:lastdate
                                                                  toDate:[NSDate date]
                                                                 options:NSCalendarWrapComponents];
            
            NSInteger diffDay = [components day];
            float progressDay = dueDays > 0 ? (float) diffDay/dueDays : 0;
            float progressMiles = dueMiles > 0 ? (float) diffToday/dueMiles : 0;
            
            y = progressDay > progressMiles ? progressDay : progressMiles;
            
            [sortedDict setValue:[NSNumber numberWithFloat:y] forKey:@"progress"];
            [sortArray addObject:sortedDict];
        }else{
            [sortedDict setValue:[NSNumber numberWithFloat:z] forKey:@"progress"];
            [sortArray addObject:sortedDict];
        }
        
    }
    
    [toReturnSortedArray addObjectsFromArray: sortArray];
    [toReturnSortedArray sortUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"progress" ascending:NO], nil]];
    return toReturnSortedArray;
}

-(CGSize)checkIfiPhoneX
{
    CGSize sizeValue;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        CGSize screenSize = [[UIScreen mainScreen] bounds].size;
        sizeValue = screenSize;
    }
    return sizeValue;
}

- (IBAction)vehButton:(UIButton *)sender {
    
    [self openselectpicker];
}

- (IBAction)vehDropButton:(UIButton *)sender {
    
    [self openselectpicker];
}
@end
