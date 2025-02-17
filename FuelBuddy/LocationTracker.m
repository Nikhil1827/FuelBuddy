//
//  LocationTracker.m
//  FuelBuddy
//
//  Created by Nikhil on 12/10/18.
//  Copyright © 2018 Oraganization. All rights reserved.
//

#import "LocationTracker.h"
#import "AppDelegate.h"
#import "T_Trip.h"
#import "Veh_Table.h"
#import "Loc_Table.h"
#import "Sync_Table.h"
#import "Services_Table.h"
#import "commonMethods.h"
#import "Reachability.h"
#import "WebServiceURL's.h"
#import "JRNLocalNotificationCenter.h"
#import "AddTripViewController.h"
#import "LocationManager.h"
#import <Crashlytics/Crashlytics.h>
#import "CheckReachability.h"
#define LATITUDE @"latitude"
#define LONGITUDE @"longitude"
#define ACCURACY @"theAccuracy"

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

@interface LocationTracker (){
    
    BOOL stoppedTimeSet;
    NSDate *waitTime;
    NSDate *currentTime;
    NSDate *startTime;
    __block NSString *depLoca;
    __block NSString *arrLoca;
    BOOL changeTo30Sec,tripStartNoti;
    NSMutableArray *trackArray;
    NSUInteger tripCount;
    NSMutableArray *tripTypeArray;
    
}
@end

@implementation LocationTracker{
    
    CLPlacemark *placemark;
    CLGeocoder *geoCoder;
}

+ (CLLocationManager *)sharedLocationManager {
    static CLLocationManager *_locationManager;
    
    @synchronized(self) {
        if (_locationManager == nil) {
            _locationManager = [[CLLocationManager alloc] init];
            _locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
            _locationManager.allowsBackgroundLocationUpdates = YES;
            _locationManager.pausesLocationUpdatesAutomatically = NO;
        }
    }
    return _locationManager;
}

- (id)init {
    if (self==[super init]) {
        //Get the share model and also initialize myLocationArray
        self.shareModel = [LocationShareModel sharedModel];
        self.shareModel.myLocationArray = [[NSMutableArray alloc]init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    return self;
}

-(void)applicationEnterBackground{
    CLLocationManager *locationManager = [LocationTracker sharedLocationManager];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    
    if(IS_OS_8_OR_LATER) {
        [locationManager requestAlwaysAuthorization];
    }
    [locationManager startUpdatingLocation];
    
    //Use the BackgroundTaskManager to manage all the background Task
    self.shareModel.bgTask = [BackgroundTaskManager sharedBackgroundTaskManager];
    [self.shareModel.bgTask beginNewBackgroundTask];
}

- (void)startLocationTracking {
    
    NSLog(@"startLocationTracking");
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"tripInProgress"];
    NSLog(@"Set YES to tripInProgress");
    
    if ([CLLocationManager locationServicesEnabled] == NO) {
        
        NSLog(@"locationServicesEnabled false");

    } else {
        CLAuthorizationStatus authorizationStatus= [CLLocationManager authorizationStatus];
        
        if(authorizationStatus == kCLAuthorizationStatusDenied || authorizationStatus == kCLAuthorizationStatusRestricted){
            NSLog(@"authorizationStatus failed");
        } else {
            NSLog(@"authorizationStatus authorized");
            CLLocationManager *locationManager = [LocationTracker sharedLocationManager];
            locationManager.delegate = self;
            locationManager.desiredAccuracy = kCLLocationAccuracyBest;
            locationManager.distanceFilter = kCLDistanceFilterNone;
            
            if(IS_OS_8_OR_LATER) {
                [locationManager requestAlwaysAuthorization];
            }
            [locationManager startUpdatingLocation];
            //NSLog(@"startUpdatingLocation:- %@",locationManager);
        }
    }
    
}


- (void)stopLocationTracking {
    NSLog(@"stopLocationTracking");
    
    if (self.shareModel.timer) {
        [self.shareModel.timer invalidate];
        self.shareModel.timer = nil;
    }
    
    CLLocationManager *locationManager = [LocationTracker sharedLocationManager];
    [locationManager stopUpdatingLocation];

}



#pragma mark - CLLocationManagerDelegate Methods

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    
    NSLog(@"locationTracker didUpdateLocations");
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    geoCoder = [[CLGeocoder alloc] init];
    self.speed = 0;
    self.latestLoc = [locations lastObject];
    
    NSDate* eventDate = self.latestLoc.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (fabs(howRecent) < 15.0) {
        
        currentTime = self.latestLoc.timestamp;
        
        if(self.startLoc == nil){
            trackArray = [[NSMutableArray alloc] init];
            self.startLoc = self.latestLoc;
            
            startTime = currentTime;
            NSLog(@"startTime:- %@",startTime);
            
            BOOL internetOn = [self checkForNetwork];
            if(internetOn){
                
                NSLog(@"Internet **** Connection **** Available ************");
            }else{
                
                NSLog(@"No **** Internet **** Connection **********");
            }
            
        }
 
        self.lastLoc = [trackArray lastObject];

        [trackArray addObject:self.latestLoc];
        
        self.speed = self.latestLoc.speed*3.6;
        NSLog(@"speed = %f", self.speed);
        
        CLLocationDistance currDistance = [self.startLoc distanceFromLocation:self.latestLoc];
        CLLocationDistance currKilometers = currDistance / 1000.0;
        NSNumber *currDistanceInKm = [NSNumber numberWithDouble:currKilometers];
        
        NSLog(@"distanceInKm before trip ended in auto trip = %@", currDistanceInKm);
        
        [def setObject:currDistanceInKm forKey:@"distFromAutoTrip"];
    
        NSMutableDictionary *dataDict = [[NSMutableDictionary alloc] init];
        
        if(self.speed > 15.00){
            
            waitTime = [currentTime dateByAddingTimeInterval:240];
            stoppedTimeSet = YES;
            
            NSLog(@"currentTime speed more than 15 = %@",currentTime);
            NSLog(@"waitTime speed more than 15 = %@",waitTime);
        
            //Notification on starting the Trip
            if(!tripStartNoti){
                
                NSMutableDictionary *inProDict = [[NSMutableDictionary alloc] init];
                [inProDict setObject:startTime forKey:@"depDate"];
                [inProDict setObject:self.startLoc forKey:@"depLoc"];
                NSLog(@"Saving Trip In Progress");
                [self savetripInProgressData:inProDict];
                [def setBool:NO forKey:@"tripEndedManually"];
                
                tripStartNoti = YES;
                
            }
            
        }else{
            
            if(!stoppedTimeSet){
                
                stoppedTimeSet = YES; // 4 mintues 
                waitTime = [currentTime dateByAddingTimeInterval:240];
                
            }
            
            NSLog(@"currentTime speed less than 15 = %@",currentTime);
            NSLog(@"waitTime speed less than 15 = %@",waitTime);
            
            if([waitTime compare:currentTime] == NSOrderedAscending || [waitTime compare:currentTime] == NSOrderedSame){
                
                [self stopLocationTracking];
                
                NSLog(@"End Trip");
                
                CLLocationDistance totalKilometers = 0;
                
                for (int i = 0; i < (trackArray.count - 1); i++)
                {
                    CLLocation *loc1 = [trackArray objectAtIndex:i];
                    CLLocation *loc2 = [trackArray objectAtIndex:(i + 1)];
                    
                    CLLocationDistance distance = [loc1 distanceFromLocation:loc2];
                    CLLocationDistance kilometers = distance / 1000.0;
                    totalKilometers += kilometers;
                }
                
                
                NSNumber *distanceInKm = [NSNumber numberWithDouble:totalKilometers];
                NSLog(@"distanceInKm after trip ended in auto trip = %@", distanceInKm);
                
                [dataDict setObject:distanceInKm forKey:@"dist"];
                [dataDict setObject:startTime forKey:@"depDate"];
                [dataDict setObject:currentTime forKey:@"arrDate"];
                [dataDict setObject:self.startLoc forKey:@"depLoc"];
                [dataDict setObject:self.latestLoc forKey:@"arrLoc"];
                
                if(tripStartNoti && ![def boolForKey:@"tripEndedManually"]){
                    
                    self.shareModel.bgTask = [BackgroundTaskManager sharedBackgroundTaskManager];
                    [self.shareModel.bgTask beginNewBackgroundTask];
                    [self sendDataToAddTrip:dataDict];
                    
                }

                stoppedTimeSet = NO;
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"locationKey"];
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"tripInProgress"];
                NSLog(@"Set NO to tripInProgress");
                
            }
            
        }
        
       
    }
    
}

- (void)locationManager: (CLLocationManager *)manager didFailWithError: (NSError *)error
{
     NSLog(@"locationManager entered in didFailsWith Error and error is:- %@",error);
    
    switch([error code])
    {
        case kCLErrorNetwork: // general, network-related error
        {
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Error" message:@"Please check your network connection." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
//            [alert show];
        }
            break;
        case kCLErrorDenied:{
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Enable Location Service" message:@"You have to enable the Location Service to use this App. To enable, please go to Settings->Privacy->Location Services" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
//            [alert show];
        }
            break;
        default:
        {
            
        }
            break;
    }
}


-(void)fetchTripTypes{
    
    tripTypeArray = [[NSMutableArray alloc] init];
    NSManagedObjectContext *contex = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSFetchRequest *request=[[NSFetchRequest alloc] initWithEntityName:@"Services_Table"];
    NSError *err;
    NSArray *data=[contex executeFetchRequest:request error:&err];
    
    for(Services_Table *tripType in data)
    {
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
        if([tripType.type  intValue] == 3 && tripType.vehid != nil){
            
            [dictionary setObject:tripType.vehid forKey:@"vehid"];
            [dictionary setObject:tripType.serviceName forKey:@"serviceName"];
            if(tripType.dueMiles == nil){
                [dictionary setObject:@"0.0" forKey:@"dueMiles"];
            }else{
                [dictionary setObject:tripType.dueMiles forKey:@"dueMiles"];
            }
            [dictionary setObject:tripType.type forKey:@"type"];
            
            
            [tripTypeArray addObject:dictionary];
        }
        
    }
}

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
    
    tripCount = datavalue.count;
    NSLog(@"Trip count for this month:-%lu",(unsigned long)tripCount);
    
}

-(void)sendDataToAddTrip:(NSDictionary *)dataDictionary{
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSArray *sortedLogArray=[[NSUserDefaults standardUserDefaults] objectForKey:@"SortedLog"];
    NSString *comparestring = [NSString stringWithFormat:@"%@",[def objectForKey:@"fillupid"]];
    NSString *rowID = [NSString stringWithFormat:@"%@",[def objectForKey:@"maxFuelID"]];
    double maxOdo = 0;
    
    //set Date
    NSDateFormatter *f=[[NSDateFormatter alloc] init];
    [f setDateStyle:NSDateFormatterLongStyle];
    
    [f setDateFormat:@"dd-MMM-yyyy hh:mm aa"];
    [f setAMSymbol:@"AM"];
    [f setPMSymbol:@"PM"];
    
    NSLog(@"Came before if in saving complete trip");
    
    if(sortedLogArray.count > 0){
        
        NSMutableDictionary *maxRecord = [[NSMutableDictionary alloc] init];
        NSMutableDictionary *minRecord = [[NSMutableDictionary alloc] init];
        
        maxRecord = [sortedLogArray firstObject];
        minRecord = [sortedLogArray lastObject];
        
        if([[maxRecord objectForKey:@"type"]  isEqual: @3]){
            
            maxOdo = [[maxRecord objectForKey:@"arrOdo"] floatValue];
        } else {
            
            maxOdo = [[maxRecord objectForKey:@"odo"] floatValue];
        }
        
    }
    
    NSLog(@"maxOdo: %f",maxOdo);
    
    NSDate *depDate =[f dateFromString:[f stringFromDate:[dataDictionary objectForKey:@"depDate"]]];
    NSDate *arrDate =[f dateFromString:[f stringFromDate:[dataDictionary objectForKey:@"arrDate"]]];
    
    if(!geoCoder)
        geoCoder = [[CLGeocoder alloc] init];
    
    
    [geoCoder reverseGeocodeLocation:self.latestLoc completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        
        NSLog(@"Came inside geocoder saving complete trip");
        
        if(error == nil && [placemarks count] > 0){
            
            CLPlacemark * localPlaceMark = [placemarks lastObject];
            // placemark = [placemarks lastObject];
            
            arrLoca = [NSString stringWithFormat:@"%@ %@", localPlaceMark.name, localPlaceMark.subLocality];
            NSLog(@"arrLoca inside geocoder:%@",arrLoca);
            
        } else {
            
            NSLog(@"arrLoca placeMark error:- %@ and latest loc is:- %@", error.debugDescription,self.latestLoc);
        }
    
        //NSLog(@"arrLoca outside geocoder:%@",arrLoca);
        double arrOdom = [[dataDictionary objectForKey:@"dist"] floatValue] + maxOdo;
        //NSLog(@"arrOdom:%f",arrOdom);
    
    
    //TO get vehid
    NSManagedObjectContext *contex = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSError *err;
    
    NSFetchRequest *vehRequest = [[NSFetchRequest alloc] initWithEntityName:@"Veh_Table"];
    NSPredicate *vehPredicate = [NSPredicate predicateWithFormat:@"iD == %i",[comparestring intValue]];
    [vehRequest setPredicate:vehPredicate];
    NSArray *vehData = [contex executeFetchRequest:vehRequest error:&err];
    
    Veh_Table *vehicleData = [vehData firstObject];
    
    NSString *vehid = vehicleData.vehid;
    
    NSMutableDictionary *forFriendDict = [[NSMutableDictionary alloc]init];
    if([def objectForKey:@"UserEmail"] != nil){
        [forFriendDict setObject:[def objectForKey:@"UserEmail"] forKey:@"email"];
        [forFriendDict setObject:[def objectForKey:@"UserName"] forKey:@"name"];
    }else{
        [forFriendDict setObject:@"" forKey:@"email"];
        [forFriendDict setObject:@"" forKey:@"name"];
    }
    [forFriendDict setObject:@"update" forKey:@"action"];
    
    NSFetchRequest *request=[[NSFetchRequest alloc] initWithEntityName:@"T_Trip"];
    NSPredicate *predicate;
    predicate = [NSPredicate predicateWithFormat:@"vehId==%@ AND tripComplete == 0 AND iD == %i",comparestring,[rowID intValue]];
    [request setPredicate:predicate];
    
    NSArray *result=[contex executeFetchRequest:request error:&err];
        
    T_Trip *dataval = [result firstObject];
        
    if(dataval != nil){
        
        [forFriendDict setObject:dataval.iD forKey:@"id"];
        [forFriendDict setObject:dataval.depOdo forKey:@"oldOdo"];
        [forFriendDict setObject:dataval.tripType forKey:@"oldServiceType"];
       
        dataval.depOdo = @(maxOdo);
        [forFriendDict setObject:@(maxOdo) forKey:@"odo"];
        
        dataval.vehId=comparestring;
        if(dataval.vehId != nil){
            [forFriendDict setObject:vehid forKey:@"vehid"];
        }
        
        NSDateFormatter *formater = [[NSDateFormatter alloc] init];
        [formater setDateFormat:@"EEEE"];
        NSString *currentDay = [formater stringFromDate:[NSDate date]];
        
        NSString *tripTypeAccToDay = [[NSString alloc] init];
        
        if([currentDay isEqualToString:@"Saturday"] || [currentDay isEqualToString:@"Sunday"]){
            
            tripTypeAccToDay = [def objectForKey:@"weekEndsTripType"];
        }else{
            
            tripTypeAccToDay = [def objectForKey:@"weekDaysTripType"];
        }
        
        [self fetchTripTypes];
        
        double rate = 0.0;
        for(int i=0;i<tripTypeArray.count;i++){
            
            if([[[tripTypeArray objectAtIndex:i] valueForKey:@"serviceName"] isEqualToString:tripTypeAccToDay]){
                
                rate = [[[tripTypeArray objectAtIndex:i] valueForKey:@"dueMiles"] doubleValue];
            }
            
        }
        
        float taxDedc = (arrOdom-maxOdo)* rate;
        
        dataval.tripType= tripTypeAccToDay;
        NSLog(@"tripTypeAccToDay:-%@",tripTypeAccToDay);
        [forFriendDict setObject:tripTypeAccToDay forKey:@"serviceType"];
        
        dataval.depDate=depDate;
        [forFriendDict setObject:depDate forKey:@"date"];
        
        dataval.depLocn= depLoca;
        if(dataval.depLocn){
            [forFriendDict setObject:dataval.depLocn forKey:@"fuelBrand"];
        }else{
            [forFriendDict setObject:@"" forKey:@"fuelBrand"];
        }
        
        dataval.arrDate=arrDate;
        
        commonMethods *common = [[commonMethods alloc] init];
        NSDictionary *epochDictionary = [common getDayMonthYrFromStringDate:dataval.arrDate];
        NSString *gotDate = [epochDictionary valueForKey:@"epochTime"];
        NSString *sendDate;
        if(gotDate.length>8){
            sendDate = [gotDate substringToIndex:13];
            [forFriendDict setObject:sendDate forKey:@"octane"];
        }else{
            [forFriendDict setObject:gotDate forKey:@"octane"];
        }
        
        dataval.arrOdo= [NSNumber numberWithDouble:arrOdom];
        [forFriendDict setObject:[NSNumber numberWithDouble:arrOdom] forKey:@"qty"];
        
        dataval.arrLocn=arrLoca;
        if(dataval.arrLocn){
            [forFriendDict setObject:dataval.arrLocn forKey:@"fillStation"];
        }else{
            [forFriendDict setObject:@"" forKey:@"fillStation"];
        }
        
        dataval.parkingAmt=@(0);
        [forFriendDict setObject:@"0" forKey:@"OT"];
       
        dataval.tollAmt=@(0);
        [forFriendDict setObject:@(0) forKey:@"year"];
        
        dataval.taxDedn=@(taxDedc);
        [forFriendDict setObject:@(taxDedc) forKey:@"cost"];
        
        dataval.notes = @"";
        [forFriendDict setObject:@"" forKey:@"cost"];
        
        dataval.arrLatitude = [NSNumber numberWithDouble:self.latestLoc.coordinate.latitude];
        if([NSNumber numberWithDouble:self.latestLoc.coordinate.latitude] != nil)
        [forFriendDict setObject:[NSNumber numberWithDouble:self.latestLoc.coordinate.latitude] forKey:@"arrLat"];
        dataval.arrLongitude = [NSNumber numberWithDouble:self.latestLoc.coordinate.longitude];
        if([NSNumber numberWithDouble:self.latestLoc.coordinate.longitude] != nil)
        [forFriendDict setObject:[NSNumber numberWithDouble:self.latestLoc.coordinate.longitude] forKey:@"arrLong"];
        
        dataval.tripComplete = YES;
        [forFriendDict setObject:@3 forKey:@"type"];
        
        if ([contex hasChanges])
        {
            
            NSLog(@"Came inside changes if saving complete trip");
            BOOL saved = [contex save:&err];
            if (!saved) {
                // do some real error handling
                //CLSLog(@“Could not save Data due to %@“, error);
            }
            // NSLog(@"odometer saved");
            [[CoreDataController sharedInstance] saveMasterContext];
            
            //Swapnil NEW_6
            NSString *userEmail = [def objectForKey:@"UserEmail"];
            
            //If user is signed In, then only do the sync process..
            if(userEmail != nil && userEmail.length > 0){
                
                [self writeToSyncTableWithRowID:dataval.iD tableName:@"TRIP" andType:@"edit" andOS: @"self"];
                
                //To share data with friend
                //Commented sync with friend "testing"
//                BOOL friendPresent = [self checkforConfirmedFriends];
//
//                if(friendPresent){
//                    //NSLog(@"Call script ☺️ with Dictionary:- %@",forFriendDict);
//                    [self sendUpdatedRecordToFriend:forFriendDict];
//                }

               // [self checkNetworkForCloudStorage];
                
            }
            
            //Swapnil 25-May-2017
            BOOL proUser = [[NSUserDefaults standardUserDefaults] boolForKey:@"isAdDisabled"];
            
            if(!proUser){
                NSInteger gadCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"adCount"];
                gadCount = gadCount + 1;
                [[NSUserDefaults standardUserDefaults] setInteger:gadCount forKey:@"adCount"];
            }
            
            
            [def setInteger :[def integerForKey:@"appopenstatus"]+1 forKey:@"appopenstatus"];
            
            NSLog(@"Show Trip Complete Notification");
            AppDelegate *app = [[AppDelegate alloc] init];
            
            
            //Trip complete
            NSString *typetripComplete = [NSString stringWithFormat:@"%@ %@",tripTypeAccToDay,NSLocalizedString(@"trip_complete",@"Trip complete")];
            
            NSArray *array = [[[NSUserDefaults standardUserDefaults]objectForKey:@"curr_unit"] componentsSeparatedByString:@"-"];
            NSString *curr_unit = [array lastObject];
            
            NSString *taxDedValue = [NSString stringWithFormat:@"%@ : %.2f%@",NSLocalizedString(@"tax_deduction_amount",@"Tax Deducted"),taxDedc,curr_unit];
            
            
            [app showNotification:typetripComplete :taxDedValue];
            [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"showPage"];
            
            //Change the title of navigation Control to "Save Trip" and Update trip_state to 'Complete'
            AddTripViewController *tripView = [[AddTripViewController alloc] init];
            tripView.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"Save Trip" style:UIBarButtonItemStylePlain target:self action:@selector(saveTrip)];
            
            
            //Nikhil 29Nov2018 fabric events for auto trip count
            NSString *appInstallDate = [def objectForKey:@"installDate"];
            NSInteger autoTripCount = [def integerForKey:@"autoTripCount"] + 1;
            [def setInteger:autoTripCount forKey:@"autoTripCount"];
            NSString *tripCnt = [NSString stringWithFormat:@"%ld", (long)autoTripCount];
            
            NSString *autoTripCountEvent = [NSString stringWithFormat:@"%@; %@", appInstallDate, tripCnt];
            [Answers logCustomEventWithName:@"Auto Trips Count"
                           customAttributes:@{@"Auto Trips": autoTripCountEvent}];
            
        }
    }
        
        [def setBool:NO forKey:@"showTripInProgress"];
        [self.shareModel.bgTask endAllBackgroundTasks];
        
    }];
    
}

-(void)savetripInProgressData:(NSDictionary *)dataDictionary{
   
    // Trip can be Started
    //Insert record in the DB with trip complete = NO
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSArray *sortedLogArray=[[NSUserDefaults standardUserDefaults] objectForKey:@"SortedLog"];
    NSString *comparestring = [NSString stringWithFormat:@"%@",[def objectForKey:@"fillupid"]];
    
    double maxOdo = 0;
    
    //set Date
    NSDateFormatter *f=[[NSDateFormatter alloc] init];
    [f setDateStyle:NSDateFormatterLongStyle];
    
    [f setDateFormat:@"dd-MMM-yyyy hh:mm aa"];
    [f setAMSymbol:@"AM"];
    [f setPMSymbol:@"PM"];
    
    if(sortedLogArray.count > 0){
        
        NSMutableDictionary *maxRecord = [[NSMutableDictionary alloc] init];
        NSMutableDictionary *minRecord = [[NSMutableDictionary alloc] init];
        
        maxRecord = [sortedLogArray firstObject];
        minRecord = [sortedLogArray lastObject];
        
        if([[maxRecord objectForKey:@"type"]  isEqual: @3]){
            
            maxOdo = [[maxRecord objectForKey:@"arrOdo"] floatValue];
        } else {
            
            maxOdo = [[maxRecord objectForKey:@"odo"] floatValue];
        }
        
    }
    
    NSDate *depDate =[f dateFromString:[f stringFromDate:[dataDictionary objectForKey:@"depDate"]]];
    
    geoCoder = [[CLGeocoder alloc] init];
    NSLog(@"self.startLoc:%@",self.startLoc);
    
    [geoCoder reverseGeocodeLocation:self.startLoc completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        
        if(error == nil && [placemarks count] > 0){
            
            CLPlacemark * localPlaceMark = [placemarks lastObject];
            // placemark = [placemarks lastObject];
            
            depLoca = [NSString stringWithFormat:@"%@ %@", localPlaceMark.name, localPlaceMark.subLocality];
            NSLog(@"depLoca:%@",depLoca);
            
        } else {
            
            NSLog(@"depLoca placeMark Error:- %@ and startLoc is :-%@", error.debugDescription,self.startLoc);
        }
        
        
        //TO get vehid
        NSManagedObjectContext *contex = [[CoreDataController sharedInstance] newManagedObjectContext];
        NSError *err;
        
        NSFetchRequest *vehRequest = [[NSFetchRequest alloc] initWithEntityName:@"Veh_Table"];
        NSPredicate *vehPredicate = [NSPredicate predicateWithFormat:@"iD == %i",[comparestring intValue]];
        [vehRequest setPredicate:vehPredicate];
        NSArray *vehData = [contex executeFetchRequest:vehRequest error:&err];
        
        Veh_Table *vehicleData = [vehData firstObject];
        
        NSString *vehid = vehicleData.vehid;
        
        T_Trip *dataval=[NSEntityDescription insertNewObjectForEntityForName:@"T_Trip" inManagedObjectContext:contex];
        
        if(dataval != nil){
            
            NSMutableDictionary *forFriendDict = [[NSMutableDictionary alloc]init];
            if([def objectForKey:@"UserEmail"] != nil){
                [forFriendDict setObject:[def objectForKey:@"UserEmail"] forKey:@"email"];
                [forFriendDict setObject:[def objectForKey:@"UserName"] forKey:@"name"];
            }else{
                [forFriendDict setObject:@"" forKey:@"email"];
                [forFriendDict setObject:@"" forKey:@"name"];
            }
            [forFriendDict setObject:@"add" forKey:@"action"];
            
            int fuelID;
            if([def objectForKey:@"maxFuelID"] != nil){
                
                fuelID = [[def objectForKey:@"maxFuelID"] intValue];
            } else {
                
                fuelID = 0;
            }
            
            dataval.iD = [NSNumber numberWithInt:fuelID + 1];
            [def setObject:dataval.iD forKey:@"maxFuelID"];
            if(dataval.iD !=nil){
                [forFriendDict setObject:dataval.iD forKey:@"id"];
            }else{
                [forFriendDict setObject:@"" forKey:@"id"];
            }
            
            dataval.depOdo = [NSNumber numberWithDouble:maxOdo];
            [forFriendDict setObject:[NSNumber numberWithDouble:maxOdo] forKey:@"odo"];
            
            
            dataval.vehId=comparestring;
            if(dataval.vehId != nil){
                [forFriendDict setObject:vehid forKey:@"vehid"];
            }
            
            NSDateFormatter *formater = [[NSDateFormatter alloc] init];
            [formater setDateFormat:@"EEEE"];
            NSString *currentDay = [formater stringFromDate:[NSDate date]];
            
            NSString *tripTypeAccToDay = [[NSString alloc] init];;
            
            if([currentDay isEqualToString:@"Saturday"] || [currentDay isEqualToString:@"Sunday"]){
                
                tripTypeAccToDay = [def objectForKey:@"weekEndsTripType"];
            }else{
                
                tripTypeAccToDay = [def objectForKey:@"weekDaysTripType"];
            }
         
            NSLog(@"tripTypeAccToDay:-%@",tripTypeAccToDay);
            dataval.tripType = tripTypeAccToDay;
            [forFriendDict setObject:tripTypeAccToDay forKey:@"serviceType"];
            dataval.depDate=depDate;
            [forFriendDict setObject:depDate forKey:@"date"];
            //NSLog(@"depLoc while Saving:-%@",depLoca);
            dataval.depLocn= depLoca;
            if(depLoca != nil){
                [forFriendDict setObject:depLoca forKey:@"fuelBrand"];
            }else{
                [forFriendDict setObject:@"" forKey:@"fuelBrand"];
            }
            
            dataval.arrOdo= @(0);
            [forFriendDict setObject:@(0) forKey:@"qty"];
            
            dataval.arrLocn= @"";
            [forFriendDict setObject:@"" forKey:@"fillStation"];
            
            dataval.parkingAmt=@(0);
            [forFriendDict setObject:@(0) forKey:@"OT"];
            
            dataval.tollAmt=@(0);
            [forFriendDict setObject:@(0) forKey:@"year"];
            
            dataval.taxDedn=@(0);
            [forFriendDict setObject:@(0) forKey:@"cost"];
            
            dataval.notes = @"";
            [forFriendDict setObject:@"" forKey:@"notes"];
            
            
            dataval.depLongitude = [NSNumber numberWithDouble:self.startLoc.coordinate.longitude];
            if([NSNumber numberWithDouble:self.startLoc.coordinate.longitude])
            [forFriendDict setObject:dataval.depLongitude forKey:@"depLong"];
            dataval.depLatitude = [NSNumber numberWithDouble:self.startLoc.coordinate.latitude];
            if([NSNumber numberWithDouble:self.startLoc.coordinate.latitude])
            [forFriendDict setObject:dataval.depLatitude forKey:@"depLat"];
            dataval.tripComplete = NO;
            [forFriendDict setObject:@3 forKey:@"type"];
            NSMutableDictionary *paramDict = [[NSMutableDictionary alloc] init];
            
            if ([contex hasChanges])
            {
                BOOL saved = [contex save:&err];
                if (!saved) {
                    // do some real error handling
                    //CLSLog(@“Could not save Data due to %@“, error);
                }
                // NSLog(@"odometer saved");
                [[CoreDataController sharedInstance] saveMasterContext];
                //Swapnil NEW_6
                NSString *userEmail = [def objectForKey:@"UserEmail"];
                
                //If user is signed In, then only do the sync process..
                if(userEmail != nil && userEmail.length > 0){
                    
                    [self writeToSyncTableWithRowID:dataval.iD tableName:@"TRIP" andType:@"add" andOS: @"self" ];
                    
                    //To share data with friend
                    //Commented sync with friend "testing"
//                    BOOL friendPresent = [self checkforConfirmedFriends];
//
//                    if(friendPresent){
//                        //NSLog(@"Call script  with Dictionary:- %@",forFriendDict);
//                        [self sendUpdatedRecordToFriend:forFriendDict];
//                    }

                    if(paramDict != nil && paramDict.count > 0){
                        
                        [self writeToSyncTableWithRowID:[paramDict objectForKey:@"rowid"] tableName:@"LOC_TABLE" andType:[paramDict objectForKey:@"type"] andOS: @"self"];
                    }
                   // [self checkNetworkForCloudStorage];
                }
              
                NSUInteger remainingTripCount=0;
                [self fetchTripCountForThisMonth];
                
                if(tripCount<10){
                    
                    remainingTripCount = 10-tripCount;
                }else{
                    remainingTripCount = tripCount;
                }
                
               // NSLog(@"Show Trip started Notification, remaining trips:-%lu",(unsigned long)remainingTripCount);
                AppDelegate *app = [[AppDelegate alloc] init];
                BOOL proUserSubscribed = [[NSUserDefaults standardUserDefaults] boolForKey:@"isSubscribed"];
                if(!proUserSubscribed && remainingTripCount < 4){
                    
                    NSString *freeTripsString = NSLocalizedString(@"free_trips_remaining",@"Free trips remaining this month:");
                    NSString *withTripString = [NSString stringWithFormat:@"%lu",(unsigned long)remainingTripCount];
                    NSString *finalString = [freeTripsString stringByAppendingString:withTripString];
                    [app showTripCountNotification:finalString :NSLocalizedString(@"noti_trips_remaining_msg",@"The free version allows 15 automatic trips per month. After which you can upgrade or continue logging manually.")];
                }
                
                [app showNotification:NSLocalizedString(@"trip_in_progress",@"Trip In Progress"):@""];
                [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"showPage"];
                
                
                //Change the title of navigation Control to "End Trip" and Update trip_state to 'In Progress'
                AddTripViewController *tripView = [[AddTripViewController alloc] init];
                tripView.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithTitle: NSLocalizedString(@"end_trip", @"End Trip") style:UIBarButtonItemStylePlain target:self action:@selector(saveTrip)];
                
            }
        }
        
    }];
    
}

- (BOOL)checkForNetwork{
    
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    
    if(networkStatus == NotReachable){
        
        return NO;
    } else {
        
        return YES;
        
    }
}

#pragma mark Friend Single Sync Methods
-(BOOL)checkforConfirmedFriends{
    
    //TO get confirmed friends
    NSManagedObjectContext *contex = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSError *err;
    NSString *comparestring = @"confirm";
    NSFetchRequest *friendRequest = [[NSFetchRequest alloc] initWithEntityName:@"Friends_Table"];
    NSPredicate *friendPredicate = [NSPredicate predicateWithFormat:@"status == %@",comparestring];
    [friendRequest setPredicate:friendPredicate];
    NSArray *frndData = [contex executeFetchRequest:friendRequest error:&err];
    
    if (frndData.count>0) {
        return YES;
    }else{
        
        return NO;
    }
}

//-(void)sendUpdatedRecordToFriend:(NSDictionary *)friendDict{
//    
//    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
//    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
//  
//    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
//    NSMutableDictionary *parametersDict = [[NSMutableDictionary alloc]init];
//    parametersDict = [friendDict mutableCopy];
//    NSDate *date = [friendDict objectForKey:@"date"];
//    
//    commonMethods *common = [[commonMethods alloc] init];
//    NSDictionary *epochDictionary = [common getDayMonthYrFromStringDate:date];
//    int month = [[epochDictionary valueForKey:@"month"] intValue] -1;
//    [parametersDict setObject:[epochDictionary valueForKey:@"day"] forKey:@"day"];
//    [parametersDict setValue:[NSNumber numberWithInt:month] forKey:@"month"];
//    [parametersDict setObject:[epochDictionary valueForKey:@"year"] forKey:@"year"];
//    [parametersDict setObject:[epochDictionary valueForKey:@"hours"] forKey:@"pfill"];
//    [parametersDict setObject:[epochDictionary valueForKey:@"minutes"] forKey:@"mfill"];
//
//    //Trim after decimals
//    NSString *gotDate = [epochDictionary valueForKey:@"epochTime"];
//    NSString *sendDate = [gotDate substringToIndex:13];
//    //NSLog(@"date:- %@",sendDate);
//    [parametersDict setObject:sendDate forKey:@"date"];
//    
//    if(networkStatus == NotReachable){
//        
//        NSMutableArray *saveArray = [[NSMutableArray alloc] init];
//        saveArray = [def objectForKey:@"pendingFriendRecord"];
//        [saveArray addObject:parametersDict];
//        [def setObject:saveArray forKey:@"pendingFriendRecord"];
//        
//    } else {
//        
//        NSError *err;
//        NSData *postDataArray = [NSJSONSerialization dataWithJSONObject:parametersDict options:NSJSONWritingPrettyPrinted error:&err];
//        
//        [def setBool:NO forKey:@"updateTimeStamp"];
//        [common saveToCloud:postDataArray urlString:kFriendSyncDataScript success:^(NSDictionary *responseDict) {
//            
//            //NSLog(@"ResponseDict is : %@", responseDict);
//            
//            if([[responseDict valueForKey:@"success"]  isEqual: @1]){
//                
//                NSLog(@"success:- %@",[responseDict valueForKey:@"success"]);
//                
//            }else{
//                
//                AppDelegate *app = [[AppDelegate alloc]init];
//                NSString* alertBody = @"Failed to sync data.";
//                [app showNotification:@"":alertBody];
//                
//            }
//            
//        } failure:^(NSError *error) {
//            
//        }];
//    }
//    
//}

#pragma mark CLOUD SYNC METHODS

//Save rowID, tableName, and type in phones Sync table
- (void)writeToSyncTableWithRowID: (NSNumber *)rowID tableName: (NSString *)tableName andType: (NSString *)type andOS: (NSString *)originalSource{
    
    NSManagedObjectContext *context = [[CoreDataController sharedInstance] newManagedObjectContext];
    Sync_Table *syncData = [NSEntityDescription insertNewObjectForEntityForName:@"Sync_Table" inManagedObjectContext:context];
    NSError *err;
    syncData.rowID = rowID;
    syncData.tableName = tableName;
    syncData.type = type;
    syncData.processing = @0;
    syncData.originalSource = originalSource;
    
    if([context hasChanges]){
        
        BOOL saved = [context save:&err];
        if (!saved) {
            // do some real error handling
            //CLSLog(@“Could not save Data due to %@“, error);
        }
        [[CoreDataController sharedInstance] saveMasterContext];
        //upload data from common methods
        commonMethods *common = [[commonMethods alloc] init];
        [common checkNetworkForCloudStorage:@"isTrip"];
    }
}


- (void)checkNetworkForCloudStorage{
    
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    
    if(networkStatus == NotReachable){
        
        [CheckReachability.sharedManager startNetworkMonitoring];
    } else {
        
        //[self fetchDataFromSyncTable];
        //Send from common methods
        //[self performSelectorInBackground:@selector(fetchDataFromSyncTable) withObject:nil];
    }
}

//Loop through the Sync table, fetch table name, type (add, edit, del) and rowID of record
- (void)fetchDataFromSyncTable{
    
    NSManagedObjectContext *context = [[CoreDataController sharedInstance] backgroundManagedObjectContext];
    NSError *err;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Sync_Table"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"tableName == 'TRIP' OR tableName == 'LOC_TABLE'"];
    [request setPredicate:predicate];
    NSArray *dataArray = [context executeFetchRequest:request error:&err];
    
    for(Sync_Table *syncData in dataArray){
        
        NSString *type = syncData.type;
        //NSInteger rowID = [syncData.rowID integerValue];
        if(syncData.rowID == nil){

            NSError *err;
            if(syncData != nil){

                [context deleteObject:syncData];
            }

            if ([context hasChanges])
            {
                BOOL saved = [context save:&err];
                if (!saved) {
                    // do some real error handling
                    //CLSLog(@“Could not save Data due to %@“, error);
                }
                [[CoreDataController sharedInstance] saveBackgroundContext];
                [[CoreDataController sharedInstance] saveMasterContext];
            }
        }else{

            [self setParametersWithType:type andRowID:syncData.rowID andTableName:syncData.tableName];
        }


    }
}

//Loop thr' the specified tableName and get record for specified rowID
- (void)setParametersWithType: (NSString *)type andRowID: (NSNumber *)rowID andTableName: (NSString *)tableName{
    ;
    NSManagedObjectContext *context = [[CoreDataController sharedInstance] backgroundManagedObjectContext];
    NSError *err;
    if([tableName isEqualToString:@"TRIP"]){
        
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"T_Trip"];
        NSPredicate *iDPredicate = [NSPredicate predicateWithFormat:@"iD == %d", [rowID intValue]];
        [request setPredicate:iDPredicate];
        
        NSArray *fetchedData = [context executeFetchRequest:request error:&err];
        
        T_Trip *tripData = [fetchedData firstObject];
        
        
        NSFetchRequest *vehRequest = [[NSFetchRequest alloc] initWithEntityName:@"Veh_Table"];
        NSPredicate *vehPredicate = [NSPredicate predicateWithFormat:@"iD == %d", [tripData.vehId intValue]];
        [vehRequest setPredicate:vehPredicate];
        
        NSArray *vehData = [context executeFetchRequest:vehRequest error:&err];
        
        Veh_Table *vehicleData = [vehData firstObject];
        
        commonMethods *common = [[commonMethods alloc] init];
        NSDictionary *epochDictionary = [common getDayMonthYrFromStringDate:tripData.depDate];
        
        
        NSMutableDictionary *parametersDictionary = [[NSMutableDictionary alloc] init];
        NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
        if([def objectForKey:@"UserEmail"] != nil){
            [parametersDictionary setObject:[def objectForKey:@"UserEmail"] forKey:@"email"];
        }else{
            [parametersDictionary setObject:@"" forKey:@"email"];
        }
        [parametersDictionary setObject:@"phone" forKey:@"source"];
        
        if(type != nil){
            [parametersDictionary setObject:type forKey:@"type"];
        } else {
            [parametersDictionary setObject:@"" forKey:@"type"];
        }

        //Added new parameter for friend stuff
        [parametersDictionary setObject:@"self" forKey:@"originalSource"];
        
        if(rowID != nil){
            [parametersDictionary setObject:rowID forKey:@"_id"];
        } else {
            [parametersDictionary setObject:@"" forKey:@"_id"];
        }
        [parametersDictionary setObject:[def objectForKey:@"UserDeviceId"] forKey:@"androidId"];
        
        [parametersDictionary setObject:[epochDictionary valueForKey:@"day"] forKey:@"day"];
        [parametersDictionary setObject:[epochDictionary valueForKey:@"month"] forKey:@"month"];
        [parametersDictionary setObject:[epochDictionary valueForKey:@"year"] forKey:@"year"];
        [parametersDictionary setObject:[epochDictionary valueForKey:@"epochTime"] forKey:@"date"];
        [parametersDictionary setObject:@"3" forKey:@"rec_type"];
        
        
        if(vehicleData.vehid != nil){
            [parametersDictionary setObject:vehicleData.vehid forKey:@"vehid"];
        } else {
            [parametersDictionary setObject:@"" forKey:@"vehid"];
        }
        
        if(tripData.depOdo != nil){
            [parametersDictionary setObject:tripData.depOdo forKey:@"odo"];
        } else {
            [parametersDictionary setObject:@"" forKey:@"odo"];
        }
        
        if(tripData.arrOdo != nil){
            [parametersDictionary setObject:tripData.arrOdo forKey:@"qty"];
        } else {
            [parametersDictionary setObject:@"" forKey:@"qty"];
        }
        
        //Convert dep time to dep hour and dep min
        NSDictionary *depDT = [common getDayMonthYrFromStringDate:tripData.depDate];
        
        if([depDT valueForKey:@"hours"] != nil){
            [parametersDictionary setObject:[depDT valueForKey:@"hours"] forKey:@"pfill"];
        } else {
            [parametersDictionary setObject:@"" forKey:@"pfill"];
        }
        
        if([depDT valueForKey:@"minutes"] != nil){
            [parametersDictionary setObject:[depDT valueForKey:@"minutes"] forKey:@"mfill"];
        } else {
            [parametersDictionary setObject:@"" forKey:@"mfill"];
        }
        
        if(tripData.taxDedn != nil){
            [parametersDictionary setObject:tripData.taxDedn forKey:@"cost"];
        } else {
            [parametersDictionary setObject:@"" forKey:@"cost"];
        }
        
        if(tripData.parkingAmt != nil){
            [parametersDictionary setObject:tripData.parkingAmt forKey:@"dist"];
        } else {
            [parametersDictionary setObject:@"" forKey:@"dist"];
        }
        
        if(tripData.arrDate != nil){
            
            //Convert arr date/time in epoch
            NSDictionary *epochArrival = [common getDayMonthYrFromStringDate:tripData.arrDate];
            [parametersDictionary setObject:[epochArrival valueForKey:@"epochTime"] forKey:@"cons"];
            
        } else {
            [parametersDictionary setObject:@"" forKey:@"cons"];
        }
        //BUG_157 NIKHIL keyName octane changed to ocatne
        if(tripData.tollAmt != nil){
            [parametersDictionary setObject:tripData.tollAmt forKey:@"octane"];
        } else {
            [parametersDictionary setObject:@"" forKey:@"octane"];
        }
        
        if(tripData.depLocn != nil){
            [parametersDictionary setObject:tripData.depLocn forKey:@"fuelBrand"];
        } else {
            [parametersDictionary setObject:@"" forKey:@"fuelBrand"];
        }
        
        if(tripData.arrLocn != nil){
            [parametersDictionary setObject:tripData.arrLocn forKey:@"fillStation"];
        } else {
            [parametersDictionary setObject:@"" forKey:@"fillStation"];
        }
        
        if(tripData.notes != nil){
            [parametersDictionary setObject:tripData.notes forKey:@"notes"];
        } else {
            [parametersDictionary setObject:@"" forKey:@"notes"];
        }
        
        if(tripData.depLatitude != nil){
            [parametersDictionary setObject:tripData.depLatitude forKey:@"depLat"];
        } else {
            [parametersDictionary setObject:@0 forKey:@"depLat"];
        }
        
        if(tripData.depLongitude != nil){
            [parametersDictionary setObject:tripData.depLongitude forKey:@"depLong"];
        } else {
            [parametersDictionary setObject:@0 forKey:@"depLong"];
        }
        
        if(tripData.arrLatitude != nil){
            [parametersDictionary setObject:tripData.arrLatitude forKey:@"arrLat"];
        } else {
            [parametersDictionary setObject:@0 forKey:@"arrLat"];
        }
        
        if(tripData.arrLongitude != nil){
            [parametersDictionary setObject:tripData.arrLongitude forKey:@"arrLong"];
        } else {
            [parametersDictionary setObject:@0 forKey:@"arrLong"];
        }
        
        if(tripData.tripType != nil){
            [parametersDictionary setObject:tripData.tripType forKey:@"serviceType"];
        } else {
            [parametersDictionary setObject:@"" forKey:@"serviceType"];
        }
        
        
        NSData *postData = [NSJSONSerialization dataWithJSONObject:parametersDictionary options:NSJSONWritingPrettyPrinted error:&err];
        [def setBool:YES forKey:@"updateTimeStamp"];
        //Pass paramters dictionary and URL of script to get response
        [common saveToCloud:postData urlString:kLogDataScript success:^(NSDictionary *responseDict) {
            //NSLog(@"responseDict LOG : %@", responseDict);
            
            if([[responseDict objectForKey:@"message"] isEqualToString:@"Success"]){
                
                [common clearPhoneSyncTableWithID:rowID tableName:tableName andType:type];
            }
        } failure:^(NSError *error) {
            //  NSLog(@"%@", error.localizedDescription);
        }];
        
    } else if ([tableName isEqualToString:@"LOC_TABLE"]){
        
        NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
        NSError *locErr;
        NSFetchRequest *locRequest = [[NSFetchRequest alloc] initWithEntityName:@"Loc_Table"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"iD == %d", [rowID intValue]];
        [locRequest setPredicate:predicate];
        
        NSArray *locArray = [context executeFetchRequest:locRequest error:&locErr];
        
        Loc_Table *locationData = [locArray firstObject];
        
        NSMutableDictionary *parametersDictionary = [[NSMutableDictionary alloc] init];
        
        if([def objectForKey:@"UserDeviceId"] != nil){
            [parametersDictionary setObject:[def objectForKey:@"UserDeviceId"] forKey:@"androidId"];
        } else {
            [parametersDictionary setObject:@"" forKey:@"androidId"];
        }
        
        if([def objectForKey:@"UserEmail"] != nil){
            [parametersDictionary setObject:[def objectForKey:@"UserEmail"] forKey:@"email"];
        } else {
            [parametersDictionary setObject:@"" forKey:@"email"];
        }
        
        if(type != nil){
            [parametersDictionary setObject:type forKey:@"type"];
        } else {
            [parametersDictionary setObject:@"" forKey:@"type"];
        }
        
        if(rowID != nil){
            [parametersDictionary setObject:rowID forKey:@"_id"];
        } else {
            [parametersDictionary setObject:@"" forKey:@"_id"];
        }
        
        if([locationData.lat floatValue] != 0.0){
            [parametersDictionary setObject:locationData.lat forKey:@"lat"];
        } else {
            [parametersDictionary setObject:@"" forKey:@"lat"];
        }
        
        if([locationData.longitude floatValue] != 0.0){
            [parametersDictionary setObject:locationData.longitude forKey:@"long"];
        } else {
            [parametersDictionary setObject:@"" forKey:@"long"];
        }
        
        if(locationData.address != nil){
            [parametersDictionary setObject:locationData.address forKey:@"address"];
        } else {
            [parametersDictionary setObject:@"" forKey:@"address"];
        }
        
        if(locationData.brand != nil){
            [parametersDictionary setObject:locationData.brand forKey:@"brand"];
        } else {
            [parametersDictionary setObject:@"" forKey:@"brand"];
        }
        
        NSError *error;
        NSData *postData = [NSJSONSerialization dataWithJSONObject:parametersDictionary options:NSJSONWritingPrettyPrinted error:&error];
        [def setBool:YES forKey:@"updateTimeStamp"];
        commonMethods *common = [[commonMethods alloc] init];
        //Pass paramters dictionary and URL of script to get response
        [common saveToCloud:postData urlString:kLocationScript success:^(NSDictionary *responseDict) {
            // NSLog(@"responseDict LOG : %@", responseDict);
            
            if([[responseDict objectForKey:@"message"] isEqualToString:@"Success"]){
                
                [common clearPhoneSyncTableWithID:rowID tableName:tableName andType:type];
            }
        } failure:^(NSError *error) {
            //          NSLog(@"%@", error.localizedDescription);
        }];
    }
}



@end
