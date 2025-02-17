//
//  GADMasterViewController.h
//  FuelBuddy
//
//  Created by surabhi on 04/03/16.
//  Copyright © 2016 Oraganization. All rights reserved.
//

#import <UIKit/UIKit.h>
@import GoogleMobileAds;
#import "GADMasterViewController.h"
#import <AdSupport/AdSupport.h>

@interface GADMasterViewController : UIViewController <GADBannerViewDelegate>
{
//GADBannerView *adBanner_;
BOOL didCloseWebsiteView_;
BOOL isLoaded_;
id currentDelegate_;
}
@property (nonatomic,retain) GADBannerView *adBanner_;
+(GADMasterViewController *)singleton;
-(void)resetAdView:(UIViewController *)rootViewController;
@end
