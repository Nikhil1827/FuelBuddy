//
//  EmailLogViewController.h
//  FuelBuddy
//
//  Created by Swapnil on 16/03/17.
//  Copyright © 2017 Oraganization. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface EmailLogViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UIPickerViewDelegate, MFMailComposeViewControllerDelegate>

- (IBAction)backButtonPressed:(id)sender;
- (IBAction)showEmail:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,retain) NSMutableArray *fillUparray;
@property (nonatomic,retain) NSMutableDictionary *emailDataFillup;

@property (nonatomic,retain) NSMutableArray *csvCell;

@property (nonatomic,retain) NSMutableArray *tripArray, *sortedTripsArr, *sortedFillsArr, *sortedServiceArr, *sortedExpenseArr, *distByTypeArr, *taxDednByTypeArr, *tripTypeArray, *tripTypeDictArray;


@property (weak, nonatomic) IBOutlet UIImageView *vehImage;
- (IBAction)vehButton:(id)sender;
- (IBAction)vehFilterClick:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *dateRangeView;
@property (weak, nonatomic) IBOutlet UITextField *endDate;
@property (weak, nonatomic) IBOutlet UITextField *startDate;

@property (nonatomic,retain) UIPickerView *picker;
@property (nonatomic,retain)NSMutableArray *vehiclearray;
@property (nonatomic,retain) NSString *pickerval;
@property (nonatomic,retain)UIButton *setbutton;

@property (retain, nonatomic) IBOutlet UIDatePicker *datePicker;

@property (nonatomic,retain) NSMutableArray *fieldTitlesarray;

@property NSInteger selectedRow;

-(void)donelabel;
@property (weak, nonatomic) IBOutlet UILabel *vehName;

@property NSString *vehicleFetched, *fillupFilePath, *serviceFilePath, *expenseFilePath, *tripFilePath;

@end
