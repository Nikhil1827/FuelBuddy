//
//  FillUpDataHandler.h
//  FuelBuddy
//
//  Created by Nikhil on 14/05/18.
//  Copyright © 2018 Oraganization. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FillUpDataHandler : NSObject

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
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSNumber * latitude;
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

-(void)addFillUp:(int)contextType;
-(void)editFillUp:(NSDictionary *)editDict :(int)contextType;
-(void)deleteFillUp:(int)contextType;

@end
