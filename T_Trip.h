//
//  T_Trip.h
//  FuelBuddy
//
//  Created by Nupur on 20/09/16.
//  Copyright © 2016 Oraganization. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface T_Trip : NSManagedObject


@property (nullable, nonatomic, copy) NSDate *arrDate;
@property (nullable, nonatomic, copy) NSString *arrLocn;
@property (nullable, nonatomic, copy) NSNumber *arrOdo;
@property (nullable, nonatomic, copy) NSDate *depDate;
@property (nullable, nonatomic, copy) NSString *depLocn;
@property (nullable, nonatomic, copy) NSNumber *depOdo;
@property (nullable, nonatomic, copy) NSNumber *iD;
@property (nullable, nonatomic, copy) NSString *notes;
@property (nullable, nonatomic, copy) NSNumber *parkingAmt;
@property (nullable, nonatomic, copy) NSNumber *taxDedn;
@property (nullable, nonatomic, copy) NSNumber *tollAmt;
@property (nullable, nonatomic, copy) NSString *tripType;
@property (nullable, nonatomic, copy) NSString *vehId;
@property (nullable, nonatomic, copy) NSNumber *depLongitude;
@property (nullable, nonatomic, copy) NSNumber *depLatitude;
@property (nullable, nonatomic, copy) NSNumber *arrLongitude;
@property (nullable, nonatomic, copy) NSNumber *arrLatitude;
@property (nonatomic) BOOL tripComplete;


@end
