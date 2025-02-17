//
//  AppDelegate.m
//  FuelBuddy
//
//  Copyright (c) 2015 Oraganization. All rights reserved.
//

#import "AppDelegate.h"
#import "VehicleaddViewController.h"
#import "AddFillupViewController.h"
#import "ServiceViewController.h"
#import "Veh_Table.h"
#import "Services_Table.h"
#import "T_Fuelcons.h"
#import "Friends_Table.h"
#import "AddExpenseViewController.h"
#import <Crashlytics/Crashlytics.h>
#import "GraphViewController.h"
#import "BarGraphViewController.h"
#import "JRNLocalNotificationCenter.h"
#import "AddTripViewController.h"
#import "LogViewController.h"
#import "commonMethods.h"
#import "T_Trip.h"
#import "Loc_Table.h"
#import "SignInCloudViewController.h"
#import "LoggedInVC.h"
#import "WebServiceURL's.h"
#import "LocationServices.h"
#import "FillUpDataHandler.h"
#import "TripDataHandler.h"
#import "MoreViewController.h"
#import "AutorotateNavigation.h"
#import "ReportViewController.h"
#import "CheckReachability.h"
#import "MainScreenViewController.h"
#import "Autorotate.h"
#import "Sync_Table.h"
#import "FuelBuddy-Swift.h"
#import "GoProViewController.h"

@import GooglePlaces;
@import Fabric;
@import GoogleMobileAds;

// Dynamic Links will start with https://com.simplyauto/mobi
//"appAssociation": "AUTO",
//"rewrites": [ { "source": "/mobi/**", "dynamicLinks": true } ]

#define SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

NSString *const kGCMMessageIDKey = @"gcm.message_id";

@interface AppDelegate (){
    
    NSUInteger tripCount;
}
@property (nonatomic,retain) NSMutableArray *beforeArray;
@property (nonatomic,retain) NSMutableArray *toChangetripTypeArray;
@property (nonatomic) bool tripRateUpdated;
@property (nonatomic, strong) NSURL *launchedURL;
//@property (nonatomic,strong) netPerfWrapper *myTest;

@end

@implementation AppDelegate


@synthesize result = result;

-(UIWindow *)topView {
    return [[[UIApplication sharedApplication] windows] firstObject];
}

- (NSInteger)selPickerViewRow {
    NSUserDefaults *setRowValue = [NSUserDefaults standardUserDefaults];
    int picRowId = (int)[setRowValue integerForKey:@"rowValue"];
    return picRowId;
}

- (void)setSelPickerViewRow:(NSInteger)selPickerViewRow {
    NSUserDefaults *setRowValue = [NSUserDefaults standardUserDefaults];
    [setRowValue setInteger:selPickerViewRow forKey:@"rowValue"];
}

+ (AppDelegate *)sharedAppDelegate {
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    //TODO re,oved this from build phases check if it works 24-5-2020 Nikhil
    //"${PODS_ROOT}/Fabric/run" d532568af0b64dc2a386726e7bda745948b5403f ffe90a9e61e779380e1a226353c1f521a254d49518877bf4f8d0be3fb9ebfe70

    //LINE44-45
//    <key>Fabric</key>
//    <dict>
//    <key>APIKey</key>
//    <string>d532568af0b64dc2a386726e7bda745948b5403f</string>
//    <key>Kits</key>
//    <array>
//    <dict>
//    <key>KitInfo</key>
//    <dict/>
//    <key>KitName</key>
//    <string>Crashlytics</string>
//    </dict>
//    </array>
//    </dict>
    //TODO Measurementsys cha initialzation
//    if (self.myTest == nil){
//        self.myTest = [[netPerfWrapper alloc] init];
//    }
//
//    [self.myTest startNetPerf];

    self.launchedURL = [launchOptions objectForKey:UIApplicationLaunchOptionsURLKey];

    [self fetchCurrentLocation];
    // nikhil for Google places
    [GMSPlacesClient provideAPIKey:@"AIzaSyDegPf_k0weXo03DJVoqbDpq6pm9kTLEpg"];

    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    //NSLog(@"FillupType ahe:%@",[def objectForKey:@"filluptype"]);

    if(![[NSUserDefaults standardUserDefaults]boolForKey:@"changefilluptype"]){

        if([[def objectForKey:@"filluptype"]isEqualToString:NSLocalizedString(@"trp", @"Trip")]){

            [def setObject:@"Trip" forKey:@"filluptype"];
        }else{
            [def setObject:@"odometer" forKey:@"filluptype"];
        }
        [[NSUserDefaults standardUserDefaults]setBool:true forKey:@"changefilluptype"];

    }

    //https://www.simplyauto.app/DatabaseScripts/ios_pro/make_pro.php?reg_id=fjyrLgzgKSw:APA91bEAfcm5norOT24qwZ0SlrJyK5vT7shg3aSBP0dHTA8L2Vnp0tq9ueQAFaDTikYQOpzbD5asbgew5mtye7mJ5BakreVjjVWSyBnRrAoxq23MJ3ilr1LbDONyNR5xu1lcaoCrUMLx&email=nikhilthite45@gmail.com&pro_type=1
   // NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSLog(@"*************************************************************************************************************************************************************************************************************************************************************regID:- %@",[def objectForKey:@"UserRegId"]);
     //TODO remove this in Final Build
    if (!isatty(STDERR_FILENO)) {
        // Redirection code
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                             NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *logPath = [documentsDirectory
                             stringByAppendingPathComponent:@"console.log"];
        freopen([logPath cStringUsingEncoding:NSASCIIStringEncoding],"a+",stderr);
    }
    
    //Nikhil 11 Oct 2018 added below code for autotrip logging
    //We have to make sure that the Background App Refresh is enable for the Location updates to work in the background.
    self.shareModel = [LocationManager sharedManager];
    
    //New_10 Nikhil 1December2018 Auto Trip Loging
    if([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusDenied){
        
        //NSLog(@"The app doesn't work without the Background App Refresh enabled. To turn it on, go to Settings > General > Background App Refresh");

        
    }else if([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusRestricted){
        
       // NSLog(@"The functions of this app are limited because the Background App Refresh is disable.");

        
    } else{
        
        NSLog(@"UIApplicationLaunchOptionsLocationKey : %@" , [launchOptions objectForKey:UIApplicationLaunchOptionsLocationKey]);
        if ([launchOptions objectForKey:UIApplicationLaunchOptionsLocationKey]) {
           
            BOOL autoTripOn = [def boolForKey:@"autoTripSwitchOn"];
            BOOL tripInProgress = [[NSUserDefaults standardUserDefaults] boolForKey:@"tripInProgress"];
            BOOL proUser = [[NSUserDefaults standardUserDefaults] boolForKey:@"isSubscribed"];
            
            NSUInteger remainingTripCount=0;
            [self fetchTripCountForThisMonth];
            
            if(tripCount<10){
                
                remainingTripCount = 10-tripCount;
            }else{
                remainingTripCount = tripCount;
            }
            
            if(proUser || remainingTripCount<11){
                
                if(!tripInProgress && autoTripOn){
                    
                    [self.shareModel startMonitoringLocation];
                    
                }
                
            }else{
                
                [self showNotification:NSLocalizedString(@"noti_free_trips_over_title",@"Upgrade for unlimited auto logging of trips"):NSLocalizedString(@"noti_free_trips_over_msg",@"You have finished your quota of 15 automatic trips for this month. Upgrade or log trips manually.")];
                
            }
            
            
            
            [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"appStatusTrip"];

            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"locationKey"];

        }
        
        BOOL tripInProgress = [[NSUserDefaults standardUserDefaults] boolForKey:@"tripInProgress"];
        if(tripInProgress){
            NSLog(@"Trip in progress");
        }else{
            NSLog(@"NO Trip in progress");
        }
    }
    
    //ENH_53 To check if sync is updated when app was killed
    NSString *userEmail;
    if([def objectForKey:@"UserEmail"]){
        userEmail = [def objectForKey:@"UserEmail"];
    }else{
        userEmail = @"";
    }
    //[[def objectForKey:@"quit"]  isEqual: @1] &&

    
    //NSLog(@"make : %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"fillupid"]);
    NSString *language = [[NSLocale preferredLanguages] firstObject];
    //NSLog(@"language : %@", [[NSUserDefaults standardUserDefaults] dictionaryRepresentation]);
    
    NSMutableDictionary *settingDict;
    if([language hasPrefix:@"pt-BR"] && [[NSUserDefaults standardUserDefaults] objectForKey:@"dist_unit"] != nil && [[NSUserDefaults standardUserDefaults] objectForKey:@"vol_unit"] != nil && [[NSUserDefaults standardUserDefaults] objectForKey:@"con_unit"] != nil){
    
        NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
        if([def objectForKey:@"language"] == nil){
            
            NSString *distanceUnit = [def objectForKey:@"dist_unit"];
            NSString *volumeUnit = [def objectForKey:@"vol_unit"];
            NSString *consUnit = [def objectForKey:@"con_unit"];
            NSString *fillupUnit = [def objectForKey:@"filluptype"];
            
            
            settingDict = [[NSMutableDictionary alloc] init];
            if([distanceUnit isEqualToString:@"Miles"]){
                [settingDict setObject:@"Miles" forKey:@"distance"];
            } else {
                [settingDict setObject:@"Kilometers" forKey:@"distance"];
            }

            if([volumeUnit isEqualToString:@"Kilowatt-Hour"]){
                [settingDict setObject:@"Kilowatt-Hour" forKey:@"volume"];
            }else if([volumeUnit isEqualToString:@"Litre"]){
                [settingDict setObject:@"Litre" forKey:@"volume"];
            } else if ([volumeUnit isEqualToString:@"Gallon (US)"]){
                [settingDict setObject:@"Gallon (US)" forKey:@"volume"];
            } else {
                [settingDict setObject:@"Gallon (UK)" forKey:@"volume"];
            }

            if ([consUnit isEqualToString:@"km/kWh"]) {
                [settingDict setObject:@"km/kWh" forKey:@"cons"];
            }else if([consUnit isEqualToString:@"m/kWh"]){
                [settingDict setObject:@"m/kWh" forKey:@"cons"];
            }else if([consUnit isEqualToString:@"km/L"]){
                [settingDict setObject:@"km/L" forKey:@"cons"];
            } else if ([consUnit isEqualToString:@"L/100km"]){
                [settingDict setObject:@"L/100km" forKey:@"cons"];
            } else if ([consUnit isEqualToString:@"mpg (US)"]){
                [settingDict setObject:@"mpg (US)" forKey:@"cons"];
            } else {
                [settingDict setObject:@"mpg (UK)" forKey:@"cons"];
            }
            
            if([fillupUnit isEqualToString:@"Odometer"]){
                [settingDict setObject:@"Odometer" forKey:@"fillupUnit"];
            } else {
                [settingDict setObject:@"Trip" forKey:@"fillupUnit"];
            }
            
            [settingDict setObject:[def objectForKey:@"curr_unit"] forKey:@"currencyUnit"];
            [settingDict setObject:[def objectForKey:@"vehname"] forKey:@"currentVehicle"];
            
            NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
            [def removePersistentDomainForName:appDomain];
            [def setObject:@"languageSet" forKey:@"language"];
        }
    }
    
    
    //GID Sign In Setup
    //Swapnil NEW_6
    [FIRApp configure];
    [FIRMessaging messaging].delegate = self;
    
    
    //NSError* configureError;
    NSString *kClientID = @"336428349177-hud26k15ouvlv7hlsjh72v49pndlhoid.apps.googleusercontent.com";
    [GIDSignIn sharedInstance].clientID = kClientID;
    //[[GGLContext sharedInstance] configureWithError: &configureError];
   // NSAssert(!configureError, @"Error configuring Google services: %@", configureError);
    
    
//    [GIDSignIn sharedInstance].clientID = [FIRApp defaultApp].options.clientID;
    
    [GIDSignIn sharedInstance].delegate = self;
    

    
    [Fabric with:@[[Crashlytics class]]];

    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
   
    result = [[UIScreen mainScreen] bounds].size;
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *currentAppVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *previousVersion = [defaults objectForKey:@"appVersion"];
    [defaults setObject:previousVersion forKey:@"prevAppVersion"];
    [defaults setObject:currentAppVersion forKey:@"appVersion"];
    [defaults synchronize];
    
    
   // NSUserDefaults *def = [NSUserDefaults standardUserDefaults];

    
    [self numberOfrecords];
    if(self.recordnumber == 0)
    {
        [self savetolocaldatabase];
    }
    
    [self setupInteractiveNotification];
     
     UITabBarController *tabBarcontroller = (UITabBarController *)self.window.rootViewController;
   [[UITabBar appearance] setBarTintColor:[self colorFromHexString:@"#2c2c2c"]];
    self.tabbutton = [[UIButton alloc]init];
    self.tabbutton.frame = CGRectMake(result.width/2-22,0, 50, 50);
    
    tabBarcontroller.tabBar.tintColor =[UIColor systemTealColor];
    [ self.tabbutton setImage:[UIImage imageNamed:@"tab_add_new"] forState:UIControlStateNormal];
    [ self.tabbutton addTarget:self action:@selector(clickadd) forControlEvents:UIControlEventTouchUpInside];
    [tabBarcontroller.tabBar addSubview:self.tabbutton];
    
   
    
    NSLocale *currentLocale = [NSLocale currentLocale];  // get the current locale.
    NSString *countryCode = [currentLocale objectForKey:NSLocaleCountryCode];
//    NSUserDefaults *def =[NSUserDefaults standardUserDefaults];
    NSArray* countryArr = [[NSArray alloc] initWithObjects:@"CA",@"ZA",@"AU",@"NZ",@"RU",@"DE",@"FR", @"IT", @"ES",@"PL",@"BE",@"GR", @"CZ", @"PT", @"HU",@"SE",@"CH", @"BG", @"RS", @"FI", @"IE",@"IS", @"HR", nil];
    
    if(settingDict.count > 0){
        
        NSString *distanceUnit = [settingDict objectForKey:@"distance"];
        NSString *volumeUnit = [settingDict objectForKey:@"volume"];
        NSString *consUnit = [settingDict objectForKey:@"cons"];
        NSString *fillupUnit = [settingDict objectForKey:@"fillupUnit"];
        
        if([distanceUnit isEqualToString:@"Miles"]){
            [def setObject:NSLocalizedString(@"disp_miles", @"Miles") forKey:@"dist_unit"];
        } else{
            [def setObject:NSLocalizedString(@"disp_kilometers", @"Kilometers") forKey:@"dist_unit"];
        }
        
        if([volumeUnit isEqualToString:@"Litre"]){
            [def setObject:NSLocalizedString(@"disp_litre", @"Litre") forKey:@"vol_unit"];
        } else if ([volumeUnit isEqualToString:@"Gallon (US)"]){
            [def setObject:NSLocalizedString(@"disp_gal_us", @"Gallon (US)") forKey:@"vol_unit"];
        } else if ([volumeUnit isEqualToString:@"Gallon (UK)"]){
            [def setObject:NSLocalizedString(@"disp_gal_uk", @"Gallon (UK)") forKey:@"vol_unit"];
        }else{
            [def setObject:NSLocalizedString(@"disp_kilowatt_hour", @"Kilowatt-Hour") forKey:@"vol_unit"];
        }
        
        
        if([consUnit isEqualToString:@"km/L"]){
            [def setObject:NSLocalizedString(@"disp_kmpl", @"km/L") forKey:@"con_unit"];
        } else if ([consUnit isEqualToString:@"L/100km"]){
            [def setObject:NSLocalizedString(@"disp_lp100kms", @"L/100km") forKey:@"con_unit"];
        } else if ([consUnit isEqualToString:@"mpg (US)"]){
            [def setObject:NSLocalizedString(@"disp_mpg_us", @"mpg (US)") forKey:@"con_unit"];
        } else if ([consUnit isEqualToString:@"mpg (UK)"]){
            [def setObject:NSLocalizedString(@"disp_mpg_uk", @"mpg (UK)") forKey:@"con_unit"];
        } else if ([consUnit isEqualToString:@"km/kWh"]){
            [def setObject:NSLocalizedString(@"disp_kmpkwh", @"km/kWh") forKey:@"con_unit"];
        } else {
            [def setObject:NSLocalizedString(@"disp_mpkwh", @"m/kWh") forKey:@"con_unit"];
        }

        //Changed the object type bcuz it is causing langaue issues
        if([fillupUnit isEqualToString:@"Odometer"]){
           // [def setObject:NSLocalizedString(@"odometer", @"Odometer") forKey:@"filluptype"];
            [def setObject:@"odometer" forKey:@"filluptype"];
        } else {
            //[def setObject:NSLocalizedString(@"trp", @"Trip") forKey:@"filluptype"];
            [def setObject:@"Trip" forKey:@"filluptype"];
        }
        
        [def setObject:[settingDict objectForKey:@"currencyUnit"] forKey:@"curr_unit"];
        [def setObject:[settingDict objectForKey:@"currentVehicle"] forKey:@"fillupid"];
        
        LogViewController *logVC = [[LogViewController alloc] init];
        [logVC fetchallfillup];
        [logVC fetchdata];
        [logVC donelabel];
        
        [def setValue:@"1" forKey:@"logLaunch"];
        [def setValue:@"1" forKey:@"fillupLaunch"];
        [def setValue:@"1" forKey:@"isFirstLaunch"];
        [def setValue:@"1" forKey:@"dashLaunch"];
        [def setValue:@"1" forKey:@"reminderLaunch"];
        [def setValue:@"1" forKey:@"serviceLaunch"];
        [def setValue:@"1" forKey:@"tripLaunch"];
    }
    
    else {

        if ([countryCode isEqualToString:@"US"] ) {

            if ([def objectForKey:@"dist_unit" ]==nil)
            {
                [def setObject:NSLocalizedString(@"disp_miles", @"Miles") forKey:@"dist_unit"];
            }

            if([def objectForKey:@"vol_unit"]==nil)
            {
                [def setObject:NSLocalizedString(@"disp_gal_us", @"Gallon (US)") forKey:@"vol_unit"];
            }
            if([def objectForKey:@"con_unit"]==nil)
            {
                [def setObject:NSLocalizedString(@"disp_mpg_us", @"mpg (US)") forKey:@"con_unit"];
            }
            if([def objectForKey:@"curr_unit"]==nil)
            {
                [def setObject:@"U.S. Dollar - USD" forKey:@"curr_unit"];

            }

        }
        else if ([countryCode isEqualToString:@"GB"])
        {

            if ([def objectForKey:@"dist_unit" ]==nil)
            { [def setObject:NSLocalizedString(@"disp_miles", @"Miles") forKey:@"dist_unit"]; }

            if([def objectForKey:@"vol_unit"]==nil)
            {
                [def setObject:NSLocalizedString(@"disp_litre", @"Litre") forKey:@"vol_unit"];
            }
            if([def objectForKey:@"con_unit"]==nil)
            {
                [def setObject:NSLocalizedString(@"disp_mpg_uk", @"mpg (UK)") forKey:@"con_unit"];
            }
            if([def objectForKey:@"curr_unit"]==nil)
            {
                [def setObject:@"British pound - GBP" forKey:@"curr_unit"];
            }

        }

        else if ([countryArr containsObject:countryCode])
        {

            if ([def objectForKey:@"dist_unit" ]==nil)
            { [def setObject:NSLocalizedString(@"disp_kilometers", @"Kilometers") forKey:@"dist_unit"];

            }

            if([def objectForKey:@"vol_unit"]==nil)
            {
                [def setObject:NSLocalizedString(@"disp_litre", @"Litre") forKey:@"vol_unit"];
            }
            if([def objectForKey:@"con_unit"]==nil)
            {
                [def setObject:NSLocalizedString(@"disp_lp100kms", @"L/100km") forKey:@"con_unit"];
            }
        }
        else
        {

            if ([def objectForKey:@"dist_unit" ]==nil)
            {
                [def setObject:NSLocalizedString(@"disp_kilometers", @"Kilometers") forKey:@"dist_unit"];

            }

            if([def objectForKey:@"vol_unit"]==nil)
            {
                [def setObject:NSLocalizedString(@"disp_litre", @"Litre") forKey:@"vol_unit"];
            }
            if([def objectForKey:@"con_unit"]==nil)
            {
                [def setObject:NSLocalizedString(@"disp_kmpl", @"km/L") forKey:@"con_unit"];
            }
        }

        NSString *currencyCode = [[NSLocale currentLocale] objectForKey: NSLocaleCurrencyCode];

        if([def objectForKey:@"curr_unit"]==nil)
        {
            [def setObject:currencyCode forKey:@"curr_unit"];
        }
    }
    //Invoke Instabug
    
    //[Instabug startWithToken:@"da68164502442834cf9ab785e8d01d35" invocationEvent:IBGInvocationEventShake];
    
    
    //Get Local notifications Access
    
    if(SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(@"10.0")){
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error){
            if( !error ){

                dispatch_async(dispatch_get_main_queue(), ^{
                    [[UIApplication sharedApplication] registerForRemoteNotifications];
                });


            }
        }];
    }
   /* if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
    }
    */
    
    //Swapnil
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(tokenRefreshCallback:)
                                                 name:kFIRInstanceIDTokenRefreshNotification
                                               object:nil];
    
//  NSLog(@"def object of double %d",[def integerForKey:@"appopenstatus"]);

    //Page control
    UIPageControl *pageControl = [UIPageControl appearance];
    pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
    pageControl.backgroundColor = [UIColor clearColor];

    [GADMobileAds configureWithApplicationID:@"ca-app-pub-6674448976750697~1094484366"];

    if([[NSUserDefaults standardUserDefaults] integerForKey:@"adCount"] == nil){
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"adCount"];
    }
    
    //Swapnil Fabric events
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd-MMM-yyyy"];
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"installDate"] == nil){
        
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"fillupCountEvent"];
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"serviceCountEvent"];
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"expenseCountEvent"];
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"tripCountEvent"];
        [[NSUserDefaults standardUserDefaults] setObject:[formatter stringFromDate:[NSDate date]] forKey:@"installDate"];
    }
    
    //Swapnil ENH_11
    if([def objectForKey:@"autoDetectLoc"] == nil){
        [def setObject:@"YES" forKey:@"autoDetectLoc"];
    }
    //NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    //Swapnil NEW_6
    //updating rowIDs of all tables once (for app versions <= 7.3)
    if(![[def objectForKey:@"rowIDUpdated"] isEqualToString:@"yes"]){
        
        
        int fuelID = 0;
        int serviceID = 0;
        int locID = 0;
        
        //BUG_156
        NSManagedObjectContext *context = [[CoreDataController sharedInstance] newManagedObjectContext];
        NSError *err;
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"T_Fuelcons"];
        NSArray *fetchedData = [context executeFetchRequest:request error:&err];
        
        NSError *servErr;
        NSFetchRequest *serviceRequest = [[NSFetchRequest alloc] initWithEntityName:@"Services_Table"];
        NSArray *fetchedDataService = [context executeFetchRequest:serviceRequest error:&servErr];
        
        for (T_Fuelcons *logData in fetchedData) {
            
            fuelID = fuelID + 1;
            logData.iD = [NSNumber numberWithInt:fuelID];
            //NSLog(@"iD in AppDelegate:::%@",logData.iD);
        }
        
        for(Services_Table *serviceData in fetchedDataService){
            
            
            serviceID = serviceID + 1;
            serviceData.iD = [NSNumber numberWithInt:serviceID];
        }
        
        NSError *locErr;
        NSFetchRequest *locReq = [[NSFetchRequest alloc] initWithEntityName:@"Loc_Table"];
        NSArray *fetchedLocData = [context executeFetchRequest:locReq error:&locErr];
        
        for (Loc_Table *locations in fetchedLocData) {
            
            locID = locID + 1;
            locations.iD = [NSNumber numberWithInt:locID];
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
        //NSLog(@"insertrecord fuelID::::%i",fuelID);
        [def setObject:[NSNumber numberWithInt:fuelID] forKey:@"maxFuelID"];
        [def setObject:[NSNumber numberWithInt:serviceID] forKey:@"maxServiceID"];
        [def setObject:[NSNumber numberWithInt:locID] forKey:@"maxLocID"];
        
        NSError *tripErr;
        NSFetchRequest *tripRequest = [[NSFetchRequest alloc] initWithEntityName:@"T_Trip"];
        NSArray *fetchedTrips = [context executeFetchRequest:tripRequest error:&tripErr];
        
        fuelID = [[def objectForKey:@"maxFuelID"] intValue];
        for (T_Trip *trips in fetchedTrips) {
            
            fuelID = fuelID + 1;
            trips.iD = [NSNumber numberWithInt:fuelID];
        }
        
        //    if([context hasChanges]){
            //            [context save:&servErr];
            //        }
            
        if ([context hasChanges])
        {
            BOOL saved = [context save:&err];
            if (!saved) {
                // do some real error handling
                //CLSLog(@“Could not save Data due to %@“, error);
            }
            [[CoreDataController sharedInstance] saveMasterContext];
        }
        //NSLog(@"insertrecord fuelID::::%i",fuelID);
        [def setObject:[NSNumber numberWithInt:fuelID] forKey:@"maxFuelID"];
        
        
        [def setObject:@"yes" forKey:@"rowIDUpdated"];
    }
  
    
    if(![[def objectForKey:@"recordType0InService"] isEqualToString:@"yes"]){
        
        
        [self removeRecordType0FromService];
        [self removeDistFromServiceExp];
        [def setObject:@"yes" forKey:@"recordType0InService"];
    }

    //NIKHIL ENH_40 //Checking if user is new and updating tax rate values
    NSUserDefaults *checkRate = [NSUserDefaults standardUserDefaults];
    _tripRateUpdated = [checkRate boolForKey:@"updatetrip2020"];
    
    if (_tripRateUpdated == false)
    {
        [self updateTrip];
     
        [checkRate setBool:TRUE forKey:@"updatetrip2020"];
        _tripRateUpdated = true;
    }
    
    //nikhil 12june2018 to signIn only firstTime the app opens
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"doSignIn"];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];



    //NIKHIL ADDED 13june2019 To validate receipt monthly if user is Platinum user
    bool platinumPurchased = [[NSUserDefaults standardUserDefaults] boolForKey:@"isSubscribed"];
    if(platinumPurchased){

        NSDate *purchaseDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"platinumPurchaseDate"];
        NSDate *lastCalledDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastCalledDate"];

        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        // now build a NSDate object for the next day
        NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
        [offsetComponents setDay:31];

        NSDate *currentDate = [NSDate date];

        NSData *receiptData = [[NSUserDefaults standardUserDefaults] objectForKey:@"receiptData"];

        if(lastCalledDate == nil){

            //add 30 days to purchase date and call script
            NSDate *nextDate = [gregorian dateByAddingComponents:offsetComponents toDate: purchaseDate options:0];

             if([currentDate compare: nextDate] == NSOrderedSame ||  [currentDate compare:nextDate] == NSOrderedDescending)
            {
                //call script
                [self performSelectorInBackground:@selector(callUploadSubscriptionReceipt:) withObject:receiptData];
                [[NSUserDefaults standardUserDefaults]setObject:currentDate forKey:@"lastCalledDate"];
            }

        }else{

            //add 30days to lastCalledDate and call script
            NSDate *nextDate = [gregorian dateByAddingComponents:offsetComponents toDate: lastCalledDate options:0];
            //left operand is greater than right operand

            if([currentDate compare: nextDate] == NSOrderedSame ||  [currentDate compare:nextDate] == NSOrderedDescending)
            {
                //call script
                [self performSelectorInBackground:@selector(callUploadSubscriptionReceipt:) withObject:receiptData];
                [[NSUserDefaults standardUserDefaults]setObject:currentDate forKey:@"lastCalledDate"];
            }

        }

    }

    //Check if there is any data to send to server if yes then send the call pullData script
    [CheckReachability.sharedManager fetchDataFromSyncTable];

    if([def objectForKey:@"UserEmail"] != nil){

        //GEt data from sync table on every app open in background
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

            [self performSelectorInBackground:@selector(saveResponseToDB) withObject:nil];
        });
    }
    [CheckReachability.sharedManager startNetworkMonitoring];

    [self expireOldNotifications];
    return YES;
}

-(BOOL)application:(UIApplication *)application
           openURL:(NSURL *)url
 sourceApplication:(NSString *)sourceApplication
        annotation:(id)annotation{

    if([[url host] isEqualToString:@"deeplink"]) {
        if([[url path] isEqualToString:@"/gopro"]) {
//            GoProViewController *gopro = (GoProViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"gopro"];
//            dispatch_async(dispatch_get_main_queue(), ^{
//                gopro.modalPresentationStyle = UIModalPresentationFullScreen;
//                [self.window.rootViewController presentViewController:gopro animated:YES completion:nil];
//            });
//            self.window.rootViewController = [[GoProViewController alloc] init];
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                                     bundle: nil];
            GoProViewController *gopro = (GoProViewController *)[mainStoryboard instantiateViewControllerWithIdentifier:@"gopro"];
            #define ROOTVIEW [[[UIApplication sharedApplication] keyWindow] rootViewController]
            gopro.modalPresentationStyle = UIModalPresentationFullScreen;
            [ROOTVIEW presentViewController:gopro animated:YES completion:^{}];

            return YES;
        } else {
            return NO;
        }
    } else {
        return NO;
    }
    //return YES;
}

- (BOOL)openLink:(NSURL *)urlLink
{

    if([[urlLink host] isEqualToString:@"deeplink"]) {
        if([[urlLink path] isEqualToString:@"/gopro"]) {

            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                                     bundle: nil];
            GoProViewController *gopro = (GoProViewController *)[mainStoryboard instantiateViewControllerWithIdentifier:@"gopro"];
            #define ROOTVIEW [[[UIApplication sharedApplication] keyWindow] rootViewController]
            gopro.modalPresentationStyle = UIModalPresentationFullScreen;
            [ROOTVIEW presentViewController:gopro animated:YES completion:^{}];
            return YES;
        } else {
            return NO;
        }
    } else {
        return NO;
    }

}

-(void)fetchCurrentLocation{

    //Swapnil ENH_11
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];


    //check if auto detect locn checkmark is checked, permission to access locn is granted and location services are enabled
    if([[def objectForKey:@"autoDetectLoc"]  isEqual: @"YES"] && ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways || ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse && [CLLocationManager locationServicesEnabled]))){

        //Request current location
        [[LocationServices sharedInstance].locationManager requestLocation];

        //Get latest locn in currentLocation
        CLLocation *currentLocation = [LocationServices sharedInstance].latestLoc;

        [[NSUserDefaults standardUserDefaults] setObject:currentLocation forKey:@"currentLocationFromAppDelegate"];

//        NSNumberFormatter *lformatter = [NSNumberFormatter new];
//        [lformatter setRoundingMode:NSNumberFormatterRoundFloor];
//        [lformatter setMaximumFractionDigits:3];
//        [lformatter setPositiveFormat:@"0.###"];
//        NSString *latString = [lformatter stringFromNumber: [NSNumber numberWithDouble: currentLocation.coordinate.latitude]];
//        NSString *longiString = [lformatter stringFromNumber: [NSNumber numberWithDouble: currentLocation.coordinate.longitude]];

//        double latValue = [latString doubleValue];
//        double longitudeValue = [longiString doubleValue];
//
//        currentLat = [NSNumber numberWithDouble:latValue];
//        currentLongitude = [NSNumber numberWithDouble:longitudeValue];
        //Mention changes in Sheet
        //NIKHIL BUG_151
//        saveCurLat = [NSNumber numberWithDouble: currentLocation.coordinate.latitude];
//        saveCurLongitude = [NSNumber numberWithDouble: currentLocation.coordinate.longitude];

//        NSManagedObjectContext *context = [[CoreDataController sharedInstance] newManagedObjectContext];
//        NSError *err;
//
//        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Loc_Table"];
//
//        NSArray *locationArray = [[NSArray alloc] init];
//        locationArray = [context executeFetchRequest:request error:&err];
//
//        //NSLog(@"locArr : %@", locationArray);
//
//        //First set locFound to NO
//        BOOL locFound = NO;
//
//        if(![currentLocation.coordinate.latitude  == 0.0] && ![currentLocation.coordinate.longitude == 0.0]){
//
//            //Loop thr' each record in Loc_Table
//            for (Loc_Table *location in locationArray) {
//                NSString *latString = [lformatter stringFromNumber: location.lat];
//                NSString *longiString = [lformatter stringFromNumber: location.longitude];
//                location.lat = [NSNumber numberWithDouble:[latString doubleValue]];
//                location.longitude = [NSNumber numberWithDouble:[longiString doubleValue]];
//
//                //Check if current lat, long is present in that record of Loc_Table
//
//                if([currentLat floatValue] == [location.lat floatValue] && [currentLongitude floatValue] == [location.longitude floatValue]){
//
//                    //If present, set locFound to YES
//                    locFound = YES;
//
//                    //Extract brand and address from Loc_Table for matching coordinates and set to fuelbrand and filling station
//                    UITextField *fuelbrand = (UITextField *)[self.view viewWithTag:9];
//                    UITextField *filling = (UITextField *) [self.view viewWithTag:10];
//
//                    if(fuelbrand.text.length == 0){
//                        fuelbrand.text = location.brand;
//                    }
//                    if(filling.text.length == 0){
//                        filling.text = location.address;
//                    }
//                    break;
//                } else {
//
//                    //Set locFound to NO
//                    locFound = NO;
//                }
//            }
//        }
//
//        //current lat, long not present in Loc_Table
//        //NIKHIL BUG_150 removed locFound == NO &&
//        if(![currentLat  isEqual: @0.0] && ![currentLongitude isEqual:@0.0] && currentLat){
//
//            //Hit query to google places api to find nearest gas station around 500m
//            NSString *urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/search/json?location=%f,%f&radius=500&types=gas_station&sensor=true&key=AIzaSyAT6PGoESv5KtMC8Tu13LOB5NRXseCOYHk",
//                                   currentLocation.coordinate.latitude, currentLocation.coordinate.longitude];
//            NSURL *googleRequestUrl = [NSURL URLWithString:urlString];
//
//            // dispatch_async(kBgQueue, ^{
//            NSData* data = [NSData dataWithContentsOfURL:googleRequestUrl];
//            [self performSelectorOnMainThread:@selector(placesFetchedData:) withObject:data waitUntilDone:YES];
//            // });
//
//        }

    }

}

- (void)removeRecordType0FromService{
    
    //BUG_156
    NSManagedObjectContext *context = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSError *error;
    NSError *err;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Services_Table"];
    NSPredicate *recordType0Predicate = [NSPredicate predicateWithFormat:@"iD == 0 OR type == 0"];
    
    [request setPredicate:recordType0Predicate];
    
    NSArray *serviceRecords = [context executeFetchRequest:request error:&error];
    
    //NSLog(@"count : %lu", (unsigned long)serviceRecords.count);
    for (Services_Table *service in serviceRecords) {
        
        [context deleteObject:service];
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


- (void)removeDistFromServiceExp{
    
    //BUG_156
    NSManagedObjectContext *context = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSError *err;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"T_Fuelcons"];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"type == 1 OR type == 2"];
    [request setPredicate:pred];
    
    NSArray *records = [context executeFetchRequest:request error:&err];
    
    
    for (T_Fuelcons *data in records) {
        
        data.dist = @(0.0);
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


-(BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions{

    return YES;
}

//ENH_58 Nikhil 13june2019 added subscription
-(void)callUploadSubscriptionReceipt:(NSData *)receiptData {

    NSMutableDictionary *uploadDictionary = [[NSMutableDictionary alloc]init];
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    
    if([def objectForKey:@"UserEmail"]){
        [uploadDictionary setObject:[def objectForKey:@"UserEmail"] forKey:@"email"];
    }else{
        [uploadDictionary setObject:@"dummy@gmail.com" forKey:@"email"];
    }

    [[FIRInstanceID instanceID] instanceIDWithHandler:^(FIRInstanceIDResult * _Nullable result,
                                                        NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Error fetching remote instance ID: %@", error);
        } else {
            //NSString *fcmToken = [[FIRInstanceID instanceID] token];
            NSString *fcmToken = result.token;
            NSString *userRegId = [def objectForKey:@"UserRegId"];

            if(fcmToken != nil){

                [uploadDictionary setObject:fcmToken forKey:@"reg_id"];
            }else if(userRegId != nil){

                [uploadDictionary setObject:userRegId forKey:@"reg_id"];
            }

            if(receiptData == nil){

                [uploadDictionary setObject:@"" forKey:@"receipt"];

            }else{

                NSString *base64Data = [receiptData base64EncodedStringWithOptions:0];
                [uploadDictionary setObject:base64Data forKey:@"receipt"];

            }

           // NSLog(@"uploadDictionary:- %@",uploadDictionary);

            NSError *err;
            NSData *postDataArray = [NSJSONSerialization dataWithJSONObject:uploadDictionary options:NSJSONWritingPrettyPrinted error:&err];

            commonMethods *common = [[commonMethods alloc]init];
            [def setBool:NO forKey:@"updateTimeStamp"];
            [common saveToCloud:postDataArray urlString:kSubscriptionValidationScript success:^(NSDictionary *responseDict) {

             //   NSLog(@"ResponseDict is callUploadSubscriptionReceipt app open: %@", responseDict);
                if([[responseDict objectForKey:@"success"] intValue] == 1){

                    NSMutableDictionary *purchaseDataDict = [responseDict objectForKey:@"purchase_data"];
                    if([[purchaseDataDict objectForKey:@"cancellation_date"] isKindOfClass:[NSString class]]){

                 //       NSLog(@"Cancellation date is: - %@",[purchaseDataDict objectForKey:@"cancellation_date"]);

                    }else{

                        //Do something with cancellation date
                       // NSLog(@"%@",[purchaseDataDict objectForKey:@"cancellation_date"]);
                        NSDate *cancellationDate = [NSDate dateWithTimeIntervalSince1970:[[purchaseDataDict objectForKey:@"cancellation_date"] doubleValue]];
                      //  NSLog(@"%@",cancellationDate);
                        if(cancellationDate != nil){

                            //Testing cancel subscription immediately
                            [[NSUserDefaults standardUserDefaults]setBool:false forKey:@"isSubscribed"];
                        }

                    }

                    if([[purchaseDataDict objectForKey:@"expires_date"] isKindOfClass:[NSString class]]){

                       // NSLog(@"expires date is: - %@",[purchaseDataDict objectForKey:@"expires_date"]);


                    }else{

                        //Do something with expires date
                      //  NSLog(@"%@",[purchaseDataDict objectForKey:@"expires_date"]);
                        NSDate *expiresDate = [NSDate dateWithTimeIntervalSince1970:[[purchaseDataDict objectForKey:@"expires_date"] doubleValue]];
                    //    NSLog(@"%@",expiresDate);

                        NSDate *currentDate = [NSDate date];

                        if([[purchaseDataDict objectForKey:@"expires_date"]  isEqual: @0]){

                     //       NSLog(@"yes it is number:- %@",expiresDate);

                        }else{


                            if([currentDate compare:expiresDate] == NSOrderedDescending)
                            {
                                //Testing cancel subscription immediately
                                [[NSUserDefaults standardUserDefaults]setBool:false forKey:@"isSubscribed"];
                            }

                        }

                    }

                } else {

                    NSLog(@"%@",[responseDict objectForKey:@"success"]);
                }


            } failure:^(NSError *error){

                NSLog(@"receipt validation failed due to :- %@",error);
            }];
        }
    }];

}

//New_10 Nikhil 1December2018 Auto Trip Loging
-(void)fetchTripCountForThisMonth{
    
    NSMutableArray *datavalue= [[NSMutableArray alloc]init];
    NSManagedObjectContext *contex = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSFetchRequest *request=[[NSFetchRequest alloc] initWithEntityName:@"T_Trip"];
    NSError *err;
    NSArray *data=[contex executeFetchRequest:request error:&err];
    
    NSDateFormatter *formater=[[NSDateFormatter alloc] init];
    [formater setDateFormat:@"MM"];
    NSDateFormatter *formater1=[[NSDateFormatter alloc] init];
    [formater1 setDateFormat:@"yyyy"];
    NSString *currentmonth = [formater stringFromDate:[NSDate date]];
    NSString *currentyear = [formater1 stringFromDate:[NSDate date]];
    
    for(T_Trip *trip in data)
    {
        if([[formater stringFromDate:trip.depDate] isEqualToString:currentmonth] && [[formater1 stringFromDate:trip.depDate] isEqualToString:currentyear])
        {
            [datavalue addObject: trip];
        }
    }
    
    //NSLog(@"Trips of this month:-%@",datavalue);
    
    tripCount = datavalue.count;
    NSLog(@"Trip count for this month:-%lu",(unsigned long)tripCount);
    
}

#pragma mark FIREBASE & CLOUD SYNC

//Swapnil NEW_6
-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    
    //NSLog(@"Nikhils extended version %s", __PRETTY_FUNCTION__);
    if(userInfo[kGCMMessageIDKey]){
        
       //NSLog(@"didReceiveRemoteNotification : %@", userInfo[kGCMMessageIDKey]);
    }
    
    [self application:application didReceiveRemoteNotification:userInfo fetchCompletionHandler:^(UIBackgroundFetchResult result) {
    }];
    
    //Print full message
   // NSLog(@"%@", userInfo);
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(nonnull void (^)(UIBackgroundFetchResult))completionHandler{

    //NSLog(@"didReceiveRemoteNotificationwithcompleteionhandler:- %s", __PRETTY_FUNCTION__);
    
 //   NSLog(@"Message ID : %@", userInfo[kGCMMessageIDKey]);
    [[FIRMessaging messaging] appDidReceiveMessage:userInfo];
    
    //Print full message
    NSLog(@"GCM response : %@", userInfo);

    //Start executing code even if app is in background state
    UIApplication *app = [UIApplication sharedApplication];
    __block UIBackgroundTaskIdentifier bgTask;
    
    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        
        [app endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
        [[CoreDataController sharedInstance] saveMasterContext];

    }];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        if([[userInfo objectForKey:@"type"] isEqualToString:@"make pro"]){

            NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
            NSString *userEmail = [def objectForKey:@"UserEmail"];
            NSString *confirmEmail = [userInfo objectForKey:@"email"];

            int proType = [[userInfo valueForKey:@"pro_type"] intValue];

            if([userEmail isEqualToString:confirmEmail]){

                if(proType == 0){
                    //Set gold to true
                    [[NSUserDefaults standardUserDefaults]setBool:true forKey:@"isAdDisabled"];
                    [[NSUserDefaults standardUserDefaults]setBool:false forKey:@"isSubscribed"];
                    [[NSUserDefaults standardUserDefaults]setBool:false forKey:@"isSubscribedMonthly"];
                }else if(proType == 1 || proType == 2){
                    //set subscription true
                    [[NSUserDefaults standardUserDefaults]setBool:true forKey:@"isAdDisabled"];
                    [[NSUserDefaults standardUserDefaults]setBool:true forKey:@"isSubscribed"];
                    [[NSUserDefaults standardUserDefaults]setBool:true forKey:@"isSubscribedMonthly"];
                    
                }else{
                    //set all false
                    [[NSUserDefaults standardUserDefaults]setBool:false forKey:@"isAdDisabled"];
                    [[NSUserDefaults standardUserDefaults]setBool:false forKey:@"isSubscribed"];
                    [[NSUserDefaults standardUserDefaults]setBool:false forKey:@"isSubscribedMonthly"];
                }

            }

            NSString *alertTitle = @"Pro Update";
            [self showLogNotificationForPro:alertTitle:@"Hello you are now a Pro user"];

        }

        if([[userInfo objectForKey:@"type"] isEqualToString:@"add friend"]){

//            NSMutableDictionary *addDict = [[NSMutableDictionary alloc]init];
//            [addDict setObject:[userInfo objectForKey:@"action"] forKey:@"action"];
//            [addDict setObject:[userInfo objectForKey:@"email"] forKey:@"friendEmail"];
//            [addDict setObject:[userInfo objectForKey:@"name"] forKey:@"friendName"];
//            //NSLog(@"addDict for addfriend:- %@",addDict);
//            [self reqOrConfirmOrDelReceived:addDict];
            NSString *name = [userInfo objectForKey:@"name"];
            NSString *alertTitle = [NSString stringWithFormat:@"%@ needs to Update the App Version",name];
            [self showLogNotification:alertTitle:@"Please ask your added driver to update his/her app version to successfully sync data. After updating the version, the driver will need to perform a full sync to send the data to your phone."];

        }

        if([[userInfo objectForKey:@"type"] isEqualToString:@"delete friend"]){

//            NSMutableDictionary *addDict = [[NSMutableDictionary alloc]init];
//            [addDict setObject:[userInfo objectForKey:@"action"] forKey:@"action"];
//            [addDict setObject:[userInfo objectForKey:@"email"] forKey:@"friendEmail"];
//            [addDict setObject:[userInfo objectForKey:@"name"] forKey:@"friendName"];
//            // NSLog(@"addDict for deleteFriend:- %@",addDict);
//            [self reqOrConfirmOrDelReceived:addDict];
            NSString *name = [userInfo objectForKey:@"name"];
            NSString *alertTitle = [NSString stringWithFormat:@"%@ needs to Update the App Version",name];
            [self showLogNotification:alertTitle:@"Please ask your added driver to update his/her app version to successfully sync data. After updating the version, the driver will need to perform a full sync to send the data to your phone."];
        }
        if([[userInfo objectForKey:@"type"] isEqualToString:@"full sync"]){

            NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
            NSMutableDictionary *friendrequest = [[NSMutableDictionary alloc]init];
            NSMutableArray *allFriendRequests = [[NSMutableArray alloc]init];
            [friendrequest setObject:[userInfo objectForKey:@"syncFileName"] forKey:@"syncFileName"];
            [friendrequest setObject:[userInfo objectForKey:@"name"] forKey:@"name"];

            //NSLog(@"addDict for friendSyncRequest:- %@",friendrequest);

            if([def objectForKey:@"syncFriends"] != nil){
                allFriendRequests = [[def objectForKey:@"syncFriends"]mutableCopy];
            }
            for(NSDictionary *dict in allFriendRequests){

                if([[dict objectForKey:@"name"] isEqualToString:[userInfo objectForKey:@"name"]]){
                    // NSLog(@"Same friend again:- %@",dict);
                }else{
                    [allFriendRequests addObject:friendrequest];
                }
            }
            if(allFriendRequests.count==0){
                [allFriendRequests addObject:friendrequest];
            }
            //NSLog(@"allFriendRequests::-%@",allFriendRequests);
            [def setObject:allFriendRequests forKey:@"syncFriends"];

            [def setBool:YES forKey:@"redRequest"];

            NSString* alertBody = [NSString stringWithFormat:@"%@%@",[userInfo objectForKey:@"name"],NSLocalizedString(@"full_sync_request_noti_msg", @" would like to sync his/her Simply Auto data with your device.")];
            [self showNotification:@"Full Sync Request":alertBody];


        }
        if([[userInfo objectForKey:@"type"] isEqualToString:@"0"] || [[userInfo objectForKey:@"type"] isEqualToString:@"1"] || [[userInfo objectForKey:@"type"] isEqualToString:@"2"]){
            //NSLog(@"friend log Pull request received");

            //TO get vehid
//            NSManagedObjectContext *contex = [[CoreDataController sharedInstance] newManagedObjectContext];
//            NSError *err;
//
//            NSFetchRequest *vehRequest = [[NSFetchRequest alloc] initWithEntityName:@"Veh_Table"];
//            NSArray *vehData = [contex executeFetchRequest:vehRequest error:&err];
//            BOOL vehiclePresent = NO;
//            for(Veh_Table *vehicleData in vehData){
//
//                if([[userInfo objectForKey:@"vehid"] isEqualToString:vehicleData.vehid]){
//
//                    // [self performSelectorInBackground:@selector(updateFriendFillUp:) withObject:userInfo];
//                    [[NSUserDefaults standardUserDefaults] setObject:@"pull" forKey:@"responseType"];
//                    [self performSelectorInBackground:@selector(saveResponseToDB) withObject:nil];
//                    vehiclePresent = YES;
//                    break;
//                }else{
//                    vehiclePresent = NO;
//                }
//
//            }
//            if(!vehiclePresent){
//
//                NSString *alertBody = [NSString stringWithFormat:@"%@ not found.",[userInfo objectForKey:@"vehid"]];
//                // NSLocalizedString(@"mi", @"mi")
//                [self showNotification:@"":alertBody];
//            }

            NSString *name = [userInfo objectForKey:@"name"];
            NSString *alertTitle = [NSString stringWithFormat:@"%@ needs to Update the App Version",name];
            [self showLogNotification:alertTitle:@"Please ask your added driver to update his/her app version to successfully sync data. After updating the version, the driver will need to perform a full sync to send the data to your phone."];

        }
        if([[userInfo objectForKey:@"type"] isEqualToString:@"3"]){
            // NSLog(@"friend trip Pull request received");
            //TO get vehid
//            NSManagedObjectContext *contex = [[CoreDataController sharedInstance] newManagedObjectContext];
//            NSError *err;
//
//            NSFetchRequest *vehRequest = [[NSFetchRequest alloc] initWithEntityName:@"Veh_Table"];
//            NSArray *vehData = [contex executeFetchRequest:vehRequest error:&err];
//            BOOL vehiclePresent = NO;
//            for(Veh_Table *vehicleData in vehData){
//
//                if([[userInfo objectForKey:@"vehid"] isEqualToString:vehicleData.vehid]){
//
//                    [self performSelectorInBackground:@selector(updateFriendTrip:) withObject:userInfo];
//                    vehiclePresent = YES;
//                    break;
//                }else{
//                    vehiclePresent = NO;
//                }
//
//            }
//            if(!vehiclePresent){
//                NSString *alertBody = [NSString stringWithFormat:@"%@ not found.",[userInfo objectForKey:@"vehid"]];
//                [self showNotification:@"":alertBody];
//            }
            NSString *name = [userInfo objectForKey:@"name"];
            NSString *alertTitle = [NSString stringWithFormat:@"%@ needs to Update the App Version",name];
            [self showLogNotification:alertTitle:@"Please ask your added driver to update his/her app version to successfully sync data. After updating the version, the driver will need to perform a full sync to send the data to your phone."];
        }

        if(userInfo != nil){
 
            //If GCM response is 'pull'
            if([[userInfo objectForKey:@"type"] isEqualToString:@"pull"]){
               // NSLog(@"Pull request received");
                [[NSUserDefaults standardUserDefaults] setObject:@"pull" forKey:@"responseType"];
                [self performSelectorInBackground:@selector(saveResponseToDB) withObject:nil];
            }
            
            if([[userInfo objectForKey:@"type"] isEqualToString:@"full_pull_silent"]){
                
                [[NSUserDefaults standardUserDefaults] setObject:@"full_pull_silent" forKey:@"responseType"];
                [self performSelectorInBackground:@selector(saveToDBFromFullPullSilent) withObject:nil];
            }
            
            if([[userInfo objectForKey:@"type"] isEqualToString:@"sendreport"]){
  
                [self performSelectorInBackground:@selector(autoReportTriggered) withObject:nil];
            }
        }
        
    });

    dispatch_async(dispatch_get_main_queue(),^{
      completionHandler(UIBackgroundFetchResultNewData);
    });

}

-(void)saveToDBFromFullPullSilent{
    
    [self saveCloudDataInBg:1];
}

-(void)autoReportTriggered{
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    ReportViewController *autoReport = [[ReportViewController alloc]init];
    NSString *timeSelected = [def objectForKey:@"scheduledTime"];
    if(timeSelected != nil || timeSelected.length > 0){
        
        [def setBool:YES forKey:@"sendAutoReport"];
        [autoReport fetchVehiclesData];
        [autoReport fetchvalue:[def objectForKey:@"scheduledTime"]];
        [autoReport callEmailBody];
        
    }
    
}

- (void)saveResponseToDB{
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    //NSMutableDictionary *syncDictionary = [[NSMutableDictionary alloc] init];
    
    NSError *err;
    [dictionary setValue:[def objectForKey:@"UserDeviceId"] forKey:@"androidId"];
    
    NSData *postData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:&err];
    dispatch_async(dispatch_get_main_queue(), ^{

       commonMethods *common = [[commonMethods alloc] init];

        [def setBool:YES forKey:@"updateTimeStamp"];
          //Call 'pull_data_v3.php' with 'androidId' as parameter
          [common saveToCloud:postData urlString:kPullDataScript success:^(NSDictionary *responseDictionary){

              dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

                  //Response dictionary
                  NSLog(@"resposeDict from saveResponseToDB: %@", responseDictionary);

                  if([responseDictionary objectForKey:@"success"] != nil){

                      int success = [[responseDictionary objectForKey:@"success"] intValue];

                      if(success == 1){

                          //'sync_data' has an array of dictionaries which are not yet synced
                          NSArray *responseArray = [responseDictionary objectForKey:@"sync_data"];

                          // NSLog(@"Sync Data arr: %@", responseArray);

                          NSMutableArray *syncedArray = [[NSMutableArray alloc] init];
                          if(responseArray.count > 0){

                              //NSMutableArray *syncedArray = [[NSMutableArray alloc] init];

                              //Loop through the dictionaries in the responseArray
                              for(int i = 0; i < responseArray.count; i++){

                                  if([[[responseArray objectAtIndex:i] objectForKey:@"type"] isEqualToString:@"friend_req"] || [[[responseArray objectAtIndex:i] objectForKey:@"type"] isEqualToString:@"friend_con"] || [[[responseArray objectAtIndex:i] objectForKey:@"type"] isEqualToString:@"friend_del"]){

                                      NSMutableDictionary *addDict = [[NSMutableDictionary alloc]init];
                                      [addDict setObject:[[responseArray objectAtIndex:i] objectForKey:@"type"] forKey:@"action"];
                                      [addDict setObject:[[responseArray objectAtIndex:i] objectForKey:@"uploaded_by"] forKey:@"friendEmail"];
                                      [addDict setObject:[[responseArray objectAtIndex:i] objectForKey:@"sync_with"] forKey:@"friendName"];
                                      [addDict setObject:[[responseArray objectAtIndex:i] objectForKey:@"user_id"] forKey:@"user_id"];
                                      //NSLog(@"addDict for addfriend:- %@",addDict);
                                      [self reqOrConfirmOrDelReceived:addDict];

                                  }

                                  //check for table name
                                  if([[[responseArray objectAtIndex:i] valueForKey:@"table"] isEqualToString:@"VEH_TABLE"]){

                                      //If VEH_TABLE, save to vehicle table
                                      [common saveToVehicleTable:[responseArray objectAtIndex:i]];

                                      NSMutableDictionary *syncedDictionary = [[NSMutableDictionary alloc] init];
                                      //NSMutableArray *syncedArray = [[NSMutableArray alloc] init];

                                      [syncedDictionary setObject:[[responseArray objectAtIndex:i] valueForKey:@"table"] forKey:@"tableName"];
                                      [syncedDictionary setObject:[[responseArray objectAtIndex:i] valueForKey:@"_ID"] forKey:@"rowID"];
                                      [syncedDictionary setObject:[[responseArray objectAtIndex:i] valueForKey:@"type"] forKey:@"type"];
                                      [syncedDictionary setObject:[def objectForKey:@"UserDeviceId"] forKey:@"androidId"];
                                      [syncedArray addObject:syncedDictionary];

                                  } else if ([[[responseArray objectAtIndex:i] valueForKey:@"table"] isEqualToString:@"LOG_TABLE"]){

                                      //If LOG_TABLE, save to T_Fuelcons table
                                      [common saveToLogTable:[responseArray objectAtIndex:i]];

                                      if([[[responseArray objectAtIndex:i] valueForKey:@"sync_with"] isEqualToString:@"friend"]){

                                          // NSLog(@"Don't do else part as it will be done inside saveToLogTable");
                                      }else{

                                          NSMutableDictionary *syncedDictionary = [[NSMutableDictionary alloc] init];

                                          [syncedDictionary setObject:[[responseArray objectAtIndex:i] valueForKey:@"table"] forKey:@"tableName"];
                                          [syncedDictionary setObject:[[responseArray objectAtIndex:i] valueForKey:@"_ID"] forKey:@"rowID"];
                                          [syncedDictionary setObject:[[responseArray objectAtIndex:i] valueForKey:@"type"] forKey:@"type"];
                                          [syncedDictionary setObject:[def objectForKey:@"UserDeviceId"] forKey:@"androidId"];
                                          [syncedDictionary setObject:[[responseArray objectAtIndex:i] valueForKey:@"user_id"] forKey:@"userID"];
                                          [syncedArray addObject:syncedDictionary];
                                      }



                                  } else if ([[[responseArray objectAtIndex:i] valueForKey:@"table"] isEqualToString:@"SERVICE_TABLE"]){

                                      //If SERVICE_TABLE, save to services
                                      [common saveToServiceTable:[responseArray objectAtIndex:i]];

                                      NSMutableDictionary *syncedDictionary = [[NSMutableDictionary alloc] init];
                                      //NSMutableArray *syncedArray = [[NSMutableArray alloc] init];

                                      [syncedDictionary setObject:[[responseArray objectAtIndex:i] valueForKey:@"table"] forKey:@"tableName"];
                                      [syncedDictionary setObject:[[responseArray objectAtIndex:i] valueForKey:@"_ID"] forKey:@"rowID"];
                                      [syncedDictionary setObject:[[responseArray objectAtIndex:i] valueForKey:@"type"] forKey:@"type"];
                                      [syncedDictionary setObject:[def objectForKey:@"UserDeviceId"] forKey:@"androidId"];
                                      [syncedDictionary setObject:[[responseArray objectAtIndex:i] valueForKey:@"user_id"] forKey:@"userID"];
                                      [syncedArray addObject:syncedDictionary];

                                  } else if ([[[responseArray objectAtIndex:i] valueForKey:@"table"] isEqualToString:@"LOC_TABLE"]){

                                      //If LOC_TABLE, save to location table
                                      [common saveToLocationTable:[responseArray objectAtIndex:i]];

                                      NSMutableDictionary *syncedDictionary = [[NSMutableDictionary alloc] init];
                                      //NSMutableArray *syncedArray = [[NSMutableArray alloc] init];

                                      [syncedDictionary setObject:[[responseArray objectAtIndex:i] valueForKey:@"table"] forKey:@"tableName"];
                                      [syncedDictionary setObject:[[responseArray objectAtIndex:i] valueForKey:@"_ID"] forKey:@"rowID"];
                                      [syncedDictionary setObject:[[responseArray objectAtIndex:i] valueForKey:@"type"] forKey:@"type"];
                                      [syncedDictionary setObject:[def objectForKey:@"UserDeviceId"] forKey:@"androidId"];
                                      [syncedDictionary setObject:[[responseArray objectAtIndex:i] valueForKey:@"user_id"] forKey:@"userID"];
                                      [syncedArray addObject:syncedDictionary];

                                  } else if ([[[responseArray objectAtIndex:i] valueForKey:@"table"] isEqualToString:@"SETTINGS"]){

                                      //If SETTINGS, make changes to SETTINGS
                                      [common saveSettings:[responseArray objectAtIndex:i]];

                                      NSMutableDictionary *syncedDictionary = [[NSMutableDictionary alloc] init];
                                      //NSMutableArray *syncedArray = [[NSMutableArray alloc] init];

                                      [syncedDictionary setObject:[[responseArray objectAtIndex:i] valueForKey:@"table"] forKey:@"tableName"];
                                      [syncedDictionary setObject:[[responseArray objectAtIndex:i] valueForKey:@"_ID"] forKey:@"rowID"];
                                      [syncedDictionary setObject:[[responseArray objectAtIndex:i] valueForKey:@"type"] forKey:@"type"];
                                      [syncedDictionary setObject:[def objectForKey:@"UserDeviceId"] forKey:@"androidId"];
                                      [syncedDictionary setObject:[[responseArray objectAtIndex:i] valueForKey:@"user_id"] forKey:@"userID"];
                                      [syncedArray addObject:syncedDictionary];
                                  }
                              }

                              if(syncedArray.count>0){

                                //  NSLog(@"Show success notification successfully saved data with no error");
                                  //TODO ask for msgs
                               //   [self showNotification:@"Success" :@"Data saved successfully"];
                                  [common clearCloudSyncTable:syncedArray];
                              }

                              //To show spinner in status bar, hope this works
                              dispatch_async(dispatch_get_main_queue(), ^{

                                  [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                  //            AppDelegate *appd = [[AppDelegate alloc]init];
                                  //            UIView *topView = appd.topView;

                                  UIViewController *currentViewController = [self topViewController];
                                  if([currentViewController isKindOfClass:[Autorotate class]] || [currentViewController isKindOfClass:[UIAlertController class]]){

                                      // NSLog(@"Yes it is [MainScreenViewController class]");
                                      [[NSNotificationCenter defaultCenter] postNotificationName:@"mainScreenRefreshData"
                                                                                          object:nil];
                                  }

                              });

                          }

                      }else{

                        //  NSLog(@"Show Fail notification success = 0");
                          //TODO ask for msgs
                          [self showNotification:@"Failed" :@"Failed to sync data"];

                      }
                  }

              });


          } failure:^(NSError *error){
        //      NSLog(@"%@", error.localizedDescription);
          }];
    });


}

- (UIViewController *)topViewController{
    return [self topViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

- (UIViewController *)topViewController:(UIViewController *)rootViewController
{
    if (rootViewController.presentedViewController == nil) {
        return rootViewController;
    }

    if ([rootViewController.presentedViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)rootViewController.presentedViewController;
        UIViewController *lastViewController = [[navigationController viewControllers] lastObject];

        if([lastViewController isKindOfClass:[UIAlertController class]]){

            lastViewController = [[navigationController viewControllers] objectAtIndex:[navigationController viewControllers].count-1];

        }
        return [self topViewController:lastViewController];
    }

    UIViewController *presentedViewController = (UIViewController *)rootViewController.presentedViewController;
    return [self topViewController:presentedViewController];
}

- (void)saveCloudDataInBg: (int)DBDeletionFlag{ 
    
    //NSLog(@"DBDeletionFlag:- %i",DBDeletionFlag);
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    //NSMutableDictionary *syncDictionary = [[NSMutableDictionary alloc] init];
    
    NSError *err;
    [dictionary setValue:[def objectForKey:@"UserDeviceId"] forKey:@"androidId"];
    
    NSData *postData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:&err];
    
    commonMethods *common = [[commonMethods alloc] init];
    [def setBool:YES forKey:@"updateTimeStamp"];
    //Call 'pull_data_v3.php' with 'androidId' as parameter
    [common saveToCloud:postData urlString:kPullDataScript success:^(NSDictionary *responseDict) {
        
        NSArray *responseKeys = [responseDict allKeys];
        //NSLog(@"reponseKeys : %@", responseKeys);
        if([[responseDict objectForKey:@"success"] intValue] > 0){
             
            //printf("full pull silent data : %s", [[NSString stringWithFormat:@"%@", responseDict] UTF8String]);
            if(DBDeletionFlag == 1){
            
                [common deleteAllTablesFromDB];
            }
            //TEST BUG_149 download alert
            NSMutableArray *responseData = [responseDict objectForKey:@"sync_data"];
           // NSLog(@"sync data dict : %@", responseData);
            NSMutableArray *syncedArray = [[NSMutableArray alloc] init];
            if(responseData.count > 0){
                    
                for (int i = 0; i < responseData.count; i++) {
                    
                        [common saveFromCloudToLocalDB:[responseData objectAtIndex:i]];
                    
                        NSMutableDictionary *syncedDictionary = [[NSMutableDictionary alloc] init];
                        //NSMutableArray *syncedArray = [[NSMutableArray alloc] init];
                    
                        [syncedDictionary setObject:[[responseData objectAtIndex:i] valueForKey:@"table"] forKey:@"tableName"];
                        [syncedDictionary setObject:[[responseData objectAtIndex:i] valueForKey:@"_ID"] forKey:@"rowID"];
                        [syncedDictionary setObject:[[responseData objectAtIndex:i] valueForKey:@"type"] forKey:@"type"];
                        [syncedDictionary setObject:[def objectForKey:@"UserDeviceId"] forKey:@"androidId"];
                        [syncedDictionary setObject:[[responseData objectAtIndex:i] valueForKey:@"user_id"] forKey:@"userID"];
                        [syncedArray addObject:syncedDictionary];
                        //NSLog(@"sync data dict : %@", syncedArray);

                }
            
            }
            
           // printf("sync arr to b deleted : %s", [[NSString stringWithFormat:@"%@", syncedArray] UTF8String]);
            int deleteSyncStatus = [common clearCloudSyncTable:syncedArray];
            
            if(deleteSyncStatus == 1 && [responseKeys containsObject:@"to_be_continued"]){
                
                //DBDeletionFlag = 0;
                [self saveCloudDataInBg:0];
            }
            
        }
        
        //[[NSNotificationCenter defaultCenter] postNotificationName:@"logFinish" object:nil];
        //[self performSelectorInBackground:@selector(notifyFinish) withObject:nil];
        [self performSelectorOnMainThread:@selector(notifyFinish) withObject:nil waitUntilDone:NO];
        
        
    } failure:^(NSError *error) {
        
 //       NSLog(@"failed to get response");
    }];
    
}

-(void)checkTimeStampAfterWakeUp{
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *parametersDictionary = [[NSMutableDictionary alloc] init];
    [parametersDictionary setObject:[def objectForKey:@"UserEmail"] forKey:@"email1"];
    NSDate *stringDate = [def objectForKey:@"localTimeStamp"];
    if(stringDate != nil){
        
        NSTimeInterval unixTimeStamp = [stringDate timeIntervalSince1970];
        NSString *unixTime = [NSString stringWithFormat:@"%f", unixTimeStamp];
        NSString *sendDate = [unixTime substringToIndex:10];
        [parametersDictionary setObject:sendDate forKey:@"time_stamp"];
        
        
        NSError *err;
        NSData *postDataArray = [NSJSONSerialization dataWithJSONObject:parametersDictionary options:NSJSONWritingPrettyPrinted error:&err];
        
        [def setBool:NO forKey:@"updateTimeStamp"];
        commonMethods *common = [[commonMethods alloc] init];
        [common saveToCloud:postDataArray urlString:kAppKillTimeStampCheckScript success:^(NSDictionary *responseDict) {
            
            // NSLog(@"ResponseDict is : %@", responseDict);
            
            if([[responseDict valueForKey:@"success"]  isEqual: @1]){
                
                [def setBool:YES forKey:@"newDataAvailable"];
                
                [self saveResponseToDB];
                
            }
            
        } failure:^(NSError *error) {
            
            // NSLog(@"response failed");
        }];
    }
    
    
}



- (void)notifyFinish{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"logFinish" object:nil];
    //NIKHIL BUG_154
    [[CoreDataController sharedInstance] saveMasterContext];
}

#pragma mark Driver Server Related Methods

//add driver scene
-(void)reqOrConfirmOrDelReceived: (NSMutableDictionary *)addDict{
    
    NSString *requestAction = @"friend_req";
    NSString *confirmAction = @"friend_con";
    NSString *deleteAction = @"friend_del";
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    //NSLog(@"response dict is %@",addDict);
    if ([[addDict objectForKey:@"action"] isEqualToString: requestAction]) {
        
        //NSLog(@"Friend request received");
        [self saveToFriendTable: addDict];
        NSString *alertBody = [NSString stringWithFormat:@"%@%@",[addDict objectForKey:@"friendName"],NSLocalizedString(@"sync_friend_req", @" wants to add you as a driver")];

        [self showNotification:NSLocalizedString(@"sync_friend_req_title",@"Driver Request"):alertBody];
        
    }else if([[addDict objectForKey:@"action"] isEqualToString: confirmAction]){
        //"sync_friend_confirmed"=" has confirmed as a driver"
        //NSLog(@"Friend confirmation received");
        [self editFriendRecord: addDict];
         NSString *alertBody = [NSString stringWithFormat:@"%@%@",[addDict objectForKey:@"friendName"],NSLocalizedString(@"sync_friend_confirmed", @"  has confirmed as a driver")];
      
        [self showNotification:NSLocalizedString(@"sync_friend_confirmed_title",@"Driver Confirmed"):alertBody];
   
    }else if([[addDict objectForKey:@"action"] isEqualToString: deleteAction]){
        //"sync_friend_deleted"=" has deleted you as a driver";
        //NSLog(@"Delete confirmation received");
        [self deleteRecord: addDict];
        NSString *alertBody = [NSString stringWithFormat:@"%@%@",[addDict objectForKey:@"friendName"],NSLocalizedString(@"sync_friend_deleted", @" has deleted you as a driver")];
        
        [self showNotification:NSLocalizedString(@"sync_friend_confirmed_title",@"Driver Deleted"):alertBody];
       
    }

    NSMutableArray *syncedArray = [[NSMutableArray alloc] init];
    NSMutableDictionary *syncedDictionary = [[NSMutableDictionary alloc] init];
    [syncedDictionary setObject:@"FRIENDS" forKey:@"tableName"];
    [syncedDictionary setObject:@(0) forKey:@"rowID"];
    [syncedDictionary setObject:[addDict valueForKey:@"action"] forKey:@"type"];
    [syncedDictionary setObject:[addDict objectForKey:@"user_id"] forKey:@"userID"];
    [syncedDictionary setObject:[def objectForKey:@"UserDeviceId"] forKey:@"androidId"];
    [syncedArray addObject:syncedDictionary];
    commonMethods *common = [[commonMethods alloc] init];
    [common clearCloudSyncTable:syncedArray];
}

-(void)showNotification:(NSString *)alertTitle :(NSString *)alertBody{
    
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc]init];
    
    content.title = alertTitle;
    content.body = alertBody;
    content.sound = [UNNotificationSound defaultSound];
    
    UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:1 repeats:NO];
    
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"UYlocalNotification" content:content trigger:trigger];
    
    [center addNotificationRequest:request withCompletionHandler:nil];
    
    [[NSUserDefaults standardUserDefaults] setInteger:2 forKey:@"showPage"];
    
}

-(void)showTripCountNotification:(NSString *)alertTitle :(NSString *)alertBody{
    
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc]init];
    
    content.title = alertTitle;
    content.body = alertBody;
    content.sound = [UNNotificationSound defaultSound];
    
    UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:1 repeats:NO];
    
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"tripRemainingNotification" content:content trigger:trigger];
    
    [center addNotificationRequest:request withCompletionHandler:nil];
    
    [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"showPage"];
    
}

-(void)showLogNotification:(NSString *)alertTitle :(NSString *)alertBody{

    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];

    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc]init];

    content.title = alertTitle;
    content.body = alertBody;
    content.sound = [UNNotificationSound defaultSound];

    UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:1 repeats:NO];

    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"logNotification" content:content trigger:trigger];

    [center addNotificationRequest:request withCompletionHandler:nil];

    [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"showPage"];

}

-(void)showLogNotificationForPro:(NSString *)alertTitle :(NSString *)alertBody{

    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];

    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc]init];

    content.title = alertTitle;
    content.body = alertBody;
    content.sound = [UNNotificationSound defaultSound];

    UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:1 repeats:NO];

    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"proNotification" content:content trigger:trigger];

    [center addNotificationRequest:request withCompletionHandler:nil];

    [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"showPage"];

}

-(BOOL)checkOdo:(float)iOdo ForDate:(NSDate*)iDate
{
    //Swapnil BUG_76
    commonMethods *commMethod = [[commonMethods alloc] init];
    BOOL valuesOK = [commMethod checkOdo:iOdo ForDate:iDate];
    return valuesOK;
    
}

-(void)updateFriendFillUp:(NSDictionary *)userInfo{

    FillUpDataHandler *updRecord = [[FillUpDataHandler alloc]init];
    
    if([[userInfo objectForKey:@"action"] isEqualToString:@"add"]){
        
        float iOdo = [[userInfo objectForKey:@"odo"] floatValue];
        
        double convertDate = [[userInfo objectForKey:@"date"] doubleValue]/1000;
        NSTimeInterval timestamp = (NSTimeInterval)convertDate;
        NSDate *convertedDate = [NSDate dateWithTimeIntervalSince1970:timestamp];
        
        if([self checkOdo:iOdo ForDate:convertedDate]){
        
             updRecord.iD = [userInfo objectForKey:@"id"];
             updRecord.vehid = [userInfo objectForKey:@"vehid"];
             updRecord.odo = [userInfo objectForKey:@"odo"];
             updRecord.qty = [userInfo objectForKey:@"qty"];
             updRecord.cost = [userInfo objectForKey:@"cost"];
             updRecord.octane = [userInfo objectForKey:@"octane"];
             updRecord.fuelBrand = [userInfo objectForKey:@"fuelBrand"];
             updRecord.fillStation = [userInfo objectForKey:@"fillStation"];
             updRecord.notes = [userInfo objectForKey:@"notes"];
             updRecord.pfill = [userInfo objectForKey:@"pfill"];
             updRecord.mfill = [userInfo objectForKey:@"mfill"];
             updRecord.type = [userInfo objectForKey:@"type"];
             updRecord.serviceType = [userInfo objectForKey:@"serviceType"];
             updRecord.stringDate = [userInfo objectForKey:@"date"];
             updRecord.day = [userInfo objectForKey:@"day"];
             updRecord.month = [userInfo objectForKey:@"month"];
             updRecord.year = [userInfo objectForKey:@"year"];
             updRecord.latitude = [userInfo objectForKey:@"depLat"];
             updRecord.longitude = [userInfo objectForKey:@"depLong"];
        
             [updRecord addFillUp:0];
             NSString *alertTitle = @"Record Synced";
             NSString *alertBody;
             NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
            
            if([[userInfo objectForKey:@"type"] isEqualToString:@"0"]){
            
                NSString* alertBody1 = [NSString stringWithFormat:@"%@ has just filled up %@\nPrice: %@ %@",[userInfo objectForKey:@"name"],[userInfo objectForKey:@"vehid"],[def objectForKey:@"curr_unit"],[userInfo objectForKey:@"cost"]];
                alertBody = [NSString stringWithString:alertBody1];
                
            }else if([[userInfo objectForKey:@"type"] isEqualToString:@"1"]){
            
                NSString* alertBody1 = [NSString stringWithFormat:@"%@ has just serviced %@\nServices: %@",[userInfo objectForKey:@"name"],[userInfo objectForKey:@"vehid"],[userInfo objectForKey:@"serviceType"]];
                alertBody = [NSString stringWithString:alertBody1];
                
            }else if([[userInfo objectForKey:@"type"] isEqualToString:@"2"]){
                
                NSString* alertBody1 = [NSString stringWithFormat:@"%@ has just added an expense for %@\Expenses: %@",[userInfo objectForKey:@"name"],[userInfo objectForKey:@"vehid"],[userInfo objectForKey:@"serviceType"]];
                alertBody = [NSString stringWithString:alertBody1];
            }
            
             [self showLogNotification:alertTitle :alertBody];

        }else{
            //
            NSString *alertTitle = NSLocalizedString(@"sync_failed", @"Sync Failed");
            NSString *alertBody = [NSString stringWithFormat:@"Failed to sync data from %@",[userInfo objectForKey:@"name"]];
            [self showLogNotification:alertTitle :alertBody];
            
        }
     
    }else if([[userInfo objectForKey:@"action"] isEqualToString:@"update"]){
        
          //NSLog(@"userinfo:- %@",userInfo);
        
        float iOdo = [[userInfo objectForKey:@"odo"] floatValue];
        
        double convertDate = [[userInfo objectForKey:@"date"] doubleValue]/1000;
        NSTimeInterval timestamp = (NSTimeInterval)convertDate;
        NSDate *convertedDate = [NSDate dateWithTimeIntervalSince1970:timestamp];
        
        if([self checkOdo:iOdo ForDate:convertedDate]){
            
           NSString *alertTitle = @"Record Synced";
           NSString *alertBody;
           [updRecord editFillUp:userInfo :0];
            
            if([[userInfo objectForKey:@"type"] isEqualToString:@"0"]){
                
                alertBody = [NSString stringWithFormat:@"%@ just updated a fill up for %@",[userInfo objectForKey:@"name"],[userInfo objectForKey:@"vehid"]];
               
            }else if([[userInfo objectForKey:@"type"] isEqualToString:@"1"]){
               
                alertBody = [NSString stringWithFormat:@"%@ just updated a service for %@",[userInfo objectForKey:@"name"],[userInfo objectForKey:@"vehid"]];
                
            }else if([[userInfo objectForKey:@"type"] isEqualToString:@"2"]){
                
                alertBody = [NSString stringWithFormat:@"%@ just updated a expense for %@",[userInfo objectForKey:@"name"],[userInfo objectForKey:@"vehid"]];
            }
                
             [self showLogNotification:alertTitle :alertBody];
        }else{
            
            NSString *alertTitle = NSLocalizedString(@"sync_failed", @"Sync Failed");
            NSString *alertBody = [NSString stringWithFormat:@"Failed to sync data from %@",[userInfo objectForKey:@"name"]];
            [self showLogNotification:alertTitle :alertBody];
            
        }
        
    }else if([[userInfo objectForKey:@"action"] isEqualToString:@"delete"]){
        
          //NSLog(@"userinfo:- %@",userInfo);
        
        updRecord.iD = [userInfo objectForKey:@"id"];
        updRecord.vehid = [userInfo objectForKey:@"vehid"];
        updRecord.odo = [userInfo objectForKey:@"odo"];
        updRecord.type = [userInfo objectForKey:@"type"];
        updRecord.serviceType = [userInfo objectForKey:@"serviceType"];
       
        [updRecord deleteFillUp:0];
        //Mrigaen just deleted a fill up for SL350
        NSString *alertTitle = @"Record Synced";
        NSString *alertBody;
        if([[userInfo objectForKey:@"type"] isEqualToString:@"0"]){
            
            alertBody = [NSString stringWithFormat:@"%@ just deleted a fill up for %@",[userInfo objectForKey:@"name"],[userInfo objectForKey:@"vehid"]];
            
        }else if([[userInfo objectForKey:@"type"] isEqualToString:@"1"]){
            
            alertBody = [NSString stringWithFormat:@"%@ just deleted a service for %@",[userInfo objectForKey:@"name"],[userInfo objectForKey:@"vehid"]];
            
        }else if([[userInfo objectForKey:@"type"] isEqualToString:@"2"]){
            
            alertBody = [NSString stringWithFormat:@"%@ just deleted a expense for %@",[userInfo objectForKey:@"name"],[userInfo objectForKey:@"vehid"]];
        }
        [self showLogNotification:alertTitle :alertBody];
        
    }
    
    
}

-(void)updateFriendTrip:(NSDictionary *)userInfo{
    
    
    //NSLog(@"user info:- %@",userInfo);
    
    TripDataHandler *updRecord = [[TripDataHandler alloc]init];
    
    if([[userInfo objectForKey:@"action"] isEqualToString:@"add"]){
        float depOdo = [[userInfo objectForKey:@"odo"] floatValue];
        if(depOdo && depOdo != 0.00){
        
            updRecord.iD = [userInfo objectForKey:@"id"];
            updRecord.vehId = [userInfo objectForKey:@"vehid"];
            updRecord.depOdo = [userInfo objectForKey:@"odo"];
            updRecord.arrOdo = [userInfo objectForKey:@"qty"];
            updRecord.taxDedn = [userInfo objectForKey:@"cost"];
            updRecord.arrDate = [userInfo objectForKey:@"octane"];
            updRecord.depLocn = [userInfo objectForKey:@"fuelBrand"];
            updRecord.arrLocn = [userInfo objectForKey:@"fillStation"];
            updRecord.notes = [userInfo objectForKey:@"notes"];
            updRecord.tripType = [userInfo objectForKey:@"serviceType"];
            updRecord.depDate = [userInfo objectForKey:@"date"];
            updRecord.parkingAmt = [userInfo objectForKey:@"OT"];
            updRecord.tollAmt = [userInfo objectForKey:@"year"];
        
            [updRecord addTrip:0];
            
            NSString *alertTitle = @"Record Synced";
            NSString *alertBody = [NSString stringWithFormat:@"%@ has just added a trip for %@",[userInfo objectForKey:@"name"],[userInfo objectForKey:@"vehid"]];
            [self showLogNotification:alertTitle :alertBody];
        
        }else{
            
            NSString *alertTitle = NSLocalizedString(@"sync_failed", @"Sync Failed");
            NSString *alertBody = [NSString stringWithFormat:@"Failed to sync data from %@",[userInfo objectForKey:@"name"]];
            [self showLogNotification:alertTitle :alertBody];
            
        }
        
    }else if([[userInfo objectForKey:@"action"] isEqualToString:@"update"]){
        
        //NSLog(@"userinfo:- %@",userInfo);
        
        float arrODo = [[userInfo objectForKey:@"qty"] floatValue];
        if(arrODo && arrODo != 0.00){
        
           [updRecord editTrip:userInfo :0];
            
            NSString *alertTitle = @"Record Synced";
            NSString *alertBody = [NSString stringWithFormat:@"%@ has just updated a trip for %@",[userInfo objectForKey:@"name"],[userInfo objectForKey:@"vehid"]];
            [self showLogNotification:alertTitle :alertBody];
            
            
        }else{
            
            NSString *alertTitle = NSLocalizedString(@"sync_failed", @"Sync Failed");
            NSString *alertBody = [NSString stringWithFormat:@"Failed to sync data from %@",[userInfo objectForKey:@"name"]];
            [self showLogNotification:alertTitle :alertBody];
            
        }
        
    }else if([[userInfo objectForKey:@"action"] isEqualToString:@"delete"]){
        
        //NSLog(@"userinfo:- %@",userInfo);
        
        updRecord.iD = [userInfo objectForKey:@"id"];
        updRecord.vehId = [userInfo objectForKey:@"vehid"];
        updRecord.depOdo = [userInfo objectForKey:@"odo"];
        updRecord.tripType = [userInfo objectForKey:@"serviceType"];
        
        [updRecord deleteTrip:0];
        
        NSString *alertTitle = @"Record Synced";
        NSString *alertBody = [NSString stringWithFormat:@"%@ has just deleted a trip for %@",[userInfo objectForKey:@"name"],[userInfo objectForKey:@"vehid"]];
        [self showLogNotification:alertTitle :alertBody];
    }
}

-(void)saveToFriendTable:(NSMutableDictionary *)friendDict {
    
    NSManagedObjectContext *context = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSError *err;
    NSString *comparestring = [NSString stringWithFormat:@"%@",[friendDict objectForKey:@"friendEmail"]];
    NSFetchRequest *request=[[NSFetchRequest alloc] initWithEntityName:@"Friends_Table"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"email==%@",comparestring];
    [request setPredicate:predicate];
    NSArray *datavalue=[context executeFetchRequest:request error:&err];
    //NSLog(@"friend is there? ::%@",datavalue);
    Friends_Table *delRecord = [datavalue firstObject];
    //if datavalue is nil means no record found for current mail, friend is new
    if(delRecord == nil){
    
       Friends_Table *friendData = [NSEntityDescription insertNewObjectForEntityForName:@"Friends_Table" inManagedObjectContext:context];
    
        // NSLog(@"response Array is::%@",self.friendDictionary);
        if(![[friendDict objectForKey:@"friendEmail"] isEqual:@""]){
            friendData.name = [friendDict objectForKey:@"friendName"];
            friendData.email = [friendDict objectForKey:@"friendEmail"];

            if([[friendDict objectForKey:@"action"] isEqualToString:@"friend_req"]){

                friendData.status = @"request";
            }else if([[friendDict objectForKey:@"action"] isEqualToString:@"friend_con"]){

                friendData.status = @"confirm";
            }else if([[friendDict objectForKey:@"action"] isEqualToString:@"friend_del"]){

                friendData.status = @"delete";
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
      }
}

-(void)editFriendRecord: (NSMutableDictionary *)friendDict{
    
    NSManagedObjectContext *contex = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSError *err;
    NSString *comparestring = [NSString stringWithFormat:@"%@",[friendDict objectForKey:@"friendEmail"]];
    
    
    NSFetchRequest *request=[[NSFetchRequest alloc] initWithEntityName:@"Friends_Table"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"email==%@",comparestring];
    [request setPredicate:predicate];
    
    NSArray *datavalue=[contex executeFetchRequest:request error:&err];

    if(datavalue.count > 0){

        if(friendDict.count > 0){

            Friends_Table *updRecord = [datavalue firstObject];

            updRecord.name = [friendDict objectForKey:@"friendName"];
            updRecord.email = [friendDict objectForKey:@"friendEmail"];
            if([[friendDict objectForKey:@"action"] isEqualToString:@"friend_req"]){

                updRecord.status = @"request";
            }else if([[friendDict objectForKey:@"action"] isEqualToString:@"friend_con"]){

                updRecord.status = @"confirm";
            }else if([[friendDict objectForKey:@"action"] isEqualToString:@"friend_del"]){

                updRecord.status = @"delete";
            }

            if ([contex hasChanges])
            {
                BOOL saved = [contex save:&err];
                if (!saved) {
                    // do some real error handling
                    //CLSLog(@“Could not save Data due to %@“, error);
                }
                [[CoreDataController sharedInstance] saveMasterContext];
            }
        }


    }

    
}

-(void)deleteRecord:(NSMutableDictionary *)deleteFriend{
    
    NSManagedObjectContext *context = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSError *error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Friends_Table"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"email == %@",[deleteFriend objectForKey:@"friendEmail"]];
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
        [[CoreDataController sharedInstance] saveMasterContext];
    }
    
}



- (void)applicationReceivedRemoteMessage:(nonnull FIRMessagingRemoteMessage *)remoteMessage{
    
    //NSLog(@"userInfo : %@", remoteMessage);
}

- (void)messaging:(nonnull FIRMessaging *)messaging didRefreshRegistrationToken:(nonnull NSString *)fcmToken
{
    // Note that this callback will be fired everytime a new token is generated, including the first
    // time. So if you need to retrieve the token as soon as it is available this is where that
    // should be done.
    //NSLog(@"FCM registration token: %@", fcmToken);
    
    // TODO: If necessary send token to application server.

    NSString* userRegId = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserRegId"];
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    if (![userRegId isEqualToString:fcmToken])
    {
        
        [def setObject:fcmToken forKey:@"UserRegId"];
        SignInCloudViewController *signInVC = [[SignInCloudViewController alloc] init];
        [signInVC getName:[def objectForKey:@"UserName"] email:[def objectForKey:@"UserEmail"]];
    }
    
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{

    [FIRMessaging messaging].APNSToken = deviceToken;
    //[[FIRInstanceID instanceID] setAPNSToken:deviceToken type:FIRInstanceIDAPNSTokenTypeProd];
    //[[FIRInstanceID instanceID] setAPNSToken:deviceToken type:FIRInstanceIDAPNSTokenTypeSandbox];

    //NSLog(@"deviceToken : %@", deviceToken);
    //NSLog(@"[FIRInstanceID instanceID] : %@", [FIRInstanceID instanceID]);
}




//
//- (void)connectToFirebase{
//    
//    [[FIRMessaging messaging] connectWithCompletion:^(NSError * _Nullable error) {
//        
//        if(error != nil){
//            NSLog(@"cant connect to fcm : %@", error);
//        } else {
//            NSLog(@"connected to fcm");
//        }
//    }];
//}
//
- (void)tokenRefreshCallback: (NSNotification *)notification{
    
    
    
   // NSLog(@"instanceId notification : %@", [notification object]);

    [[FIRInstanceID instanceID] instanceIDWithHandler:^(FIRInstanceIDResult * _Nullable result,
                                                        NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Error fetching remote instance ID: %@", error);
        } else {
            //NSString *fcmToken = [[FIRInstanceID instanceID] token];
            NSString *refreshedToken = result.token;
           // NSString *refreshedToken = [[FIRInstanceID instanceID] token];
            //NSLog(@"instance id token : %@", refreshedToken);
            NSString* userRegId = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserRegId"];
            NSUserDefaults *def = [NSUserDefaults standardUserDefaults];

            if(userRegId != nil){

                if (![userRegId isEqualToString:refreshedToken])
                {

                    [def setObject:refreshedToken forKey:@"UserRegId"];
                    SignInCloudViewController *signInVC = [[SignInCloudViewController alloc] init];
                    [signInVC getName:[def objectForKey:@"UserName"] email:[def objectForKey:@"UserEmail"]];
                }
            }
            //[self connectToFirebase];
        }
    }];

}

#pragma mark


//-(NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
//{
//    if(self.restrictRotation)
//        return UIInterfaceOrientationMaskPortrait;
//    else
//        return UIInterfaceOrientationMaskAll;
//}

//#if __IPHONE_OS_VERSION_MAX_ALLOWED < 90000
//- (NSUInteger) application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
//#else
//    - (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
//#endif
//{
//    NSUInteger orientations = UIInterfaceOrientationMaskAllButUpsideDown;
//    
//    if(self.window.rootViewController){
//        UIViewController *presentedViewController = [[(UINavigationController *)self.window.rootViewController viewControllers] lastObject];
//        orientations = [presentedViewController supportedInterfaceOrientations];
//    }
//    
//    return orientations;
//}

- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary *)options {


    return [[GIDSignIn sharedInstance] handleURL:url];
//    BOOL handled = [[GIDSignIn sharedInstance] handleURL:url sourceApplication:sourceApplication annotation:annotation];
//    return handled;

   // return [[GIDSignIn sharedInstance] handleURL:url
   //                            sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
   //                                   annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
}

//Swapnil NEW_6
//-(void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error{
//    
//    if(error == nil){
//        
//        GIDAuthentication *authentication = user.authentication;
//        FIRAuthCredential *credential = [FIRGoogleAuthProvider credentialWithIDToken:authentication.idToken    accessToken:authentication.accessToken];
//    }
//}
//
//-(void)signIn:(GIDSignIn *)signIn didDisconnectWithUser:(GIDGoogleUser *)user withError:(NSError *)error{
//    
//    NSLog(@"user disconnects from app");
//}


-(UIColor *)colorFromHexString:(NSString *)hexString
{
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

//NIKHIL iPhoneX SYNC Bugs added function to capture X size value
-(CGSize)checkIfiPhoneX
{
    CGSize sizeValue;
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    sizeValue = screenSize;
    return sizeValue;
}


-(void)clickadd
{
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    UIView *topView = window.rootViewController.view;
    
    //NIKHIL iPhoneX SYNC Bugs
    CGSize screenSize = [self checkIfiPhoneX];
    if(self.services.selected==YES)
    {
          result = [[UIScreen mainScreen] bounds].size;
        [self.tabbutton setImage:[UIImage imageNamed:@"tab_add_new"] forState:UIControlStateNormal];

        [self.blurview removeFromSuperview];
         [self animate:self.expense :result.width/2-22 :result.height];
        //[self.expense removeFromSuperview];
         [self animate:self.services :result.width/2-22 :result.height];
        //[self.services removeFromSuperview];
         [self animate:self.fillup :result.width/2-22 :result.height];
       // [self.fillup removeFromSuperview];
        [self animate:self.trip :result.width/2-22 :result.height];
        // [self.fillup removeFromSuperview];
        
        [self.expenselab removeFromSuperview];
        [self.filluplab removeFromSuperview];
        [self.serviceslab removeFromSuperview];
        [self.tripLab removeFromSuperview];
        self.services.selected=NO;
       
    }
    
   else if(self.services.selected ==NO)
    {
    result = [[UIScreen mainScreen] bounds].size;
    topView.backgroundColor =[UIColor clearColor];
    self.blurview = [[UIView alloc]init];
    self.blurview.backgroundColor=[UIColor blackColor];
    self.blurview.alpha=0.8;
    self.blurview.frame = CGRectMake(0,0, result.width,result.height);
    [topView addSubview:self.blurview];
    [self.tabbutton removeFromSuperview];
    self.tabbutton = [[UIButton alloc]init];
        
        
      //NIKHIL iPhoneX SYNC Bugs //x+10, y+32
       UITabBarController *tabBarcontroller = (UITabBarController *)self.window.rootViewController;
       self.tabbutton.frame = CGRectMake(result.width/2-22,tabBarcontroller.tabBar.frame.origin.y, 50, 50);

        //}
    /* Also To check the current device at run time!
    @"iPhone10,3" on iPhone X (CDMA)
    @"iPhone10,6" on iPhone X (GSM)
    NSLog(@"%@",deviceName());
 */
 
    [self.tabbutton setImage:[UIImage imageNamed:@"tab_close"] forState:UIControlStateNormal];
    [self.tabbutton addTarget:self action:@selector(clickadd) forControlEvents:UIControlEventTouchUpInside];
        [topView insertSubview:self.tabbutton aboveSubview:self.blurview];
    self.services = [[UIButton alloc]init];
    self.services.frame = CGRectMake(result.width/2-22,result.height-10, 50, 50);
    [self.services setBackgroundImage:[UIImage imageNamed:@"service_icon"] forState:UIControlStateNormal];
    [self.services addTarget:self action:@selector(addservice) forControlEvents:UIControlEventTouchUpInside];

    [topView addSubview:self.services];
        //NIKHIL iPhoneX SYNC Bugs //x+10, y+32
        if (screenSize.height == 812.0f){
            [self animate:self.services :(result.width/4)-40 :result.height-147];
        }else{
            [self animate:self.services :(result.width/4)-50 :result.height-115];
        //[self animate:self.expense :result.width/2-22 :result.height-200];
        }
        //NSLog(@"Service X coordinate : %f",(result.width/4)-50 );
        
        self.services.selected=YES;
        
        self.fillup = [[UIButton alloc]init];
        self.fillup.frame = CGRectMake(result.width/2-22,result.height, 50, 50);
        [self.fillup setBackgroundImage:[UIImage imageNamed:@"fill_up_icon"] forState:UIControlStateNormal];
        [topView addSubview:self.fillup];
        [self.fillup addTarget:self action:@selector(addfillup) forControlEvents:UIControlEventTouchUpInside];
        
        //NIKHIL iPhoneX SYNC Bugs //x+10, y+32
        if (screenSize.height == 812.0f){
            [self animate:self.fillup :((result.width/4)+32) :result.height-182];
        }else{
        //  [self animate:self.fillup :result.width/2-22 :result.height-150];
            [self animate:self.fillup :((result.width/4)+22) :result.height-150];
        //NSLog(@"Fillup X coordinate : %f",((result.width/4)+22) );
        }
        
        self.trip = [[UIButton alloc]init];
        self.trip.frame = CGRectMake(result.width/2-22,result.height-10, 50, 50);
        [self.trip setBackgroundImage:[UIImage imageNamed:@"trip_icon"] forState:UIControlStateNormal];
        [self.trip addTarget:self action:@selector(addTrip) forControlEvents:UIControlEventTouchUpInside];
        
        [topView addSubview:self.trip];
        
        //NIKHIL iPhoneX SYNC Bugs //x+10, y+32
        if (screenSize.height == 812.0f){
            [self animate:self.trip :(result.width/4)+110 :result.height-182];
        }else{
            [self animate:self.trip :(result.width/4)+100 :result.height-150];
            //NSLog(@"Trip X coordinate : %f",(result.width/4)+100 );
        }
        
        self.expense = [[UIButton alloc]init];
        self.expense.frame = CGRectMake(result.width/2-22,result.height, 50, 50);
        [self.expense setBackgroundImage:[UIImage imageNamed:@"expense_icon"] forState:UIControlStateNormal];
        [topView addSubview:self.expense];
         [self.expense addTarget:self action:@selector(addexpense) forControlEvents:UIControlEventTouchUpInside];
        
        //NIKHIL iPhoneX SYNC Bugs //x+10, y+32
        if (screenSize.height == 812.0f){
            [self animate:self.expense :((result.width/4)+180) :result.height-147];
        }else{
            [self animate:self.expense :((result.width/4)+170) :result.height-115];
       // [self animate:self.services :result.width/2+60 :result.height-115];
        //NSLog(@"expense_icon X coordinate : %f",((result.width/4)+ 170));
        }
        
        
        
        
        self.serviceslab = [[UILabel alloc]init];
//        self.expenselab.frame = CGRectMake(result.width/2-115,result.height-65, 80, 20);
        //NIKHIL iPhoneX SYNC Bugs //x+10, y+32
        if (screenSize.height == 812.0f){
            self.serviceslab.frame = CGRectMake((result.width/4)-55,result.height-97, 80, 20);
        }else{
            self.serviceslab.frame = CGRectMake((result.width/4)-65,result.height-65, 80, 20);
        }
        self.serviceslab.text = NSLocalizedString(@"view_service", @"Service");
        [self.serviceslab setFont:[UIFont systemFontOfSize:9]];
        self.serviceslab.textAlignment = NSTextAlignmentCenter;
        self.serviceslab.textColor = [UIColor whiteColor];
        [topView addSubview:self.serviceslab];
        
        self.filluplab = [[UILabel alloc]init];
        
        //NIKHIL iPhoneX SYNC Bugs //x+10, y+32
        if (screenSize.height == 812.0f){
            self.filluplab.frame = CGRectMake((result.width/4)+ 20,result.height-132, 80, 20);
        }else{
           self.filluplab.frame = CGRectMake((result.width/4)+ 10,result.height-100, 80, 20);
        }
        self.filluplab.text = NSLocalizedString(@"view_fill_up", @"Fill-Up");
        self.filluplab.textAlignment = NSTextAlignmentCenter;
        [self.filluplab setFont:[UIFont systemFontOfSize:9]];
        self.filluplab.textColor = [UIColor whiteColor];
        [topView addSubview:self.filluplab];
        
        self.tripLab = [[UILabel alloc]init];
        
        //NIKHIL iPhoneX SYNC Bugs //x+10, y+32
        if (screenSize.height == 812.0f){
            self.tripLab.frame = CGRectMake((result.width/4)+95,result.height-132, 80, 20);
        }else{
        self.tripLab.frame = CGRectMake((result.width/4)+85,result.height-100, 80, 20);
        }
        self.tripLab.text =NSLocalizedString(@"trp", @"Trip");
        self.tripLab.textAlignment = NSTextAlignmentCenter;
        [self.tripLab setFont:[UIFont systemFontOfSize:9]];
        self.tripLab.textColor = [UIColor whiteColor];
        [topView addSubview:self.tripLab];

        
        self.expenselab = [[UILabel alloc]init];
        
        //NIKHIL iPhoneX SYNC Bugs //x+10, y+32
        if (screenSize.height == 812.0f){
            self.expenselab.frame = CGRectMake((result.width/4)+ 165,result.height-97, 80, 20);
        }else{
            self.expenselab.frame = CGRectMake((result.width/4)+ 155,result.height-65, 80, 20);
        }
        self.expenselab.text = NSLocalizedString(@"view_expense", @"Expense");
        self.expenselab.textAlignment = NSTextAlignmentCenter;
        [self.expenselab setFont:[UIFont systemFontOfSize:9]];
        self.expenselab.textColor = [UIColor whiteColor];
        [topView addSubview:self.expenselab];

    }
}

/* //To check current Device name
NSString* deviceName()
{
    struct utsname systemInfo;
    uname(&systemInfo);
    
    return [NSString stringWithCString:systemInfo.machine
                              encoding:NSUTF8StringEncoding];
    
}*/

-(void)addfillup
{
    [self dismissLabs];
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
    AddFillupViewController *addfillup = (AddFillupViewController *)[mainStoryboard instantiateViewControllerWithIdentifier:@"addfillup"];
    #define ROOTVIEW [[[UIApplication sharedApplication] keyWindow] rootViewController]
    addfillup.modalPresentationStyle = UIModalPresentationFullScreen;
    [ROOTVIEW presentViewController:addfillup animated:YES completion:^{}];
// UITabBarController *tabBarcontroller = (UITabBarController *)self.window.rootViewController;
  //  [(UINavigationController *) tabBarcontroller.selectedViewController pushViewController:addfillup animated:YES];

}


-(void)addservice
{
    [self dismissLabs];
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
   ServiceViewController *addservice = (ServiceViewController *)[mainStoryboard instantiateViewControllerWithIdentifier:@"service"];
#define ROOTVIEW [[[UIApplication sharedApplication] keyWindow] rootViewController]
    addservice.modalPresentationStyle = UIModalPresentationFullScreen;
    [ROOTVIEW presentViewController:addservice animated:YES completion:^{}];
   
}


-(void)addexpense
{
    [self dismissLabs];
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
    AddExpenseViewController *addexpense = (AddExpenseViewController *)[mainStoryboard instantiateViewControllerWithIdentifier:@"expense"];
    addexpense.modalPresentationStyle = UIModalPresentationFullScreen;
#define ROOTVIEW [[[UIApplication sharedApplication] keyWindow] rootViewController]
    [ROOTVIEW presentViewController:addexpense animated:YES completion:^{}];
    
}

-(void)addTrip
{
    [self dismissLabs];
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
    AddTripViewController *addTrip = (AddTripViewController *)[mainStoryboard instantiateViewControllerWithIdentifier:@"AddTrip"];
#define ROOTVIEW [[[UIApplication sharedApplication] keyWindow] rootViewController]
    addTrip.modalPresentationStyle = UIModalPresentationFullScreen;
    [ROOTVIEW presentViewController:addTrip animated:YES completion:^{}];
    
}

-(void)animate: (UIView *)view :(float)xaxis : (float)yaxis
{
   
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         view.frame = CGRectMake(xaxis,yaxis, 50, 50);
                     }
                     completion:^(BOOL finished){
                     }];
    //[topView addSubview:self.expense];
}

-(void)animate1: (UIView *)view :(float)xaxis : (float)yaxis
{
[UIView animateWithDuration:1.5
                      delay:0.5
                    options: UIViewAnimationOptionCurveEaseIn
                 animations:^{
                     view.frame = CGRectMake(xaxis,yaxis, 50, 50);
                 }
                 completion:^(BOOL finished){
                     if (finished)
                         [view removeFromSuperview];
                 }];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    result = [[UIScreen mainScreen] bounds].size;
    [self.blurview removeFromSuperview];
    [self.tabbutton setImage:[UIImage imageNamed:@"tab_add_new"] forState:UIControlStateNormal];
    [self animate:self.expense :result.width/2-22 :result.height];
    //[self.expense removeFromSuperview];
    [self animate:self.services :result.width/2-22 :result.height];
    //[self.services removeFromSuperview];
    [self animate:self.fillup :result.width/2-22 :result.height];
    // [self.fillup removeFromSuperview];
    [self animate:self.trip :result.width/2-22 :result.height];

    [self.expenselab removeFromSuperview];
    [self.filluplab removeFromSuperview];
    [self.serviceslab removeFromSuperview];
    [self.tripLab removeFromSuperview];

    self.services.selected = NO;
}

-(void)dismissLabs{

    result = [[UIScreen mainScreen] bounds].size;
       [self.blurview removeFromSuperview];
       [self.tabbutton setImage:[UIImage imageNamed:@"tab_add_new"] forState:UIControlStateNormal];
       [self animate:self.expense :result.width/2-22 :result.height];
       //[self.expense removeFromSuperview];
       [self animate:self.services :result.width/2-22 :result.height];
       //[self.services removeFromSuperview];
       [self animate:self.fillup :result.width/2-22 :result.height];
       // [self.fillup removeFromSuperview];
       [self animate:self.trip :result.width/2-22 :result.height];

       [self.expenselab removeFromSuperview];
       [self.filluplab removeFromSuperview];
       [self.serviceslab removeFromSuperview];
       [self.tripLab removeFromSuperview];

       self.services.selected = NO;

}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
   
    //New_10 Nikhil 1December2018 Auto Trip Loging
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSLog(@"App entered in applicationDidEnterBackground");
    
    BOOL autoTripOn = [def boolForKey:@"autoTripSwitchOn"];
    BOOL tripInProgress = [[NSUserDefaults standardUserDefaults] boolForKey:@"tripInProgress"];
    BOOL proUser = [[NSUserDefaults standardUserDefaults] boolForKey:@"isSubscribed"];
    
    NSUInteger remainingTripCount=0;
    [self fetchTripCountForThisMonth];
    
    if(tripCount<10){
        
        remainingTripCount = 10-tripCount;
    }else{
        remainingTripCount = tripCount;
    }
    
    if(proUser || remainingTripCount<11){
        
        if(!tripInProgress && autoTripOn){
            
            NSLog(@"App entered in didEnteredBackground and no trip is in progress");
            [def setBool:YES forKey:@"fromAppDelegate"];
           // NSLog(@"Set YES to fromAppDelegate");
            [self.shareModel startMonitoringLocation];
            
        }
    }
    
    [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"appStatusTrip"];
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"locationKey"];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];

    if([def objectForKey:@"UserEmail"] != nil){

        //GEt data from sync table on every app open in background
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{


            [self performSelectorInBackground:@selector(saveResponseToDB) withObject:nil];
        });
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

    if (self.launchedURL) {
        [self openLink:self.launchedURL];
        self.launchedURL = nil;
    }

    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    
    //New_10 Nikhil 1December2018 Auto Trip Loging
    BOOL autoTripOn = [def boolForKey:@"autoTripSwitchOn"];
    BOOL tripInProgress = [[NSUserDefaults standardUserDefaults] boolForKey:@"tripInProgress"];
    BOOL proUser = [[NSUserDefaults standardUserDefaults] boolForKey:@"isSubscribed"];
    
    NSUInteger remainingTripCount=0;
    [self fetchTripCountForThisMonth];
    
    //NSLog(@"tripCount:- %lu",(unsigned long)tripCount);
    
    if(tripCount<10){
        
        remainingTripCount = 10-tripCount;
    }else{
        remainingTripCount = tripCount;
    }
    
    NSLog(@"remainingTripCount:- %lu",(unsigned long)remainingTripCount);
    
    if(proUser || remainingTripCount<11){
        
        if(!tripInProgress && autoTripOn){
            
            NSLog(@"App entered in didBecomeActive and no trip is in progress");
            [def setBool:YES forKey:@"fromAppDelegate"];
           // NSLog(@"Set YES to fromAppDelegate");
            [self.shareModel startMonitoringLocation];
            
        }
        
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"locationKey"];
    [[NSUserDefaults standardUserDefaults] setInteger:2 forKey:@"appStatusTrip"];
    
    //Swapnil
    //[self connectToFirebase];
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
   
    /*[[[UIApplication sharedApplication] scheduledLocalNotifications] enumerateObjectsUsingBlock:^(UILocalNotification *notification, NSUInteger idx, BOOL *stop) {
        NSLog(@"Notification %lu: %@",(unsigned long)idx, notification);
    }];
     */
    
    //Expire zombie notifications
    if ([def objectForKey:@"ExprireAllNotifications"] == nil)
    {
        [self expireOldNotifications];
    }
  

    //RATE APP on itunes prompt
    
    //if([[[def objectForKey:@"rateappclick"] lowercaseString] isEqualToString:[@"later" lowercaseString]] || [def objectForKey:@"rateappclick"]==nil){
   //     [def setInteger :[def integerForKey:@"appopenstatus"]+1 forKey:@"appopenstatus"];
   // }
    
    if([def objectForKey:@"appopenstatus"] == nil){
        [def setInteger:0 forKey:@"appopenstatus"];
    }
    
    //NSLog(@"appopen %ld",(long)[def integerForKey:@"appopenstatus"]);
    
//    NSLog(@"appOpen Status = %ld", (long)[def integerForKey:@"appopenstatus"]);
//    NSLog(@"appOpen Status = %@", [def objectForKey:@"rateappclick"]);
/*
    if([def integerForKey:@"appopenstatus"]>=10){
        [self ratealert];
        
    }
    else if ([def integerForKey:@"appopenstatus"]>=5 && [[[def objectForKey:@"rateappclick"]lowercaseString] isEqualToString:[@"later" lowercaseString]]){
        [self ratealert];
    }
*/
    
    //[self FaceBookalert];
    
    //Facebook Like prompt
    if([[[def objectForKey:@"fblikeClick"] lowercaseString] isEqualToString:[@"later" lowercaseString]] || [def objectForKey:@"fblikeClick"]==nil){
        [def setInteger :[def integerForKey:@"fbopenstatus"]+1 forKey:@"fbopenstatus"];
    }
    
    //NSLog(@"appopen %ld",(long)[def integerForKey:@"appopenstatus"]);
    
    
    if([def integerForKey:@"fbopenstatus"]>=20){
        [self FaceBookalert];
        
    }
    else if ([def integerForKey:@"fbopenstatus"]>=10 && [[[def objectForKey:@"fblikeClick"]lowercaseString] isEqualToString:[@"later" lowercaseString]]){
        [self FaceBookalert];
    }
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    NSLog(@"App is terminating, setting tripInProgress to NO from applicationWillTerminate");
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"tripInProgress"];
    
    //New_10 Nikhil 1December2018 Auto Trip Loging
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    BOOL autoTripOn = [def boolForKey:@"autoTripSwitchOn"];
    BOOL proUser = [[NSUserDefaults standardUserDefaults] boolForKey:@"isSubscribed"];

    NSUInteger remainingTripCount=0;
    [self fetchTripCountForThisMonth];

   // NSLog(@"tripCount:- %lu",(unsigned long)tripCount);

    if(tripCount<10){

        remainingTripCount = 10-tripCount;
    }else{
        remainingTripCount = tripCount;
    }

    //NSLog(@"remainingTripCount:- %lu",(unsigned long)remainingTripCount);

    if((proUser || remainingTripCount<11) && autoTripOn){

        NSLog(@"App entered in applicationWillTerminate and autoSwitch is on");
        [def setBool:YES forKey:@"fromAppDelegate"];
        NSLog(@"Set YES to fromAppDelegate");
        [self.shareModel startMonitoringLocation];

    }
    
    //ENH_53 To remind user that sync wont work if force quit the app
    [self fetchDrivers];
    //NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSString *userEmail = [def objectForKey:@"UserEmail"];
    
    if (userEmail != nil && userEmail.length > 0 && self.friendsArray.count>0)
    {
        NSString* alertBody = NSLocalizedString(@"app_terminate", @"Oops the app is terminated, Sync and auto report won't work till you reopen the App");
        [self showLogNotification:@"":alertBody];
        
        //NSDate *date = [[NSDate alloc] init];
        //NSLog(@"localTS when user terminated the App : %@", date);
        
        // [def setObject:date forKey:@"localTimeStamp"];
        [def setInteger:1 forKey:@"quit"];
    }
    
     //NSLog(@"application terminated..");
    //[self appTerminatedNotification];
        [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"odovalue"];
        [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"odofilter"];
    
        [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"datevalue"];
        [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"datefilter"];
        [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"notefilter"];
        [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"recordfilter"];
    
        [[CoreDataController sharedInstance] saveMasterContext];
    
    //Swapnil NEW_5
    //App terminates while gps tracking in progress, show notification
    if([def boolForKey:@"gpsSelect"] == YES){
        
        [self addNewNotification];
    }

   // [CheckReachability.sharedManager stopNetworkMonitoring];
}

- (void)addNewNotification{
    
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.title = [NSString localizedUserNotificationStringForKey:@"" arguments:nil];
    
    NSString *contentBody = @"Simply Auto stopped tracking trip via GPS";
    content.body = contentBody;
    
    content.sound = [UNNotificationSound defaultSound];
    content.badge = nil;
    
    UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger
                                                  triggerWithTimeInterval:2.f repeats:NO];
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"tripDismissed"
                                                                          content:content trigger:trigger];
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        if (!error) {
            //NSLog(@"add NotificationRequest succeeded!");
        }
    }];
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
        
        [self.friendsArray addObject:dictionary];
    }
    
}



//- (void)appTerminatedNotification{
//    
//    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
//    content.title = [NSString localizedUserNotificationStringForKey:@"" arguments:nil];
//    
//    NSString *contentBody = @"Application terminated";
//    content.body = contentBody;
//    
//    content.sound = [UNNotificationSound defaultSound];
//    content.badge = nil;
//    
//    UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger
//                                                  triggerWithTimeInterval:2.f repeats:NO];
//    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"appTerminate"
//                                                                          content:content trigger:trigger];
//    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
//    [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
//        if (!error) {
//            NSLog(@"add NotificationRequest succeeded!");
//        }
//    }];
//}





-(void)savetolocaldatabase
{
        //BUG_156
        NSManagedObjectContext *context = [[CoreDataController sharedInstance] newManagedObjectContext];
        //NSFetchRequest *requset=[[NSFetchRequest alloc] initWithEntityName:@"Veh_Table"];
        //NSArray *datavalue=[contex executeFetchRequest:requset error:&err];
         NSUserDefaults *def =[NSUserDefaults standardUserDefaults];
    
        Veh_Table *data=[NSEntityDescription insertNewObjectForEntityForName:@"Veh_Table" inManagedObjectContext:context];
            
        
            data.iD = [NSNumber numberWithInt:1];
            [def setObject:data.iD forKey:@"idvalue"];
        
            data.make = NSLocalizedString(@"def_car", @"Default Car");
            data.vehid = NSLocalizedString(@"def_car", @"Default Car");
            data.model = @"";
    NSError *err;
    [[NSUserDefaults standardUserDefaults]setObject:data.iD forKey:@"fillupid"];
   
    [def setObject:@"1" forKey:@"idvalue"];
    [def setObject:NSLocalizedString(@"def_car", @"Default Car") forKey:@"vehname"];
    [def setObject:[NSString stringWithFormat:@"%@",@"1"] forKey:@"fillupid"];
    [def setObject:@"" forKey:@"vehimage"];
            if ([context hasChanges])
            {
                BOOL saved = [context save:&err];
                if (!saved) {
                    // do some real error handling
                    //CLSLog(@“Could not save Data due to %@“, error);
                }
               [[CoreDataController sharedInstance] saveMasterContext];
            }
    
    [self saveTrip];
    [self saveservice];
    [self saveexpense];
    
   }


-(void)saveservice
{
    //BUG_156
    NSManagedObjectContext *context = [[CoreDataController sharedInstance] newManagedObjectContext];
    //NSFetchRequest *requset=[[NSFetchRequest alloc] initWithEntityName:@"Veh_Table"];
    //NSArray *datavalue=[contex executeFetchRequest:requset error:&err];
    NSMutableArray *servicearray = [[NSMutableArray alloc]initWithObjects:
                                    @"Engine Oil",
                                    @"Battery",
                                    @"Tire Rotation",
                                    @"Wheel Alignment",
                                    @"Spark Plugs",
                                    @"Timing Belt", nil];
    NSError *err;
    for(int i =0;i<servicearray.count;i++)
    {
    Services_Table *data=[NSEntityDescription insertNewObjectForEntityForName:@"Services_Table" inManagedObjectContext:context];
    data.vehid = @"1";
    data.serviceName = [servicearray objectAtIndex:i];
    data.recurring = @(1);
    data.type = @(1);
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
    
    
}

-(void)updateTrip
{

    NSManagedObjectContext *context = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSError *err;
    NSFetchRequest *requset=[[NSFetchRequest alloc] initWithEntityName:@"Services_Table"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type==3"];
    [requset setPredicate:predicate];
    
    NSArray *datavalue=[context executeFetchRequest:requset error:&err];
    
    for ( Services_Table *service in datavalue)
    {
        if([service.serviceName isEqualToString:NSLocalizedString(@"business", @"Business")])
        {
            service.dueMiles = @0.575;
            
        }
        
        else if([service.serviceName isEqualToString:NSLocalizedString(@"moving", @"Moving")] || [service.serviceName isEqualToString:NSLocalizedString(@"medical", @"Medical")])
        {
            service.dueMiles = @0.17;
            
        }
        else if([service.serviceName isEqualToString:NSLocalizedString(@"personal", @"Personal")])
        {
            service.dueMiles = @0.0;
            
        }
        else if([service.serviceName isEqualToString:NSLocalizedString(@"charity", @"Charity")])
        {
            service.dueMiles = @0.14;
            
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
    
}


-(void)saveTrip
{
    //NIKHIL ENH_40 //Changed values for US
    //BUG_156
    NSManagedObjectContext *context = [[CoreDataController sharedInstance] newManagedObjectContext];
    //NSFetchRequest *requset=[[NSFetchRequest alloc] initWithEntityName:@"Veh_Table"];
    //NSArray *datavalue=[context  executeFetchRequest:requset error:&err];
    NSMutableArray *tripArray = [[NSMutableArray alloc]initWithObjects:
                                 NSLocalizedString(@"business", @"Business"),
                                 NSLocalizedString(@"personal", @"Personal"),
                                 NSLocalizedString(@"charity", @"Charity"),
                                 NSLocalizedString(@"moving", @"Moving"),
                                 NSLocalizedString(@"medical", @"Medical"),nil];
    NSMutableArray *rateArray = [[NSMutableArray alloc]initWithObjects:@0.545,@0.0,@0.14,@0.18,@0.18, nil];
    NSError *err;
    for(int i =0;i<tripArray.count;i++)
    {
        Services_Table *data=[NSEntityDescription insertNewObjectForEntityForName:@"Services_Table" inManagedObjectContext:context];
        data.vehid = @"All";
        data.serviceName = [tripArray objectAtIndex:i];
        data.dueMiles = [rateArray objectAtIndex:i];
        data.type = @(3);
        if ([context  hasChanges])
        {
            BOOL saved = [context save:&err];
            if (!saved) {
                // do some real error handling
                //CLSLog(@“Could not save Data due to %@“, error);
            }
            [[CoreDataController sharedInstance] saveMasterContext];
        }
    }
    
    
}


-(void)saveexpense
{
    //BUG_156
    NSManagedObjectContext *context  = [[CoreDataController sharedInstance] newManagedObjectContext];
    //NSFetchRequest *requset=[[NSFetchRequest alloc] initWithEntityName:@"Veh_Table"];
    //NSArray *datavalue=[contex executeFetchRequest:requset error:&err];
    NSMutableArray *servicearray = [[NSMutableArray alloc]initWithObjects:
                                    @"Fine",
                                    @"Insurance",
                                    @"MOT",
                                    @"Toll",
                                    @"Tax",
                                    @"Parking",nil];
    NSError *err;
    for(int i =0;i<servicearray.count;i++)
    {
        Services_Table *data=[NSEntityDescription insertNewObjectForEntityForName:@"Services_Table" inManagedObjectContext:context ];
        data.vehid = @"1";
        data.serviceName = [servicearray objectAtIndex:i];
        data.recurring = @(0);
        data.type = @(2);
        if ([context  hasChanges])
        {
            BOOL saved = [context  save:&err];
            if (!saved) {
                // do some real error handling
                //CLSLog(@“Could not save Data due to %@“, error);
            }
            NSLog(@"saved");
            [[CoreDataController sharedInstance] saveMasterContext];
        }
    }

    
}




- (void) numberOfrecords{
    
   // NSLog(@"record checking*******");
   // NSManagedObjectContext *contex=app.managedObjectContext;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSManagedObjectContext *managedObjectContext = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Veh_Table" inManagedObjectContext:managedObjectContext];
    [request setEntity:entity];
    
    NSError *error = nil;
    NSUInteger count = [managedObjectContext countForFetchRequest:request
                                                            error:&error];
    if (!error) {
        self.recordnumber = count;
    
    } else {
        self.recordnumber = 0;
    }
   // NSLog(@"record number %d",self.recordnumber);
}

#pragma mark- Interactive Notifications & Local Notifications
-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler{
    
    UNNotificationPresentationOptions presentationOptions = UNNotificationPresentationOptionAlert + UNNotificationPresentationOptionSound;
    //Called when a notification is delivered to a foreground app.
    
    //NSLog(@"Userinfo %@",notification.request.content.userInfo);
    completionHandler(presentationOptions);
}

-(void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler{
    
    //Called to let your app know which action was selected by the user for a given notification.
    //NSLog(@"Userinfo %@",response.notification.request.content.userInfo);
    //NIKHIL 8june2018
    if(completionHandler != nil)    //Finally call completion handler if its not nil
        completionHandler();
    
    
    NSInteger toShowViewController = [[NSUserDefaults standardUserDefaults] integerForKey:@"showPage"];
    
    //show ReminderViewController
    if(toShowViewController == 0){
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        AutorotateNavigation *reminderController = [storyboard instantiateViewControllerWithIdentifier:@"reminder"];
        reminderController.modalPresentationStyle = UIModalPresentationFullScreen;
        [self.window.rootViewController presentViewController:reminderController animated:YES completion:nil];
        
     //show LogViewController
    }else if(toShowViewController == 1){
       
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        AutorotateNavigation *logController = [storyboard instantiateViewControllerWithIdentifier:@"logVC"];
        logController.modalPresentationStyle = UIModalPresentationFullScreen;
        [self.window.rootViewController presentViewController:logController animated:YES completion:nil];
        
     //show LoggedInViewController
    }else if(toShowViewController == 2){
        
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"doSignIn"];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        AutorotateNavigation *loginController = [storyboard instantiateViewControllerWithIdentifier:@"loggedInScreen"];
        loginController.modalPresentationStyle = UIModalPresentationFullScreen;
        [self.window.rootViewController presentViewController:loginController animated:YES completion:nil];
    }

}

-(void)expireOldNotifications
{

//Get all scheduled Notification
    
    NSArray *arrayOfLocalNotifications = [[UIApplication sharedApplication] scheduledLocalNotifications] ;
    
//Cancel all the above
    if (arrayOfLocalNotifications.count > 0) {
        [[JRNLocalNotificationCenter defaultCenter] cancelAllLocalNotifications];
    }
    
    //fetch day reminders from DB
    //BUG_156
    NSManagedObjectContext *context  = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSError *err;
    
    NSFetchRequest *requset=[[NSFetchRequest alloc] initWithEntityName:@"Services_Table"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dueDays>0"];
    [requset setPredicate:predicate];
    NSArray *dayReminders=[context  executeFetchRequest:requset error:&err];
    
    
    //Fetch Vehicles Data
    
    NSFetchRequest *vehRequest=[[NSFetchRequest alloc] initWithEntityName:@"Veh_Table"];
    NSArray *vehicles=[context  executeFetchRequest:vehRequest error:&err];
    
    
    // setup new notifications
    
    for (Services_Table *reminder in dayReminders) {
        
        NSString* vehName;
        
        for (Veh_Table *vehicle in vehicles) {
            if ([vehicle.iD intValue] == [reminder.vehid intValue]) {
                vehName = vehicle.vehid;
            }
        }
      
        NSDate* remDate = [reminder.lastDate dateByAddingTimeInterval:([reminder.dueDays integerValue]*60*60*24)];
        
        NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
        NSDateComponents *timeComponents = [calendar components:( NSCalendarUnitYear |  NSCalendarUnitMonth |  NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond )
                                                       fromDate:remDate];
        [timeComponents setHour:7];
        [timeComponents setMinute:00];
        [timeComponents setSecond:0];
        
        NSDate *dtFinal = [calendar dateFromComponents:timeComponents];
        
        NSString* alertBody = [NSString stringWithFormat:@"%@ %@ %@",reminder.serviceName, NSLocalizedString(@"noti_msg_veh", @"Overdue for"),vehName];
        
        
         //NSLog(@"dtFinal is %@", [dtFinal descriptionWithLocale:[NSLocale currentLocale]]);

        //TODO currently stop daily reminder notification as it is showing even when the service is done.
        if(dtFinal != nil){

            NSString* jrnKey = [[reminder.serviceName stringByAppendingString:@","] stringByAppendingString:vehName];
            [[JRNLocalNotificationCenter defaultCenter] postNotificationOn:dtFinal                                                            forKey:jrnKey alertBody:[NSString stringWithFormat:@"Pull or swipe to interact. %@", alertBody]
                                                               alertAction:@"Open"
                                                                 soundName:nil
                                                               launchImage:nil
                                                                  userInfo:@{@"DueDate": dtFinal}
                                                                badgeCount:0
                                                            repeatInterval:NO
                                                                  category:@"DayReminder"];


            [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"showPage"];

        }
        
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"ExprireAllNotifications"];

}

-(void)updateServiceTable
{
    //fetch services and expenses from T_FUELCONS table
    NSError *err;

    NSManagedObjectContext *fuelContext = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSFetchRequest *fuelRequest=[[NSFetchRequest alloc] initWithEntityName:@"T_Fuelcons"];
    NSPredicate *fpredicate = [NSPredicate predicateWithFormat:@"type ==1 OR  type==2"];
    [fuelRequest setPredicate:fpredicate];
    [fuelRequest setResultType:NSDictionaryResultType];

    NSArray *fuelLogArr =[fuelContext executeFetchRequest:fuelRequest error:&err];
    
    if(fuelLogArr.count > 0)
    { // convert comma seperated services/expenses into rows
    
    NSMutableArray* array = [[NSMutableArray alloc] init];
    
    for (NSDictionary *fuelDict in fuelLogArr)
    {
        NSString* services = [fuelDict objectForKey:@"serviceType"];
        NSArray *serviceArry = [services componentsSeparatedByString:@","];
        
        for (NSString* service in serviceArry)
        {
            //NSLog(@"%@",service);
            
            NSMutableDictionary* fuelMutDict =[fuelDict mutableCopy];
            [fuelMutDict setObject:service forKey:@"serviceType"];
            [array addObject:fuelMutDict];
            
        }
     
    }
    
    //NSLog(@"Arry is: %@", array);
    //NSLog(@"count Arry is: %lu", (unsigned long)array.count);

    NSSortDescriptor * descriptor = [[NSSortDescriptor alloc] initWithKey:@"stringDate" ascending:NO];
    NSSortDescriptor * type = [[NSSortDescriptor alloc] initWithKey:@"serviceType" ascending:NO];
    NSArray* sortedArray = [array sortedArrayUsingDescriptors:@[type,descriptor]];
    NSMutableArray* uniqueServices = [[NSMutableArray alloc] init];
    
    
  //get all unique service type to loop for
    for (NSDictionary *recDict in sortedArray) {
       //Get all unique services
        if (![uniqueServices containsObject:recDict[@"serviceType"]])
        {
            [uniqueServices  addObject:recDict[@"serviceType"]];
            
        }
    }

   // NSLog(@"uniqueServices: %@", uniqueServices);

    //Take maxdate for each vehicle for each service
    
    NSMutableArray* finalArray = [[NSMutableArray alloc] init];
    NSMutableArray* prevVehid=[[NSMutableArray alloc] init];
    
   
            for (NSString* type in uniqueServices) {
            
                
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"serviceType == %@", type];
                NSArray* filteredArray = [sortedArray filteredArrayUsingPredicate:predicate];
                
                for (NSDictionary* dict in filteredArray) {
                    
                    if (![ prevVehid containsObject:dict[@"vehid"]])
                    {
                        //Vehid not included
                        //Record to be incuded
                        
                        [finalArray addObject:dict];
                        [prevVehid addObject:dict[@"vehid" ]];
                        
                        
                    }
                
                }
                [prevVehid removeAllObjects];
                
          
    }

    //NSLog(@"Final Array :%@",finalArray );
    
    //fetch records from service table.
    
        //BUG_156
    NSManagedObjectContext *context  = [[CoreDataController sharedInstance] newManagedObjectContext];
    
    NSFetchRequest *requset=[[NSFetchRequest alloc] initWithEntityName:@"Services_Table"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(type ==1 OR  type==2)"];
    [requset setPredicate:predicate];
    NSArray *services=[context  executeFetchRequest:requset error:&err];
    //beforeArray = [[NSArray alloc] initWithArray:services copyItems:YES];
    _beforeArray=[[NSMutableArray alloc]init];
    
    for (Services_Table* service in services) {
        
        NSMutableDictionary* serviceDict = [[NSMutableDictionary alloc] init];
        
        //NSLog(@"Service.vehid : %@", service.vehid);
        
        [serviceDict setObject:service.lastOdo forKey:@"lastOdo"];
       // [serviceDict setObject:service.lastDate forKey:@"lastDate"];
        [serviceDict setObject:service.dueDays forKey:@"dueDays"];
        [serviceDict setObject:service.dueMiles forKey:@"dueMiles"];
        [serviceDict setObject:service.serviceName forKey:@"serviceName"];
        [serviceDict setObject:service.vehid forKey:@"vehid"];

        [_beforeArray addObject:serviceDict ];
        

        service.lastOdo = @0;
        service.lastDate=nil;
        service.dueDays= @0;
        service.dueMiles=@0;

    
    }
    if ([context  hasChanges])
    {
        BOOL saved = [context  save:&err];
        if (!saved) {
            // do some real error handling
            //CLSLog(@“Could not save Data due to %@“, error);
        }
        [[CoreDataController sharedInstance] saveMasterContext];
    }
    
    for (Services_Table* service in services) {
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"serviceName == %@ and vehid ==%@", service.serviceName,service.vehid];
        
        NSArray* filteredbeforeArray = [_beforeArray filteredArrayUsingPredicate:predicate];
        //NSLog(@"filteredbeforeArray.count: %@", filteredbeforeArray);
      NSDictionary* beforeDict = [filteredbeforeArray firstObject];
        
        for (NSDictionary* dict in sortedArray) {
            
            if (([dict[@"serviceType"] isEqualToString: service.serviceName]) && [dict[@"vehid"] isEqualToString: service.vehid] )
            {
                service.lastOdo = dict[@"odo"];
                service.lastDate= dict[@"stringDate"];
                NSLog(@"AppDelegate line number 3467:- %@",service.lastDate);
                service.dueMiles= beforeDict[@"dueMiles"];
                service.dueDays = beforeDict[@"dueDays"];
                
            }
            
        }
    
        
        if ([context  hasChanges])
        {
            BOOL saved = [context  save:&err];
            if (!saved) {
                // do some real error handling
                //CLSLog(@“Could not save Data due to %@“, error);
            }
            [[CoreDataController sharedInstance] saveMasterContext];
        }

    }

    [self expireOldNotifications];

    }
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"fixed" ];
        
}

-(void)setupInteractiveNotification
{
    
    //Targetted at over usage
    UIMutableUserNotificationAction *notificationAction1 = [[UIMutableUserNotificationAction alloc] init];
    notificationAction1.identifier = @"OK";
    notificationAction1.title = [NSString stringWithFormat:@"%@, %@", NSLocalizedString(@"ok", @"Ok"), NSLocalizedString(@"got_it", @"got it")];
    notificationAction1.activationMode = UIUserNotificationActivationModeBackground;
    notificationAction1.destructive = NO;
    notificationAction1.authenticationRequired = NO;
    
    UIMutableUserNotificationAction *notificationAction2 = [[UIMutableUserNotificationAction alloc] init];
    notificationAction2.identifier = @"Remind";
    notificationAction2.title = NSLocalizedString(@"button_later_for_tip", @"Remind me again") ;
    notificationAction2.activationMode = UIUserNotificationActivationModeBackground;
    notificationAction2.destructive = YES;
    notificationAction2.authenticationRequired = YES;
    
    
    UIMutableUserNotificationCategory *dayReminderCatg = [[UIMutableUserNotificationCategory alloc] init];
    dayReminderCatg.identifier = @"DayReminder";
    [dayReminderCatg setActions:@[notificationAction1,notificationAction2] forContext:UIUserNotificationActionContextDefault];
    [dayReminderCatg setActions:@[notificationAction1,notificationAction2] forContext:UIUserNotificationActionContextMinimal];
    
    
    NSSet *categories = [NSSet setWithObjects:dayReminderCatg, nil];
    
    UIUserNotificationType notificationType = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:notificationType categories:categories];
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
    
    
    
    
}
- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void(^)())completionHandler {
    
    NSDictionary *dict = [notification userInfo];
    
    NSString* key = [dict objectForKey:@"JRN_KEY"];
    NSDate* dueDate = [dict objectForKey:@"DueDate"];
    
    //NSLog(@"Due Date is %@", dueDate);
    [[JRNLocalNotificationCenter defaultCenter] cancelLocalNotificationForKey:key];
    if ([identifier isEqualToString: @"OK"]) {
        //NSLog(@"You clicked OK");
        
    //    [[JRNLocalNotificationCenter defaultCenter] didReceiveLocalNotificationUserInfo:notification.userInfo];
        

    }
    if ([identifier isEqualToString: @"Remind"]) {
      //  NSLog(@"You clicked Remind me again");
        
     //    [[JRNLocalNotificationCenter defaultCenter] didReceiveLocalNotificationUserInfo:notification.userInfo];
        
 //       [[JRNLocalNotificationCenter defaultCenter] cancelLocalNotificationForKey:key];
        //TODO see what to do about this
//        [[JRNLocalNotificationCenter defaultCenter] postNotificationOn:dueDate forKey:key  alertBody:notification.alertBody
//                                                           alertAction:@"Open"
//                                                             soundName:nil
//                                                           launchImage:nil
//                                                              userInfo:@{@"DueDate": dueDate}
//                                                            badgeCount:0
//                                                        repeatInterval:NSCalendarUnitDay
//                                                              category:@"DayReminder"];
//
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"showPage"];

    }
    
    if(completionHandler != nil)    //Finally call completion handler if its not nil
        completionHandler();
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler {
    
    // Handle actions of remote notifications here. You can identify the action by using "identifier" and perform appropriate operations
    //NSLog(@"User opened the notification");
    
    if(completionHandler != nil)    //Finally call completion handler if its not nil
        completionHandler();
    
}


- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    //NSDictionary *dict = [notification userInfo];
    
    //NSLog(@"User opened the notification");
    
    //id obj = [dict objectForKey:@"TESTKEY"];
    //[self.window.rootViewController ];
    
    [[JRNLocalNotificationCenter defaultCenter] didReceiveLocalNotificationUserInfo:notification.userInfo];
}

-(void)FaceBookalert {
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@""
                                          message:NSLocalizedString(@"like_us_msg", @"Like using Simply Auto? Why don't you share your love by liking us on Facebook?")
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    //NSString *button_fb_like = @"LIKE!";
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"button_fb_like", @"LIKE!")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   [[NSUserDefaults standardUserDefaults]setObject:@"Like" forKey:@"fblikeClick"];
                                   [[NSUserDefaults standardUserDefaults]setInteger:0 forKey:@"fbopenstatus"];
                                   NSString *fbLink = @"http://www.facebook.com/fuelbuddytheapp";
                                   [[UIApplication sharedApplication] openURL:[NSURL URLWithString:fbLink]];
                                   
                               }];
    
    //NSString *button_later = @"Later";
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"button_later", "Later")
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       [[NSUserDefaults standardUserDefaults]setObject:@"Later" forKey:@"fblikeClick"];
                                       [[NSUserDefaults standardUserDefaults]setInteger:0 forKey:@"fbopenstatus"];
                                   }];
    
    //NSString *button_never = @"Never";
    UIAlertAction *neverAction = [UIAlertAction
                                  actionWithTitle:NSLocalizedString(@"button_never", @"Never")
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction *action)
                                  {
                                      [[NSUserDefaults standardUserDefaults]setObject:@"Never" forKey:@"fblikeClick"];
                                      [[NSUserDefaults standardUserDefaults]setInteger:0 forKey:@"fbopenstatus"];
                                  }];
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    [alertController addAction:neverAction];
#define ROOTVIEW [[[UIApplication sharedApplication] keyWindow] rootViewController]
    [ROOTVIEW presentViewController:alertController animated:YES completion:nil];
    
}

@end
