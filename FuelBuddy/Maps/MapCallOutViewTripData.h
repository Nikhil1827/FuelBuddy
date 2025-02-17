//
//  MapCallOutViewTripData.h
//  FuelBuddy
//
//  Created by Nikhil on 08/01/19.
//  Copyright © 2019 Oraganization. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MapCallOutViewTripData : NSObject

@property (nonatomic, readonly, strong) NSNumber *depLatitude;
@property (nonatomic, readonly, strong) NSNumber *depLongitude;
@property (nonatomic, readonly, strong) NSNumber *arrLatitude;
@property (nonatomic, readonly, strong) NSNumber *arrLongitude;
@property (nonatomic, readonly, strong) NSString *depTitle;
@property (nonatomic, readonly, strong) NSString *arrTitle;
@property (nonatomic, readonly, strong) NSString *depDate;
@property (nonatomic, readonly, strong) NSString *arrDate;
@property (nonatomic, readonly, strong) NSString *taxDed;

- (instancetype)initWithDepLatitude:(NSNumber *)depLatitude
                       depLongitude:(NSNumber *)depLongitude
                       arrLatitude:(NSNumber *)arrLatitude
                       arrLongitude:(NSNumber *)arrLongitude
                           depTitle:(NSString *)depTitle
                            arrTitle:(NSString *)arrTitle
                            depDate:(NSString *)depDate
                            arrDate:(NSString *)arrDate
                            taxDed:(NSString *)taxDed;

- (NSString *)tripDepStringWith;
- (NSString *)tripArrStringWith;
@end

