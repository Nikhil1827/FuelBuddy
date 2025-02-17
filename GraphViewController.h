//
//  GraphViewController.h
//  FuelBuddy
//
//  Created by surabhi on 25/01/16.
//  Copyright © 2016 Oraganization. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GADMasterViewController.h"

@interface GraphViewController : UIViewController <GADBannerViewDelegate>
@property (nonatomic,retain) NSMutableArray *xaxis;
@property (nonatomic,retain) NSMutableArray *yaxis;
@property (nonatomic,retain) NSString *titlestring;
@property (weak, nonatomic) IBOutlet UILabel *xaxislabel;
@property (weak, nonatomic) IBOutlet UILabel *yaxislabel;
@property (nonatomic,retain) NSString *yaxisstring;
@property (nonatomic) BOOL isPresented;
@end
