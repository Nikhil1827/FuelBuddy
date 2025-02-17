//
//  ServiceTypeViewController.h
//  FuelBuddy
//
//  Created by Surabhi on 16/12/15.
//  Copyright (c) 2015 Oraganization. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GADMasterViewController.h"
#import "AppDelegate.h"
#import "ReminderPageContentViewController.h"


@interface ServiceTypeViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,GADBannerViewDelegate, UIPageViewControllerDataSource>
{
    //Swapnil 7 Mar-17
    UIView *navigationOverlay;
    UIView *tabbarOverlay;

}
@property (strong, nonatomic) IBOutlet UITableView *tableview;
@property (nonatomic,retain) NSMutableArray *servicearray,*checkedarray,*lastservice;
@property (nonatomic,retain) NSString *updateservice;


//Swapnil 7 Mar-17

@property (nonatomic, strong) UIPageViewController *pageViewController;

@property (nonatomic, strong) NSArray *pageTitles1;
@property (nonatomic, strong) NSArray *pageTitles2;
@property (nonatomic, strong) NSArray *imagesArray1;
@property (nonatomic, strong) NSArray *imagesArray2;




- (ReminderPageContentViewController *)viewControllerAtIndex: (NSUInteger)index;

@end
