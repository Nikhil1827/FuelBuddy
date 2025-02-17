//
//  LocationManager.m
//  FuelBuddy
//
//  Created by Nikhil on 25/10/18.
//  Copyright © 2018 Oraganization. All rights reserved.
//

#import "LocationManager.h"
#import <UIKit/UIKit.h>
#import "CoreDataController.h"
#import "T_Trip.h"


@interface LocationManager () <CLLocationManagerDelegate> {
    
    NSUInteger tripCount;
}

@end


@implementation LocationManager

//Class method to make sure the share model is synch across the app
+ (id)sharedManager {
    static id sharedMyModel = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedMyModel = [[self alloc] init];
    });
    
    return sharedMyModel;
}


#pragma mark - CLLocationManager

- (void)startMonitoringLocation {
    if (_anotherLocationManager)
        [_anotherLocationManager stopMonitoringSignificantLocationChanges];
    
    self.anotherLocationManager = [[CLLocationManager alloc]init];
    _anotherLocationManager.delegate = self;
    _anotherLocationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    _anotherLocationManager.activityType = CLActivityTypeOtherNavigation;
    
    if(IS_OS_8_OR_LATER) {
        [_anotherLocationManager requestAlwaysAuthorization];
    }
    [_anotherLocationManager startMonitoringSignificantLocationChanges];
   
    NSLog(@"started startMonitoringSignificantLocationChanges in startMonitoringLocation");
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    
    BOOL autoTripOn = [def boolForKey:@"autoTripSwitchOn"];
    BOOL tripInProgress = [[NSUserDefaults standardUserDefaults] boolForKey:@"tripInProgress"];
    BOOL doNotDetect = [def boolForKey:@"doNotDetectTripOnWeekEnd"];
    
    BOOL proUser = [[NSUserDefaults standardUserDefaults] boolForKey:@"isSubscribed"];
    
    NSDateFormatter *formater = [[NSDateFormatter alloc] init];
    [formater setDateFormat:@"EEEE"];
    NSString *currentDay = [formater stringFromDate:[NSDate date]];
    
    NSUInteger remainingTripCount=0;
    [self fetchTripCountForThisMonth];
        
    if(tripCount<10){
        
        remainingTripCount = 10-tripCount;
    }else{
        remainingTripCount = tripCount;
    }
    
    if(![def boolForKey:@"fromAppDelegate"]){
        
        if(proUser || remainingTripCount<11){
            
            if(doNotDetect){
                
                if([currentDay isEqualToString:@"Saturday"] || [currentDay isEqualToString:@"Sunday"]){
                    
                    NSLog(@"Do not detect is on and today is %@ so cannot auto log trip",currentDay);
                }else{
                    
                    if(!tripInProgress && autoTripOn){
                        
                        NSLog(@"started location ""TRACKING"" from startMonitoringLocation in location manager");
                        self.locationTracker = [[LocationTracker alloc]init];
                        [self.locationTracker startLocationTracking];
                        [def setBool:YES forKey:@"showTripInProgress"];
                        
                    }
                }
                
            }else{
                
                if(!tripInProgress && autoTripOn){
                    
                    NSLog(@"started location ""TRACKING"" from startMonitoringLocation in location manager");
                    self.locationTracker = [[LocationTracker alloc]init];
                    [self.locationTracker startLocationTracking];
                    [def setBool:YES forKey:@"showTripInProgress"];
                }
                
            }
            
        }
    }
    
    // [def setBool:NO forKey:@"fromAppDelegate"];
    
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


#pragma mark - CLLocationManager Delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    
    NSLog(@"locationManager didUpdateLocations");
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    BOOL autoTripOn = [def boolForKey:@"autoTripSwitchOn"];
    BOOL tripInProgress = [[NSUserDefaults standardUserDefaults] boolForKey:@"tripInProgress"];
    BOOL doNotDetect = [def boolForKey:@"doNotDetectTripOnWeekEnd"];
    
    BOOL proUser = [[NSUserDefaults standardUserDefaults] boolForKey:@"isSubscribed"];
    
    NSDateFormatter *formater = [[NSDateFormatter alloc] init];
    [formater setDateFormat:@"EEEE"];
    NSString *currentDay = [formater stringFromDate:[NSDate date]];
    
    NSUInteger remainingTripCount=0;
    [self fetchTripCountForThisMonth];
    
    if(tripCount<10){
        
        remainingTripCount = 10-tripCount;
    }else{
        remainingTripCount = tripCount;
    }
    
    if(![def boolForKey:@"fromAppDelegate"]){
        
        if(proUser || remainingTripCount<11){
            
            if(doNotDetect){
                
                if([currentDay isEqualToString:@"Saturday"] || [currentDay isEqualToString:@"Sunday"]){
                    
                    NSLog(@"Do not detect is on and today is %@ so cannot auto log trip",currentDay);
                }else{
                    
                    if(!tripInProgress && autoTripOn){
                        
                        NSLog(@"started location ""TRACKING"" from didUpdateLocations in location manager");
                        self.locationTracker = [[LocationTracker alloc]init];
                        [self.locationTracker startLocationTracking];
                        [def setBool:YES forKey:@"showTripInProgress"];
                    }
                }
                
                
            }else{
                
                if(!tripInProgress && autoTripOn){
                    
                    NSLog(@"started location ""TRACKING"" from didUpdateLocations in location manager");
                    self.locationTracker = [[LocationTracker alloc]init];
                    [self.locationTracker startLocationTracking];
                    [def setBool:YES forKey:@"showTripInProgress"];
                }
                
            }
            
        }
    }
    [def setBool:NO forKey:@"fromAppDelegate"];
    NSLog(@"Set No to fromAppDelegate");
    
}

@end
