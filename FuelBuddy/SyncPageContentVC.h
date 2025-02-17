//
//  SyncPageContentVC.h
//  FuelBuddy
//
//  Created by Swapnil on 11/11/17.
//  Copyright © 2017 Oraganization. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SyncPageContentVC : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *proSubtitleLabel;

@property NSUInteger pageIndex;
@property NSString *titleText;
@property NSString *subtitleText;
@property NSString *proSubtitleText;
@property NSString *imageFile;


@end
