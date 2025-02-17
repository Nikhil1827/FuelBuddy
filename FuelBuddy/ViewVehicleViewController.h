//
//  ViewVehicleViewController.h
//  FuelBuddy
//
//  Copyright (c) 2015 Oraganization. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GADMasterViewController.h"

@interface ViewVehicleViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,GADBannerViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableview;
@property (nonatomic,retain) NSMutableArray *vehiclearray;
@property (nonatomic,retain) NSString *urlstring;
@property (nonatomic,retain) NSMutableArray *checkedarray;

@end
