//
//  ContainerPageViewController.m
//  FuelBuddy
//
//  Created by Nikhil on 23/04/19.
//  Copyright © 2019 Oraganization. All rights reserved.
//

#import "ContainerPageViewController.h"
#import "SignInFeaturesViewController.h"

@interface ContainerPageViewController ()

@end

@implementation ContainerPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _imgArray = [[NSArray alloc] initWithObjects:@"020-lock.png",@"web1.png",@"data-transfer.png",@"driver_sync1.png", nil];
    NSString *pageSubtitle1 = NSLocalizedString(@"cloud_backup_msg", @"All your data is instantly backed up on the cloud.");
    NSString *pageSubtitle2 = NSLocalizedString(@"desktop_access_msg", @"Get access to all your data on www.simplyauto.app.");
    NSString *pageSubtitle3 = NSLocalizedString(@"device_sync_msg", @"Use multiple devices? No problem. Simply Auto keeps data on all your devices in sync.");
    NSString *pageSubtitle4 = @"Is your vehicle shared between multiple drivers? SimplyAuto lets you invite other drivers and sync your data with them.";
    _label1Array = [[NSArray alloc] initWithObjects:pageSubtitle1,pageSubtitle2,pageSubtitle3,pageSubtitle4, nil];

    // Create page view controller
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SignFeaturesPageViewController"];
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

    SignInFeaturesViewController *startingViewController = (SignInFeaturesViewController *)[self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];

    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];


    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];

    UIView *tempview = [[UIView alloc] initWithFrame:CGRectMake(0, -40, 320, 40)];
    [tempview addSubview:thisControl];
    thisControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    thisControl.currentPageIndicatorTintColor = [UIColor whiteColor];
    [self.view addSubview:tempview];
}


//MARK: Page view methods
-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController{

    NSUInteger index =((SignInFeaturesViewController *)viewController).valueIndex;

    if(index == 0 || index == NSNotFound){

        return nil;
    }

    index--;
    return [self viewControllerAtIndex:index];
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController{

    NSUInteger index =((SignInFeaturesViewController *)viewController).valueIndex;

    if(index == NSNotFound){

        return nil;
    }

    index++;

    if (index == _imgArray.count){

        return nil;
    }

    return [self viewControllerAtIndex:index];

}

//Helper Methods
-(UIViewController *)viewControllerAtIndex:(NSUInteger)index{

    SignInFeaturesViewController *signFVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SignInFeaturesViewController"];

    signFVC.backImageString = _imgArray[index];
    signFVC.labelString = _label1Array[index];
    signFVC.valueIndex = index;

    return signFVC;
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return [self.imgArray count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}



@end
