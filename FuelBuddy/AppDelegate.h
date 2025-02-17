//
//  AppDelegate.h
//  FuelBuddy
//
//  Copyright (c) 2015 Oraganization. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataController.h"
#import <UserNotifications/UserNotifications.h>
#import <GoogleSignIn/GoogleSignIn.h>
#import "LocationTracker.h"
#import "LocationManager.h"

@import Firebase;
@import GoogleSignIn;

typedef NS_ENUM(NSInteger, SpinnerType) {
    DownloadStarted
};

@interface AppDelegate : UIResponder <UIApplicationDelegate, UNUserNotificationCenterDelegate, GIDSignInDelegate, FIRMessagingDelegate ,CLLocationManagerDelegate>


@property (strong, nonatomic) UIWindow *window;
@property LocationTracker * locationTracker;
@property (strong,nonatomic) LocationManager * shareModel;
@property (nonatomic) NSTimer* locationUpdateTimer;

@property (nonatomic,retain)UIButton *expense,*fillup,*services,*tabbutton,*trip;
@property (nonatomic,retain)UILabel *expenselab,*filluplab,*serviceslab, *tripLab;
@property (nonatomic,retain)UIView *blurview;
@property (nonatomic,assign)CGSize result;
@property (nonatomic,assign)long recordnumber;
@property (nonatomic,retain) NSString * globalCheckOrientation;

@property (nonatomic) NSInteger selPickerViewRow;
@property (nonatomic) NSMutableArray *friendsArray;

//- (NSURL *)applicationDocumentsDirectory;
-(void)clickadd;
-(void)saveTrip;
-(void)updateTrip;
-(void)expireOldNotifications;
-(void)showNotification:(NSString *)alertTitle :(NSString *)alertBody;
-(void)showTripCountNotification:(NSString *)alertTitle :(NSString *)alertBody;

-(BOOL)application:(UIApplication *)application
           openURL:(NSURL *)url
 sourceApplication:(NSString *)sourceApplication
        annotation:(id)annotation;

@property () BOOL restrictRotation;

- (void)removeRecordType0FromService;
- (void)saveCloudDataInBg: (int)DBDeletionFlag;

+ (AppDelegate *)sharedAppDelegate;

-(UIWindow *)topView;

@end

