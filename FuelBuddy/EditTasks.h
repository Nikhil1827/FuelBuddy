//
//  EditTasks.h
//  FuelBuddy
//
//  Created by Nupur on 13/06/16.
//  Copyright © 2016 Oraganization. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditTasks : UIViewController <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UITextField *taskNameField;

@property (weak, nonatomic) IBOutlet UISwitch *forAllVehicleSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *recurringSwitch;

- (IBAction)deleteButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *forAllVehicleLabel;
@property (weak, nonatomic) IBOutlet UILabel *recurringTaskLabel;
@property (weak, nonatomic) IBOutlet UILabel *recurringLabel;

- (IBAction)cancelButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;

- (IBAction)updateButtonPressed:(id)sender;

@property (weak, nonatomic) IBOutlet UIView *bgView;

- (IBAction)forAllVehicleSwitchChanged:(id)sender;
- (IBAction)switchChanged:(id)sender;



@property (weak, nonatomic) IBOutlet UILabel *taskNameLabel;

// call back function, a block
@property (nonatomic, strong) void (^onDismiss)(UIViewController *sender, NSString* message);


@property (nonatomic,retain) NSString *operation;
@property (nonatomic,retain) NSString *taskType;
@property (nonatomic,retain) NSMutableArray *serviceArray;
@property (nonatomic,retain) NSMutableArray *expenseArray;
@property (nonatomic,retain) NSString *updServiceName;
@property (nonatomic,retain) NSMutableDictionary *serviceRec;


@end
