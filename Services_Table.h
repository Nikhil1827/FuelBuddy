//
//  Services_Table.h
//  FuelBuddy
//
//  Created by Surabhi on 23/12/15.
//  Copyright (c) 2015 Oraganization. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Services_Table : NSManagedObject

@property (nonatomic, retain) NSNumber * dueDays;
@property (nonatomic, retain) NSNumber * dueMiles;
@property (nonatomic, retain) NSNumber * iD;
@property (nonatomic, retain) NSDate * lastDate;
@property (nonatomic, retain) NSNumber * lastOdo;
@property (nonatomic, retain) NSNumber * recurring;
@property (nonatomic, retain) NSString * serviceName;
@property (nonatomic, retain) NSString * vehid;
@property (nonatomic, retain) NSNumber * type;

@end
