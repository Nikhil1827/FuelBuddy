//
//  JRNLocalNotificationCenter.m
//  DemoApp
//
//  Created by jarinosuke on 7/27/13.
//  Copyright (c) 2013 jarinosuke. All rights reserved.
//

#import "JRNLocalNotificationCenter.h"

NSString *const JRNLocalNotificationHandlingKeyName = @"JRN_KEY";
NSString *const JRNApplicationDidReceiveLocalNotification = @"JRNApplicationDidReceiveLocalNotification";

@interface JRNLocalNotificationCenter()
@property (nonatomic) NSMutableDictionary *localPushDictionary;
@property (nonatomic) BOOL checkRemoteNotificationAvailability;
@end

static JRNLocalNotificationCenter *defaultCenter;

@implementation JRNLocalNotificationCenter

+ (instancetype)defaultCenter
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultCenter = [JRNLocalNotificationCenter new];
        defaultCenter.localPushDictionary = [NSMutableDictionary new];
        [defaultCenter loadScheduledLocalPushNotificationsFromApplication];
        defaultCenter.checkRemoteNotificationAvailability = NO;
        defaultCenter.localNotificationHandler = nil;
    });
    return defaultCenter;
}

- (void)loadScheduledLocalPushNotificationsFromApplication
{
    NSArray *scheduleLocalPushNotifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    for (UILocalNotification *localNotification in scheduleLocalPushNotifications) {
        if (localNotification.userInfo[JRNLocalNotificationHandlingKeyName]) {
            [self.localPushDictionary setObject:localNotification forKey:localNotification.userInfo[JRNLocalNotificationHandlingKeyName]];
        }
    }
}

- (NSArray *)localNotifications
{
    return [[NSArray alloc] initWithArray:[self.localPushDictionary allValues]];
}


- (void)didReceiveLocalNotificationUserInfo:(NSDictionary *)userInfo
{
    NSString *key = userInfo[JRNLocalNotificationHandlingKeyName];
    if (!key) {
        return;
    }
    [self.localPushDictionary removeObjectForKey:key];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:JRNApplicationDidReceiveLocalNotification
                                                        object:nil
                                                      userInfo:userInfo];
    
    if (self.localNotificationHandler) {
        self.localNotificationHandler(userInfo[JRNLocalNotificationHandlingKeyName], userInfo);
    }
}


- (void)cancelAllLocalNotifications
{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [self.localPushDictionary removeAllObjects];
}

- (void)cancelLocalNotification:(UILocalNotification *)localNotification
{
    if (!localNotification) {
        return;
    }
    
    [[UIApplication sharedApplication] cancelLocalNotification:localNotification];
    if (localNotification.userInfo[JRNLocalNotificationHandlingKeyName]) {
        [self.localPushDictionary removeObjectForKey:localNotification.userInfo[JRNLocalNotificationHandlingKeyName]];
    }
}

- (void)cancelLocalNotificationForKey:(NSString *)key
{
    if (!self.localPushDictionary[key]) {
        return;
    }
    
    UILocalNotification *localNotification = self.localPushDictionary[key];
    [[UIApplication sharedApplication] cancelLocalNotification:localNotification];
    [self.localPushDictionary removeObjectForKey:key];
}

#pragma mark -
#pragma mark - Post on now

- (UILocalNotification *)postNotificationOnNowForKey:(NSString *)key
                                           alertBody:(NSString *)alertBody
{
    return [self postNotificationOnNow:YES
                              fireDate:nil
                                forKey:key
                             alertBody:alertBody
                           alertAction:nil
                             soundName:nil
                           launchImage:nil
                              userInfo:nil
                            badgeCount:0
                        repeatInterval:0
                        category:nil];
}

- (UILocalNotification *)postNotificationOnNowForKey:(NSString *)key
                          alertBody:(NSString *)alertBody
                           userInfo:(NSDictionary *)userInfo
{
    return [self postNotificationOnNow:YES
                              fireDate:nil
                                forKey:key
                             alertBody:alertBody
                           alertAction:nil
                             soundName:nil
                           launchImage:nil
                              userInfo:userInfo
                            badgeCount:0
                        repeatInterval:0
                              category:nil];
}

- (UILocalNotification *)postNotificationOnNowForKey:(NSString *)key
                          alertBody:(NSString *)alertBody
                           userInfo:(NSDictionary *)userInfo
                         badgeCount:(NSInteger)badgeCount
{
    return [self postNotificationOnNow:YES
                              fireDate:nil
                                forKey:key
                             alertBody:alertBody
                           alertAction:nil
                             soundName:nil
                           launchImage:nil
                              userInfo:userInfo
                            badgeCount:badgeCount
                        repeatInterval:0
                        category:nil];
}

- (UILocalNotification *)postNotificationOnNowForKey:(NSString *)key
                          alertBody:(NSString *)alertBody
                        alertAction:(NSString *)alertAction
                          soundName:(NSString *)soundName
                        launchImage:(NSString *)launchImage
                           userInfo:(NSDictionary *)userInfo
                         badgeCount:(NSUInteger)badgeCount
                     repeatInterval:(NSCalendarUnit)repeatInterval
{
    return [self postNotificationOnNow:YES
                              fireDate:nil
                                forKey:key
                             alertBody:alertBody
                           alertAction:alertAction
                             soundName:soundName
                           launchImage:launchImage
                              userInfo:userInfo
                            badgeCount:badgeCount
                        repeatInterval:repeatInterval
                              category:nil];
}


#pragma mark -
#pragma mark - Post on specified date

- (UILocalNotification *)postNotificationOn:(NSDate *)fireDate
                    forKey:(NSString *)key
                 alertBody:(NSString *)alertBody
{
    return [self postNotificationOnNow:NO
                              fireDate:fireDate
                                forKey:key
                             alertBody:alertBody
                           alertAction:nil
                             soundName:nil
                           launchImage:nil
                              userInfo:nil
                            badgeCount:0
                        repeatInterval:0
                              category:nil];
}

- (UILocalNotification *)postNotificationOn:(NSDate *)fireDate
                    forKey:(NSString *)key
                 alertBody:(NSString *)alertBody
                  userInfo:(NSDictionary *)userInfo
{
    return [self postNotificationOnNow:NO
                              fireDate:fireDate
                                forKey:key
                             alertBody:alertBody
                           alertAction:nil
                             soundName:nil
                           launchImage:nil
                              userInfo:userInfo
                            badgeCount:0
                        repeatInterval:0
                        category:nil];
}

- (UILocalNotification *)postNotificationOn:(NSDate *)fireDate
                    forKey:(NSString *)key
                 alertBody:(NSString *)alertBody
                  userInfo:(NSDictionary *)userInfo
                badgeCount:(NSInteger)badgeCount
{
    return [self postNotificationOnNow:NO
                              fireDate:fireDate
                                forKey:key
                             alertBody:alertBody
                           alertAction:nil
                             soundName:nil
                           launchImage:nil
                              userInfo:userInfo
                            badgeCount:badgeCount
                        repeatInterval:0
                        category:nil];
}

- (UILocalNotification *)postNotificationOn:(NSDate *)fireDate
                    forKey:(NSString *)key
                 alertBody:(NSString *)alertBody
               alertAction:(NSString *)alertAction
                 soundName:(NSString *)soundName
               launchImage:(NSString *)launchImage
                  userInfo:(NSDictionary *)userInfo
                badgeCount:(NSUInteger)badgeCount
            repeatInterval:(NSCalendarUnit)repeatInterval
                 category:(NSString *)category

{
    return [self postNotificationOnNow:NO
                              fireDate:fireDate
                                forKey:key
                             alertBody:alertBody
                           alertAction:alertAction
                             soundName:soundName
                           launchImage:launchImage
                              userInfo:userInfo
                            badgeCount:badgeCount
                        repeatInterval:repeatInterval
                              category:category
            ];
}

- (UILocalNotification *)postNotificationOnNow:(BOOL)presentNow
                     fireDate:(NSDate *)fireDate
                       forKey:(NSString *)key
                    alertBody:(NSString *)alertBody
                  alertAction:(NSString *)alertAction
                    soundName:(NSString *)soundName
                  launchImage:(NSString *)launchImage
                     userInfo:(NSDictionary *)userInfo
                   badgeCount:(NSUInteger)badgeCount
               repeatInterval:(NSCalendarUnit)repeatInterval
                    category:(NSString *)category;
{
    if (self.localPushDictionary[key]) {
        //same key already exists
        return self.localPushDictionary[key];
    }
    
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    if (!localNotification) {
        return nil;
    }
    
    //return nil, if user denied app's notification requirement
    
    NSUInteger notificationType; //UIUserNotificationType(>= iOS8) and UIRemoteNotificatioNType(< iOS8) use same value
    UIApplication *application = [UIApplication sharedApplication];
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1) {
        notificationType = [[application currentUserNotificationSettings] types];
    } else {
        notificationType = [[UIApplication sharedApplication] isRegisteredForRemoteNotifications];
    }
    if (self.checkRemoteNotificationAvailability && ![[UIApplication sharedApplication] isRegisteredForRemoteNotifications]) {
        return nil;
    }
    
    
    BOOL needsNotify = NO;
    
    //Alert
    if (self.checkRemoteNotificationAvailability && (notificationType & UIUserNotificationTypeAlert) != UIUserNotificationTypeAlert) {
        needsNotify = NO;
    } else {
        needsNotify = YES;
    }
    //add key name for handling it.
    NSMutableDictionary *userInfoAddingHandlingKey = [NSMutableDictionary dictionaryWithDictionary:userInfo];
    [userInfoAddingHandlingKey setObject:key forKey:JRNLocalNotificationHandlingKeyName];
    localNotification.userInfo         = userInfoAddingHandlingKey;
    localNotification.alertBody        = alertBody;
    localNotification.alertAction      = alertAction;
    localNotification.alertLaunchImage = launchImage;
    localNotification.repeatInterval   = repeatInterval;
    localNotification.category         =  category;
    
    
    //Sound
    if (self.checkRemoteNotificationAvailability && (notificationType & UIUserNotificationTypeSound) != UIUserNotificationTypeSound) {
        needsNotify = NO;
    } else {
        needsNotify = YES;
    }
    if (soundName) {
        localNotification.soundName = soundName;
    } else {
        localNotification.soundName = UILocalNotificationDefaultSoundName;
    }
    
    
    //Badge
    if (self.checkRemoteNotificationAvailability && (notificationType & UIUserNotificationTypeBadge) != UIUserNotificationTypeBadge) {
    } else {
        localNotification.applicationIconBadgeNumber = badgeCount;
    }
    
    
    if (needsNotify) {
        if (presentNow && !fireDate) {
            [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
        } else {
            localNotification.fireDate = fireDate;
            localNotification.timeZone = [NSTimeZone defaultTimeZone];
            [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        }
        [self.localPushDictionary setObject:localNotification forKey:key];
        return localNotification;
    } else {
        return nil;
    }
}
@end
