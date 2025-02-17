//
//  ServiceDataHandler.h
//  FuelBuddy
//
//  Created by Nikhil on 16/05/18.
//  Copyright © 2018 Oraganization. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServiceDataHandler : NSObject

@property (nonatomic, retain) NSNumber * dueDays;
@property (nonatomic, retain) NSNumber * dueMiles;
@property (nonatomic, retain) NSNumber * iD;
@property (nonatomic, retain) NSDate * lastDate;
@property (nonatomic, retain) NSNumber * lastOdo;
@property (nonatomic, retain) NSNumber * recurring;
@property (nonatomic, retain) NSString * serviceName;
@property (nonatomic, retain) NSString * vehid;
@property (nonatomic, retain) NSNumber * type;

-(void)addService:(int)contextType;
-(void)editService:(NSDictionary *)editDict :(int)contextType;
-(void)deleteService:(int)contextType;

@end
