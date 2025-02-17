//
//  VehicleaddViewController.h
//  FuelBuddy
//  Copyright (c) 2015 Oraganization. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GADMasterViewController.h"

@interface VehicleaddViewController : UIViewController <UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,GADBannerViewDelegate, UITextViewDelegate , UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *contentView;


@property (strong, nonatomic) IBOutlet UITableView *fuelTypeTableView;

@property (weak, nonatomic) IBOutlet UITextView *notesView;
@property (weak, nonatomic) IBOutlet UITextField *insurance;
@property (strong, nonatomic) IBOutlet UIButton *addPhotoLabel;

@property (strong, nonatomic) IBOutlet UITextField *make;
@property (strong, nonatomic) IBOutlet UITextField *model;
@property (strong, nonatomic) IBOutlet UITextField *licence;
@property (strong, nonatomic) IBOutlet UITextField *vin;
@property (strong, nonatomic) IBOutlet UITextField *year;
@property (strong, nonatomic) IBOutlet UITextField *fuelType;

@property (strong, nonatomic) IBOutlet UIImageView *imageview;
@property (nonatomic,retain) NSData *imagedata;
@property (nonatomic,retain) NSString *imagepath;
@property (nonatomic,retain) NSString *ID;
@property (strong, nonatomic) IBOutlet UIView *topview;
@property (nonatomic,retain) NSString *makestring,*modelstring,*yearstring,*vinstring,*lincestring,*imagestring, *noteString, *insuranceString, *customSpecsString,*fuelTypeString;
@property (nonatomic,retain) NSMutableArray *custArr;
@property (strong, nonatomic) IBOutlet UILabel *yearlab;
@property (weak, nonatomic) IBOutlet UIButton *clickimage;
@property (weak, nonatomic) IBOutlet UIButton *addphotobutton;

@property (strong, nonatomic) IBOutlet UIImageView *defaultimage;

@property (weak, nonatomic) IBOutlet UIImageView *topimage;

@property (strong, nonatomic) IBOutlet UIButton *editbutton;

@property (strong, nonatomic) IBOutlet UILabel *namelab;
@property (strong, nonatomic) IBOutlet UILabel *modellab;
@property (strong, nonatomic) IBOutlet UILabel *vinlab;
@property (strong, nonatomic) IBOutlet UILabel *fuelTypeLabel;

@property (strong, nonatomic) IBOutlet UILabel *licencelab;
@property (weak, nonatomic) IBOutlet UILabel *insuranceLab;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollview;
- (IBAction)fuelTypeClicked:(UIButton *)sender;

- (IBAction)addSpecsButton:(id)sender;
- (void)setType: (NSString *)type andRowID: (NSNumber *)rowID andTableName: (NSString *)tableName;
- (void)writeToSyncTableWithRowID: (NSNumber *)rowID tableName: (NSString *)tableName andType: (NSString *)type;
@end
