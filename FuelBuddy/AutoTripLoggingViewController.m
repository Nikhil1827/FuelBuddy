//
//  AutoTripLoggingViewController.m
//  FuelBuddy
//
//  Created by Nikhil on 29/10/18.
//  Copyright © 2018 Oraganization. All rights reserved.
//

#import "AutoTripLoggingViewController.h"
#import "AppDelegate.h"
#import "GoProViewController.h"
#import "TaxDeductionViewController.h"
#import "T_Trip.h"
#import "Services_Table.h"
#import <Crashlytics/Crashlytics.h>

@interface AutoTripLoggingViewController (){
    
    NSString *seltripType;
    NSUInteger tripCount;
}

@property int selPickerRow;

@end

@implementation AutoTripLoggingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.barTintColor = [self colorFromHexString:@"#0098AB"];
    self.navigationController.navigationBar.tintColor =[UIColor whiteColor];
    self.navigationController.navigationBar.topItem.title = NSLocalizedString(@"auto_drive_detect_menu",@"Auto Trip Logging");
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor] , NSFontAttributeName: [UIFont fontWithName:@"Helvetica-Light" size:18.0] }];
    
    self.mainView.backgroundColor = [self colorFromHexString:@"#2c2c2c"];
    UIImage *buttonImage = [[UIImage imageNamed:@"nav_back"] resizableImageWithCapInsets:UIEdgeInsetsMake(20,10,10,10)];
    UIButton *Button = [UIButton buttonWithType:UIButtonTypeCustom];
    [Button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    Button.frame = CGRectMake(0.0, 10.0, buttonImage.size.width+4,buttonImage.size.height+4);
    UIBarButtonItem *BarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:Button];
    [Button addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setLeftBarButtonItem:BarButtonItem];
   
    self.AutoTripSwitchLabel.text = NSLocalizedString(@"auto_drive_detection",@"Automatic trip logging");
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    if([def boolForKey:@"autoTripSwitchOn"]){
        
        self.autoSwitch.on = YES;
    }else{
        
        self.autoSwitch.on = NO;
    }
    
    if([def boolForKey:@"doNotDetectTripOnWeekEnd"]){
        
        self.weekEndButtonOutLet.userInteractionEnabled = NO;
        [self.weekEndButtonOutLet setImage:[UIImage imageNamed:@"dowpdown_grey"] forState:UIControlStateSelected];
        self.weekEnds.textColor = [UIColor grayColor];
        self.weekEndsTripType.textColor = [UIColor grayColor];
        
    }else{
        
        self.weekEndButtonOutLet.userInteractionEnabled = YES;
        [self.weekEndButtonOutLet setImage:[UIImage imageNamed:@"dowpdown_white"] forState:UIControlStateSelected];
        self.weekEnds.textColor = [UIColor whiteColor];
        self.weekEndsTripType.textColor = [UIColor whiteColor];
    }
    
    NSMutableAttributedString *termsOfService = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"t_and_c",@"I agree to Simply Auto's Terms of Service and Privacy Policy.")];

    [termsOfService addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range: [[termsOfService string] rangeOfString:NSLocalizedString(@"t_and_c",@"I agree to Simply Auto's Terms of Service and Privacy Policy.")]];

    [termsOfService addAttribute:NSLinkAttributeName
                           value:@"http://www.simplyauto.app/Terms2.html"
                           range:[[termsOfService string] rangeOfString:NSLocalizedString(@"pattern1",@"Terms of Service")]];

    [termsOfService addAttribute:NSLinkAttributeName
                           value:@"http://www.simplyauto.app/policy.html"
                           range:[[termsOfService string] rangeOfString:NSLocalizedString(@"pattern2",@"Privacy Policy")]];
    
    NSDictionary *linkAttributes = @{NSForegroundColorAttributeName: [self colorFromHexString:@"#FFCA1D"],
                                     NSUnderlineColorAttributeName: [self colorFromHexString:@"#FFCA1D"],
                                     NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
   
    self.termsText.delegate = self;
    self.termsText.linkTextAttributes = linkAttributes;
    self.termsText.attributedText = termsOfService;
    self.termsText.backgroundColor = [UIColor clearColor];
   
    self.checkYes.selected = YES;
    [self.checkYes setImage:[UIImage imageNamed:@"check"] forState:UIControlStateSelected];
    
    self.doNotYes.selected = [def boolForKey:@"doNotDetectTripOnWeekEnd"];
    
    if(self.doNotYes.selected){
        
        [self.doNotYes setImage:[UIImage imageNamed:@"checkmark01"] forState:UIControlStateNormal];
    }else{
       
        [self.doNotYes setImage:[UIImage imageNamed:@"uncheck"] forState:UIControlStateNormal];
    }

    //Set Trip Type from database
    [self fetchTripTypes];
    
    self.defaultTripType.text = NSLocalizedString(@"def_trip_type",@"Default trip type");
    self.weekDays.text = NSLocalizedString(@"weekdays",@"Weekdays");
    self.weekEnds.text = NSLocalizedString(@"weekend",@"Weekend");

    self.doNotLabel.text = NSLocalizedString(@"do_not_track",@"Do not detect trips on weekends");
    [self.viewEditButtonLabel setTitle:NSLocalizedString(@"view_edit_tax_rates",@"View/Edit tax rates") forState:UIControlStateNormal];
    
    NSString *yourString = @"UPGRADE";
    NSMutableAttributedString *yourAttributedString = [[NSMutableAttributedString alloc] initWithString:yourString];
    NSString *boldString = @"UPGRADE";
    NSRange boldRange = [yourString rangeOfString:boldString];
    [yourAttributedString addAttribute: NSFontAttributeName value:[UIFont boldSystemFontOfSize:11] range:boldRange];
    [yourAttributedString addAttribute: NSForegroundColorAttributeName value:[UIColor blackColor] range:boldRange];
    [self.upgradeButtonLabel setAttributedTitle:yourAttributedString forState:UIControlStateNormal];
  
    self.upgradeButtonLabel.layer.masksToBounds=YES;
    self.upgradeButtonLabel.layer.cornerRadius = 4;
   
    NSString *yourString2 = NSLocalizedString(@"go_pro_for_auto_logging",@"for unlimited auto logging of trips");
    NSMutableAttributedString *yourAttributedString2 = [[NSMutableAttributedString alloc] initWithString:yourString2];
    NSString *boldString2 = NSLocalizedString(@"go_pro_for_auto_logging",@"for unlimited auto logging of trips");
    NSRange boldRange2 = [yourString2 rangeOfString:boldString2];
    [yourAttributedString2 addAttribute: NSFontAttributeName value:[UIFont italicSystemFontOfSize:10] range:boldRange2];
    [self.unlimitedLabel setAttributedText:yourAttributedString2];

    self.FreetripsLabel.text = NSLocalizedString(@"free_trips_remaining",@"Free trips remaining this month:");
    
    [self fetchTripCountForThisMonth];
    
    if(tripCount<10){
        
        NSUInteger remainingTripCount = 10-tripCount;
        self.freeTripsCountLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)remainingTripCount];
    }else{
        NSUInteger remainingTripCount = 0;
        self.freeTripsCountLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)remainingTripCount];
    }
    
    BOOL proUser = [[NSUserDefaults standardUserDefaults] boolForKey:@"isSubscribed"];
    
    if(proUser){
        
        self.FreetripsLabel.hidden = YES;
        self.freeTripsCountLabel.hidden = YES;
        self.upgradeButtonLabel.hidden = YES;
        self.upgradeButtonLabel.userInteractionEnabled = NO;
        self.unlimitedLabel.hidden = YES;
    }else{
        
        self.FreetripsLabel.hidden = NO;
        self.freeTripsCountLabel.hidden = NO;
        self.upgradeButtonLabel.hidden = NO;
        self.upgradeButtonLabel.userInteractionEnabled = YES;
        self.unlimitedLabel.hidden = NO;
    }
    
}

-(void)viewDidAppear:(BOOL)animated{
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    //Set Trip Type from database
    [self fetchTripTypes];
    
    if(self.tripTypeArray.count>0){
        
        if([def objectForKey:@"weekDaysTripType"]){
            self.tripType.text = [def objectForKey:@"weekDaysTripType"];
        }else{
            self.tripType.text = @"Business";
            [def setObject:@"Business" forKey:@"weekDaysTripType"];
        }
        if([def objectForKey:@"weekEndsTripType"]){
            
            self.weekEndsTripType.text = [def objectForKey:@"weekEndsTripType"];
        }else{
            self.weekEndsTripType.text = @"Business";
            [def setObject:@"Business" forKey:@"weekEndsTripType"];
        }
    }else{
        
        self.tripType.text = @"Personal";
        [def setObject:@"Personal" forKey:@"weekDaysTripType"];
        self.weekEndsTripType.text = @"Personal";
        [def setObject:@"Personal" forKey:@"weekEndsTripType"];
    }
    
    
}

-(void)fetchTripTypes{
    
    self.tripTypeArray = [[NSMutableArray alloc] init];
    NSManagedObjectContext *contex = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSFetchRequest *request=[[NSFetchRequest alloc] initWithEntityName:@"Services_Table"];
    NSError *err;
    NSArray *data=[contex executeFetchRequest:request error:&err];
    
    for(Services_Table *tripType in data)
    {
        
        if([tripType.type  intValue] == 3){
            
           [self.tripTypeArray addObject:tripType.serviceName];
        }
        
    }
}

-(void)fetchTripCountForThisMonth{
    
    NSMutableArray *datavalue= [[NSMutableArray alloc]init];
    NSManagedObjectContext *contex = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSFetchRequest *request=[[NSFetchRequest alloc] initWithEntityName:@"T_Trip"];
    NSError *err;
    NSArray *data=[contex executeFetchRequest:request error:&err];
    
    NSDateFormatter *formater=[[NSDateFormatter alloc] init];
    [formater setDateFormat:@"MM"];
    NSDateFormatter *formater1=[[NSDateFormatter alloc] init];
    [formater1 setDateFormat:@"yyyy"];
    NSString *currentmonth = [formater stringFromDate:[NSDate date]];
    NSString *currentyear = [formater1 stringFromDate:[NSDate date]];
    
    for(T_Trip *trip in data)
    {
        if([[formater stringFromDate:trip.depDate] isEqualToString:currentmonth] && [[formater1 stringFromDate:trip.depDate] isEqualToString:currentyear])
        {
            [datavalue addObject: trip];
        }
    }
    
    tripCount = datavalue.count;
    
}


#pragma mark Textview METHODS
- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    //    if ([[URL scheme] isEqualToString:@"username"]) {
    //        NSString *username = [URL host];
    //        // do something with this username
    //        // ...
    //        return NO;
    //    }
    //NSLog(@"delegate called for links");
    return YES; // let the system open this URL
}

- (IBAction)backButtonPressed: (id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

-(UIColor *)colorFromHexString:(NSString *)hexString
{
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

- (void)showTermAlert: (NSString *)title message:(NSString *)message{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"OK") style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
    
}


- (IBAction)autoSwitchClicked:(UISwitch *)sender {
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    self.shareModel = [LocationManager sharedManager];
    
    if(self.autoSwitch.on){
        
        [def setBool:YES forKey:@"autoTripSwitchOn"];
        //Nikhil 29Nov2018 fabric
        NSString *appInstallDate = [def objectForKey:@"installDate"];
        NSInteger autoTripStartCount = [def integerForKey:@"autoTripStartCount"] + 1;
        [def setInteger:autoTripStartCount forKey:@"autoTripStartCount"];
        NSString *tripCnt = [NSString stringWithFormat:@"%ld", (long)autoTripStartCount];
        
        NSString *startAutoTripEvent = [NSString stringWithFormat:@"%@; %@", appInstallDate, tripCnt];
        [Answers logCustomEventWithName:@"Started Auto Trip"
                       customAttributes:@{@"Started Trips": startAutoTripEvent}];
        
        [def setBool:YES forKey:@"fromAppDelegate"];
        [self.shareModel startMonitoringLocation];
        if(![def boolForKey:@"firstTimeSwitch"]){
            
            [self showTermAlert:NSLocalizedString(@"first_auto_trip_check_title", @"Auto trip enabled") message:NSLocalizedString(@"first_auto_trip_check_msg", @"Auto trip will now automatically detect your drives and save them as trips.This feature might need a couple of trips to start calculating accurately.")];
            [def setBool:YES forKey:@"firstTimeSwitch"];
        }
        
    }else{
        
        [def setBool:NO forKey:@"autoTripSwitchOn"];
        
        //Nikhil 29Nov2018 fabric
        NSString *appInstallDate = [def objectForKey:@"installDate"];
        NSInteger autoTripStopCount = [def integerForKey:@"autoTripStopCount"] + 1;
        [def setInteger:autoTripStopCount forKey:@"autoTripStopCount"];
        NSString *tripCnt = [NSString stringWithFormat:@"%ld", (long)autoTripStopCount];
        
        NSString *stopAutoTripEvent = [NSString stringWithFormat:@"%@; %@", appInstallDate, tripCnt];
        [Answers logCustomEventWithName:@"Stopped Auto Trip"
                       customAttributes:@{@"Stopped Trips": stopAutoTripEvent}];
    }
    
    
    
}

- (IBAction)checkedButton:(UIButton *)sender {
    
    if(sender.selected == YES){
        
        sender.selected=NO;
        self.autoSwitch.userInteractionEnabled = NO; 
        [self showTermAlert:@"" message:NSLocalizedString(@"accept_t_and_c",@"Please accept the Terms of Service")];
        
    }else{
        
        sender.selected=YES;
        self.autoSwitch.userInteractionEnabled = YES;
    }
    [self.checkYes setImage:[UIImage imageNamed:@"check"] forState:UIControlStateSelected];
    [self.checkYes setImage:[UIImage imageNamed:@"uncheck"] forState:UIControlStateNormal];
}

-(void)tripTypePicker:(NSString *)tripType{
    
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
    seltripType = tripType;
    
    //NIKHIL BUG_131 //added below line
    NSUserDefaults *setRowValue = [NSUserDefaults standardUserDefaults];
    int picRowId = (int)[setRowValue integerForKey:@"rowValue"];
    [_picker selectRow:picRowId inComponent:0 animated:NO];
    
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
    [_setbutton setBackgroundColor:[UIColor lightGrayColor]];
    [_setbutton setTitle:NSLocalizedString(@"set", @"Set") forState:UIControlStateNormal];
    [_setbutton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_setbutton addTarget:self action:@selector(donelabel) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_setbutton];
}

-(void)donelabel{
    
    [_setbutton removeFromSuperview];
    [_picker removeFromSuperview];
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    
    if(_tripTypeArray.count > 0){
        
        if([seltripType isEqualToString:@"weekDays"]){
            
            self.tripType.text = [self.tripTypeArray objectAtIndex:[self.picker selectedRowInComponent:0]];
            [def setObject:[self.tripTypeArray objectAtIndex:[self.picker selectedRowInComponent:0]] forKey:@"weekDaysTripType"];
            
        }else if([seltripType isEqualToString:@"weekEnds"]){
            
            self.weekEndsTripType.text = [self.tripTypeArray objectAtIndex:[self.picker selectedRowInComponent:0]];
            [def setObject:[self.tripTypeArray objectAtIndex:[self.picker selectedRowInComponent:0]] forKey:@"weekEndsTripType"];
        }
    }else{
        
        self.tripType.text = @"Personal";
        [def setObject:@"Personal" forKey:@"weekDaysTripType"];
        self.weekEndsTripType.text = @"Personal";
        [def setObject:@"Personal" forKey:@"weekEndsTripType"];
        
    }
    
    
    
}

#pragma mark pickerView Delegate methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if(self.tripTypeArray.count>0){
        
        return self.tripTypeArray.count;
    }else{
        return 1;
    }
    
}


- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *tripType;
    if(self.tripTypeArray.count>0){
        
        tripType = [self.tripTypeArray objectAtIndex:row];
    }else{
        tripType = @"Personal";
    }
    
    
    return tripType;
    
}


//NIKHIL BUG_131 added below method
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    _selPickerRow = (int)[pickerView selectedRowInComponent:0];
    NSUserDefaults *setRowValue = [NSUserDefaults standardUserDefaults];
    [setRowValue setInteger:_selPickerRow forKey:@"rowValue"];
}



- (IBAction)tripTypeClicked:(UIButton *)sender {
    
    [self tripTypePicker:@"weekDays"];
}

- (IBAction)weenEndsTripTypeClicked:(UIButton *)sender {
    
    [self tripTypePicker:@"weekEnds"];
}

- (IBAction)doNotDetectClicked:(UIButton *)sender {
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    
    if(sender.selected == YES){
        
        sender.selected=NO;
        self.weekEndButtonOutLet.userInteractionEnabled = YES;
        [self.weekEndButtonOutLet setImage:[UIImage imageNamed:@"dowpdown_white"] forState:UIControlStateSelected];
        self.weekEnds.textColor = [UIColor whiteColor];
        self.weekEndsTripType.textColor = [UIColor whiteColor];
        [def setBool:NO forKey:@"doNotDetectTripOnWeekEnd"];
        
    }else{
        
        sender.selected=YES;
        self.weekEndButtonOutLet.userInteractionEnabled = NO;
        [self.weekEndButtonOutLet setImage:[UIImage imageNamed:@"dowpdown_grey"] forState:UIControlStateSelected];
        self.weekEnds.textColor = [UIColor grayColor];
        self.weekEndsTripType.textColor = [UIColor grayColor];
        [def setBool:YES forKey:@"doNotDetectTripOnWeekEnd"];
    }
    [self.doNotYes setImage:[UIImage imageNamed:@"checkmark01"] forState:UIControlStateSelected];
    [self.doNotYes setImage:[UIImage imageNamed:@"uncheck"] forState:UIControlStateNormal];
}

- (IBAction)viewEditClicked:(UIButton *)sender {
    
    TaxDeductionViewController *taxScreen =(TaxDeductionViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"taxDeduction"];
    taxScreen.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:taxScreen animated:YES completion:nil];
    
}

- (IBAction)upgradeButtonClicked:(UIButton *)sender {
    
    GoProViewController *gopro = (GoProViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"gopro"];
    gopro.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:gopro animated:YES completion:nil];
    
}


@end
