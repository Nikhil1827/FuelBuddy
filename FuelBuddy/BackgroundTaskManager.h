//
//  BackgroundTaskManager.h
//  FuelBuddy
//
//  Created by Nikhil on 12/10/18.
//  Copyright © 2018 Oraganization. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface BackgroundTaskManager : NSObject

+(instancetype)sharedBackgroundTaskManager;
-(UIBackgroundTaskIdentifier)beginNewBackgroundTask;
-(void)endAllBackgroundTasks;

@end
