//
//  DashBoardViewController.h
//  FuelBuddy
//
//  Created by Surabhi on 16/11/15.
//  Copyright (c) 2015 Oraganization. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DashPageContentViewController.h"
#import "GADMasterViewController.h"
@interface DashBoardViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,UIPickerViewDataSource,UIPickerViewDelegate,GADBannerViewDelegate, UIPageViewControllerDataSource>
{
    //Swapnil 7 Mar-17
    UIView *navigationOverlay;
    UIView *tabbarOverlay;

}
- (IBAction)vehfilterClick:(id)sender;


@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (nonatomic,retain) NSMutableArray *section1,*section2,*section3,*section4,*section5;
@property (nonatomic,retain) NSMutableArray *totalstat, *avgfuelstat,*avgservstat,*avgexpstat, *totTripStats, *tripTypeArray,*distByTypeArr , *dednByTypeArr;
@property (strong, nonatomic) IBOutlet UIButton *vehiclebutton;
@property (strong, nonatomic) IBOutlet UILabel *vehname;
@property (strong, nonatomic) IBOutlet UIImageView *vehimage;
@property (strong, nonatomic) IBOutlet UIView *lineview;
@property (nonatomic,retain) NSString *pickerval;
@property(nonatomic,retain)UIDatePicker *pic;
@property (nonatomic,retain)UIPickerView *picker;
@property (nonatomic,retain)NSMutableArray *vehiclearray,*pickerdata;
@property (weak, nonatomic) IBOutlet UIImageView *dropdown;
@property (nonatomic,retain)UIButton *setbutton;
@property (weak, nonatomic) IBOutlet UILabel *dateRangeLabel;

- (IBAction)dropdownclick:(id)sender;
- (IBAction)pickfilter:(id)sender;
@property (nonatomic,retain) UITextField *startdate,*enddate;
@property (weak, nonatomic) IBOutlet UIButton *selectpicker;
@property (nonatomic,retain)NSMutableArray *filluparray,*servicearray,*expensearray;
@property (nonatomic,retain)NSMutableArray *octArray, *octEffArray, *octaneEff;
@property (nonatomic,retain)NSMutableArray *fbGraphArr, *fbEffGraphArr, *fbEffArray;
@property (nonatomic,retain)NSMutableArray *fsGraphArr, *fsEffGraphArr, *fsEffArray;


@property (nonatomic,assign) CGFloat heightvalue;

//-(void)fetchAvgDist :(NSString *) filterstring;

//Swapnil 6 Mar-17

@property (nonatomic, strong) UIPageViewController *pageViewController;

@property (nonatomic, strong) NSArray *pageTitles;
@property (nonatomic, strong) NSArray *imagesArray;


- (DashPageContentViewController *)viewControllerAtIndex: (NSUInteger)index;
-(void)fetchvalue :(NSString *) filterstring;

//BUG 156
@property (nonatomic,retain) NSManagedObjectContext *context;


@end
