//
//  ReportViewController.h
//  FuelBuddy
//
//  Created by Nikhil on 08/08/18.
//  Copyright © 2018 Oraganization. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReportViewController : UIViewController <UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic,retain)UIPickerView *picker;
@property (nonatomic,retain)UIButton *setbutton;
@property (nonatomic,retain)NSMutableArray *timePickerArray;
@property (nonatomic,retain) UITextField *startdate,*enddate;
@property (nonatomic,retain) NSManagedObjectContext *context;
@property (nonatomic,retain) NSString *pickerval;
@property (nonatomic,retain)NSMutableArray *vehiclearray;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UILabel *emailThisLabel;
@property (strong, nonatomic) IBOutlet UITextField *emailTextField;
@property (strong, nonatomic) IBOutlet UILabel *includeDataLabel;
@property (strong, nonatomic) IBOutlet UIButton *timeSelectLabel;
@property (strong, nonatomic) IBOutlet UILabel *fromLabel;
@property (strong, nonatomic) IBOutlet UILabel *toLabel;
@property (strong, nonatomic) IBOutlet UITextField *fromTextField;
@property (strong, nonatomic) IBOutlet UITextField *toTextField;
@property (strong, nonatomic) IBOutlet UILabel *includeRawLabel;
@property (strong, nonatomic) IBOutlet UILabel *fileTypeLabel;
@property (strong, nonatomic) IBOutlet UILabel *includeReceiptLabel;
@property (strong, nonatomic) IBOutlet UIButton *generateReportLabel;
@property (strong, nonatomic) IBOutlet UIButton *automatedLabel;
@property (strong, nonatomic) IBOutlet UIButton *includeRawOutlet;
@property (strong, nonatomic) IBOutlet UIButton *includeReceiptOutlet;
@property (strong, nonatomic) IBOutlet UIButton *pdfOutlet;
@property (strong, nonatomic) IBOutlet UIButton *csvOutlet;
@property (strong, nonatomic) IBOutlet UILabel *pdfLabel;
@property (strong, nonatomic) IBOutlet UILabel *csvLabel;
@property (strong, nonatomic) IBOutlet UIImageView *vehicleImage;

@property (strong, nonatomic) IBOutlet UILabel *vehicleName;


- (IBAction)vehicleDropDownClick:(UIButton *)sender;

- (IBAction)vehicleClick:(UIButton *)sender;

- (IBAction)timeSelectButton:(UIButton *)sender;
- (IBAction)timeDropDownButton:(UIButton *)sender;
- (IBAction)includeRawButton:(UIButton *)sender;
- (IBAction)PDFButton:(UIButton *)sender;
- (IBAction)CSVButton:(UIButton *)sender;
- (IBAction)includeReceiptButton:(UIButton *)sender;
- (IBAction)generateReportButton:(UIButton *)sender;
- (IBAction)automatedButton:(UIButton *)sender;
- (IBAction)automatedDropButton:(UIButton *)sender;
-(void)callEmailBody;
-(void)fetchvalue :(NSString *) filterstring;
-(void)fetchTripStats:(NSString*) filterString;
-(void)fetchVehiclesData;
@end
