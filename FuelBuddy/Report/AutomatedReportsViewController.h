//
//  AutomatedReportsViewController.h
//  FuelBuddy
//
//  Created by Nikhil on 08/08/18.
//  Copyright © 2018 Oraganization. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AutomatedReportsViewController : UIViewController <UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic,retain)UIPickerView *picker;
@property (nonatomic,retain)UIButton *setbutton;
@property (nonatomic,retain)NSMutableArray *timePickerArray;
@property (nonatomic,retain)NSMutableArray *vehiclearray;
@property (nonatomic,retain) NSString *pickerval;

@property (strong, nonatomic) IBOutlet UILabel *emailLabel;
@property (strong, nonatomic) IBOutlet UITextField *emailTextField;
@property (strong, nonatomic) IBOutlet UILabel *scheduleLabel;
@property (strong, nonatomic) IBOutlet UIButton *scheduleButtonLabel;
@property (strong, nonatomic) IBOutlet UILabel *includeRawLabel;
@property (strong, nonatomic) IBOutlet UILabel *fileTypeLabel;
@property (strong, nonatomic) IBOutlet UILabel *includeReceiptsLabel;
@property (strong, nonatomic) IBOutlet UIButton *startScheduleLabel;
@property (strong, nonatomic) IBOutlet UIButton *includeRawOutlet;
@property (strong, nonatomic) IBOutlet UIButton *includeReceiptOutlet;
@property (strong, nonatomic) IBOutlet UIButton *pdfOutlet;
@property (strong, nonatomic) IBOutlet UIButton *csvOutlet;
@property (strong, nonatomic) IBOutlet UILabel *pdfLabel;
@property (strong, nonatomic) IBOutlet UILabel *csvLabel;
@property (strong, nonatomic) IBOutlet UIImageView *vehicleImage;
@property (strong, nonatomic) IBOutlet UILabel *vehicleName;


- (IBAction)vehicleClick:(UIButton *)sender;
- (IBAction)dropClick:(UIButton *)sender;

- (IBAction)scheduledButton:(UIButton *)sender;
- (IBAction)scheduleDropButton:(UIButton *)sender;
- (IBAction)includeRawButton:(UIButton *)sender;
- (IBAction)PDFButton:(UIButton *)sender;
- (IBAction)CSVButton:(UIButton *)sender;
- (IBAction)includeReceiptsButton:(UIButton *)sender;
- (IBAction)startScheduleButton:(UIButton *)sender;

@end
