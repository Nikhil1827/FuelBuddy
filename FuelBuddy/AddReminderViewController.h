//
//  AddReminderViewController.h
//  FuelBuddy
//
//  Created by surabhi on 10/05/16.
//  Copyright © 2016 Oraganization. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddReminderViewController : UIViewController<UITextFieldDelegate,UIPickerViewDataSource,UIPickerViewDelegate>
{
    NSString *checkedstatus;
    long notificationtime;
}
@property (strong, nonatomic) IBOutlet UILabel *vehname;
@property (strong, nonatomic) IBOutlet UIImageView *vehimage;
@property (weak, nonatomic) IBOutlet UILabel *servicename;
@property (weak, nonatomic) IBOutlet UILabel *desc;

@property (weak, nonatomic) IBOutlet UIButton *odocheck;
@property (weak, nonatomic) IBOutlet UITextField *odotext;
@property (weak, nonatomic) IBOutlet UIButton *daysButton;
@property (weak, nonatomic) IBOutlet UITextField *daystext;
@property (weak, nonatomic) IBOutlet UIButton *comesfirstButton;
@property (nonatomic,retain) NSMutableArray *vehiclearray,*durationarray;
@property (weak, nonatomic) IBOutlet UIButton *noreminderButton;
@property(nonatomic,retain) NSString *namestring;
@property (nonatomic,retain)UIPickerView *picker;
@property (nonatomic,retain) UIButton *setbutton;
@property (weak, nonatomic) IBOutlet UILabel *distanceunitLabel;
@property (weak, nonatomic) IBOutlet UIButton *durationButton;
@property (weak, nonatomic) IBOutlet UIButton *durationDropDownButton;
@property (weak, nonatomic) IBOutlet UIButton *durationArrowButton;
@property (weak, nonatomic) IBOutlet UILabel *lastserviceLabel;
@property (weak, nonatomic) IBOutlet UITextField *lastodoText;
@property (weak, nonatomic) IBOutlet UILabel *lastodounitLabel;
@property (strong, nonatomic) IBOutlet UIView *separatorLine;
@property (weak, nonatomic) IBOutlet UITextField *dateText;
@property (nonatomic,retain) NSDictionary *servicedetails;
@property (weak, nonatomic) IBOutlet UIView *view1;
@property BOOL recurring;
- (IBAction)openDatePicker:(UIButton *)sender;

@end
