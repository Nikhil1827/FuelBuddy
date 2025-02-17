//
//  SyncHelpRootVC.m
//  FuelBuddy
//
//  Created by Swapnil on 11/11/17.
//  Copyright © 2017 Oraganization. All rights reserved.
//

#import "SyncHelpRootVC.h"
#import "SignInCloudViewController.h"
#import "LoggedInVC.h"
#import "GoProViewController.h"
@interface SyncHelpRootVC ()

@end

@implementation SyncHelpRootVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationController.navigationBar.barTintColor = [self colorFromHexString:@"#0098AB"];
    self.navigationController.navigationBar.tintColor =[UIColor whiteColor];
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.topItem.title= NSLocalizedString(@"sync_btn", @"Sign In To Cloud");
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor] , NSFontAttributeName: [UIFont fontWithName:@"Helvetica-Light" size:18.0] }];
    self.view.backgroundColor = [self colorFromHexString:@"#2c2c2c"];
    UIImage *buttonImage = [UIImage imageNamed:@"nav_back"];
    
    UIButton *Button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [Button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    
    Button.frame = CGRectMake(0.0, 0.0, buttonImage.size.width,buttonImage.size.height);
    
    UIBarButtonItem *BarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:Button];
    
    [Button addTarget:self action:@selector(backbuttonclick) forControlEvents:UIControlEventTouchUpInside];
    
    [self.navigationItem setLeftBarButtonItem:BarButtonItem];
    
    //Making sync free 30may2018 nikhil
   //BOOL proUser = [[NSUserDefaults standardUserDefaults] boolForKey:@"isAdDisabled"];
   
//    if(!proUser){
//
//        UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"ok", @"OK")
//                                                                           style:UIBarButtonItemStylePlain
//                                                                          target:self
//                                                                          action:@selector(goProAlertBox)];
//        [self.navigationItem setRightBarButtonItem:rightBarButton];
//    } else {
   
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"ok", @"OK")
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(goToSignInScreen)];
        [self.navigationItem setRightBarButtonItem:rightBarButton];
  // }
    
    
    
    NSString *pageTitle1 = NSLocalizedString(@"cloud_backup_header", @"Never lose your data again.");
    NSString *pageTitle2 = NSLocalizedString(@"desktop_access_header", @"Access your data on the desktop.");
    NSString *pageTitle3 = NSLocalizedString(@"device_sync_header", @"Sync across multiple devices.");
    NSString *pageTitle4 = NSLocalizedString(@"driver_share_header", @"Sync between multiple drivers.");
    
    NSString *pageSubtitle1 = NSLocalizedString(@"cloud_backup_msg", @"All your data is instantly backed up on the cloud.");
    NSString *pageSubtitle2 = NSLocalizedString(@"desktop_access_msg", @"Get access to all your data on www.simplyauto.app.");
    NSString *pageSubtitle3 = NSLocalizedString(@"device_sync_msg", @"Use multiple devices? No problem. Simply Auto keeps data on all your devices in sync.");
    NSString *pageSubtitle4 = @"Is your vehicle shared between multiple drivers? SimplyAuto lets you invite other drivers and sync your data with them.";
    
    //Sync Free changes
    NSString *pageProSubtilte1 = NSLocalizedString(@"receipt_pro_only", @"*Receipt images are not backed up in the free version");
    NSString *pageProSubtilte24 = NSLocalizedString(@"sync_sign_in_footnote", @"*Available in the pro version only");
    
    self.pageTitles = @[pageTitle1, pageTitle2, pageTitle3, pageTitle4];
    self.pageSubtitles = @[pageSubtitle1, pageSubtitle2, pageSubtitle3, pageSubtitle4];
    //Sync Free changes
    self.proSubtitles = @[pageProSubtilte1, pageProSubtilte24, @"",pageProSubtilte24];
    self.pageImages = @[@"SyncHelp1.png", @"SyncHelp2.png", @"SyncHelp3.png", @"splash_driver_share.png"];
    
    
    //Create page view controller
    self.pageVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SyncPageViewController"];
    self.pageVC.dataSource = self;
    
    SyncPageContentVC *startingVC = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingVC];
    [self.pageVC setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    
    // Change the size of page view controller
    self.pageVC.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 30);
    
    [self addChildViewController:self.pageVC];
    [self.view addSubview:self.pageVC.view];
    [self.pageVC didMoveToParentViewController:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dismissVC)
                                                 name:@"dismissHelpVC"
                                               object:nil];
    
}


- (void)dismissVC{
    
    
    
    [self dismissViewControllerAnimated:NO completion:^{
        
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:@"dismissHelpVC"
                                                      object:nil];
    }];
}

- (void)goToSignInScreen{
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setObject:@"1" forKey:@"SyncHelpScreensShown"];
    
    
    NSString *userEmail = [def objectForKey:@"UserEmail"];
    
    SignInCloudViewController *signIn = (SignInCloudViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"cloudSignIn"];
    
    LoggedInVC *loggedIn = (LoggedInVC *)[self.storyboard instantiateViewControllerWithIdentifier:@"loggedInScreen"];
    
    if (userEmail != nil && userEmail.length > 0) {

        loggedIn.modalPresentationStyle = UIModalPresentationFullScreen;
        [self.navigationController presentViewController:loggedIn animated:YES completion:nil];
        
    } else {

        signIn.modalPresentationStyle = UIModalPresentationFullScreen;
        [self.navigationController presentViewController:signIn animated:YES completion:nil];
    }
//    if(userEmail != nil && userEmail.length > 0){
//        
//        
//    } else {
//        
//        
//    }
}

- (void)goProAlertBox{
    
    NSString *title = @"This feature is available in Pro";
    NSString *message = @"";
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:title
                                          message:message
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"cancel", @"Cancel action")
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       
                                   }];
    
    //NSString *go_pro_btn = @"Go Pro";
    UIAlertAction *goproAction = [UIAlertAction
                                  actionWithTitle:NSLocalizedString(@"go_pro_btn", @"Ok action")
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction *action)
                                  {
                                      GoProViewController *gopro = (GoProViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"gopro"];
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          gopro.modalPresentationStyle = UIModalPresentationFullScreen;
                                          [self presentViewController:gopro animated:YES completion:nil];
                                      });
                                  }];
    
    
    [alertController addAction:goproAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
    
}

-(void)viewWillAppear:(BOOL)animated{
    
    NSString *pageTitle1 = NSLocalizedString(@"cloud_backup_header", @"Never lose your data again.");
    NSString *pageTitle2 = NSLocalizedString(@"desktop_access_header", @"Access your data on the desktop.");
    NSString *pageTitle3 = NSLocalizedString(@"device_sync_header", @"Sync across multiple devices.");
    NSString *pageTitle4 = @"Sync between multiple drivers.";
    
    NSString *pageSubtitle1 = NSLocalizedString(@"cloud_backup_msg", @"All your data is instantly backed up on the cloud.");
    NSString *pageSubtitle2 = NSLocalizedString(@"desktop_access_msg", @"Get access to all your data on simplyauto.app.");
    NSString *pageSubtitle3 = NSLocalizedString(@"device_sync_msg", @"Use multiple devices? No problem. Simply Auto keeps data on all your devices in sync.");
    NSString *pageSubtitle4 = @"Is your vehicle shared between multiple drivers? SimplyAuto lets you invite other drivers and sync your data with them.";
    
    //Sync Free changes
    NSString *pageProSubtilte1 = NSLocalizedString(@"receipt_pro_only", @"*Receipt images are not backed up in the free version");
    //sync_sign_in_footnote
    NSString *pageProSubtilte24 = NSLocalizedString(@"sync_sign_in_footnote", @"*Available in the pro version only");
    
    self.pageTitles = @[pageTitle1, pageTitle2, pageTitle3, pageTitle4];
    self.pageSubtitles = @[pageSubtitle1, pageSubtitle2, pageSubtitle3, pageSubtitle4];
    //Sync Free changes
    self.proSubtitles = @[pageProSubtilte1, pageProSubtilte24, @"", pageProSubtilte24];
    self.pageImages = @[@"SyncHelp1.png", @"SyncHelp2.png", @"SyncHelp3.png", @"splash_driver_share.png"];
    
    
    //Create page view controller
    self.pageVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SyncPageViewController"];
    self.pageVC.dataSource = self;
    
    SyncPageContentVC *startingVC = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingVC];
    [self.pageVC setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    
    // Change the size of page view controller
    self.pageVC.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 30);
    
    [self addChildViewController:self.pageVC];
    [self.view addSubview:self.pageVC.view];
    [self.pageVC didMoveToParentViewController:self];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)shouldAutorotate {
    return NO;
}

-(void)backbuttonclick
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(UIColor *)colorFromHexString:(NSString *)hexString
{
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}


#pragma mark Page View Controller Data Source

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController{
    
    NSUInteger index = ((SyncPageContentVC *) viewController).pageIndex;
    
    if(index == 0 || index == NSNotFound){
        
        return nil;
    }
    index--;
    return [self viewControllerAtIndex: index];
}


-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController{
    
    NSUInteger index = ((SyncPageContentVC *) viewController).pageIndex;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == [self.pageTitles count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

- (SyncPageContentVC *)viewControllerAtIndex:(NSUInteger)index
{
    if (([self.pageTitles count] == 0) || (index >= [self.pageTitles count])) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    SyncPageContentVC *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SyncPageContentVC"];
    pageContentViewController.imageFile = self.pageImages[index];
    pageContentViewController.titleText = self.pageTitles[index];
    pageContentViewController.subtitleText = self.pageSubtitles[index];
    pageContentViewController.proSubtitleText = self.proSubtitles[index];
    pageContentViewController.pageIndex = index;
    
    return pageContentViewController;
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return [self.pageTitles count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}


@end
