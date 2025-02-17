//
//  AddTripViewController.m
//  FuelBuddy
//
//  Created by Nupur on 07/09/16.
//  Copyright © 2016 Oraganization. All rights reserved.
//

#import "AddTripViewController.h"
#import "AppDelegate.h"
#import "Veh_Table.h"
#import "Services_Table.h"
#import "T_Fuelcons.h"
#import "T_Trip.h"
#import "JRNLocalNotificationCenter.h"
#import "AutorotateNavigation.h"
#import "LogViewController.h"
#import "commonMethods.h"
#import "LocationServices.h"
#import "GoProViewController.h"
#import <Crashlytics/Crashlytics.h>
#import "Loc_Table.h"
#import "Sync_Table.h"
#import "Reachability.h"
#import "WebServiceURL's.h"
#import "CustomiseTripViewController.h"
#import "TaxDeductionViewController.h"
#import "CheckReachability.h"

@import UserNotifications;


@interface AddTripViewController ()
{
    NSDateFormatter *f;
    NSString* maxOdo;
    CGPoint buttonOrigin;
    CGFloat oldX;
    CGFloat oldY ;
    NSDate* arrDate;
    float prevOdo;
    NSString* recOrder;
    NSNumber *depLat, *depLong, *arrLat, *arrLong;
    //NIKHIL BUG_151
    //NSNumber *saveDepLat, *saveDepLong, *saveArrLat, *saveArrLong;
    //BOOL gpsSelected;
    
}
//NIKHIL BUG_131 //added property
@property int selPickerRow;

@end

@implementation AddTripViewController{
    
    //Swapnil NEW_5
    CLPlacemark *placemark;
    CLGeocoder *geoCoder;
    double gpsDistance;
}

- (void)viewDidLoad {


    [super viewDidLoad];
    
     //Nikhil ENH_51
    [self createPageVC];
    //Swapnil 14 Mar-17
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
   
    if([[NSUserDefaults standardUserDefaults]objectForKey:@"editdetails"]!=nil)
    {
         self.editTripDict = [[[NSUserDefaults standardUserDefaults]objectForKey:@"editdetails"]mutableCopy];
    }
    
    UIImage *buttonImage = [[UIImage imageNamed:@"nav_back"] resizableImageWithCapInsets:UIEdgeInsetsMake(20,10,10,10)];
    UIButton *Button = [UIButton buttonWithType:UIButtonTypeCustom];
    [Button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    Button.frame = CGRectMake(0.0, 10.0, buttonImage.size.width+4,buttonImage.size.height+4);
    UIBarButtonItem *BarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:Button];
    [Button addTarget:self action:@selector(backButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    [self.navigationItem setLeftBarButtonItem:BarButtonItem];

    self.navigationController.navigationBar.barTintColor = [self colorFromHexString:@"#0098AB"];
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.tintColor =[UIColor whiteColor];
    self.navigationController.navigationBar.topItem.title = NSLocalizedString(@"add_trip", @"Add Trip");
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor] , NSFontAttributeName: [UIFont fontWithName:@"Helvetica-Light" size:18.0] }];
    
    self.view.backgroundColor = [self colorFromHexString:@"#2c2c2c"];
    self.saveButton.layer.cornerRadius = 6; // this value vary as per your desire
    self.saveButton.clipsToBounds = YES;
    
    _vehImage.contentMode = UIViewContentModeScaleAspectFill;
    _vehImage.layer.borderWidth=0;
    _vehImage.layer.masksToBounds=YES;
    _vehImage.layer.cornerRadius = 21;
    
    
    self.vehName.text = [[NSUserDefaults standardUserDefaults]objectForKey:@"vehname"];
    if([[[NSUserDefaults standardUserDefaults]objectForKey:@"vehimage"]isEqualToString:@""])
    {
        // NSLog(@"blank....");
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
    
    [self.vehicleButton addTarget:self action:@selector(openVehiclePicker) forControlEvents:UIControlEventTouchUpInside];
    
    
    _depDateTimeField.delegate = self;
    _depOdoField.delegate = self;
    _depLocnField.delegate = self;
    _arrOdoField.delegate = self;
    _arrDateTimeFld.delegate = self;
    _arrLocnField.delegate=self;
    _parkingField.delegate=self;
    _tollField.delegate=self;
    _notesView.delegate=self;
    _taxPercField.delegate = self;
    _distanceField.delegate = self;
    [self textfieldSetting:self.distanceField];
    [self textfieldSetting:self.tollField];
    [self textfieldSetting:self.parkingField];
    [self textfieldSetting:self.depOdoField];
    [self textfieldSetting:self.depLocnField];
    [self textfieldSetting:self.depDateTimeField];
    [self textfieldSetting:self.arrOdoField];
    [self textfieldSetting:self.arrLocnField];
    [self textfieldSetting:self.arrDateTimeFld];
    [self textfieldSetting:self.taxPercField];
    
    //set Date
    f=[[NSDateFormatter alloc] init];
    [f setDateStyle:NSDateFormatterLongStyle];
    
    [f setDateFormat:@"dd-MMM-yyyy hh:mm aa"];
    [f setAMSymbol:@"AM"];
    [f setPMSymbol:@"PM"];

    NSString *today=[f stringFromDate:[NSDate date ]];
    //NSLog(@"Date is: %@", today );
    _depDateTimeField.text = today;
    
    self.miLabel2.hidden = NO;
    //Get and Set maxOdo
    [self setMaxOdo];

    //Swapnil NEW_5
    geoCoder = [[CLGeocoder alloc] init];
    
    //NSLog(@"%@", [[NSUserDefaults standardUserDefaults] dictionaryRepresentation]);
    
    [self checkOdoSettings];
    self.gpsView.hidden = NO;
    self.gpsButton.hidden = NO;
    self.gpsButton.userInteractionEnabled = YES;
    self.trackTripLabel.hidden = NO;
    //New_10 Nikhil 1December2018 Auto Trip Loging
    self.trackTripLabel.text = NSLocalizedString(@"track_via_gps", @"Track trip via GPS");
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

-(void)viewWillAppear:(BOOL)animated
{
    //To scroll contentview when keyboard appears
    
    [self registerForKeyboardNotifications];
  
    // Fetch Vehicles data from DB
    [self fetchVehiclesData]; //fills vehicle array
    [self fetchTripTypeData]; //fills tripTypeArray
    [self fetchTripData];
    
    self.navigationController.navigationBarHidden = NO;
    
    //Set Default trip Type

    //If Trip Types are not in the DBase can happen during restore, Load those first
    if (self.tripTypeArray.count == 0)
    {
        AppDelegate *App = [AppDelegate sharedAppDelegate];
        
        [App saveTrip];
        [self fetchTripTypeData];
    }
    
    //NIKHIL BUG_127 added edit trip title
    if([[NSUserDefaults standardUserDefaults]objectForKey:@"editdetails"]!=nil)
    {
        
        self.navigationController.navigationBar.topItem.title = NSLocalizedString(@"edit_trip", @"Edit Trip");
    }
    
    NSDictionary *dictionary = [self.tripTypeArray objectAtIndex:[self.picker selectedRowInComponent:0]];
   
    //NSLog(@"tripType arr = %@", dictionary);
    
    if(self.editTripDict.count > 0){
    _typeLabel.text = [_editTripDict objectForKey:@"tripType"];
    
    
    //Swapnil BUG_51
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"serviceName == %@", _typeLabel.text];
    NSArray *selectedArray = [self.tripTypeArray filteredArrayUsingPredicate:predicate];
    
       //NSLog(@"%@",selectedArray);
        if(selectedArray.count > 0){
            
            //Swapnil ENH_24
            //NIKHIL ENH_40 //Calculating _taxPercfield for old record
            float startOdo = [[_editTripDict objectForKey:@"odo"] floatValue];
            float endOdo = [[_editTripDict objectForKey:@"arrOdo"] floatValue];
            
            float totalTaxDedn = [[_editTripDict objectForKey:@"cost"] floatValue];
            float rate = ( totalTaxDedn - [_parkingField.text floatValue] - [_tollField.text floatValue] ) / (endOdo-startOdo);
            _taxPercField.text = totalTaxDedn > 0 ? [NSString stringWithFormat:@"%.3f", rate] :[[[selectedArray firstObject] valueForKey:@"rate"] stringValue];
  
        }
    }
    //NIKHIL BUG_160 added if for tripType
    else if(self.tripArray.count > 0){
        //NIKHIL BUG_160 check if tripArray has record!
//        _typeLabel.text = [self.tripArray valueForKey:@"tripType"];
//        _taxPercField.text = [[dictionary objectForKey:@"rate"] stringValue];
           //NSLog(@"Do nothing from here");
    }else {
        _typeLabel.text = [dictionary objectForKey:@"serviceName"];
        _taxPercField.text = [[dictionary objectForKey:@"rate"] stringValue];
        
    }

    //NSLog(@"tax percentage field = %@", _taxPercField.text);

    
    //Swapnil 10 Mar-17
    _taxPercField.userInteractionEnabled = YES;
    _taxPercField.keyboardType = UIKeyboardTypeDecimalPad;
    _taxRateLabel.hidden = NO;
    
    
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"maxodo"]!=nil) {
        _depOdoField.text=[[NSUserDefaults standardUserDefaults] objectForKey:@"maxodo"];
        _depOdoLabel.hidden = NO;
    }
    
    
    NSArray *array = [[[NSUserDefaults standardUserDefaults]objectForKey:@"curr_unit"] componentsSeparatedByString:@"-"];
    NSString *string = [array lastObject];
    _usdLabel.text = string;
    _usdLabel2.text = string;
    _usdLabel3.text = string;
    
    if([[[NSUserDefaults standardUserDefaults]objectForKey:@"dist_unit"] isEqualToString:NSLocalizedString(@"disp_miles", @"Miles")])
    {
        _miLabel1.text = NSLocalizedString(@"mi", @"mi");
        _miLabel2.text = NSLocalizedString(@"mi", @"mi");
        _miLabel3.text = NSLocalizedString(@"mi", @"mi");
    }
    
    else
    {
        _miLabel1.text = NSLocalizedString(@"kms", @"km");
        _miLabel2.text = NSLocalizedString(@"kms", @"km");
        _miLabel3.text = NSLocalizedString(@"kms", @"km");
    }


    _usdpermiLabel.text = [[_usdLabel.text stringByAppendingString:@"/"] stringByAppendingString:_miLabel1.text];
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];

    //Swapnil NEW_5
    //Auto populate dep_loc if it is new trip
    if(self.editTripDict.count == 0){
        
        //Requset permission for location access to singleton class
        NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
        BOOL tripLocPopUpShown = [def boolForKey:@"tripLocPopUpShown"];
        if(!tripLocPopUpShown){
        
            if ([CLLocationManager authorizationStatus]==kCLAuthorizationStatusDenied){

                [self showPopUps:@"Need location access to auto detect trip arrival location and track via GPS" :@"To re-enable, please go to Settings and turn on Location Service for this app."];

            }else if(![CLLocationManager locationServicesEnabled] || !([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse)){
//
//               NSString *message = @"Simply Auto needs access to your location to auto detect trip arrival location and to track trips via GPS.";
//               UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
//               UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"OK") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//
                     [[LocationServices sharedInstance].locationManager requestWhenInUseAuthorization];
//               }];
//
//              [alert addAction:ok];
//              [self presentViewController:alert animated:YES completion:nil];
           }
            [def setBool:YES forKey:@"tripLocPopUpShown"];
        }
        //Check if location services are enabled and permission is granted by user then only give dep_loc
        if([CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse){
            
            //requestLocation returns only one location. No need to startUpdatingLocation and stopUpdatingLocation. requestLocation does it. 
            [[LocationServices sharedInstance].locationManager requestLocation];
            
            //Latest Location in coordinates
            CLLocation *latestLoc = [LocationServices sharedInstance].latestLoc;
            //NSLog(@"dep loc = %@", latestLoc);
            
            //Converting lat, long to 3 decimals only
//            NSString *latString = [NSString stringWithFormat:@"%.3f", latestLoc.coordinate.latitude];
//            NSString *longiString = [NSString stringWithFormat:@"%.3f", latestLoc.coordinate.longitude];
            
            //NIKHIL BUG_151
            commonMethods *common = [[commonMethods alloc]init];
            NSNumberFormatter *lformatter = [common decimalFormatter];
            
            NSString *latString = [lformatter stringFromNumber: [NSNumber numberWithDouble: latestLoc.coordinate.latitude]];
            NSString *longiString = [lformatter stringFromNumber: [NSNumber numberWithDouble: latestLoc.coordinate.longitude]];
            
            depLat = [NSNumber numberWithDouble:[latString doubleValue]];
            depLong = [NSNumber numberWithDouble:[longiString doubleValue]];
           // saveArrLat = saveDepLat = [NSNumber numberWithDouble: latestLoc.coordinate.latitude];
            //saveArrLong = saveDepLong = [NSNumber numberWithDouble: latestLoc.coordinate.longitude];
     //       NSLog(@"####dep lat : %@, long : %@", depLat, depLong);
      //      NSLog(@"####saveDepLat : %@, saveDepLong : %@", saveDepLat, saveDepLong);
            //Accessing Loc_Table from DB
            NSManagedObjectContext *context = [[CoreDataController sharedInstance] newManagedObjectContext];
            NSError *err;
            
            NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Loc_Table"];
            
            NSArray *locationArray = [[NSArray alloc] init];
            locationArray = [context executeFetchRequest:request error:&err];
            //NSLog(@"locArr : %@", locationArray);
            
            //First set locFound to NO
            BOOL locFound = NO;
            
            
            if(![depLat isEqual:@0.0] && ![depLong isEqual:@0.0]){
            //Loop thr' each record in Loc_Table
            for (Loc_Table *location in locationArray) {
                NSString *latString = [lformatter stringFromNumber: location.lat];
                NSString *longiString = [lformatter stringFromNumber: location.longitude];
                location.lat = [NSNumber numberWithDouble:[latString doubleValue]];
                location.longitude = [NSNumber numberWithDouble:[longiString doubleValue]];
       //         NSLog(@"####lat long from db : %@, %@", location.lat,location.longitude);
                
                //Check if current lat, long present in that record of Loc_Table
                if([depLat floatValue] == [location.lat floatValue] && [depLong floatValue] == [location.longitude floatValue]){
                    
                    //If present, set locFound to YES
                    locFound = YES;
                    
                    //Extract address from Loc_Table for matching coordinates and set to dep location
                    
                    if([self.depLocnField.text isEqualToString:@""]){
                        
                        self.depLocnField.text = location.address;
                    }
                    
                } else {
                    
                    //Set locFound to NO
                    locFound = NO;
                }
            }
            }

            //NIKHIL BUG_150
            if(locFound == NO && ![depLat isEqual:@0.0] && ![depLong isEqual:@0.0] && depLat){
                
                //reverse geocode coordinates to identify location
                [geoCoder reverseGeocodeLocation:latestLoc completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
            
                    if(error == nil && [placemarks count] > 0){
                
                        placemark = [placemarks lastObject];
                    
                        if(self.depLocnField.text.length == 0){
                            self.depLocnField.text = [NSString stringWithFormat:@"%@ %@", placemark.name, placemark.subLocality];
                        }
                    } else {
                
                       NSLog(@"%@", error.debugDescription);
                    }
                }];
            }
        }
    }

    //Hide "track trip via gps" view if trip is a complete trip when view appears
    if([[_editTripDict objectForKey:@"isComplete"] boolValue]){
        
        [self.gpsView setHidden:YES];
        self.gpsButton.hidden = YES;
        self.trackTripLabel.hidden = YES;
        
    }
    
    //Tracking state of checkmark button in track trip via gps
    if([def boolForKey:@"gpsSelect"] == YES){
        self.gpsButton.selected = YES;
        [self.gpsButton setImage:[UIImage imageNamed:@"check"] forState:UIControlStateSelected];
        
    }
    
    if(_distanceField.text.length > 0){
        _distanceLabel.hidden = NO;
    }
    
    [self checkOdoSettings];
    
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
    
    //remove dict while exiting
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"editdetails"];
    

}

-(void)viewWillDisappear:(BOOL)animated
{
    [self deregisterFromKeyboardNotifications];
    
    [super viewWillDisappear:animated];
    

}

-(void)viewDidAppear:(BOOL)animated{

    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];

    _tripState = @"";
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    //BOOL tripInProgress = [[NSUserDefaults standardUserDefaults] boolForKey:@"tripInProgress"];
    
    //New_10 Nikhil 1December2018 Auto Trip Loging
    if([def boolForKey:@"showTripInProgress"]){
        
        self.gpsView.hidden = YES;
        self.gpsButton.hidden = YES;
        self.gpsButton.userInteractionEnabled = NO;
        self.trackTripLabel.text = NSLocalizedString(@"track_via_auto_trip", @"Tracking via Auto Trip");
    }

    //Coming from the log view Controller
    if (_editTripDict.count > 0 )
    {
        
        if ([[_editTripDict objectForKey:@"isComplete"] boolValue]) {
            self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"Save Trip" style:UIBarButtonItemStylePlain target:self action:@selector(saveTrip)];
            _tripState = @"Complete";
        }
        else
        {
            self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"end_trip", @"End Trip")
                                                        style:UIBarButtonItemStylePlain
                                                        target:self action:@selector(saveTrip)];
            _tripState = @"InProgress";
            _arrOdoField.text = @"";
            
        }

    }
    else if (_tripArray.count > 0) {
        
        self.navigationController.navigationBar.topItem.title = NSLocalizedString(@"edit_trip", @"Edit Trip");
        self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"End Trip" style:UIBarButtonItemStylePlain target:self action:@selector(saveTrip)];
        _tripState = @"InProgress";
        _arrOdoField.text = @"";
        
    }
    else
    {
        self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"start_trip", @"Start Trip") style:UIBarButtonItemStylePlain target:self action:@selector(saveTrip)];
        _tripState = @"New";
        
    }
    
}

-(void)checkOdoSettings{
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    if([def boolForKey:@"showTripOdo"]){
        
        self.odoLabelHConstraint.constant = 21;
        self.odoFieldHConstraint.constant = 30;
        self.unitLabelHConstraint.constant = 21;
        self.odoUnderLineHCon.constant = 0.65;
        self.arrOdoLHConstraint.constant = 21;
        self.arrFHConstraint.constant = 30;
        self.arrUnitConstraint.constant = 21;
        self.arrOdoUHConstraint.constant = 0.65;
        
    }else{
        
        self.odoLabelHConstraint.constant = 0;
        self.odoFieldHConstraint.constant = 0;
        self.unitLabelHConstraint.constant = 0;
        self.odoUnderLineHCon.constant = 0;
        self.arrOdoLHConstraint.constant = 0;
        self.arrFHConstraint.constant = 0;
        self.arrUnitConstraint.constant = 0;
        self.arrOdoUHConstraint.constant = 0;
    }
    
}

#pragma mark Navigatiion Bar methods


- (IBAction)backButtonPressed {
    
   [self dismissViewControllerAnimated:YES completion:nil];
    
}



#pragma mark Type Picker methods



- (IBAction)typeButtonPressed:(id)sender
{
        if(self.tripTypeArray.count>0)
    {
        
        [self tripPicker:@"Select Trip Type"];
    }
    
    else
    {
        
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:@"No Trip Types Present"
                                              message:NSLocalizedString(@"add_new", @"Add New")
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

- (void)tripPicker : (NSString *) string{
    //NIKHIL BUG_134 //added setbutton remove FROM SuperView
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
    
    
    UIView *scrollView = (UIView*)[self.view viewWithTag:-2];
    //
    [scrollView addSubview:_picker];
    _setbutton =[[UIButton alloc]init];
    _setbutton.frame = CGRectMake(App.result.width/2-130,(App.result.height/2-220)+270, 260, 40);
    //button.titleLabel.text = @"Set" ;
    [_setbutton setBackgroundColor:[UIColor lightGrayColor]];
    [_setbutton setTitle:string forState:UIControlStateNormal];
    [_setbutton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    //_setbutton.layer.cornerRadius = 5;
    [_setbutton addTarget:self action:@selector(setTripType) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_setbutton];
    
    
    
}

-(void)setTripType
{
    
    
    [self.picker removeFromSuperview];
    [self.setbutton removeFromSuperview];
 
    NSDictionary *dictionary = [[NSDictionary alloc]init];
    dictionary = [self.tripTypeArray objectAtIndex:[self.picker selectedRowInComponent:0]];

    
    _typeLabel.text = [dictionary objectForKey:@"serviceName"];
    //NSLog(@"service name %@", _typeLabel.text);

    _taxPercField.text = [[dictionary objectForKey:@"rate"] stringValue];
    //NSLog(@"tax perc %@", _taxPercField.text);

    
    
    _taxRateLabel.hidden = NO;
    
    if (_arrOdoField.text.length >1) {
        [self calcTax];
    }
    
}

#pragma mark Vehicle Picker methods

-(void)openVehiclePicker
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
    
    //NIKHIL BUG_134 //added setbutton removeFromSuperview
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
    [_picker selectRow:App.selPickerViewRow inComponent:0 animated:NO];
    
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
        
        return self.tripTypeArray.count;
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
        //NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
        NSDictionary *dictionary = [[NSDictionary alloc]init];
        // NSLog(@"dictionary value %@",dictionary);
        dictionary = [self.tripTypeArray objectAtIndex:row];
        return [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"serviceName"]];
    }
    else
        
        return 0;
}

//NIKHIL BUG_131 added below method
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    AppDelegate *App = [AppDelegate sharedAppDelegate];
    App.selPickerViewRow = row;
}

-(void)donelabel
{
    
    NSUserDefaults *def =[NSUserDefaults standardUserDefaults];
    [self.picker removeFromSuperview];
    [self.setbutton removeFromSuperview];
    
    if([def boolForKey:@"editPageOpen"]){
        
        [def setObject:[def objectForKey:@"fillupid"] forKey:@"oldFillupid"];
        
    }
    
    NSDictionary *dictionary = [[NSDictionary alloc]init];
    dictionary = [self.vehiclearray objectAtIndex:[self.picker selectedRowInComponent:0]];
    [[NSUserDefaults standardUserDefaults]setObject:[dictionary objectForKey:@"Id"] forKey:@"fillupid"];
    
    [[NSUserDefaults standardUserDefaults]setObject:[NSString stringWithFormat:@"%@ %@",[dictionary objectForKey:@"Make"],[dictionary objectForKey:@"Model"]] forKey:@"fillupmake"];
    
    self.vehName.text = [NSString stringWithFormat:@"%@ %@",[dictionary objectForKey:@"Make"],[dictionary objectForKey:@"Model"]];
    
    [def setObject:[dictionary objectForKey:@"Id"] forKey:@"idvalue"];
    [def setObject:[NSString stringWithFormat:@"%@ %@",[dictionary objectForKey:@"Make"],[dictionary objectForKey:@"Model"]] forKey:@"vehname"];
    [def setObject:[NSString stringWithFormat:@"%@",[dictionary objectForKey:@"Id"]] forKey:@"fillupid"];
    [def setObject:[dictionary objectForKey:@"Picture"] forKey:@"vehimage"];
    if([[[NSUserDefaults standardUserDefaults]objectForKey:@"vehimage"]isEqualToString:@""])
    {
        // NSLog(@"blank....");
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
    
   // Change the maxOdo as per the vehicle selected
    
    _depOdoField.text=@"";
    //Call Method to refresh the Sorted Log as per the vehicle Selected
    
    LogViewController *lvc = [[LogViewController alloc] init];
    [lvc fetchallfillup];
    
    [self setMaxOdo];
    
}

//Swapnil BUG_83
//New setMaxOdo
- (void) setMaxOdo{
    
    NSArray *sortedLogArray=[[NSUserDefaults standardUserDefaults] objectForKey:@"SortedLog"];

    if(sortedLogArray.count > 0){
        
        NSMutableDictionary *maxRecord = [[NSMutableDictionary alloc] init];
        NSMutableDictionary *minRecord = [[NSMutableDictionary alloc] init];

        maxRecord = [sortedLogArray firstObject];
        minRecord = [sortedLogArray lastObject];
        
        if([[maxRecord objectForKey:@"type"]  isEqual: @3] && [[maxRecord objectForKey:@"isComplete"]  isEqual: @1] ){
            
            maxOdo = [[maxRecord objectForKey:@"arrOdo"] stringValue];
        } else {
        
            maxOdo = [[maxRecord objectForKey:@"odo"] stringValue];
        }
        
        _depOdoField.text = maxOdo;
    }
    
}

-(void)fetchTripData
{
   // NSLog(@"self.editTripDict: %@", self.editTripDict);
    
    NSUserDefaults *Def =[NSUserDefaults standardUserDefaults];
    NSString *comparestring = [NSString stringWithFormat:@"%@",[Def objectForKey:@"fillupid"]];
    
    //NSLog(@"%@",_editTripDict);
    
    if (self.editTripDict.count > 0)
    //Edit Data from LogViewController
    {
        
        _typeLabel.text = [_editTripDict objectForKey:@"tripType"];
        _depOdoField.text= [[_editTripDict objectForKey:@"odo"] stringValue];
        _depLocnField.text= [_editTripDict objectForKey:@"depLocn"];
        _depDateTimeField.text = [_editTripDict objectForKey:@"date"];
        // NSLog(@"dedateTimefieldtext:::%@",_depDateTimeField.text);
        _arrDateTimeFld.text = [f stringFromDate:[_editTripDict objectForKey:@"arrDate"]];
        _arrOdoField.text = [[_editTripDict objectForKey:@"arrOdo"] stringValue];
        _arrLocnField.text = [_editTripDict objectForKey:@"arrLocn"];
        _parkingField.text = [[_editTripDict objectForKey:@"parkingAmt"] stringValue];
        _tollField.text = [[_editTripDict objectForKey:@"tollAmt"] stringValue];
        _taxValueLabel.text = [[_editTripDict objectForKey:@"cost"] stringValue];
        _notesView.text =[_editTripDict objectForKey:@"notes"] ;
    }
    else
    {
    self.tripArray =[[NSMutableArray alloc]init];

    NSManagedObjectContext *contex = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSFetchRequest *request=[[NSFetchRequest alloc] initWithEntityName:@"T_Trip"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"tripComplete == 0 AND vehId = %@", comparestring];
    [request setPredicate:predicate];
    
    NSError *err;
    NSArray *data=[contex executeFetchRequest:request error:&err];
    NSMutableDictionary *tripDict;
        
        
    for(T_Trip *tripRec in data)
    {
        tripDict = [[NSMutableDictionary alloc]init];
        [tripDict setObject:tripRec.vehId forKey:@"vehId"];
        [tripDict setObject:tripRec.tripType forKey:@"tripType"];
        [tripDict setObject:tripRec.depOdo forKey:@"depOdo"];
        [tripDict setObject:tripRec.depDate forKey:@"depDate"];

        if (tripRec.depLocn!= nil) {
            [tripDict setObject:tripRec.depLocn forKey:@"depLocn"];
        }
        if (tripRec.arrOdo!= nil) {
            [tripDict setObject:tripRec.arrOdo forKey:@"arrOdo"];
        }
        if (tripRec.arrDate!= nil) {
            [tripDict setObject:tripRec.arrDate forKey:@"arrDate"];
        }
        if (tripRec.arrLocn!= nil) {
            [tripDict setObject:tripRec.arrLocn forKey:@"arrLocn"];
        }
        if (tripRec.parkingAmt!= nil) {
            [tripDict setObject:tripRec.parkingAmt forKey:@"parkingAmt"];
        }
        if (tripRec.tollAmt!= nil) {
            [tripDict setObject:tripRec.tollAmt forKey:@"tollAmt"];
        }
        if (tripRec.taxDedn!= nil) {
            [tripDict setObject:tripRec.taxDedn forKey:@"taxDedn"];
        }
        if (tripRec.notes!= nil) {
            [tripDict setObject:tripRec.notes forKey:@"notes"];
        }
        
        [_tripArray addObject:tripDict];
        // NSLog(@"tripArray: %@", _tripArray);
        
        for (NSDictionary* dictionary in self.vehiclearray)
        {
            
            if ([[tripDict objectForKey:@"vehId"] isEqualToString: [[dictionary objectForKey:@"Id"] stringValue]]) {
                //dictionary = [self.vehiclearray objectAtIndex:[self.picker selectedRowInComponent:0]];
                
                self.vehName.text = [NSString stringWithFormat:@"%@ %@",[dictionary objectForKey:@"Make"],[dictionary objectForKey:@"Model"]];
                
                    //[def setObject:[dictionary objectForKey:@"Picture"] forKey:@"vehimage"];
                    if([[dictionary objectForKey:@"Picture"] isEqualToString:@""])
                    {
                      // NSLog(@"blank....");
                      _vehImage.image=[UIImage imageNamed:@"car4.jpg"];
                    }
                
                    else
                    {
                        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                    
                        //Swapnil ENH_24
                        NSString *urlstring = [paths firstObject];
                    
                        NSString *vehiclepic = [NSString stringWithFormat:@"%@/%@",urlstring,[dictionary objectForKey:@"Picture"]];
                        _vehImage.image =[UIImage imageWithContentsOfFile:vehiclepic];
                    }
                }
            
            }
            _typeLabel.text = tripRec.tripType;
            _depOdoField.text= [tripRec.depOdo stringValue];
            _depLocnField.text= tripRec.depLocn;
            _depDateTimeField.text = [f stringFromDate:tripRec.depDate];
            _arrDateTimeFld.text = [f stringFromDate:tripRec.arrDate];
            _arrOdoField.text = [tripRec.arrOdo stringValue];
            _arrLocnField.text = tripRec.arrLocn;
            _parkingField.text = [tripRec.parkingAmt stringValue];
            _tollField.text = [tripRec.tollAmt stringValue];
            _taxValueLabel.text = [tripRec.taxDedn stringValue];

             break;
      }
    }
    
    for (NSDictionary *typeDict in self.tripTypeArray)
    {
        if ([_typeLabel.text isEqualToString:[typeDict objectForKey:@"serviceName" ]])
        {
            _taxPercField.text = [[typeDict objectForKey:@"rate"] stringValue];
            _taxRateLabel.hidden = NO;
        }
        
    }
 
    if (_arrOdoField.text.length > 1) {
        
        //NIKHIL BUG_128 //removed calcTax call and took distance and total values from database itself
        float startOdo = [_depOdoField.text floatValue];
        float endOdo = [_arrOdoField.text floatValue];
        
        float distance = endOdo - startOdo;
        _distanceField.text = [NSString stringWithFormat:@"%.2f",distance];
        _taxValueLabel.text = [[_editTripDict objectForKey:@"cost"] stringValue];
        
    }
    
    //New_10 Nikhil 1December2018 Auto Trip Loging
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"tripInProgress"]){
        
        if([Def objectForKey:@"distFromAutoTrip"]){
            
            _distanceField.text = [NSString stringWithFormat:@"%.2f",[[Def objectForKey:@"distFromAutoTrip"] floatValue]];
            float arrodo = [_depOdoField.text floatValue] + [_distanceField.text floatValue];
            NSString *arr = [NSString stringWithFormat:@"%.2f", arrodo];
            
            float taxDedc = ([[Def objectForKey:@"distFromAutoTrip"] floatValue])* [_taxPercField.text floatValue] + [_parkingField.text floatValue] + [_tollField.text floatValue];
            _taxValueLabel.text = [[NSNumber numberWithFloat:taxDedc] stringValue];
            
            //Auto populate arr_Odo
            self.arrOdoField.text = arr;
            
            _arrDateTimeFld.text = [f stringFromDate:[NSDate date]];
            
        }
        

//
//       if(!geoCoder)
//            geoCoder = [[CLGeocoder alloc] init];
//
//        [geoCoder reverseGeocodeLocation:arrLocation completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
//
//            NSLog(@"Came inside geocoder saving complete trip");
//
//            if(error == nil && [placemarks count] > 0){
//
//                CLPlacemark * localPlaceMark = [placemarks lastObject];
//                // placemark = [placemarks lastObject];
//
//                self.arrLocnField.text = [NSString stringWithFormat:@"%@ %@", localPlaceMark.name, localPlaceMark.subLocality];
//                NSLog(@"arrLoca inside geocoder:%@",self.arrLocnField.text);
//
//            } else {
//
//                NSLog(@"Manual Trip location paassed, placeMark error:- %@ and latest loc is:- %@", error.debugDescription,arrLocation);
//            }
//
//        }];
//
    }
    [self calcTime];
    
    [self showLabel];
    
}

-(void)showLabel {
 
    if (_depOdoField.text.length>0) {
        _depOdoLabel.hidden = NO;
    }
    if (_depLocnField.text.length>0) {
        _depLocnLabel.hidden = NO;
    }
    if (_arrOdoField.text.length>0) {
        _arrOdoLabel.hidden = NO;
        _arrOdoField.placeholder = @"";
    }
    if (_arrLocnField.text.length>0) {
        _arrLocnLabel.hidden = NO;
    }
    if (_parkingField.text.length>0) {
        _parkingLabel.hidden = NO;
    }
    if (_tollField.text.length>0) {
        _tollLabel.hidden = NO;
    }
 
}


-(void)fetchTripTypeData
{
    self.tripTypeArray =[[NSMutableArray alloc]init];

    NSManagedObjectContext *contex = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSFetchRequest *request=[[NSFetchRequest alloc] initWithEntityName:@"Services_Table"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type==3"];
    [request setPredicate:predicate];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"serviceName" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    
    [request setSortDescriptors:sortDescriptors];
    
    
    
    NSError *err;
    NSArray *data=[contex executeFetchRequest:request error:&err];
    
    for(Services_Table *serviceRec in data)
    {
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
   
        //[dictionary setObject:serviceRec.vehid forKey:@"vehid"];
        if(serviceRec.dueMiles != nil){
            [dictionary setObject:serviceRec.dueMiles forKey:@"rate"];

            
        } else {
            [dictionary setObject:@(0) forKey:@"rate"];

        }
        [dictionary setObject:serviceRec.serviceName forKey:@"serviceName"];
        [dictionary setObject:serviceRec.type forKey:@"type"];
   
        
      //  [dictionary setValue:@"12" forKey:@"rate"];
        [self.tripTypeArray addObject:dictionary];
        

      // NSLog(@"self.tripTypeArray: %@", self.tripTypeArray);
        
    }

}


-(void)fetchVehiclesData
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
    
    //NSLog(@"vehicle array %@",self.vehiclearray);
}


#pragma mark Save methods





-(void) showCompleteAlertFor:(NSString*)title :(NSString*)message :(BOOL) success
{

    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:title
                                          message:message
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"ok", @"OK action")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   if (success) {
                                       [self backButtonPressed];
                                   }
                                   
                                   
                               }];
    
    
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];

}


-(void)saveTrip
{
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    
    if([_tripState isEqualToString:@"InProgress"]){
        
        if(self.arrDateTimeFld.text.length == 0){
            arrDate = [NSDate date];
            self.arrDateTimeFld.text = [f stringFromDate:arrDate];
        }
        [self validateTime];
    }
    
    
    //check if gps checkmark is selected
    if([def boolForKey:@"gpsSelect"] == YES){
        
        //check trip state. In progress going to end
        if([_tripState isEqualToString:@"InProgress"] && self.arrOdoField.text.length == 0){
            
            float arrodo;
            gpsDistance = [[LocationServices sharedInstance] distanceTravelled] / 1000;
            //double distMetrics;
            if([[def objectForKey:@"dist_unit"] isEqualToString:NSLocalizedString(@"disp_miles", @"Miles")]){
                gpsDistance = gpsDistance / 1.61;
            }
            
            //add distance traveled to dep_odo to calculate arr_odo
            NSString *gpsDist = [NSString stringWithFormat:@"%.2f", gpsDistance];
            self.distanceField.text = gpsDist;
            arrodo = [_depOdoField.text floatValue] + [_distanceField.text floatValue];
            NSString *arr = [NSString stringWithFormat:@"%.2f", arrodo];
            
            //Auto populate arr_Odo
            self.arrOdoField.text = arr;
            
        }
    }
    
    NSDate *endDate = [f dateFromString:_arrDateTimeFld.text];
    float endOdo = [_arrOdoField.text floatValue];
    
    
    if ([self checkOdo:endOdo ForDate:endDate] )
    {

    //We have the Trip State available at this point
    //New, InProgress & Complete
    
    //Get if the fields are valid
    // 0 = valid
    // 1 = departure fields invalid
    // 2 = arrival fields are invalid
    
    int valid = [self checkTextFieldsIfNil];
    
    NSUserDefaults *Def =[NSUserDefaults standardUserDefaults];
    NSDate *depDate =[f dateFromString:_depDateTimeField.text];
    arrDate =[f dateFromString:_arrDateTimeFld.text];
    NSString *comparestring = [NSString stringWithFormat:@"%@",[Def objectForKey:@"fillupid"]];
    
    //BUG_177 for carChange
    NSString *oldComapreString = [NSString stringWithFormat:@"%@",[Def objectForKey:@"oldFillupid"]];
    
    if ([_tripState isEqualToString:@"New"]) {
     
        if (valid == 1)
        {
            //Cannot start the trip
            //Alert to fix
            
            [self showCompleteAlertFor:@"Cannot Start Trip":_warning : NO];
        }
        else if(valid == 2)
        {// Trip can be Started
          //Insert record in the DB with trip complete = NO
          //Notification on Trip Start
            
        
            //New_10 To stop auto trip as manual trip is started
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"tripInProgress"];
         
            //Swapnil - Fabric Event
            NSString *appInstallDate = [def objectForKey:@"installDate"];
            NSInteger tripCountEvent = [def integerForKey:@"tripCountEvent"] + 1;
            [def setInteger:tripCountEvent forKey:@"tripCountEvent"];
            NSString *tripCnt = [NSString stringWithFormat:@"%ld", (long)tripCountEvent];
            NSString *gpsEvent;
            
            if([def boolForKey:@"gpsSelect"] == YES){
                gpsEvent = @"ON";
            } else {
                gpsEvent = @"OFF";
            }
    
            NSString *completeTripEvent = [NSString stringWithFormat:@"%@; %@; %@", appInstallDate, tripCnt, gpsEvent];
            [Answers logCustomEventWithName:@"Trip Event"
                           customAttributes:@{@"Trip start Event": completeTripEvent}];

            //TO get vehid
            NSManagedObjectContext *contex = [[CoreDataController sharedInstance] newManagedObjectContext];
            NSError *err;
            
            NSFetchRequest *vehRequest = [[NSFetchRequest alloc] initWithEntityName:@"Veh_Table"];
            NSPredicate *vehPredicate = [NSPredicate predicateWithFormat:@"iD == %i",[comparestring intValue]];
            [vehRequest setPredicate:vehPredicate];
            NSArray *vehData = [contex executeFetchRequest:vehRequest error:&err];
            
            Veh_Table *vehicleData = [vehData firstObject];
            //till here
           
            NSString *vehid = vehicleData.vehid;
            //NSLog(@"gadiname:- %@",vehid);
            
            T_Trip *dataval=[NSEntityDescription insertNewObjectForEntityForName:@"T_Trip" inManagedObjectContext:contex];
            
            if(dataval != nil){
                
                NSMutableDictionary *forFriendDict = [[NSMutableDictionary alloc]init];
                if([Def objectForKey:@"UserEmail"] != nil){
                    [forFriendDict setObject:[Def objectForKey:@"UserEmail"] forKey:@"email"];
                    [forFriendDict setObject:[Def objectForKey:@"UserName"] forKey:@"name"];
                }else{
                    [forFriendDict setObject:@"" forKey:@"email"];
                    [forFriendDict setObject:@"" forKey:@"name"];
                }
                [forFriendDict setObject:@"add" forKey:@"action"];
                
                
                //Swapnil NEW_6
                int fuelID;
                if([Def objectForKey:@"maxFuelID"] != nil){
                    
                    fuelID = [[Def objectForKey:@"maxFuelID"] intValue];
                } else {
                    
                    fuelID = 0;
                }
                
                dataval.iD = [NSNumber numberWithInt:fuelID + 1];
                //NSLog(@"inserrecord dataval.iD ::::%@",dataval.iD);
                [Def setObject:[NSNumber numberWithInt:fuelID + 1] forKey:@"maxFuelID"];
                [forFriendDict setObject:[NSNumber numberWithInt:fuelID + 1] forKey:@"id"];
                
                if([def boolForKey:@"showTripOdo"]){
                    dataval.depOdo = @([_depOdoField.text floatValue]);
                    [forFriendDict setObject:@([_depOdoField.text floatValue]) forKey:@"odo"];
                }else{
                    dataval.depOdo = @([maxOdo floatValue]);
                    [forFriendDict setObject:@([maxOdo floatValue]) forKey:@"odo"];
                }
                
                dataval.vehId=comparestring;
                if(comparestring != nil){
                    [forFriendDict setObject:vehid forKey:@"vehid"];
                }
                
                dataval.tripType=_typeLabel.text;
                [forFriendDict setObject:_typeLabel.text forKey:@"serviceType"];
                
                dataval.depDate=depDate;
                [forFriendDict setObject:depDate forKey:@"date"];
                
                dataval.depLocn=_depLocnField.text;
                [forFriendDict setObject:_depLocnField.text forKey:@"fuelBrand"];
                
                dataval.arrDate=arrDate;
                if(arrDate)
                [forFriendDict setObject:arrDate forKey:@"octane"];
                
                dataval.arrOdo = @([_arrOdoField.text floatValue]);
                [forFriendDict setObject:@([_arrOdoField.text floatValue]) forKey:@"qty"];
                
                dataval.arrLocn=_arrLocnField.text;
                [forFriendDict setObject:_arrLocnField.text forKey:@"fillStation"];
                
                dataval.parkingAmt=@([_parkingField.text floatValue]);
                [forFriendDict setObject:@([_parkingField.text floatValue]) forKey:@"OT"];
                
                dataval.tollAmt=@([_tollField.text floatValue]);
                [forFriendDict setObject:@([_tollField.text floatValue]) forKey:@"year"];
                
                dataval.taxDedn=@([_taxValueLabel.text floatValue]);
                [forFriendDict setObject:@([_taxValueLabel.text floatValue]) forKey:@"cost"];
                
                dataval.notes = _notesView.text;
                [forFriendDict setObject:_notesView.text forKey:@"notes"];
                
                //Trip Map database lat long
                dataval.depLatitude = depLat;
                if(depLat)
                    [forFriendDict setObject:depLat forKey:@"depLat"];
                
                dataval.depLongitude = depLong;
                if(depLong)
                    [forFriendDict setObject:depLong forKey:@"depLong"];
                
                dataval.arrLatitude = arrLat;
                if(arrLat)
                    [forFriendDict setObject:arrLat forKey:@"arrLat"];
                
                dataval.arrLongitude = arrLong;
                if(arrLong)
                [forFriendDict setObject:arrLong forKey:@"arrLong"];
                
                dataval.tripComplete = NO;
                
                [forFriendDict setObject:@3 forKey:@"type"];
                NSMutableDictionary *paramDict = [[NSMutableDictionary alloc] init];
                //Swapnil ENH_11
                if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse && [CLLocationManager locationServicesEnabled]){
                    
                    
                    //Accessing Loc_Table from DB
                    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Loc_Table"];
                    
                    NSArray *locationArray = [[NSArray alloc] init];
                    locationArray = [contex executeFetchRequest:request error:&err];
                    //NSLog(@"locArr : %@", locationArray);
                    NSNumberFormatter *formatter = [NSNumberFormatter new];
                    [formatter setRoundingMode:NSNumberFormatterRoundFloor];
                    [formatter setMaximumFractionDigits:3];
                    [formatter setPositiveFormat:@"0.###"];
                    
                    BOOL isPresent = NO;
                    //NIKHIL BUG_150
                    if(![depLat isEqual:@0.0] && ![depLong isEqual:@0.0])
                    {
                        for(Loc_Table *location in locationArray){
                            NSString *latString = [formatter stringFromNumber: location.lat];
                            NSString *longiString = [formatter stringFromNumber: location.longitude];
                            location.lat = [NSNumber numberWithDouble:[latString doubleValue]];
                            location.longitude = [NSNumber numberWithDouble:[longiString doubleValue]];
                            //           NSLog(@"####Comparing lat long from db : %@, %@", location.lat,location.longitude);
                            //          NSLog(@"####Comparing lat long from location : %@, %@",depLat ,depLong);
                            
                            //If current lat, long matches with the record's lat, long
                            if([depLat floatValue] == [location.lat floatValue] && [depLong floatValue] == [location.longitude floatValue]){
                                
                                //means that lat, long are already present in Locn table
                                isPresent = YES;
                                
                                //then check corresponding address is similar to what user has entered
                                if(![location.address isEqualToString:self.depLocnField.text]){
                                    
                                    //If not, edit address and brand to user entered data
                                    location.address = self.depLocnField.text;
                                    
                                    [paramDict setObject:location.iD forKey:@"rowid"];
                                    [paramDict setObject:@"edit" forKey:@"type"];
                                }
                                
                            } else {
                                
                                //that lat, long not present in Locn table
                                isPresent = NO;
                            }
                        }
                    }
                    //If location not present in Loc_table then add new location
                    //NIKHIL BUG_150
                    if(isPresent == NO && ![depLat isEqual:@0.0] && ![depLong isEqual:@0.0] && depLat){
                        Loc_Table *locationData = [NSEntityDescription insertNewObjectForEntityForName:@"Loc_Table" inManagedObjectContext:contex];
                        
                        //Swapnil NEW_6
                        int locID;
                        if([Def objectForKey:@"maxLocID"] != nil){
                            
                            locID = [[Def objectForKey:@"maxLocID"] intValue];
                        } else {
                            
                            locID = 0;
                        }
                        
                        locationData.iD = [NSNumber numberWithInt:locID + 1];
                        [Def setObject:locationData.iD forKey:@"maxLocID"];
                        locationData.address = self.depLocnField.text;
                        //NIKHIL BUG_151
                        locationData.lat = depLat;
                        //           NSLog(@"####locationData.lat after saving to DB from saveTrip::%@",locationData.lat);
                        locationData.longitude = depLong;
                        
                        [paramDict setObject:locationData.iD forKey:@"rowid"];
                        [paramDict setObject:@"add" forKey:@"type"];
                        
                        
                    }
                }
                
                if ([contex hasChanges])
                {
                    BOOL saved = [contex save:&err];
                    if (!saved) {
                        // do some real error handling
                        //CLSLog(@“Could not save Data due to %@“, error);
                    }
                    // NSLog(@"odometer saved");
                    [[CoreDataController sharedInstance] saveMasterContext];
                    //Swapnil NEW_6
                    NSString *userEmail = [Def objectForKey:@"UserEmail"];
                    
                    //If user is signed In, then only do the sync process..
                    if(userEmail != nil && userEmail.length > 0){
                        
                        [self writeToSyncTableWithRowID:dataval.iD tableName:@"TRIP" andType:@"add" andOS:@"self"];
                        
                        //To share data with friend
                        //TCommented sync with friend "testing"
//                        BOOL friendPresent = [self checkforConfirmedFriends];
//
//                        if(friendPresent){
//                            //NSLog(@"Call script ☺️ with Dictionary:- %@",forFriendDict);
//                            [self sendUpdatedRecordToFriend:forFriendDict];
//                        }

                        if(paramDict != nil && paramDict.count > 0){
                            
                            [self writeToSyncTableWithRowID:[paramDict objectForKey:@"rowid"] tableName:@"LOC_TABLE" andType:[paramDict objectForKey:@"type"] andOS:@"self"];
                        }
                       // [self checkNetworkForCloudStorage];
                    }
                    //Alert
                    [self showCompleteAlertFor:NSLocalizedString(@"trip_started", @"Trip Started") :@"" :nil];
                    
                    //Swapnil NEW_5
                    
                    //If gps tracking is checkmarked
                    if([def boolForKey:@"gpsSelect"] == YES){
                        
                        [def setBool:YES forKey:@"startNotifications"];
                        
                        //Set dist traveled to 0
                        [[LocationServices sharedInstance] setDistanceTravelled:0.0];
                        
                        //Start location updates
                        [[LocationServices sharedInstance].locationManager startUpdatingLocation];
                        
                        //Receive background location updates
                        [LocationServices sharedInstance].locationManager.allowsBackgroundLocationUpdates = YES;
                        
                        //Set start Loc nil
                        [[LocationServices sharedInstance] setStartLoc:nil];
                        
                        //UNUserNotification
                        [self showNotificationFor:NSLocalizedString(@"trip_in_progress", @"Trip In Progress")];
                        
                        
                    } else {
                        
                        //If gps tracking is unchecked. Normal trip execution
                        //Notification on starting the Trip
                        [[JRNLocalNotificationCenter defaultCenter] postNotificationOnNowForKey:@"TripStart" alertBody:NSLocalizedString(@"trip_in_progress", @"Trip In Progress")];
                        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"showPage"];
                    }
                    
                    //Change the title of navigation Control to "End Trip" and Update trip_state to 'In Progress'
                    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithTitle: NSLocalizedString(@"end_trip", @"End Trip") style:UIBarButtonItemStylePlain target:self action:@selector(saveTrip)];
                    _tripState = @"InProgress";
                    
                }
            }
            
        }
        else if(valid == 0)
        {// Trip can be complete
            //Insert record in the DB with trip complete
            //Notification on Trip Complete
  
            //TO get vehid
            NSManagedObjectContext *contex = [[CoreDataController sharedInstance] newManagedObjectContext];
            NSError *err;
            
            NSFetchRequest *vehRequest = [[NSFetchRequest alloc] initWithEntityName:@"Veh_Table"];
            NSPredicate *vehPredicate = [NSPredicate predicateWithFormat:@"iD == %i",[comparestring intValue]];
            [vehRequest setPredicate:vehPredicate];
            NSArray *vehData = [contex executeFetchRequest:vehRequest error:&err];
            
            Veh_Table *vehicleData = [vehData firstObject];
            //till here
            
            NSString *vehid = vehicleData.vehid;
            //NSLog(@"gadiname:- %@",vehid);
            
            T_Trip *dataval=[NSEntityDescription insertNewObjectForEntityForName:@"T_Trip" inManagedObjectContext:contex];
           
            if(dataval != nil){
                
                NSMutableDictionary *forFriendDict = [[NSMutableDictionary alloc]init];
                if([Def objectForKey:@"UserEmail"] != nil){
                    [forFriendDict setObject:[Def objectForKey:@"UserEmail"] forKey:@"email"];
                    [forFriendDict setObject:[Def objectForKey:@"UserName"] forKey:@"name"];
                }else{
                    [forFriendDict setObject:@"" forKey:@"email"];
                    [forFriendDict setObject:@"" forKey:@"name"];
                }
                [forFriendDict setObject:@"add" forKey:@"action"];
                
                
                //Swapnil NEW_6
                int fuelID;
                if([Def objectForKey:@"maxFuelID"] != nil){
                    
                    fuelID = [[Def objectForKey:@"maxFuelID"] intValue];
                } else {
                    
                    fuelID = 0;
                }
                
                dataval.iD = [NSNumber numberWithInt:fuelID + 1];
                //NSLog(@"inserrecord dataval.iD ::::%@",dataval.iD);
                [Def setObject:[NSNumber numberWithInt:fuelID + 1] forKey:@"maxFuelID"];
                [forFriendDict setObject:[NSNumber numberWithInt:fuelID + 1] forKey:@"id"];
                
                if([def boolForKey:@"showTripOdo"]){
                    dataval.depOdo = @([_depOdoField.text floatValue]);
                    [forFriendDict setObject:@([_depOdoField.text floatValue]) forKey:@"odo"];
                }else{
                    dataval.depOdo = @([maxOdo floatValue]);
                    [forFriendDict setObject:@([maxOdo floatValue]) forKey:@"odo"];
                }
                
                dataval.vehId=comparestring;
                if(dataval.vehId != nil){
                    [forFriendDict setObject:vehid forKey:@"vehid"];
                }
                
                dataval.tripType=_typeLabel.text;
                [forFriendDict setObject:_typeLabel.text forKey:@"serviceType"];
                
                dataval.depDate=depDate;
                [forFriendDict setObject:depDate forKey:@"date"];
                
                dataval.depLocn=_depLocnField.text;
                [forFriendDict setObject:_depLocnField.text forKey:@"fuelBrand"];
                
                
                dataval.arrDate=arrDate;
                
                commonMethods *common = [[commonMethods alloc] init];
                NSDictionary *epochDictionary = [common getDayMonthYrFromStringDate:dataval.arrDate];
                //Trim after decimals
                NSString *gotDate = [epochDictionary valueForKey:@"epochTime"];
                NSString *sendDate;
                if(gotDate.length>8){
                    sendDate = [gotDate substringToIndex:13];
                    [forFriendDict setObject:sendDate forKey:@"octane"];
                }else{
                    [forFriendDict setObject:gotDate forKey:@"octane"];
                }
                dataval.arrOdo=@([_arrOdoField.text floatValue]);
                [forFriendDict setObject:@([_arrOdoField.text floatValue]) forKey:@"qty"];
                
                dataval.arrLocn=_arrLocnField.text;
                [forFriendDict setObject:_arrLocnField.text forKey:@"fillStation"];
                
                dataval.parkingAmt=@([_parkingField.text floatValue]);
                [forFriendDict setObject:@([_parkingField.text floatValue]) forKey:@"OT"];
                
                dataval.tollAmt=@([_tollField.text floatValue]);
                [forFriendDict setObject:@([_tollField.text floatValue]) forKey:@"year"];
                
                dataval.taxDedn=@([_taxValueLabel.text floatValue]);
                [forFriendDict setObject:@([_taxValueLabel.text floatValue]) forKey:@"cost"];
                
                dataval.notes = _notesView.text;
                [forFriendDict setObject:_notesView.text forKey:@"notes"];
                
                //Trip Map database lat long
                dataval.depLatitude = depLat;
                if(depLat)
                [forFriendDict setObject:depLat forKey:@"depLat"];
                
                dataval.depLongitude = depLong;
                if(depLong)
                [forFriendDict setObject:depLong forKey:@"depLong"];
                
                dataval.arrLatitude = arrLat;
                if(arrLat)
                [forFriendDict setObject:arrLat forKey:@"arrLat"];
                
                dataval.arrLongitude = arrLong;
                if(arrLong)
                    [forFriendDict setObject:arrLong forKey:@"arrLong"];
                
                
                dataval.tripComplete = YES;
                [forFriendDict setObject:@3 forKey:@"type"];
                
                if ([contex hasChanges])
                {
                    BOOL saved = [contex save:&err];
                    if (!saved) {
                        // do some real error handling
                        //CLSLog(@“Could not save Data due to %@“, error);
                    }
                    // NSLog(@"odometer saved");
                    [[CoreDataController sharedInstance] saveMasterContext];
                    
                    //Swapnil NEW_6
                    NSString *userEmail = [Def objectForKey:@"UserEmail"];
                    
                    //If user is signed In, then only do the sync process..
                    if(userEmail != nil && userEmail.length > 0){
                        
                        [self writeToSyncTableWithRowID:dataval.iD tableName:@"TRIP" andType:@"add" andOS:@"self"];
                        
                        //To share data with friend
                        //Commented sync with friend "testing"
//                        BOOL friendPresent = [self checkforConfirmedFriends];
//
//                        if(friendPresent){
//                            // NSLog(@"Call script ☺️ with Dictionary:- %@",forFriendDict);
//                            [self sendUpdatedRecordToFriend:forFriendDict];
//                        }

                      //  [self checkNetworkForCloudStorage];
                    }
                    //Alert
                    [self showCompleteAlertFor:@"Trip Added":@"" : YES];
                    
                    //Swapnil 25-May-2017
                    BOOL proUser = [[NSUserDefaults standardUserDefaults] boolForKey:@"isAdDisabled"];
                    
                    if(!proUser){
                        NSInteger gadCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"adCount"];
                        gadCount = gadCount + 1;
                        [[NSUserDefaults standardUserDefaults] setInteger:gadCount forKey:@"adCount"];
                    }
                    
                    [def setInteger :[def integerForKey:@"appopenstatus"]+1 forKey:@"appopenstatus"];
                    
                    //Notification on starting the Trip
                    [[JRNLocalNotificationCenter defaultCenter] postNotificationOnNowForKey:@"TripStart" alertBody:@"Your trip has been added successfully"];
                    [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"showPage"];
                    
                    //Change the title of navigation Control to "Save Trip" and Update trip_state to 'Complete'
                    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"Save Trip" style:UIBarButtonItemStylePlain target:self action:@selector(saveTrip)];
                    _tripState = @"Complete";
                    
                    //New_10 To start auto trip as manual trip is ended
                    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"tripInProgress"];
                }
            }
            
        }
    
    }
    else if ([_tripState isEqualToString:@"InProgress"])
    {
        if(valid == 0)
        {// Trip can be complete
        //Update record from tripArray or EditTripArray in the DB with trip complete
        //UPdate the arr datetime and notification to be changed to 'Trip Ended'
            
            //Swapnil NEW_5
            //If gps tracking is checkmarked
            if([def boolForKey:@"gpsSelect"] == YES){
                
                //Stop Location updates
                [[LocationServices sharedInstance].locationManager stopUpdatingLocation];
                
                //Disable background location updates
                [LocationServices sharedInstance].locationManager.allowsBackgroundLocationUpdates = NO;
                
                //Cancel gps tracking user defaults
                //[def setBool:NO forKey:@"gpsSelect"];
            
                //Get latest location
                CLLocation *latestLoc = [LocationServices sharedInstance].latestLoc;
                //NSLog(@"arr loc = %@", latestLoc);
                
                //Converting lat, long to 3 decimals only
                //NIKHIL BUG_151
                commonMethods *common = [[commonMethods alloc]init];
                NSNumberFormatter *lformatter = [common decimalFormatter];
                NSString *latString = [lformatter stringFromNumber: [NSNumber numberWithDouble: latestLoc.coordinate.latitude]];
                NSString *longiString = [lformatter stringFromNumber: [NSNumber numberWithDouble: latestLoc.coordinate.longitude]];
                
                arrLat = [NSNumber numberWithDouble:[latString doubleValue]];
                arrLong = [NSNumber numberWithDouble:[longiString doubleValue]];
                //NSLog(@"arr lat : %@, long : %@", arrLat, arrLong);
                
                //Accessing Loc_Table from DB
                NSManagedObjectContext *context = [[CoreDataController sharedInstance] newManagedObjectContext];
                NSError *err;
                
                NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Loc_Table"];
                
                NSArray *locationArray = [[NSArray alloc] init];
                locationArray = [context executeFetchRequest:request error:&err];
                //NSLog(@"locArr : %@", locationArray);
                
                //First set locFound to NO
                BOOL locFound = NO;
                //NIKHIL BUG_150
                if(![arrLat isEqual:@0.0] && ![arrLong isEqual:@0.0]){
                //Loop thr' each record in Loc_Table
                for (Loc_Table *location in locationArray) {
                    NSString *latString = [lformatter stringFromNumber: location.lat];
                    NSString *longiString = [lformatter stringFromNumber: location.longitude];
                    location.lat = [NSNumber numberWithDouble:[latString doubleValue]];
                    location.longitude = [NSNumber numberWithDouble:[longiString doubleValue]];
//                    NSLog(@"####Comparing lat long from db : %@, %@", location.lat, location.longitude);
//                    NSLog(@"####Comparing lat long from location : %@, %@", arrLat,arrLong);
//                    //Check if current lat, long present in that record of Loc_Table
                    if([arrLat floatValue] == [location.lat floatValue] && [arrLong floatValue] == [location.longitude floatValue]){
                        
                        //If present, set locFound to YES
                        locFound = YES;
                        self.arrLocnField.text = location.address;
                        
                    } else {
                        
                        //Set locFound to NO
                        locFound = NO;
                    }
                }
                }
                
                //NIKHIL BUG_150
                if(locFound == NO && ![arrLat isEqual:@0.0] && ![arrLong isEqual:@0.0] && depLat){
                    //Reverse geocode to identify arr_loc address
                    [geoCoder reverseGeocodeLocation:latestLoc completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
                
                        if(error == nil && [placemarks count] > 0){
                    
                            placemark = [placemarks lastObject];
                            
                            if(self.arrLocnField.text.length == 0){
                                self.arrLocnField.text = [NSString stringWithFormat:@"%@ %@", placemark.name, placemark.subLocality];
                            }
                        } else {
                    
    //                        NSLog(@"%@", error.debugDescription);
                        }
                    }];
                   
                }
                //NSLog(@"arr loc = %@", self.arrLocnField.text);
                
                [def setBool:NO forKey:@"startNotifications"];

            } else {
                
                [[LocationServices sharedInstance].locationManager requestLocation];
                
                //Latest Location in coordinates
                CLLocation *latestLoc = [LocationServices sharedInstance].latestLoc;
                //NSLog(@"dep loc = %@", latestLoc);
                
                //Converting lat, long to 3 decimals only
                //NIKHIL BUG_151
                commonMethods *common = [[commonMethods alloc]init];
                NSNumberFormatter *lformatter = [common decimalFormatter];
                
                NSString *latString = [lformatter stringFromNumber: [NSNumber numberWithDouble: latestLoc.coordinate.latitude]];
                NSString *longiString = [lformatter stringFromNumber: [NSNumber numberWithDouble: latestLoc.coordinate.longitude]];
                
                arrLat = [NSNumber numberWithDouble:[latString doubleValue]];
                arrLong = [NSNumber numberWithDouble:[longiString doubleValue]];
                //NSLog(@"arr lat : %@, long : %@", arrLat, arrLong);
                
                //Accessing Loc_Table from DB
                NSManagedObjectContext *context = [[CoreDataController sharedInstance] newManagedObjectContext];
                NSError *err;
                
                NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Loc_Table"];
                
                NSArray *locationArray = [[NSArray alloc] init];
                locationArray = [context executeFetchRequest:request error:&err];
                //NSLog(@"locArr : %@", locationArray);
                
                //First set locFound to NO
                BOOL locFound = NO;
                
                //NIKHIL BUG_150
                if(![arrLat isEqual:@0.0] && ![arrLong isEqual:@0.0]){
                //Loop thr' each record in Loc_Table
                for (Loc_Table *location in locationArray) {
                    NSString *latString = [lformatter stringFromNumber: location.lat];
                    NSString *longiString = [lformatter stringFromNumber: location.longitude];
                    location.lat = [NSNumber numberWithDouble:[latString doubleValue]];
                    location.longitude = [NSNumber numberWithDouble:[longiString doubleValue]];
//                    NSLog(@"####Comparing lat long from db : %@, %@", location.lat, location.longitude);
//                    NSLog(@"####Comparing lat long from location : %@, %@", arrLat, arrLong);
                    
                    //Check if current lat, long present in that record of Loc_Table
                    if([arrLat floatValue] == [location.lat floatValue] && [arrLong floatValue] == [location.longitude floatValue]){
                        
                        //If present, set locFound to YES
                        locFound = YES;
                        self.arrLocnField.text = location.address;
                        
                        
                    } else {
                        
                        //Set locFound to NO
                        locFound = NO;
                    }
                }
                }
                
                //NIKHIL BUG_150
                if(locFound == NO && ![arrLat isEqual:@0.0] && ![arrLong isEqual:@0.0] && arrLat){
                    
                    //reverse geocode coordinates to identify location
                    [geoCoder reverseGeocodeLocation:latestLoc completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
                        
                        if(error == nil && [placemarks count] > 0){
                            
                            placemark = [placemarks lastObject];
                            
                            if(self.arrLocnField.text.length == 0){
                                self.arrLocnField.text = [NSString stringWithFormat:@"%@ %@", placemark.name, placemark.subLocality];
                            }
                        } else {
                            
                           // NSLog(@"%@", error.debugDescription);
                        }
                    }];
                }

            }
            
            //TO get vehid
            NSManagedObjectContext *contex = [[CoreDataController sharedInstance] newManagedObjectContext];
            NSError *err;
            
            NSFetchRequest *vehRequest = [[NSFetchRequest alloc] initWithEntityName:@"Veh_Table"];
            NSPredicate *vehPredicate = [NSPredicate predicateWithFormat:@"iD == %i",[comparestring intValue]];
            [vehRequest setPredicate:vehPredicate];
            NSArray *vehData = [contex executeFetchRequest:vehRequest error:&err];
            
            Veh_Table *vehicleData = [vehData firstObject];
            //till here
            
            NSString *vehid = vehicleData.vehid;
            //NSLog(@"gadiname:- %@",vehid);
            
            NSMutableDictionary *forFriendDict = [[NSMutableDictionary alloc]init];
            if([Def objectForKey:@"UserEmail"] != nil){
                [forFriendDict setObject:[Def objectForKey:@"UserEmail"] forKey:@"email"];
                [forFriendDict setObject:[Def objectForKey:@"UserName"] forKey:@"name"];
            }else{
                [forFriendDict setObject:@"" forKey:@"email"];
                [forFriendDict setObject:@"" forKey:@"name"];
            }
            [forFriendDict setObject:@"update" forKey:@"action"];
   
            NSFetchRequest *request=[[NSFetchRequest alloc] initWithEntityName:@"T_Trip"];
            NSPredicate *predicate;
            predicate = [NSPredicate predicateWithFormat:@"vehId==%@ AND tripComplete == 0",comparestring];
            [request setPredicate:predicate];
            
            NSArray *result=[contex executeFetchRequest:request error:&err];
            
            //Swapnil ENH_24
            T_Trip *dataval = [result firstObject];
            
            
            if(dataval != nil){
                
                [forFriendDict setObject:dataval.iD forKey:@"id"];
                
                if(dataval.depOdo != nil){
                    [forFriendDict setObject:dataval.depOdo forKey:@"oldOdo"];
                }
                if(dataval.tripType != nil){
                    [forFriendDict setObject:dataval.tripType forKey:@"oldServiceType"];
                }
                
                if([def boolForKey:@"showTripOdo"]){
                    dataval.depOdo = @([_depOdoField.text floatValue]);
                }else{
                    dataval.depOdo = @([maxOdo floatValue]);
                }
                if(dataval.depOdo != nil){
                    [forFriendDict setObject:dataval.depOdo forKey:@"odo"];
                }
                
                dataval.vehId=comparestring;
                if(dataval.vehId != nil){
                    [forFriendDict setObject:vehid forKey:@"vehid"];
                }
                
                dataval.tripType=_typeLabel.text;
                [forFriendDict setObject:_typeLabel.text forKey:@"serviceType"];
                
                dataval.depDate=depDate;
                [forFriendDict setObject:depDate forKey:@"date"];
                
                dataval.depLocn=_depLocnField.text;
                [forFriendDict setObject:_depLocnField.text forKey:@"fuelBrand"];
                
                
                dataval.arrDate=arrDate;
                commonMethods *common = [[commonMethods alloc] init];
                NSDictionary *epochDictionary = [common getDayMonthYrFromStringDate:dataval.arrDate];
                //Trim after decimals
                NSString *gotDate = [epochDictionary valueForKey:@"epochTime"];
                NSString *sendDate;
                if(gotDate.length>8){
                    sendDate = [gotDate substringToIndex:13];
                    [forFriendDict setObject:sendDate forKey:@"octane"];
                }else{
                    [forFriendDict setObject:gotDate forKey:@"octane"];
                }
                dataval.arrOdo=@([_arrOdoField.text floatValue]);
                [forFriendDict setObject:@([_arrOdoField.text floatValue]) forKey:@"qty"];
                
                dataval.arrLocn=_arrLocnField.text;
                [forFriendDict setObject:_arrLocnField.text forKey:@"fillStation"];
                
                dataval.parkingAmt=@([_parkingField.text floatValue]);
                [forFriendDict setObject:@([_parkingField.text floatValue]) forKey:@"OT"];
                
                dataval.tollAmt=@([_tollField.text floatValue]);
                [forFriendDict setObject:@([_tollField.text floatValue]) forKey:@"year"];
                
                dataval.taxDedn=@([_taxValueLabel.text floatValue]);
                [forFriendDict setObject:@([_taxValueLabel.text floatValue]) forKey:@"cost"];
                
                dataval.notes = _notesView.text;
                [forFriendDict setObject:_notesView.text forKey:@"notes"];
                
                
                //Trip Map database lat long
                dataval.depLatitude = depLat;
                if(depLat)
                    [forFriendDict setObject:depLat forKey:@"depLat"];
                
                dataval.depLongitude = depLong;
                if(depLong)
                    [forFriendDict setObject:depLong forKey:@"depLong"];
                
                dataval.arrLatitude = arrLat;
                if(arrLat)
                    [forFriendDict setObject:arrLat forKey:@"arrLat"];
                
                dataval.arrLongitude = arrLong;
                if(arrLong)
                    [forFriendDict setObject:arrLong forKey:@"arrLong"];
                
                dataval.tripComplete = YES;
                [forFriendDict setObject:@3 forKey:@"type"];
                
                if ([contex hasChanges])
                {
                    BOOL saved = [contex save:&err];
                    if (!saved) {
                        // do some real error handling
                        //CLSLog(@“Could not save Data due to %@“, error);
                    }
                    // NSLog(@"odometer saved");
                    [[CoreDataController sharedInstance] saveMasterContext];
                    
                    //Swapnil NEW_6
                    NSString *userEmail = [Def objectForKey:@"UserEmail"];
                    
                    //If user is signed In, then only do the sync process..
                    if(userEmail != nil && userEmail.length > 0){
                        
                        [self writeToSyncTableWithRowID:dataval.iD tableName:@"TRIP" andType:@"edit" andOS:@"self"];
                        
                        //To share data with friend
                        //Commented sync with friend "testing"🙃
//                        BOOL friendPresent = [self checkforConfirmedFriends];
//
//                        if(friendPresent){
//                            //NSLog(@"Call script ☺️ with Dictionary:- %@",forFriendDict);
//                            [self sendUpdatedRecordToFriend:forFriendDict];
//                        }

                     //   [self checkNetworkForCloudStorage];
                        
                    }
                    //Alert
                    [self showCompleteAlertFor:NSLocalizedString(@"trip_complete", @"Trip complete"):@"" :nil];
                    
                    //Swapnil 25-May-2017
                    BOOL proUser = [[NSUserDefaults standardUserDefaults] boolForKey:@"isAdDisabled"];
                    
                    if(!proUser){
                        NSInteger gadCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"adCount"];
                        gadCount = gadCount + 1;
                        [[NSUserDefaults standardUserDefaults] setInteger:gadCount forKey:@"adCount"];
                    }
                    
                    
                    [def setInteger :[def integerForKey:@"appopenstatus"]+1 forKey:@"appopenstatus"];
                    
//                    2.5 arche dam cha kadala 3 per guntha
//                    1-2 per guntha cha kadala nasli tar
                    //Notification on starting the Trip
                    //[[JRNLocalNotificationCenter defaultCenter] postNotificationOnNowForKey:@"TripEnd" alertBody:@"Your trip has Ended"];
                    
                    //Swapnil NEW_5
                    if([self.gpsButton isSelected]){
                        
                        //UnUserNotifications
                        [self showNotificationFor:NSLocalizedString(@"trip_complete", @"Trip complete")];
                        
                    } else {
                        
                        
                        [[JRNLocalNotificationCenter defaultCenter] postNotificationOn:[NSDate dateWithTimeIntervalSinceNow:1] forKey:@"Trip End" alertBody:NSLocalizedString(@"trip_complete", @"Trip complete") alertAction:nil soundName:nil launchImage:nil userInfo:@{@"trip":@"End"} badgeCount:1 repeatInterval:NO category:nil];
                        
                        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"showPage"];
                    }
                    
                    //Change the title of navigation Control to "Save Trip" and Update trip_state to 'Complete'
                    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"Save Trip" style:UIBarButtonItemStylePlain target:self action:@selector(saveTrip)];
                    _tripState = @"Complete";
                    
                }
                
                //BUG_86
                [self calcTax];
                
                //New_10 Inorder to stop location tracking if trip is ended manually
                [def setBool:YES forKey:@"tripEndedManually"];
                
                //New_10 To start auto trip as manual trip is ended
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"tripInProgress"];
            }
            
        }
        else
        {//Trip cannot be complete still
            [self showCompleteAlertFor:@"Cannot End Trip":_warning : NO];
        
        }
        
    }
    else if ([_tripState isEqualToString:@"Complete"])
    {//Trip is already complete. NO change required
    
        if(valid == 0)
        {
            //Update record from editTripDict
            
            //TO get vehid
            NSManagedObjectContext *contex = [[CoreDataController sharedInstance] newManagedObjectContext];
            NSError *err;
            
            NSFetchRequest *vehRequest = [[NSFetchRequest alloc] initWithEntityName:@"Veh_Table"];
            NSPredicate *vehPredicate = [NSPredicate predicateWithFormat:@"iD == %i",[comparestring intValue]];
            [vehRequest setPredicate:vehPredicate];
            NSArray *vehData = [contex executeFetchRequest:vehRequest error:&err];
            
            Veh_Table *vehicleData = [vehData firstObject];
            //till here
            
            NSString *vehid = vehicleData.vehid;
            //NSLog(@"gadiname:- %@",vehid);
            
            NSMutableDictionary *forFriendDict = [[NSMutableDictionary alloc]init];
            if([Def objectForKey:@"UserEmail"] != nil){
                [forFriendDict setObject:[Def objectForKey:@"UserEmail"] forKey:@"email"];
                [forFriendDict setObject:[Def objectForKey:@"UserName"] forKey:@"name"];
            }else{
                [forFriendDict setObject:@"" forKey:@"email"];
                [forFriendDict setObject:@"" forKey:@"name"];
            }
            [forFriendDict setObject:@"update" forKey:@"action"];
        
            NSFetchRequest *request=[[NSFetchRequest alloc] initWithEntityName:@"T_Trip"];
            NSPredicate *predicate;
            
            //AND arrOdo == %f, [[_editTripDict objectForKey:@"arrOdo"] floatValue]
            //[[_editTripDict objectForKey:@"odo"] floatValue]
            
            //Swapnil NEW_5
            
            if(self.editTripDict != nil){
                predicate = [NSPredicate predicateWithFormat:@"vehId==%@ AND depOdo == %f", oldComapreString, [[_editTripDict objectForKey:@"odo"] floatValue]];
            } else {
                predicate = [NSPredicate predicateWithFormat:@"vehId==%@ AND depOdo == %f", comparestring, [_depOdoField.text floatValue]];
            }
            
            
            [request setPredicate:predicate];
            
            NSArray *result=[contex executeFetchRequest:request error:&err];
            
            [self calcTax];

            //Swapnil ENH_24
            T_Trip *dataval = [result firstObject];
            
            if(dataval != nil){
                
                [forFriendDict setObject:dataval.iD forKey:@"id"];
                
                if(dataval.depOdo != nil){
                    [forFriendDict setObject:dataval.depOdo forKey:@"oldOdo"];
                }
                if(dataval.tripType != nil){
                    [forFriendDict setObject:dataval.tripType forKey:@"oldServiceType"];
                }
                if([def boolForKey:@"showTripOdo"]){
                    dataval.depOdo = @([_depOdoField.text floatValue]);
                    [forFriendDict setObject:@([_depOdoField.text floatValue]) forKey:@"odo"];
                }else{
                    dataval.depOdo = @([maxOdo floatValue]);
                    [forFriendDict setObject:@([maxOdo floatValue]) forKey:@"odo"];
                }
                
                dataval.vehId=oldComapreString;
                if(dataval.vehId != nil){
                    [forFriendDict setObject:vehid forKey:@"vehid"];
                }
                
                dataval.tripType=_typeLabel.text;
                [forFriendDict setObject:_typeLabel.text forKey:@"serviceType"];
                
                dataval.depDate=depDate;
                [forFriendDict setObject:depDate forKey:@"date"];
                
                dataval.depLocn=_depLocnField.text;
                [forFriendDict setObject:_depLocnField.text forKey:@"fuelBrand"];
                
                dataval.arrDate=arrDate;
                commonMethods *common = [[commonMethods alloc] init];
                NSDictionary *epochDictionary = [common getDayMonthYrFromStringDate:dataval.arrDate];
                //Trim after decimals
                NSString *gotDate = [epochDictionary valueForKey:@"epochTime"];
                NSString *sendDate;
                if(gotDate.length>8){
                    sendDate = [gotDate substringToIndex:13];
                    [forFriendDict setObject:sendDate forKey:@"octane"];
                }else{
                    [forFriendDict setObject:gotDate forKey:@"octane"];
                }
                
                dataval.arrOdo=@([_arrOdoField.text floatValue]);
                [forFriendDict setObject:@([_arrOdoField.text floatValue]) forKey:@"qty"];
                
                dataval.arrLocn=_arrLocnField.text;
                [forFriendDict setObject:_arrLocnField.text forKey:@"fillStation"];
                
                dataval.parkingAmt=@([_parkingField.text floatValue]);
                [forFriendDict setObject:@([_parkingField.text floatValue]) forKey:@"OT"];
                
                dataval.tollAmt=@([_tollField.text floatValue]);
                [forFriendDict setObject:@([_tollField.text floatValue]) forKey:@"year"];
                
                dataval.taxDedn=@([_taxValueLabel.text floatValue]);
                [forFriendDict setObject:@([_taxValueLabel.text floatValue]) forKey:@"cost"];
                
                dataval.notes = _notesView.text;
                [forFriendDict setObject:_notesView.text forKey:@"notes"];
                
                
                //Trip Map database lat long
                dataval.depLatitude = depLat;
                if(depLat)
                    [forFriendDict setObject:depLat forKey:@"depLat"];
                
                dataval.depLongitude = depLong;
                if(depLong)
                    [forFriendDict setObject:depLong forKey:@"depLong"];
                
                dataval.arrLatitude = arrLat;
                if(arrLat)
                    [forFriendDict setObject:arrLat forKey:@"arrLat"];
                
                dataval.arrLongitude = arrLong;
                if(arrLong)
                    [forFriendDict setObject:arrLong forKey:@"arrLong"];
                
                
                dataval.tripComplete = YES;
                [forFriendDict setObject:@3 forKey:@"type"];
                
                NSMutableDictionary *paramDict = [[NSMutableDictionary alloc] init];
                //Swapnil ENH_11
                if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse && [CLLocationManager locationServicesEnabled]){
                    
                    //NIKHIL BUG_151
                    commonMethods *common = [[commonMethods alloc]init];
                    NSNumberFormatter *lformatter = [common decimalFormatter];
                    //Accessing Loc_Table from DB
                    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Loc_Table"];
                    
                    NSArray *locationArray = [[NSArray alloc] init];
                    locationArray = [contex executeFetchRequest:request error:&err];
                    //NSLog(@"locArr : %@", locationArray);
                    
                    
                    BOOL isPresent = NO;
                    //NIKHIL BUG_150
                    if(![arrLat isEqual:@0.0] && ![arrLong isEqual:@0.0])
                    {
                        for(Loc_Table *location in locationArray){
                            NSString *latString = [lformatter stringFromNumber: location.lat];
                            NSString *longiString = [lformatter stringFromNumber: location.longitude];
                            location.lat = [NSNumber numberWithDouble:[latString doubleValue]];
                            location.longitude = [NSNumber numberWithDouble:[longiString doubleValue]];
                            //                       NSLog(@"####Comparing lat long from db : %@, %@", location.lat, location.longitude);
                            //                       NSLog(@"####Comparing lat long from loc : %@, %@", arrLat, arrLong);
                            
                            //If location already present in Loc_Table dont add a new one
                            if([arrLat floatValue] == [location.lat floatValue] && [arrLong floatValue] == [location.longitude floatValue]){
                                
                                isPresent = YES;
                                
                                if(![location.address isEqualToString:self.arrLocnField.text]){
                                    
                                    location.address = self.arrLocnField.text;
                                    [paramDict setObject:location.iD forKey:@"rowid"];
                                    [paramDict setObject:@"edit" forKey:@"type"];
                                }
                                
                            }
                            
                            else {
                                isPresent = NO;
                            }
                        }
                    }
                    //If location not present in Loc_table then add new location
                    //NIKHIL BUG_150
                    if(isPresent == NO && ![arrLat isEqual:@0.0] && ![arrLong isEqual:@0.0] && arrLat){
                        Loc_Table *locationData = [NSEntityDescription insertNewObjectForEntityForName:@"Loc_Table" inManagedObjectContext:contex];
                        
                        //Swapnil NEW_6
                        int locID;
                        if([Def objectForKey:@"maxLocID"] != nil){
                            
                            locID = [[Def objectForKey:@"maxLocID"] intValue];
                        } else {
                            
                            locID = 0;
                        }
                        
                        locationData.iD = [NSNumber numberWithInt:locID + 1];
                        [Def setObject:locationData.iD forKey:@"maxLocID"];
                        locationData.address = self.arrLocnField.text;
                        //NIKHIL BUG_151
                        locationData.lat = arrLat;
                        locationData.longitude = arrLong;
                        [paramDict setObject:locationData.iD forKey:@"rowid"];
                        //              NSLog(@"####loc.lat and loc.long after saving to database saveTrip-2:::%@   %@",locationData.lat,locationData.longitude);
                        [paramDict setObject:@"add" forKey:@"type"];
                        
                    }
                }
                
                
                if ([contex hasChanges])
                {
                    BOOL saved = [contex save:&err];
                    if (!saved) {
                        // do some real error handling
                        //CLSLog(@“Could not save Data due to %@“, error);
                    }
                    // NSLog(@"odometer saved");
                    [[CoreDataController sharedInstance] saveMasterContext];
                    
                    //Swapnil NEW_6
                    NSString *userEmail = [Def objectForKey:@"UserEmail"];
                    
                    //If user is signed In, then only do the sync process..
                    if(userEmail != nil && userEmail.length > 0){
                        
                        [self writeToSyncTableWithRowID:dataval.iD tableName:@"TRIP" andType:@"edit" andOS:@"self"];
                        
                        //To share data with friend
                        //Commented sync with friend "testing"🙃
//                        BOOL friendPresent = [self checkforConfirmedFriends];
//
//                        if(friendPresent){
//                            //NSLog(@"Call script ☺️ with Dictionary:- %@",forFriendDict);
//                            [self sendUpdatedRecordToFriend:forFriendDict];
//                        }

                        if(paramDict != nil && paramDict.count > 0){
                            
                            [self writeToSyncTableWithRowID:[paramDict objectForKey:@"rowid"] tableName:@"LOC_TABLE" andType:[paramDict objectForKey:@"type"] andOS:@"self"];
                        }
                     //   [self checkNetworkForCloudStorage];
                    }
                    //Alert
                    [self showCompleteAlertFor:@"Trip Saved":@"" : YES];
                    
                    //Swapnil 25-May-2017
                    BOOL proUser = [[NSUserDefaults standardUserDefaults] boolForKey:@"isAdDisabled"];
                    
                    if(!proUser){
                        NSInteger gadCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"adCount"];
                        gadCount = gadCount + 1;
                        [[NSUserDefaults standardUserDefaults] setInteger:gadCount forKey:@"adCount"];
                    }
                    
                    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
                    [def setInteger :[def integerForKey:@"appopenstatus"]+1 forKey:@"appopenstatus"];
                    
                    [def setObject:[def objectForKey:@"fillupid"] forKey:@"oldFillupid"];
                    [def setBool:NO forKey:@"editPageOpen"];
                }
                
            }
            
        }
        else{
            //Prompt user to fix the fields and try again
            [self showCompleteAlertFor:@"Cannot Save Trip":_warning : NO];

        }
    }


    //[self showNotificationFor:@"Just"];

    }//Swapnil BUG_76
    else {
       
            [self showAlert:@"" message:@"Distance Traveled cannot be 0"];
       
    }
    
}

#pragma mark Friend Single Sync Methods
-(BOOL)checkforConfirmedFriends{
    
    //TO get confirmed friends
    NSManagedObjectContext *contex = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSError *err;
    NSString *comparestring = @"confirm";
    NSFetchRequest *friendRequest = [[NSFetchRequest alloc] initWithEntityName:@"Friends_Table"];
    NSPredicate *friendPredicate = [NSPredicate predicateWithFormat:@"status == %@",comparestring];
    [friendRequest setPredicate:friendPredicate];
    NSArray *frndData = [contex executeFetchRequest:friendRequest error:&err];
    
    if (frndData.count>0) {
        //NSLog(@"myFriends:- %@",frndData);
        return YES;
    }else{
        
        return NO;
    }
}

//-(void)sendUpdatedRecordToFriend:(NSDictionary *)friendDict{
//
//    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
//    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
//
//    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
//    NSMutableDictionary *parametersDict = [[NSMutableDictionary alloc]init];
//    parametersDict = [friendDict mutableCopy];
//    NSDate *date = [friendDict objectForKey:@"date"];
//
//    //syncData[8] = String.valueOf(myDepDate);       params.put("day", vals[8]);
//
//   commonMethods *common = [[commonMethods alloc] init];
//    NSDictionary *epochDictionary = [common getDayMonthYrFromStringDate:date];
//    int month = [[epochDictionary valueForKey:@"month"] intValue] -1;
//    [parametersDict setObject:[epochDictionary valueForKey:@"day"] forKey:@"day"];
//    [parametersDict setValue:[NSNumber numberWithInt:month] forKey:@"month"];
//    [parametersDict setObject:[epochDictionary valueForKey:@"year"] forKey:@"year"];
//    [parametersDict setObject:[epochDictionary valueForKey:@"hours"] forKey:@"pfill"];
//    [parametersDict setObject:[epochDictionary valueForKey:@"minutes"] forKey:@"mfill"];
//
//    //NSLog(@"date:- %@",epochDictionary);
//
//    //Trim after decimals
//    NSString *gotDate = [epochDictionary valueForKey:@"epochTime"];
//    NSString *sendDate;
//    if(gotDate.length>8){
//        sendDate = [gotDate substringToIndex:13];
//        [parametersDict setObject:sendDate forKey:@"date"];
//    }else{
//        [parametersDict setObject:gotDate forKey:@"date"];
//    }
//    //NSLog(@"date:- %@",sendDate);
//
//
//
//    //NSLog(@"Friend dict to be sent, has arrived here,  woohoo::- %@",parametersDict);
//    if(networkStatus == NotReachable){
//
//        [CheckReachability.sharedManager startNetworkMonitoring];
//    } else {
//
//        NSError *err;
//        NSData *postDataArray = [NSJSONSerialization dataWithJSONObject:parametersDict options:NSJSONWritingPrettyPrinted error:&err];
//
//        [def setBool:NO forKey:@"updateTimeStamp"];
//        [common saveToCloud:postDataArray urlString:kFriendSyncDataScript success:^(NSDictionary *responseDict) {
//
//            //NSLog(@"ResponseDict is : %@", responseDict);
//
//            if([[responseDict valueForKey:@"success"]  isEqual: @1]){
//
//                //NSLog(@"success:- %@",[responseDict valueForKey:@"success"]);
//
//            }else{
//
//                AppDelegate *app = [[AppDelegate alloc]init];
//                NSString* alertBody = @"Failed to sync data.";
//                [app showNotification:@"":alertBody];
//
//            }
//
//        } failure:^(NSError *error) {
//
//        }];
//    }
//
//}

#pragma mark UITextFieldDelegate methods
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    //NIKHIL ENH_50 decimalPad given to Odometer textField
    if(textField == _depOdoField || textField == _arrOdoField || textField == _distanceField){
        
        textField.keyboardType = UIKeyboardTypeDecimalPad;
    }
    _currentField = textField;
    buttonOrigin = _currentField.frame.origin;

    if (textField == _depDateTimeField || textField == _arrDateTimeFld)
    {
        [textField resignFirstResponder];
    }
    

    return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if(textField == _depLocnField || textField == _arrLocnField){
        if([textField.text containsString:@","]){
            
            UIAlertController *alertControl = [UIAlertController alertControllerWithTitle: [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"location", @"Location"), NSLocalizedString(@"comma_err", @"cannot accept commas")]
                                                                message:nil
                                                preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"ok action") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                
            }];
            [alertControl addAction:ok];
            [self presentViewController:alertControl animated:YES completion:nil];
            NSString *Stringval = [textField.text stringByReplacingOccurrencesOfString:@"," withString:@""];
            textField.text = Stringval;
        }

    }
  
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    //_field.background = [UIImage imageNamed:@"nofocus.png"];
    

    if (textField ==_depOdoField && _depOdoField.text.length > 0) {
        
//        float startOdo = [_depOdoField.text floatValue];
//        NSDate* startDate = [f dateFromString: _depDateTimeField.text];
        
        //[self checkOdo:startOdo ForDate:startDate];
        
        //Swapnil BUG_76
        //Nikhil ENH_51 removed odo check for trips
//        if([self checkOdo:startOdo ForDate:startDate] == NO){
//            [self showAlert:NSLocalizedString(@"incorrect_odo", @"Incorrect Odometer value for Date") message:@""];
//        }
        
 
    }
    if (textField ==_parkingField || textField ==_tollField){
        
        [self calcTax];
        
        if([_parkingField.text isEqualToString:@""]){
            _parkingField.placeholder = @"Parking";
            _parkingLabel.hidden = YES;
        }else{
            _parkingLabel.hidden = NO;
        }
        if([_tollField.text isEqualToString:@""]){
            _tollField.placeholder =@"Toll";
            _tollLabel.hidden = YES;
        }else{
            _tollLabel.hidden = NO;
        }
        
    }
    
    if(textField == _distanceField){
        
       float startOdo = [_depOdoField.text floatValue];
       float distance = [_distanceField.text floatValue];
       float endOdo = startOdo + distance;
        
       _arrOdoField.text = [NSString stringWithFormat:@"%.2f", endOdo];
       [self calcTax];
    }
    
    
        
    if (textField ==_arrOdoField && _arrOdoField.text.length > 1) {
        
        NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
        if([def boolForKey:@"showTripOdo"]){
            
//            float endOdo = [_arrOdoField.text floatValue];
//            NSDate* endDate = [f dateFromString: _arrDateTimeFld.text];
//
//            //Swapnil BUG_76
//            if([self checkOdo:endOdo ForDate:endDate] == NO){
//                [self showAlert:@"Arrival odometer should be greater than departure odometer" message:@""];
//            }
//
//            BOOL valid = [self validateOdo];
//
//
//           if (!valid) {
//               _arrOdoField.text = nil;
//               _arrOdoLabel.hidden = YES;
//               _arrOdoField.placeholder = @"Odometer";
//           }
            float arrodo;
            if(_arrOdoField.text != nil){
                
                arrodo = [_arrOdoField.text floatValue] - [_depOdoField.text floatValue];
                NSString *arr = [NSString stringWithFormat:@"%.2f", arrodo];
                _distanceField.text = arr;
                [self calcTax];
            }
           
            
       }else{
        
        float distance = [_distanceField.text floatValue];
        if(distance <= 0 ){
            
            [self showAlert:@"Incorrect Odometer" message:@""];
        }
      }
    
    }
   
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    
    if (textField == _depDateTimeField || textField == _arrDateTimeFld) {
        
        [self openDatepickerforTag:textField.tag] ;
        [textField resignFirstResponder];
    }

    
    
    if (textField == _depOdoField) {
        
       [self addNumberKeyboard];
       _depOdoLabel.hidden = NO;
       _depOdoField.placeholder = nil;
       
   }
    if (textField == _depLocnField) {
        //_depOdoField.hidden = NO;
        //[self addNumberKeyboard];
        _depLocnLabel.hidden = NO;
        _depLocnField.placeholder = nil;
        
    }

    if (textField == _arrOdoField) {
        //_depOdoField.hidden = NO;
        [self addNumberKeyboard];
        _arrOdoLabel.hidden = NO;
        _arrOdoField.placeholder = nil;
        
    }
    if (textField == _arrLocnField) {
        //_depOdoField.hidden = NO;
        [self addNumberKeyboard];
        _arrLocnLabel.hidden = NO;
        _arrLocnField.placeholder = nil;
        
    }
    if (textField == _parkingField) {
        _parkingLabel.hidden = NO;
        [self addNumberKeyboard];
        _parkingField.placeholder = nil;
        
    }
    if (textField == _tollField) {
        _tollLabel.hidden = NO;
        [self addNumberKeyboard];
        _tollField.placeholder = nil;
        
    }
    
    if(textField == _taxPercField){
        
        //New_10 Nikhil 1December2018 Auto Trip Loging
        [textField resignFirstResponder];
        TaxDeductionViewController *taxScreen =(TaxDeductionViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"taxDeduction"];
        taxScreen.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:taxScreen animated:YES completion:nil];

    }
    
    if(textField == _distanceField){
        _distanceLabel.hidden = NO;
        [self addNumberKeyboard];
        _distanceField.placeholder = nil;
    }
    
}

-(void)textfieldSetting:(UITextField *)textField{

    NSMutableAttributedString *placeholderAttributedString = [[NSMutableAttributedString alloc] initWithAttributedString:textField.attributedPlaceholder];
    [placeholderAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:NSMakeRange(0, [placeholderAttributedString length])];
    textField.attributedPlaceholder = placeholderAttributedString;
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    
    if(textField == _depLocnField || textField == _arrLocnField){
        if([textField.text containsString:@","]){
            
            UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"location", @"Location"), NSLocalizedString(@"comma_err", @"cannot accept commas")] message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"ok action") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                
            }];
            [alertControl addAction:ok];
            [self presentViewController:alertControl animated:YES completion:nil];
            NSString *Stringval = [textField.text stringByReplacingOccurrencesOfString:@"," withString:@""];
            textField.text = Stringval;
        }
        
    }
   
    if(textField == _taxPercField){
        
       [self updateTaxPercField];
        //NIKHIL BUG_128 //added call to calcTax in order to calculate total during tax rate change
        [self calcTax];
    }
    
}

#pragma mark UITextViewDelegate methods

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    //NSLog(@"textViewShouldBeginEditing:");
    
    buttonOrigin = textView.frame.origin;

    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    
    if ([text isEqualToString:@"\n"]) {
        
        [textView resignFirstResponder];
        // Return FALSE so that the final '\n' character doesn't get added
        return NO;
    }
    
    if(textView == _notesView){
        
        if([textView.text containsString:@","]){
            
            UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"comma_enter_err", @"Notes cannot accept commas") message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"ok action") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                
            }];
            [alertControl addAction:ok];
            [self presentViewController:alertControl animated:YES completion:nil];
            NSString *Stringval = [textView.text stringByReplacingOccurrencesOfString:@"," withString:@""];
            textView.text = Stringval;
        }
    }
    
    // For any other character return TRUE so that the text gets added to the view
    return YES;
}
- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
    
    return YES;
    
}

-(void)textViewDidEndEditing:(UITextView *)textView{
    
    if(textView == _notesView){
        
        if([textView.text containsString:@","]){
            
            UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"comma_enter_err", @"Notes cannot accept commas") message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"ok action") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                
            }];
            [alertControl addAction:ok];
            [self presentViewController:alertControl animated:YES completion:nil];
            NSString *Stringval = [textView.text stringByReplacingOccurrencesOfString:@"," withString:@""];
            textView.text = Stringval;
        }
    }
}

#pragma mark Numeric Keyboard methods

- (void)registerForKeyboardNotifications {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
}

- (void)deregisterFromKeyboardNotifications {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidHideNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    
}

- (void)keyboardWasShown:(NSNotification *)notification {
    
    NSDictionary* info = [notification userInfo];
    
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    
   //Get old offset
    
    oldY = self.scrollView.contentOffset.y;
    oldX = self.scrollView.contentOffset.x;

    
    CGFloat buttonHeight = _currentField.frame.size.height;
    
    CGRect visibleRect = self.view.frame;
    
    visibleRect.size.height -= (keyboardSize.height + 100);
    
    if (!CGRectContainsPoint(visibleRect, buttonOrigin)){
        
        CGPoint scrollPoint = CGPointMake(0.0, buttonOrigin.y - visibleRect.size.height + buttonHeight+40);
        
        
        [self.scrollView setContentOffset:scrollPoint animated:YES];
        //NSLog(@"scrollPoint Coordinates is %@",NSStringFromCGPoint( scrollPoint));
        

        
    }
    
}

- (void)keyboardWillBeHidden:(NSNotification *)notification {
    
    //[self.scrollView setContentOffset:CGPointZero animated:YES];
    [self.scrollView setContentOffset: CGPointMake(oldX, oldY+ 1) animated:YES];
    
}
-(void)addNumberKeyboard {
    
    
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.barStyle = UIBarStyleDefault;
    numberToolbar.backgroundColor =[UIColor whiteColor];
    numberToolbar.items = [NSArray arrayWithObjects:
                           [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"cancel", @"Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(cancelNumberPad)],
                           [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad)],
                           nil];
    [numberToolbar sizeToFit];
    
    if (_currentField == _depOdoField || _currentField == _arrOdoField || _currentField == _parkingField|| _currentField == _tollField || _currentField == _distanceField) {
        //NSLog(@"YEs");
        _currentField.inputAccessoryView = numberToolbar;
       // _currentField.keyboardType = UIKeyboardTypeDecimalPad;
    }
    
}


-(void)cancelNumberPad{
    
    if (_currentField == _depOdoField || _currentField == _arrOdoField || _currentField == _parkingField|| _currentField == _tollField || _currentField == _distanceField)
    {
        [_currentField resignFirstResponder];
        _currentField.text = @"";
    }
    
}

-(void)doneWithNumberPad{
    
    if (_currentField == _depOdoField || _currentField == _arrOdoField || _currentField == _parkingField|| _currentField == _tollField || _currentField == _distanceField) {
        [_currentField resignFirstResponder];
    }
    
}


#pragma mark Date choose


-(void)openDatepickerforTag:(NSInteger)tag
{
    //NIKHIL BUG_134 //added setbutton removefromsuperview
    [_datePicker removeFromSuperview];
    [_setbutton removeFromSuperview];
    
    _datePicker=[[UIDatePicker alloc] init];
    NSString *str;
    AppDelegate *App = [AppDelegate sharedAppDelegate];
    _datePicker.frame = CGRectMake(App.result.width/2-130,App.result.height/2-220, 260, 270);
    _datePicker.backgroundColor=[self colorFromHexString:@"#edebeb"];
    
    UIBezierPath *maskPath;
    maskPath = [UIBezierPath bezierPathWithRoundedRect:_datePicker.bounds
                                     byRoundingCorners:(UIRectCornerTopLeft|UIRectCornerTopRight)
                                           cornerRadii:CGSizeMake(5.0, 5.0)];
    
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.view.frame;
    maskLayer.path = maskPath.CGPath;
    _datePicker.layer.mask = maskLayer;
    _datePicker.timeZone=[NSTimeZone localTimeZone];
    _datePicker.datePickerMode=UIDatePickerModeDateAndTime;
    str = NSLocalizedString(@"date_hint", @"Set Date");
    
    if (tag ==50) {
        self.pickerval= @"DepDate";
    }
    else
        self.pickerval= @"ArrDate";
    
    UIView *topview = (UIView*)[self.view viewWithTag:-2];
    [topview addSubview:_datePicker];
    _setbutton =[[UIButton alloc]init];
    _setbutton.frame = CGRectMake(App.result.width/2-130,(App.result.height/2-220)+270, 260, 40);
    [_setbutton setBackgroundColor:[UIColor lightGrayColor]];
    [_setbutton setTitle:NSLocalizedString(@"set", @"Set") forState:UIControlStateNormal];
    [_setbutton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_setbutton addTarget:self action:@selector(setDate) forControlEvents:UIControlEventTouchUpInside];
    [topview addSubview:_setbutton];
}

-(void)setDate
{
    
    [_datePicker removeFromSuperview];
    [self.picker removeFromSuperview];
    [self.setbutton removeFromSuperview];
    NSString *date=[f stringFromDate:_datePicker.date];

    if([self.pickerval isEqualToString:@"DepDate"])
    {
        _depDateTimeField.text = date;
        NSDate* startDate = [f dateFromString: _depDateTimeField.text];
        float startOdo = [_depOdoField.text floatValue];
        
        if (_depOdoField.text > 0 ) {
            [self checkOdo:startOdo ForDate:startDate];
        }
        
        
    }
    if([self.pickerval isEqualToString:@"ArrDate"])
    {
        
        _arrDateTimeFld.text = date;
        [self validateTime ];
    }

}

#pragma mark Validation & Calculation methods

-(int)checkTextFieldsIfNil {
   
    int valid = 0;

    
        _warning = [[NSString alloc]init];
    if (_depOdoField.text.length <= 1)
    { //invalid Departure
        valid = 1;
        _warning = [_warning stringByAppendingString:@"Departure Odometer,"];
    
    }
    else if (_arrOdoField.text.length <= 1 || _arrDateTimeFld.text.length == 0)
    {
     //Invalid Arrival
        valid = 2;
        if (_arrOdoField.text.length <= 1 )
            {
            _warning = [_warning stringByAppendingString:@"Arrival Odometer,"];
            }
       
        if (_arrDateTimeFld.text.length == 0 &&( [_tripState isEqualToString:@"New"] || [_tripState isEqualToString:@"Complete"])) {
            _warning = [_warning stringByAppendingString:@"Arrival Date,"];
            }
    
    }
    
        
    if (_warning.length > 0) {
        //Remove trailing comma's
        _warning = [_warning substringToIndex:[_warning length] - 1];
        _warning = [@"The following fields cannot be empty: " stringByAppendingString:_warning];
    
    }
     
    
    return  valid;
}

-(BOOL)validateOdo{
    
    float startOdo = [_depOdoField.text floatValue];
    float endOdo = [_arrOdoField.text floatValue];
    
    if (endOdo < startOdo) {
        
        [self showAlert:NSLocalizedString(@"invalid_at_msg3", @"Arrival Odometer cannot be less than Departure Odometer")  message:@""];
        
       
        
        return NO;
        
    }
    else {
    
        [self calcTax];
    
    
    return YES;
    
    }
    
}


-(void)calcTax {
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    float startOdo;
    float endOdo;
    float distance;
    if([def boolForKey:@"showTripOdo"]){
        
        startOdo = [_depOdoField.text floatValue];
        endOdo = [_arrOdoField.text floatValue];
        distance = endOdo - startOdo;
       
    }else{
        
        startOdo = [maxOdo floatValue];
        distance = [_distanceField.text floatValue];
        endOdo = startOdo + distance;
     
    }
    
    float taxDedc = (endOdo-startOdo)* [_taxPercField.text floatValue] + [_parkingField.text floatValue] + [_tollField.text floatValue];
    _taxValueLabel.text = [[NSNumber numberWithFloat:taxDedc] stringValue];
    _distanceField.text = [NSString stringWithFormat:@"%.2f",distance];
    _arrOdoField.text = [NSString stringWithFormat:@"%.2f", endOdo];
    _distanceLabel.hidden = NO;
    
}

-(BOOL)validateTime{
    
    //check if end time > than start time
    
    NSDate* stDate = [f dateFromString:_depDateTimeField.text];
    NSDate* endDate =[f dateFromString:_arrDateTimeFld.text];
    NSTimeInterval distanceBetweenDates = [endDate timeIntervalSinceDate:stDate];
    
    if (distanceBetweenDates <= 0) {
        //show alert of wrong dates
//        UIAlertView* wrongTime =[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"invalid_at_msg4", @"Arrival date/time cannot be less than departure date/time") message:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil];
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:NSLocalizedString(@"invalid_at_msg4", @"Arrival date/time cannot be less than departure date/time")
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
        //wrongTime.tag = 1;
        //[wrongTime show];
        _arrDateTimeFld.text = nil; 
        _arrDateTimeFld.placeholder=NSLocalizedString(@"select_date", @"Select Date");
        return NO;
        
    }
    else{
        //calculate the total time
        [self calcTime];
        return YES;
        
    }
    
    
    
    
}


-(void) calcTime
{
    NSDate* stDate = [f dateFromString:_depDateTimeField.text];
    NSDate* endDate =[f dateFromString:_arrDateTimeFld.text];
    NSTimeInterval distanceBetweenDates = [endDate timeIntervalSinceDate:stDate];
    
    double secondsInAnHour = 3600;
    NSInteger hours = distanceBetweenDates / secondsInAnHour;
    
    NSString* totalTime = @"";
    //totalTime = [NSString stringWithFormat:@"%.3f", hours];
    
    //NSLog(@" hours =%@", totalTime );
    
    //NSInteger hours = distanceBetweenDates / secondsInAnHour;
    //NSLog(@" hours = %ld", (long)hours );
    NSInteger minutes = (distanceBetweenDates - (hours*3600))/60;
    //NSLog(@" minutes = %ld", (long)minutes );
    
    
    NSString* hr = [NSString stringWithFormat: @"%ld", (long)hours];
    NSString* min = [NSString stringWithFormat: @"%ld", (long)minutes];
    
    
    totalTime = [[[hr stringByAppendingString:@"h "] stringByAppendingString: min] stringByAppendingString:@"m"] ;
    
    if([totalTime isEqualToString:@"0h 0m"]){
        _timeValueLabel.text = NSLocalizedString(@"time_traveled", @"Time Traveled");
        _timetraveledLabel.hidden = YES;
    }else{
        _timeValueLabel.text = totalTime;
        _timetraveledLabel.hidden = NO;
    }

}


#pragma mark GENERAL methods

-(UIColor *)colorFromHexString:(NSString *)hexString
{
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

-(BOOL)checkOdo:(float)iOdo ForDate:(NSDate*)iDate
{
    //Swapnil BUG_76
    //commonMethods *commMethod = [[commonMethods alloc] init];
    BOOL valuesOK = NO;
    if(_depOdoField.text.length > 0 && [f dateFromString:_depDateTimeField.text] != nil && _arrOdoField.text.length == 0 && [f dateFromString:_arrDateTimeFld.text] == nil){
        valuesOK = YES;
    } else if (_arrOdoField.text.length > 0 && [f dateFromString:_arrDateTimeFld.text] != nil){
        float startOdo = [_depOdoField.text floatValue];
        float endODo = [_arrOdoField.text floatValue];
        if(endODo > startOdo){
            valuesOK = YES;
        }else{
            valuesOK = NO;
        }
    }
    recOrder = [[NSUserDefaults standardUserDefaults] objectForKey:@"recordOrder"];
    prevOdo = [[NSUserDefaults standardUserDefaults] floatForKey:@"prevOdom"];
    return valuesOK;
    
}

- (void)showAlert:(NSString *)title message:(NSString *)message {
    
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:title
                                          message:message
                                          preferredStyle:UIAlertControllerStyleAlert];
    
//    UIAlertAction *okAction = [UIAlertAction
//                               actionWithTitle:NSLocalizedString(@"OK", @"OK action")
//                               style:UIAlertActionStyleDefault
//                               handler:^(UIAlertAction *action)
//                               {
//                                   
//                               }];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"ok", @"OK action")
                               style:UIAlertActionStyleDefault
                               handler:nil];
    
    
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
    
}



-(void)showNotificationFor:(NSString*)title
{
    
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.title = [NSString localizedUserNotificationStringForKey:title arguments:nil];
    
    NSString *metric;
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"dist_unit"] isEqualToString:NSLocalizedString(@"disp_miles", @"Miles")]){
        metric = NSLocalizedString(@"mi", @"mi");
    } else {
        metric = NSLocalizedString(@"kms", @"Km");
    }
    
    content.body = [NSString stringWithFormat:@"%@ : %.2f %@", NSLocalizedString(@"trp_distance", @"Trip Distance"), [_distanceField.text floatValue], metric];
    //content.body = [NSString localizedUserNotificationStringForKey:[NSString stringWithFormat:@"%@ : %.2f %@", NSLocalizedString(@"trp_distance", @"Trip Distance"), gpsDistance, metric]
                                                         //arguments:nil];
    //content.sound = [UNNotificationSound defaultSound];
    
    /// 4. update application icon badge number
//    content.badge = ([NSNumber numberWithInteger:[[UIApplication sharedApplication] applicationIconBadgeNumber] + 1]) ;
    
    content.badge = nil;
    // Deliver the notification in five seconds.
    UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger
                                                  triggerWithTimeInterval:1.f repeats:NO];
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"FiveSecond"
                                                                          content:content trigger:trigger];
    /// 3. schedule localNotification
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        if (!error) {
           // NSLog(@"add NotificationRequest succeeded!");
        }
    }];
    
}


//Swapnil 13 Mar-17
- (void)updateTaxPercField{
    
    self.tripTypeArray =[[NSMutableArray alloc]init];

    NSManagedObjectContext *contex = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSFetchRequest *request=[[NSFetchRequest alloc] initWithEntityName:@"Services_Table"];
    
    

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type==3 AND serviceName == %@", _typeLabel.text];
    [request setPredicate:predicate];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"serviceName" ascending:YES];
    
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    
    [request setSortDescriptors:sortDescriptors];
    
    
    
    NSError *err;
    NSArray *data=[contex executeFetchRequest:request error:&err];
    
    
    
        NSNumberFormatter *textToNumber = [[NSNumberFormatter alloc] init];
        textToNumber.numberStyle = NSNumberFormatterDecimalStyle;
    
        NSNumber *taxPerc;
        if(_taxPercField.text.length != 0){
            taxPerc = [textToNumber numberFromString:_taxPercField.text];
        } else {
            taxPerc = @(0);
        }
    
    if(data.count > 0){
        
        //Swapnil ENH_24
        Services_Table *dataVal = [data firstObject];
        dataVal.dueMiles = taxPerc;
    }
    
        //NSLog(@"self.tripTypeArray: %@", self.tripTypeArray);
        if ([contex hasChanges])
        {
            BOOL saved = [contex save:&err];
            if (!saved) {
                // do some real error handling
                //CLSLog(@“Could not save Data due to %@“, error);
            }
            [[CoreDataController sharedInstance] saveMasterContext];
            NSLog(@"saved");
       }
    

}


- (IBAction)savePressed:(id)sender {
    
    [self saveTrip];
}

-(void)showPopUps:(NSString *)tite :(NSString *)message{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:tite message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
   
        }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"Cancel") style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:ok];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
    
}

#pragma mark GPS TRACKING METHODS

//Swapnil NEW_5
- (IBAction)gpsButtonChecked:(id)sender {
    BOOL proUser = [[NSUserDefaults standardUserDefaults] boolForKey:@"isAdDisabled"];
    
    if(proUser){
        
        //Requset permission for location access to singleton class
        NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
        BOOL tripLocPopUpShown = [def boolForKey:@"tripLocPopUpShown"];
        if(!tripLocPopUpShown){
            
            if ([CLLocationManager authorizationStatus]==kCLAuthorizationStatusDenied){
                
                [self showPopUps:@"Need location access to detect station" :@"To re-enable, please go to Settings and turn on Location Service for this app."];
                
            }else if(![CLLocationManager locationServicesEnabled] || !([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse)){
                
                NSString *message = @"Simply Auto needs access to your location to auto detect trip arrival location and to track trips via GPS.";
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"OK") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    
                    [[LocationServices sharedInstance].locationManager requestWhenInUseAuthorization];
                }];
                
                [alert addAction:ok];
                [self presentViewController:alert animated:YES completion:nil];
            }
            [def setBool:YES forKey:@"tripLocPopUpShown"];
        }
        
        
        if([sender isSelected]){
            
            //User unchecks gps tracking while trip in progress
            if([self.tripState isEqualToString:@"InProgress"]){
                
                //Stop tracking location
                [[LocationServices sharedInstance].locationManager stopUpdatingLocation];
                
                [LocationServices sharedInstance].locationManager.allowsBackgroundLocationUpdates = NO;
                //NSLog(@"stopped location updates");
            }
            
            [sender setImage:[UIImage imageNamed:@"uncheck"] forState:UIControlStateNormal];
            [sender setSelected:NO];
        } else {
            
            if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse){
                
                //User checks gps tracking while trip in progress
                if([self.tripState isEqualToString:@"InProgress"]){
                    
                    //Start location tracking
                    [[LocationServices sharedInstance].locationManager startUpdatingLocation];
                    
                    [LocationServices sharedInstance].locationManager.allowsBackgroundLocationUpdates = YES;
                    //NSLog(@"started location updates");
                    [self showNotificationFor:@"Trip In Progress"];
                    
                }
                [sender setImage:[UIImage imageNamed:@"check"] forState:UIControlStateSelected];
                [sender setSelected:YES];
            } else if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
                
                [self showAlert:NSLocalizedString(@"enable_location", @"Enable Location") message:NSLocalizedString(@"gps_tracking_not_poss", @"Tracking via GPS is not possible, since Simply Auto does not have permission to access location.")];
                //            [sender setImage:[UIImage imageNamed:@"uncheck"] forState:UIControlStateNormal];
                //            [sender setSelected:NO];
            }
        }
        
        if([sender isSelected]){
            
            //gpsSelected = YES;
            // [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"chkMarkSelected"];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"gpsSelect"];
        } else {
            
            //gpsSelected = NO;
            //[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"chkMarkSelected"];
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"gpsSelect"];
            
        }
    }
    else {
        
        [self goProAlert:NSLocalizedString(@"trip_go_pro_msg", @"Tracking via GPS is only available in the Pro version.") message:@""];
    }
}


- (void)goProAlert:(NSString *)title message:(NSString *)message {
    
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:title
                                          message:message
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"cancel", @"Cancel action")
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       
                                   }];
    
    //NSString *go_pro_btn = @"Go Pro";
    UIAlertAction *goproAction = [UIAlertAction
                                  actionWithTitle:NSLocalizedString(@"go_pro_btn", @"Ok action")
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction *action)
                                  {
                                      GoProViewController *gopro = (GoProViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"gopro"];
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          gopro.modalPresentationStyle = UIModalPresentationFullScreen;
                                          [self presentViewController:gopro animated:YES completion:nil];
                                      });
                                  }];
    
    
    [alertController addAction:goproAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
    
}

//Swapnil NEW_6
#pragma mark CLOUD SYNC METHODS


//Save rowID, tableName, and type in phones Sync table
- (void)writeToSyncTableWithRowID: (NSNumber *)rowID tableName: (NSString *)tableName andType: (NSString *)type andOS:(NSString *)originalSource{

    NSManagedObjectContext *context = [[CoreDataController sharedInstance] newManagedObjectContext];
    Sync_Table *syncData = [NSEntityDescription insertNewObjectForEntityForName:@"Sync_Table" inManagedObjectContext:context];
    NSError *err;
    syncData.rowID = rowID;
    syncData.tableName = tableName;
    syncData.type = type;
    syncData.processing = @0;
    syncData.originalSource = originalSource;
    
    if([context hasChanges]){
        
        BOOL saved = [context save:&err];
        if (!saved) {
            // do some real error handling
            //CLSLog(@“Could not save Data due to %@“, error);
        }
        [[CoreDataController sharedInstance] saveMasterContext];
        //[self checkNetworkForCloudStorage];
        //Upload data from common methods
        commonMethods *common = [[commonMethods alloc] init];
        [common checkNetworkForCloudStorage:@"isTrip"];
    }
}


- (void)checkNetworkForCloudStorage{
    
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    
    if(networkStatus == NotReachable){
        
       [CheckReachability.sharedManager startNetworkMonitoring];
    } else {
        
        [self performSelectorInBackground:@selector(fetchDataFromSyncTable) withObject:nil];
    }
}

//Loop through the Sync table, fetch table name, type (add, edit, del) and rowID of record
- (void)fetchDataFromSyncTable{

    NSManagedObjectContext *context = [[CoreDataController sharedInstance] backgroundManagedObjectContext];
    NSError *err;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Sync_Table"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"tableName == 'TRIP' OR tableName == 'LOC_TABLE'"];
    [request setPredicate:predicate];
    NSArray *dataArray = [context executeFetchRequest:request error:&err];
    
    for(Sync_Table *syncData in dataArray){
        
        NSString *type = syncData.type;
        //NSInteger rowID = [syncData.rowID integerValue];
        if(syncData.rowID == nil){

            NSError *err;
            if(syncData != nil){

                [context deleteObject:syncData];
            }

            if ([context hasChanges])
            {
                BOOL saved = [context save:&err];
                if (!saved) {
                    // do some real error handling
                    //CLSLog(@“Could not save Data due to %@“, error);
                }
                [[CoreDataController sharedInstance] saveBackgroundContext];
                [[CoreDataController sharedInstance] saveMasterContext];
            }
        }else{

            [self setParametersWithType:type andRowID:syncData.rowID andTableName:syncData.tableName];
        }

    }
}

//Loop thr' the specified tableName and get record for specified rowID
- (void)setParametersWithType: (NSString *)type andRowID: (NSNumber *)rowID andTableName: (NSString *)tableName{
;
    NSManagedObjectContext *context = [[CoreDataController sharedInstance] backgroundManagedObjectContext];
    NSError *err;
    if([tableName isEqualToString:@"TRIP"]){
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"T_Trip"];
    NSPredicate *iDPredicate = [NSPredicate predicateWithFormat:@"iD == %d", [rowID intValue]];
    [request setPredicate:iDPredicate];
    
    NSArray *fetchedData = [context executeFetchRequest:request error:&err];
    
    T_Trip *tripData = [fetchedData firstObject];
    
    
    NSFetchRequest *vehRequest = [[NSFetchRequest alloc] initWithEntityName:@"Veh_Table"];
    NSPredicate *vehPredicate = [NSPredicate predicateWithFormat:@"iD == %d", [tripData.vehId intValue]];
    [vehRequest setPredicate:vehPredicate];
    
    NSArray *vehData = [context executeFetchRequest:vehRequest error:&err];
    
    Veh_Table *vehicleData = [vehData firstObject];
    
    commonMethods *common = [[commonMethods alloc] init];
    NSDictionary *epochDictionary = [common getDayMonthYrFromStringDate:tripData.depDate];
    
    
    NSMutableDictionary *parametersDictionary = [[NSMutableDictionary alloc] init];
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    if([def objectForKey:@"UserEmail"] != nil){
         [parametersDictionary setObject:[def objectForKey:@"UserEmail"] forKey:@"email"];
    }else{
         [parametersDictionary setObject:@"" forKey:@"email"];
    }
    [parametersDictionary setObject:@"phone" forKey:@"source"];
    
    if(type != nil){
        [parametersDictionary setObject:type forKey:@"type"];
    } else {
        [parametersDictionary setObject:@"" forKey:@"type"];
    }

    //Added new parameter for friend stuff
    [parametersDictionary setObject:@"self" forKey:@"originalSource"];
    
    if(rowID != nil){
        [parametersDictionary setObject:rowID forKey:@"_id"];
    } else {
        [parametersDictionary setObject:@"" forKey:@"_id"];
    }
    [parametersDictionary setObject:[def objectForKey:@"UserDeviceId"] forKey:@"androidId"];
    
    [parametersDictionary setObject:[epochDictionary valueForKey:@"day"] forKey:@"day"];
    [parametersDictionary setObject:[epochDictionary valueForKey:@"month"] forKey:@"month"];
    [parametersDictionary setObject:[epochDictionary valueForKey:@"year"] forKey:@"year"];
    [parametersDictionary setObject:[epochDictionary valueForKey:@"epochTime"] forKey:@"date"];
    [parametersDictionary setObject:@"3" forKey:@"rec_type"];
    
    
    if(vehicleData.vehid != nil){
        [parametersDictionary setObject:vehicleData.vehid forKey:@"vehid"];
    } else {
        [parametersDictionary setObject:@"" forKey:@"vehid"];
    }
    
    if(tripData.depOdo != nil){
        [parametersDictionary setObject:tripData.depOdo forKey:@"odo"];
    } else {
        [parametersDictionary setObject:@"" forKey:@"odo"];
    }
    
    if(tripData.arrOdo != nil){
        [parametersDictionary setObject:tripData.arrOdo forKey:@"qty"];
    } else {
        [parametersDictionary setObject:@"" forKey:@"qty"];
    }
    
    //Convert dep time to dep hour and dep min
    NSDictionary *depDT = [common getDayMonthYrFromStringDate:tripData.depDate];
    
    if([depDT valueForKey:@"hours"] != nil){
        [parametersDictionary setObject:[depDT valueForKey:@"hours"] forKey:@"pfill"];
    } else {
        [parametersDictionary setObject:@"" forKey:@"pfill"];
    }
    
    if([depDT valueForKey:@"minutes"] != nil){
        [parametersDictionary setObject:[depDT valueForKey:@"minutes"] forKey:@"mfill"];
    } else {
        [parametersDictionary setObject:@"" forKey:@"mfill"];
    }
    
    if(tripData.taxDedn != nil){
        [parametersDictionary setObject:tripData.taxDedn forKey:@"cost"];
    } else {
        [parametersDictionary setObject:@"" forKey:@"cost"];
    }
    
    if(tripData.parkingAmt != nil){
        [parametersDictionary setObject:tripData.parkingAmt forKey:@"dist"];
    } else {
        [parametersDictionary setObject:@"" forKey:@"dist"];
    }

    if(tripData.arrDate != nil){
        
        //Convert arr date/time in epoch
        NSDictionary *epochArrival = [common getDayMonthYrFromStringDate:tripData.arrDate];
        [parametersDictionary setObject:[epochArrival valueForKey:@"epochTime"] forKey:@"cons"];
        
    } else {
        [parametersDictionary setObject:@"" forKey:@"cons"];
    }
    //BUG_157 NIKHIL keyName octane changed to ocatne
    if(tripData.tollAmt != nil){
        [parametersDictionary setObject:tripData.tollAmt forKey:@"octane"];
    } else {
        [parametersDictionary setObject:@"" forKey:@"octane"];
    }
    
    if(tripData.depLocn != nil){
        [parametersDictionary setObject:tripData.depLocn forKey:@"fuelBrand"];
    } else {
        [parametersDictionary setObject:@"" forKey:@"fuelBrand"];
    }
    
    if(tripData.arrLocn != nil){
        [parametersDictionary setObject:tripData.arrLocn forKey:@"fillStation"];
    } else {
        [parametersDictionary setObject:@"" forKey:@"fillStation"];
    }
    
    if(tripData.notes != nil){
        [parametersDictionary setObject:tripData.notes forKey:@"notes"];
    } else {
        [parametersDictionary setObject:@"" forKey:@"notes"];
    }
    
    if(tripData.tripType != nil){
        [parametersDictionary setObject:tripData.tripType forKey:@"serviceType"];
    } else {
        [parametersDictionary setObject:@"" forKey:@"serviceType"];
    }
    
        if(tripData.depLatitude != nil){
            [parametersDictionary setObject:tripData.depLatitude forKey:@"depLat"];
        } else {
            [parametersDictionary setObject:@0 forKey:@"depLat"];
        }
        
        if(tripData.depLongitude != nil){
            [parametersDictionary setObject:tripData.depLongitude forKey:@"depLong"];
        } else {
            [parametersDictionary setObject:@0 forKey:@"depLong"];
        }
        
        if(tripData.arrLatitude != nil){
            [parametersDictionary setObject:tripData.arrLatitude forKey:@"arrLat"];
        } else {
            [parametersDictionary setObject:@0 forKey:@"arrLat"];
        }
        
        if(tripData.arrLongitude != nil){
            [parametersDictionary setObject:tripData.arrLongitude forKey:@"arrLong"];
        } else {
            [parametersDictionary setObject:@0 forKey:@"arrLong"];
        }
        
    //NSLog(@"Log params dict : %@", parametersDictionary);
    
    NSData *postData = [NSJSONSerialization dataWithJSONObject:parametersDictionary options:NSJSONWritingPrettyPrinted error:&err];
    [def setBool:YES forKey:@"updateTimeStamp"];
    //Pass paramters dictionary and URL of script to get response
    [common saveToCloud:postData urlString:kLogDataScript success:^(NSDictionary *responseDict) {
        //NSLog(@"responseDict LOG : %@", responseDict);
        
        if([[responseDict objectForKey:@"message"] isEqualToString:@"Success"]){
            
            [common clearPhoneSyncTableWithID:rowID tableName:tableName andType:type];
        }
    } failure:^(NSError *error) {
      //  NSLog(@"%@", error.localizedDescription);
    }];
        
    } else if ([tableName isEqualToString:@"LOC_TABLE"]){
        
        NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
        NSError *locErr;
        NSFetchRequest *locRequest = [[NSFetchRequest alloc] initWithEntityName:@"Loc_Table"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"iD == %d", [rowID intValue]];
        [locRequest setPredicate:predicate];
        
        NSArray *locArray = [context executeFetchRequest:locRequest error:&locErr];
        
        Loc_Table *locationData = [locArray firstObject];
        
        NSMutableDictionary *parametersDictionary = [[NSMutableDictionary alloc] init];
        
        if([def objectForKey:@"UserDeviceId"] != nil){
            [parametersDictionary setObject:[def objectForKey:@"UserDeviceId"] forKey:@"androidId"];
        } else {
            [parametersDictionary setObject:@"" forKey:@"androidId"];
        }
        
        if([def objectForKey:@"UserEmail"] != nil){
            [parametersDictionary setObject:[def objectForKey:@"UserEmail"] forKey:@"email"];
        } else {
            [parametersDictionary setObject:@"" forKey:@"email"];
        }
        
        if(type != nil){
            [parametersDictionary setObject:type forKey:@"type"];
        } else {
            [parametersDictionary setObject:@"" forKey:@"type"];
        }
        
        if(rowID != nil){
            [parametersDictionary setObject:rowID forKey:@"_id"];
        } else {
            [parametersDictionary setObject:@"" forKey:@"_id"];
        }
        
        if([locationData.lat floatValue] != 0.0){
            [parametersDictionary setObject:locationData.lat forKey:@"lat"];
        } else {
            [parametersDictionary setObject:@"" forKey:@"lat"];
        }
        
        if([locationData.longitude floatValue] != 0.0){
            [parametersDictionary setObject:locationData.longitude forKey:@"long"];
        } else {
            [parametersDictionary setObject:@"" forKey:@"long"];
        }
        
        if(locationData.address != nil){
            [parametersDictionary setObject:locationData.address forKey:@"address"];
        } else {
            [parametersDictionary setObject:@"" forKey:@"address"];
        }
        
        if(locationData.brand != nil){
            [parametersDictionary setObject:locationData.brand forKey:@"brand"];
        } else {
            [parametersDictionary setObject:@"" forKey:@"brand"];
        }
        
       // NSLog(@"Log params dict : %@", parametersDictionary);
        
        NSError *error;
        NSData *postData = [NSJSONSerialization dataWithJSONObject:parametersDictionary options:NSJSONWritingPrettyPrinted error:&error];
        [def setBool:YES forKey:@"updateTimeStamp"];
        commonMethods *common = [[commonMethods alloc] init];
        //Pass paramters dictionary and URL of script to get response
        [common saveToCloud:postData urlString:kLocationScript success:^(NSDictionary *responseDict) {
           // NSLog(@"responseDict LOG : %@", responseDict);
            
            if([[responseDict objectForKey:@"message"] isEqualToString:@"Success"]){
                
                [common clearPhoneSyncTableWithID:rowID tableName:tableName andType:type];
            }
        } failure:^(NSError *error) {
  //          NSLog(@"%@", error.localizedDescription);
        }];
    }
}


- (IBAction)settingsPressed:(UIButton *)sender {
    
    //NSLog(@"Settings Clicked");
    CustomiseTripViewController *customVC = [self.storyboard instantiateViewControllerWithIdentifier:@"customTrip"];
    customVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController pushViewController:customVC animated:YES];
    
}

#pragma mark CreatePageVC
- (void)createPageVC{
    
    if(![@"1" isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"tripLaunch"]]){
        
        [[NSUserDefaults standardUserDefaults] setValue:@"1" forKey:@"tripLaunch"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        navigationOverlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
        navigationOverlay.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.65];
        
        [self.navigationController.view addSubview:navigationOverlay];
        
        
        self.pageTitles = @[@"To input departure and arrival odometer values, enable the fields from here."];
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
        self.pageViewController.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y+40, self.view.frame.size.width, self.view.frame.size.height + 48);
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



@end
