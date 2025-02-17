//
//  SERVICE_CENTER_RATING+CoreDataProperties.h
//  FuelBuddy
//
//  Created by Nikhil on 08/07/19.
//  Copyright © 2019 Oraganization. All rights reserved.
//
//

#import "SERVICE_CENTER_RATING+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface SERVICE_CENTER_RATING (CoreDataProperties)

+ (NSFetchRequest<SERVICE_CENTER_RATING *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *email;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSString *address;
@property (nullable, nonatomic, copy) NSNumber *lat;
@property (nullable, nonatomic, copy) NSNumber *longi;
@property (nullable, nonatomic, copy) NSNumber *rating;
@property (nullable, nonatomic, copy) NSString *comments;
@property (nullable, nonatomic, copy) NSString *services;
@property (nullable, nonatomic, copy) NSNumber *cost;
@property (nullable, nonatomic, copy) NSString *curr;
@property (nullable, nonatomic, copy) NSDate *date;
@property (nullable, nonatomic, copy) NSString *phone_number;
@property (nullable, nonatomic, copy) NSString *website;

@end

NS_ASSUME_NONNULL_END
