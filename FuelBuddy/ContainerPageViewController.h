//
//  ContainerPageViewController.h
//  FuelBuddy
//
//  Created by Nikhil on 23/04/19.
//  Copyright © 2019 Oraganization. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContainerPageViewController : UIPageViewController<UIPageViewControllerDataSource>

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) NSArray *imgArray;
@property (strong, nonatomic) NSArray *label1Array;

@end

