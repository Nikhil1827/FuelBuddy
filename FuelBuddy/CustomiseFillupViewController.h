//
//  CustomiseFillupViewController.h
//  FuelBuddy
//
//  Created by Surabhi on 20/11/15.
//  Copyright (c) 2015 Oraganization. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GADMasterViewController.h"

@interface CustomiseFillupViewController : UIViewController <UITableViewDelegate,UITableViewDataSource,GADBannerViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableview;
@property (nonatomic,retain) NSMutableArray *arrayaddedtext,*textplace;
@end
