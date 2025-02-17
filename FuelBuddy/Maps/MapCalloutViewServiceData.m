//
//  MapCalloutViewServiceData.m
//  FuelBuddy
//
//  Created by Nikhil on 25/12/18.
//  Copyright © 2018 Oraganization. All rights reserved.
//

#import "MapCalloutViewServiceData.h"

@implementation MapCalloutViewServiceData

- (instancetype)initWithLatitude:(NSNumber *)latitude
                       longitude:(NSNumber *)longitude
                           title:(NSString *)title
                            date:(NSString *)date
                            name:(NSString *)name {
    self = [super init];
    if (self) {
        _latitude = latitude;
        _longitude = longitude;
        _title = title;
        _date = date;
        _name = name;
    }
    return self;
}

- (NSString *)serviceStringWith{
    
    return [NSString stringWithFormat:@"%@\n%@",_date,_name];
}

@end


@implementation serLatLong

- (instancetype)initWithLatitude:(NSString *)latitude
                       longitude:(NSString *)longitude
                       title:(NSString *)title{
    self = [super init];
    if (self) {
        _latitude = latitude;
        _longitude = longitude;
        _title = title;
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[serLatLong class]]) {
        serLatLong *expectedLatLong = (serLatLong *)object;
        return [_latitude isEqualToString:expectedLatLong.latitude] && [_longitude isEqualToString:expectedLatLong.longitude] && [_title isEqualToString:expectedLatLong.title];
    }
    return NO;
}

@end
