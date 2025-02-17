//
//  PageContentViewController.h
//  FuelBuddy
//
//  Created by Swapnil on 06/03/17.
//  Copyright © 2017 Oraganization. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PageContentViewController : UIViewController

@property NSString *labelText;
@property NSString *labelText2;

@property NSUInteger pageIndex;
@property NSString *imageText;

@property (weak, nonatomic) IBOutlet UILabel *screenLabel;
@property (weak, nonatomic) IBOutlet UILabel *screenLabel2;
@property (weak, nonatomic) IBOutlet UIImageView *imageLabel;

@end
