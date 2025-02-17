//
//  ReminderViewController.h
//  FuelBuddy
//
//  Created by surabhi on 28/04/16.
//  Copyright © 2016 Oraganization. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReminderPageContentViewController.h"
@interface ReminderViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,UIPickerViewDataSource,UIPickerViewDelegate, UIPageViewControllerDataSource>
{
    float maxodo;
    
    //Swapnil 7 Mar-17
    UIView *navigationOverlay;
    UIView *tabbarOverlay;
}

@property (nonatomic,retain)NSMutableArray *dataArray;
@property(nonatomic,retain)NSArray *sortNames;
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;

@property (strong, nonatomic) IBOutlet UIButton *vehiclebutton;
@property (strong, nonatomic) IBOutlet UILabel *vehname;
@property (strong, nonatomic) IBOutlet UIImageView *vehimage;
@property (strong, nonatomic) IBOutlet UILabel *sortLabelName;
@property (nonatomic,retain) NSString *pickerval;
@property (nonatomic,retain)UIPickerView *picker,*sortPicker;
@property (nonatomic,retain) UIButton *setbutton;
@property (nonatomic,retain) NSMutableArray *vehiclearray;
@property (weak, nonatomic) IBOutlet UIButton *dropdownButton;

- (IBAction)addClick:(id)sender;
- (IBAction)sortType:(UIButton *)sender;
- (IBAction)sortTypeButton:(UIButton *)sender;

//Swapnil 7 Mar-17

@property (nonatomic, strong) UIPageViewController *pageViewController;

@property (nonatomic, strong) NSArray *pageTitles1;
@property (nonatomic, strong) NSArray *pageTitles2;
@property (nonatomic, strong) NSArray *imagesArray1;
@property (nonatomic, strong) NSArray *imagesArray2;


- (void)writeToSyncTableWithRowID: (NSNumber *)rowID tableName: (NSString *)tableName andType: (NSString *)type;

- (ReminderPageContentViewController *)viewControllerAtIndex: (NSUInteger)index;

@end
