//
//  BarGraphViewController.m
//  FuelBuddy
//
//  Created by surabhi on 02/02/16.
//  Copyright © 2016 Oraganization. All rights reserved.
//

#import "BarGraphViewController.h"
#import "EColumnChart.h"
#import "EFloatBox.h"
#import "AppDelegate.h"

@interface BarGraphViewController ()
@property (nonatomic, strong) NSMutableArray *data;
@property (nonatomic, strong) EFloatBox *eFloatBox;

@property (nonatomic, strong) EColumn *eColumnSelected;
@property (nonatomic, strong) UIColor *tempColor;

@end



@implementation BarGraphViewController

@synthesize tempColor = _tempColor;
@synthesize eFloatBox = _eFloatBox;
@synthesize eColumnChart = _eColumnChart;
@synthesize data = _data;
@synthesize eColumnSelected = _eColumnSelected;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeLeft];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    [self.tabBarController.tabBar setHidden:YES];
    AppDelegate *App = [AppDelegate sharedAppDelegate];
    App.tabbutton.hidden=YES;
    self.rightbutton.hidden=true;
    [self.rightbutton addTarget:self action:@selector(rightclick) forControlEvents:UIControlEventTouchUpInside];
      [self.leftbutton addTarget:self action:@selector(leftclick) forControlEvents:UIControlEventTouchUpInside];
    self.view.backgroundColor = [self colorFromHexString:@"#2c2c2c"];
   
    //CGRect orig = self.yaxislabel.frame;
    
    self.yaxislabel.transform=CGAffineTransformMakeRotation((- M_PI)/2);
    self.yaxislabel.frame =  CGRectMake(10, 100, 14, 160);
    self.yaxislabel.textColor = [UIColor whiteColor];
    self.xaxislabel.textColor = [UIColor whiteColor];
    
    UIImage *buttonImage = [UIImage imageNamed:@"nav_back"];
    
    UIButton *Button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [Button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    
    Button.frame = CGRectMake(0.0, 0.0, buttonImage.size.width,buttonImage.size.height);
    
    UIBarButtonItem *BarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:Button];
    
    [Button addTarget:self action:@selector(backbuttonclick) forControlEvents:UIControlEventTouchUpInside];
    
    [self.navigationItem setLeftBarButtonItem:BarButtonItem];
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:GregorianCalendar];
    NSDateComponents *components1 = [gregorian components:NSCalendarUnitYear fromDate:[NSDate date]];
    originalyearstart=(int)components1.year;
    NSDateFormatter *formatter=[[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy"];
    startyear=[[formatter stringFromDate:[NSDate date]]intValue];
     originalyearstart=[[formatter stringFromDate:[NSDate date]]intValue];
    
    if ([_barChartType intValue] == 3)
    {
        
        self.xaxislabel.text = NSLocalizedString(@"edit_trip_type_hint", @"Trip Type");
        self.yaxislabel.text = NSLocalizedString(@"dist_tv", @"Distance");
        self.leftbutton.hidden = YES;
        self.rightbutton.hidden = YES;
        [self drawgraph:_dataArray values:_values];
    }
    else if ([_barChartType intValue] == 4)
    {
        
        self.xaxislabel.text = NSLocalizedString(@"edit_trip_type_hint", @"Trip Type");
        self.yaxislabel.text = @"Tax Deduction";
        self.leftbutton.hidden = YES;
        self.rightbutton.hidden = YES;
        [self drawgraph:_dataArray values:_values];
    }
    
    //Swapnil ENH_19
    else if ([_barChartType intValue] == 5){
        
        self.xaxislabel.text = NSLocalizedString(@"octane", @"Octane");
        self.yaxislabel.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"con_unit"];
        self.leftbutton.hidden = YES;
        self.rightbutton.hidden = YES;
        [self drawgraph:_dataArray values:_values];
    }
    
    //Swapnil ENH_19
    else if ([_barChartType intValue] == 6){
        
        self.xaxislabel.text = NSLocalizedString(@"fb_tv", @"Fuel Brand");
        self.yaxislabel.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"con_unit"];
        self.leftbutton.hidden = YES;
        self.rightbutton.hidden = YES;
        [self drawgraph:_dataArray values:_values];
    }
    
    //Swapnil ENH_19
    else if ([_barChartType intValue] == 7){
        
        self.xaxislabel.text = NSLocalizedString(@"fs_tv", @"Filling Station");
        self.yaxislabel.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"con_unit"];
        self.leftbutton.hidden = YES;
        self.rightbutton.hidden = YES;
        [self drawgraph:_dataArray values:_values];
    }
    else
    {
        [self addgraph:[NSString stringWithFormat:@"%d", startyear  ]];
    }
}


-(void)addgraph : (NSString *) yearstring
{
    _monthlist=[[NSMutableArray alloc] initWithObjects:@"Jan",@"Feb",@"Mar",@"Apr",@"May",@"Jun",@"Jul",@"Aug",@"Sep",@"Oct",@"Nov",@"Dec",nil];
    
    _values = [[NSMutableArray alloc]initWithObjects:@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0", nil];
    NSDateFormatter *formater=[[NSDateFormatter alloc] init];
    [formater setDateFormat:@"MMM"];
    NSDateFormatter *formater1=[[NSDateFormatter alloc] init];
    [formater1 setDateFormat:@"yyyy"];
    NSMutableArray *addmonth =[[NSMutableArray alloc]init];
    NSMutableArray *costSum =[[NSMutableArray alloc]init];

   
        // NSLog(@"month array %@",addmonth);
    
    
   // _barChartType = @1;
    
    //FillUps per month
    if ([_barChartType intValue] == 1)
    {
        
        //NSLog(@"self.dataArray %@", self.dataArray);
        for(NSDictionary *data in self.dataArray)
        {
            if([[data objectForKey:@"year"] isEqualToString:yearstring])
            {
                [addmonth addObject:[data objectForKey:@"month"]];
                //[costSum addObject:[data objectForKey:@"TotalCost"]];
            }
        }
        

        
    for(int j =0;j <addmonth.count;j ++)
    {
        int i = 0;
        NSString *obj = [addmonth objectAtIndex:j];
        if ([obj isEqualToString:@"Jan"])
        {
            i=0;
            [self calculate:i];
        }
        
        if ([obj isEqualToString:@"Feb"])
        {
            i=1;
            [self calculate:i];
        }
        if ([obj isEqualToString:@"Mar"])
        {
            i=2;
            [self calculate:i];
        }
        if ([obj isEqualToString:@"Apr"])
        {
            i=3;
            [self calculate:i];
        }
        if ([obj isEqualToString:@"May"])
        {
            i=4;
            [self calculate:i];
        }
        if ([obj isEqualToString:@"Jun"])
        {
            i=5;
            [self calculate:i];
        }
        if ([obj isEqualToString:@"Jul"])
        {
            i=6;
            [self calculate:i];
        }
        if ([obj isEqualToString:@"Aug"])
        {
            i=7;
            [self calculate:i];
        }
        if ([obj isEqualToString:@"Sep"])
        {
            i=8;
            [self calculate:i];
        }
        if ([obj isEqualToString:@"Oct"])
        {
            i=9;
            [self calculate:i];
        }
        if ([obj isEqualToString:@"Nov"])
        {
            i=10;
            [self calculate:i];
        }
        if ([obj isEqualToString:@"Dec"])
        {
            i=11;
            [self calculate:i];
        }
        
    }
    
    
    }
    //Fuel Cost / MOnth
    else if ([_barChartType intValue] == 2)
    {
        
        for(NSDictionary *data in self.dataArray)
        {
            if([[data objectForKey:@"Year"] isEqualToString:yearstring])
            {
                //for(int j =0;j <_monthlist.count;j ++)
                //{
                //    NSString* mon = [_monthlist objectAtIndex:j ];
                    
                //    if ([mon isEqualToString:[data objectForKey:@"Month"]])
                //    {
                    
                NSDateFormatter* formatter = [[NSDateFormatter alloc] init] ;
                [formatter setDateFormat:@"MMM"];
                NSDate *aDate = [formatter dateFromString:[data objectForKey:@"Month"]];
                NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitMonth fromDate:aDate];
               // NSLog(@"Month: %i", [components month]); /* => 7 */
                
                [_values replaceObjectAtIndex:[components month]-1 withObject:[data objectForKey:@"TotalCost"]];
            }
        }
        
     
    }
    
    
    
    NSArray *compareval =  [[NSArray alloc]initWithObjects:@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0", nil];
    //NSLog(@"value array %@",_values);
    if(![compareval isEqualToArray:_values])
    {
         self.xaxislabel.text = [NSString stringWithFormat:@"Year %@",yearstring];
    [self drawgraph:_monthlist values:_values];
    }
    else
    {
        self.xaxislabel.text = [NSString stringWithFormat:@"Year %@",yearstring];
        [self drawgraph:_monthlist values:_values];

        [self showAlert:[NSString stringWithFormat:@"No data for %@",yearstring] message:@""];
        
//        if([self.swipestring isEqualToString:@"left"])
//        {
//            startyear++;
//        }
//        else if([self.swipestring isEqualToString:@"right"])
//        {
//            startyear--;
//        }
//        
//        NSLog(@"year value %@",yearstring);
//        NSLog(@"start year %d",startyear);
       
    }
    
}



- (void)showAlert:(NSString *)title message:(NSString *)message {
    
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:title
                                          message:message
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"ok", @"OK action")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   
                               }];
    
    
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
    
}

-(void)calculate: (int)value
{
    int val = [[_values objectAtIndex:value] intValue];
    val = val + 1;
      [_values replaceObjectAtIndex:value withObject:[NSString stringWithFormat:@"%d",val]];
}

-(void)backbuttonclick
{
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)drawgraph:(NSMutableArray *)keys values:(NSMutableArray *)values
{
    
    
    [_eColumnChart removeFromSuperview];
    NSMutableArray *temp = [NSMutableArray array];
    for (int i = 0; i <keys.count; i++)
    {
        EColumnDataModel *eColumnDataModel = [[EColumnDataModel alloc] initWithLabel:[keys objectAtIndex:i] value:[[values objectAtIndex:i] intValue] index:i unit:@""];
        
        [temp addObject:eColumnDataModel];
    }
    
    _data = [[NSMutableArray alloc]initWithArray:temp];
   
    
    if([UIScreen mainScreen].bounds.size.height > 320)
    {
        _eColumnChart = [[EColumnChart alloc] initWithFrame:CGRectMake(60, [UIScreen mainScreen].bounds.size.height/2-125, [UIScreen mainScreen].bounds.size.width-100, [UIScreen mainScreen].bounds.size.height-120)];
    }
    else
    {
        _eColumnChart = [[EColumnChart alloc] initWithFrame:CGRectMake(60, [UIScreen mainScreen].bounds.size.height/2-100, [UIScreen mainScreen].bounds.size.width-100, [UIScreen mainScreen].bounds.size.height-100)];
    }


    [_eColumnChart setColumnsIndexStartFromLeft:YES];
    [_eColumnChart setDelegate:self];
    [_eColumnChart setDataSource:self];

  
    //Activate only for type 1 or 2 (Fill ups per month, fuel cost per month)
    if (!([self.barChartType intValue] < 3)) {
        [self stegestures];
        [_eColumnChart addGestureRecognizer:_leftswipe];
        [_eColumnChart addGestureRecognizer:_rightswipe];
        
    }
    
    [self.view addSubview:_eColumnChart];
   
}


-(void)stegestures
{
    _leftswipe=[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(statechange:)];
    [_leftswipe setDirection:UISwipeGestureRecognizerDirectionLeft];
    [_leftswipe setNumberOfTouchesRequired:1];
    _leftswipe.delegate=self;
    
    _rightswipe=[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(statechange:)];
    [_rightswipe setDirection:UISwipeGestureRecognizerDirectionRight];
    [_rightswipe setNumberOfTouchesRequired:1];
    _rightswipe.delegate=self;
}

-(void)statechange:(UISwipeGestureRecognizer *)ges
{
    if (ges==_rightswipe)
    {
        NSDateFormatter *formater1=[[NSDateFormatter alloc] init];
        [formater1 setDateFormat:@"yyyy"];
        
        if(startyear==originalyearstart-1)
        {
            self.swipestring=@"right";
            self.rightbutton.hidden=true;
            self.swipestring=@"right";
            startyear++;
            [self addgraph:[NSString stringWithFormat:@"%d",startyear]];
        }
        
        else if(startyear<originalyearstart)
        {
            self.swipestring=@"right";
            startyear++;
            self.rightbutton.hidden=false;
            [self addgraph:[NSString stringWithFormat:@"%d",startyear]];
            
        }
        
        else
        {
            self.swipestring=@"right";
            self.rightbutton.hidden=true;
        }
    }
    else
    {
        self.swipestring=@"left";
        self.rightbutton.hidden=false;
        startyear--;
        [self addgraph:[NSString stringWithFormat:@"%d",startyear]];
        
    }
}


-(void)rightclick
{
    NSDateFormatter *formater1=[[NSDateFormatter alloc] init];
            [formater1 setDateFormat:@"yyyy"];
   
    if(startyear==originalyearstart-1)
    {
        self.swipestring=@"right";
        self.rightbutton.hidden=true;
        self.swipestring=@"right";
        startyear++;
        [self addgraph:[NSString stringWithFormat:@"%d",startyear]];
    }
    
   else if(startyear<originalyearstart)
    {
        self.swipestring=@"right";
        startyear++;
        self.rightbutton.hidden=false;
        [self addgraph:[NSString stringWithFormat:@"%d",startyear]];
        
    }
   
    else
    {
        self.swipestring=@"right";
        self.rightbutton.hidden=true;
    }

}

-(void)leftclick
{
    
    self.swipestring=@"left";
    self.rightbutton.hidden=false;
    startyear--;
     [self addgraph:[NSString stringWithFormat:@"%d",startyear]];
    
}

- (NSInteger) numberOfColumnsInEColumnChart:(EColumnChart *) eColumnChart
{
    return _data.count;
}
- (NSInteger) numberOfColumnsPresentedEveryTime:(EColumnChart *) eColumnChart
{

    return _data.count;
}

- (EColumnDataModel *)highestValueEColumnChart:(EColumnChart *) eColumnChart
{
    EColumnDataModel *maxDataModel = nil;
    float maxValue = -FLT_MIN;
    for (EColumnDataModel *dataModel in _data)
    {
        if (dataModel.value > maxValue)
        {
            maxValue = dataModel.value;
            maxDataModel = dataModel;
        }
    }
    return maxDataModel;
}

-(EColumnDataModel *)eColumnChart:(EColumnChart *)eColumnChart valueForIndex:(NSInteger)index
{
    if (index >= [_data count] || index < 0) return nil;
    return [_data objectAtIndex:index];
}


- (UIColor *)colorForEColumn:(EColumn *)eColumn
{
    return [self colorFromHexString:@"#ECB40B"];
}

-(UIColor *)colorFromHexString:(NSString *)hexString
{
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

- (void)eColumnChart:(EColumnChart *)eColumnChart
fingerDidEnterColumn:(EColumn *)eColumn
{
    
}


-(void)eColumnChart:(EColumnChart *)eColumnChart fingerDidLeaveColumn:(EColumn *)eColumn
{
    
}

- (void)fingerDidLeaveEColumnChart:(EColumnChart *)eColumnChart
{
    if (_eFloatBox)
    {
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionTransitionNone animations:^{
            _eFloatBox.alpha = 0.0;
            _eFloatBox.frame = CGRectMake(_eFloatBox.frame.origin.x, _eFloatBox.frame.origin.y + _eFloatBox.frame.size.height, _eFloatBox.frame.size.width, _eFloatBox.frame.size.height);
        } completion:^(BOOL finished)
         {
             [_eFloatBox removeFromSuperview];
             _eFloatBox = nil;
         }];
    }
}
-(void)eColumnChart:(EColumnChart *)eColumnChart didSelectColumn:(EColumn *)eColumn
{
    
}

-(void)adddaylabel
{
    UIView *chartback;
    UIView *yxies;
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"screen"]intValue]==40)
    {
        
        chartback=[[UIView alloc] initWithFrame:CGRectMake(7,121,310,359)];
        yxies=[[UIView alloc] initWithFrame:CGRectMake(40,133,2,318)];
    }
    else
    {
        chartback=[[UIView alloc] initWithFrame:CGRectMake(7,121,310,272)];
        yxies=[[UIView alloc] initWithFrame:CGRectMake(40,133,2,250)];
    }
    
    chartback.backgroundColor=[self colorFromHexString:@"#ffffff"];
    chartback.layer.cornerRadius=5;
    [self.view addSubview:chartback];
    
    
    yxies.backgroundColor=[self colorFromHexString:@"#747272"];
    [self.view addSubview:yxies];
    
  
    [self addmonthslabel];
    
}

-(void)addmonthslabel
{
    
    UIView *monthsview;
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"screen"]intValue]==40)
    {
        monthsview=[[UIView alloc] initWithFrame:CGRectMake(34,455,280,15)];
    }
    else
    {
        monthsview=[[UIView alloc] initWithFrame:CGRectMake(34,380,280,15)];
    }
    int x=10;
    
    NSArray * arrayofmonth=[[NSArray alloc] initWithObjects:@"January",@"February",@"March",@"April",@"May",@"June",@"July",@"August",@"September",@"October",@"November",@"December",nil];
    
    for (NSString *mon in arrayofmonth)
    {
        UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(x,0,17,15)];
        label.font=[UIFont fontWithName:@"oswald-regular" size:9.0f];
        label.text=[[mon substringToIndex:3]uppercaseString];
        label.textColor=[UIColor grayColor];
        label.textAlignment=NSTextAlignmentCenter;
        x+=23.4;
        [monthsview addSubview:label];
    }
    
    [self.view insertSubview:monthsview atIndex:10];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
