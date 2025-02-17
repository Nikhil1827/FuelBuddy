//
//  CheckReachability.h
//  FuelBuddy
//
//  Created by Nikhil on 14/01/19.
//  Copyright © 2019 Oraganization. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"

@interface CheckReachability : NSObject

@property (retain, nonatomic)  Reachability* reach;

+ (CheckReachability *)sharedManager;
-(void)startNetworkMonitoring;
-(void)stopNetworkMonitoring;
- (void)fetchDataFromSyncTable;

@end

