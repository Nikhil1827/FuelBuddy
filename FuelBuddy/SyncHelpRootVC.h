//
//  SyncHelpRootVC.h
//  FuelBuddy
//
//  Created by Swapnil on 11/11/17.
//  Copyright © 2017 Oraganization. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SyncPageContentVC.h"

@interface SyncHelpRootVC : UIViewController <UIPageViewControllerDataSource>

@property (strong, nonatomic) UIPageViewController *pageVC;
@property (strong, nonatomic) NSArray *pageTitles;
@property (strong, nonatomic) NSArray *pageSubtitles;
@property (strong, nonatomic) NSArray *proSubtitles;
@property (strong, nonatomic) NSArray *pageImages;

@end
