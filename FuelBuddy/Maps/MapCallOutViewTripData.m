//
//  MapCallOutViewTripData.m
//  FuelBuddy
//
//  Created by Nikhil on 08/01/19.
//  Copyright © 2019 Oraganization. All rights reserved.
//

#import "MapCallOutViewTripData.h"

@implementation MapCallOutViewTripData

- (instancetype)initWithDepLatitude:(NSNumber *)depLatitude
                       depLongitude:(NSNumber *)depLongitude
                        arrLatitude:(NSNumber *)arrLatitude
                       arrLongitude:(NSNumber *)arrLongitude
                           depTitle:(NSString *)depTitle
                           arrTitle:(NSString *)arrTitle
                            depDate:(NSString *)depDate
                            arrDate:(NSString *)arrDate
                             taxDed:(NSString *)taxDed {
    self = [super init];
    if (self) {
        _depLatitude = depLatitude;
        _depLongitude = depLongitude;
        _arrLatitude = arrLatitude;
        _arrLongitude = arrLongitude;
        _depTitle = depTitle;
        _arrTitle = arrTitle;
        _depDate = depDate;
        _arrDate = arrDate;
        _taxDed = taxDed;
        
    }
    return self;
}

- (NSString *)tripDepStringWith{
    
    return [NSString stringWithFormat:@"%@",_depDate];
}

- (NSString *)tripArrStringWith{
    
    return [NSString stringWithFormat:@"%@",_arrDate];
}

@end
