//
//  FaqViewController.h
//  FuelBuddy
//
//  Created by Surabhi on 10/12/15.
//  Copyright (c) 2015 Oraganization. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GADMasterViewController.h"

@interface FaqViewController : UIViewController <UIWebViewDelegate,GADBannerViewDelegate>

@property (strong, nonatomic) IBOutlet UIWebView *webview;
@property (nonatomic,retain) NSString *urlstring;
@property (nonatomic,retain) NSString *navtitle;
@property (nonatomic,retain) UIView *loadingView;

@end
