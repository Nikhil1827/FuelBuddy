//
//  MapCalloutViewServiceData.h
//  FuelBuddy
//
//  Created by Nikhil on 25/12/18.
//  Copyright © 2018 Oraganization. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MapCalloutViewServiceData : NSObject

@property (nonatomic, readonly, strong) NSNumber *latitude;
@property (nonatomic, readonly, strong) NSNumber *longitude;
@property (nonatomic, readonly, strong) NSString *title;
@property (nonatomic, readonly, strong) NSString *date;
@property (nonatomic, readonly, strong) NSString *name;

- (instancetype)initWithLatitude:(NSNumber *)latitude
                       longitude:(NSNumber *)longitude
                           title:(NSString *)title
                            date:(NSString *)date
                            name:(NSString *)name;

- (NSString *)serviceStringWith;

@end

@interface serLatLong : NSObject

@property (nonatomic, readonly, strong) NSString *latitude;
@property (nonatomic, readonly, strong) NSString *longitude;
@property (nonatomic, readonly, strong) NSString *title;

- (instancetype)initWithLatitude:(NSString *)latitude
                       longitude:(NSString *)longitude
                       title:(NSString *)title;

@end
