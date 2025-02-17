//
//  FeedBackView.h
//  FuelBuddy
//
//  Created by Nikhil on 08/07/19.
//  Copyright © 2019 Oraganization. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeedBackView : UIView

@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) IBOutlet UILabel *wouldYouLabel;
@property (strong, nonatomic) IBOutlet UIView *ratingView;
@property (strong, nonatomic) IBOutlet UIView *imageBGView;
@property (strong, nonatomic) IBOutlet UIImageView *serviceIconImageView;
@property (strong, nonatomic) IBOutlet UILabel *centerNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *centerAddressLabel;
@property (strong, nonatomic) IBOutlet UIButton *rating1OLT;
@property (strong, nonatomic) IBOutlet UIButton *rating2OLT;
@property (strong, nonatomic) IBOutlet UIButton *rating3OLT;
@property (strong, nonatomic) IBOutlet UIButton *rating4OLT;
@property (strong, nonatomic) IBOutlet UIButton *rating5OLT;
@property (strong, nonatomic) IBOutlet UILabel *cmntsLabel;
@property (strong, nonatomic) IBOutlet UITextView *cmntsTextView;
@property (strong, nonatomic) IBOutlet UIButton *submitOLT;
@property (strong, nonatomic) IBOutlet UILabel *ThisRatingLabel;
@property (strong, nonatomic) NSMutableDictionary *feedBackDataDict;

- (IBAction)closeTapped:(id)sender;
- (IBAction)rating1Tapped:(id)sender;
- (IBAction)rating2Tapped:(id)sender;
- (IBAction)rating3Tapped:(id)sender;
- (IBAction)rating4Tapped:(id)sender;
- (IBAction)rating5Tapped:(id)sender;
- (IBAction)submitTapped:(id)sender;
@end

