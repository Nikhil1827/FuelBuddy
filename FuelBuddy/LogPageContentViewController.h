//
//  LogPageContentViewController.h
//  FuelBuddy
//
//  Created by Swapnil on 07/03/17.
//  Copyright © 2017 Oraganization. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LogPageContentViewController : UIViewController

@property NSString *labelText;
@property NSUInteger pageIndex;
@property NSString *imageText;

@property (weak, nonatomic) IBOutlet UILabel *screenLabel;
@property (weak, nonatomic) IBOutlet UIImageView *screenImage;

@end
