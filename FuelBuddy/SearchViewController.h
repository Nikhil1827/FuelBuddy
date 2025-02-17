//
//  SearchViewController.h
//  FuelBuddy
//
//  Created by surabhi on 01/03/16.
//  Copyright © 2016 Oraganization. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GADMasterViewController.h"

@interface SearchViewController : UIViewController <UIPickerViewDataSource,UIPickerViewDelegate,UITextFieldDelegate,GADBannerViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *selectveh;
@property (weak, nonatomic) IBOutlet UIButton *Datefilter;
@property (weak, nonatomic) IBOutlet UIButton *Pickdate;
@property (weak, nonatomic) IBOutlet UIButton *Odofilter;
@property (weak, nonatomic) IBOutlet UITextField *Odotext;
@property (weak, nonatomic) IBOutlet UITextField *Notetext;
@property (weak, nonatomic) IBOutlet UIButton *Recordtype;
@property (strong, nonatomic) IBOutlet UILabel *vehname;
@property (strong, nonatomic) IBOutlet UIImageView *vehimage;
@property (nonatomic,retain) NSString *pickerval;
@property(nonatomic,retain)UIDatePicker *pic;
@property (nonatomic,retain)UIPickerView *picker;
@property (nonatomic,retain) NSMutableArray *vehiclearray;
@property (nonatomic,retain) UIButton *setbutton;
@property (nonatomic,retain)NSMutableArray *filtervalue;

@property (weak, nonatomic) IBOutlet UILabel *DateLabel;
@property (weak, nonatomic) IBOutlet UILabel *recordlabel;


@property (weak, nonatomic) IBOutlet UIImageView *vehdropdown;
@property (weak, nonatomic) IBOutlet UIImageView *datedropdown;
@property (weak, nonatomic) IBOutlet UIImageView *ododropdown;
@property (weak, nonatomic) IBOutlet UIImageView *recorddropdown;



@end
