//
//  SERVICE_CENTER_RATING+CoreDataProperties.m
//  FuelBuddy
//
//  Created by Nikhil on 08/07/19.
//  Copyright © 2019 Oraganization. All rights reserved.
//
//

#import "SERVICE_CENTER_RATING+CoreDataProperties.h"

@implementation SERVICE_CENTER_RATING (CoreDataProperties)

+ (NSFetchRequest<SERVICE_CENTER_RATING *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"SERVICE_CENTER_RATING"];
}

@dynamic email;
@dynamic name;
@dynamic address;
@dynamic lat;
@dynamic longi;
@dynamic rating;
@dynamic comments;
@dynamic services;
@dynamic cost;
@dynamic curr;
@dynamic date;
@dynamic phone_number;
@dynamic website;

@end
