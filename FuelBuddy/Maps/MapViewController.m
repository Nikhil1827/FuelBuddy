//
//  MapViewController.m
//  FuelBuddy
//
//  Created by Nikhil on 12/12/18.
//  Copyright © 2018 Oraganization. All rights reserved.
//

#import "MapViewController.h"
#import "AppDelegate.h"
#import "Veh_Table.h"
#import "T_Fuelcons.h"
#import "T_Trip.h"
#import "CustomAnnotations.h"
#import "MapCalloutViewFillUpData.h"
#import "MapCalloutViewServiceData.h"
#import "MapCallOutViewTripData.h"
#import "GoProViewController.h"


@interface MapViewController (){
    
    
    NSMutableArray *dataArray, *fillUpArray, *serviceArray,*tripArray, *thisMonthFillups, *thisMonthServices, *todaysTrips;
    NSMutableArray *stationArray;
    NSMutableArray<MapCalloutViewFillUpData *> *mapFillUpData;
    NSMutableArray<MapCalloutViewServiceData *> *mapServiceData;
    NSMutableArray<MapCallOutViewTripData *> *mapTripData;
    UILabel *taxLabel;
    UILabel *taxValueLabel;
    UIImageView *imageView;
    int stationCount,tapCount;
    BOOL tripPresent;
}

@property int selPickerRow;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    
    self.navigationController.navigationBar.barTintColor = [self colorFromHexString:@"#0098AB"];
    self.navigationController.navigationBar.topItem.title = NSLocalizedString(@"maps", @"Maps");
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor] , NSFontAttributeName: [UIFont fontWithName:@"Helvetica-Light" size:18.0] }];
    
    //NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    UIImage *buttonImage = [[UIImage imageNamed:@"nav_back"] resizableImageWithCapInsets:UIEdgeInsetsMake(20,10,10,10)];
    UIButton *Button = [UIButton buttonWithType:UIButtonTypeCustom];
    [Button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    Button.frame = CGRectMake(0.0, 10.0, buttonImage.size.width+4,buttonImage.size.height+4);
    UIBarButtonItem *BarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:Button];
    [Button addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setLeftBarButtonItem:BarButtonItem];
    
    _vehImage.contentMode = UIViewContentModeScaleAspectFill;
    _vehImage.layer.borderWidth=0;
    _vehImage.layer.masksToBounds=YES;
    _vehImage.layer.cornerRadius = self.vehImage.frame.size.width/2;
    
    self.vehName.text = [[NSUserDefaults standardUserDefaults]objectForKey:@"vehname"];
    if([[[NSUserDefaults standardUserDefaults]objectForKey:@"vehimage"]isEqualToString:@""])
    {

        _vehImage.image=[UIImage imageNamed:@"car4.jpg"];
    }
    
    else
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
        //Swapnil ENH_24
        NSString *urlstring = [paths firstObject];
        
        NSString *vehiclepic = [NSString stringWithFormat:@"%@/%@",urlstring,[[NSUserDefaults standardUserDefaults]objectForKey:@"vehimage"]];
        _vehImage.image =[UIImage imageWithContentsOfFile:vehiclepic];
    }
    
    _tripLabel.hidden = YES;
    _rightTripButOt.hidden = YES;
    _rightTripButOt.userInteractionEnabled = NO;
    _leftTripButOt.hidden = YES;
    _leftTripButOt.userInteractionEnabled = NO;
    taxLabel.hidden = YES;
    taxValueLabel.hidden = YES;
    
    self.mapView.delegate = self;
    taxLabel = [[UILabel alloc] init];
    taxValueLabel = [[UILabel alloc] init];
  
    [_mapView setFrame:CGRectMake(0, _tripLabel.frame.origin.y-1, self.view.frame.size.width, self.view.frame.size.height/1.5)];
    
    [taxLabel setFrame:CGRectMake(_mapView.frame.origin.x+_mapView.frame.size.width-140, 20, 180, 30)];
    taxLabel.text = NSLocalizedString(@"tax_deductions", @"Tax deductions");
    taxLabel.textAlignment = NSTextAlignmentLeft;
    [_mapView addSubview:taxLabel];
    taxLabel.hidden = YES;
    
    [taxValueLabel setFrame:CGRectMake(taxLabel.frame.origin.x-3, taxLabel.frame.origin.y+20, 150, 40)];
    taxValueLabel.textAlignment = NSTextAlignmentLeft;
    [_mapView addSubview:taxValueLabel];
    taxValueLabel.hidden = YES;
    
    [self fetchdata];
    [self fetchFillups];
   // [self selectedsegment];
    [self setSegment];
    
}

- (IBAction)backButtonPressed: (id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

//Swapnil 14 Mar-17
#if __IPHONE_OS_VERSION_MAX_ALLOWED < 90000
- (NSUInteger)supportedInterfaceOrientations
#else
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
#endif
{
    return UIInterfaceOrientationMaskPortrait;
}

-(BOOL)shouldAutorotate
{
    return NO;
}

-(UIColor *)colorFromHexString:(NSString *)hexString
{
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

-(void)setSegment{
    
    [self fetchtrips];
    
    tripPresent = NO;
    
    NSDateFormatter *formater=[[NSDateFormatter alloc] init];
    [formater setDateFormat:@"dd MM yyyy"];
    
    //Last 7 days
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitMonth|NSCalendarUnitDay fromDate:[NSDate date]];
    
    NSDate *today = [[NSDate alloc] init];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    [offsetComponents setDay:-7];
    NSDate *last90thday = [gregorian dateByAddingComponents:offsetComponents toDate:today options:0];
    
    //current year
    NSDateFormatter *formater1=[[NSDateFormatter alloc] init];
    [formater1 setDateFormat:@"yyyy"];
    NSString *currentyear = [formater1 stringFromDate:[NSDate date]];
    
    //last year
    NSDate *today1 = [[NSDate alloc] init];
    NSCalendar *gregorian1 = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *offsetComponents1 = [[NSDateComponents alloc] init];
    [offsetComponents1 setYear:-1];
    NSDate *lastYear = [gregorian1 dateByAddingComponents:offsetComponents1 toDate:today1 options:0];
    
    
    if(components.month!=12)
    {
        for(T_Trip *trip in tripArray)
        {
            if((([last90thday compare:trip.depDate] == NSOrderedAscending && [today compare:trip.depDate] == NSOrderedDescending) || ([last90thday compare:trip.depDate] == NSOrderedSame) || ([today compare:trip.depDate] == NSOrderedSame)) && [[formater1 stringFromDate:trip.depDate] isEqualToString:currentyear])
            {
                tripPresent = YES;
            }
        }
        
    }
    
    else
    {
        for(T_Trip *trip in tripArray)
        {
            if((([last90thday compare:trip.depDate] == NSOrderedAscending && [today compare:trip.depDate] == NSOrderedDescending) || ([last90thday compare:trip.depDate] == NSOrderedSame) || ([today compare:trip.depDate] == NSOrderedSame)) && [[formater1 stringFromDate:trip.depDate] isEqualToString:[formater1 stringFromDate:lastYear]])
            {
                tripPresent = YES;
            }
        }
    }
    
    [self.segment removeAllSegments];
    if(tripPresent){
        
        
        [self.segment insertSegmentWithTitle: @"Trips" atIndex: 0 animated: NO];
        [self.segment insertSegmentWithTitle: @"Fillups & Services" atIndex: 1 animated: NO];
        
    }else{
        
        [self.segment insertSegmentWithTitle: @"Fillups & Services" atIndex: 0 animated: NO];
        [self.segment insertSegmentWithTitle: @"Trips" atIndex: 1 animated: NO];
    }
   
    [self.segment setSelectedSegmentIndex:0];
    [self.segment addTarget:self action:@selector(selectedsegment) forControlEvents:UIControlEventValueChanged];
    [self selectedsegment];
    
}

-(void)selectedsegment {
    
    [self Update_Date_By:0];
    
    if(!tripPresent){
        
        if(self.segment.selectedSegmentIndex == 0){
            
            [_mapView setFrame:CGRectMake(0, _tripLabel.frame.origin.y-1, self.view.frame.size.width, self.view.frame.size.height/1.5)];
            [imageView removeFromSuperview];
            taxLabel.hidden = YES;
            taxValueLabel.hidden = YES;
            _tripLabel.hidden = YES;
            _rightTripButOt.hidden = YES;
            _rightTripButOt.userInteractionEnabled = NO;
            _leftTripButOt.hidden = YES;
            _leftTripButOt.userInteractionEnabled = NO;
            
        }
        else {
            
            BOOL proUserSubscribed = [[NSUserDefaults standardUserDefaults] boolForKey:@"isSubscribed"];
            if(!proUserSubscribed){
                
                [self showUpgradeView];
            }
            
        }
    }else{
        
        if(self.segment.selectedSegmentIndex == 0){
            
            BOOL proUserSubscribed = [[NSUserDefaults standardUserDefaults] boolForKey:@"isSubscribed"];
            if(!proUserSubscribed){
                
                [self showUpgradeView];
            }
            
        }
        else {
            
            [_mapView setFrame:CGRectMake(0, _tripLabel.frame.origin.y-1, self.view.frame.size.width, self.view.frame.size.height/1.5)];
            [imageView removeFromSuperview];
            taxValueLabel.hidden = YES;
            taxLabel.hidden = YES;
            _tripLabel.hidden = YES;
            _rightTripButOt.hidden = YES;
            _rightTripButOt.userInteractionEnabled = NO;
            _leftTripButOt.hidden = YES;
            _leftTripButOt.userInteractionEnabled = NO;
        }
    }
    
   
}

-(void)showUpgradeView{
    
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y+self.segment.frame.origin.y+self.segment.frame.size.height, self.view.frame.size.width, self.view.frame.size.height-(self.view.frame.origin.y+self.segment.frame.origin.y+self.segment.frame.size.height))];
    
    imageView.image = [UIImage imageNamed:@"mapBlurView"];
    
    [self.view addSubview:imageView];
    
    UILabel *upgradeLabel = [[UILabel alloc] init];
    [upgradeLabel setFrame:CGRectMake(imageView.frame.size.width/2-140, imageView.frame.size.height/2-30, 280, 50)];
    upgradeLabel.numberOfLines = 2; //TODO localizaed string
    upgradeLabel.text = @"To view trip maps please upgrade to Platinum membership.";
    upgradeLabel.textAlignment = NSTextAlignmentCenter;
    [upgradeLabel setFont:[UIFont boldSystemFontOfSize:17]];
    [imageView addSubview:upgradeLabel];
    
    UIButton *upgradeButton = [[UIButton alloc] init];
    [upgradeButton setFrame:CGRectMake(imageView.frame.size.width/2-50, upgradeLabel.frame.origin.y+60, 100, 40)];
    [upgradeButton addTarget:self action:@selector(showGoProScreen) forControlEvents:UIControlEventTouchUpInside];
    NSString *yourString = @"Upgrade";
    NSMutableAttributedString *yourAttributedString = [[NSMutableAttributedString alloc] initWithString:yourString];
    NSString *boldString = @"Upgrade";
    NSRange boldRange = [yourString rangeOfString:boldString];
    [yourAttributedString addAttribute: NSFontAttributeName value:[UIFont boldSystemFontOfSize:17] range:boldRange];
    [yourAttributedString addAttribute: NSForegroundColorAttributeName value:[UIColor whiteColor] range:boldRange];
    [upgradeButton setAttributedTitle:yourAttributedString forState:UIControlStateNormal];

    upgradeButton.backgroundColor = [self colorFromHexString:@"#FFCA1D"];
    upgradeButton.layer.cornerRadius = 10;
    upgradeButton.userInteractionEnabled = YES;
    imageView.userInteractionEnabled = YES;
    
    [imageView addSubview:upgradeButton];
    
}

-(void)showGoProScreen{
    
    GoProViewController *gopro = (GoProViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"gopro"];
    dispatch_async(dispatch_get_main_queue(), ^{
        gopro.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:gopro animated:YES completion:nil];
    });
}

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
    
    [_picker removeFromSuperview];
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
    
    
    //self.pickerval = @"Select";
    
    UIBezierPath *maskPath;
    maskPath = [UIBezierPath bezierPathWithRoundedRect:_picker.bounds
                                     byRoundingCorners:(UIRectCornerTopLeft|UIRectCornerTopRight)
                                           cornerRadii:CGSizeMake(5.0, 5.0)];
    
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.view.frame;
    maskLayer.path = maskPath.CGPath;
    _picker.layer.mask = maskLayer;
    
    
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
    return  self.vehiclearray.count;
}


- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSDictionary *dictionary = [[NSDictionary alloc]init];
    dictionary = [self.vehiclearray objectAtIndex:row];
    return [NSString stringWithFormat:@"%@ %@",[dictionary objectForKey:@"Make"],[dictionary objectForKey:@"Model"]];
    
}

//NIKHIL BUG_131 added below method
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    _selPickerRow = (int)[pickerView selectedRowInComponent:0];
    NSUserDefaults *setRowValue = [NSUserDefaults standardUserDefaults];
    [setRowValue setInteger:_selPickerRow forKey:@"rowValue"];
}

-(void)donelabel
{
    [self.picker removeFromSuperview];
    [self.setbutton removeFromSuperview];
    NSUserDefaults *def =[NSUserDefaults standardUserDefaults];
    NSDictionary *dictionary = [[NSDictionary alloc]init];
    dictionary = [self.vehiclearray objectAtIndex:[self.picker selectedRowInComponent:0]];
    [[NSUserDefaults standardUserDefaults]setObject:[dictionary objectForKey:@"Id"] forKey:@"fillupid"];
    [[NSUserDefaults standardUserDefaults]setObject:[NSString stringWithFormat:@"%@ %@",[dictionary objectForKey:@"Make"],[dictionary objectForKey:@"Model"]] forKey:@"fillupmake"];
    [def setObject:[def objectForKey:@"fillupid"] forKey:@"oldFillupid"];

    self.vehName.text = [NSString stringWithFormat:@"%@ %@",[dictionary objectForKey:@"Make"],[dictionary objectForKey:@"Model"]];
    
    [def setObject:[dictionary objectForKey:@"Id"] forKey:@"idvalue"];
    [def setObject:[NSString stringWithFormat:@"%@ %@",[dictionary objectForKey:@"Make"],[dictionary objectForKey:@"Model"]] forKey:@"vehname"];
    [def setObject:[NSString stringWithFormat:@"%@",[dictionary objectForKey:@"Id"]] forKey:@"fillupid"];
    [def setObject:[dictionary objectForKey:@"Picture"] forKey:@"vehimage"];
    if([[[NSUserDefaults standardUserDefaults]objectForKey:@"vehimage"]isEqualToString:@""])
    {
       
        _vehImage.image=[UIImage imageNamed:@"car4.jpg"];
    }
    
    else
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
        //Swapnil ENH_24
        NSString *urlstring = [paths firstObject];
        
        NSString *vehiclepic = [NSString stringWithFormat:@"%@/%@",urlstring,[[NSUserDefaults standardUserDefaults]objectForKey:@"vehimage"]];
        _vehImage.image =[UIImage imageWithContentsOfFile:vehiclepic];
    }
    if(self.segment.selectedSegmentIndex==0){
       // [self fetchservice:1 :1];
    }
    else{
       // [self fetchservice:2 :0];
    }
    
}
-(void)fetchdata
{
    self.vehiclearray =[[NSMutableArray alloc]init];
    
    NSManagedObjectContext *contex = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSFetchRequest *requset=[[NSFetchRequest alloc] initWithEntityName:@"Veh_Table"];
    NSError *err;
    NSArray *data=[contex executeFetchRequest:requset error:&err];
    
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
    
}

-(void)fetchFillups{
    
    NSManagedObjectContext *contex = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSError *err;
    NSUserDefaults *Def =[NSUserDefaults standardUserDefaults];
    NSString *comparestring = [NSString stringWithFormat:@"%@",[Def objectForKey:@"fillupid"]];
    
    NSFetchRequest *requset=[[NSFetchRequest alloc] initWithEntityName:@"T_Fuelcons"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"vehid==%@ AND (type==0 OR type==1 OR type==3)" ,comparestring];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"odo"
                                                                   ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [requset setPredicate:predicate];
    [requset setSortDescriptors:sortDescriptors];
    
    
    NSArray *datavalue=[contex executeFetchRequest:requset error:&err];
    
    fillUpArray = [[NSMutableArray alloc] init];
    serviceArray = [[NSMutableArray alloc] init];
    tripArray = [[NSMutableArray alloc] init];
    
    for(T_Fuelcons *logData in datavalue){
        
        
        if([logData.type isEqual:@(0)]){
            
            [fillUpArray addObject:logData];
        }else if([logData.type isEqual:@(1)]){
            
            [serviceArray addObject:logData];
            
        }
        
    }
}

-(void)fetchtrips{
    
    NSManagedObjectContext *contex = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSError *err;
    NSUserDefaults *Def =[NSUserDefaults standardUserDefaults];
    NSString *comparestring = [NSString stringWithFormat:@"%@",[Def objectForKey:@"fillupid"]];
    
    NSFetchRequest *requset=[[NSFetchRequest alloc] initWithEntityName:@"T_Trip"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"vehId==%@" ,comparestring];
    //NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"odo"
       //                                                            ascending:YES];
    //NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [requset setPredicate:predicate];
    //[requset setSortDescriptors:sortDescriptors];
    
    
    NSArray *datavalue=[contex executeFetchRequest:requset error:&err];
    
    tripArray = [[NSMutableArray alloc] init];
    
    for(T_Trip *tripData in datavalue){
        
        [tripArray addObject:tripData];
        
    }
}

- (IBAction)vehButton:(id)sender {
    
    [self openselectpicker];
}

- (IBAction)dropdownButton:(UIButton *)sender {
    
    [self openselectpicker];
}
- (IBAction)leftArrow:(UIButton *)sender {
    
    [self Update_Date_By:-1];
    
}

- (IBAction)rightArrow:(UIButton *)sender {
    
    [self Update_Date_By:1];
    
}

- (IBAction)leftTripButton:(UIButton *)sender {
    
    tapCount--;
    if(tapCount>-1){
        
        [self showTripAnnotations:tapCount];
        self.tripLabel.text = [NSString stringWithFormat:@"%@ %i",NSLocalizedString(@"trp", @"Trip"),tapCount+1];
        
    }else
        tapCount++;
}

- (IBAction)rightTripButton:(UIButton *)sender {
    
    tapCount++;
    if(tapCount<mapTripData.count){
        
        [self showTripAnnotations:tapCount];
        self.tripLabel.text = [NSString stringWithFormat:@"%@ %i",NSLocalizedString(@"trp", @"Trip"),tapCount+1];
        
    }else
        tapCount--;
}

-(void)showTripAnnotations:(NSInteger)value{
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    MapCallOutViewTripData *tripData = [mapTripData objectAtIndex:tapCount];
    
    taxValueLabel.text = tripData.taxDed;
    [taxValueLabel setFont:[UIFont boldSystemFontOfSize:24]];
    
    CLLocationCoordinate2D depLoc = CLLocationCoordinate2DMake([tripData.depLatitude doubleValue],
                                                               [tripData.depLongitude doubleValue]);
    
    CustomAnnotations *depAnno = [[CustomAnnotations alloc] initWithTile:tripData.depTitle
                                                                Location:depLoc];
    
    depAnno.annotationType = @"3";
    [self.mapView addAnnotation:depAnno];
    
    CLLocationCoordinate2D arrLoc = CLLocationCoordinate2DMake([tripData.arrLatitude doubleValue],
                                                               [tripData.arrLongitude doubleValue]);
    
    CustomAnnotations *arrAnno = [[CustomAnnotations alloc] initWithTile:tripData.arrTitle
                                                                Location:arrLoc];
    
    arrAnno.annotationType = @"4";
    [self.mapView addAnnotation:arrAnno];
    
    [self setTripRegion];
    
}

-(void)Update_Date_By:(NSInteger)value {
    
    [self fetchFillups];
    [self fetchtrips];
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    if(!tripPresent){
        
        if(self.segment.selectedSegmentIndex == 0){
            
            [self addFillupsAndServicesOnMap:value];
            
        }else{
            
            [self addTripsOnMap:value];
        }
        
    }else{
        
        if(self.segment.selectedSegmentIndex == 0){
            
            [self addTripsOnMap:value];
            
            
        }else{
            
            [self addFillupsAndServicesOnMap:value];
        }
        
    }
    
}

-(void)addFillupsAndServicesOnMap:(NSInteger)value{
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MMM yyyy"];
    NSDate *date = [dateFormat dateFromString:_dateLabel.text];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [NSDateComponents new];
    dateComponents.month = value;
    if (value == 0) {
        date = [NSDate date];
    }
    NSDate *newDate = [calendar dateByAddingComponents:dateComponents toDate:date options:0];
    [dateFormat setDateFormat:@"MMM yyyy"];
    NSString *finalDate_String = [dateFormat stringFromDate:newDate];
    _dateLabel.text = finalDate_String;
    
    // thismonth
    NSDateFormatter *formater=[[NSDateFormatter alloc] init];
    [formater setDateFormat:@"MM"];
    NSDateFormatter *formater1=[[NSDateFormatter alloc] init];
    [formater1 setDateFormat:@"yyyy"];
    
    NSString *currentmonth = [formater stringFromDate:newDate];
    NSString *currentyear = [formater1 stringFromDate:newDate];
    
    thisMonthFillups = [[NSMutableArray alloc] init];
    thisMonthServices = [[NSMutableArray alloc] init];
    
    for(T_Fuelcons *fuel in fillUpArray)
    {
        if([[formater stringFromDate:fuel.stringDate] isEqualToString:currentmonth] && [[formater1 stringFromDate:fuel.stringDate] isEqualToString:currentyear])
        {
            [thisMonthFillups addObject: fuel];
        }
    }
    
    for(T_Fuelcons *fuel in serviceArray)
    {
        if([[formater stringFromDate:fuel.stringDate] isEqualToString:currentmonth] && [[formater1 stringFromDate:fuel.stringDate] isEqualToString:currentyear])
        {
            [thisMonthServices addObject: fuel];
        }
    }
    
    mapFillUpData = [[NSMutableArray alloc] init];
    
    NSDateFormatter *ft = [[NSDateFormatter alloc] init];
    [ft setDateFormat:@"dd/MMM/yyyy"];
    
    
    for(T_Fuelcons *log in thisMonthFillups){
        
        if([log.latitude doubleValue] > 0){
            
            NSString *fuelPump = log.fillStation;
            NSString *date;
            if(log.stringDate){
                date = [ft stringFromDate:log.stringDate];
            }
            NSString *title;
            if(!fuelPump || fuelPump.length<1){
                //fillUp has two spaces
                title = @"  ";
            }else{
                title = fuelPump;
            }
            MapCalloutViewFillUpData *fillUpData = [[MapCalloutViewFillUpData alloc] initWithLatitude:log.latitude
                                                                                            longitude:log.longitude
                                                                                                title:title
                                                                                                 date:date
                                                                                                 cost:log.cost
                                                                                                  qty:log.qty];
            [mapFillUpData addObject:fillUpData];
        }
        
    }
    
    //New_11 For more than one fillup
    NSNumberFormatter *lformatter = [NSNumberFormatter new];
    [lformatter setRoundingMode:NSNumberFormatterRoundFloor];
    [lformatter setMaximumFractionDigits:3];
    [lformatter setPositiveFormat:@"0.###"];
    NSMutableArray<fillUpLatLong *> *latLongArray = [NSMutableArray new];
    
    for(int i=0;i<mapFillUpData.count;i++){
        MapCalloutViewFillUpData *fillUpData = [mapFillUpData objectAtIndex:i];
        fillUpLatLong *latLong = [[fillUpLatLong alloc] initWithLatitude:[lformatter stringFromNumber: fillUpData.latitude] longitude:[lformatter stringFromNumber: fillUpData.longitude] title:fillUpData.title];
        
        if ([self fillUpArray:latLongArray contains:latLong]) {
            continue;
        } else {
            [latLongArray addObject:latLong];
        }
        
        // Add an annotation
        CLLocationCoordinate2D loc = CLLocationCoordinate2DMake([fillUpData.latitude doubleValue],
                                                                [fillUpData.longitude doubleValue]);
        CustomAnnotations *fillAnno = [[CustomAnnotations alloc] initWithTile:fillUpData.title
                                                                     Location:loc];
        fillAnno.annotationType = @"0";
        
        [self.mapView addAnnotation:fillAnno];
    }
    
    mapServiceData = [[NSMutableArray alloc] init];
    
    for(T_Fuelcons *log in thisMonthServices){
        
        if([log.latitude doubleValue] > 0){
            
            NSString *fuelPump = log.fillStation;
            NSString *date;
            if(log.stringDate){
                date = [ft stringFromDate:log.stringDate];
            }
            NSString *title;
            if(!fuelPump || fuelPump.length<1){
                title = @" ";
            }else{
                title = fuelPump;
            }
            
            MapCalloutViewServiceData *serviceData = [[MapCalloutViewServiceData alloc] initWithLatitude:log.latitude longitude:log.longitude title:title date:date name:log.serviceType];
            
            [mapServiceData addObject:serviceData];
        }
        
    }
    
    NSMutableArray<serLatLong *> *serlatLongArray = [NSMutableArray new];
    for(int i=0;i<mapServiceData.count;i++){
        
        MapCalloutViewServiceData *serviceData = [mapServiceData objectAtIndex:i];
        
        serLatLong *latLong = [[serLatLong alloc] initWithLatitude:[lformatter stringFromNumber: serviceData.latitude] longitude:[lformatter stringFromNumber: serviceData.longitude] title:serviceData.title];
        if ([self serArray:serlatLongArray contains:latLong]) {
            continue;
        } else {
            [serlatLongArray addObject:latLong];
        }
        
        CLLocationCoordinate2D loc = CLLocationCoordinate2DMake([serviceData.latitude doubleValue],
                                                                [serviceData.longitude doubleValue]);
        CustomAnnotations *serAnno = [[CustomAnnotations alloc] initWithTile:serviceData.title
                                                                    Location:loc];
        
        serAnno.annotationType = @"1";
        [self.mapView addAnnotation:serAnno];
        
    }
    
    [self setRegion];
   
}

-(void)addTripsOnMap:(NSInteger)value{
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd/MM/yyyy"];
    NSDate *date = [dateFormat dateFromString:_dateLabel.text];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [NSDateComponents new];
    dateComponents.day = value;
    if (value == 0) {
        date = [NSDate date];
    }
    NSDate *newDate = [calendar dateByAddingComponents:dateComponents toDate:date options:0];
    [dateFormat setDateFormat:@"dd/MM/yyyy"];
    NSString *finalDate_String = [dateFormat stringFromDate:newDate];
    _dateLabel.text = finalDate_String;
    
    todaysTrips = [[NSMutableArray alloc] init];
    
    NSDateFormatter *ft = [[NSDateFormatter alloc] init];
    [ft setDateFormat:@"hh:mm a"];
    
    for(T_Trip *trip in tripArray){
        
        if([[dateFormat stringFromDate:trip.depDate] isEqualToString:finalDate_String])
            [todaysTrips addObject: trip];
        
    }
    
    if(todaysTrips.count>0){
        
        mapTripData = [[NSMutableArray alloc] init];
        
        for(T_Trip *trip in todaysTrips){
            
            if([trip.depLatitude doubleValue] > 0 || [trip.arrLatitude doubleValue] > 0){
                
                NSString *depLocString = trip.depLocn;
                NSString *arrLocString = trip.arrLocn;
                
                NSString *depDate;
                NSString *arrDate;
                if(trip.depDate)
                    depDate = [ft stringFromDate:trip.depDate];
                
                if(trip.arrDate)
                    arrDate = [ft stringFromDate:trip.arrDate];
                
                NSString *depTitle;
                NSString *arrTitle;
                
                if(!depLocString || depLocString.length<1){
                    depTitle = @" ";
                }else{
                    depTitle = depLocString;
                }
                if(!arrLocString || arrLocString.length<1){
                    arrTitle = @" ";
                }else{
                    arrTitle = arrLocString;
                }
                
                NSArray *array = [[[NSUserDefaults standardUserDefaults]objectForKey:@"curr_unit"] componentsSeparatedByString:@"-"];
                NSString *currString = [array lastObject];
                
                NSString *taxDeduc = [NSString stringWithFormat:@"%@ %@",currString,trip.taxDedn];
                
                MapCallOutViewTripData *tripData = [[MapCallOutViewTripData alloc] initWithDepLatitude:trip.depLatitude depLongitude:trip.depLongitude arrLatitude:trip.arrLatitude arrLongitude:trip.arrLongitude depTitle:depTitle arrTitle:arrTitle depDate:depDate arrDate:arrDate taxDed:taxDeduc];
                
                [mapTripData addObject:tripData];
            }
            
        }
        
        if(mapTripData.count>1){
            
            [_mapView setFrame:CGRectMake(0, _tripLabel.frame.origin.y+30, self.view.frame.size.width, self.view.frame.size.height/1.5-31)];
            _tripLabel.hidden = NO;
            _rightTripButOt.hidden = NO;
            _rightTripButOt.userInteractionEnabled = YES;
            _leftTripButOt.hidden = NO;
            _leftTripButOt.userInteractionEnabled = YES;
            taxLabel.hidden = NO;
            taxValueLabel.hidden = NO;
            
            MapCallOutViewTripData *tripData = [mapTripData firstObject];
            
            taxValueLabel.text = tripData.taxDed;
            [taxValueLabel setFont:[UIFont boldSystemFontOfSize:24]];
            
            CLLocationCoordinate2D depLoc = CLLocationCoordinate2DMake([tripData.depLatitude doubleValue],
                                                                       [tripData.depLongitude doubleValue]);
            
            CustomAnnotations *depAnno = [[CustomAnnotations alloc] initWithTile:tripData.depTitle
                                                                        Location:depLoc];
            
            depAnno.annotationType = @"3";
            [self.mapView addAnnotation:depAnno];
            
            CLLocationCoordinate2D arrLoc = CLLocationCoordinate2DMake([tripData.arrLatitude doubleValue],
                                                                       [tripData.arrLongitude doubleValue]);
            
            CustomAnnotations *arrAnno = [[CustomAnnotations alloc] initWithTile:tripData.arrTitle
                                                                        Location:arrLoc];
            
            arrAnno.annotationType = @"4";
            [self.mapView addAnnotation:arrAnno];
            
        }else{
            
            [_mapView setFrame:CGRectMake(0, _tripLabel.frame.origin.y-1, self.view.frame.size.width, self.view.frame.size.height/1.5)];
            _tripLabel.hidden = YES;
            _rightTripButOt.hidden = YES;
            _rightTripButOt.userInteractionEnabled = NO;
            _leftTripButOt.hidden = YES;
            _leftTripButOt.userInteractionEnabled = NO;
            taxLabel.hidden = YES;
            taxValueLabel.hidden = YES;
        }
        
    }
    
    [self setTripRegion];
    tapCount=0;
}

-(void)setRegion{
    
    CLLocationCoordinate2D coord;
    
    BOOL foundCoord = NO;
    
    if(mapFillUpData.count>0){
        
        for(int i=0;i<mapFillUpData.count;i++){
            
            if([mapFillUpData objectAtIndex:i].latitude > 0){
                
                coord = CLLocationCoordinate2DMake([[mapFillUpData objectAtIndex:i].latitude doubleValue],
                                                   [[mapFillUpData objectAtIndex:i].longitude doubleValue]);
                foundCoord = YES;
                break;
                
            }else{
                
                foundCoord = NO;
            }
        }
        
    }
    
    if(mapServiceData.count>0 && !foundCoord){
        
        for(int i=0;i<mapServiceData.count;i++){
            
            if([mapServiceData objectAtIndex:i].latitude > 0){
                
                coord = CLLocationCoordinate2DMake([[mapServiceData objectAtIndex:i].latitude doubleValue], [[mapServiceData objectAtIndex:i].longitude doubleValue]);
                foundCoord = YES;
                break;
                
            }else{
                
                coord = self.mapView.region.center;
                foundCoord = NO;
                
            }
        }
        
    }else if(!foundCoord){
        
        coord = self.mapView.region.center;
        
    }
    
    self.mapView.showsUserLocation = NO;
    MKCoordinateRegion viewRegion;
    
    if(foundCoord){
        
        if(self.mapView.annotations.count>2){
            viewRegion = MKCoordinateRegionMakeWithDistance(coord, 10000, 10000);
        }else{
            viewRegion = MKCoordinateRegionMakeWithDistance(coord, 1000, 1000);
        }
    }else{
        
        viewRegion = MKCoordinateRegionMakeWithDistance(coord, 10000000, 10000000);
    }
    
    
    [self.mapView setRegion:viewRegion animated:YES];
}

-(void)setTripRegion{
    
    CLLocationCoordinate2D coord;
    
    BOOL foundCoord = NO;
    
    if(mapTripData.count>0){
        
        for(int i=0;i<mapTripData.count;i++){
            
            if([mapTripData objectAtIndex:i].depLatitude > 0){
                
                coord = CLLocationCoordinate2DMake([[mapTripData objectAtIndex:i].depLatitude doubleValue],
                                                   [[mapTripData objectAtIndex:i].depLongitude doubleValue]);
                foundCoord = YES;
                break;
                
            }else{
                
                coord = self.mapView.region.center;
                foundCoord = NO;
            }
        }
        
    }else{
        
        coord = self.mapView.region.center;
        
    }
    
    self.mapView.showsUserLocation = NO;
    MKCoordinateRegion viewRegion;
    
    if(foundCoord){
        
        if(self.mapView.annotations.count>2){
            viewRegion = MKCoordinateRegionMakeWithDistance(coord, 100000, 100000);
        }else{
            viewRegion = MKCoordinateRegionMakeWithDistance(coord, 10000, 10000);
        }
    }else{
        
        viewRegion = MKCoordinateRegionMakeWithDistance(coord, 10000000, 10000000);
    }
    
    
    [self.mapView setRegion:viewRegion animated:YES];
}

- (BOOL)fillUpArray:(NSArray<fillUpLatLong *> *)array contains:(fillUpLatLong *)value {
    for (fillUpLatLong *latLong in array) {
        if ([value isEqual:latLong]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)serArray:(NSArray<serLatLong *> *)array contains:(serLatLong *)value {
    for (serLatLong *latLong in array) {
        if ([value isEqual:latLong]) {
            return YES;
        }
    }
    return NO;
}

#pragma mark MapView Delegate methods

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    
    //NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    
    if([annotation isKindOfClass:[CustomAnnotations class]]){
        
        
        CustomAnnotations *location = (CustomAnnotations *)annotation;
        MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"FillUpAnnotations"];
        
        if(annotationView == nil){
            
            annotationView = location.annotationView;
        }else{
            annotationView.annotation = annotation;
        }
        
        if([((CustomAnnotations *)annotation).annotationType isEqualToString: @"0"]){
            annotationView.image=[UIImage imageNamed:@"map_fillup"];
        }
        else if([((CustomAnnotations *)annotation).annotationType isEqualToString: @"1"]){
            annotationView.image=[UIImage imageNamed:@"map_service"];
        }
        else if([((CustomAnnotations *)annotation).annotationType isEqualToString: @"3"]){
            annotationView.image=[UIImage imageNamed:@"map_trip_start"];
        }
        else if([((CustomAnnotations *)annotation).annotationType isEqualToString: @"4"]){
            annotationView.image=[UIImage imageNamed:@"map_trip_end"];
        }
        
        return annotationView;
    }else{
        
        return nil;
    }
    
}

-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
    
    UILabel *subTitlelbl = [[UILabel alloc]init];
    
    NSArray *array = [[[NSUserDefaults standardUserDefaults]objectForKey:@"curr_unit"] componentsSeparatedByString:@"-"];
    NSString *currString = [array lastObject];
    //Fabric Bug solved
    //NSString *volString = [[[NSUserDefaults standardUserDefaults]objectForKey:@"vol_unit"] stringValue];
    NSString *volString = [[NSUserDefaults standardUserDefaults]objectForKey:@"vol_unit"];
    NSNumberFormatter *lformatter = [NSNumberFormatter new];
    [lformatter setRoundingMode:NSNumberFormatterRoundFloor];
    [lformatter setMaximumFractionDigits:3];
    [lformatter setPositiveFormat:@"0.###"];
    
    stationCount = 0;
    
    if ([view.annotation isKindOfClass:[CustomAnnotations class]]) {
        CustomAnnotations *annotation = (CustomAnnotations *)view.annotation;
        
        NSString *latFString = [lformatter stringFromNumber: [NSNumber numberWithDouble:annotation.coordinate.latitude]];
        NSString *longFString = [lformatter stringFromNumber: [NSNumber numberWithDouble:annotation.coordinate.longitude]];
        stationArray = [[NSMutableArray alloc] init];
        
        for(int i=0;i<mapFillUpData.count;i++){
            
            NSString *latSString = [lformatter stringFromNumber: [mapFillUpData objectAtIndex:i].latitude];
            NSString *longSString = [lformatter stringFromNumber: [mapFillUpData objectAtIndex:i].longitude];
            if([annotation.title isEqualToString:[mapFillUpData objectAtIndex:i].title]
               && [latFString isEqualToString: latSString]
               && [longFString isEqualToString: longSString]){
              
                NSString *fillstring = [[mapFillUpData objectAtIndex:i] fillUpStringWith:volString currString:currString];
                [stationArray addObject:fillstring];
                if(stationCount<1){
                    subTitlelbl.text = fillstring;
                    stationCount = stationCount+1;
                }else{
                    stationCount = stationCount+1;
                    
                }
            }
        }
        
        for(int j=0;j<mapServiceData.count;j++){
            
            NSString *latSString = [lformatter stringFromNumber: [mapServiceData objectAtIndex:j].latitude];
            NSString *longSString = [lformatter stringFromNumber: [mapServiceData objectAtIndex:j].longitude];
            
            if([annotation.title isEqualToString:[mapServiceData objectAtIndex:j].title]
               && [latFString isEqualToString: latSString]
               && [longFString isEqualToString: longSString]){
                
                NSString *serString = [[mapServiceData objectAtIndex:j] serviceStringWith];
                [stationArray addObject:serString];
                if(stationCount<1){
                    
                    subTitlelbl.text = serString;
                    stationCount = stationCount+1;
                    
                }else{
                    
                    stationCount=stationCount+1;
                    
                    
                }
                
            }
        }
        
        for(int j=0;j<mapTripData.count;j++){
            
            
            NSString *latDString = [lformatter stringFromNumber: [mapTripData objectAtIndex:j].depLatitude];
            NSString *longDString = [lformatter stringFromNumber: [mapTripData objectAtIndex:j].depLongitude];
            NSString *latAtring = [lformatter stringFromNumber: [mapTripData objectAtIndex:j].arrLatitude];
            NSString *longAtring = [lformatter stringFromNumber: [mapTripData objectAtIndex:j].arrLongitude];
           
            if([annotation.title isEqualToString:[mapTripData objectAtIndex:j].depTitle]
               && [latFString isEqualToString: latDString]
               && [longFString isEqualToString: longDString]){
                
                NSString *tripString = [[mapTripData objectAtIndex:j] tripDepStringWith];
                subTitlelbl.text = tripString;
                
            }
            else if([annotation.title isEqualToString:[mapTripData objectAtIndex:j].arrTitle]
                    && [latFString isEqualToString: latAtring]
                    && [longFString isEqualToString: longAtring]){
                
                NSString *tripString = [[mapTripData objectAtIndex:j] tripArrStringWith];
                subTitlelbl.text = tripString;
                
            }
        }
        
    }
    
    [subTitlelbl setFont: [subTitlelbl.font fontWithSize:13]];
    
    view.detailCalloutAccessoryView = subTitlelbl;
    [subTitlelbl setNumberOfLines:0];
    [[[subTitlelbl widthAnchor] constraintEqualToConstant:100] setActive:YES];
   
    if ([view.annotation isKindOfClass:[CustomAnnotations class]]) {
        
        CustomAnnotations *annotation = (CustomAnnotations *)view.annotation;
        
        if([annotation.annotationType isEqualToString: @"3"] || [annotation.annotationType isEqualToString: @"4"]){
            
            
        }else{
            
            if(stationCount>1){
                
                view.rightCalloutAccessoryView = [self countButton];
                tapCount=1;
            }
        }
        
    }
    
}

- (UIButton *)countButton {
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 30, 30);
    button.layer.cornerRadius = 15;
    button.layer.masksToBounds=YES;
    button.backgroundColor = UIColor.lightGrayColor;
    [button setTitle:[NSString stringWithFormat:@"%i",stationCount] forState:UIControlStateNormal];
    [button setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    
    return button;
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    UILabel *subTitlelbl = (UILabel *)view.detailCalloutAccessoryView;
    [subTitlelbl setFont: [subTitlelbl.font fontWithSize:13]];
    if(tapCount<stationCount){
       subTitlelbl.text = [stationArray objectAtIndex:tapCount];
       tapCount++;
    }else if(tapCount==stationCount){
        
        subTitlelbl.text = [stationArray objectAtIndex:0];
        tapCount=0;
    }
}
@end
