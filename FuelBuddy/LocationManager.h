//
//  LocationManager.h
//  FuelBuddy
//
//  Created by Nikhil on 25/10/18.
//  Copyright © 2018 Oraganization. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "LocationTracker.h"

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

@interface LocationManager : NSObject

@property (nonatomic) CLLocationManager * anotherLocationManager, *someAnotherLocationManager;

@property (nonatomic) CLLocationCoordinate2D myLastLocation;
@property (nonatomic) CLLocationAccuracy myLastLocationAccuracy;

@property (nonatomic) CLLocationCoordinate2D myLocation;
@property (nonatomic) CLLocationAccuracy myLocationAccuracy;
@property LocationTracker *locationTracker;

+ (id)sharedManager;

- (void)startMonitoringLocation;
//- (void)restartMonitoringLocation;

@end
