//
//  LocationServices.m
//  FuelBuddy
//
//  Created by Swapnil on 10/07/17.
//  Copyright © 2017 Oraganization. All rights reserved.
//

#import "LocationServices.h"
#import "AddTripViewController.h"

@import UserNotifications;



@interface LocationServices ()

@end

@implementation LocationServices{
    
    CLPlacemark *placemark;
    double counter;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

+(LocationServices *)sharedInstance{
    
    static LocationServices *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

- (id)init{
    
    self = [super init];
    if(self != nil){
        
        self.locationManager = [[CLLocationManager alloc] init];
        //self.geoCoder = [[CLGeocoder alloc] init];
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationManager.distanceFilter = 5;
        self.locationManager.activityType = CLActivityTypeAutomotiveNavigation;

        self.locationManager.delegate = self;
    }
    return self;
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"unable to access location");
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    
    self.latestLoc = [locations lastObject];
    //NSLog(@"latest loc = %@", self.latestLoc);
    
    if(self.startLoc == nil){
        self.startLoc = self.latestLoc;
    }
    
    self.distanceTravelled += [self distanceBetweenStartLoc:self.startLoc andEndLoc:self.latestLoc];
    
    self.distInKm = [NSString stringWithFormat:@"%.2f", self.distanceTravelled / 1000];
   // NSLog(@"dist = %@", self.distInKm);
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    if([def boolForKey:@"startNotifications"] == YES){
        if(counter >= 100){
        
            counter = 0;
            [self removeNotification];
        }
    }
    

    self.startLoc = self.latestLoc;
}

- (double)distanceBetweenStartLoc: (CLLocation *)startLocation andEndLoc: (CLLocation *)endLocation{

    CLLocationDistance distance = [endLocation distanceFromLocation:startLocation];
    counter += distance;
    return distance;
}


- (void)removeNotification{
    
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center removeDeliveredNotificationsWithIdentifiers:[NSArray arrayWithObject:@"FiveSecond"]];
    [self addNewNotification];
}

- (void)addNewNotification{
    //NIKHIL Resolved crash #241
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.title = [NSString localizedUserNotificationStringForKey:NSLocalizedString(@"trip_in_progress", @"Trip In Progress")  arguments:nil];
    
    double dist = self.distanceTravelled / 1000;
    NSString *metric;;
    if([[[NSUserDefaults standardUserDefaults]objectForKey:@"dist_unit"] isEqualToString:NSLocalizedString(@"disp_miles", @"Miles")]){
        metric = NSLocalizedString(@"mi", @"mi");
        dist = dist / 1.61;
    } else {
        metric = NSLocalizedString(@"kms", @"Km");
    }
    
    content.body = [NSString localizedUserNotificationStringForKey:[NSString stringWithFormat:@"%@ : %.2f %@", NSLocalizedString(@"trp_distance", @"Trip Distance"), dist, metric] arguments:nil];
    
    //content.sound = [UNNotificationSound defaultSound];
    content.badge = nil;
    
    UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger
                                                  triggerWithTimeInterval:2.f repeats:NO];
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"FiveSecond"
                                                                          content:content trigger:trigger];
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        if (!error) {
            NSLog(@"add NotificationRequest succeeded!");
        }
    }];
}

@end
