//
//  LogViewController.h
//  FuelBuddy
//
//  Created by Surabhi on 16/11/15.
//  Copyright (c) 2015 Oraganization. All rights reserved.
//

#import <UIKit/UIKit.h>
//@import GoogleMobileAds;
#import "LogPageContentViewController.h"
#import <UserNotifications/UserNotifications.h>

@interface LogViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIPickerViewDataSource,UIPickerViewDelegate, UIPageViewControllerDataSource, UNUserNotificationCenterDelegate>
{
    //Swapnil 7 Mar-17
    UIView *navigationOverlay;
    UIView *tabbarOverlay;
}

@property (strong, nonatomic) IBOutlet UIImageView *vehimg;
@property (strong, nonatomic) IBOutlet UILabel *addveh;
@property (strong, nonatomic) IBOutlet UIImageView *set;
@property (nonatomic,retain) NSMutableArray *detailsarray;
@property (strong, nonatomic) IBOutlet UILabel *distlab;
@property (strong, nonatomic) IBOutlet UILabel *getstarted;
@property (strong, nonatomic) IBOutlet UITableView *tableview;
@property (strong, nonatomic) IBOutlet UIButton *vehiclebutton;
@property (strong, nonatomic) IBOutlet UILabel *vehname;
@property (strong, nonatomic) IBOutlet UIImageView *vehimage;
@property (strong, nonatomic) IBOutlet UIView *lineview;

@property (nonatomic,retain) NSString *pickerval;
@property(nonatomic,retain)UIDatePicker *pic;
@property (nonatomic,retain)UIPickerView *picker;
@property (nonatomic,retain) UIButton *setbutton;
@property (nonatomic,retain) NSMutableArray *vehiclearray;
@property (nonatomic,retain) NSString *curr,*vol,*dist,*con;
@property (weak, nonatomic) IBOutlet UIButton *dropdownButton;

//Swapnil 7 Mar-17

@property (nonatomic, strong) UIPageViewController *pageViewController;

@property (nonatomic, strong) NSArray *pageTitles;
@property (nonatomic, strong) NSArray *imagesArray;

- (void)donelabel;

- (LogPageContentViewController *)viewControllerAtIndex: (NSUInteger)index;
-(void)fetchdata;
-(void)fetchallfillup;
-(void)updateServiceOdo: (NSString *)vehid : (NSArray *)servicename andiD: (NSNumber *)rowID;

@end
