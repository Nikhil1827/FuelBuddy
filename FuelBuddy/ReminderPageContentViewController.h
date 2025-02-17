//
//  ReminderPageContentViewController.h
//  FuelBuddy
//
//  Created by Swapnil on 07/03/17.
//  Copyright © 2017 Oraganization. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReminderPageContentViewController : UIViewController

@property NSString *labelText1;
@property NSString *labelText2;
@property NSString *imageText1;
@property NSString *imageText2;


@property NSUInteger pageIndex;


@property (weak, nonatomic) IBOutlet UILabel *screenLabel1;
@property (weak, nonatomic) IBOutlet UILabel *screenLabel2;
@property (weak, nonatomic) IBOutlet UIImageView *screenImage1;
@property (weak, nonatomic) IBOutlet UIImageView *screenImage2;



@end
