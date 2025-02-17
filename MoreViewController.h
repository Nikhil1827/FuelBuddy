//
//  MoreViewController.h
//  FuelBuddy
//
//  Created by Surabhi on 16/11/15.
//  Copyright (c) 2015 Oraganization. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "GTLRDrive.h"
#import "GADMasterViewController.h"
@interface MoreViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,MFMailComposeViewControllerDelegate,GADBannerViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableview;
@property (nonatomic,retain) NSMutableArray *imagearray,*titlearray;
@property (nonatomic,retain) GTLRDrive_File * drivefile;
@end
