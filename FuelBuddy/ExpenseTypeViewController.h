//
//  ExpenseTypeViewController.h
//  FuelBuddy
//
//  Created by Surabhi on 21/12/15.
//  Copyright (c) 2015 Oraganization. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GADMasterViewController.h"

@interface ExpenseTypeViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,GADBannerViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableview;
@property (nonatomic,retain) NSMutableArray *expensearray,*checkedarray,*lastexpense;
@property (nonatomic,retain) NSString *updateexpense;
@end
