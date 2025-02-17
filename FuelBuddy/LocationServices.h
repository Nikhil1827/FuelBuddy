//
//  LocationServices.h
//  FuelBuddy
//
//  Created by Swapnil on 10/07/17.
//  Copyright © 2017 Oraganization. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface LocationServices : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate>

+(LocationServices *)sharedInstance;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLGeocoder *geoCoder;
@property (strong, nonatomic) CLLocation *startLoc, *latestLoc;
@property double distanceTravelled;
@property (strong, nonatomic) NSString *distInKm;
@property NSString *address;

@end
