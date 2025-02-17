//
//  CustomSubViewController.h
//  FuelBuddy
//
//  Created by surabhi on 05/02/16.
//  Copyright © 2016 Oraganization. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GADMasterViewController.h"
@interface CustomSubViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,GADBannerViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (nonatomic,retain) NSMutableArray *arrayaddedtext,*textplace;
@property (nonatomic,retain)NSString *titlestring;
@end
