//
//  SlideOutVC.h
//  FuelBuddy
//
//  Created by Swapnil on 13/11/17.
//  Copyright © 2017 Oraganization. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SlideOutVC : UIViewController <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *slideOutTable;
@property (nonatomic,retain)UIView *loadingView;

- (void)deregisterPopup;
@property (nonatomic,retain) UITapGestureRecognizer *dismissTap;
- (void)startActivitySpinner: (NSString *)labelText;

@end
