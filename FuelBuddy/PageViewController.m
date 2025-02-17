//
//  PageViewController.m
//  FuelBuddy
//
//  Created by Nikhil on 19/04/19.
//  Copyright © 2019 Oraganization. All rights reserved.
//

#import "PageViewController.h"
#import "OnboardViewController.h"

@interface PageViewController ()
{

//    NSArray *backImgArray;
//    NSArray *iconImgArray;
//    NSArray *labelArray;
//    NSArray *btnTitleArray;
}

@end

@implementation PageViewController

- (void)viewDidLoad {
    [super viewDidLoad];

//    backImgArray = [[NSArray alloc] initWithObjects:@"onboarding_expenses.png",@"onboarding_servicing.png",@"onboarding_trip.png",@"onboarding_cloud.png", nil];
//    iconImgArray = [[NSArray alloc] initWithObjects:@"expenses_center.png",@"servicing_center.png",@"trip_center.png",@"cloud_center.png", nil];
//
//    NSString *expenseString = NSLocalizedString(@"onboarding_expenses", @"Keep your vehicle's expenses in check by tracking fuel consumption and other expenses.");
//    NSString *serviceString = NSLocalizedString(@"onboarding_servicing", @"Improve your vehicle's life with timely services and maintenance.");
//    NSString *tripString = NSLocalizedString(@"onboarding_trip", @"Log your trips to keep track of your tax deductions.");
//    NSString *cloudString =NSLocalizedString(@"onboarding_cloud", @"Sign into cloud for instant backups, sharing of data with other drivers and syncing data across devices.");
//
//    NSString *skip = NSLocalizedString(@"skip", @"SKIP");
//    NSString *getstarted = NSLocalizedString(@"lets_get_stared", @"LET'S GET STARTED");
//
//    labelArray = [[NSArray alloc] initWithObjects:expenseString,serviceString,tripString,cloudString, nil];
//    btnTitleArray = [[NSArray alloc] initWithObjects:skip,skip,skip,getstarted, nil];
//
//   // self.dataSource = self;
//
//    OnboardViewController *vc = (OnboardViewController *)[self viewControllerAtIndex:0];
//    NSArray *arr = [NSArray arrayWithObject:vc];
//    [self setViewControllers:arr direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
//
////    UIPageControl *pageControl = [UIPageControl appearance];
////    pageControl.pageIndicatorTintColor = UIColor.lightGrayColor;
////    pageControl.currentPageIndicatorTintColor = UIColor.whiteColor;

 
}

////Helper Methods
//-(UIViewController *)viewControllerAtIndex:(NSUInteger)index{
//
//    OnboardViewController *onBoardVC = [self.storyboard instantiateViewControllerWithIdentifier:@"onBoardVC"];
//
//    onBoardVC.backImageString = backImgArray[index];
//    onBoardVC.iconImageString = iconImgArray[index];
//    onBoardVC.labelString = labelArray[index];
//    onBoardVC.buttonString = btnTitleArray[index];
//    onBoardVC.valueIndex = index;
//
//    return onBoardVC;
//}
//
//-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController{
//
//    NSUInteger index =((OnboardViewController *)viewController).valueIndex;
//
//    if(index == 0 || index == NSNotFound){
//
//        return nil;
//    }
//
//    index--;
//    return [self viewControllerAtIndex:index];
//}
//
//-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController{
//
//    NSUInteger index =((OnboardViewController *)viewController).valueIndex;
//
//    if(index == NSNotFound){
//
//        return nil;
//    }
//
//    index++;
//
//    if (index == backImgArray.count){
//
//        return nil;
//    }
//
//    return [self viewControllerAtIndex:index];
//
//}
//
//-(NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
//{
//
//    return [backImgArray count];
//}
//
//- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
//{
//    return 0;
//}


@end
