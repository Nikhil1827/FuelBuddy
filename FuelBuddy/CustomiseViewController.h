//
//  CustomiseViewController.h
//  FuelBuddy
//
//  Created by Surabhi on 23/11/15.
//  Copyright (c) 2015 Oraganization. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GADMasterViewController.h"
#import "AppDelegate.h"

@interface CustomiseViewController : UIViewController <GADBannerViewDelegate>
@property (nonatomic,retain)NSMutableArray *addvalues;
@property (nonatomic,assign)CGSize result;
@end
