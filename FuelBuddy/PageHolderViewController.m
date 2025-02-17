//
//  PageHolderViewController.m
//  FuelBuddy
//
//  Created by Nikhil on 22/04/19.
//  Copyright © 2019 Oraganization. All rights reserved.
//

#import "PageHolderViewController.h"
#import "OnboardViewController.h"

@interface PageHolderViewController ()

@end

@implementation PageHolderViewController

- (void)viewDidLoad {
    [super viewDidLoad];

//    _backImgArray = [[NSArray alloc] initWithObjects:@"onboarding_expenses.png",@"onboarding_servicing.png",@"onboarding_trip.png",@"onboarding_cloud.png", nil];
//    _iconImgArray = [[NSArray alloc] initWithObjects:@"expenses_center.png",@"servicing_center.png",@"trip_center.png",@"cloud_center.png", nil];
//
//    NSString *expenseString = NSLocalizedString(@"onboarding_expenses", @"Keep your vehicle's expenses in check by tracking fuel consumption and other expenses.");
//    NSString *serviceString = NSLocalizedString(@"onboarding_servicing", @"Improve your vehicle's life with timely services and maintenance.");
//    NSString *tripString = NSLocalizedString(@"onboarding_trip", @"Log your trips to keep track of your tax deductions.");
//    NSString *cloudString =NSLocalizedString(@"onboarding_cloud", @"Sign into cloud for instant backups, sharing of data with other drivers and syncing data across devices.");
//
//    NSString *skip = NSLocalizedString(@"skip", @"SKIP");
//    NSString *getstarted = NSLocalizedString(@"lets_get_stared", @"LET'S GET STARTED");
//
//    _labelArray = [[NSArray alloc] initWithObjects:expenseString,serviceString,tripString,cloudString, nil];
//    _btnTitleArray = [[NSArray alloc] initWithObjects:skip,skip,skip,getstarted, nil];
//
//    // Create page view controller
//    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"OnBoardPageViewController"];
//    self.pageViewController.dataSource = self;
//
//    CGRect rect = [self.view bounds];
//    rect.size.height+=37;
//    [[self.pageViewController view] setFrame:rect];
//    NSArray *subviews = self.pageViewController.view.subviews;
//
//    UIPageControl *thisControl = nil;
//    for (int i=0; i<[subviews count]; i++) {
//        if ([[subviews objectAtIndex:i] isKindOfClass:[UIPageControl class]]) {
//            thisControl = (UIPageControl *)[subviews objectAtIndex:i];
//        }
//    }
//
//    OnboardViewController *startingViewController = (OnboardViewController *)[self viewControllerAtIndex:0];
//    NSArray *viewControllers = @[startingViewController];
//
//    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
//
//
//    [self addChildViewController:_pageViewController];
//    [self.view addSubview:_pageViewController.view];
//    [self.pageViewController didMoveToParentViewController:self];
//
//    UIView *tempview = [[UIView alloc] initWithFrame:CGRectMake(0, -140, 320, 40)];
//    [tempview addSubview:thisControl];
//    thisControl.pageIndicatorTintColor = [UIColor lightGrayColor];
//    thisControl.currentPageIndicatorTintColor = [UIColor whiteColor];
//    [self.view addSubview:tempview];

}

-(void)viewWillAppear:(BOOL)animated{

    BOOL signInDone = [[NSUserDefaults standardUserDefaults]boolForKey:@"signInDone"];
    
    if(signInDone){

        [self dismissViewControllerAnimated:NO completion:nil];
    }else{

        _backImgArray = [[NSArray alloc] initWithObjects:@"onboarding_expenses.png",@"onboarding_servicing.png",@"onboarding_trip.png",@"onboarding_cloud.png", nil];
        _iconImgArray = [[NSArray alloc] initWithObjects:@"expenses_center.png",@"servicing_center.png",@"trip_center.png",@"cloud_center.png", nil];

        NSString *expenseString = NSLocalizedString(@"onboarding_expenses", @"Keep your vehicle's expenses in check by tracking fuel consumption and other expenses.");
        NSString *serviceString = NSLocalizedString(@"onboarding_servicing", @"Improve your vehicle's life with timely services and maintenance.");
        NSString *tripString = NSLocalizedString(@"onboarding_trip", @"Log your trips to keep track of your tax deductions.");
        NSString *cloudString =NSLocalizedString(@"onboarding_cloud", @"Sign into cloud for instant backups, sharing of data with other drivers and syncing data across devices.");

        NSString *skip = NSLocalizedString(@"skip", @"SKIP");
        NSString *getstarted = NSLocalizedString(@"lets_get_stared", @"LET'S GET STARTED");

        _labelArray = [[NSArray alloc] initWithObjects:expenseString,serviceString,tripString,cloudString, nil];
        _btnTitleArray = [[NSArray alloc] initWithObjects:skip,skip,skip,getstarted, nil];

        // Create page view controller
        self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"OnBoardPageViewController"];
        self.pageViewController.dataSource = self;

        CGRect rect = [self.view bounds];
        rect.size.height+=37;
        [[self.pageViewController view] setFrame:rect];
        NSArray *subviews = self.pageViewController.view.subviews;

        UIPageControl *thisControl = nil;
        for (int i=0; i<[subviews count]; i++) {
            if ([[subviews objectAtIndex:i] isKindOfClass:[UIPageControl class]]) {
                thisControl = (UIPageControl *)[subviews objectAtIndex:i];
            }
        }

        OnboardViewController *startingViewController = (OnboardViewController *)[self viewControllerAtIndex:0];
        NSArray *viewControllers = @[startingViewController];

        [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];


        [self addChildViewController:_pageViewController];
        [self.view addSubview:_pageViewController.view];
        [self.pageViewController didMoveToParentViewController:self];

        UIView *tempview = [[UIView alloc] initWithFrame:CGRectMake(0, -140, 320, 40)];
        [tempview addSubview:thisControl];
        thisControl.pageIndicatorTintColor = [UIColor lightGrayColor];
        thisControl.currentPageIndicatorTintColor = [UIColor whiteColor];
        [self.view addSubview:tempview];


    }
}

-(BOOL)shouldAutorotate{

    return NO;
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    
}


-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController{

    NSUInteger index =((OnboardViewController *)viewController).valueIndex;

    if(index == 0 || index == NSNotFound){

        return nil;
    }

    index--;
    return [self viewControllerAtIndex:index];
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController{

    NSUInteger index =((OnboardViewController *)viewController).valueIndex;

    if(index == NSNotFound){

        return nil;
    }

    index++;

    if (index == _backImgArray.count){

        return nil;
    }

    return [self viewControllerAtIndex:index];

}

//Helper Methods
-(UIViewController *)viewControllerAtIndex:(NSUInteger)index{

    OnboardViewController *onBoardVC = [self.storyboard instantiateViewControllerWithIdentifier:@"onBoardVC"];

    onBoardVC.backImageString = _backImgArray[index];
    onBoardVC.iconImageString = _iconImgArray[index];
    onBoardVC.labelString = _labelArray[index];
    onBoardVC.buttonString = _btnTitleArray[index];
    onBoardVC.valueIndex = index;

    return onBoardVC;
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return [self.backImgArray count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}

@end
