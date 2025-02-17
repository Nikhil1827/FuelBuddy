//
//  Veh_Table.h
//  FuelBuddy
//
//  Created by Surabhi on 05/11/15.
//  Copyright (c) 2015 Oraganization. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Veh_Table : NSManagedObject

@property (nonatomic, retain) NSNumber * iD;
@property (nonatomic, retain) NSString * insuranceNo;
@property (nonatomic, retain) NSString * lic;
@property (nonatomic, retain) NSString * make;
@property (nonatomic, retain) NSString * model;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSString * picture;
@property (nonatomic, retain) NSString * vehid;
@property (nonatomic, retain) NSString * vin;
@property (nonatomic, retain) NSString * year;
@property (nonatomic, retain) NSString * fuel_type;
@property (nonatomic, retain) NSString *customSpecs;

@end
