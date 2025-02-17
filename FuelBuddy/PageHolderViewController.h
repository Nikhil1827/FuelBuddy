//
//  PageHolderViewController.h
//  FuelBuddy
//
//  Created by Nikhil on 22/04/19.
//  Copyright © 2019 Oraganization. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PageHolderViewController : UIViewController <UIPageViewControllerDataSource>

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) NSArray *backImgArray;
@property (strong, nonatomic) NSArray *iconImgArray;
@property (strong, nonatomic) NSArray *labelArray;
@property (strong, nonatomic) NSArray *btnTitleArray;

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;

@end

