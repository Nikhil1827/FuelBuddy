//
//  DashBoardViewController.m
//  FuelBuddy
//
//  Created by Surabhi on 16/11/15.
//  Copyright (c) 2015 Oraganization. All rights reserved.
//

#import "DashBoardViewController.h"
#import "AppDelegate.h"
#import "SettingsViewController.h"
#import "Veh_Table.h"
#import "T_Fuelcons.h"
#import "T_Trip.h"
#import "GraphViewController.h"
#import "BarGraphViewController.h"
#import "CustomDashViewController.h"
#import <Crashlytics/Crashlytics.h>


@interface DashBoardViewController ()
{
    NSString* newStr1;
    NSString* newStr2, *maxBrand, *maxStation, *maxOctane;
    NSMutableArray *copynikArray;
    UIView *fuelPerDistBtnPickerView;
    UIView *fuelPerDayBtnPickerView;
    NSMutableArray *allTypeArray;
    
}
//NIKHIL BUG_131 //added property
@property int selPickerRow;

@end



//Swapnil 15 Mar-17
//static GADMasterViewController *shared;
@implementation DashBoardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //BUG_156
    self.context = [[CoreDataController sharedInstance] newManagedObjectContext];
    allTypeArray = [[NSMutableArray alloc]init];
    [self.tabBarController.tabBar setHidden:NO];
    AppDelegate* App = [AppDelegate sharedAppDelegate];
    App.tabbutton.hidden=NO;
    self.navigationController.navigationBar.barTintColor = [self colorFromHexString:@"#0098AB"];
    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"odovalue"];
    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"odofilter"];
    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"datevalue"];
    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"datefilter"];
    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"notefilter"];
    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"recordfilter"];
    self.navigationController.navigationBar.tintColor =[UIColor whiteColor];
    self.navigationController.navigationBar.topItem.title= NSLocalizedString(@"newTab2Title", @"Stats & Charts"); 
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor] , NSFontAttributeName: [UIFont fontWithName:@"Helvetica-Light" size:18.0] }];
    
    self.view.backgroundColor = [self colorFromHexString:@"#2c2c2c"];
    self.tableview.backgroundColor = [self colorFromHexString:@"#303030"];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(pickertap)];
    self.dropdown.userInteractionEnabled = YES;
    [self.dropdown addGestureRecognizer:tap];
    self.selectpicker.titleLabel.adjustsFontSizeToFitWidth = true;
    self.selectpicker.titleLabel.numberOfLines = 1;
    [self.selectpicker.titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
    self.selectpicker.titleLabel.lineBreakMode = NSLineBreakByClipping;
    self.tableview.delegate=self;
    self.tableview.dataSource=self;
    
    _vehimage.contentMode = UIViewContentModeScaleAspectFill;
    _vehimage.layer.borderWidth=0;
    _vehimage.layer.masksToBounds=YES;
    _vehimage.layer.cornerRadius = 21;
    
    
    self.vehname.text = [[NSUserDefaults standardUserDefaults]objectForKey:@"vehname"];
    if([[[NSUserDefaults standardUserDefaults]objectForKey:@"vehimage"]isEqualToString:@""])
    {
        // NSLog(@"blank....");
        _vehimage.image=[UIImage imageNamed:@"car4.jpg"];
    }
    
    else
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
        //Swapnil ENH_24
        NSString *urlstring = [paths firstObject];
        
        NSString *vehiclepic = [NSString stringWithFormat:@"%@/%@",urlstring,[[NSUserDefaults standardUserDefaults]objectForKey:@"vehimage"]];
        _vehimage.image =[UIImage imageWithContentsOfFile:vehiclepic];
    }
    
    [self.vehiclebutton addTarget:self action:@selector(openselectpicker) forControlEvents:UIControlEventTouchUpInside];
    
    // Do any additional setup after loading the view.
    self.pickerdata =[[NSMutableArray alloc]initWithObjects:
                      NSLocalizedString(@"graph_date_range_0", @"All Time"),
                      NSLocalizedString(@"graph_date_range_1", @"This Month"),
                      NSLocalizedString(@"graph_date_range_2", @"Last Month"),
                      NSLocalizedString(@"graph_date_range_3", @"This Year"),
                      NSLocalizedString(@"graph_date_range_4", @"Custom Dates") ,nil];
    
    UIImage *buttonImage = [UIImage imageNamed:@"nav_settings"];
    
    UIButton *Button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [Button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    
    Button.frame = CGRectMake(0.0, 10.0, buttonImage.size.width+4,buttonImage.size.height+4);
    
    UIBarButtonItem *BarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:Button];
    
    [Button addTarget:self action:@selector(backbuttonclick) forControlEvents:UIControlEventTouchUpInside];
    
    [self.navigationItem setRightBarButtonItem:BarButtonItem];
    self.heightvalue = App.result.height;
    
    [self createPageVC];
}


//Swapnil 6 Mar-17
- (void)createPageVC{
    
    if(![@"1" isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"dashLaunch"]]){
        
        [[NSUserDefaults standardUserDefaults] setValue:@"1" forKey:@"dashLaunch"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        navigationOverlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
        navigationOverlay.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.65];
        
        tabbarOverlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
        tabbarOverlay.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.65];
        
        [self.navigationController.view addSubview:navigationOverlay];
        [self.tabBarController.tabBar addSubview:tabbarOverlay];
        
        
        self.pageTitles = @[NSLocalizedString(@"customize_dashboard_screen_help", @"Customize this screen to add new statistics or remove redundant ones")];
        self.imagesArray = @[@"help_arrow.png"];
        //Create page view controller
        
        self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DashPageViewController"];
        self.pageViewController.dataSource = self;
        DashPageContentViewController *startingViewController = [self viewControllerAtIndex:0];
        NSArray *viewControllers = @[startingViewController];
        [self.pageViewController setViewControllers:viewControllers
                                          direction:UIPageViewControllerNavigationDirectionForward
                                           animated:YES
                                         completion:nil];
        
        //change size of page view controller
        self.pageViewController.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height + 48);
        [self addChildViewController:self.pageViewController];
        [self.view addSubview:self.pageViewController.view];
        [self.pageViewController didMoveToParentViewController:self];
        
        UITapGestureRecognizer *tapToDissmiss = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dissmissAction)];
        [self.pageViewController.view addGestureRecognizer:tapToDissmiss];
    }
    
}


#pragma mark - PAGEVIEWCONTROLLER Delegate methods

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController{
    
    NSUInteger index = ((DashPageContentViewController *) viewController).pageIndex;
    if ((index == 0) || (index == NSNotFound)){
        
        return nil;
    }
    index--;
    return [self viewControllerAtIndex:index];
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController{
    
    NSUInteger index = ((DashPageContentViewController*) viewController).pageIndex;
    
    if (index == NSNotFound){
        return nil;
    }
    
    index++;
    
    if (index == [self.pageTitles count]){
        
       // NSLog(@"%lu", [self.pageTitles count]);
        
        
        
        return nil;
    }
    
    
    return [self viewControllerAtIndex:index];
}

- (void)dissmissAction{
    
    [self.pageViewController.view removeFromSuperview];
    [self.pageViewController removeFromParentViewController];
    [navigationOverlay removeFromSuperview];
    [tabbarOverlay removeFromSuperview];
}

-(DashPageContentViewController *)viewControllerAtIndex:(NSUInteger)index{
    
    if (([self.pageTitles count] == 0) || (index >= [self.pageTitles count])) {
        
        
        return nil;
    }
    
    DashPageContentViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DashPageContentViewController"];
    pageContentViewController.labelText = self.pageTitles[index];
    pageContentViewController.imageText = self.imagesArray[index];
    pageContentViewController.pageIndex = index;
    return pageContentViewController;
    
}

-(NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController{
    
    return 0;
}

-(NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController{
    
    return 0;
}




-(void)backbuttonclick
{
    CustomDashViewController *cust = (CustomDashViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"custdash"];
    cust.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController pushViewController:cust animated:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
    
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    
}
-(void)viewDidAppear:(BOOL)animated
{
    
    [self fetchdata];
    
    self.vehname.text = [[NSUserDefaults standardUserDefaults]objectForKey:@"vehname"];
    if([[[NSUserDefaults standardUserDefaults]objectForKey:@"vehimage"]isEqualToString:@""])
    {
        // NSLog(@"blank....");
        _vehimage.image=[UIImage imageNamed:@"car4.jpg"];
    }
    
    else
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
        //Swapnil ENH_24
        NSString *urlstring = [paths firstObject];
        
        NSString *vehiclepic = [NSString stringWithFormat:@"%@/%@",urlstring,[[NSUserDefaults standardUserDefaults]objectForKey:@"vehimage"]];
        _vehimage.image =[UIImage imageWithContentsOfFile:vehiclepic];
    }
    
    [self setarray];
    //[self.section4 removeObject:@""];
    [self.tableview setContentOffset:CGPointZero animated:YES];
    // NSLog(@"table height %f",self.tableview.frame.size.height);
    //    if (self.tableview.contentSize.height > self.tableview.frame.size.height)
    //    {
    //        CGPoint offset = CGPointMake(0, self.tableview.contentSize.height -     self.tableview.frame.size.height);
    //        [self.tableview setContentOffset:offset animated:YES];
    //    }
    //[self.tableview setContentOffset:CGPointMake(0, CGFLOAT_MAX)];
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    [self.tabBarController.tabBar setHidden:NO];
    AppDelegate *App = [AppDelegate sharedAppDelegate];
    App.tabbutton.hidden=NO;
    
    // NSLog(@"self.selectpicker.titleLabel.text : %@", self.selectpicker.titleLabel.text);
    
    //[self fetchvalue : self.selectpicker.titleLabel.text];
    [self.selectpicker setTitle:NSLocalizedString(@"graph_date_range_0", @"All Time")  forState:UIControlStateNormal];
    
    [self fetchvalue : NSLocalizedString(@"graph_date_range_0", @"All Time")];
    
    App.result = [[UIScreen mainScreen] bounds].size;

    //Fuel chi butna
    fuelPerDistBtnPickerView = [[UIView alloc] initWithFrame:CGRectMake(self.tableview.frame.size.width - 180, 240, 150, 100)];
    fuelPerDistBtnPickerView.backgroundColor = [UIColor lightGrayColor];
    UIButton *runningBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, fuelPerDistBtnPickerView.frame.size.width, fuelPerDistBtnPickerView.frame.size.height/2-1)];
    runningBtn.backgroundColor = [UIColor lightGrayColor];
    [runningBtn setTitle:@"Running" forState:UIControlStateNormal];
    [runningBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [runningBtn addTarget:self action:@selector(showRunningFuelPerDistGraph)
         forControlEvents:UIControlEventTouchUpInside];
    UIButton *perMileBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, fuelPerDistBtnPickerView.frame.size.height/2+1, fuelPerDistBtnPickerView.frame.size.width, fuelPerDistBtnPickerView.frame.size.height/2-1)];
    perMileBtn.backgroundColor = [UIColor lightGrayColor];
    [perMileBtn setTitle:@"Per Mile" forState:UIControlStateNormal];
    [perMileBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [perMileBtn addTarget:self action:@selector(showPerMileFuelPerDistGraph) forControlEvents:UIControlEventTouchUpInside];
    [fuelPerDistBtnPickerView addSubview:runningBtn];
    [fuelPerDistBtnPickerView addSubview:perMileBtn];
    [self.navigationController.view addSubview:fuelPerDistBtnPickerView];
    [self.tableview bringSubviewToFront:fuelPerDistBtnPickerView];
    fuelPerDistBtnPickerView.hidden = true;

    fuelPerDayBtnPickerView = [[UIView alloc] initWithFrame:CGRectMake(self.tableview.frame.size.width - 180, 250, 150, 100)];
    fuelPerDayBtnPickerView.backgroundColor = [UIColor lightGrayColor];
    UIButton *runningBtn2 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, fuelPerDayBtnPickerView.frame.size.width, fuelPerDayBtnPickerView.frame.size.height/2-1)];
    runningBtn2.backgroundColor = [UIColor lightGrayColor];
    [runningBtn2 setTitle:@"Running" forState:UIControlStateNormal];
    [runningBtn2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [runningBtn2 addTarget:self action:@selector(showRunningFuelPerDayGraph)
         forControlEvents:UIControlEventTouchUpInside];
    UIButton *perMileBtn2 = [[UIButton alloc] initWithFrame:CGRectMake(0, fuelPerDayBtnPickerView.frame.size.height/2+1, fuelPerDayBtnPickerView.frame.size.width, fuelPerDayBtnPickerView.frame.size.height/2-1)];
    perMileBtn2.backgroundColor = [UIColor lightGrayColor];
    [perMileBtn2 setTitle:@"Per Mile" forState:UIControlStateNormal];
    [perMileBtn2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [perMileBtn2 addTarget:self action:@selector(showPerMileFuelPerDayGraph) forControlEvents:UIControlEventTouchUpInside];
    [fuelPerDayBtnPickerView addSubview:runningBtn2];
    [fuelPerDayBtnPickerView addSubview:perMileBtn2];
    [self.navigationController.view addSubview:fuelPerDayBtnPickerView];
    [self.tableview bringSubviewToFront:fuelPerDayBtnPickerView];
    fuelPerDayBtnPickerView.hidden = true;

    
    
    
}

-(void)setarray
{
    NSString *dist,*vol;
    if([[[NSUserDefaults standardUserDefaults]objectForKey:@"dist_unit"] isEqualToString:NSLocalizedString(@"disp_miles", @"Miles")])
    {
        dist = NSLocalizedString(@"mi", @"mi");
    }
    
    else
    {
        dist= NSLocalizedString(@"kms", @"km");
    }
    
    NSString *stringval1 =[NSString stringWithFormat:@"%@%@",NSLocalizedString(@"cost_tv", @"Fuel cost/"), dist];

    if([[[NSUserDefaults standardUserDefaults]objectForKey:@"vol_unit"] isEqualToString:NSLocalizedString(@"disp_kilowatt_hour", @"Kilowatt-Hour")]){

        vol = NSLocalizedString(@"kwh", @"kWh");

    }else if([[[NSUserDefaults standardUserDefaults]objectForKey:@"vol_unit"] isEqualToString:NSLocalizedString(@"disp_litre", @"Litre")])
    {
        vol = NSLocalizedString(@"ltr", @"Ltr");
        
    }
    
    else
    {
        vol = NSLocalizedString(@"gal", @"gal");
    }
    
    
    //NSLog(@"volume unit %@",vol);
    if([[NSUserDefaults standardUserDefaults]objectForKey:@"section0"]==nil)
    {
        self.section1 = [[NSMutableArray alloc]initWithObjects:
                         NSLocalizedString(@"dist_tv", @"Distance"),
                         NSLocalizedString(@"f_u_tv", @"Fill-ups"),
                         NSLocalizedString(@"f_q_tv", @"Fuel Qty"),
                         NSLocalizedString(@"f_c_tv", @"Fuel Cost"),
                         NSLocalizedString(@"tot_services", @"Services"),
                         NSLocalizedString(@"tot_service_cost", @"Service Cost"),
                         NSLocalizedString(@"tot_expense_cost", @"Other Expenses"),
                         NSLocalizedString(@"tc_tv", @"Total Cost"),nil];
        NSString *totalCostperMiString =[NSString stringWithFormat:@"%@/%@",NSLocalizedString(@"tc_tv", @"Total Cost"), dist];
        [self.section1 addObject:totalCostperMiString];
        //NSLog(@"%@",self.section1);
    }
    else
    {
        self.section1 =[[NSMutableArray alloc]initWithArray:[[[NSUserDefaults standardUserDefaults] objectForKey:@"section0"]mutableCopy]];
    }
    
    //[self.section1 removeObject:@""];
    NSArray *addedTextsArr = [[[NSUserDefaults standardUserDefaults] objectForKey:@"section1"]mutableCopy];
   
    NSString *stringval2 =[NSString stringWithFormat:@"%@%@", NSLocalizedString(@"avg_price_tv", @"Average Price/"),vol];
    NSString *effOctStr = [NSString stringWithFormat:@"%@ (%@)", NSLocalizedString(@"eff_oct_tv", @"Eff by Octane"), maxOctane];
    NSString *effBrndStr = [NSString stringWithFormat:@"%@ (%@)", NSLocalizedString(@"eff_brand_tv", @"Eff by Brand"), maxBrand] ;
    NSString *effStnStr =[NSString stringWithFormat:@"%@ (%@)", NSLocalizedString(@"eff_stn_tv", @"Eff by Stn"), maxStation];
    
    if([[NSUserDefaults standardUserDefaults]objectForKey:@"section1"]==nil || addedTextsArr.count < 9)
    {
        
        self.section2 = [[NSMutableArray alloc]initWithObjects:
                         NSLocalizedString(@"avg_fuel_tv", @"Average Fuel Efficiency"),
                         NSLocalizedString(@"dist_btn_fu_graph_name", @"Distance between Fill-ups"),
                         NSLocalizedString(@"qty_per_fu_tv", @"Qty per Fill-up"),
                         NSLocalizedString(@"cost_per_fu_tv", @"Cost per Fill-up"),
                         NSLocalizedString(@"fu_pm_tv", @"Fill-ups/month"),
                         NSLocalizedString(@"cpd_tv", @"Fuel Cost/day"),
                         NSLocalizedString(@"cpmth_tv", @"Fuel Cost/Mth"), nil];
         // NSLog(@"string value....... %@",stringval2);
        
            [self.section2 insertObject:stringval2 atIndex:4];
            [self.section2 insertObject:stringval1 atIndex:6];
            [self.section2 insertObject:effOctStr atIndex:9];
            [self.section2 insertObject:effBrndStr atIndex:10];
            [self.section2 insertObject:effStnStr atIndex:11];

    }
    else
    {

        self.section2 =[[NSMutableArray alloc]initWithArray:[[[NSUserDefaults standardUserDefaults] objectForKey:@"section1"]mutableCopy]];
        
        //NSLog(@"[def objectForKey:@addedTexts]: %@",[def objectForKey:@"addedTexts"]);
        //[self.section2 insertObject:stringval2 atIndex:4];
        
        if (![[self.section2 objectAtIndex:4] isEqualToString:@""]) {
            [self.section2 replaceObjectAtIndex:4 withObject:stringval2];
        }
        if (![[self.section2 objectAtIndex:6] isEqualToString:@""]) {
            [self.section2 replaceObjectAtIndex:6 withObject:stringval1];
        }
        if (![[self.section2 objectAtIndex:9] isEqualToString:@""]) {
            [self.section2 replaceObjectAtIndex:9 withObject:effOctStr];
        }
        if (![[self.section2 objectAtIndex:10] isEqualToString:@""]) {
            [self.section2 replaceObjectAtIndex:10 withObject:effBrndStr];
        }
        if (![[self.section2 objectAtIndex:11] isEqualToString:@""]) {
            [self.section2 replaceObjectAtIndex:11 withObject:effStnStr];
            
        }
        

    }
    [[NSUserDefaults standardUserDefaults] setObject:self.section2 forKey:@"section1"];

    
    //[self.section2 removeObject:@""];
    if([[NSUserDefaults standardUserDefaults]objectForKey:@"section2"]==nil)
    {
        self.section3 = [[NSMutableArray alloc]init];
        NSString *stringval =[NSString stringWithFormat:@"%@%@", NSLocalizedString(@"service_cost_tv", @"Service Cost/"),dist];
        
        [self.section3 addObject:stringval];
        [self.section3 addObject:NSLocalizedString(@"scpd_tv", @"Service Cost/Day")];
        
    }
    
    else
    {
        self.section3 =[[NSMutableArray alloc]initWithArray:[[[NSUserDefaults standardUserDefaults] objectForKey:@"section2"]mutableCopy]];
        NSString *stringval =[NSString stringWithFormat:@"%@%@", NSLocalizedString(@"service_cost_tv", @"Service Cost/"),dist];
        
        [self.section3 replaceObjectAtIndex:0 withObject:stringval];
    }
    //[self.section3 removeObject:@""];
    
    if([[NSUserDefaults standardUserDefaults]objectForKey:@"section3"]==nil)
    {
        self.section4 = [[NSMutableArray alloc]initWithObjects:
                         NSLocalizedString(@"ecpd_tv", @"Other Expenses/Day"),nil];
        
        [self.section4 insertObject:[NSString stringWithFormat:@"%@%@", NSLocalizedString(@"expense_cost_tv", @"Other Expenses/"),dist] atIndex:0];
    }
    else
    {
        self.section4 =[[NSMutableArray alloc]initWithArray:[[[NSUserDefaults standardUserDefaults] objectForKey:@"section3"]mutableCopy]];
        //[self.section4 insertObject:[NSString stringWithFormat:@"Other Expenses/%@",dist] atIndex:0];
        [self.section4 replaceObjectAtIndex:0 withObject:[NSString stringWithFormat:@"%@%@", NSLocalizedString(@"expense_cost_tv", @"Other Expenses/"),dist]];
    }
    
    if([[NSUserDefaults standardUserDefaults]objectForKey:@"section4"]==nil)
    {
        self.section5 = [[NSMutableArray alloc]initWithObjects:
                         NSLocalizedString(@"total_trips", @"Total Trips"),
                         NSLocalizedString(@"total_trip_dist", @"Total Trip Distance"),
                         NSLocalizedString(@"total_tax_ded", @"Total Trip Deduction"),
                         NSLocalizedString(@"trip_by_type", @"Dist by Type()"),
                         NSLocalizedString(@"tax_ded_by_type", @"Tax Dedn by Type()"), nil];
        //[self.section5 insertObject:[NSString stringWithFormat:@"Other Expenses/%@",dist] atIndex:0];
    }
    else 
    {
        self.section5 =[[NSMutableArray alloc]initWithArray:[[[NSUserDefaults standardUserDefaults] objectForKey:@"section4"]mutableCopy]];
        //[self.section4 insertObject:[NSString stringWithFormat:@"Other Expenses/%@",dist] atIndex:0];
        // [self.section5 replaceObjectAtIndex:0 withObject:[NSString stringWithFormat:@"Other Expenses/%@",dist]];
        //NSLog(@"self.section 5 string: %@", self.section5);
    }
    
}
-(BOOL)shouldAutorotate
{
    return NO;
}


#if __IPHONE_OS_VERSION_MAX_ALLOWED < 90000
- (NSUInteger)supportedInterfaceOrientations
#else
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
#endif
{
    
    return UIInterfaceOrientationMaskPortrait;
}

-(void)pickertap
{
    //NIKHIL BUG_134 added setbutton removeFromSuperView
    [_picker removeFromSuperview];
    [_setbutton removeFromSuperview];
    _picker = [[UIPickerView alloc]init];
    AppDelegate *App = [AppDelegate sharedAppDelegate];
    _picker.frame = CGRectMake(App.result.width/2-130,App.result.height/2-220, 260, 270);
    _picker.backgroundColor=[UIColor grayColor];
    
    _picker.clipsToBounds=YES;
    _picker.delegate =self;
    _picker.dataSource=self;
    _picker.tag=-4;
    self.pickerval = @"Select";
    
    UIBezierPath *maskPath;
    maskPath = [UIBezierPath bezierPathWithRoundedRect:_picker.bounds
                                     byRoundingCorners:(UIRectCornerTopLeft|UIRectCornerTopRight)
                                           cornerRadii:CGSizeMake(5.0, 5.0)];
    
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.view.frame;
    maskLayer.path = maskPath.CGPath;
    _picker.layer.mask = maskLayer;
    
    
    //UIView *topview = (UIView*)[self.view viewWithTag:-2];
    //
    [self.view addSubview:_picker];
    _setbutton =[[UIButton alloc]init];
    _setbutton.frame = CGRectMake(App.result.width/2-130,(App.result.height/2-220)+270, 260, 40);
    //button.titleLabel.text = @"Set" ;
    [_setbutton setBackgroundColor:[UIColor lightGrayColor]];
    [_setbutton setTitle:NSLocalizedString(@"set", @"Set") forState:UIControlStateNormal];
    [_setbutton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    //_setbutton.layer.cornerRadius = 5;
    [_setbutton addTarget:self action:@selector(setfilter) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_setbutton];
    
    
}

-(void)setfilter
{
    
    [self.selectpicker setTitle:[self.pickerdata objectAtIndex:[self.picker selectedRowInComponent:0]] forState:UIControlStateNormal];
    
    
    if(![[self.pickerdata objectAtIndex:[self.picker selectedRowInComponent:0]] isEqualToString:NSLocalizedString(@"graph_date_range_4", @"Custom Dates")])
    {
        [self.picker removeFromSuperview];
        [self.setbutton removeFromSuperview];
        
        [self fetchvalue: [self.pickerdata objectAtIndex:[self.picker selectedRowInComponent:0]]];
        
    }
    else
    {
        [self.picker removeFromSuperview];
        [self.setbutton removeFromSuperview];
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:NSLocalizedString(@"graph_date_range_4", @"Custom Date")
                                              message:NSLocalizedString(@"custom_date_err", @"Please make sure that the dates are selected correctly.")
                                              preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
         {
             textField.placeholder = NSLocalizedString(@"from_date_head", @"Start Date");
             
         }];
        
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
         {
             textField.placeholder = NSLocalizedString(@"to_date_head", @"End Date");
             textField.secureTextEntry = NO;
         }];
        
        
        self.startdate = alertController.textFields.firstObject;
        [self.startdate setPlaceholder:NSLocalizedString(@"from_date_head", @"Start Date")];
        
        [self.startdate setFont:[UIFont systemFontOfSize:25.0]];
        
        self.enddate = alertController.textFields.lastObject;
        [self.enddate setPlaceholder:NSLocalizedString(@"to_date_head", @"End Date")];
        UIDatePicker *datePicker = [[UIDatePicker alloc]init];
        UIDatePicker *datePicker1 = [[UIDatePicker alloc]init];
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"dd-MMM-yyyy"];
        datePicker.timeZone=[NSTimeZone localTimeZone];
        datePicker.datePickerMode=UIDatePickerModeDate;
        //[datePicker setDate:[NSDate date]];
        self.startdate.text = [format stringFromDate:[NSDate date]];
        [datePicker setDate:[format dateFromString:self.startdate.text]];
        [datePicker addTarget:self action:@selector(updateTextField:) forControlEvents:UIControlEventValueChanged];
        
        [datePicker1 addTarget:self action:@selector(updateTextField1:) forControlEvents:UIControlEventValueChanged];
        self.startdate.inputView = datePicker;
        datePicker1.timeZone=[NSTimeZone localTimeZone];
        datePicker1.datePickerMode=UIDatePickerModeDate;
        self.enddate.text = [format stringFromDate:[NSDate date]];
        self.enddate.inputView = datePicker1;
        [self.enddate setFont:[UIFont systemFontOfSize:25.0]];

        
        UIAlertAction *cancelAction = [UIAlertAction
                                       actionWithTitle:NSLocalizedString(@"cancel", @"Cancel action")
                                       style:UIAlertActionStyleCancel
                                       handler:^(UIAlertAction *action)
                                       {
                                         //  NSLog(@"Cancel action");
                                           
                                           [self.selectpicker setTitle:NSLocalizedString(@"graph_date_range_0", @"All Time")  forState:UIControlStateNormal];
                                           
                                           [self fetchvalue : NSLocalizedString(@"graph_date_range_0", @"All Time")];
                                           
                                           
                                           
                                       }];
        
        UIAlertAction *okAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"ok", @"OK action")
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       [self setfilterdata];
                                   }];
        
        [alertController addAction:cancelAction];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

-(void)setfilterdata
{
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"dd-MM-yyyy"];
    //BUG_164 same date shows alert //added Or so if it same even then it will go in
    if([[format dateFromString:self.startdate.text] compare:[format dateFromString:self.enddate.text]]==NSOrderedAscending || [[format dateFromString:self.startdate.text] compare:[format dateFromString:self.enddate.text]]==NSOrderedSame)
    {
        // [self.selectpicker setTitle:[NSString stringWithFormat:@"%@ - %@",self.startdate.text,self.enddate.text] forState:UIControlStateNormal];
        
        [self fetchvalue:@"Custom Dates"];
    }
    else
    {
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:NSLocalizedString(@"custom_date_err", @"Please make sure that the dates are selected correctly.")
                                              message:@""
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
}

-(void)updateTextField:(id)sender
{
    UIDatePicker *picker = (UIDatePicker *)sender;
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"dd-MMM-yyyy"];
    self.startdate.text = [NSString stringWithFormat:@"%@",[format stringFromDate:picker.date]];
}

-(void)updateTextField1:(id)sender
{
    UIDatePicker *picker = (UIDatePicker *)sender;
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"dd-MMM-yyyy"];
    self.enddate.text = [NSString stringWithFormat:@"%@",[format stringFromDate:picker.date]];
}


#pragma mark Vehicle Picker methods

-(void)openselectpicker
{
    if(self.vehiclearray.count>0)
    {
        [self picker:@"Select Vehicle"];
    }
    
    else
    {
        
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:NSLocalizedString(@"no_veh_id", @"No Vehicle Found")
                                              message:@""
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
}

- (void)picker : (NSString *) string{
    //NIKHIL BUG_134 //added setbutton removeFromSuperView
    [_picker removeFromSuperview];
    [_setbutton removeFromSuperview];
    _picker = [[UIPickerView alloc]init];
    AppDelegate *App = [AppDelegate sharedAppDelegate];
    _picker.frame = CGRectMake(App.result.width/2-130,App.result.height/2-220, 260, 270);
    _picker.backgroundColor=[UIColor grayColor];
    
    _picker.clipsToBounds=YES;
    _picker.delegate =self;
    _picker.dataSource=self;
    _picker.tag=-8;
    
    //NIKHIL BUG_131 //added below line
    NSUserDefaults *setRowValue = [NSUserDefaults standardUserDefaults];
    int picRowId = (int)[setRowValue integerForKey:@"rowValue"];
    [_picker selectRow:picRowId inComponent:0 animated:NO];
    self.pickerval = @"Select";
    
    UIBezierPath *maskPath;
    maskPath = [UIBezierPath bezierPathWithRoundedRect:_picker.bounds
                                     byRoundingCorners:(UIRectCornerTopLeft|UIRectCornerTopRight)
                                           cornerRadii:CGSizeMake(5.0, 5.0)];
    
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.view.frame;
    maskLayer.path = maskPath.CGPath;
    _picker.layer.mask = maskLayer;
    
    
    //UIView *topview = (UIView*)[self.view viewWithTag:-2];
    //
    [self.view addSubview:_picker];
    _setbutton =[[UIButton alloc]init];
    _setbutton.frame = CGRectMake(App.result.width/2-130,(App.result.height/2-220)+270, 260, 40);
    //button.titleLabel.text = @"Set" ;
    [_setbutton setBackgroundColor:[UIColor lightGrayColor]];
    [_setbutton setTitle:NSLocalizedString(@"set", @"Set") forState:UIControlStateNormal];
    [_setbutton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    //_setbutton.layer.cornerRadius = 5;
    [_setbutton addTarget:self action:@selector(donelabel) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_setbutton];
    
    
    
}



- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if(pickerView.tag==-8)
    {
        return  self.vehiclearray.count;
    }
    
    if(pickerView.tag==-4)
    {
        
        return self.pickerdata.count;
    }
    else
        return 0;
}



- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if(pickerView.tag==-8)
    {
        NSDictionary *dictionary = [[NSDictionary alloc]init];
        // NSLog(@"dictionary value %@",dictionary);
        dictionary = [self.vehiclearray objectAtIndex:row];
        return [NSString stringWithFormat:@"%@ %@",[dictionary objectForKey:@"Make"],[dictionary objectForKey:@"Model"]];
    }
    
    if(pickerView.tag==-4)
    {
        return [self.pickerdata objectAtIndex:row];
    }
    else
        
        return 0;
}

//NIKHIL BUG_131 added below method
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    _selPickerRow = (int)[pickerView selectedRowInComponent:0];
    NSUserDefaults *setRowValue = [NSUserDefaults standardUserDefaults];
    [setRowValue setInteger:_selPickerRow forKey:@"rowValue"];
}

#pragma mark TIME RANGE PICKER methods
-(void)donelabel
{
    
    NSUserDefaults *def =[NSUserDefaults standardUserDefaults];
    [self.picker removeFromSuperview];
    [self.setbutton removeFromSuperview];
    NSDictionary *dictionary = [[NSDictionary alloc]init];
    dictionary = [self.vehiclearray objectAtIndex:[self.picker selectedRowInComponent:0]];
    //NSLog(@"id value for vehid %@",[dictionary objectForKey:@"Id"]);
    [[NSUserDefaults standardUserDefaults]setObject:[dictionary objectForKey:@"Id"] forKey:@"fillupid"];
    // [[NSUserDefaults standardUserDefaults]setObject:[dictionary objectForKey:@"Id"] forKey:@"idvalue"];
    [def setObject:[def objectForKey:@"fillupid"] forKey:@"oldFillupid"];

    [[NSUserDefaults standardUserDefaults]setObject:[NSString stringWithFormat:@"%@ %@",[dictionary objectForKey:@"Make"],[dictionary objectForKey:@"Model"]] forKey:@"fillupmake"];
    
    self.vehname.text = [NSString stringWithFormat:@"%@ %@",[dictionary objectForKey:@"Make"],[dictionary objectForKey:@"Model"]];
    
    [def setObject:[dictionary objectForKey:@"Id"] forKey:@"idvalue"];
    [def setObject:[NSString stringWithFormat:@"%@ %@",[dictionary objectForKey:@"Make"],[dictionary objectForKey:@"Model"]] forKey:@"vehname"];
    [def setObject:[NSString stringWithFormat:@"%@",[dictionary objectForKey:@"Id"]] forKey:@"fillupid"];
    [def setObject:[dictionary objectForKey:@"Picture"] forKey:@"vehimage"];
    if([[[NSUserDefaults standardUserDefaults]objectForKey:@"vehimage"]isEqualToString:@""])
    {
        // NSLog(@"blank....");
        _vehimage.image=[UIImage imageNamed:@"car4.jpg"];
    }
    
    else
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
        //Swapnil ENH_24
        NSString *urlstring = [paths firstObject];
        
        NSString *vehiclepic = [NSString stringWithFormat:@"%@/%@",urlstring,[[NSUserDefaults standardUserDefaults]objectForKey:@"vehimage"]];
        _vehimage.image =[UIImage imageWithContentsOfFile:vehiclepic];
    }
    
    //[self fetchallfillup];
    
    [self fetchvalue: self.selectpicker.titleLabel.text];
    [self.tableview reloadData];
    
}


-(void)fetchdata
{
    self.vehiclearray =[[NSMutableArray alloc]init];
    
    //BUG changed context to global
    NSManagedObjectContext *context = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSFetchRequest *requset=[[NSFetchRequest alloc] initWithEntityName:@"Veh_Table"];
    NSError *err;
    NSArray *data=[context  executeFetchRequest:requset error:&err];
    for(Veh_Table *vehicle in data)
    {
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
        [dictionary setObject:vehicle.make forKey:@"Make"];
        [dictionary setObject:vehicle.model forKey:@"Model"];
        [dictionary setObject:vehicle.iD forKey:@"Id"];
        
        if(vehicle.picture!=nil)
        {
            [dictionary setObject:vehicle.picture forKey:@"Picture"];
        }
        else
        {
            
            [dictionary setObject:@"" forKey:@"Picture"];
            
        }
        if(vehicle.lic!=nil)
        {
            [dictionary setObject:vehicle.lic forKey:@"Lic"];
        }
        else
        {
            
            [dictionary setObject:@"" forKey:@"Lic"];
        }
        if(vehicle.vin!=nil)
        {
            [dictionary setObject:vehicle.vin forKey:@"Vin"];
        }
        else
        {
            [dictionary setObject:@"" forKey:@"Vic"];
        }
        if(vehicle.year!=nil)
        {
            [dictionary setObject:vehicle.year forKey:@"Year"];
        }
        else
        {
            
            [dictionary setObject:@"" forKey:@"Year"];
        }
        [self.vehiclearray addObject:dictionary];
    }
    
    //NSLog(@"vehicle array %@",self.vehiclearray);
}


-(UIColor *)colorFromHexString:(NSString *)hexString
{
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

-(void)viewDidDisappear:(BOOL)animated
{
    AppDelegate *App = [AppDelegate sharedAppDelegate];
    App.result = [[UIScreen mainScreen] bounds].size;
    [App.blurview removeFromSuperview];
    [App.tabbutton setImage:[UIImage imageNamed:@"tab_add_new"] forState:UIControlStateNormal];
    //[self animate:App.expense :App.result.width/2-22 :App.result.height];
    [App.expense removeFromSuperview];
    //[self animate:App.services :App.result.width/2-22 :App.result.height];
    [App.services removeFromSuperview];
    [App.trip removeFromSuperview];
    
    // [self animate:self.fillup :result.width/2-22 :result.height];
    [App.fillup removeFromSuperview];
    [App.expenselab removeFromSuperview];
    [App.filluplab removeFromSuperview];
    [App.serviceslab removeFromSuperview];
    [App.tripLab removeFromSuperview];
    
    App.services.selected=NO;
    
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 5;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section==0)
    {
        return self.section1.count;
    }
    
    else if(section==1)
    {
        return self.section2.count;
    }
    
    else if(section==2)
    {
        return self.section3.count;
    }
    
    else if(section==3)
    {
        return self.section4.count;
    }
    else if(section==4)
    {
        return self.section5.count;
    }
    else
    {
        return 0;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"] ;
        
    }
    NSString *dist;
    if([[[NSUserDefaults standardUserDefaults]objectForKey:@"dist_unit"] isEqualToString:NSLocalizedString(@"disp_miles", @"Miles")])
    {
        dist = NSLocalizedString(@"mi", @"mi");
    }

    else
    {
        dist= NSLocalizedString(@"kms", @"km");
    }

    NSString *stringval1 =[NSString stringWithFormat:@"%@%@",NSLocalizedString(@"cost_tv", @"Fuel cost/"), dist];
    NSString *stringval2 =[NSString stringWithFormat:@"%@%@", NSLocalizedString(@"service_cost_tv", @"Service Cost/"),dist];
    NSString *stringval3 =[NSString stringWithFormat:@"%@%@", NSLocalizedString(@"expense_cost_tv", @"Other Expenses/"),dist];
    
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
//    cell.textLabel.textColor =[UIColor whiteColor];
//    cell.textLabel.font = [UIFont systemFontOfSize:14];
    
    for (UIView *subview in [cell.contentView subviews])
    {
        if ([subview isKindOfClass:[UILabel class]])
        {
            [subview removeFromSuperview];
        }
    }
    
    
    for (UIView *subview in [cell.contentView subviews])
    {
        if ([subview isKindOfClass:[UIImageView class]])
        {
            [subview removeFromSuperview];
        }
    }
    UILabel *value =[[UILabel alloc]init];
    //[value removeFromSuperview];
    // NSLog(@"value of result %f",App.result.width);
    CGSize result = [[UIScreen mainScreen] bounds].size;
    if(result.width ==320)
    {
        value.frame = CGRectMake(180, 18, 100, 30);//NIKHIL ENH_45  y 8 to 18
    }
    else
    {
        value.frame = CGRectMake(220, 16, 100, 30);//NIKHIL ENH_45 y 6 to 16
    }
    value.textColor =[UIColor whiteColor];
    value.font = [UIFont systemFontOfSize:12];
    value.textAlignment =NSTextAlignmentCenter;
    value.text = NSLocalizedString(@"not_applicable", @"n/a");
    [cell.contentView addSubview:value];
    
    UILabel *stringLabel = [[UILabel alloc] init];
    stringLabel.frame = CGRectMake(12, 10, 170, 45);//NIKHIL ENH_45
    stringLabel.textColor = [UIColor whiteColor];
    stringLabel.textAlignment = NSTextAlignmentLeft;
    [stringLabel setFont:[UIFont systemFontOfSize:14.0]];
    stringLabel.backgroundColor = [UIColor clearColor];
    
    if(indexPath.section == 0)
    {
        stringLabel.text = [self.section1 objectAtIndex:indexPath.row];
        //cell.textLabel.text = [self.section1 objectAtIndex:indexPath.row];
        // NSLog(@"cell text %@",cell.textLabel.text);
        value.text =[self.totalstat objectAtIndex:indexPath.row];
        [cell.contentView addSubview:stringLabel];

    }
    
    if(indexPath.section == 1)
    {
        stringLabel.text = [self.section2 objectAtIndex:indexPath.row];
        
        
        //NSLog(@"self.section2 : %@", self.section2);
        //cell.textLabel.text = [self.section2 objectAtIndex:indexPath.row];
        
        UIImageView *graphimage = [[UIImageView alloc]init];
        if(result.width ==320)
        {
            graphimage.frame = CGRectMake(290, 22, 15, 15);//NIKHIL ENH_45
        }
        else
        {
            
            graphimage.frame = CGRectMake(330, 20, 15, 15);//NIKHIL ENH_45
        }

        NSString *vol_unit;
        if([[[NSUserDefaults standardUserDefaults]objectForKey:@"vol_unit"] isEqualToString:NSLocalizedString(@"disp_kilowatt_hour", @"Kilowatt-Hour")]){

            vol_unit = NSLocalizedString(@"kwh", @"kWh");

        }else if([[[NSUserDefaults standardUserDefaults]objectForKey:@"vol_unit"] isEqualToString:NSLocalizedString(@"disp_litre", @"Litre")])
        {
            vol_unit = NSLocalizedString(@"ltr", @"Ltr");
            
        }
        
        else
        {
            vol_unit = NSLocalizedString(@"gal", @"gal");
        }
        
        //Swapnil ENH_19
        NSString *vol = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"avg_price_tv", @"Average Price/"), vol_unit];
        //[NSString stringWithFormat:@"%@%@",NSLocalizedString(@"cost_tv", @"Fuel cost/"), dist]
        if(indexPath.row==0 || [[self.section2 objectAtIndex:indexPath.row]isEqualToString:NSLocalizedString(@"dist_btn_fu_graph_name", @"Distance between Fill-ups")] || [[self.section2 objectAtIndex:indexPath.row]isEqualToString:NSLocalizedString(@"fu_pm_tv", @"Fill-ups/month")] || [[self.section2 objectAtIndex:indexPath.row]isEqualToString:stringval1] || [[self.section2 objectAtIndex:indexPath.row]isEqualToString:NSLocalizedString(@"cpd_tv", @"Fuel Cost/day")] || [[self.section2 objectAtIndex:indexPath.row]isEqualToString:vol] || [[self.section2 objectAtIndex:indexPath.row]isEqualToString:NSLocalizedString(@"cpmth_tv", @"Fuel Cost/Mth")] || [[self.section2 objectAtIndex:indexPath.row]isEqualToString:[NSString stringWithFormat:@"%@ (%@)", NSLocalizedString(@"eff_oct_tv", @"Eff by Octane"), maxOctane]] || [[self.section2 objectAtIndex:indexPath.row]isEqualToString:[NSString stringWithFormat:@"%@ (%@)", NSLocalizedString(@"eff_brand_tv", @"Eff by Brand"), maxBrand]] || [[self.section2 objectAtIndex:indexPath.row]isEqualToString:[NSString stringWithFormat:@"%@ (%@)", NSLocalizedString(@"eff_stn_tv", @"Eff by Stn"), maxStation]])
        {

            graphimage.image = [UIImage imageNamed:@"graph_icon"];
        }
        else
        {
            graphimage.image = nil;
        }
        
        // graphimage.image = [UIImage imageNamed:@"graph_icon"];
        [cell.contentView addSubview:graphimage];
        
        value.text =[self.avgfuelstat objectAtIndex:indexPath.row];
        [cell.contentView addSubview:stringLabel];
        
    }
    
    if(indexPath.section == 2)
    {

        UIImageView *graphimage = [[UIImageView alloc]init];
        if(result.width ==320)
        {
            graphimage.frame = CGRectMake(290, 22, 15, 15);//NIKHIL ENH_45
        }
        else
        {

            graphimage.frame = CGRectMake(330, 20, 15, 15);//NIKHIL ENH_45
        }
        if([[self.section3 objectAtIndex:indexPath.row]isEqualToString:stringval2] || [[self.section3 objectAtIndex:indexPath.row]isEqualToString:NSLocalizedString(@"scpd_tv", @"Service Cost/Day")])
        {

            graphimage.image = [UIImage imageNamed:@"graph_icon"];
        }
        else
        {
            graphimage.image = nil;
        }
        stringLabel.text = [self.section3 objectAtIndex:indexPath.row];
        //cell.textLabel.text = [self.section3 objectAtIndex:indexPath.row];
        //UIImageView *graphimage = [[UIImageView alloc]init];
        value.text = [self.avgservstat objectAtIndex:indexPath.row];
        
        [cell.contentView addSubview:graphimage];
        [cell.contentView addSubview:stringLabel];
    }
    
    if(indexPath.section == 3)
    {
        UIImageView *graphimage = [[UIImageView alloc]init];
        if(result.width ==320)
        {
            graphimage.frame = CGRectMake(290, 22, 15, 15);//NIKHIL ENH_45
        }
        else
        {

            graphimage.frame = CGRectMake(330, 20, 15, 15);//NIKHIL ENH_45
        }
        if([[self.section4 objectAtIndex:indexPath.row]isEqualToString:stringval3] || [[self.section4 objectAtIndex:indexPath.row]isEqualToString:NSLocalizedString(@"ecpd_tv", @"Other Expenses/Day")])
        {

            graphimage.image = [UIImage imageNamed:@"graph_icon"];
        }
        else
        {
            graphimage.image = nil;
        }

        stringLabel.text = [self.section4 objectAtIndex:indexPath.row];

        value.text = [self.avgexpstat objectAtIndex:indexPath.row];
        [cell.contentView addSubview:graphimage];
        [cell.contentView addSubview:stringLabel];

    }
    if(indexPath.section == 4)
    {

        UIImageView *graphimage = [[UIImageView alloc]init];
        if(result.width ==320)
        {
            graphimage.frame = CGRectMake(290, 22, 15, 15);//NIKHIL ENH_45 y 12 to 22
        }
        else
        {
            
            graphimage.frame = CGRectMake(330, 20, 15, 15);//NIKHIL ENH_45 y 10 to 20
        }
        
        if([[self.section5 objectAtIndex:indexPath.row]isEqualToString:newStr1 ]||[[self.section5 objectAtIndex:indexPath.row]isEqualToString:newStr2] )
        {
            graphimage.image = [UIImage imageNamed:@"graph_icon"];
        }
        else
        {
            graphimage.image = nil;
        }
        
        [cell.contentView addSubview:graphimage];
        stringLabel.text = [self.section5 objectAtIndex:indexPath.row];

        //cell.textLabel.text = [self.section5 objectAtIndex:indexPath.row];
        value.text = [self.totTripStats objectAtIndex:indexPath.row];
        [cell.contentView addSubview:stringLabel];

    }

    
    return cell;
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    
    if(tableView==self.tableview)
    {
        UIView *sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 728, 40)];
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(67,12 , 728, 40)];//NIKHIL ENH_45 y to 15
        
        //titleLabel.backgroundColor = [UIColor whiteColor];
        UIImageView *sectionimg = [[UIImageView alloc]init];
        sectionimg.frame =CGRectMake(12, titleLabel.frame.origin.y, 35, 35);//NIKHIL ENH_45
        
        
        titleLabel.textColor =[UIColor whiteColor];
        titleLabel.font =[UIFont systemFontOfSize:18];
        sectionView.backgroundColor =[self colorFromHexString:@"#2c2c2c"];
        if(section==0)
        {
            
            titleLabel.text = NSLocalizedString(@"tot_fig_tv", @"Total Stats");
            
            
            sectionimg.image=[UIImage imageNamed:@"total_stats"];
        }
        
        if(section==1)
        {
            
            titleLabel.text = NSLocalizedString(@"avg_fig_head", @"Average Fuel Stats");
            
            sectionimg.image=[UIImage imageNamed:@"fill_up_icon"];
        }
        if(section==2)
        {
            
            titleLabel.text = NSLocalizedString(@"avg_service_head", @"Average Service Stats") ;
            
            sectionimg.image=[UIImage imageNamed:@"service_icon"];
        }
        if(section==3)
        {
            
            titleLabel.text = NSLocalizedString(@"avg_expense_head", @"Average Expense Stats");
            
            sectionimg.image=[UIImage imageNamed:@"expense_icon"];
        }
        if(section==4)
        {
            
            titleLabel.text = NSLocalizedString(@"trip_stats", @"Total Trip Stats");
            
            sectionimg.image=[UIImage imageNamed:@"trip_icon"];
        }
        
        [sectionView addSubview:titleLabel];
        [sectionView addSubview: sectionimg];
        
        
        
        
        return sectionView;
    }
    else
        return nil;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(tableView==self.tableview)
    {
        return 75;
        return UITableViewAutomaticDimension;
    }
    
    
    else
        return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    NSString *dist;
    if([[[NSUserDefaults standardUserDefaults]objectForKey:@"dist_unit"] isEqualToString:NSLocalizedString(@"disp_miles", @"Miles")])
    {
        dist = NSLocalizedString(@"mi", @"mi");
    }

    else
    {
        dist= NSLocalizedString(@"kms", @"km");
    }

    NSString *stringval1 =[NSString stringWithFormat:@"%@%@",NSLocalizedString(@"cost_tv", @"Fuel cost/"), dist];
    NSString *stringval2 =[NSString stringWithFormat:@"%@%@", NSLocalizedString(@"service_cost_tv", @"Service Cost/"),dist];
    NSString *stringval3 =[NSString stringWithFormat:@"%@%@", NSLocalizedString(@"expense_cost_tv", @"Other Expenses/"),dist];

    NSDateFormatter *formater=[[NSDateFormatter alloc] init];
    [formater setDateFormat:@"dd/MMM"];

    if (indexPath.section ==1)
    {
        
        if(![[self.avgfuelstat objectAtIndex:indexPath.row] isEqualToString:NSLocalizedString(@"not_applicable", @"n/a")])
        {

            NSString *dist_unit,*vol_unit;
            if(indexPath.row==0)
            {
                GraphViewController *graph = (GraphViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"graph"];
                graph.xaxis =[[NSMutableArray alloc]init];
                graph.yaxis =[[NSMutableArray alloc]init];
                
                for(T_Fuelcons *fillup in self.filluparray)
                {
               
                    if([fillup.cons floatValue]!=0 && fillup.cons!=NULL)
                    {
                        NSString *datevalue = [formater stringFromDate:fillup.stringDate];

                        //Swapnil Issue #94 (crashlytics)
                        if(datevalue != nil){
                            [graph.yaxis addObject:datevalue];
                            
                            //NSLog(@"fill.cons = %.2f", [fillup.cons floatValue]);
                            
                            //Swapnil BUG_93
                            if([[[NSUserDefaults standardUserDefaults] objectForKey:@"con_unit"] isEqualToString:NSLocalizedString(@"disp_lp100kms", @"L/100km")]){
                                
                                [graph.xaxis addObject:[NSString stringWithFormat:@"%.2f", 100 / [fillup.cons floatValue]]];
                            } else {
                                [graph.xaxis addObject:[NSString stringWithFormat:@"%.2f",[fillup.cons floatValue]]];
                            }
                        }
                    }
                } 
                
                NSArray *array1 = [[[NSUserDefaults standardUserDefaults]objectForKey:@"con_unit"] componentsSeparatedByString:@" "];
                NSString *string1 = [array1 firstObject];
                
                
                graph.yaxisstring = string1;
//                NSLog(@"xaxis array %@",graph.xaxis);
//                NSLog(@"yaxis array %@",graph.yaxis);
                graph.titlestring = [self.section2 objectAtIndex:indexPath.row];
                graph.modalPresentationStyle = UIModalPresentationFullScreen;
                [self.navigationController pushViewController:graph animated:YES];
            }

            //Fuel cost/km running is default
            if([[self.section2 objectAtIndex:indexPath.row] isEqualToString:stringval1]){

                fuelPerDistBtnPickerView.hidden = false;
            }

            //Fuel cost/day
            if([[self.section2 objectAtIndex:indexPath.row]isEqualToString:NSLocalizedString(@"cpd_tv", @"Fuel Cost/day")]){

                fuelPerDayBtnPickerView.hidden = false;
//                GraphViewController *graph = (GraphViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"graph"];
//                graph.xaxis =[[NSMutableArray alloc]init];
//                graph.yaxis =[[NSMutableArray alloc]init];
//
//                NSNumber *cost = 0;
//
//                NSMutableDictionary *dataDict = [[NSMutableDictionary alloc] init];
//                NSMutableArray *dataArray = [[NSMutableArray alloc] init];
//
//                NSDateFormatter *thisFormater=[[NSDateFormatter alloc] init];
//                [thisFormater setDateFormat:@"dd/MMM/yyyy"];
//
//                for(T_Fuelcons *fillup in self.filluparray)
//                {
//                    NSString *datevalue = [thisFormater stringFromDate:fillup.stringDate];
//                    cost = fillup.cost;
//
//                    [dataDict setObject:datevalue forKey:@"date"];
//                    [dataDict setValue:cost forKey:@"cost"];
//                    [dataArray addObject:[dataDict mutableCopy]];
//                    [dataDict removeAllObjects];
//                }
//
//                double totalCost = 0;
//                int index = 0;
//                NSInteger days;
//                NSString *datevalue;
//                for(NSDictionary *dict in dataArray){
//
//                    if (index == 0){
//                        datevalue = [dict objectForKey:@"date"];
//                        days = 1;
//
//                        if(datevalue != nil){
//                            [graph.yaxis addObject:datevalue];
//
//                        }
//                    }else{
//
//                        NSString *date2value = [dict objectForKey:@"date"];
//
//                        days = [self numberOfDaysBetween:datevalue and:date2value]+1;
//
//                        if(datevalue != nil){
//                            [graph.yaxis addObject:date2value];
//
//                        }
//                    }
//
//                    double cost = [[dict objectForKey:@"cost"] floatValue];
//
//                    totalCost = totalCost + cost;
//
//                    double costPerKm = totalCost/days;
//                    [graph.xaxis addObject:[NSString stringWithFormat:@"%.2f",costPerKm]];
//
//                    index = index+1;
//                }
//
//                graph.yaxisstring = @"Cost";
//                graph.titlestring = NSLocalizedString(@"cpd_tv", @"Fuel Cost/day");
//                graph.modalPresentationStyle = UIModalPresentationFullScreen;
//                [self.navigationController pushViewController:graph animated:YES];
            }

            if([[self.section2 objectAtIndex:indexPath.row] isEqualToString:NSLocalizedString(@"dist_btn_fu_graph_name", @"Distance between Fill-ups")])
            {
                GraphViewController *graph = (GraphViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"graph"];
                graph.xaxis =[[NSMutableArray alloc]init];
                graph.yaxis =[[NSMutableArray alloc]init];
                if([[[NSUserDefaults standardUserDefaults]objectForKey:@"dist_unit"] isEqualToString:NSLocalizedString(@"disp_miles", @"Miles")])
                {
                    dist_unit = NSLocalizedString(@"mi", @"mi");
                }

                else
                {
                    dist_unit = NSLocalizedString(@"kms", @"km");
                }

                for(T_Fuelcons *fillup in self.filluparray)
                    {
                    if([fillup.dist floatValue]!=0 && fillup.dist!=NULL)
                    {
                        NSString *datevalue = [formater stringFromDate:fillup.stringDate];
                        if (datevalue != nil) {
                            [graph.yaxis addObject:datevalue];
                            [graph.xaxis addObject:[NSString stringWithFormat:@"%.2f",[fillup.dist floatValue]]];
                        }
                        
                    }
                }

                graph.yaxisstring = dist_unit;
                graph.titlestring = [self.section2 objectAtIndex:indexPath.row];
                graph.modalPresentationStyle = UIModalPresentationFullScreen;
                [self.navigationController pushViewController:graph animated:YES];
            }

            if([[[NSUserDefaults standardUserDefaults]objectForKey:@"vol_unit"] isEqualToString:NSLocalizedString(@"disp_kilowatt_hour", @"Kilowatt-Hour")]){

                vol_unit = NSLocalizedString(@"kwh", @"kWh");

            }else if([[[NSUserDefaults standardUserDefaults]objectForKey:@"vol_unit"] isEqualToString:NSLocalizedString(@"disp_litre", @"Litre")])
            {
                vol_unit = NSLocalizedString(@"ltr", @"Ltr");
                
            }
            
            else
            {
                vol_unit = NSLocalizedString(@"gal", @"gal");
            }
            
            if([[self.section2 objectAtIndex:indexPath.row] isEqualToString:[NSString stringWithFormat:@"%@%@", NSLocalizedString(@"avg_price_tv", @"Average Price/"), vol_unit]])
            {
                GraphViewController *graph = (GraphViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"graph"];
                graph.xaxis =[[NSMutableArray alloc]init];
                graph.yaxis =[[NSMutableArray alloc]init];
                
                for(T_Fuelcons *fillup in self.filluparray)
                {
                    // NSLog(@"cost value %.2f",[fillup.cost floatValue]);
                    if([fillup.cost floatValue]!=0 && fillup.cost!=NULL)
                    {
                        //GRAPH ISSUE BUG
                        
                        NSString *datevalue = [formater stringFromDate:fillup.stringDate];
                        if (datevalue != nil) {
                        float price = [fillup.cost floatValue] /[fillup.qty floatValue];
                        [graph.yaxis addObject:datevalue];
                        [graph.xaxis addObject:[NSString stringWithFormat:@"%.2f",price]];
                   
                        }
                    }
                    
                    
                }
                
                //NSLog(@"xaxis array %@",graph.xaxis);
                //NSLog(@"yaxis array %@",graph.yaxis);
                graph.yaxisstring = vol_unit;
                graph.titlestring = [self.section2 objectAtIndex:indexPath.row];
                graph.modalPresentationStyle = UIModalPresentationFullScreen;
                [self.navigationController pushViewController:graph animated:YES];
                //[self presentViewController:graph animated:YES completion:nil];
            }
            
            
            if([[self.section2 objectAtIndex:indexPath.row] isEqualToString:NSLocalizedString(@"cpmth_tv", @"Fuel Cost/Mth")])
            {
                //NIKHIL BUG_156
                self.context =[[CoreDataController sharedInstance] newManagedObjectContext];
                
                NSUserDefaults *Def =[NSUserDefaults standardUserDefaults];
                NSString *comparestring = [NSString stringWithFormat:@"%@",[Def objectForKey:@"fillupid"]];
                
                NSFetchRequest *request=[[NSFetchRequest alloc] initWithEntityName:@"T_Fuelcons"];
                
                
                
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"vehid==%@ AND type==0",comparestring]      ;
                [request setPredicate:predicate];
                
                NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"stringDate" ascending:YES];
                NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
                [request setSortDescriptors:sortDescriptors];
                // Specify that the request should return dictionaries.
                [request setResultType:NSDictionaryResultType];
                [request setPropertiesToFetch:
                 [NSArray arrayWithObjects:@"cost", @"stringDate",nil]];
                
                // Execute the fetch.
                NSError *error = nil;
                NSArray *result = [self.context executeFetchRequest:request error:&error];
                
                NSMutableArray* dataArray = [[NSMutableArray alloc] init];
                for(NSDictionary *costPerMonth in result)
                {
                    NSMutableDictionary *dataval = [[NSMutableDictionary alloc]init];
                    [formater setDateFormat:@"MMM"];
                    [dataval setValue:[formater stringFromDate:[costPerMonth objectForKey:@"stringDate"]] forKey:@"month"];
                    [formater setDateFormat:@"yyyy"];
                    [dataval setValue:[formater stringFromDate:[costPerMonth objectForKey:@"stringDate"]] forKey:@"year"];
                    [dataval setValue:[costPerMonth objectForKey:@"cost"] forKey:@"cost"];
                    // NSLog(@"DataVal: %@", dataval);
                    [dataArray addObject:dataval];
                    
                }
                
                // NSLog(@"dataArray: %@", dataArray);
                NSArray *yearArray = [dataArray valueForKeyPath:@"@distinctUnionOfObjects.year"];
                
                NSMutableArray *results = [[NSMutableArray alloc] init];
                for (id year in yearArray)
                {
                    
                    NSMutableDictionary *resultsByDate = [[NSMutableDictionary alloc] init];
                    
                    for (NSDictionary *dictionary in dataArray) {
                        
                        
                        id mon = [dictionary objectForKey:@"month"];
                        id yr = [dictionary objectForKey:@"year"];
                        
                        if (yr == year) {
                            NSMutableDictionary *result = [resultsByDate objectForKey:mon];
                            
                            if (result == nil) {
                                result = [[NSMutableDictionary alloc] init];
                                [resultsByDate setObject:result forKey:mon];
                                [results addObject:result];
                                [result setObject:mon forKey:@"Month"];
                                [result setObject:yr forKey:@"Year"];
                            }
                            
                            double total = [[result objectForKey:@"TotalCost"] doubleValue];
                            total += [[dictionary objectForKey:@"cost"] doubleValue];
                            
                            int count = 1 + [[result objectForKey:@"Count"] intValue];
                            
                            [result setObject:@(total) forKey:@"TotalCost"];
                            [result setObject:@(count) forKey:@"Count"];
                        }
                    }
                    
                }
                
              //  NSLog(@"Result: %@", results);
                
                
                BarGraphViewController *barchart = [self.storyboard instantiateViewControllerWithIdentifier:@"bargraph1"];
                barchart.dataArray =[[NSMutableArray alloc]initWithArray:results];
                barchart.barChartType = @2; // Fuel Cost per Month
                barchart.title = [self.section2 objectAtIndex:indexPath.row];
                barchart.modalPresentationStyle = UIModalPresentationFullScreen;
                [self.navigationController pushViewController:barchart animated:YES];
            }
            
            
            if([[self.section2 objectAtIndex:indexPath.row] isEqualToString:NSLocalizedString(@"fu_pm_tv", @"Fill-ups/month")])
            {
                //NSLog(@"self.filluparray from didselect - DashBoard:::%@",self.filluparray.lastObject);

                NSMutableArray *montharray =[[NSMutableArray alloc]init];
                for(T_Fuelcons *fillup in self.filluparray)
                {
                    NSMutableDictionary *dataval = [[NSMutableDictionary alloc]init];
                    [formater setDateFormat:@"MMM"];
                    [dataval setValue:[formater stringFromDate:fillup.stringDate] forKey:@"month"];
                    [formater setDateFormat:@"yyyy"];
                    [dataval setValue:[formater stringFromDate:fillup.stringDate] forKey:@"year"];
                    // NSLog(@"DataVal: %@", dataval);
                    [montharray addObject:dataval];
                    
                }
                
                
                BarGraphViewController *barchart = [self.storyboard instantiateViewControllerWithIdentifier:@"bargraph1"];
                barchart.dataArray =[[NSMutableArray alloc]initWithArray:montharray];
                barchart.barChartType = @1; // Fill-ups/month
                barchart.title = [self.section2 objectAtIndex:indexPath.row];
                barchart.modalPresentationStyle = UIModalPresentationFullScreen;
                [self.navigationController pushViewController:barchart animated:YES];
            }
            
            //Swapnil ENH_19
            //Eff by Octane
            
            if([[self.section2 objectAtIndex:indexPath.row] isEqualToString:[NSString stringWithFormat:@"%@ (%@)", NSLocalizedString(@"eff_oct_tv", @"Eff by Octane"), maxOctane]]){
                self.octaneEff = [[NSMutableArray alloc] init];

                NSString *con_unit = [[NSUserDefaults standardUserDefaults]objectForKey:@"con_unit"];

                for(int i = 0; i < self.octEffArray.count; i++){
                    
                    NSString *str1=[NSString stringWithFormat:@"%.2f",[[self.octEffArray objectAtIndex:i] floatValue]];
                    if([con_unit containsString:@"100"])
                    {
                        str1=[NSString stringWithFormat:@"%.2f",100/[[self.octEffArray objectAtIndex:i] floatValue]];
                        
                    }
                    NSArray *arr2=[[NSArray alloc]init];
                    arr2 = [str1 componentsSeparatedByString:@"."];
                    int temp=[[arr2 lastObject] intValue];
                    NSString *decimalval1 = [NSString stringWithFormat:@"%d",temp];
                    
                    if([con_unit containsString:@"100"])
                    {
                        //Swapnil ISSUE #93 (crashlytics)

//                        if(temp==0)
//                        {
//                            [self.octaneEff addObject:[NSString stringWithFormat:@"%.2f",[[self.octEffArray objectAtIndex:i] floatValue]]];
//                        }
//                        else if(![[decimalval1 substringFromIndex:1]isEqualToString:@"0"])
//                        {
                            [self.octaneEff addObject:[NSString stringWithFormat:@"%.2f",100/[[self.octEffArray objectAtIndex:i] floatValue]]];
//                        }
//                        
//                        else
//                        {
//                            [self.octaneEff addObject:[NSString stringWithFormat:@"%.1f",100/[[self.octEffArray objectAtIndex:i] floatValue]]];
//                        }
                        
                    }
                    else
                    {
                        //Swapnil ISSUE #93 (crashlytics)

//                        if(temp==0)
//                        {
//                            [self.octaneEff addObject:[NSString stringWithFormat:@"%.2f",[[self.octEffArray objectAtIndex:i] floatValue]]];
//                        }
//                        else if(![[decimalval1 substringFromIndex:1]isEqualToString:@"0"])
//                        {
                            [self.octaneEff addObject:[NSString stringWithFormat:@"%.2f",[[self.octEffArray objectAtIndex:i] floatValue]]];
//                        }
//                        
//                        else
//                        {
//                            [self.octaneEff addObject:[NSString stringWithFormat:@"%.1f",[[self.octEffArray objectAtIndex:i] floatValue]]];
//                        }
                        
                    }
                }
                //NSLog(@"octaneEff = %@", self.octaneEff);
                BarGraphViewController *barchart = [self.storyboard instantiateViewControllerWithIdentifier:@"bargraph1"];
                barchart.dataArray =[[NSMutableArray alloc]initWithArray:self.octArray];
                barchart.values = self.octaneEff;
                barchart.barChartType = @5; // Eff by Octane
                barchart.title = NSLocalizedString(@"eff_by_oct_graph_name", @"Efficiency by Octane");
                barchart.modalPresentationStyle = UIModalPresentationFullScreen;
                [self.navigationController pushViewController:barchart animated:YES];
            }
            
            
            //Eff by brand
            if([[self.section2 objectAtIndex:indexPath.row] isEqualToString:[NSString stringWithFormat:@"%@ (%@)", NSLocalizedString(@"eff_brand_tv", @"Eff by Brand"), maxBrand]]){
                self.fbEffArray = [[NSMutableArray alloc] init];
                
                NSString *con_unit = [[NSUserDefaults standardUserDefaults]objectForKey:@"con_unit"];
                
                for(int i = 0; i < self.fbEffGraphArr.count; i++){
                    
                    NSString *str1=[NSString stringWithFormat:@"%.2f",[[self.fbEffGraphArr objectAtIndex:i] floatValue]];
                    if([con_unit containsString:@"100"])
                    {
                        str1=[NSString stringWithFormat:@"%.2f",100/[[self.fbEffGraphArr objectAtIndex:i] floatValue]];
                        
                    }
                    NSArray *arr2=[[NSArray alloc]init];
                    arr2 = [str1 componentsSeparatedByString:@"."];
                    int temp=[[arr2 lastObject] intValue];
                    NSString *decimalval1 = [NSString stringWithFormat:@"%d",temp];
                    
                    if([con_unit containsString:@"100"])
                    {
                        //Swapnil ISSUE #93 (crashlytics)

//                        if(temp==0)
//                        {
//                            [self.fbEffArray addObject:[NSString stringWithFormat:@"%.2f",[[self.fbEffGraphArr objectAtIndex:i] floatValue]]];
//                        }
//                        else if(![[decimalval1 substringFromIndex:1]isEqualToString:@"0"])
//                        {
                            [self.fbEffArray addObject:[NSString stringWithFormat:@"%.2f",100/[[self.fbEffGraphArr objectAtIndex:i] floatValue]]];
//                        }
//                        
//                        else
//                        {
//                            [self.fbEffArray addObject:[NSString stringWithFormat:@"%.1f",100/[[self.fbEffGraphArr objectAtIndex:i] floatValue]]];
//                        }
                        
                    }
                    else
                    {
//                        if(temp==0)
//                        {
//                            [self.fbEffArray addObject:[NSString stringWithFormat:@"%.2f",[[self.fbEffGraphArr objectAtIndex:i] floatValue]]];
//                        }
//                        else if(![[decimalval1 substringFromIndex:1]isEqualToString:@"0"])
//                        {
                            [self.fbEffArray addObject:[NSString stringWithFormat:@"%.2f",[[self.fbEffGraphArr objectAtIndex:i] floatValue]]];
//                        }
//                        
//                        else
//                        {
//                            [self.fbEffArray addObject:[NSString stringWithFormat:@"%.1f",[[self.fbEffGraphArr objectAtIndex:i] floatValue]]];
//                        }
                        
                    }
                }
                //NSLog(@"brandEff = %@", self.fbEffArray);
                BarGraphViewController *barchart = [self.storyboard instantiateViewControllerWithIdentifier:@"bargraph1"];
                barchart.dataArray =[[NSMutableArray alloc]initWithArray:self.fbGraphArr];
                barchart.values = self.fbEffArray;
                barchart.barChartType = @6; // Eff by brand
                barchart.title = NSLocalizedString(@"eff_by_brand_graph_name", @"Efficiency by Brand") ;
                barchart.modalPresentationStyle = UIModalPresentationFullScreen;
                [self.navigationController pushViewController:barchart animated:YES];
            }
            
            //Eff by Station
            if([[self.section2 objectAtIndex:indexPath.row] isEqualToString:[NSString stringWithFormat:@"%@ (%@)", NSLocalizedString(@"eff_stn_tv", @"Eff by Stn"), maxStation]]){
                self.fsEffArray = [[NSMutableArray alloc] init];
                
                NSString *con_unit = [[NSUserDefaults standardUserDefaults]objectForKey:@"con_unit"];
                
                for(int i = 0; i < self.fsEffGraphArr.count; i++){
                    
                    NSString *str1=[NSString stringWithFormat:@"%.2f",[[self.fsEffGraphArr objectAtIndex:i] floatValue]];
                    if([con_unit containsString:@"100"])
                    {
                        str1=[NSString stringWithFormat:@"%.2f",100/[[self.fsEffGraphArr objectAtIndex:i] floatValue]];
                        
                    }
                    NSArray *arr2=[[NSArray alloc]init];
                    arr2 = [str1 componentsSeparatedByString:@"."];
                    int temp=[[arr2 lastObject] intValue];
                    NSString *decimalval1 = [NSString stringWithFormat:@"%d",temp];
                    
                    if([con_unit containsString:@"100"])
                    {
                        //Swapnil ISSUE #93 (crashlytics)

//                        if(temp==0)
//                        {
//                            [self.fsEffArray addObject:[NSString stringWithFormat:@"%.2f",[[self.fsEffGraphArr objectAtIndex:i] floatValue]]];
//                        }
//                        else if(![[decimalval1 substringFromIndex:1]isEqualToString:@"0"])
//                        {
                            [self.fsEffArray addObject:[NSString stringWithFormat:@"%.2f",100/[[self.fsEffGraphArr objectAtIndex:i] floatValue]]];
//                        }
//                        
//                        else
//                        {
//                            [self.fsEffArray addObject:[NSString stringWithFormat:@"%.1f",100/[[self.fsEffGraphArr objectAtIndex:i] floatValue]]];
//                        }
                        
                    }
                    else
                    {
                        //Swapnil ISSUE #93 (crashlytics)

//                        if(temp==0)
//                        {
//                            [self.fsEffArray addObject:[NSString stringWithFormat:@"%.2f",[[self.fsEffGraphArr objectAtIndex:i] floatValue]]];
//                        }
//                        else if(![[decimalval1 substringFromIndex:1]isEqualToString:@"0"])
//                        {
                            [self.fsEffArray addObject:[NSString stringWithFormat:@"%.2f",[[self.fsEffGraphArr objectAtIndex:i] floatValue]]];
//                        }
//                        
//                        else
//                        {
//                            [self.fsEffArray addObject:[NSString stringWithFormat:@"%.1f",[[self.fsEffGraphArr objectAtIndex:i] floatValue]]];
//                        }
                        
                    }
                }
                //NSLog(@"stnarr = %@", self.fsEffArray);
                BarGraphViewController *barchart = [self.storyboard instantiateViewControllerWithIdentifier:@"bargraph1"];
                barchart.dataArray =[[NSMutableArray alloc]initWithArray:self.fsGraphArr];
                barchart.values = self.fsEffArray;
                barchart.barChartType = @7; // Eff by Station
                barchart.title = NSLocalizedString(@"eff_by_stn_graph_name", @"Efficiency by Station");
                barchart.modalPresentationStyle = UIModalPresentationFullScreen;
                [self.navigationController pushViewController:barchart animated:YES];
            }
        }

    }else if(indexPath.section==2){

        //Service cost/km running is default

        if([[self.section3 objectAtIndex:indexPath.row] isEqualToString:stringval2]){

            [self showRunningServicePerDistGraph];
//            GraphViewController *graph = (GraphViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"graph"];
//            graph.xaxis =[[NSMutableArray alloc]init];
//            graph.yaxis =[[NSMutableArray alloc]init];
//
//            NSNumber *odo = 0;
//            NSNumber *dist = 0;
//            NSNumber *cost = 0;
//
//            NSMutableDictionary *dataDict = [[NSMutableDictionary alloc] init];
//            NSMutableArray *dataArray = [[NSMutableArray alloc] init];
//
//            //NSLog(@"self.servicearray:- %@",self.servicearray);
//            BOOL firstServiceFound = false;
//            for(T_Fuelcons *fillup in self.servicearray)
//            {
//                if(!firstServiceFound){
//
//                    if([fillup.type integerValue]==1){
//                        firstServiceFound = true;
//                        NSString *datevalue = [formater stringFromDate:fillup.stringDate];
//                        odo = fillup.odo;
//                        dist = fillup.dist;
//                        cost = fillup.cost;
//
//                        [dataDict setObject:fillup.type forKey:@"type"];
//                        [dataDict setObject:datevalue forKey:@"date"];
//                        [dataDict setValue:odo forKey:@"odo"];
//                        [dataDict setValue:cost forKey:@"cost"];
//                        [dataArray addObject:[dataDict mutableCopy]];
//                        [dataDict removeAllObjects];
//                    }else{
//                        continue;
//                    }
//                }else{
//
//                    NSString *datevalue = [formater stringFromDate:fillup.stringDate];
//                    odo = fillup.odo;
//                    dist = fillup.dist;
//                    cost = fillup.cost;
//
//                    [dataDict setObject:fillup.type forKey:@"type"];
//                    [dataDict setObject:datevalue forKey:@"date"];
//                    [dataDict setValue:odo forKey:@"odo"];
//                    [dataDict setValue:cost forKey:@"cost"];
//                    [dataArray addObject:[dataDict mutableCopy]];
//                    [dataDict removeAllObjects];
//                }
//
//            }
//
//            int index = 0;
//            double totalCost = 0;
//            double totalkm = 0;
//            double serOdo=0;
//            double odometer = 0;
//            for(NSDictionary *dict in dataArray){
//
//                if(index == 0){
//
//                    serOdo = [[dict objectForKey:@"odo"] floatValue];
//                    totalCost = [[dict objectForKey:@"cost"] floatValue];
//                }
//                else if(index == 1){
//
//                    NSString *datevalue = [dict objectForKey:@"date"];
//
//                    if(datevalue != nil){
//                        [graph.yaxis addObject:datevalue];
//
//                    }
//
//                    int recordType = [[dict objectForKey:@"type"] intValue];
//                    if(recordType == 1){
//
//                        double cost = [[dict objectForKey:@"cost"] floatValue];
//                        totalCost = totalCost + cost;
//                    }
//
//                    odometer = [[dict objectForKey:@"odo"] floatValue];
//                    double dist = odometer - serOdo;
//                    totalkm = totalkm + dist;
//
//                    double costPerKm = totalCost/totalkm;
//                    NSLog(@"%.2f",totalCost);
//                    NSLog(@"%.2f",totalkm);
//                    NSLog(@"%.2f",costPerKm);
//                    [graph.xaxis addObject:[NSString stringWithFormat:@"%.2f",costPerKm]];
//
//                }else if(index > 1){
//
//                    NSString *datevalue = [dict objectForKey:@"date"];
//
//                    if(datevalue != nil){
//                        [graph.yaxis addObject:datevalue];
//
//                    }
//
//                    int recordType = [[dict objectForKey:@"type"] intValue];
//                    if(recordType == 1){
//
//                        double cost = [[dict objectForKey:@"cost"] floatValue];
//                        totalCost = totalCost + cost;
//                    }
//
//                    double dist = [[dict objectForKey:@"odo"] floatValue] - odometer;
//                    totalkm = totalkm + dist;
//                    odometer = [[dict objectForKey:@"odo"] floatValue];
//                    double costPerKm = totalCost/totalkm;
//                    [graph.xaxis addObject:[NSString stringWithFormat:@"%.2f",costPerKm]];
//
//                }
//                index = index+1;
//            }
//
//            graph.yaxisstring = @"Cost";
//            graph.titlestring = stringval2;
//            graph.modalPresentationStyle = UIModalPresentationFullScreen;
//            [self.navigationController pushViewController:graph animated:YES];
        }

        //Service Cost/day
        if([[self.section3 objectAtIndex:indexPath.row]isEqualToString:NSLocalizedString(@"scpd_tv", @"Service Cost/Day")]){

            [self showPerMileServicePerDayGraph];
//            GraphViewController *graph = (GraphViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"graph"];
//            graph.xaxis =[[NSMutableArray alloc]init];
//            graph.yaxis =[[NSMutableArray alloc]init];
//
//            NSNumber *cost = 0;
//
//            NSMutableDictionary *dataDict = [[NSMutableDictionary alloc] init];
//            NSMutableArray *dataArray = [[NSMutableArray alloc] init];
//
//            NSDateFormatter *thisFormater=[[NSDateFormatter alloc] init];
//            [thisFormater setDateFormat:@"dd/MMM/yyyy"];
//
//            BOOL firstServiceFound = false;
//            for(T_Fuelcons *fillup in self.servicearray)
//            {
//                NSString *datevalue = [thisFormater stringFromDate:fillup.stringDate];
//                cost = fillup.cost;
//                if(!firstServiceFound){
//
//                    if([fillup.type integerValue]==1){
//
//                        firstServiceFound = true;
//                        [dataDict setObject:fillup.type forKey:@"type"];
//                        [dataDict setObject:datevalue forKey:@"date"];
//                        [dataDict setValue:cost forKey:@"cost"];
//                        [dataArray addObject:[dataDict mutableCopy]];
//                        [dataDict removeAllObjects];
//
//                    }else{
//                        continue;
//                    }
//                }else{
//
//                    [dataDict setObject:fillup.type forKey:@"type"];
//                    [dataDict setObject:datevalue forKey:@"date"];
//                    [dataDict setValue:cost forKey:@"cost"];
//                    [dataArray addObject:[dataDict mutableCopy]];
//                    [dataDict removeAllObjects];
//                }
//
//            }
//
//            double totalCost = 0;
//            int index = 0;
//            NSInteger days;
//            NSString *datevalue;
//            for(NSDictionary *dict in dataArray){
//
//                if (index == 0){
//                    datevalue = [dict objectForKey:@"date"];
//                    days = 1;
//
//                    if(datevalue != nil){
//                        [graph.yaxis addObject:datevalue];
//
//                    }
//                }else{
//
//                    NSString *date2value = [dict objectForKey:@"date"];
//
//                    days = [self numberOfDaysBetween:datevalue and:date2value]+1;
//
//                    if(datevalue != nil){
//                        [graph.yaxis addObject:date2value];
//
//                    }
//                }
//
//                int recordType = [[dict objectForKey:@"type"] intValue];
//
//                if(recordType==1){
//
//                    double cost = [[dict objectForKey:@"cost"] floatValue];
//
//                    totalCost = totalCost + cost;
//                }
//
//                double costPerKm = totalCost/days;
//                NSLog(@"%.2f",totalCost);
//                NSLog(@"%li",(long)days);
//                NSLog(@"%.2f",costPerKm);
//                [graph.xaxis addObject:[NSString stringWithFormat:@"%.2f",costPerKm]];
//
//                index = index+1;
//            }
//
//            graph.yaxisstring = @"Cost";
//            graph.titlestring = NSLocalizedString(@"scpd_tv", @"Service Cost/Day");
//            graph.modalPresentationStyle = UIModalPresentationFullScreen;
//            [self.navigationController pushViewController:graph animated:YES];
        }

    }else if(indexPath.section==3){

        //Expenses cost/km running is default
        if([[self.section4 objectAtIndex:indexPath.row] isEqualToString:stringval3]){

            [self showRunningExpensePerDistGraph];
//            GraphViewController *graph = (GraphViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"graph"];
//            graph.xaxis =[[NSMutableArray alloc]init];
//            graph.yaxis =[[NSMutableArray alloc]init];
//
//            NSNumber *odo = 0;
//            NSNumber *dist = 0;
//            NSNumber *cost = 0;
//
//            NSMutableDictionary *dataDict = [[NSMutableDictionary alloc] init];
//            NSMutableArray *dataArray = [[NSMutableArray alloc] init];
//
//            //NSLog(@"self.servicearray:- %@",self.servicearray);
//            //TODO: check if correct values as changed from servicearray
//            BOOL firstExpenseFound = false;
//            for(T_Fuelcons *fillup in self.expensearray)//here
//            {
//                if(!firstExpenseFound){
//
//                    if([fillup.type integerValue]==2){
//                        firstExpenseFound = true;
//                        NSString *datevalue = [formater stringFromDate:fillup.stringDate];
//                        odo = fillup.odo;
//                        dist = fillup.dist;
//                        cost = fillup.cost;
//
//                        [dataDict setObject:fillup.type forKey:@"type"];
//                        [dataDict setObject:datevalue forKey:@"date"];
//                        [dataDict setValue:odo forKey:@"odo"];
//                        [dataDict setValue:cost forKey:@"cost"];
//                        [dataArray addObject:[dataDict mutableCopy]];
//                        [dataDict removeAllObjects];
//                    }else{
//                        continue;
//                    }
//                }else{
//
//                    NSString *datevalue = [formater stringFromDate:fillup.stringDate];
//                    odo = fillup.odo;
//                    dist = fillup.dist;
//                    cost = fillup.cost;
//
//                    [dataDict setObject:fillup.type forKey:@"type"];
//                    [dataDict setObject:datevalue forKey:@"date"];
//                    [dataDict setValue:odo forKey:@"odo"];
//                    [dataDict setValue:cost forKey:@"cost"];
//                    [dataArray addObject:[dataDict mutableCopy]];
//                    [dataDict removeAllObjects];
//                }
//
//            }
//
//            int index = 0;
//            double totalCost = 0;
//            double totalkm = 0;
//            double serOdo=0;
//            double odometer = 0;
//            for(NSDictionary *dict in dataArray){
//
//                if(index == 0){
//
//                    serOdo = [[dict objectForKey:@"odo"] floatValue];
//                    totalCost = [[dict objectForKey:@"cost"] floatValue];
//                }
//                else if(index == 1){
//
//                    NSString *datevalue = [dict objectForKey:@"date"];
//
//                    if(datevalue != nil){
//                        [graph.yaxis addObject:datevalue];
//
//                    }
//
//                    int recordType = [[dict objectForKey:@"type"] intValue];
//                    if(recordType == 2){
//
//                        double cost = [[dict objectForKey:@"cost"] floatValue];
//                        totalCost = totalCost + cost;
//                    }
//
//                    odometer = [[dict objectForKey:@"odo"] floatValue];
//                    double dist = odometer - serOdo;
//                    totalkm = totalkm + dist;
//
//                    double costPerKm = totalCost/totalkm;
//                    NSLog(@"%.2f",totalCost);
//                    NSLog(@"%.2f",totalkm);
//                    NSLog(@"%.2f",costPerKm);
//                    [graph.xaxis addObject:[NSString stringWithFormat:@"%.2f",costPerKm]];
//
//                }else if(index > 1){
//
//                    NSString *datevalue = [dict objectForKey:@"date"];
//
//                    if(datevalue != nil){
//                        [graph.yaxis addObject:datevalue];
//
//                    }
//
//                    int recordType = [[dict objectForKey:@"type"] intValue];
//                    if(recordType == 1){
//
//                        double cost = [[dict objectForKey:@"cost"] floatValue];
//                        totalCost = totalCost + cost;
//                    }
//
//                    double dist = [[dict objectForKey:@"odo"] floatValue] - odometer;
//                    totalkm = totalkm + dist;
//                    odometer = [[dict objectForKey:@"odo"] floatValue];
//                    double costPerKm = totalCost/totalkm;
//                    NSLog(@"%.2f",totalCost);
//                    NSLog(@"%.2f",totalkm);
//                    NSLog(@"%.2f",costPerKm);
//                    [graph.xaxis addObject:[NSString stringWithFormat:@"%.2f",costPerKm]];
//
//                }
//                index = index+1;
//            }
//
//            graph.yaxisstring = @"Cost";
//            graph.titlestring = stringval3;
//            graph.modalPresentationStyle = UIModalPresentationFullScreen;
//            [self.navigationController pushViewController:graph animated:YES];
        }

        //Expense cost/day
        if([[self.section4 objectAtIndex:indexPath.row]isEqualToString:NSLocalizedString(@"ecpd_tv", @"Other Expenses/Day")]){

            [self showPerMileExpensePerDayGraph];
//            GraphViewController *graph = (GraphViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"graph"];
//            graph.xaxis =[[NSMutableArray alloc]init];
//            graph.yaxis =[[NSMutableArray alloc]init];
//
//            NSNumber *cost = 0;
//
//            NSMutableDictionary *dataDict = [[NSMutableDictionary alloc] init];
//            NSMutableArray *dataArray = [[NSMutableArray alloc] init];
//
//            NSDateFormatter *thisFormater=[[NSDateFormatter alloc] init];
//            [thisFormater setDateFormat:@"dd/MMM/yyyy"];
//
//            BOOL firstServiceFound = false;
//            for(T_Fuelcons *fillup in self.servicearray)
//            {
//                NSString *datevalue = [thisFormater stringFromDate:fillup.stringDate];
//                cost = fillup.cost;
//                if(!firstServiceFound){
//
//                    if([fillup.type integerValue]==2){
//
//                        firstServiceFound = true;
//                        [dataDict setObject:fillup.type forKey:@"type"];
//                        [dataDict setObject:datevalue forKey:@"date"];
//                        [dataDict setValue:cost forKey:@"cost"];
//                        [dataArray addObject:[dataDict mutableCopy]];
//                        [dataDict removeAllObjects];
//
//                    }else{
//                        continue;
//                    }
//                }else{
//
//                    [dataDict setObject:fillup.type forKey:@"type"];
//                    [dataDict setObject:datevalue forKey:@"date"];
//                    [dataDict setValue:cost forKey:@"cost"];
//                    [dataArray addObject:[dataDict mutableCopy]];
//                    [dataDict removeAllObjects];
//                }
//
//            }
//
//            double totalCost = 0;
//            int index = 0;
//            NSInteger days;
//            NSString *datevalue;
//            for(NSDictionary *dict in dataArray){
//
//                if (index == 0){
//                    datevalue = [dict objectForKey:@"date"];
//                    days = 1;
//
//                    if(datevalue != nil){
//                        [graph.yaxis addObject:datevalue];
//
//                    }
//                }else{
//
//                    NSString *date2value = [dict objectForKey:@"date"];
//
//                    days = [self numberOfDaysBetween:datevalue and:date2value]+1;
//
//                    if(datevalue != nil){
//                        [graph.yaxis addObject:date2value];
//
//                    }
//                }
//
//                int recordType = [[dict objectForKey:@"type"] intValue];
//
//                if(recordType==2){
//
//                    double cost = [[dict objectForKey:@"cost"] floatValue];
//
//                    totalCost = totalCost + cost;
//                }
//
//                double costPerKm = totalCost/days;
//                NSLog(@"%.2f",totalCost);
//                NSLog(@"%li",(long)days);
//                NSLog(@"%.2f",costPerKm);
//                [graph.xaxis addObject:[NSString stringWithFormat:@"%.2f",costPerKm]];
//
//                index = index+1;
//            }
//
//            graph.yaxisstring = @"Cost";
//            graph.titlestring = NSLocalizedString(@"ecpd_tv", @"Other Expenses/Day");
//            graph.modalPresentationStyle = UIModalPresentationFullScreen;
//            [self.navigationController pushViewController:graph animated:YES];
        }

    }
    
    //For Trips
    //Dist by Type
    else if (indexPath.section == 4 && [[self.section5 objectAtIndex:indexPath.row] isEqualToString:newStr1])
        
    {
        
        BarGraphViewController *barchart = [self.storyboard instantiateViewControllerWithIdentifier:@"bargraph1"];
        barchart.dataArray =[[NSMutableArray alloc]initWithArray:self.tripTypeArray];
        barchart.values = self.distByTypeArr;
        barchart.barChartType = @3; // Fill-ups/month
        barchart.title = NSLocalizedString(@"trip_dist_by_type_graph_name", @"Distance By Trip Type");
        barchart.modalPresentationStyle = UIModalPresentationFullScreen;
        [self.navigationController pushViewController:barchart animated:YES];
        
    }
    
    else if (indexPath.section == 4 && [[self.section5 objectAtIndex:indexPath.row] isEqualToString:newStr2])
        
    {
        
        BarGraphViewController *barchart = [self.storyboard instantiateViewControllerWithIdentifier:@"bargraph1"];
        barchart.dataArray =[[NSMutableArray alloc]initWithArray:self.tripTypeArray];
        barchart.values = self.dednByTypeArr;
        barchart.barChartType = @4; // Fill-ups/month
        barchart.title = NSLocalizedString(@"trip_tax_ded_by_type_graph_name", @"Deduction By Trip Type");
        barchart.modalPresentationStyle = UIModalPresentationFullScreen;
        [self.navigationController pushViewController:barchart animated:YES];
        
    }

}

-(void)showRunningFuelPerDistGraph{

    fuelPerDistBtnPickerView.hidden = true;
    NSDateFormatter *formater=[[NSDateFormatter alloc] init];
    [formater setDateFormat:@"dd/MMM"];

    NSString *distString;
    if([[[NSUserDefaults standardUserDefaults]objectForKey:@"dist_unit"] isEqualToString:NSLocalizedString(@"disp_miles", @"Miles")])
    {
        distString = NSLocalizedString(@"mi", @"mi");
    }

    else
    {
        distString= NSLocalizedString(@"kms", @"km");
    }

    NSString *stringval1 =[NSString stringWithFormat:@"%@%@",NSLocalizedString(@"cost_tv", @"Fuel cost/"), distString];

    GraphViewController *graph = (GraphViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"graph"];
    graph.xaxis =[[NSMutableArray alloc]init];
    graph.yaxis =[[NSMutableArray alloc]init];

    NSMutableDictionary *dataDict = [[NSMutableDictionary alloc] init];
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];


    for(T_Fuelcons *fillup in allTypeArray){

        if([fillup.type integerValue] != 3){

            NSString *datevalue = [formater stringFromDate:fillup.stringDate];
            [dataDict setObject:datevalue forKey:@"date"];
            [dataDict setValue:fillup.odo forKey:@"odo"];

            if([fillup.type integerValue] == 0){

                [dataDict setValue:fillup.cost forKey:@"cost"];
            }else{

                [dataDict setValue:0 forKey:@"cost"];
            }

            [dataArray addObject:[dataDict mutableCopy]];
            [dataDict removeAllObjects];
        }
    }

    double minOdo = 0;
    int indx = 0;
    double totalCost = 0;

    for(NSDictionary *dict in dataArray){

        if(indx == 0){

            minOdo = [[dict valueForKey:@"odo"] floatValue];
        }

        NSString *datevalue = [dict objectForKey:@"date"];

        if(datevalue != nil){
            [graph.yaxis addObject:datevalue];
        }

        double cost = [[dict valueForKey:@"cost"] floatValue];
        double odo = [[dict valueForKey:@"odo"] floatValue];

        totalCost = totalCost + cost;
        double diffDist = odo - minOdo;

        double costPerDist = totalCost / diffDist;

        if(!isnan(costPerDist)){

            [graph.xaxis addObject:[NSString stringWithFormat:@"%.2f",costPerDist]];

        }else{

            [graph.xaxis addObject:[NSString stringWithFormat:@"%.2f",0.0]];
        }

        indx += 1;

    }

    graph.yaxisstring = @"Cost";
    graph.titlestring = stringval1;
    graph.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController pushViewController:graph animated:YES];

}

-(void)showPerMileFuelPerDistGraph{

    fuelPerDistBtnPickerView.hidden = true;
    NSDateFormatter *formater=[[NSDateFormatter alloc] init];
    [formater setDateFormat:@"dd/MMM"];

    NSString *distString;
    if([[[NSUserDefaults standardUserDefaults]objectForKey:@"dist_unit"] isEqualToString:NSLocalizedString(@"disp_miles", @"Miles")])
    {
        distString = NSLocalizedString(@"mi", @"mi");
    }

    else
    {
        distString= NSLocalizedString(@"kms", @"km");
    }

    NSString *stringval1 =[NSString stringWithFormat:@"%@%@",NSLocalizedString(@"cost_tv", @"Fuel cost/"), distString];

    GraphViewController *graph = (GraphViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"graph"];
    graph.xaxis =[[NSMutableArray alloc]init];
    graph.yaxis =[[NSMutableArray alloc]init];

    NSNumber *odo = 0;
    NSNumber *dist = 0;
    NSNumber *cost = 0;

    NSMutableDictionary *dataDict = [[NSMutableDictionary alloc] init];
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];

    for(T_Fuelcons *fillup in self.filluparray)
    {
        NSString *datevalue = [formater stringFromDate:fillup.stringDate];
        odo = fillup.odo;
        dist = fillup.dist;
        cost = fillup.cost;

        [dataDict setObject:datevalue forKey:@"date"];
        [dataDict setValue:odo forKey:@"odo"];
        [dataDict setValue:dist forKey:@"dist"];
        [dataDict setValue:cost forKey:@"cost"];
        [dataArray addObject:[dataDict mutableCopy]];
        [dataDict removeAllObjects];
    }

    int index = 0;
    for(NSDictionary *dict in dataArray){

        if(index > 0){

            NSString *datevalue = [dict objectForKey:@"date"];

            if(datevalue != nil){
                [graph.yaxis addObject:datevalue];

            }

            //double odo = [dict[@"odo"] floatValue];
            double dist = [[dict objectForKey:@"dist"] floatValue];
            double cost = [[dict objectForKey:@"cost"] floatValue];

            double costPerKm = cost/dist;
            [graph.xaxis addObject:[NSString stringWithFormat:@"%.2f",costPerKm]];

        }
        index = index+1;
    }

    graph.yaxisstring = @"Cost";
    graph.titlestring = stringval1;
    graph.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController pushViewController:graph animated:YES];

}

-(void)showRunningFuelPerDayGraph{

    fuelPerDayBtnPickerView.hidden = true;
    GraphViewController *graph = (GraphViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"graph"];
    graph.xaxis =[[NSMutableArray alloc]init];
    graph.yaxis =[[NSMutableArray alloc]init];

    NSNumber *cost = 0;

    NSMutableDictionary *dataDict = [[NSMutableDictionary alloc] init];
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];

    NSDateFormatter *thisFormater=[[NSDateFormatter alloc] init];
    [thisFormater setDateFormat:@"dd/MMM/yyyy"];

                              //filluparray
    for(T_Fuelcons *fillup in allTypeArray)
    {
        if([fillup.type integerValue] != 3){

            NSString *datevalue = [thisFormater stringFromDate:fillup.stringDate];
            cost = fillup.cost;

            [dataDict setObject:datevalue forKey:@"date"];
            if([fillup.type integerValue] == 0){

                [dataDict setValue:cost forKey:@"cost"];
            }
            [dataArray addObject:[dataDict mutableCopy]];
            [dataDict removeAllObjects];
        }
    }

    double totalCost = 0;
    int index = 0;
    NSInteger days;
    NSString *datevalue;
    for(NSDictionary *dict in dataArray){

        if (index == 0){
            datevalue = [dict objectForKey:@"date"];
            days = 1;

            if(datevalue != nil){
                [graph.yaxis addObject:datevalue];

            }
        }else{

            NSString *date2value = [dict objectForKey:@"date"];

            days = [self numberOfDaysBetween:datevalue and:date2value]+1;

            if(datevalue != nil){
                [graph.yaxis addObject:date2value];

            }
        }

        double cost = [[dict objectForKey:@"cost"] floatValue];

        totalCost = totalCost + cost;

        double costPerKm = totalCost/days;
        [graph.xaxis addObject:[NSString stringWithFormat:@"%.2f",costPerKm]];

        index = index+1;
    }

    graph.yaxisstring = @"Cost";
    graph.titlestring = NSLocalizedString(@"cpd_tv", @"Fuel Cost/day");
    graph.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController pushViewController:graph animated:YES];
}

-(void)showPerMileFuelPerDayGraph{

    fuelPerDayBtnPickerView.hidden = true;
    GraphViewController *graph = (GraphViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"graph"];
    graph.xaxis =[[NSMutableArray alloc]init];
    graph.yaxis =[[NSMutableArray alloc]init];

    NSNumber *cost = 0;

    NSMutableDictionary *dataDict = [[NSMutableDictionary alloc] init];
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];

    NSDateFormatter *thisFormater=[[NSDateFormatter alloc] init];
    [thisFormater setDateFormat:@"dd/MMM/yyyy"];

    for(T_Fuelcons *fillup in self.filluparray)
    {
        NSString *datevalue = [thisFormater stringFromDate:fillup.stringDate];
        cost = fillup.cost;

        [dataDict setObject:datevalue forKey:@"date"];
        [dataDict setValue:cost forKey:@"cost"];
        [dataArray addObject:[dataDict mutableCopy]];
        [dataDict removeAllObjects];
    }

    int index = 0;
    NSInteger days;
    NSString *datevalue;
    for(NSDictionary *dict in dataArray){

        if (index == 0){
            datevalue = [dict objectForKey:@"date"];
            days = 1;

            if(datevalue != nil){
                [graph.yaxis addObject:datevalue];

            }
        }else{

            NSString *date2value = [dict objectForKey:@"date"];

            days = [self numberOfDaysBetween:datevalue and:date2value]+1;
            datevalue = [dict objectForKey:@"date"];
            if(datevalue != nil){
                [graph.yaxis addObject:date2value];

            }
        }

        double cost = [[dict objectForKey:@"cost"] floatValue];

        double costPerKm = cost/days;
        [graph.xaxis addObject:[NSString stringWithFormat:@"%.2f",costPerKm]];

        index = index+1;
    }

    graph.yaxisstring = @"Cost";
    graph.titlestring = NSLocalizedString(@"cpd_tv", @"Fuel Cost/day");
    graph.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController pushViewController:graph animated:YES];
}

//Service graphs
-(void)showRunningServicePerDistGraph{

    NSDateFormatter *formater=[[NSDateFormatter alloc] init];
    [formater setDateFormat:@"dd/MMM"];

    NSString *distString;
    if([[[NSUserDefaults standardUserDefaults]objectForKey:@"dist_unit"] isEqualToString:NSLocalizedString(@"disp_miles", @"Miles")])
    {
        distString = NSLocalizedString(@"mi", @"mi");
    }

    else
    {
        distString= NSLocalizedString(@"kms", @"km");
    }

    NSString *stringval1 =[NSString stringWithFormat:@"%@%@",NSLocalizedString(@"cost_tv", @"Fuel cost/"), distString];

    GraphViewController *graph = (GraphViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"graph"];
    graph.xaxis =[[NSMutableArray alloc]init];
    graph.yaxis =[[NSMutableArray alloc]init];

    NSMutableDictionary *dataDict = [[NSMutableDictionary alloc] init];
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];


    for(T_Fuelcons *fillup in allTypeArray){

        if([fillup.type integerValue] != 3){

            NSString *datevalue = [formater stringFromDate:fillup.stringDate];
            [dataDict setObject:datevalue forKey:@"date"];
            [dataDict setValue:fillup.odo forKey:@"odo"];

            if([fillup.type integerValue] == 1){

                [dataDict setValue:fillup.cost forKey:@"cost"];
            }else{

                [dataDict setValue:0 forKey:@"cost"];
            }

            [dataArray addObject:[dataDict mutableCopy]];
            [dataDict removeAllObjects];
        }
    }

    double minOdo = 0;
    int indx = 0;
    double totalCost = 0;

    for(NSDictionary *dict in dataArray){

        if(indx == 0){

            minOdo = [[dict valueForKey:@"odo"] floatValue];
        }

        NSString *datevalue = [dict objectForKey:@"date"];

        if(datevalue != nil){
            [graph.yaxis addObject:datevalue];
        }

        double cost = [[dict valueForKey:@"cost"] floatValue];
        double odo = [[dict valueForKey:@"odo"] floatValue];

        totalCost = totalCost + cost;
        double diffDist = odo - minOdo;

        double costPerDist = totalCost / diffDist;

        if(!isnan(costPerDist)){

            [graph.xaxis addObject:[NSString stringWithFormat:@"%.2f",costPerDist]];

        }else{

            [graph.xaxis addObject:[NSString stringWithFormat:@"%.2f",0.0]];
        }

        indx += 1;

    }

    graph.yaxisstring = @"Cost";
    graph.titlestring = stringval1;
    graph.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController pushViewController:graph animated:YES];

}

//-(void)showPerMileServicePerDistGraph{
//
//    servicePerDistBtnPickerView.hidden = true;
//    NSDateFormatter *formater=[[NSDateFormatter alloc] init];
//    [formater setDateFormat:@"dd/MMM"];
//
//    NSString *distString;
//    if([[[NSUserDefaults standardUserDefaults]objectForKey:@"dist_unit"] isEqualToString:NSLocalizedString(@"disp_miles", @"Miles")])
//    {
//        distString = NSLocalizedString(@"mi", @"mi");
//    }
//
//    else
//    {
//        distString= NSLocalizedString(@"kms", @"km");
//    }
//
//    NSString *stringval1 =[NSString stringWithFormat:@"%@%@",NSLocalizedString(@"cost_tv", @"Fuel cost/"), distString];
//
//    GraphViewController *graph = (GraphViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"graph"];
//    graph.xaxis =[[NSMutableArray alloc]init];
//    graph.yaxis =[[NSMutableArray alloc]init];
//
//    NSNumber *odo = 0;
//    NSNumber *dist = 0;
//    NSNumber *cost = 0;
//
//    NSMutableDictionary *dataDict = [[NSMutableDictionary alloc] init];
//    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
//
//    for(T_Fuelcons *fillup in self.servicearray)
//    {
//        NSString *datevalue = [formater stringFromDate:fillup.stringDate];
//        odo = fillup.odo;
//        dist = fillup.dist;
//        cost = fillup.cost;
//
//        [dataDict setObject:datevalue forKey:@"date"];
//        [dataDict setValue:odo forKey:@"odo"];
//        [dataDict setValue:dist forKey:@"dist"];
//        [dataDict setValue:cost forKey:@"cost"];
//        [dataArray addObject:[dataDict mutableCopy]];
//        [dataDict removeAllObjects];
//    }
//
//    int index = 0;
//    for(NSDictionary *dict in dataArray){
//
//        if(index > 0){
//
//            NSString *datevalue = [dict objectForKey:@"date"];
//
//            if(datevalue != nil){
//                [graph.yaxis addObject:datevalue];
//
//            }
//
//            //double odo = [dict[@"odo"] floatValue];
//            double dist = [[dict objectForKey:@"dist"] floatValue];
//            double cost = [[dict objectForKey:@"cost"] floatValue];
//
//            double costPerKm = cost/dist;
//            [graph.xaxis addObject:[NSString stringWithFormat:@"%.2f",costPerKm]];
//
//        }
//        index = index+1;
//    }
//
//    graph.yaxisstring = @"Cost";
//    graph.titlestring = stringval1;
//    graph.modalPresentationStyle = UIModalPresentationFullScreen;
//    [self.navigationController pushViewController:graph animated:YES];
//
//}

//-(void)showRunningServicePerDayGraph{
//
//    servicePerDistBtnPickerView.hidden = true;
//    GraphViewController *graph = (GraphViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"graph"];
//    graph.xaxis =[[NSMutableArray alloc]init];
//    graph.yaxis =[[NSMutableArray alloc]init];
//
//    NSNumber *cost = 0;
//
//    NSMutableDictionary *dataDict = [[NSMutableDictionary alloc] init];
//    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
//
//    NSDateFormatter *thisFormater=[[NSDateFormatter alloc] init];
//    [thisFormater setDateFormat:@"dd/MMM/yyyy"];
//
//    //filluparray
//    for(T_Fuelcons *fillup in allTypeArray)
//    {
//        if([fillup.type integerValue] != 3){
//
//            NSString *datevalue = [thisFormater stringFromDate:fillup.stringDate];
//            cost = fillup.cost;
//
//            [dataDict setObject:datevalue forKey:@"date"];
//            if([fillup.type integerValue] == 1){
//
//                [dataDict setValue:cost forKey:@"cost"];
//            }
//            [dataArray addObject:[dataDict mutableCopy]];
//            [dataDict removeAllObjects];
//        }
//    }
//
//    double totalCost = 0;
//    int index = 0;
//    NSInteger days;
//    NSString *datevalue;
//    for(NSDictionary *dict in dataArray){
//
//        if (index == 0){
//            datevalue = [dict objectForKey:@"date"];
//            days = 1;
//
//            if(datevalue != nil){
//                [graph.yaxis addObject:datevalue];
//
//            }
//        }else{
//
//            NSString *date2value = [dict objectForKey:@"date"];
//
//            days = [self numberOfDaysBetween:datevalue and:date2value]+1;
//
//            if(datevalue != nil){
//                [graph.yaxis addObject:date2value];
//
//            }
//        }
//
//        double cost = [[dict objectForKey:@"cost"] floatValue];
//
//        totalCost = totalCost + cost;
//
//        double costPerKm = totalCost/days;
//        [graph.xaxis addObject:[NSString stringWithFormat:@"%.2f",costPerKm]];
//
//        index = index+1;
//    }
//
//    graph.yaxisstring = @"Cost";
//    graph.titlestring = NSLocalizedString(@"cpd_tv", @"Fuel Cost/day");
//    graph.modalPresentationStyle = UIModalPresentationFullScreen;
//    [self.navigationController pushViewController:graph animated:YES];
//}

-(void)showPerMileServicePerDayGraph{

    GraphViewController *graph = (GraphViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"graph"];
    graph.xaxis =[[NSMutableArray alloc]init];
    graph.yaxis =[[NSMutableArray alloc]init];

    NSNumber *cost = 0;

    NSMutableDictionary *dataDict = [[NSMutableDictionary alloc] init];
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];

    NSDateFormatter *thisFormater=[[NSDateFormatter alloc] init];
    [thisFormater setDateFormat:@"dd/MMM/yyyy"];

    for(T_Fuelcons *fillup in self.servicearray)
    {
        NSString *datevalue = [thisFormater stringFromDate:fillup.stringDate];
        cost = fillup.cost;

        [dataDict setObject:datevalue forKey:@"date"];
        [dataDict setValue:cost forKey:@"cost"];
        [dataArray addObject:[dataDict mutableCopy]];
        [dataDict removeAllObjects];
    }

    int index = 0;
    NSInteger days;
    NSString *datevalue;
    for(NSDictionary *dict in dataArray){

        if (index == 0){
            datevalue = [dict objectForKey:@"date"];
            days = 1;

            if(datevalue != nil){
                [graph.yaxis addObject:datevalue];

            }
        }else{

            NSString *date2value = [dict objectForKey:@"date"];

            days = [self numberOfDaysBetween:datevalue and:date2value]+1;
            datevalue = [dict objectForKey:@"date"];
            if(datevalue != nil){
                [graph.yaxis addObject:date2value];

            }
        }

        double cost = [[dict objectForKey:@"cost"] floatValue];

        double costPerKm = cost/days;
        [graph.xaxis addObject:[NSString stringWithFormat:@"%.2f",costPerKm]];

        index = index+1;
    }

    graph.yaxisstring = @"Cost";
    graph.titlestring = NSLocalizedString(@"cpd_tv", @"Fuel Cost/day");
    graph.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController pushViewController:graph animated:YES];
}

//Expense graphs
-(void)showRunningExpensePerDistGraph{

    NSDateFormatter *formater=[[NSDateFormatter alloc] init];
    [formater setDateFormat:@"dd/MMM"];

    NSString *distString;
    if([[[NSUserDefaults standardUserDefaults]objectForKey:@"dist_unit"] isEqualToString:NSLocalizedString(@"disp_miles", @"Miles")])
    {
        distString = NSLocalizedString(@"mi", @"mi");
    }

    else
    {
        distString= NSLocalizedString(@"kms", @"km");
    }

    NSString *stringval1 =[NSString stringWithFormat:@"%@%@",NSLocalizedString(@"cost_tv", @"Fuel cost/"), distString];

    GraphViewController *graph = (GraphViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"graph"];
    graph.xaxis =[[NSMutableArray alloc]init];
    graph.yaxis =[[NSMutableArray alloc]init];

    NSMutableDictionary *dataDict = [[NSMutableDictionary alloc] init];
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];


    for(T_Fuelcons *fillup in allTypeArray){

        if([fillup.type integerValue] != 3){

            NSString *datevalue = [formater stringFromDate:fillup.stringDate];
            [dataDict setObject:datevalue forKey:@"date"];
            [dataDict setValue:fillup.odo forKey:@"odo"];

            if([fillup.type integerValue] == 2){

                [dataDict setValue:fillup.cost forKey:@"cost"];
            }else{

                [dataDict setValue:0 forKey:@"cost"];
            }

            [dataArray addObject:[dataDict mutableCopy]];
            [dataDict removeAllObjects];
        }
    }

    double minOdo = 0;
    int indx = 0;
    double totalCost = 0;

    for(NSDictionary *dict in dataArray){

        if(indx == 0){

            minOdo = [[dict valueForKey:@"odo"] floatValue];
        }

        NSString *datevalue = [dict objectForKey:@"date"];

        if(datevalue != nil){
            [graph.yaxis addObject:datevalue];
        }

        double cost = [[dict valueForKey:@"cost"] floatValue];
        double odo = [[dict valueForKey:@"odo"] floatValue];

        totalCost = totalCost + cost;
        double diffDist = odo - minOdo;

        double costPerDist = totalCost / diffDist;

        if(!isnan(costPerDist)){

            [graph.xaxis addObject:[NSString stringWithFormat:@"%.2f",costPerDist]];

        }else{

            [graph.xaxis addObject:[NSString stringWithFormat:@"%.2f",0.0]];
        }

        indx += 1;

    }

    graph.yaxisstring = @"Cost";
    graph.titlestring = stringval1;
    graph.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController pushViewController:graph animated:YES];

}

//-(void)showPerMileExpensePerDistGraph{
//
//    expensePerDistBtnPickerView.hidden = true;
//    NSDateFormatter *formater=[[NSDateFormatter alloc] init];
//    [formater setDateFormat:@"dd/MMM"];
//
//    NSString *distString;
//    if([[[NSUserDefaults standardUserDefaults]objectForKey:@"dist_unit"] isEqualToString:NSLocalizedString(@"disp_miles", @"Miles")])
//    {
//        distString = NSLocalizedString(@"mi", @"mi");
//    }
//
//    else
//    {
//        distString= NSLocalizedString(@"kms", @"km");
//    }
//
//    NSString *stringval1 =[NSString stringWithFormat:@"%@%@",NSLocalizedString(@"cost_tv", @"Fuel cost/"), distString];
//
//    GraphViewController *graph = (GraphViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"graph"];
//    graph.xaxis =[[NSMutableArray alloc]init];
//    graph.yaxis =[[NSMutableArray alloc]init];
//
//    NSNumber *odo = 0;
//    NSNumber *dist = 0;
//    NSNumber *cost = 0;
//
//    NSMutableDictionary *dataDict = [[NSMutableDictionary alloc] init];
//    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
//
//    for(T_Fuelcons *fillup in self.expensearray)
//    {
//        NSString *datevalue = [formater stringFromDate:fillup.stringDate];
//        odo = fillup.odo;
//        dist = fillup.dist;
//        cost = fillup.cost;
//
//        [dataDict setObject:datevalue forKey:@"date"];
//        [dataDict setValue:odo forKey:@"odo"];
//        [dataDict setValue:dist forKey:@"dist"];
//        [dataDict setValue:cost forKey:@"cost"];
//        [dataArray addObject:[dataDict mutableCopy]];
//        [dataDict removeAllObjects];
//    }
//
//    int index = 0;
//    for(NSDictionary *dict in dataArray){
//
//        if(index > 0){
//
//            NSString *datevalue = [dict objectForKey:@"date"];
//
//            if(datevalue != nil){
//                [graph.yaxis addObject:datevalue];
//
//            }
//
//            //double odo = [dict[@"odo"] floatValue];
//            double dist = [[dict objectForKey:@"dist"] floatValue];
//            double cost = [[dict objectForKey:@"cost"] floatValue];
//
//            double costPerKm = cost/dist;
//            [graph.xaxis addObject:[NSString stringWithFormat:@"%.2f",costPerKm]];
//
//        }
//        index = index+1;
//    }
//
//    graph.yaxisstring = @"Cost";
//    graph.titlestring = stringval1;
//    graph.modalPresentationStyle = UIModalPresentationFullScreen;
//    [self.navigationController pushViewController:graph animated:YES];
//
//}

//-(void)showRunningExpensePerDayGraph{
//
//    expensePerDistBtnPickerView.hidden = true;
//    GraphViewController *graph = (GraphViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"graph"];
//    graph.xaxis =[[NSMutableArray alloc]init];
//    graph.yaxis =[[NSMutableArray alloc]init];
//
//    NSNumber *cost = 0;
//
//    NSMutableDictionary *dataDict = [[NSMutableDictionary alloc] init];
//    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
//
//    NSDateFormatter *thisFormater=[[NSDateFormatter alloc] init];
//    [thisFormater setDateFormat:@"dd/MMM/yyyy"];
//
//    //filluparray
//    for(T_Fuelcons *fillup in allTypeArray)
//    {
//        if([fillup.type integerValue] != 3){
//
//            NSString *datevalue = [thisFormater stringFromDate:fillup.stringDate];
//            cost = fillup.cost;
//
//            [dataDict setObject:datevalue forKey:@"date"];
//            if([fillup.type integerValue] == 2){
//
//                [dataDict setValue:cost forKey:@"cost"];
//            }
//            [dataArray addObject:[dataDict mutableCopy]];
//            [dataDict removeAllObjects];
//        }
//    }
//
//    double totalCost = 0;
//    int index = 0;
//    NSInteger days;
//    NSString *datevalue;
//    for(NSDictionary *dict in dataArray){
//
//        if (index == 0){
//            datevalue = [dict objectForKey:@"date"];
//            days = 1;
//
//            if(datevalue != nil){
//                [graph.yaxis addObject:datevalue];
//
//            }
//        }else{
//
//            NSString *date2value = [dict objectForKey:@"date"];
//
//            days = [self numberOfDaysBetween:datevalue and:date2value]+1;
//
//            if(datevalue != nil){
//                [graph.yaxis addObject:date2value];
//
//            }
//        }
//
//        double cost = [[dict objectForKey:@"cost"] floatValue];
//
//        totalCost = totalCost + cost;
//
//        double costPerKm = totalCost/days;
//        [graph.xaxis addObject:[NSString stringWithFormat:@"%.2f",costPerKm]];
//
//        index = index+1;
//    }
//
//    graph.yaxisstring = @"Cost";
//    graph.titlestring = NSLocalizedString(@"cpd_tv", @"Fuel Cost/day");
//    graph.modalPresentationStyle = UIModalPresentationFullScreen;
//    [self.navigationController pushViewController:graph animated:YES];
//}

-(void)showPerMileExpensePerDayGraph{

    GraphViewController *graph = (GraphViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"graph"];
    graph.xaxis =[[NSMutableArray alloc]init];
    graph.yaxis =[[NSMutableArray alloc]init];

    NSNumber *cost = 0;

    NSMutableDictionary *dataDict = [[NSMutableDictionary alloc] init];
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];

    NSDateFormatter *thisFormater=[[NSDateFormatter alloc] init];
    [thisFormater setDateFormat:@"dd/MMM/yyyy"];

    for(T_Fuelcons *fillup in self.expensearray)
    {
        NSString *datevalue = [thisFormater stringFromDate:fillup.stringDate];
        cost = fillup.cost;

        [dataDict setObject:datevalue forKey:@"date"];
        [dataDict setValue:cost forKey:@"cost"];
        [dataArray addObject:[dataDict mutableCopy]];
        [dataDict removeAllObjects];
    }

    int index = 0;
    NSInteger days;
    NSString *datevalue;
    for(NSDictionary *dict in dataArray){

        if (index == 0){
            datevalue = [dict objectForKey:@"date"];
            days = 1;

            if(datevalue != nil){
                [graph.yaxis addObject:datevalue];

            }
        }else{

            NSString *date2value = [dict objectForKey:@"date"];

            days = [self numberOfDaysBetween:datevalue and:date2value]+1;
            datevalue = [dict objectForKey:@"date"];
            if(datevalue != nil){
                [graph.yaxis addObject:date2value];

            }
        }

        double cost = [[dict objectForKey:@"cost"] floatValue];

        double costPerKm = cost/days;
        [graph.xaxis addObject:[NSString stringWithFormat:@"%.2f",costPerKm]];

        index = index+1;
    }

    graph.yaxisstring = @"Cost";
    graph.titlestring = NSLocalizedString(@"cpd_tv", @"Fuel Cost/day");
    graph.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController pushViewController:graph animated:YES];
}

- (NSInteger)numberOfDaysBetween:(NSString *)startDate and:(NSString *)endDate {

    NSDateFormatter *f = [[NSDateFormatter alloc] init];
    [f setDateFormat:@"dd/MM/yyyy"];
    NSDate *start = [f dateFromString:startDate];
    NSDate *end = [f dateFromString:endDate];

    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorianCalendar components:NSCalendarUnitDay
                                                        fromDate:start
                                                          toDate:end
                                                         options:0];

    return [components day];
}

-(void)fetchTripStats:(NSString*) filterString
{
    //NIKHIL BUG_156 context changed to global
    NSManagedObjectContext *context = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSError *err;
    NSUserDefaults *Def =[NSUserDefaults standardUserDefaults];
    NSString *comparestring = [NSString stringWithFormat:@"%@",[Def objectForKey:@"fillupid"]];
    
    NSFetchRequest *requset=[[NSFetchRequest alloc] initWithEntityName:@"T_Trip"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"tripComplete == 1 AND vehId = %@", comparestring];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"depOdo"
                                                                   ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [requset setPredicate:predicate];
    [requset setSortDescriptors:sortDescriptors];
    // [requset setResultType:NSDictionaryResultType];
    
    NSArray *datavaluefilter = [[NSArray alloc]init];
    NSMutableArray *datavalue= [[NSMutableArray alloc]init];
    datavaluefilter =[context  executeFetchRequest:requset error:&err];
    NSDateFormatter *Uniformater=[[NSDateFormatter alloc] init];
    [Uniformater setDateFormat:@"dd MMM yyyy"];
    NSDateFormatter *formaterMON=[[NSDateFormatter alloc] init];
    [formaterMON setDateFormat:@"MMM"];
    
    if([filterString isEqualToString:NSLocalizedString(@"graph_date_range_0", @"All Time")])
    {
        datavalue = [[NSMutableArray alloc]initWithArray:datavaluefilter];
    }
    
    else if([filterString isEqualToString:NSLocalizedString(@"graph_date_range_1", @"This Month")])
    {
        NSDateFormatter *formater=[[NSDateFormatter alloc] init];
        [formater setDateFormat:@"MM"];
        NSDateFormatter *formater1=[[NSDateFormatter alloc] init];
        [formater1 setDateFormat:@"yyyy"];
        NSString *currentmonth = [formater stringFromDate:[NSDate date]];
        NSString *currentyear = [formater1 stringFromDate:[NSDate date]];
        
        for(T_Trip *trip in datavaluefilter)
        {
            if([[formater stringFromDate:trip.depDate] isEqualToString:currentmonth] && [[formater1 stringFromDate:trip.depDate] isEqualToString:currentyear])
            {
                [datavalue addObject: trip];
            }
        }
        
        
    }
    
    else if([filterString isEqualToString:NSLocalizedString(@"graph_date_range_2", @"Last Month")])
    {
        NSDateFormatter *formater=[[NSDateFormatter alloc] init];
        [formater setDateFormat:@"M"];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *comps = [NSDateComponents new];
        comps.month = -1;
        comps.day   = -1;
        NSDate *date = [calendar dateByAddingComponents:comps toDate:[NSDate date] options:0];
        NSDateComponents *components = [calendar components:NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date];
        NSDateFormatter *formater1=[[NSDateFormatter alloc] init];
        [formater1 setDateFormat:@"yyyy"];
        NSString *currentyear = [formater1 stringFromDate:[NSDate date]];
        
        NSDate *today = [[NSDate alloc] init];
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
        [offsetComponents setYear:-1];
        NSDate *lastYear = [gregorian dateByAddingComponents:offsetComponents toDate:today options:0];
        
        NSDateFormatter *df = [[NSDateFormatter alloc] init] ;
        NSString *monthName = [[df monthSymbols] objectAtIndex:(components.month-1)];
        
        // NSLog(@"Current Date is: %@ ", [formater stringFromDate:[NSDate date]]);
        
        if(components.month!=12)
        {
            for(T_Trip *trip in datavaluefilter)
            {
                // NSLog(@"[formater stringFromDate:fuel.stringDate]: %@ ,%ld", [formater stringFromDate:fuel.stringDate], components.month);
                
                if([[formater stringFromDate:trip.depDate] isEqualToString:[NSString stringWithFormat:@"%ld",(long)components.month]] && [[formater1 stringFromDate:trip.depDate] isEqualToString:currentyear])
                {
                    [datavalue addObject: trip];
                    
                }
            }
            
            
        }
        
        else
        {
            for(T_Trip *trip in datavaluefilter)
            {
                if([[formater stringFromDate:trip.depDate] isEqualToString:[NSString stringWithFormat:@"%ld",(long)components.month]] && [[formater1 stringFromDate:trip.depDate] isEqualToString:[formater1 stringFromDate:lastYear]])
                {
                    [datavalue addObject: trip];
                    
                    
                }
            }
            
        }
        
    }
    
    else if([filterString isEqualToString:NSLocalizedString(@"graph_date_range_3", @"This Year")])
    {
        NSDateFormatter *formater=[[NSDateFormatter alloc] init];
        [formater setDateFormat:@"yyyy"];
        NSString *currentmonth = [formater stringFromDate:[NSDate date]];
        for(T_Trip *trip in datavaluefilter)
        {
            if([[formater stringFromDate:trip.depDate] isEqualToString:currentmonth])
            {
                [datavalue addObject: trip];
                
            }
        }
    }
    
    else
    {
        NSDateFormatter *formater=[[NSDateFormatter alloc] init];
        [formater setDateFormat:@"dd-MM-yyyy"];
        for(T_Trip *trip in datavaluefilter)
        {
            if(([[formater dateFromString:self.startdate.text] compare:[formater dateFromString:[formater stringFromDate:trip.depDate]]] == NSOrderedAscending && [[formater dateFromString:self.enddate.text] compare:[formater dateFromString:[formater stringFromDate:trip.depDate]]] == NSOrderedDescending) || ([[formater dateFromString:self.startdate.text] compare:[formater dateFromString:[formater stringFromDate:trip.depDate]]] == NSOrderedSame) || ([[formater dateFromString:self.enddate.text] compare:[formater dateFromString:[formater stringFromDate:trip.depDate]]] == NSOrderedSame))
            {
                
                [datavalue addObject: trip];
                
                
            }
        }
        
        
    }
    
    
    
    
    
    NSString *dist_unit,*cost_unit;
    
    if([[[NSUserDefaults standardUserDefaults]objectForKey:@"dist_unit"] isEqualToString:NSLocalizedString(@"disp_miles", @"Miles")])
    {
        dist_unit = NSLocalizedString(@"mi", @"mi");
    }
    
    else
    {
        dist_unit = NSLocalizedString(@"kms", @"km");
    }
    
    
    NSArray *currArray = [[[NSUserDefaults standardUserDefaults]objectForKey:@"curr_unit"] componentsSeparatedByString:@"-"];
    NSString *unit = [currArray lastObject];
    cost_unit = unit;
    
    
    NSInteger totTrips=0;
    float totTripDist=0.0;
    float totTripDedn=0.0;
    float distByType=0.0;
    float dednByType=0.0;
    self.distByTypeArr = [[NSMutableArray alloc]init];
    self.dednByTypeArr = [[NSMutableArray alloc]init];
    self.tripTypeArray = [[NSMutableArray alloc] init];
    NSMutableArray* tripTypeDictArray = [[NSMutableArray alloc] init];
    self.totTripStats =[[NSMutableArray alloc]init];
    
    
    totTrips = [datavalue count];
    if (totTrips != 0) {
        //Total Trips
        [self.totTripStats addObject:[NSString stringWithFormat:@"%ld",(long)totTrips ]];
        
        //Total Trip distance & Total trip Dedn
        for (T_Trip *trip in datavalue) {
            
            // NSLog(@"[trip.taxDedn floatValue] :%f",[trip.taxDedn floatValue] );
            
            float distance = [trip.arrOdo floatValue] - [trip.depOdo floatValue];
            float taxDedc = [trip.taxDedn floatValue];
            
            totTripDist = totTripDist + distance;
            totTripDedn = totTripDedn + taxDedc;
            
            NSString* tripType = trip.tripType;
            
            //Get all unique trip types
            if (![self.tripTypeArray containsObject:tripType]) {
                [self.tripTypeArray  addObject:tripType];
                NSMutableDictionary* tripTypeDict = [[NSMutableDictionary alloc] init];
                [tripTypeDict setValue:tripType forKey:@"type"];
                
                [tripTypeDictArray addObject:tripTypeDict];
            }
            
            
        }
        
        // ADD Total Trip distance
        [self.totTripStats addObject:[NSString stringWithFormat:@"%.2f %@",totTripDist, dist_unit]];
        
        //add Total trip Dedn
        [self.totTripStats addObject:[NSString stringWithFormat:@"%.2f %@",totTripDedn , cost_unit]];
        
        
        
        
        //To aggregate the distance and dedn by unique trip types
        for (T_Trip *trip in datavalue) {
            
            for (NSString* type in self.tripTypeArray) {
                if ([trip.tripType isEqualToString:type]) {
                    
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type == %@", type];
                    NSArray* dict = [tripTypeDictArray filteredArrayUsingPredicate:predicate];
                    
                    float distance = [trip.arrOdo floatValue] - [trip.depOdo floatValue];
                    float taxDedc = [trip.taxDedn floatValue];
                    
                    distByType = [[[dict firstObject] valueForKey:@"distance"] floatValue] + distance;
                    dednByType = [[[dict firstObject] valueForKey:@"tax"] floatValue] + taxDedc;
                    
                    [[dict firstObject] setValue:[NSNumber numberWithFloat: distByType] forKey:@"distance"];
                    [[dict firstObject] setValue:[NSNumber numberWithFloat: dednByType] forKey:@"tax"];
                    
                }
            }
            
            
        }
        
        //Using KVC
        
        NSNumber *max = [tripTypeDictArray valueForKeyPath:@"@max.distance"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"distance == %@", max];
        NSArray* dict = [tripTypeDictArray filteredArrayUsingPredicate:predicate];
        
        distByType = [max floatValue];
        dednByType = [[[dict firstObject] valueForKey:@"tax"] floatValue];
        
        
        //get all distances in an Array for the graph
        self.distByTypeArr = [tripTypeDictArray valueForKey:@"distance"];
        
        //get all tax dedn in an Array for the graph
        self.dednByTypeArr = [tripTypeDictArray valueForKey:@"tax"];
        
        
        //Add  Distance by Type
        [self.totTripStats addObject:[NSString stringWithFormat:@"%.2f %@",distByType, dist_unit]];
        
        //Add Deduction by Type
        [self.totTripStats addObject:[NSString stringWithFormat:@"%.2f %@",dednByType , cost_unit]];
        
        
        //if column not selected from the custom Dashboard setting
        if (![[self.section5 objectAtIndex:3] isEqualToString:@""]) {
            newStr1 = [[NSString stringWithFormat:@"%@ (", NSLocalizedString(@"trip_by_type_tv", @"Dist by type")]  stringByAppendingString:[[[dict firstObject] valueForKey:@"type"] stringByAppendingString:@")"]];
            [ self.section5 replaceObjectAtIndex:3 withObject:newStr1];
            
        }
        //if column not selected from the custom Dashboard setting
        if (![[self.section5 objectAtIndex:4] isEqualToString:@""]) {
            newStr2 = [[NSString stringWithFormat:@"%@ (", NSLocalizedString(@"tax_ded_by_type_tv", @"Tax Ded by type")] stringByAppendingString:[[[dict firstObject] valueForKey:@"type"] stringByAppendingString:@")"]];
            [ self.section5 replaceObjectAtIndex:4 withObject:newStr2];
            
        }
        
        
        //Get all the unique types using KVC
        //        NSMutableDictionary *uniqueObjects = [NSMutableDictionary dictionaryWithCapacity:datavalue.count];
        //        for (NSMutableDictionary *trip in datavalue) {
        //            [uniqueObjects setObject:trip forKey:trip[@"tripType"]];
        //        }
        //
        //        NSLog(@"Unique Objects: %@", uniqueObjects);
        //
        
        
        
        
    }
    else
    {
        // Set all the 5 stat objects to n/a if no trips available
        for (int i = 0; i < 5; i++) {
            [self.totTripStats addObject:[NSString stringWithFormat:@"n/a"]];
        }
        
    }
    
    
    //    float taxDedc = (endOdo-startOdo)* [_taxPercField.text floatValue] + [_parkingField.text floatValue] + [_tollField.text floatValue];
    //
    //    _taxValueLabel.text = [[NSNumber numberWithFloat:taxDedc] stringValue];
    //    _distanceLabel.text = [NSString stringWithFormat:@"%.2f",distance ];
    
    
    
}

-(void)fetchvalue :(NSString *) filterstring
{
    //NIKHIL BUG_156
    //NSManagedObjectContext *contex=[[CoreDataController sharedInstance] newManagedObjectContext];
    NSError *err;
    NSUserDefaults *Def =[NSUserDefaults standardUserDefaults];
    NSString *comparestring = [NSString stringWithFormat:@"%@",[Def objectForKey:@"fillupid"]];
    
    NSFetchRequest *requset=[[NSFetchRequest alloc] initWithEntityName:@"T_Fuelcons"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"vehid==%@",comparestring];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"odo"
                                                                   ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [requset setPredicate:predicate];
    [requset setSortDescriptors:sortDescriptors];

    
    NSArray *datavaluefilter = [[NSArray alloc]init];
    NSMutableArray *datavalue= [[NSMutableArray alloc]init];
    //NIKHIL BUG 156
    datavaluefilter =[self.context  executeFetchRequest:requset error:&err];
    NSDateFormatter *Uniformater=[[NSDateFormatter alloc] init];
    [Uniformater setDateFormat:@"dd MMM yyyy"];
    NSDateFormatter *formaterMON=[[NSDateFormatter alloc] init];
    [formaterMON setDateFormat:@"MMM"];
    
    
    if([filterstring isEqualToString:NSLocalizedString(@"graph_date_range_0", @"All Time")])
    {
        datavalue = [[NSMutableArray alloc]initWithArray:datavaluefilter];
        
    }
    
    else if([filterstring isEqualToString:NSLocalizedString(@"graph_date_range_1", @"This Month")])
    {
        NSDateFormatter *formater=[[NSDateFormatter alloc] init];
        [formater setDateFormat:@"MM"];
        NSDateFormatter *formater1=[[NSDateFormatter alloc] init];
        [formater1 setDateFormat:@"yyyy"];
        NSString *currentmonth = [formater stringFromDate:[NSDate date]];
        NSString *currentyear = [formater1 stringFromDate:[NSDate date]];
        
        for(T_Fuelcons *fuel in datavaluefilter)
        {
            if([[formater stringFromDate:fuel.stringDate] isEqualToString:currentmonth] && [[formater1 stringFromDate:fuel.stringDate] isEqualToString:currentyear])
            {
                [datavalue addObject: fuel];
            }
        }
        
    }
    
    else if([filterstring isEqualToString:NSLocalizedString(@"graph_date_range_2", @"Last Month")])
    {
        NSDateFormatter *formater=[[NSDateFormatter alloc] init];
        [formater setDateFormat:@"M"];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *comps = [NSDateComponents new];
        comps.month = -1;
        comps.day   = -1;
        NSDate *date = [calendar dateByAddingComponents:comps toDate:[NSDate date] options:0];
        NSDateComponents *components = [calendar components:NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date];
        NSDateFormatter *formater1=[[NSDateFormatter alloc] init];
        [formater1 setDateFormat:@"yyyy"];
        NSString *currentyear = [formater1 stringFromDate:[NSDate date]];
        
        NSDate *today = [[NSDate alloc] init];
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
        [offsetComponents setYear:-1];
        NSDate *lastYear = [gregorian dateByAddingComponents:offsetComponents toDate:today options:0];
        
        //NSDateFormatter *df = [[NSDateFormatter alloc] init] ;
       // NSString *monthName = [[df monthSymbols] objectAtIndex:(components.month-1)];
        
        // NSLog(@"Current Date is: %@ ", [formater stringFromDate:[NSDate date]]);
        
        if(components.month!=12)
        {
            for(T_Fuelcons *fuel in datavaluefilter)
            {
                // NSLog(@"[formater stringFromDate:fuel.stringDate]: %@ ,%ld", [formater stringFromDate:fuel.stringDate], components.month);
                
                if([[formater stringFromDate:fuel.stringDate] isEqualToString:[NSString stringWithFormat:@"%ld",(long)components.month]] && [[formater1 stringFromDate:fuel.stringDate] isEqualToString:currentyear])
                {
                    [datavalue addObject: fuel];
                    
                }
            }

        }
        
        else
        {
            for(T_Fuelcons *fuel in datavaluefilter)
            {
                if([[formater stringFromDate:fuel.stringDate] isEqualToString:[NSString stringWithFormat:@"%ld",(long)components.month]] && [[formater1 stringFromDate:fuel.stringDate] isEqualToString:[formater1 stringFromDate:lastYear]])
                {
                    [datavalue addObject: fuel];
                    
                    
                }
            }
        }
       // NSLog(@"datavalue:::%@",datavalue);
    }
    
    else if([filterstring isEqualToString:NSLocalizedString(@"graph_date_range_3", @"This Year")])
    {
        NSDateFormatter *formater=[[NSDateFormatter alloc] init];
        [formater setDateFormat:@"yyyy"];
        NSString *currentmonth = [formater stringFromDate:[NSDate date]];
        for(T_Fuelcons *fuel in datavaluefilter)
        {
            if([[formater stringFromDate:fuel.stringDate] isEqualToString:currentmonth])
            {
                [datavalue addObject: fuel];
                
            }
        }
    }
    
    else
    {    //Custom dates
        NSDateFormatter *formater=[[NSDateFormatter alloc] init];
        [formater setDateFormat:@"dd-MM-yyyy"];
        for(T_Fuelcons *fuel in datavaluefilter)
        {
            if(([[formater dateFromString:self.startdate.text] compare:[formater dateFromString:[formater stringFromDate:fuel.stringDate]]] == NSOrderedAscending && [[formater dateFromString:self.enddate.text] compare:[formater dateFromString:[formater stringFromDate:fuel.stringDate]]] == NSOrderedDescending) || ([[formater dateFromString:self.startdate.text] compare:[formater dateFromString:[formater stringFromDate:fuel.stringDate]]] == NSOrderedSame) || ([[formater dateFromString:self.enddate.text] compare:[formater dateFromString:[formater stringFromDate:fuel.stringDate]]] == NSOrderedSame))
            {
                
                [datavalue addObject: fuel];

            }
        }
        
    }

    allTypeArray = [datavalue mutableCopy];
    //NSLog(@"datavalue = %@", datavalue);
    NSString *distance;
    NSString *dist_unit,*vol_unit;
    
    if([[[NSUserDefaults standardUserDefaults]objectForKey:@"dist_unit"] isEqualToString:NSLocalizedString(@"disp_miles", @"Miles")])
    {
        dist_unit = NSLocalizedString(@"mi", @"mi");
    }
    
    else
    {
        dist_unit = NSLocalizedString(@"kms", @"km");
    }
    
  
    if([[[NSUserDefaults standardUserDefaults]objectForKey:@"vol_unit"] isEqualToString:NSLocalizedString(@"disp_kilowatt_hour", @"Kilowatt-Hour")]){

        vol_unit = NSLocalizedString(@"kwh", @"kWh");

    }else if([[[NSUserDefaults standardUserDefaults]objectForKey:@"vol_unit"] isEqualToString:NSLocalizedString(@"disp_litre", @"Litre")])
    {
        vol_unit = NSLocalizedString(@"ltr", @"Ltr");
        
    }
    
    else
    {
        vol_unit = NSLocalizedString(@"gal", @"gal");
    }

    T_Fuelcons *maxodo = [datavalue lastObject];
    T_Fuelcons *minodo = [datavalue firstObject];
    
    distance = [NSString stringWithFormat:@"%.2f",[maxodo.odo floatValue] - [minodo.odo floatValue]];
    //NSLog(@"distance:::%@",distance);

    NSArray *arr=[[NSArray alloc]init];
    arr = [distance componentsSeparatedByString:@"."];
    int temp=[[arr lastObject] intValue];
    NSString *decimalval = [NSString stringWithFormat:@"%d",temp];
    
    self.totalstat = [[NSMutableArray alloc]init];
    // NSLog(@"distance ...%@",distance);
    if(distance==NULL || [distance isEqualToString:@"0.00"])
    {
        [self.totalstat addObject :[NSString stringWithFormat:@"%@", NSLocalizedString(@"not_applicable", @"n/a")]];
    }
    
    else
    {
        if(temp==0)
        {
            [self.totalstat addObject:[NSString stringWithFormat:@"%ld %@",(long)[distance integerValue] ,dist_unit]];
        }
        else if(![[decimalval substringFromIndex:1]isEqualToString:@"0"])
        {
            [self.totalstat addObject:[NSString stringWithFormat:@"%.2f %@",[distance floatValue],dist_unit]];
        }
        
        else
        {
            [self.totalstat addObject:[NSString stringWithFormat:@"%.1f %@",[distance floatValue],dist_unit]];
        }
    }

    int fillupno=0;

    NSMutableArray *dataval = [[NSMutableArray alloc]init];
    NSMutableArray *services = [[NSMutableArray alloc]init];
    NSMutableArray *expense =[[NSMutableArray alloc]init];
    
    self.filluparray = [[NSMutableArray alloc]init];
    self.servicearray = [[NSMutableArray alloc]init];
    self.expensearray =[[NSMutableArray alloc]init];

    //NSLog(@"comp %d",comp.day);
    for(T_Fuelcons *fillup in datavalue)
    {
        if([fillup.type integerValue]==0)
        {
            [dataval addObject:fillup];
            [self.filluparray addObject:fillup];
           // [self.servicearray addObject:fillup];
        }
        
        if([fillup.type integerValue]==1)
        {
            [services addObject:fillup];
            [self.servicearray addObject:fillup];
        }
        
        if([fillup.type integerValue]==2)
        {
            [expense addObject:fillup];
         //   [self.servicearray addObject:fillup];
            [self.expensearray addObject:fillup];
        }

    }
    
    fillupno = (int)dataval.count;
    float qty=0.0;
    float cost =0.0;
    float fuelcost =0.0;
    
    float servicecost = 0.0;
    float expenses =0.0;
    NSMutableArray *serviceno = [[NSMutableArray alloc]init];
    
    NSString *qtyval;
    float dist=0.0;
    int filluprecord = 0;
    int totalcostrecord =0;
    NSDateFormatter *formater=[[NSDateFormatter alloc] init];
    [formater setDateFormat:@"MMyyyy"];
    NSString *currentdate = [formater stringFromDate:[NSDate date]];
    int fillpermonth=0;
    NSMutableArray *montharray =[[NSMutableArray alloc]init];
    //int totalmonth =0;
    float costperdist =0.0, distpercost =0.0;
    float qtyeff =0.0, disteff=0.0;
    //int totaldays=0;
    float pricepergal =0.0;

    NSDate *maxdate, *mindate;
    NSDateFormatter *formater1=[[NSDateFormatter alloc] init];
    [formater1 setDateFormat:@"dd/MM/yyyy"];

    NSArray *datavalue1 = [[NSArray alloc]init];
    datavalue1 = [[dataval reverseObjectEnumerator]allObjects];

    for(T_Fuelcons *fillup in dataval)
    {
        if(fillup.cost != NULL && [fillup.cost floatValue]!=0)
        {
            mindate = fillup.stringDate;
            break;
        }
    }

    for(T_Fuelcons *fillup in datavalue1)
    {
        if(fillup.cost != NULL && [fillup.cost floatValue]!=0)
        {
            maxdate = fillup.stringDate;
            break;
        }
    }
    
    // NSLog(@"max date %@",[formater1 stringFromDate:maxdate]);
    //NSLog(@"min date %@",[formater1 stringFromDate:mindate]);
    
    NSCalendar *cal = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comp;
    if(mindate!=nil&&maxdate!=nil){
        comp = [cal components:NSCalendarUnitDay fromDate:mindate toDate:maxdate options:NSCalendarWrapComponents];
    }
    int qtyrecord=0;
    for(T_Fuelcons *fillup in dataval)
    {
        qty = qty + [fillup.qty floatValue];
        cost = cost + [fillup.cost floatValue];
        //fuelcost = fuelcost +[fillup.cost floatValue];
        dist = dist + [fillup.dist floatValue];
        if([fillup.cost floatValue]!=0 && fillup.cost!=NULL)
        {
            pricepergal = pricepergal + [fillup.cost floatValue];
            qtyrecord = qtyrecord+1;
        }
        
        if([fillup.dist floatValue]!=0)
        {
            filluprecord =filluprecord+1;
        }
        
        if([fillup.cons floatValue]!=0 && fillup.cons!=NULL)
        {
            qtyeff = qtyeff + [fillup.qty floatValue];
            disteff = disteff + [fillup.dist floatValue];
        }
        
        if([fillup.qty floatValue] * [fillup.cost floatValue]!=0)
        {
            totalcostrecord =totalcostrecord+1;
        }
        if(![currentdate isEqualToString:[formater stringFromDate:fillup.stringDate]])
        {
            fuelcost = fuelcost +[fillup.cost floatValue];
            fillpermonth =fillpermonth + 1;
            if(![montharray containsObject:[formater stringFromDate:fillup.stringDate]])
            {
                //BUG FB 45
                //CLS_LOG(@"[formater stringFromDate:fillup.stringDate] : %@, stringDate : %@", [formater stringFromDate:fillup.stringDate], fillup.stringDate);
                if(fillup.stringDate != NULL){
                    [montharray addObject:[formater stringFromDate:fillup.stringDate]];
                }
            }
        }
        //NSLog(@"Fillup.cons::::%@\nFillup.dist::::%@",fillup.cons,fillup.dist);
        if([fillup.dist floatValue]!=0 && [fillup.cost floatValue]!=0 && [fillup.cons floatValue]!=0 && fillup.cons!=NULL && fillup.cost!=NULL && fillup.dist != NULL)
        {
            costperdist = costperdist + [fillup.cost floatValue];
            distpercost =distpercost + [fillup.dist floatValue];
        }
        
    }
    
    //NSLog(@"price per gal %.2f",pricepergal);
    float servicecostval=0.0;
    float servicedist=0.0;
    
    NSDate *maxdate1, *mindate1;
    for(T_Fuelcons *fillup in services)
    {
        if(fillup.cost != NULL && [fillup.cost floatValue]!=0)
        {
            mindate1 = fillup.stringDate;
            break;
        }
    }
    NSArray *datavalue2 = [[NSArray alloc]init];
    datavalue2 = [[services reverseObjectEnumerator]allObjects];
    for(T_Fuelcons *fillup in datavalue2)
    {
        if(fillup.cost != NULL && [fillup.cost floatValue]!=0)
        {
            maxdate1 = fillup.stringDate;
            break;
        }
    }
    
    //NSLog(@"max date %@",[formater1 stringFromDate:maxdate1]);
    //NSLog(@"min date %@",[formater1 stringFromDate:mindate1]);
    NSDateComponents *comp1;
    if(mindate1!=nil&&maxdate1!=nil){
        comp1 = [cal components:NSCalendarUnitDay fromDate:mindate1 toDate:maxdate1 options:NSCalendarWrapComponents];
    }
    for(T_Fuelcons *fillup in services)
    {
        servicecost = servicecost +[fillup.cost floatValue];
        NSArray *servicenumber = [fillup.serviceType componentsSeparatedByString:@","];
        for(NSString *serviceadd in servicenumber)
        {
            if(![serviceno containsObject:serviceadd])
            {
                [serviceno addObject:serviceadd];
            }
        }
        
        if([fillup.cost floatValue]!=0 && fillup.cost!=NULL)
        {
            servicecostval = servicecostval + [fillup.cost floatValue];
        }
        
    }
    
    T_Fuelcons *maxodoserv = [self.servicearray lastObject];
    T_Fuelcons *minodoserv = [services firstObject];
    
    servicedist = [maxodoserv.odo floatValue]-[minodoserv.odo floatValue];
    //NSLog(@"service val %.2f",servicecostval);
    //NSLog(@"service val %.2f",servicedist);
    float expcostval=0.0;
    float expdist=0.0;
    
    NSDate *maxdate2, *mindate2;
    for(T_Fuelcons *fillup in expense)
    {
        if(fillup.cost != NULL && [fillup.cost floatValue]!=0)
        {
            mindate2 = fillup.stringDate;
            break;
        }
    }

    NSArray *datavalue3 = [[NSArray alloc]init];
    datavalue3 = [[expense reverseObjectEnumerator]allObjects];
    for(T_Fuelcons *fillup in datavalue3)
    {
        if(fillup.cost != NULL && [fillup.cost floatValue]!=0)
        {
            maxdate2 = fillup.stringDate;
            break;
        }
    }
    
    // NSLog(@"max date %@",[formater1 stringFromDate:maxdate2]);
    //NSLog(@"min date %@",[formater1 stringFromDate:mindate2]);
    NSDateComponents *comp2;
    if(mindate2!=nil&&maxdate2!=nil){
        comp2 = [cal components:NSCalendarUnitDay fromDate:mindate2 toDate:maxdate2 options:NSCalendarWrapComponents];
    }
    
    for(T_Fuelcons *fillup in expense)
    {
        expenses = expenses +[fillup.cost floatValue];
        
        if([fillup.cost floatValue]!=0 && fillup.cost!=NULL)
        {
            expcostval = expcostval + [fillup.cost floatValue];
        }
        
    }
    //Check if correct value changed from servicearray
    T_Fuelcons *maxodoexp = [self.expensearray lastObject];
    T_Fuelcons *minodoexp = [expense firstObject];
    
    expdist = [maxodoexp.odo floatValue]-[minodoexp.odo floatValue];
    
    NSString *str1=[NSString stringWithFormat:@"%.3f",qty];
    NSMutableArray *arr1=[[NSMutableArray alloc]init];
    NSArray *arr2=[[NSArray alloc]init];
    
    arr2 = [str1 componentsSeparatedByString:@"."];
    // int temp1=[[arr1 lastObject] intValue];
    // NSLog(@"arr2 %@",arr2);
    NSString *decimalval1 = [NSString stringWithFormat:@"%@",[arr2 lastObject]];
    
    for(int i=0;i<decimalval1.length;i++)
    {
        [arr1 addObject:[NSString stringWithFormat:@"%c",[decimalval1 characterAtIndex:i]]];
    }
    
    if(qty==0)
    {
        
        qtyval = NSLocalizedString(@"not_applicable", @"n/a");
    }
    
    else
    {
        //Swapnil ENH_24
        if([[arr1 lastObject] intValue]==0 && [[arr1 objectAtIndex:1]intValue]==0 && [[arr1 firstObject]intValue]!=0)
        {
            qtyval = [NSString stringWithFormat:@"%.1f %@",qty,vol_unit];
        }
        
        else if([[arr1 lastObject] intValue]==0 && [[arr1 objectAtIndex:1]intValue]!=0)
        {
            qtyval = [NSString stringWithFormat:@"%.2f %@",qty,vol_unit];
        }
        
        
        else if([[arr1 firstObject] intValue]==0 && [[arr1 objectAtIndex:1]intValue]==0 && [[arr1 lastObject]intValue]==0)
        {
            
            qtyval = [NSString stringWithFormat:@"%d %@",(int)ceilf(qty),vol_unit];
        }
        
        else
        {
            qtyval = [NSString stringWithFormat:@"%.3f %@",qty,vol_unit];
        }
    }
    
    NSString *curr_unit;
    
    NSArray *array = [[[NSUserDefaults standardUserDefaults]objectForKey:@"curr_unit"] componentsSeparatedByString:@"-"];
    NSString *string = [array lastObject];
    curr_unit = string;
    
    float dist_fact= 1;
    float vol_fact =1;
    
    //NSString *con_unit = [[NSUserDefaults standardUserDefaults]objectForKey:@"con_unit"];
    NSString *con_unit;
    NSArray *array1 = [[[NSUserDefaults standardUserDefaults]objectForKey:@"con_unit"] componentsSeparatedByString:@" "];
    NSString *string1 = [array1 firstObject];
    con_unit= string1;
    
    
    NSString *dist_unit1 =[[NSUserDefaults standardUserDefaults]objectForKey:@"dist_unit"];
    NSString *vol_unit1 = [[NSUserDefaults standardUserDefaults]objectForKey:@"vol_unit"];
    NSString *con_unit1 = [[NSUserDefaults standardUserDefaults]objectForKey:@"con_unit"];
    if([con_unit1 hasPrefix:@"m"] && [dist_unit1 isEqualToString:NSLocalizedString(@"disp_kilometers", @"Kilometers")])
    {
        dist_fact =0.621;
    }
    
    else if(![con_unit1 hasPrefix:@"m"] && [dist_unit1 isEqualToString:NSLocalizedString(@"disp_miles", @"Miles")])
    {
        dist_fact = 1.609;
    }
    
    if([con_unit1 isEqualToString:NSLocalizedString(@"disp_mpg_us", @"mpg (US)")])
    {
        if([vol_unit1 isEqualToString:NSLocalizedString(@"disp_litre", @"Litre")])
        {
            vol_fact=0.264;
        }
        else if ([vol_unit1 isEqualToString:NSLocalizedString(@"disp_gal_uk", @"Gallon (UK)")])
        {
            vol_fact = 1.201;
        }
    }
    
    else  if([con_unit1 isEqualToString:NSLocalizedString(@"disp_mpg_uk", @"mpg (UK)")])
    {
        if([vol_unit1 isEqualToString:NSLocalizedString(@"disp_litre", @"Litre")])
        {
            vol_fact=0.22;
        }
        else if ([vol_unit1 isEqualToString:NSLocalizedString(@"disp_gal_us", @"Gallon (US)")])
        {
            vol_fact = 0.833;
        }
    }
    
    else if([con_unit1 isEqualToString:NSLocalizedString(@"disp_lp100kms", @"L/100km")] || [con_unit1 isEqualToString:NSLocalizedString(@"disp_kmpl", @"km/L")])
    {
        if([vol_unit1 isEqualToString:NSLocalizedString(@"disp_gal_uk", @"Gallon (UK)")])
        {
            vol_fact= 4.546;
        }
        else if ([vol_unit1 isEqualToString:NSLocalizedString(@"disp_gal_us", @"Gallon (US)")])
        {
            vol_fact = 3.785;
        }
        
    }
    
    
    if(fillupno!=0)
    {
        [self.totalstat addObject:[NSString stringWithFormat:@"%d",fillupno]];
    }
    
    else
    {
        [self.totalstat addObject:[NSString stringWithFormat:NSLocalizedString(@"not_applicable", @"n/a")]];
    }
    
    [self.totalstat addObject:[NSString stringWithFormat:@"%@",qtyval]];
    
    float totalcost = 0.0;
    float totalcostpk = 0.0;
    //Take this cost
    if(cost!=0)
    {
        [self.totalstat addObject:[NSString stringWithFormat:@"%.2f %@",cost,string]];
        totalcost = cost;
    }
    
    else
    {
        [self.totalstat addObject:[NSString stringWithFormat:NSLocalizedString(@"not_applicable", @"n/a")]];
    }
    
    if(serviceno.count!=0)
    {
        [self.totalstat addObject:[NSString stringWithFormat:@"%lu",(unsigned long)serviceno.count]];
    }
    else
    {
        [self.totalstat addObject:[NSString stringWithFormat:NSLocalizedString(@"not_applicable", @"n/a")]];
    }
    //Take this servicecost
    if(servicecost!=0)
    {
        [self.totalstat addObject:[NSString stringWithFormat:@"%.2f %@",servicecost,string]];
        totalcost = totalcost+servicecost;
    }
    else
    {
        [self.totalstat addObject:[NSString stringWithFormat:NSLocalizedString(@"not_applicable", @"n/a")]];
    }
    
    if(expenses!=0)
    {
        [self.totalstat addObject:[NSString stringWithFormat:@"%.2f %@",expenses,string]];
        totalcost = totalcost+expenses;
    }
    else
    {
        [self.totalstat addObject:[NSString stringWithFormat:NSLocalizedString(@"not_applicable", @"n/a")]];
    }

    if(totalcost!=0)
    {
        [self.totalstat addObject:[NSString stringWithFormat:@"%.2f %@",totalcost,string]];
    }
    else
    {
        [self.totalstat addObject:[NSString stringWithFormat:NSLocalizedString(@"not_applicable", @"n/a")]];
    }


    
    NSPredicate *fuelpredicate = [NSPredicate predicateWithFormat:@"type = 0"];
    NSArray *fuelDataArray = [datavalue filteredArrayUsingPredicate:fuelpredicate];
    //Swapnil ENH_2
    //Eff by Octane
    NSMutableArray *octanArray = [[NSMutableArray alloc] init];
    
    //Swapnil ENH_19
    self.octArray = [[NSMutableArray alloc] init];
    
    //Find out unique octanes
    for(T_Fuelcons *fuelData in fuelDataArray){
        
        if([fuelData.type isEqual: @0] && [fuelData.pfill isEqual: @0] && [fuelData.mfill isEqual: @0] && [fuelData.octane integerValue] != 0){
            
            if(![octanArray containsObject:fuelData.octane]){
                [octanArray addObject:fuelData.octane];
                
                //Swapnil ENH_19
                [self.octArray addObject:[fuelData.octane stringValue]];
            }
        }
    }
    //NSLog(@"octArr = %@", self.octArray);
    
    float effByOct = 0.0, maxOctEff = 0.0; //effOct = 0.0;
    int efficientOct = 0;
    
    self.octEffArray = [[NSMutableArray alloc] init];
    
    //Calculate eff for each octane
    for(int i = 0; i < octanArray.count; i++){
        
        float distSum = 0.0;
        float qtySum = 0.0;
        int j = 1;
        for(T_Fuelcons *fuelData in fuelDataArray){
            if([fuelData.type isEqual: @0] && ![fuelData.octane isEqual:@0]){
                
                T_Fuelcons *lastRecord = [fuelDataArray lastObject];
                if(![fuelData.odo isEqual:lastRecord.odo]){
                    if([fuelData.octane isEqual:[octanArray objectAtIndex:i]]){
                    
                    T_Fuelcons *fuelData1 = [fuelDataArray objectAtIndex:j];
                    
                    if([fuelData1.type isEqual: @0] && [fuelData1.pfill isEqual: @0] && [fuelData1.mfill isEqual: @0]){
                        distSum = distSum + [fuelData1.dist floatValue];
                        qtySum = qtySum + [fuelData1.qty floatValue];
                    }
                }
            }
            }
            if(j != [fuelDataArray count] - 1){
                j++;
            }
        }
        effByOct = (distSum * dist_fact) / (qtySum * vol_fact);
        
        //Swapnil ENH_19
        [self.octEffArray addObject:[NSString stringWithFormat:@"%.2f", effByOct]];
        
        //Determine max octane eff
        if(effByOct > maxOctEff){
            maxOctEff = effByOct;
            //effOct = (distSum * dist_fact) / (qtySum * vol_fact);
            efficientOct = [[octanArray objectAtIndex:i] intValue];
        }
    }
    if(efficientOct != 0){
        maxOctane = [NSString stringWithFormat:@"%d", efficientOct];
    } else {
        maxOctane = @"";
    }
    
    if(maxOctane == nil || maxOctane == NULL){
        maxOctane = @"";
    }
    [Def setObject:maxOctane forKey:@"maxmOctane"];
    
    
    //Swapnil ENH_2
    //Eff by Brand
    
    NSMutableArray *fuelBrandArray = [[NSMutableArray alloc] init];
    
    //Swapnil ENH_19
    self.fbGraphArr = [[NSMutableArray alloc] init];
    
    //Find out unique Fuel Brands (fb)
    for(T_Fuelcons *fueldata in fuelDataArray){
        
        if([fueldata.type isEqual: @0] && [fueldata.pfill isEqual: @0] && [fueldata.mfill isEqual: @0] && ![fueldata.fuelBrand isEqualToString:@""] && [fueldata.fuelBrand caseInsensitiveCompare:@"NULL"] != NSOrderedSame && fueldata.fuelBrand != nil && fueldata.fuelBrand.length > 0){
       
            if(![fuelBrandArray containsObject:fueldata.fuelBrand]){
                [fuelBrandArray addObject:fueldata.fuelBrand];
                
                //Swapnil ENH_19
                [self.fbGraphArr addObject:fueldata.fuelBrand];
            }
        }
        else if (fueldata.fuelBrand == nil ||[fueldata.fuelBrand caseInsensitiveCompare:@"NULL"] == NSOrderedSame)
        { CLS_LOG(@"FuelData where fuelBrand is null: %@", fueldata);
            
        }
    }
    //NSLog(@"fbgrapharr = %@", self.fbGraphArr);

    
    float effByBrand = 0.0, maxBrandEff = 0.0, effBrand = 0.0;
    NSString *efficientBrand;
    
    //Swapnil ENH_19
    self.fbEffGraphArr = [[NSMutableArray alloc] init];
    
    //Calculate eff of each fuel brand
    for(int i = 0; i < fuelBrandArray.count; i++){
        
        float distSum = 0.0, qtySum = 0.0;
        int j = 1;
        
        for(T_Fuelcons *fueldata in fuelDataArray){
            
            if([fueldata.type isEqual: @0] && ![fueldata.fuelBrand isEqualToString:@""] && [fueldata.fuelBrand caseInsensitiveCompare:@"NULL"] != NSOrderedSame && fueldata.fuelBrand != nil && fueldata.fuelBrand.length > 0){
                
                T_Fuelcons *lastRecord = [fuelDataArray lastObject];
                if(![fueldata.odo isEqual:lastRecord.odo]){
                    if([fueldata.fuelBrand isEqual:[fuelBrandArray objectAtIndex:i]]){
                    
                    T_Fuelcons *fuelData1 = [fuelDataArray objectAtIndex:j];

                    
                    if([fuelData1.type isEqual: @0] && [fuelData1.pfill isEqual: @0] && [fuelData1.mfill isEqual: @0]){
                        distSum = distSum + [fuelData1.dist floatValue];
                        qtySum = qtySum + [fuelData1.qty floatValue];
                    }
                }
            }
            }
            if(j != [fuelDataArray count] - 1){
                j++;
            }

        }
        effByBrand = (distSum * dist_fact) / (qtySum * vol_fact);
        
        //Swapnil ENH_19
        [self.fbEffGraphArr addObject:[NSString stringWithFormat:@"%.2f", effByBrand]];
        //NSLog(@"fbeffgrapharr = %@", self.fbEffGraphArr);
        
        //Determine max fuel brand eff
        if(effByBrand > maxBrandEff){
            maxBrandEff = effByBrand;
            //effBrand = (distSum * dist_fact) / (qtySum * vol_fact);
            efficientBrand = [fuelBrandArray objectAtIndex:i];
        }
    }
    if(efficientBrand != NULL){
        maxBrand = efficientBrand;
    } else {
        maxBrand = @"";
    }
    if(maxBrand == nil || maxBrand == NULL){
        maxBrand = @"";
    }
    [Def setObject:maxBrand forKey:@"maxmBrand"];
    
    //Swapnil ENH_2
    //Eff by Station
    
    NSMutableArray *fillStationArray = [[NSMutableArray alloc] init];
    
    //Swapnil ENH_19
    self.fsGraphArr = [[NSMutableArray alloc] init];

    //Find out unique Filling Stations (FS)
    for(T_Fuelcons *fueldata in fuelDataArray){
        
        if([fueldata.type isEqual: @0] && [fueldata.pfill isEqual: @0] && [fueldata.mfill isEqual: @0] && ![fueldata.fillStation isEqualToString:@""] && [fueldata.fillStation caseInsensitiveCompare:@"NULL"] != NSOrderedSame && fueldata.fillStation != nil && fueldata.fillStation.length > 0){
            
            if(![fillStationArray containsObject:fueldata.fillStation]){
                [fillStationArray addObject:fueldata.fillStation];
                
                //Swapnil ENH_19
                [self.fsGraphArr addObject:fueldata.fillStation];
            }
        }
        else if (fueldata.fillStation == nil ||[fueldata.fillStation caseInsensitiveCompare:@"NULL"] == NSOrderedSame)
        { CLS_LOG(@"FuelData where fillStation is null: %@", fueldata);
            
        }
    }
    //NSLog(@"fsgrapharr = %@", self.fsGraphArr);
    
    float effByStn = 0.0, maxStnEff = 0.0, effStn = 0.0;
    NSString *efficientStn;
    
    //Swapnil ENH_19
    self.fsEffGraphArr = [[NSMutableArray alloc] init];
    
    //Calculate eff for each filling station
    for(int i = 0; i < fillStationArray.count; i++){
        
        float distSum = 0.0, qtySum = 0.0;
        int j = 1;
        
        for(T_Fuelcons *fueldata in fuelDataArray){
            
            if([fueldata.type isEqual: @0] && ![fueldata.fillStation isEqualToString:@""] && [fueldata.fillStation caseInsensitiveCompare:@"NULL"] != NSOrderedSame && fueldata.fillStation != nil && fueldata.fillStation.length > 0){
                
                T_Fuelcons *lastRecord = [fuelDataArray lastObject];
                
                if(![fueldata.odo isEqual:lastRecord.odo]){
                    if([fueldata.fillStation isEqual:[fillStationArray objectAtIndex:i]]){
                    
                    T_Fuelcons *fuelData1 = [fuelDataArray objectAtIndex:j];
                    
                    if([fuelData1.type isEqual: @0] && [fuelData1.pfill isEqual: @0] && [fuelData1.mfill isEqual: @0]){
                        distSum = distSum + [fuelData1.dist floatValue];
                        qtySum = qtySum + [fuelData1.qty floatValue];
                    }
                }
            }
            }
            if(j != [fuelDataArray count] - 1){
                j++;
            }
        }
        effByStn = (distSum * dist_fact) / (qtySum * vol_fact);
        
        //Swapnil ENH_19
        [self.fsEffGraphArr addObject:[NSString stringWithFormat:@"%.2f", effByStn]];
        //NSLog(@"fseffgrapharr = %@", self.fsEffGraphArr);

        //Determine max filling station eff
        if(effByStn > maxStnEff){
            maxStnEff = effByStn;
            //effStn = (distSum * dist_fact) / (qtySum * vol_fact);
            efficientStn = [fillStationArray objectAtIndex:i];
        }
    }
    if(efficientStn != NULL){
        maxStation = efficientStn;
    } else {
        maxStation = @"";
    }
    if(maxStation == nil || maxStation == NULL){
        maxStation = @"";
    }
    
    
    [Def setObject:maxStation forKey:@"maxmStation"];
    
    self.avgfuelstat = [[NSMutableArray alloc]init];
    if(disteff!=0)
    {
        
        float disteffperqty=0.0;
        disteffperqty = (disteff *dist_fact)/(qtyeff*vol_fact);
        NSString *str1=[NSString stringWithFormat:@"%.2f",disteffperqty];
        if([con_unit containsString:@"100"])
        {
            str1=[NSString stringWithFormat:@"%.2f",100/disteffperqty];
            
        }
        NSArray *arr2=[[NSArray alloc]init];
        arr2 = [str1 componentsSeparatedByString:@"."];
        int temp=[[arr2 lastObject] intValue];
        NSString *decimalval1 = [NSString stringWithFormat:@"%d",temp];
        
        //Average Fuel Efficiency
        if([con_unit containsString:@"100"])
        {
                [self.avgfuelstat addObject:[NSString stringWithFormat:@"%.2f %@",100/((disteff *dist_fact)/(qtyeff*vol_fact)),con_unit]];

            [Def setObject:self.avgfuelstat forKey:@"avgfuelstat"];
        }
        //Average Fuel Efficiency
        else
        {

                [self.avgfuelstat addObject:[NSString stringWithFormat:@"%.2f %@",(disteff *dist_fact)/(qtyeff*vol_fact),con_unit]];

            [Def setObject:self.avgfuelstat forKey:@"avgfuelstat"];
        }
    }
    //Average Fuel Efficiency
    else
    {
        [self.avgfuelstat addObject:[NSString stringWithFormat:@"n/a"]];
    }
    
    //Distance between fill-Ups
    if(dist!=0)
    {
        
        float disteffperqty=0.0;
        disteffperqty = dist/filluprecord;
        NSString *str1=[NSString stringWithFormat:@"%.2f",disteffperqty];
        NSArray *arr2=[[NSArray alloc]init];
        arr2 = [str1 componentsSeparatedByString:@"."];
        int temp=[[arr2 lastObject] intValue];
        NSString *decimalval1 = [NSString stringWithFormat:@"%d",temp];
        
        //Swapnil ISSUE #93 (crashlytics)

//        if(temp==0)
//        {
//            [self.avgfuelstat addObject:[NSString stringWithFormat:@"%d %@",(int)ceilf(disteffperqty),dist_unit]];
//            
//            // add NSUserDefaults here
//            
//            
//        }
//        
//        else if(![[decimalval1 substringFromIndex:1]isEqualToString:@"0"])
//        {
            [self.avgfuelstat addObject:[NSString stringWithFormat:@"%.2f %@",dist/filluprecord,dist_unit]];
//        }
//        
//        else
//        {
//            [self.avgfuelstat addObject:[NSString stringWithFormat:@"%.1f %@",dist/filluprecord,dist_unit]];
//        }
        
    }
    //Distance between fill-Ups
    else
    {
        [self.avgfuelstat addObject:[NSString stringWithFormat:NSLocalizedString(@"not_applicable", @"n/a")]];
    }
    
    
    //Qty per fillup
    if(qty!=0)
    {
        
        NSString *str1=[NSString stringWithFormat:@"%.3f",qty/dataval.count];
        NSMutableArray *arr1=[[NSMutableArray alloc]init];
        NSArray *arr2=[[NSArray alloc]init];
        
        arr2 = [str1 componentsSeparatedByString:@"."];
        // int temp1=[[arr1 lastObject] intValue];
        // NSLog(@"arr2 %@",arr2);
        NSString *decimalval1 = [NSString stringWithFormat:@"%@",[arr2 lastObject]];
        
        for(int i=0;i<decimalval1.length;i++)
        {
            [arr1 addObject:[NSString stringWithFormat:@"%c",[decimalval1 characterAtIndex:i]]];
        }
        
        //Swapnil ENH_24
        if([[arr1 lastObject] intValue]==0 && [[arr1 objectAtIndex:1]intValue]==0 && [[arr1 firstObject]intValue]!=0)
        {
            [self.avgfuelstat addObject:[NSString stringWithFormat:@"%.1f %@",qty/dataval.count,vol_unit]];
        }
        
        else if([[arr1 firstObject] intValue]==0 && [[arr1 objectAtIndex:1]intValue]==0 && [[arr1 lastObject]intValue]==0)
        {
            
            [self.avgfuelstat addObject:[NSString stringWithFormat:@"%d %@",(int)ceilf(qty/dataval.count),vol_unit]];
        }
        
        
        else if([[arr1 lastObject] intValue]==0 && [[arr1 objectAtIndex:1]intValue]!=0)
        {
            [self.avgfuelstat addObject:[NSString stringWithFormat:@"%.2f %@",qty/dataval.count,vol_unit]];
        }
        
        
        
        else
        {
            [self.avgfuelstat addObject:[NSString stringWithFormat:@"%.3f %@",qty/dataval.count,vol_unit]];
        }
    }
    //Qty per fillup
    else
    {
        [self.avgfuelstat addObject:[NSString stringWithFormat:NSLocalizedString(@"not_applicable", @"n/a")]];
    }
    
    
    //Cost per fill-up
    if(cost!=0)
    {
        [self.avgfuelstat addObject:[NSString stringWithFormat:@"%.2f %@",cost/totalcostrecord,curr_unit]];
        
    }
    //Cost per fill-up
    else
    {
        [self.avgfuelstat addObject:[NSString stringWithFormat:NSLocalizedString(@"not_applicable", @"n/a")]];
    }
    
    
    //Average Price/gal
    if(pricepergal!=0 && qty!=0)
    {
        
        NSString *str1=[NSString stringWithFormat:@"%.3f",(pricepergal/qtyrecord)];
        NSMutableArray *arr1=[[NSMutableArray alloc]init];
        NSArray *arr2=[[NSArray alloc]init];
        
        arr2 = [str1 componentsSeparatedByString:@"."];
        // int temp1=[[arr1 lastObject] intValue];
        // NSLog(@"arr2 %@",arr2);
        NSString *decimalval1 = [NSString stringWithFormat:@"%@",[arr2 lastObject]];
        
        for(int i=0;i<decimalval1.length;i++)
        {
            [arr1 addObject:[NSString stringWithFormat:@"%c",[decimalval1 characterAtIndex:i]]];
        }
        
        //Swapnil ENH_24
        if([[arr1 lastObject] intValue]==0 && [[arr1 objectAtIndex:1]intValue]==0 && [[arr1 firstObject]intValue]!=0)
        {
            [self.avgfuelstat addObject:[NSString stringWithFormat:@"%.2f %@",(pricepergal/qty),curr_unit]];
        }
        
        else if([[arr1 firstObject] intValue]==0 && [[arr1 objectAtIndex:1]intValue]==0 && [[arr1 lastObject]intValue]==0)
        {
            
            [self.avgfuelstat addObject:[NSString stringWithFormat:@"%.2f %@",(pricepergal/qty),curr_unit]];
        }
        
        
        else if([[arr1 lastObject] intValue]==0 && [[arr1 objectAtIndex:1]intValue]!=0)
        {
            [self.avgfuelstat addObject:[NSString stringWithFormat:@"%.2f %@",(pricepergal/qty),curr_unit]];
        }

        else
        {
            [self.avgfuelstat addObject:[NSString stringWithFormat:@"%.3f %@",(pricepergal/qty),curr_unit]];
        }
        
        //[self.avgfuelstat addObject:[NSString stringWithFormat:@"%.2f %@",(pricepergal/qtyrecord),curr_unit]];
    }
    //Average Price/gal
    else
    {
        [self.avgfuelstat addObject:[NSString stringWithFormat:NSLocalizedString(@"not_applicable", @"n/a")]];
    }
    
    
    //Fill-ups per months
    if(fillpermonth!=0)
    {
        //NSLog(@"fillpermonth %d", fillpermonth);
        //NSLog(@"fillpermonth %lu", (unsigned long)montharray.count);
        
        float a = (float)fillpermonth/montharray.count;
        float roundedup = ceil(a);
        NSInteger intValue = (NSInteger) roundf(roundedup);
        [self.avgfuelstat addObject:[NSString stringWithFormat:@"%ld", (long)intValue]];
    }
    //Fill-ups per months
    else
    {
        [self.avgfuelstat addObject:[NSString stringWithFormat:@"n/a"]];
    }
    
    //Fuel Cost per mi
    //Take this for totalcostpk
    double fuelCostPerDist = [self getCostPerDist:datavalue andType:0];

    if(fuelCostPerDist!=0) //costperdist
    {                                                                   //costperdist/distpercost
        [self.avgfuelstat addObject:[NSString stringWithFormat:@"%.2f %@",fuelCostPerDist,curr_unit]];
        
    }
    ///Fuel Cost per mi
    else
    {
        [self.avgfuelstat addObject:[NSString stringWithFormat:NSLocalizedString(@"not_applicable", @"n/a")]];
    }
    
    //Fuel Cost per day
    double fuelCostPerDay = [self getCostPerDay:datavalue andType:0];
    //(cost!=0 && compForAll.day>0)
    if(fuelCostPerDay!=0)
    {                                                                   //cost/(compForAll.day+1)
        [self.avgfuelstat addObject:[NSString stringWithFormat:@"%.2f %@",fuelCostPerDay,curr_unit]];
    }
    else
    {
        [self.avgfuelstat addObject:[NSString stringWithFormat:NSLocalizedString(@"not_applicable", @"n/a")]];
    }
    
    //Fuel cost per month
    
    if(cost!=0 && montharray.count>0)
    {
        [self.avgfuelstat addObject:[NSString stringWithFormat:@"%.2f %@",fuelcost/montharray.count,curr_unit]];

        //NSLog(@"fuelcost is : %f", fuelcost);
        //NSLog(@"montharray.count is : %lu", (unsigned long)montharray.count);

    }
    else
    {
        [self.avgfuelstat addObject:[NSString stringWithFormat:NSLocalizedString(@"not_applicable", @"n/a")]];
        
    }
    
    //Eff by Octane
    
    if(maxOctEff != 0){
        
        NSString *str1=[NSString stringWithFormat:@"%.2f",maxOctEff];
        if([con_unit containsString:@"100"])
        {
            str1=[NSString stringWithFormat:@"%.2f",100/maxOctEff];
            
        }
        NSArray *arr2=[[NSArray alloc]init];
        arr2 = [str1 componentsSeparatedByString:@"."];
        int temp=[[arr2 lastObject] intValue];
        NSString *decimalval1 = [NSString stringWithFormat:@"%d",temp];
        
        if([con_unit containsString:@"100"])
        {
            //Swapnil ISSUE #93 (crashlytics)

//            if(temp==0)
//            {
//                [self.avgfuelstat addObject:[NSString stringWithFormat:@"%.2f %@",100/maxOctEff,con_unit]];
//            }
//            else if(![[decimalval1 substringFromIndex:1]isEqualToString:@"0"])
//            {
                [self.avgfuelstat addObject:[NSString stringWithFormat:@"%.2f %@",100/maxOctEff, con_unit]];
//            }
//            
//            else
//            {
//                [self.avgfuelstat addObject:[NSString stringWithFormat:@"%.1f %@",100/maxOctEff, con_unit]];
//            }
            
        }
        else
        {
            //Swapnil ISSUE #93 (crashlytics)

//            if(temp==0)
//            {
//                [self.avgfuelstat addObject:[NSString stringWithFormat:@"%.2f %@",maxOctEff,con_unit]];
//            }
//            else if(![[decimalval1 substringFromIndex:1]isEqualToString:@"0"])
//            {
                [self.avgfuelstat addObject:[NSString stringWithFormat:@"%.2f %@",maxOctEff,con_unit]];
//            }
//            
//            else
//            {
//                [self.avgfuelstat addObject:[NSString stringWithFormat:@"%.1f %@",maxOctEff,con_unit]];
//            }
            
        }
    }
    
    //Eff by Octane
    else
    {
        [self.avgfuelstat addObject:[NSString stringWithFormat:@"n/a"]];
    }
    
    //Eff by brand
    if(maxBrandEff != 0){
        
        NSString *str1=[NSString stringWithFormat:@"%.2f",maxBrandEff];
        if([con_unit containsString:@"100"])
        {
            str1=[NSString stringWithFormat:@"%.2f",100/maxBrandEff];
            
        }
        NSArray *arr2=[[NSArray alloc]init];
        arr2 = [str1 componentsSeparatedByString:@"."];
        //int temp=[[arr2 lastObject] intValue];
        //NSString *decimalval1 = [NSString stringWithFormat:@"%d",temp];
        
        if([con_unit containsString:@"100"])
        {
            //Swapnil ISSUE #93 (crashlytics)

//            if(temp==0)
//            {
//                [self.avgfuelstat addObject:[NSString stringWithFormat:@"%.2f %@",100/maxBrandEff,con_unit]];
//            }
//            else if(![[decimalval1 substringFromIndex:1]isEqualToString:@"0"])
//            {
                [self.avgfuelstat addObject:[NSString stringWithFormat:@"%.2f %@",100/maxBrandEff, con_unit]];
//            }
//            
//            else
//            {
//                [self.avgfuelstat addObject:[NSString stringWithFormat:@"%.1f %@",100/maxBrandEff, con_unit]];
//            }
            
        }
        else
        {
            //Swapnil ISSUE #93 (crashlytics)

//            if(temp==0)
//            {
//                [self.avgfuelstat addObject:[NSString stringWithFormat:@"%.2f %@",maxBrandEff,con_unit]];
//            }
//            else if(![[decimalval1 substringFromIndex:1]isEqualToString:@"0"])
//            {
                [self.avgfuelstat addObject:[NSString stringWithFormat:@"%.2f %@",maxBrandEff,con_unit]];
//            }
//            
//            else
//            {
//                [self.avgfuelstat addObject:[NSString stringWithFormat:@"%.1f %@",maxBrandEff,con_unit]];
//            }
            
        }

    }
    
    //Eff by brand
    else
    {
        [self.avgfuelstat addObject:[NSString stringWithFormat:NSLocalizedString(@"not_applicable", @"n/a")]];
    }

    //Eff by station
    if(maxStnEff != 0){
        
        NSString *str1=[NSString stringWithFormat:@"%.2f",maxStnEff];
        if([con_unit containsString:@"100"])
        {
            str1=[NSString stringWithFormat:@"%.2f",100/maxStnEff];
            
        }
        NSArray *arr2=[[NSArray alloc]init];
        arr2 = [str1 componentsSeparatedByString:@"."];
        int temp=[[arr2 lastObject] intValue];
        NSString *decimalval1 = [NSString stringWithFormat:@"%d",temp];
        if([con_unit containsString:@"100"])
        {
            //Swapnil ISSUE #93 (crashlytics)

//            if(temp==0)
//            {
//                [self.avgfuelstat addObject:[NSString stringWithFormat:@"%.2f %@",100/maxStnEff,con_unit]];
//            }
//            else if(![[decimalval1 substringFromIndex:1]isEqualToString:@"0"])
//            {
                [self.avgfuelstat addObject:[NSString stringWithFormat:@"%.2f %@",100/maxStnEff, con_unit]];
//            }
//            
//            else
//            {
//                [self.avgfuelstat addObject:[NSString stringWithFormat:@"%.1f %@",100/maxStnEff, con_unit]];
//            }
            
        }
        else
        {
            //Swapnil ISSUE #93 (crashlytics)

//            if(temp==0)
//            {
//                [self.avgfuelstat addObject:[NSString stringWithFormat:@"%.2f %@",maxStnEff,con_unit]];
//            }
//            else if(![[decimalval1 substringFromIndex:1]isEqualToString:@"0"])
//            {
                [self.avgfuelstat addObject:[NSString stringWithFormat:@"%.2f %@",maxStnEff,con_unit]];
//            }
//            
//            else
//            {
//                [self.avgfuelstat addObject:[NSString stringWithFormat:@"%.1f %@",maxStnEff,con_unit]];
//            }
            
        }

    }
    
    //Eff by Station
    else
    {
        [self.avgfuelstat addObject:[NSString stringWithFormat:NSLocalizedString(@"not_applicable", @"n/a")]];
    }

   // NSLog(@"self.avgfuelstat : %@", self.avgfuelstat );

    self.avgservstat =[[NSMutableArray alloc]init];
    //Take this for totalcostpk
    double serviceCostPerDist = [self getCostPerDist:datavalue andType:1];
    //servicedist
    if(serviceCostPerDist != 0)
    {                                                                   //servicecostval/servicedist
        [self.avgservstat addObject:[NSString stringWithFormat:@"%.2f %@",serviceCostPerDist,curr_unit]];
    }
    
    else
    {
        [self.avgservstat addObject:[NSString stringWithFormat:NSLocalizedString(@"not_applicable", @"n/a")]];
    }

    //comp1 is for only services so used comp for all types
    double serviceCostPerDay = [self getCostPerDay:datavalue andType:1];
    //servicecostval!=0 && comp1.day>0
    if(serviceCostPerDay!=0)
    {                                                                     //servicecostval/(comp1.day + 1)
        [self.avgservstat addObject:[NSString stringWithFormat:@"%.2f %@",serviceCostPerDay,curr_unit]];
    }
    else
    {
        [self.avgservstat addObject:[NSString stringWithFormat:NSLocalizedString(@"not_applicable", @"n/a")]];
    }
    
    self.avgexpstat =[[NSMutableArray alloc]init];
    //Take this for totalcostpk
    double expenseCostPerDist = [self getCostPerDist:datavalue andType:2];
    //expdist
    if(expenseCostPerDist!=0)
    {                                                                   //expcostval/expdist
        [self.avgexpstat addObject:[NSString stringWithFormat:@"%.2f %@",expenseCostPerDist,curr_unit]];
    }
    else {
        [self.avgexpstat addObject:[NSString stringWithFormat:NSLocalizedString(@"not_applicable", @"n/a")]];
    }
    
    double expenseCostPerDay = [self getCostPerDay:datavalue andType:2];
    if(expenseCostPerDay!=0)
    {                                                                   //expcostval/(comp2.day + 1)
        [self.avgexpstat addObject:[NSString stringWithFormat:@"%.2f %@",expenseCostPerDay,curr_unit]];
    }
    else
    {
        [self.avgexpstat addObject:[NSString stringWithFormat:NSLocalizedString(@"not_applicable", @"n/a")]];
    }

    //This is done for totalcostpk
    float totalFuelCostPerDist = 0.0;
    float totalServiceCostPerDist = 0.0;
    float totalExpenseCostPerDist = 0.0;

    if((costperdist != 0) && (distpercost !=0)){

        totalFuelCostPerDist = costperdist/distpercost;
        totalcostpk = totalFuelCostPerDist;
    }

    if((servicecostval != 0) && (servicedist !=0)){

        totalServiceCostPerDist = servicecostval/servicedist;
        totalcostpk += totalServiceCostPerDist;
    }

    if((expcostval != 0) && (expdist !=0)){

        totalExpenseCostPerDist = expcostval/expdist;
        totalcostpk += totalExpenseCostPerDist;
    }

    if(totalcostpk!=0)
    {
        [self.totalstat addObject:[NSString stringWithFormat:@"%.2f %@",totalcostpk,string]];
    }
    else
    {
        [self.totalstat addObject:[NSString stringWithFormat:NSLocalizedString(@"not_applicable", @"n/a")]];
    }
    [self setarray];
    
    for(int i=0;i<self.section1.count;i++)
    {
        if([[self.section1 objectAtIndex:i] isEqualToString:@""])
        {
            [self.totalstat replaceObjectAtIndex:i withObject:@""];
        }
    }
    
    for(int i=0;i<self.section2.count;i++)
    {
        if([[self.section2 objectAtIndex:i] isEqualToString:@""])
        {
            [self.avgfuelstat replaceObjectAtIndex:i withObject:@""];
        }
    }
    
    for(int i=0;i<self.section3.count;i++)
    {
        if([[self.section3 objectAtIndex:i] isEqualToString:@""])
        {
            [self.avgservstat replaceObjectAtIndex:i withObject:@""];
        }
    }
    
    for(int i=0;i<self.section4.count;i++)
    {
        if([[self.section4 objectAtIndex:i] isEqualToString:@""])
        {
            [self.avgexpstat replaceObjectAtIndex:i withObject:@""];
        }
    }
    
    for(int i=0;i<self.section5.count;i++)
    {
        if([[self.section5 objectAtIndex:i] isEqualToString:@""])
        {
            [self.totTripStats replaceObjectAtIndex:i withObject:@""];
        }
    }
    
    //Get Trip Stats
    [self fetchTripStats:filterstring];

    //Set Date range based on SortedLog
    [self setDateRange:filterstring];
    
    [self.section1 removeObject:@""];
    [self.totalstat removeObject:@""];
    [self.section2 removeObject:@""];
    [self.avgfuelstat removeObject:@""];
    [self.section3 removeObject:@""];
    [self.avgservstat removeObject:@""];
    [self.section4 removeObject:@""];
    [self.avgexpstat removeObject:@""];
    [self.section5 removeObject:@""];
    [self.totTripStats removeObject:@""];
    
    [self.tableview reloadData];
    
    //NSLog(@"Filluparray from fetchValue - DashBoard::::%@",self.filluparray);

}

- (double)getCostPerDay: (NSMutableArray *)recordArray andType:(int)type{

    NSMutableArray *recordArrayWithoutType3 = [[NSMutableArray alloc]init];

    for(T_Fuelcons *fillup in recordArray)
    {
        if([fillup.type integerValue]!=3)
        {
            [recordArrayWithoutType3 addObject:fillup];
        }

    }

    double costPerDay = 0.0;

    NSDate *maxDateForAll, *minDateForAll;

    NSArray *datavalue1 = [[NSArray alloc]init];
    datavalue1 = [[recordArrayWithoutType3 reverseObjectEnumerator]allObjects];

    for(T_Fuelcons *record in recordArrayWithoutType3){

        minDateForAll = record.stringDate;
        break;
    }

    for(T_Fuelcons *record in datavalue1){

        maxDateForAll = record.stringDate;
        break;
    }

    NSCalendar *calForAll = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *compForAll;
    if(minDateForAll!=nil && maxDateForAll!=nil){
        compForAll = [calForAll components:NSCalendarUnitDay fromDate:minDateForAll toDate:maxDateForAll options:NSCalendarWrapComponents];
    }

    double cost = 0.0;

    if(type == 0) {

        for(T_Fuelcons *record in self.filluparray){

            cost += [record.cost floatValue];
        }
    }else if (type == 1) {

        for(T_Fuelcons *record in self.servicearray){

            cost += [record.cost floatValue];
        }
    }else if (type == 2) {

        for(T_Fuelcons *record in self.expensearray){

            cost += [record.cost floatValue];
        }
    }

    double dayDiff = compForAll.day+1;
    costPerDay = cost/dayDiff;

    return costPerDay;
}

- (double)getCostPerDist: (NSMutableArray *)recordArray andType:(int)type{

    NSMutableArray *recordArrayWithoutType3 = [[NSMutableArray alloc]init];

    for(T_Fuelcons *fillup in recordArray)
    {
        if([fillup.type integerValue]!=3)
        {
            [recordArrayWithoutType3 addObject:fillup];
        }

    }

    double costPerDist = 0.0;

    T_Fuelcons *maxodo = [recordArrayWithoutType3 lastObject];
    T_Fuelcons *minodo = [recordArrayWithoutType3 firstObject];
    double distBetOdo = [maxodo.odo floatValue] - [minodo.odo floatValue];
  //  NSLog(@"%f ---- %f = %f",[maxodo.odo floatValue],[minodo.odo floatValue],distBetOdo);

    double cost = 0.0;

    if(type == 0) {

        for(T_Fuelcons *record in self.filluparray){

            cost += [record.cost floatValue];
        }
    }else if (type == 1) {

        for(T_Fuelcons *record in self.servicearray){

            cost += [record.cost floatValue];
        }
    }else if (type == 2) {

        for(T_Fuelcons *record in self.expensearray){

            cost += [record.cost floatValue];
        }
    }

    costPerDist = cost/distBetOdo;

    return costPerDist;
}

- (IBAction)pickfilter:(id)sender {
    //NIKHIL BUG_134 added setbutton removeFromSuperView
    [_picker removeFromSuperview];
    [_setbutton removeFromSuperview];
    _picker = [[UIPickerView alloc]init];
    AppDelegate *App = [AppDelegate sharedAppDelegate];
    _picker.frame = CGRectMake(App.result.width/2-130,App.result.height/2-220, 260, 270);
    _picker.backgroundColor=[UIColor grayColor];
    
    _picker.clipsToBounds=YES;
    _picker.delegate =self;
    _picker.dataSource=self;
    _picker.tag=-4;
    self.pickerval = @"Select";
    
    UIBezierPath *maskPath;
    maskPath = [UIBezierPath bezierPathWithRoundedRect:_picker.bounds
                                     byRoundingCorners:(UIRectCornerTopLeft|UIRectCornerTopRight)
                                           cornerRadii:CGSizeMake(5.0, 5.0)];
    
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.view.frame;
    maskLayer.path = maskPath.CGPath;
    _picker.layer.mask = maskLayer;
    
    
    //UIView *topview = (UIView*)[self.view viewWithTag:-2];
    //
    [self.view addSubview:_picker];
    _setbutton =[[UIButton alloc]init];
    _setbutton.frame = CGRectMake(App.result.width/2-130,(App.result.height/2-220)+270, 260, 40);
    //button.titleLabel.text = @"Set" ;
    [_setbutton setBackgroundColor:[UIColor lightGrayColor]];
    [_setbutton setTitle:NSLocalizedString(@"set", @"Set") forState:UIControlStateNormal];
    [_setbutton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    //_setbutton.layer.cornerRadius = 5;
    [_setbutton addTarget:self action:@selector(setfilter) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_setbutton];
    
}


- (IBAction)dropdownclick:(id)sender {
    //NIKHIL BUG_134 added setbutton removeFromSuperView
    [_picker removeFromSuperview];
    [_setbutton removeFromSuperview];
    _picker = [[UIPickerView alloc]init];
    AppDelegate *App = [AppDelegate sharedAppDelegate];
    _picker.frame = CGRectMake(App.result.width/2-130,App.result.height/2-220, 260, 270);
    
    _picker.backgroundColor=[UIColor grayColor];
    
    _picker.clipsToBounds=YES;
    _picker.delegate =self;
    _picker.dataSource=self;
    _picker.tag=-4;
    self.pickerval = @"Select";
    
    UIBezierPath *maskPath;
    maskPath = [UIBezierPath bezierPathWithRoundedRect:_picker.bounds
                                     byRoundingCorners:(UIRectCornerTopLeft|UIRectCornerTopRight)
                                           cornerRadii:CGSizeMake(5.0, 5.0)];
    
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.view.frame;
    maskLayer.path = maskPath.CGPath;
    _picker.layer.mask = maskLayer;
    
    
    // UIView *topview = (UIView*)[self.view viewWithTag:-2];
    //
    [self.view addSubview:_picker];
    _setbutton =[[UIButton alloc]init];
    _setbutton.frame = CGRectMake(App.result.width/2-130,(App.result.height/2-220)+270, 260, 40);
    //button.titleLabel.text = @"Set" ;
    
    [_setbutton setBackgroundColor:[UIColor lightGrayColor]];
    [_setbutton setTitle:NSLocalizedString(@"set", @"Set") forState:UIControlStateNormal];
    [_setbutton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    //_setbutton.layer.cornerRadius = 5;
    [_setbutton addTarget:self action:@selector(setfilter) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_setbutton];
}

- (IBAction)vehfilterClick:(id)sender {
    if(self.vehiclearray.count>0)
    {
        [self picker:@"Select Vehicle"];
    }
}



-(void)setDateRange:(NSString*)pickerVal
{
    
    NSDateFormatter *logFormatter=[[NSDateFormatter alloc] init];
    [logFormatter setDateFormat:@"dd-MMM-yyyy"];
    
    NSDateFormatter* tripFormatter = [[NSDateFormatter alloc] init] ;
    [tripFormatter setDateFormat:@"dd-MMM-yyyy HH:mm a"];
    
    NSDateFormatter *yrformater=[[NSDateFormatter alloc] init];
    [yrformater setDateFormat:@"yyyy"];
    
    NSDateFormatter *mnthFormater=[[NSDateFormatter alloc] init];
    [mnthFormater setDateFormat:@"MM"];
    
    NSDateFormatter *Uniformater=[[NSDateFormatter alloc] init];
    [Uniformater setDateFormat:@"dd MMM yyyy"];
    
    NSDateFormatter *formaterMON=[[NSDateFormatter alloc] init];
    [formaterMON setDateFormat:@"MMM"];
    
    NSString* yr;
    NSString *currentYr = [yrformater stringFromDate:[NSDate date]];
    int set = 0;
    
    NSArray *sortedLogArray=[[NSUserDefaults standardUserDefaults] objectForKey:@"SortedLog"];
    
    if(sortedLogArray.count>0)
    {
        NSMutableDictionary *maxrecord = [[NSMutableDictionary alloc] init];
        NSMutableDictionary *minrecord =[[NSMutableDictionary alloc] init];
        NSDate* logDate;
        NSMutableArray* datavalue = [[NSMutableArray alloc] init];
        if([pickerVal isEqualToString:NSLocalizedString(@"graph_date_range_0", @"All Time")])
        {
            maxrecord =[sortedLogArray firstObject];
            minrecord = [sortedLogArray lastObject];
            
        }
        else if([pickerVal isEqualToString:NSLocalizedString(@"graph_date_range_1", @"This Month")])
        {
            NSString *currentmonth = [mnthFormater stringFromDate:[NSDate date]];
            yr = [yrformater stringFromDate:[NSDate date]];
            
            
            for(NSDictionary *logDict in sortedLogArray)
            {
                
                if ([[logDict objectForKey:@"type"] integerValue] == 3)
                { //if Trip type data
                    logDate = [tripFormatter dateFromString:[logDict objectForKey: @"date"]];
                }
                else
                {//For service/expense and fuel data
                    logDate = [logFormatter dateFromString:[logDict objectForKey: @"date"]];
                }
                
                if([[mnthFormater stringFromDate:logDate] isEqualToString:currentmonth] && [[yrformater stringFromDate:logDate] isEqualToString:yr])
                {
                    [datavalue addObject: logDict];
                }
                
            }
            
            maxrecord = [datavalue firstObject];
            minrecord = [datavalue lastObject];
            
        }
        else if([pickerVal isEqualToString:NSLocalizedString(@"graph_date_range_2", @"Last Month")])
        {
            NSDateFormatter *formater=[[NSDateFormatter alloc] init];
            [formater setDateFormat:@"M"];
            NSCalendar *calendar = [NSCalendar currentCalendar];
            NSDateComponents *comps = [NSDateComponents new];
            comps.month = -1;
            comps.day   = -1;
            NSDate *date = [calendar dateByAddingComponents:comps toDate:[NSDate date] options:0];
            NSDateComponents *components = [calendar components:NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date];
            NSString *currentyear = [yrformater stringFromDate:[NSDate date]];
            
            NSDate *today = [[NSDate alloc] init];
            NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
            [offsetComponents setYear:-1];
            NSDate *lastYearDte = [gregorian dateByAddingComponents:offsetComponents toDate:today options:0];
            NSString *lastYear = [yrformater stringFromDate:lastYearDte];
            
            NSDateFormatter *df = [[NSDateFormatter alloc] init] ;
            NSString *monthName = [[df monthSymbols] objectAtIndex:(components.month-1)];
            
            // NSLog(@"Current Date is: %@ ", [formater stringFromDate:[NSDate date]]);
            for(NSDictionary *logDict in sortedLogArray)
            {
                
                if(components.month!=12)
                {
                    yr = currentyear;
                }
                else
                {
                    
                    yr = lastYear;
                    
                }
                
                if ([[logDict objectForKey:@"type"] integerValue] == 3)
                { //if Trip type data
                    logDate = [tripFormatter dateFromString:[logDict objectForKey: @"date"]];
                }
                else
                {//For service/expense and fuel data
                    logDate = [logFormatter dateFromString:[logDict objectForKey: @"date"]];
                }
                
                if([[formater stringFromDate:logDate] isEqualToString:[NSString stringWithFormat:@"%ld",(long)components.month]] && [[yrformater stringFromDate:logDate] isEqualToString:yr])
                {
                    [datavalue addObject: logDict];
                    
                }
                
            }
            
            maxrecord = [datavalue firstObject];
            minrecord = [datavalue lastObject];
            
        }
        else if([pickerVal isEqualToString:NSLocalizedString(@"graph_date_range_3", @"This Year")])
        {
            //NSString *currentmonth = [yrformater stringFromDate:[NSDate date]];
            
            for(NSDictionary *logDict in sortedLogArray)
            {
                
                if ([[logDict objectForKey:@"type"] integerValue] == 3)
                { //if Trip type data
                    logDate = [tripFormatter dateFromString:[logDict objectForKey: @"date"]];
                }
                else
                {//For service/expense and fuel data
                    logDate = [logFormatter dateFromString:[logDict objectForKey: @"date"]];
                }
                
                if([[yrformater stringFromDate:logDate] isEqualToString:currentYr])
                {
                    [datavalue addObject: logDict];
                    
                }
                
            }
            
            maxrecord = [datavalue firstObject];
            minrecord = [datavalue lastObject];
            
            
        }
        else //Custom Dates
        {
            set = 1;
            self.dateRangeLabel.text = [self.startdate.text stringByAppendingString:[@"-" stringByAppendingString: self.enddate.text]];
        }
        
        
        
        if (set == 0) {
            
            NSDate *minDate;
            NSDate *maxDate;
            
            
            
            if ([[maxrecord objectForKey:@"type"] integerValue] == 3)
            { //if Trip type data
                maxDate = [tripFormatter dateFromString:[maxrecord objectForKey: @"date"]];
            }
            else
            {//For service/expense and fuel data
                maxDate = [logFormatter dateFromString:[maxrecord objectForKey: @"date"]];
            }
            
            if ([[minrecord objectForKey:@"type"] integerValue] == 3)
            { //if Trip type data
                minDate = [tripFormatter dateFromString:[minrecord objectForKey: @"date"]];
            }
            else
            {//For service/expense and fuel data
                minDate = [logFormatter dateFromString:[minrecord objectForKey: @"date"]];
            }
            
            
            if (maxrecord == nil) {
                
                self.dateRangeLabel.text = [[[formaterMON stringFromDate:[NSDate date]] stringByAppendingString:@" "] stringByAppendingString:currentYr];
            }
            
            //Swapnil BUG_87
            else if(maxDate != nil && minDate != nil){
                self.dateRangeLabel.text = [[[Uniformater stringFromDate:minDate] stringByAppendingString:@"  -  " ] stringByAppendingString:[Uniformater stringFromDate:maxDate] ];
                
            } else {
                self.dateRangeLabel.text = @"";
            }
            
        }
        
    }
    else
    {
        self.dateRangeLabel.text = @"NO DATA AVAILABLE";
    }
    
    
    
    //NSLog(@"self.dateRangeLabel.text: %@", self.dateRangeLabel.text);
    
}

@end
