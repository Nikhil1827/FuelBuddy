//
//  commonMethods.h
//  FuelBuddy
//
//  Created by Swapnil on 19/06/17.
//  Copyright © 2017 Oraganization. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface commonMethods : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate, NSURLSessionDelegate>

@property (nonatomic,retain)UIView *loadingView;
+ (void)startActivitySpinner: (NSString *)labelText; 
-(NSNumberFormatter *)decimalFormatter;
//-(void)friendRequestOrConfirmationReceived:(NSMutableDictionary *) friendDict;
- (void) updateConsumption: (int)contextStatus;
-(void)updateConsumptionMaxOdo;
- (void) updateDistance: (int)contextStatus;
- (BOOL)checkOdo:(float)iOdo ForDate:(NSDate*)iDate;
+ (UIImage *)imageWithImage:(UIImage *)image
               scaledToSize:(CGSize)newSize;

//Swapnil NEW_6
- (void)saveToCloud:(NSData *)postData urlString: (NSString *)urlString success: (void (^)(NSDictionary *responseDict))success failure: (void (^)(NSError *error))failure;

- (void)clearPhoneSyncTableWithID: (NSNumber *)rowID tableName: (NSString *)tableName andType: (NSString *)type;

- (BOOL)saveToVehicleTable: (NSDictionary *)dictionary;
- (BOOL)saveToLogTable: (NSDictionary *)dictionary;
- (BOOL)saveToServiceTable: (NSDictionary *)dictionary;
- (void)saveToLocationTable: (NSDictionary *)dictionary;
- (BOOL)saveSettings: (NSDictionary *)dictionary;

- (void)deleteAllTablesFromDB;
- (int)clearCloudSyncTable: (NSMutableArray *)syncArray;
- (void)saveFromCloudToLocalDB: (NSDictionary *)dictionary;
-(void)startHUD;
- (void)checkNetworkForCloudStorage:(NSString *)isTrip;
-(NSNumber *)getMaxFuelID;
-(double)getMaxNoTripOdoForAllVehicles;
-(double)getMaxNoTripOdoForVehicle: (NSNumber *)vehId;

- (NSDictionary *)getDayMonthYrFromStringDate: (NSDate *)stringDate;
@property (nonatomic,retain) NSString *distance,*volume,*consump, *currency;
@end
