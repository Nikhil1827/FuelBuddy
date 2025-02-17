//
//  SettingsDetailViewController.h
//  FuelBuddy
//
//  Created by Surabhi on 08/12/15.
//  Copyright (c) 2015 Oraganization. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GADMasterViewController.h"
#import "AppDelegate.h"

@interface SettingsDetailViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,GADBannerViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableview;
@property (nonatomic,retain) NSMutableArray *selectvalue;
@property (nonatomic,retain)NSString *unittype;
@property (nonatomic,retain) NSString *distance,*volume,*consump;
@end
