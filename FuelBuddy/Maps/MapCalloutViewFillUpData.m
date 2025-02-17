//
//  MapCalloutViewFillUpData.m
//  FuelBuddy
//
//  Created by Nikhil on 25/12/18.
//  Copyright © 2018 Oraganization. All rights reserved.
//

#import "MapCalloutViewFillUpData.h"

@implementation MapCalloutViewFillUpData

- (instancetype)initWithLatitude:(NSNumber *)latitude
                       longitude:(NSNumber *)longitude
                           title:(NSString *)title
                            date:(NSString *)date
                            cost:(NSNumber *)cost
                             qty:(NSNumber *)qty {
    self = [super init];
    if (self) {
        _latitude = latitude;
        _longitude = longitude;
        _title = title;
        _date = date;
        _cost = cost;
        _qty = qty;
    }
    return self;
}

- (NSString *)fillUpStringWith:(NSString *)volString
                    currString:(NSString *)currString {
    return [NSString stringWithFormat:@"%@\n%@ %@\n%@ %@", _date, _qty.stringValue, volString, _cost.stringValue, currString];
}

@end

@implementation fillUpLatLong

- (instancetype)initWithLatitude:(NSString *)latitude
                       longitude:(NSString *)longitude
                        title:(NSString *)title {
    self = [super init];
    if (self) {
        _latitude = latitude;
        _longitude = longitude;
        _title = title;
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[fillUpLatLong class]]) {
        fillUpLatLong *expectedLatLong = (fillUpLatLong *)object;
        return [_latitude isEqualToString:expectedLatLong.latitude] && [_longitude isEqualToString:expectedLatLong.longitude] && [_title isEqualToString:expectedLatLong.title];
    }
    return NO;
}

@end



