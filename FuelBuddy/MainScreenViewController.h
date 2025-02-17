//
//  MainScreenViewController.h
//  FuelBuddy
//
//  Created by Nikhil on 17/09/18.
//  Copyright © 2018 Oraganization. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GADMasterViewController.h"
@import Charts;

@interface MainScreenViewController : UIViewController <UIPickerViewDataSource,UIPickerViewDelegate,IChartAxisValueFormatter,GADInterstitialDelegate,UITableViewDelegate,UITableViewDataSource>
{
    
}
@property (strong, nonatomic) IBOutlet UILabel *vehNameLabel;
@property (strong, nonatomic) IBOutlet UIImageView *vehImageView;
@property (nonatomic,retain)UIPickerView *picker;
@property (nonatomic,retain)UIButton *setbutton;
@property (nonatomic,retain)NSMutableArray *vehiclearray;
@property (nonatomic,assign)CGSize result;
@property (nonatomic,retain) UITableView *logTableView;
@property (nonatomic,retain) NSMutableArray *detailsarray;
@property (nonatomic,retain) NSString *curr,*vol,*dist,*con;

- (IBAction)vehButton:(UIButton *)sender;
- (IBAction)vehDropButton:(UIButton *)sender;
- (NSString *)stringForValue:(double)value
                        axis:(ChartAxisBase *)axis;
-(void)fetchdata;
-(void)fetchAllValues;
-(void)addScrollView;
@end
