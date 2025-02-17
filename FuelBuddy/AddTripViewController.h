//
//  AddTripViewController.h
//  FuelBuddy
//
//  Created by Nupur on 07/09/16.
//  Copyright © 2016 Oraganization. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "DashPageContentViewController.h"

@interface AddTripViewController : UIViewController <UIPickerViewDataSource,UIPickerViewDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate,UIPickerViewDelegate, UITextViewDelegate, CLLocationManagerDelegate, UIPageViewControllerDataSource>
{
    
    UIView *navigationOverlay;
}
- (IBAction)settingsPressed:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *odoLabelHConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *odoFieldHConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *unitLabelHConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *odoUnderLineHCon;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *arrOdoLHConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *arrFHConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *arrOdoUHConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *arrUnitConstraint;

@property (nonatomic, strong) UIPageViewController *pageViewController;
@property (nonatomic, strong) NSArray *pageTitles;
@property (nonatomic, strong) NSArray *imagesArray;


- (IBAction)typeButtonPressed:(id)sender;

//- (IBAction)pickfilter:(id)sender;

- (IBAction)vehfilterClick:(id)sender;

@property (nonatomic,assign)CGSize result;
@property (strong, nonatomic) IBOutlet UIButton *vehicleButton;
@property (strong, nonatomic) IBOutlet UILabel *vehName;
@property (strong, nonatomic) IBOutlet UIImageView *vehImage;
@property (strong, nonatomic) IBOutlet UIView *lineview;

@property (nonatomic,retain) NSString *pickerval;
@property (nonatomic,retain)UIPickerView *picker;
@property (nonatomic,retain)NSMutableArray *vehiclearray,*tripTypeArray, *tripArray;
@property (nonatomic,retain)UIButton *setbutton;
@property (nonatomic,retain)NSString* tripState, *warning;



@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UITextField *depOdoField;
@property (weak, nonatomic) IBOutlet UILabel *depOdoLabel;

@property (weak, nonatomic) IBOutlet UITextField *depDateTimeField;
@property (retain, nonatomic) IBOutlet UIDatePicker *datePicker;
//@property(nonatomic,retain)UIAlertView *dateAlertView;

@property (strong, nonatomic) IBOutlet UILabel *distanceLabel;
@property (strong, nonatomic) IBOutlet UITextField *distanceField;


@property (weak, nonatomic) IBOutlet UITextField *depLocnField;

@property (weak, nonatomic) IBOutlet UILabel *depLocnLabel;
@property (retain, nonatomic) IBOutlet UITextField *currentField;


@property (weak, nonatomic) IBOutlet UITextField *arrDateTimeFld;

@property (weak, nonatomic) IBOutlet UILabel *arrOdoLabel;

@property (weak, nonatomic) IBOutlet UITextField *arrOdoField;

@property (weak, nonatomic) IBOutlet UITextField *arrLocnField;

@property (weak, nonatomic) IBOutlet UILabel *arrLocnLabel;


@property (weak, nonatomic) IBOutlet UITextField *tollField;
@property (strong, nonatomic) IBOutlet UILabel *timeValueLabel;

@property (strong, nonatomic) IBOutlet UILabel *timetraveledLabel;

@property (weak, nonatomic) IBOutlet UITextField *parkingField;

@property (weak, nonatomic) IBOutlet UILabel *taxValueLabel;

@property (weak, nonatomic) IBOutlet UILabel *taxRateLabel;

@property (weak, nonatomic) IBOutlet UILabel *tollLabel;
@property (weak, nonatomic) IBOutlet UILabel *parkingLabel;

@property (weak, nonatomic) IBOutlet UITextField *taxPercField;


@property (weak, nonatomic) IBOutlet UILabel *usdLabel;

@property (weak, nonatomic) IBOutlet UILabel *usdLabel2;

@property (weak, nonatomic) IBOutlet UILabel *miLabel1;

@property (weak, nonatomic) IBOutlet UILabel *miLabel2;

@property (weak, nonatomic) IBOutlet UILabel *miLabel3;

@property (weak, nonatomic) IBOutlet UILabel *usdLabel3;

@property (weak, nonatomic) IBOutlet UILabel *usdpermiLabel;

@property (weak, nonatomic) IBOutlet UITextView *notesView;


@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (nonatomic,strong) NSMutableDictionary *editTripDict;


@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIView *contentView;

- (IBAction)savePressed:(id)sender;

- (IBAction)gpsButtonChecked:(id)sender;

//Swapnil NEW_5
//- (IBAction)gpsButtonChecked:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *gpsButton;
@property (strong, nonatomic) IBOutlet UILabel *trackTripLabel;

@property (weak, nonatomic) IBOutlet UIView *gpsView;

@end
