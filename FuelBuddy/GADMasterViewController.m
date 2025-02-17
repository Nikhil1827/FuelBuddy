//
//  GADMasterViewController.m
//  FuelBuddy
//
//  Created by surabhi on 04/03/16.
//  Copyright © 2016 Oraganization. All rights reserved.
//

#import "GADMasterViewController.h"
#import "AppDelegate.h"

@interface GADMasterViewController ()

@end

@implementation GADMasterViewController
@synthesize adBanner_ = adBanner_;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(id)init {
    if (self = [super init]) {
        AppDelegate *app = [AppDelegate sharedAppDelegate];
             adBanner_ = [[GADBannerView alloc]
                     initWithFrame:CGRectMake(0.0,
                                              app.result.height-100,
                                              app.result.width,
                                              GAD_SIZE_320x50.height)];
           
        isLoaded_ = NO;
    }
    return self;
}

+(GADMasterViewController *)singleton {
    static dispatch_once_t pred;
    static GADMasterViewController *shared;

    dispatch_once(&pred, ^{
        shared = [[GADMasterViewController alloc] init];
    });
    return shared;
}


-(void)resetAdView:(UIViewController *)rootViewController {
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    currentDelegate_ = window.rootViewController;
    currentDelegate_ = [self.navigationController visibleViewController];

//    if( app.tabbutton.hidden == NO)
//    {
//        adBanner_ = [[GADBannerView alloc]
//                     initWithFrame:CGRectMake(0.0,
//                                              app.result.height-100,
//                                              app.result.width,
//                                              GAD_SIZE_320x50.height)];
//    }
//    
//    if( app.tabbutton.hidden == YES || [app.tabbutton superview]==nil)
//    {
//        adBanner_.frame = CGRectMake(0.0,app.result.height-100,
//                                              app.result.width,
//                                              GAD_SIZE_320x50.height);
//    }
//    
//    else
//    {
//        adBanner_.frame = CGRectMake(0.0,app.result.height-100,
//                                     app.result.width,
//                                     GAD_SIZE_320x50.height);
//    }


    if (isLoaded_) {
        [rootViewController.view addSubview:adBanner_];
    } else {
        
        adBanner_.delegate = self;
        adBanner_.rootViewController = rootViewController;
        adBanner_.adUnitID = @"ca-app-pub-6674448976750697/2571217565";
        
        GADRequest *request = [GADRequest request];
        //request.testDevices = @[@"43b8417876e13af00ee1e8f9ef0101ce",kGADSimulatorID];
        [adBanner_ loadRequest:request];
        [rootViewController.view addSubview:adBanner_];
        isLoaded_ = YES;
    }
}

- (void)adViewDidReceiveAd:(GADBannerView *)view {
    
    [currentDelegate_ adViewDidReceiveAd:view];

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
