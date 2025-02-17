//
//  Autorotate.h
//  FuelBuddy
//
//  Created by surabhi on 28/01/16.
//  Copyright © 2016 Oraganization. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PageContentViewController.h"

@interface Autorotate : UITabBarController <UIPageViewControllerDataSource>

//Swapnil 6 Mar-17

@property (nonatomic, strong) UIPageViewController *pageViewController;

@property (nonatomic, strong) NSArray *pageTitles;
@property (nonatomic, strong) NSArray *pageTitles2;

@property (nonatomic, strong) NSArray *imagesArray;


- (PageContentViewController *)viewControllerAtIndex: (NSUInteger)index;


@end
