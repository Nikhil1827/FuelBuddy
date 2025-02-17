//
//  AddDriverViewController.h
//  FuelBuddy
//
//  Created by Nikhil on 18/04/18.
//  Copyright © 2018 Oraganization. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddDriverViewController : UIViewController <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *searchEmailField;
@property (strong, nonatomic) IBOutlet UILabel *driverNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *driverEmailLabel;

@property (strong, nonatomic) IBOutlet UIView *viewUnderline;
@property (strong, nonatomic) IBOutlet UILabel *requestedLabel;
- (IBAction)requestButtonClicked:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *buttonImage;
@property NSMutableDictionary *friendDictionary;
@property (nonatomic,retain) NSMutableArray *friendsArray;
@end
