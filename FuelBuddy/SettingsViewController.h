//
//  SettingsViewController.h
//  FuelBuddy
//
//  Created by Surabhi on 07/12/15.
//  Copyright (c) 2015 Oraganization. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GADMasterViewController.h"
#import "AppDelegate.h"
#import "CustomDashViewController.h"


@interface SettingsViewController : UIViewController                                                 <UITableViewDataSource,UITableViewDelegate,UIDocumentInteractionControllerDelegate,GADBannerViewDelegate> 
@property (strong, nonatomic) IBOutlet UITableView *tableview;
@property (nonatomic,retain) NSMutableArray *titlearray;//*descarray,*titlesection2;
@property (nonatomic,retain) NSString *distance,*volume,*consump, *currency;
@property (nonatomic,assign) float convert;

- (NSString *)convertLocalizedStringToConstant: (NSString *)localizedString;
-(void) convertvalue;
-(void)updatedistance;
-(void)updateconsumption;
@end
