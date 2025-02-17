//
//  T_Fuelcons.h
//  FuelBuddy
//
//  Created by Surabhi on 29/11/15.
//  Copyright (c) 2015 Oraganization. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface T_Fuelcons : NSManagedObject

@property (nonatomic, retain) NSNumber * cons;
@property (nonatomic, retain) NSNumber * cost;
@property (nonatomic, retain) NSNumber * date;
@property (nonatomic, retain) NSNumber * day;
@property (nonatomic, retain) NSNumber * dist;
@property (nonatomic, retain) NSString * fillStation;
@property (nonatomic, retain) NSString * fuelBrand;
@property (nonatomic, retain) NSNumber * iD;
@property (nonatomic, retain) NSNumber * mfill;
@property (nonatomic, retain) NSNumber * month;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSNumber * octane;
@property (nonatomic, retain) NSNumber * odo;
@property (nonatomic, retain) NSNumber * pfill;
@property (nonatomic, retain) NSNumber * qty;
@property (nonatomic, retain) NSString * receipt;
@property (nonatomic, retain) NSString * serviceType;
@property (nonatomic, retain) NSDate * stringDate;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSString * vehid;
@property (nonatomic, retain) NSNumber * year;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSNumber * latitude;

@end
