//
//  BarGraphViewController.h
//  FuelBuddy
//
//  Created by surabhi on 02/02/16.
//  Copyright © 2016 Oraganization. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EColumnChart.h"

@interface BarGraphViewController : UIViewController <EColumnChartDelegate,EColumnChartDataSource,UIGestureRecognizerDelegate>
{
        int startyear;
        int originalyearstart;
        int endyear;
}
#ifdef __IPHONE_8_0
#define GregorianCalendar NSCalendarIdentifierGregorian
#else
#define GregorianCalendar NSGregorianCalendar
#endif

@property (weak, nonatomic) IBOutlet UIButton *rightbutton;
@property (weak, nonatomic) IBOutlet UIButton *leftbutton;


@property (strong, nonatomic) EColumnChart *eColumnChart;
@property (retain, nonatomic)UISwipeGestureRecognizer *leftswipe;
@property (retain, nonatomic)UISwipeGestureRecognizer *rightswipe;
@property (nonatomic,retain) NSMutableArray *monthlist, *values;
@property (weak, nonatomic) IBOutlet UILabel *xaxislabel;
@property (weak, nonatomic) IBOutlet UILabel *yaxislabel;
@property (nonatomic,retain) NSMutableArray *dataArray;
@property (nonatomic,retain) NSNumber* barChartType;

@property (nonatomic,retain) NSString *stringtitle,*swipestring;
@end
