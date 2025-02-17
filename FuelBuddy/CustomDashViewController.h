//
//  CustomDashViewController.h
//  FuelBuddy
//
//  Created by surabhi on 05/02/16.
//  Copyright © 2016 Oraganization. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GADMasterViewController.h"
@interface CustomDashViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,GADBannerViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (nonatomic,retain) NSMutableArray *dataarray;
@property (nonatomic,retain) NSMutableArray *selecteddata,*alldata;
@end
