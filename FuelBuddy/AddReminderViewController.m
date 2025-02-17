//
//  AddReminderViewController.m
//  FuelBuddy
//
//  Created by surabhi on 10/05/16.
//  Copyright © 2016 Oraganization. All rights reserved.
//

#import "AddReminderViewController.h"
#import "Veh_Table.h"
#import "AppDelegate.h"
#import "Services_Table.h"
#import "ACPReminder.h"
#import "JRNLocalNotificationCenter.h"
#import "Reachability.h"
#import "Sync_Table.h"
#import "commonMethods.h"
#import "WebServiceURL's.h"
#import "CheckReachability.h"

@interface AddReminderViewController ()

@property UIDatePicker *datePicker;
@property NSNumber *veh_id;

@end

@implementation AddReminderViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //NSLog(@"serviceDetails = %@", self.servicedetails);
    //NSLog(@"maxOdo = %@", [self.servicedetails objectForKey:@"maxodo"]);
    if ([[self.servicedetails objectForKey:@"maxodo"]floatValue]==0) {

        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:@"Missing Initial Record" message:@"Please add either a Fillup/Service/Expense record to continue"                                          preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"ok", @"OK action")
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
            [self backbuttonclick];
        }];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];

    }

    [self setupView];

    checkedstatus = @"odo";
    _vehimage.contentMode = UIViewContentModeScaleAspectFill;
    _vehimage.layer.borderWidth=0;
    _vehimage.layer.masksToBounds=YES;
    _vehimage.layer.cornerRadius = self.vehimage.frame.size.width/2;
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
    [self fetchdata];

    self.servicename.text = self.namestring;
    self.odotext.delegate=self;
    self.daystext.delegate=self;
    self.lastodoText.delegate=self;
    self.dateText.delegate=self;
    //[self.odocheck setImage:[UIImage imageNamed:@"check1"] forState:UIControlStateNormal];
    
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"save", @"Save") style:UIBarButtonItemStylePlain target:self action:@selector(lastServiceCheckAlert)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    
    //    NSString *reminder_due_date_unit_array_1 = @"Months";
    //    NSString *reminder_due_date_unit_array_2 = @"Years";

    
    self.durationarray = [[NSMutableArray alloc]initWithObjects:
                          NSLocalizedString(@"days", @"Days"),
                          NSLocalizedString(@"reminder_due_date_unit_array_1", @"Months"),
                          NSLocalizedString(@"reminder_due_date_unit_array_2", @"Years"), nil];
    [self.durationButton addTarget:self action:@selector(setdurationpicker) forControlEvents:UIControlEventTouchUpInside];
    
    if([[self.servicedetails objectForKey:@"duedays"]longValue]!=0 && [[self.servicedetails objectForKey:@"duemiles"]floatValue]!=0) {
        
        self.daystext.text = [[self.servicedetails objectForKey:@"duedays"] stringValue];
        self.odotext.text = [[self.servicedetails objectForKey:@"duemiles"] stringValue];
        if(!_recurring){

            if([[self.servicedetails objectForKey:@"lastodo"]longValue]!=0){

                double totalOdo = [[self.servicedetails objectForKey:@"duemiles"] doubleValue] + [[self.servicedetails objectForKey:@"lastodo"] doubleValue];
                self.odotext.text = [NSString stringWithFormat:@"%.0f",totalOdo];
            }
//            else{
//                self.odotext.text = [[self.servicedetails objectForKey:@"duemiles"] stringValue];
//            }

            if([[self.servicedetails objectForKey:@"lastdate"] length]!=0){

                NSString *lastDate = [self.servicedetails objectForKey:@"lastdate"];
                NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
                dateformatter.dateFormat = @"dd-MMM-yyyy";
                [dateformatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT+0:00"]];

                if(lastDate.length==11){

                    NSString *dateString = [self.servicedetails objectForKey:@"lastdate"];
                    NSDate *lastDate = [dateformatter dateFromString:dateString];
                    NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
                    dayComponent.day = [[self.servicedetails objectForKey:@"duedays"] longValue];

                    NSCalendar *theCalendar = [NSCalendar currentCalendar];
                    NSDate *nextDate = [theCalendar dateByAddingComponents:dayComponent toDate:lastDate options:0];

                    NSLog(@"nextDate: %@ ...", nextDate);
                    NSString *addedDate = [dateformatter stringFromDate:nextDate];

                    self.daystext.text = addedDate;

                }
            }else{


            }

        }
        [self.comesfirstButton setImage:[UIImage imageNamed:@"check"]  forState:UIControlStateNormal];
        self.odotext.enabled = YES;
        self.daystext.enabled = YES;
        self.durationButton.enabled = YES;
        
        self.odotext.textColor = [UIColor whiteColor];
        self.daystext.textColor = [UIColor whiteColor];
        self.daysButton.tintColor = [UIColor whiteColor];
        [self.odocheck setImage:[UIImage imageNamed:@"uncheck"] forState:UIControlStateNormal];
        [self.daysButton setImage:[UIImage imageNamed:@"uncheck"] forState:UIControlStateNormal];
    }

    else if([[self.servicedetails objectForKey:@"duemiles"]floatValue]!=0) {
        
        self.odotext.text = [[self.servicedetails objectForKey:@"duemiles"] stringValue];
        self.odocheck.tintColor = [UIColor whiteColor];
        //  UIImage *image = [[UIImage imageNamed:@"check1"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        
        [self.odocheck setImage:[UIImage imageNamed:@"check"]  forState:UIControlStateNormal];
        self.odotext.enabled = YES;
        self.daystext.enabled = NO;
        self.durationButton.enabled = NO;
        self.odotext.textColor = [UIColor whiteColor];
        self.daystext.textColor = [UIColor lightGrayColor];

    }
    
    else if([[self.servicedetails objectForKey:@"duedays"]longValue]!=0) {
        
        self.daystext.text = [[self.servicedetails objectForKey:@"duedays"] stringValue];
        // UIImage *image = [[UIImage imageNamed:@"check1"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        if(!_recurring){

            NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
            dateformatter.dateFormat = @"dd-MMM-yyyy";
            [dateformatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT+0:00"]];
            NSString *dateString = [self.servicedetails objectForKey:@"lastdate"];
            NSDate *lastDate = [dateformatter dateFromString:dateString];
            NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
            dayComponent.day = [[self.servicedetails objectForKey:@"duedays"] longValue];

            NSCalendar *theCalendar = [NSCalendar currentCalendar];
            NSDate *nextDate = [theCalendar dateByAddingComponents:dayComponent toDate:lastDate options:0];

            NSLog(@"nextDate: %@ ...", nextDate);
            NSString *addedDate = [dateformatter stringFromDate:nextDate];

            self.daystext.text = addedDate;

        }
        [self.daysButton setImage:[UIImage imageNamed:@"check"]  forState:UIControlStateNormal];
        self.daysButton.tintColor = [UIColor whiteColor];
        [self.odocheck setImage:[UIImage imageNamed:@"uncheck"] forState:UIControlStateNormal];

        self.odotext.enabled = NO;
        self.daystext.enabled = YES;
        self.durationButton.enabled = YES;
        self.odotext.textColor = [UIColor lightGrayColor];
        self.daystext.textColor = [UIColor whiteColor];

    }
    else
    {
        [self.noreminderButton setImage:[UIImage imageNamed:@"check"]  forState:UIControlStateNormal];

        if(!_recurring){

            //Get max odo
            commonMethods *common = [[commonMethods alloc] init];

            double maxOdo = [common getMaxNoTripOdoForVehicle: _veh_id];
            self.odotext.text = [NSString stringWithFormat:@"%.0f",maxOdo];

            NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
            dateformatter.dateFormat = @"dd-MMM-yyyy";
            [dateformatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT+0:00"]];
            NSDate *date = [[NSDate alloc] init];
            NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
            dayComponent.year = 1;

            NSCalendar *theCalendar = [NSCalendar currentCalendar];
            NSDate *nextYearDate = [theCalendar dateByAddingComponents:dayComponent toDate:date options:0];

            NSLog(@"nextYearDate: %@ ...", nextYearDate);
            NSString *addedDate = [dateformatter stringFromDate:nextYearDate];

            self.daystext.text = addedDate;

        }

        self.odotext.enabled = NO;
        self.daystext.enabled = NO;
        self.durationButton.enabled = NO;
        self.odotext.textColor = [UIColor lightGrayColor];
        self.daystext.textColor = [UIColor lightGrayColor];

    }
    
    UIImage *buttonImage = [UIImage imageNamed:@"nav_back"];
    
    UIButton *Button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [Button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    
    Button.frame = CGRectMake(0.0, 0.0, buttonImage.size.width,buttonImage.size.height);
    
    UIBarButtonItem *BarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:Button];
    
    [Button addTarget:self action:@selector(backbuttonclick) forControlEvents:UIControlEventTouchUpInside];
    
    [self.navigationItem setLeftBarButtonItem:BarButtonItem];
    self.navigationController.navigationBar.barTintColor = [self colorFromHexString:@"#0098AB"];
    self.title = NSLocalizedString(@"set_reminder", @"Set Reminder");
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor] , NSFontAttributeName: [UIFont fontWithName:@"Helvetica-Light" size:18.0] }];
    
    //NSLog(@"vehicleArray:- %@",self.vehiclearray);
    
    if([[self.servicedetails objectForKey:@"lastodo"]longValue]!=0) {
        
        //NSLog(@"last odo %@",[self.servicedetails objectForKey:@"lastodo"]);
        self.lastodoText.text = [[self.servicedetails objectForKey:@"lastodo"] stringValue];
        if ([[self.servicedetails objectForKey:@"serviceExists"]boolValue] == YES) {

            self.dateText.userInteractionEnabled = NO;
            self.lastodoText.userInteractionEnabled = NO;
        }
        else
        { self.dateText.userInteractionEnabled = YES;
            self.lastodoText.userInteractionEnabled = YES;
        }

    }

    else {
        if([[self.servicedetails objectForKey:@"maxodo"] floatValue]!=0) {
            if ([[self.servicedetails objectForKey:@"serviceExists"]boolValue] == YES) {

                self.dateText.userInteractionEnabled = NO;
                self.lastodoText.userInteractionEnabled = NO;
            }
            else
            { self.dateText.userInteractionEnabled = YES;
                self.lastodoText.userInteractionEnabled = YES;
            }

        }
    }
    
    if([[self.servicedetails objectForKey:@"lastdate"] length]!=0 &&[[self.servicedetails objectForKey:@"lastodo"]floatValue] == 0) {
        // self.dateText.text = [self.servicedetails objectForKey:@"lastdate"] ;
        if ([[self.servicedetails objectForKey:@"serviceExists"]boolValue] == YES) {

            self.dateText.userInteractionEnabled = NO;
            self.lastodoText.userInteractionEnabled = NO;
        }
        else
        { self.dateText.userInteractionEnabled = YES;
            self.lastodoText.userInteractionEnabled = YES;
        }
        
    }
    if ([[self.servicedetails objectForKey:@"lastdate"] length]!=0 && [[self.servicedetails objectForKey:@"lastodo"]floatValue] != 0) {

        NSString *lastDate = [self.servicedetails objectForKey:@"lastdate"];
        if(lastDate.length>0){

            self.dateText.text = [self.servicedetails objectForKey:@"lastdate"];

        }else{

            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT+0:00"]];
            NSDate *eventDate = [NSDate date];
            [dateFormat setDateFormat:@"dd-MMM-yyyy"];

            NSString *dateString = [dateFormat stringFromDate:eventDate];
            self.dateText.text = [NSString stringWithFormat:@"%@",dateString];

        }

        if ([[self.servicedetails objectForKey:@"serviceExists"]boolValue] == YES) {

            self.dateText.userInteractionEnabled = NO;
            self.lastodoText.userInteractionEnabled = NO;
        }
        else
        { self.dateText.userInteractionEnabled = YES;
            self.lastodoText.userInteractionEnabled = YES;
        }
        
    }
    
    UIDatePicker *datePicker = [[UIDatePicker alloc]init];
    [datePicker setDate:[NSDate date]];
    datePicker.timeZone=[NSTimeZone localTimeZone];
    datePicker.datePickerMode = UIDatePickerModeDate;
    [datePicker addTarget:self action:@selector(dateTextField:) forControlEvents:UIControlEventValueChanged];
    [self.dateText setInputView:datePicker];
    
    [self textfieldsetting:self.odotext : @"Odometer" : 1];
    [self textfieldsetting:self.daystext : @"Days" : 2];
    [self textfieldsetting:self.lastodoText : @"Odometer" : 3];
    [self textfieldsetting:self.dateText : @"Date" : 4];

    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    
    // prevents the scroll view from swallowing up the touch event of child buttons
    tapGesture.cancelsTouchesInView = NO;
    
    [self.view1 addGestureRecognizer:tapGesture];
    
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.barStyle = UIBarStyleDefault;
    numberToolbar.backgroundColor =[UIColor whiteColor];
    numberToolbar.items = [NSArray arrayWithObjects:[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad)],
                           nil];
    
    [numberToolbar sizeToFit];
    self.daystext.inputAccessoryView = numberToolbar;
    self.odotext.inputAccessoryView = numberToolbar;
    self.lastodoText.inputAccessoryView = numberToolbar;
    
}

-(void)setupView{

    if(_recurring){

        _desc.text = @"Service Every:";
        _lastserviceLabel.hidden = false;
        _lastodoText.hidden = false;
        _lastodounitLabel.hidden = false;
        _separatorLine.hidden = false;
        _dateText.hidden = false;
        _durationButton.hidden = false;
        _durationDropDownButton.hidden = false;
        _durationArrowButton.hidden = true;
       // [_durationArrowButton setImage:[UIImage imageNamed:@"dowpdown_grey"] forState: UIControlStateNormal];

    }else{

        _desc.text = NSLocalizedString(@"next_one_time_reminder", @"One Time Reminder on:");
        _lastserviceLabel.hidden = true;
        _lastodoText.hidden = true;
        _lastodounitLabel.hidden = true;
        _separatorLine.hidden = true;
        _dateText.hidden = true;
        _durationButton.hidden = true;
        _durationDropDownButton.hidden = true;
        _durationArrowButton.hidden = false;
       // [self.durationArrowButton addTarget:self action:@selector(openDatePicker) forControlEvents:UIControlEventTouchUpInside];

        _datePicker = [[UIDatePicker alloc]init];
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"dd-MMM-yyyy"];
        [format setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT+0:00"]];
        _datePicker.timeZone=[NSTimeZone localTimeZone];
        _datePicker.datePickerMode=UIDatePickerModeDate;
        //self.daystext.text = [format stringFromDate:[NSDate date]];
        NSString *lastDateString = [self.servicedetails objectForKey:@"lastdate"];
        if(lastDateString.length < 11){
            NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
            dateformatter.dateFormat = @"dd-MMM-yyyy";
            [dateformatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT+0:00"]];
            NSDate *date = [[NSDate alloc] init];
            NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
            dayComponent.year = 1;

            NSCalendar *theCalendar = [NSCalendar currentCalendar];
            NSDate *nextYearDate = [theCalendar dateByAddingComponents:dayComponent toDate:date options:0];

            NSLog(@"nextYearDate: %@ ...", nextYearDate);
            //NSString *addedDate = [dateformatter stringFromDate:nextYearDate];
            [_datePicker setDate:nextYearDate];
        }else{

            NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
            dateformatter.dateFormat = @"dd-MMM-yyyy";
            [dateformatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT+0:00"]];
            NSString *dateString = [self.servicedetails objectForKey:@"lastdate"];
            NSDate *lastDate = [dateformatter dateFromString:dateString];
            NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
            dayComponent.day = [[self.servicedetails objectForKey:@"duedays"] longValue];

            NSCalendar *theCalendar = [NSCalendar currentCalendar];
            NSDate *nextDate = [theCalendar dateByAddingComponents:dayComponent toDate:lastDate options:0];
            [_datePicker setDate:nextDate];
        }

        [_datePicker addTarget:self action:@selector(updateTextField:) forControlEvents:UIControlEventValueChanged];

        self.daystext.inputView = _datePicker;

       // [_durationArrowButton setImage:[UIImage imageNamed:@"date"] forState: UIControlStateNormal];
    }

}

-(void)updateTextField:(id)sender
{
    UIDatePicker *picker = (UIDatePicker *)sender;
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"dd-MMM-yyyy"];
    [format setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT+0:00"]];
    self.daystext.text = [NSString stringWithFormat:@"%@",[format stringFromDate:picker.date]];
}

- (IBAction)openDatePicker:(UIButton *)sender {

   // [self.view addSubview:_datePicker];
}

-(void)viewDidAppear:(BOOL)animated{

    NSString *metric = [[NSUserDefaults standardUserDefaults] objectForKey:@"dist_unit"];
    if([metric isEqualToString:NSLocalizedString(@"disp_miles", @"Miles")]){
        self.distanceunitLabel.text = NSLocalizedString(@"mi", @"mi");
        self.lastodounitLabel.text = NSLocalizedString(@"mi", @"mi");
    } else if([metric isEqualToString:NSLocalizedString(@"disp_kilometers", @"Kilometers")]){
        self.distanceunitLabel.text = NSLocalizedString(@"kms", @"Km");
        self.lastodounitLabel.text = NSLocalizedString(@"kms", @"Km");
    }

}

-(void)doneWithNumberPad {
    [self.daystext resignFirstResponder];
    [self.odotext resignFirstResponder];
    [self.lastodoText resignFirstResponder];
}
    
    // method to hide keyboard when user taps on a scrollview
-(void)hideKeyboard
{
        [self.view1 endEditing:YES];
    
}


-(void) dateTextField:(id)sender
{
    UIDatePicker *picker = (UIDatePicker*)self.dateText.inputView;
    [picker setMaximumDate:[NSDate date]];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT+0:00"]];
    NSDate *eventDate = picker.date;
    [dateFormat setDateFormat:@"dd-MMM-yyyy"];
    
    NSString *dateString = [dateFormat stringFromDate:eventDate];
    self.dateText.text = [NSString stringWithFormat:@"%@",dateString];

}


-(void)textfieldsetting: (UITextField *)textfield : (NSString *)textstring : (int)tagvalue
{
    CALayer *border = [CALayer layer];
    CGFloat borderWidth = 1;
    border.borderColor = [UIColor darkGrayColor].CGColor;
    border.frame = CGRectMake(0, textfield.frame.size.height - borderWidth, textfield.frame.size.width, textfield.frame.size.height);
    border.borderWidth = borderWidth;
    [textfield.layer addSublayer:border];
    textfield.layer.masksToBounds = YES;
    
    UIColor *color = [UIColor darkGrayColor];
   
    textfield.attributedPlaceholder = [[NSAttributedString alloc] initWithString:textstring attributes:@{NSForegroundColorAttributeName: color}];
    UILabel *placeholder =[[UILabel alloc]init];
    placeholder.textColor = [UIColor darkGrayColor];
    
    placeholder.font = [UIFont systemFontOfSize:12];
    placeholder.frame = CGRectMake(textfield.frame.origin.x,textfield.frame.origin.y-10,60, 20);
        placeholder.tag = tagvalue;
        placeholder.text = textstring;
        if(textfield.text.length!=0){
            placeholder.hidden = NO;
        }
    else {
        placeholder.hidden = YES;
        }
    [self.view1 addSubview:placeholder];
    
}

-(UIColor *)colorFromHexString:(NSString *)hexString
{
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}


-(void)backbuttonclick {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:YES];
    });
}
#pragma mark - Textfield Delegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    
    if(textField==self.odotext) {
        self.view1.frame = CGRectMake(self.view1.frame.origin.x, self.view1.frame.origin.y -60 , self.view1.frame.size.width, self.view1.frame.size.height);
        self.odotext.placeholder = @"";
        UILabel *label = (UILabel *) [self.view1 viewWithTag:1];
        [self labelanimatetoshow:label];
//        [self.odocheck setImage:[UIImage imageNamed:@"check"]  forState:UIControlStateNormal];
//        [self.daysButton setImage:[UIImage imageNamed:@"uncheck"]  forState:UIControlStateNormal];
//        [self.noreminderButton setImage:[UIImage imageNamed:@"uncheck"]  forState:UIControlStateNormal];
//        [self.comesfirstButton setImage:[UIImage imageNamed:@"uncheck"]  forState:UIControlStateNormal];

    }
    
    if(textField==self.daystext) {
        self.view1.frame = CGRectMake(self.view1.frame.origin.x, self.view1.frame.origin.y -60 , self.view1.frame.size.width, self.view1.frame.size.height);
        self.daystext.placeholder = @"";
        UILabel *label = (UILabel *) [self.view1 viewWithTag:2];
        [self labelanimatetoshow:label];
//        [self.daysButton setImage:[UIImage imageNamed:@"check"]  forState:UIControlStateNormal];
//        [self.odocheck setImage:[UIImage imageNamed:@"uncheck"]  forState:UIControlStateNormal];
//        [self.noreminderButton setImage:[UIImage imageNamed:@"uncheck"]  forState:UIControlStateNormal];
//        [self.comesfirstButton setImage:[UIImage imageNamed:@"uncheck"]  forState:UIControlStateNormal];

    }
    
    if(textField==self.lastodoText) {
        self.lastodoText.placeholder = @"";
        self.view1.frame = CGRectMake(self.view1.frame.origin.x, self.view1.frame.origin.y -120 , self.view1.frame.size.width, self.view1.frame.size.height);
        UILabel *label = (UILabel *) [self.view1 viewWithTag:3];
        [self labelanimatetoshow:label];
    
    }
    
    if(textField==self.dateText) {
        self.view1.frame = CGRectMake(self.view1.frame.origin.x, self.view1.frame.origin.y -120 , self.view1.frame.size.width, self.view1.frame.size.height);
        self.dateText.placeholder = @"";
        UILabel *label = (UILabel *) [self.view1 viewWithTag:4];
        [self labelanimatetoshow:label];
    }


}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    
    
    self.view1.frame = CGRectMake(self.view1.frame.origin.x, 0 , self.view1.frame.size.width, self.view1.frame.size.height);
    if(textField==self.odotext) {
        textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"odometer", @"Odometer") attributes:@{NSForegroundColorAttributeName: [UIColor darkGrayColor]}];
        if(self.odotext.text.length==0) {
        
        UILabel *label = (UILabel *) [self.view1 viewWithTag:1];
        [self labelanimatetohide:label];
        }
    }
    
    if(textField==self.daystext) {
        textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"days", @"Days") attributes:@{NSForegroundColorAttributeName: [UIColor darkGrayColor]}];
        if(self.daystext.text.length==0) {
            
            UILabel *label = (UILabel *) [self.view1 viewWithTag:2];
            [self labelanimatetohide:label];
        }
    }
    
    if(textField==self.lastodoText) {
        textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"odometer", @"Odometer") attributes:@{NSForegroundColorAttributeName: [UIColor darkGrayColor]}];
        if(self.lastodoText.text.length==0) {
            
            UILabel *label = (UILabel *) [self.view1 viewWithTag:3];
            [self labelanimatetohide:label];
        }
    }


    if(textField==self.dateText) {
        textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"date", @"Date") attributes:@{NSForegroundColorAttributeName: [UIColor darkGrayColor]}];
        if(self.dateText.text.length==0) {
            
            UILabel *label = (UILabel *) [self.view1 viewWithTag:4];
            [self labelanimatetohide:label];
        }
    }
    
}


-(void)labelanimatetoshow: (UIView *)view

{
    
    [UIView transitionWithView:view
                      duration:0.4
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:NULL
                    completion:NULL];
    
    view.hidden = NO;
}

-(void)labelanimatetohide: (UIView *)view

{
    
    [UIView transitionWithView:view
                      duration:0.4
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:NULL
                    completion:NULL];
    
    view.hidden = YES;
}


#pragma mark - set Reminder 
-(void)addreminder {
    
    NSString *serviceNameText = self.servicename.text;
    NSString *lastOdoText = self.lastodoText.text;
    NSString *dateText = self.dateText.text;
    NSString* jrnKey = [[[self.servicedetails objectForKey:@"name"] stringByAppendingString:@","] stringByAppendingString:[[NSUserDefaults standardUserDefaults]objectForKey:@"vehname"]];
    
    if([self.daysButton.currentImage isEqual:[UIImage imageNamed:@"check"]]){
        
        if(self.daystext.text.length !=0) {

            if(!_recurring){

                NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
                dateformatter.dateFormat = @"dd-MMM-yyyy";
                [dateformatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT+0:00"]];
                NSString *dueDateString = self.daystext.text;
                NSDate *dueDate = [dateformatter dateFromString:dueDateString];

                NSDate *currentDate = [NSDate date];

                if([dueDate compare: currentDate] == NSOrderedDescending){

                    NSString* jrnKey = [[[self.servicedetails objectForKey:@"name"] stringByAppendingString:@","] stringByAppendingString:[[NSUserDefaults standardUserDefaults]objectForKey:@"vehname"]];

                    [[JRNLocalNotificationCenter defaultCenter] cancelLocalNotificationForKey:jrnKey];

                    NSString *daysButtonLabel = self.durationButton.titleLabel.text;

                    NSOperationQueue *queue = [NSOperationQueue new];

                    queue.maxConcurrentOperationCount = 1;

                    [queue  addOperationWithBlock:^{

                        [self dayreminder:dueDateString durationButtonText:daysButtonLabel];
                    }];


                    [queue  addOperationWithBlock:^{
                        //[NSThread sleepForTimeInterval:2.0];
                        dateformatter.dateFormat = @"dd-MMM-yyyy";
                        [self updateservice:@"duedays" serviceName: serviceNameText lastodoText:@"0" dateText:[dateformatter stringFromDate:[NSDate date]]];
                    }];

                }else{

                    NSString *message = NSLocalizedString(@"one_time_duedate_reminder_less_than_today", @"Due date has to be greater than today");

                    [self showAlert:message];
                }

            }else{

                NSString* jrnKey = [[[self.servicedetails objectForKey:@"name"] stringByAppendingString:@","] stringByAppendingString:[[NSUserDefaults standardUserDefaults]objectForKey:@"vehname"]];

                [[JRNLocalNotificationCenter defaultCenter] cancelLocalNotificationForKey:jrnKey];

                NSString *daysText = self.daystext.text;
                NSString *daysButtonLabel = self.durationButton.titleLabel.text;

                NSOperationQueue *queue = [NSOperationQueue new];

                queue.maxConcurrentOperationCount = 1;

                [queue  addOperationWithBlock:^{
                    [self dayreminder:daysText durationButtonText:daysButtonLabel];
                }];


                [queue  addOperationWithBlock:^{
                    //[NSThread sleepForTimeInterval:2.0];
                    [self updateservice:@"duedays" serviceName: serviceNameText lastodoText:lastOdoText dateText:dateText];
                }];
            }

        }
    }
    
    else if([self.odocheck.currentImage isEqual:[UIImage imageNamed:@"check"]]){

        if(!_recurring){

            //Get max odo
            commonMethods *common = [[commonMethods alloc] init];
            double maxOdo = [common getMaxNoTripOdoForVehicle:_veh_id];

            double dueMiles = [self.odotext.text doubleValue];

            if(dueMiles > maxOdo){

                if(self.odotext.text.length!=0) {

                    [[JRNLocalNotificationCenter defaultCenter] cancelLocalNotificationForKey:jrnKey];
                    [self updateservice:@"duemiles" serviceName: serviceNameText lastodoText:@"0" dateText:@"0"];
                }

            }else{

                
                NSString *message = NSLocalizedString(@"one_time_odo_reminder_less_than_max", @"Odometer value has to be greater than the current maximum odometer value");

                [self showAlert:message];
            }

        }else{

            if(self.odotext.text.length!=0) {

                [[JRNLocalNotificationCenter defaultCenter] cancelLocalNotificationForKey:jrnKey];
                [self updateservice:@"duemiles" serviceName: serviceNameText lastodoText:lastOdoText dateText:dateText];
            }
        }
    }
    
    
    else if([self.noreminderButton.currentImage isEqual:[UIImage imageNamed:@"check"]]){
        // [self lastServiceCheckAlert];

        [[JRNLocalNotificationCenter defaultCenter] cancelLocalNotificationForKey:jrnKey];
        [self updateservice:@"none" serviceName: serviceNameText lastodoText:lastOdoText dateText:dateText];
    }
    
    else if([self.comesfirstButton.currentImage isEqual:[UIImage imageNamed:@"check"]]) {
        if(self.odotext.text.length !=0 && self.daystext.text) {
            [[JRNLocalNotificationCenter defaultCenter] cancelLocalNotificationForKey:jrnKey];

            bool dayNotOk = false;
            if(!_recurring){

                NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
                dateformatter.dateFormat = @"dd-MMM-yyyy";
                [dateformatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT+0:00"]];
                NSString *dueDateString = self.daystext.text;
                NSDate *dueDate = [dateformatter dateFromString:dueDateString];

                NSDate *currentDate = [NSDate date];

                if([dueDate compare: currentDate] == NSOrderedDescending){

                    [self dayreminder:self.daystext.text durationButtonText:self.durationButton.titleLabel.text];
                    dayNotOk = false;
                }else{

                    NSString *message = NSLocalizedString(@"one_time_duedate_reminder_less_than_today", @"Due date has to be greater than today");
                    dayNotOk = true;
                    [self showAlert:message];
                }

                //Get max odo
                commonMethods *common = [[commonMethods alloc] init];
                double maxOdo = [common getMaxNoTripOdoForVehicle:_veh_id];

                double dueMiles = [self.odotext.text doubleValue];

                if(dueMiles > maxOdo){

                    if(self.odotext.text.length!=0) {

                        [self updateservice:@"whicheverfirst" serviceName: serviceNameText lastodoText:lastOdoText dateText:dateText];
                    }

                }else{

                    if(!dayNotOk){

                        NSString *message = NSLocalizedString(@"one_time_odo_reminder_less_than_max", @"Odometer value has to be greater than the current maximum odometer value");

                        [self showAlert:message];
                    }
                }

            }else{

                [self dayreminder:self.daystext.text durationButtonText:self.durationButton.titleLabel.text];
                [self updateservice:@"whicheverfirst" serviceName: serviceNameText lastodoText:lastOdoText dateText:dateText];
            }


        }

    }

}

-(void)showAlert:(NSString *) message{

    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@""
                                  message:message
                                  preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:NSLocalizedString(@"ok", @"OK")
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action){


    }];

    [alert addAction:ok];

    [self presentViewController:alert animated:YES completion:nil];

}

-(void)updateservice: (NSString *)updatevalue serviceName:(NSString *)serviceNameText lastodoText:(NSString *) lastodoText dateText:(NSString *) dateText{
    
    // NSLog(@"distance value %.2f",distance);
    NSUserDefaults *Def =[NSUserDefaults standardUserDefaults];
    NSString *comparestring = [NSString stringWithFormat:@"%@",[Def objectForKey:@"fillupid"]];

    NSManagedObjectContext *contex1 = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSFetchRequest *requset1=[[NSFetchRequest alloc] initWithEntityName:@"Services_Table"];
    NSError *err1;
    NSPredicate *p1=[NSPredicate predicateWithFormat:@"vehid == %@ ",comparestring];
    NSPredicate *p2=[NSPredicate predicateWithFormat:@"serviceName == %@",serviceNameText];
    
    NSPredicate *p=[NSCompoundPredicate andPredicateWithSubpredicates:@[p1,p2]];
    [requset1 setPredicate:p];
    NSArray *data1=[contex1 executeFetchRequest:requset1 error:&err1];
    NSDateFormatter *formater=[[NSDateFormatter alloc] init];
    [formater setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT+0:00"]];
    [formater setDateFormat:@"dd-MMM-yyyy"];
    
    //Swapnil NEW_6
    NSNumber *rowID;
    
    if([updatevalue isEqualToString:@"duemiles"]) {
        
        for(Services_Table *Service in data1) {
            Service.dueMiles = @([self.odotext.text floatValue]);
            Service.dueDays = @(0);
            if(!_recurring){

                Service.lastOdo = @(0);
                Service.lastDate = [[NSDate alloc] init];//[formater dateFromString:[self.servicedetails objectForKey:@"lastdate"]];
            }else{

                Service.lastOdo = @([[self.servicedetails objectForKey:@"lastodo"] floatValue]);
                Service.lastDate = [formater dateFromString:[self.servicedetails objectForKey:@"lastdate"]];
                NSLog(@"AddreminderViewController line number 839:- %@",Service.lastDate);
            }
            //Service.lastDate = [formater dateFromString:[self.servicedetails objectForKey:@"lastdate"]];
            
            
            if(lastodoText.length!= 0 && dateText!=0) {

                if(!_recurring){

                    Service.lastOdo = @(0);
                    Service.lastDate = [[NSDate alloc] init];//[formater dateFromString:[self.servicedetails objectForKey:@"lastdate"]];
                }else{

                    Service.lastDate = [formater dateFromString:dateText];
                    Service.lastOdo = @([lastodoText floatValue]);
                }

                
                //NSLog(@"Service.lastDate :%@ ", Service.lastDate);
                //NSLog(@"Service.lastOdo :%@ ", Service.lastOdo);
                
                rowID = Service.iD;
            }
            
        }

    }
    
    else if ([updatevalue isEqualToString:@"duedays"]){
        for(Services_Table *Service in data1) {
            Service.dueMiles = @(0);
            //NSLog(@"notif %ld",notificationtime);
            Service.dueDays = @(notificationtime);

            if(!_recurring){

                Service.lastOdo = @(0);
                Service.lastDate = [formater dateFromString:dateText];
            }else{

                Service.lastOdo = @([[self.servicedetails objectForKey:@"lastodo"] floatValue]);
                Service.lastDate = [formater dateFromString:[self.servicedetails objectForKey:@"lastdate"]];

                if(lastodoText.length!= 0 && dateText.length!=0) {

                    Service.lastDate = [formater dateFromString:dateText];
                    //NSLog(@"text %f",[self.lastodoText.text floatValue]);
                    Service.lastOdo = @([lastodoText floatValue]);

                    rowID = Service.iD;
                }
            }

        }
    }

    else if ([updatevalue isEqualToString:@"none"]){
        for(Services_Table *Service in data1) {
            Service.dueMiles = @(0);
            Service.dueDays = @(0);
            if(!_recurring){

                Service.lastOdo = @(0);
                Service.lastDate = [[NSDate alloc] init];
            }else{

                Service.lastOdo = @([[self.servicedetails objectForKey:@"lastodo"] floatValue]);
                Service.lastDate = [formater dateFromString:[self.servicedetails objectForKey:@"lastdate"]];
            }
            if(lastodoText.length!= 0 && dateText.length!=0) {

                Service.lastDate = [formater dateFromString:dateText];
                Service.lastOdo = @([lastodoText floatValue]);

                if(!_recurring){

                    Service.lastOdo = @(0);
                    Service.lastDate = [[NSDate alloc] init];
                }

                rowID = Service.iD;
            }
        }
    }
    
    else if ([updatevalue isEqualToString:@"whicheverfirst"]) {

        for(Services_Table *Service in data1) {

            Service.dueMiles = @([self.odotext.text floatValue]);
            Service.dueDays = @(notificationtime);

            if(!_recurring){

                Service.lastOdo = @(0);
                Service.lastDate = [[NSDate alloc] init];//[formater dateFromString:[self.servicedetails objectForKey:@"lastdate"]];
            }else{

                Service.lastOdo = @([[self.servicedetails objectForKey:@"lastodo"] floatValue]);
                Service.lastDate = [formater dateFromString:[self.servicedetails objectForKey:@"lastdate"]];
            }
            //           Service.lastOdo = @([[self.servicedetails objectForKey:@"lastodo"] floatValue]);
            //           Service.lastDate = [formater dateFromString:[self.servicedetails objectForKey:@"lastdate"]];

            if(lastodoText.length!= 0 && dateText.length!=0) {

                if(!_recurring){

                    Service.lastOdo = @(0);
                    Service.lastDate = [[NSDate alloc] init];//[formater dateFromString:[self.servicedetails objectForKey:@"lastdate"]];
                }else{

                    Service.lastDate = [formater dateFromString:dateText];
                    Service.lastOdo = @([lastodoText floatValue]);
                }

                rowID = Service.iD;
            }


        }
    }

    if ([contex1 hasChanges])
    {
        BOOL saved = [contex1 save:&err1];
        if (!saved) {
            // do some real error handling
            //CLSLog(@“Could not save Data due to %@“, error);
        }
        [[CoreDataController sharedInstance] saveMasterContext];
        //Swapnil NEW_6
        NSString *userEmail = [Def objectForKey:@"UserEmail"];
        
        //If user is signed In, then only do the sync process..
        if(userEmail != nil && userEmail.length > 0){
            
            [self writeToSyncTableWithRowID:rowID tableName:@"SERVICE_TABLE" andType:@"edit"];
            // [self checkNetworkForCloudStorage];
        }

    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:YES];
    });
    
}


-(void)lastServiceCheckAlert
{
    //    NSLog(@"elf.lastodoText.text %@", self.lastodoText.text);
    //    NSString *rawString = [self.lastodoText text];
    //    NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    //    NSString *trimmedOdo = [rawString stringByTrimmingCharactersInSet:whitespace];

    if(!_recurring){

        [self addreminder];
    }else{

        if ([self.lastodoText.text length] == 0 || self.dateText.text.length == 0 ) {

            //NSString *last_service = @"Last Service:";

            UIAlertController * alert=   [UIAlertController
                                          alertControllerWithTitle:NSLocalizedString(@"last_service", @"Last service")
                                          message:@"As we do not have any record of your last service, we will take the current odometer value as a starting point"
                                          preferredStyle:UIAlertControllerStyleAlert];

            UIAlertAction* ok = [UIAlertAction
                                 actionWithTitle:NSLocalizedString(@"ok", @"OK")
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {

                if(self.lastodoText.text.length == 0) {
                    self.lastodoText.text = [self.servicedetails objectForKey:@"maxodo"];
                }

                if(self.dateText.text.length==0) {

                    NSString *lastDate = [self.servicedetails objectForKey:@"lastdate"];
                    if(lastDate.length>0){

                        self.dateText.text = [self.servicedetails objectForKey:@"lastdate"];

                    }else{

                        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                        NSDate *eventDate = [NSDate date];
                        [dateFormat setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT+0:00"]];
                        [dateFormat setDateFormat:@"dd-MMM-yyyy"];

                        NSString *dateString = [dateFormat stringFromDate:eventDate];
                        self.dateText.text = [NSString stringWithFormat:@"%@",dateString];

                    }


                }

                [self addreminder];
                [alert dismissViewControllerAnimated:YES completion:nil];


            }];
            UIAlertAction* cancel = [UIAlertAction
                                     actionWithTitle:NSLocalizedString(@"no", @"No")
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action)
                                     {


                [alert dismissViewControllerAnimated:YES completion:nil];


            }];

            [alert addAction:ok];
            [alert addAction:cancel];

            [self presentViewController:alert animated:YES completion:nil];

        }
        else
        {
            [self addreminder];
        }
    }

}

-(void)dayreminder: (NSString *)daysText durationButtonText:(NSString *)durationButtonText {

    NSDateFormatter *formater=[[NSDateFormatter alloc] init];
    [formater setDateFormat:@"dd-MMM-yyyy"];
    [formater setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT+0:00"]];
    NSDate *date = [formater dateFromString:[self.servicedetails objectForKey:@"lastdate"]];
    if([durationButtonText isEqualToString:NSLocalizedString(@"days", @"Days")]) {
        notificationtime = [daysText longLongValue];
    }
    
    else  if([durationButtonText isEqualToString:NSLocalizedString(@"reminder_due_date_unit_array_1", @"Months")]) {
        notificationtime = [daysText longLongValue]*30;

    }
    else  {
        
        notificationtime = [daysText longLongValue]*365;
    }

    NSDate* remDate = [[NSDate alloc] init];
    if(!_recurring){

        NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
        dateformatter.dateFormat = @"dd-MMM-yyyy";
        [dateformatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT+0:00"]];
        NSString *dueDateString = daysText;
        NSDate *dueDate = [dateformatter dateFromString:dueDateString];

        NSDate *currentDate = [NSDate date];

        remDate = dueDate; //[formater dateFromString:daysText];

        NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *components = [gregorianCalendar components:NSCalendarUnitDay
                                                            fromDate:currentDate
                                                              toDate:dueDate
                                                             options:0];

        //NSString *daysDiffString = [NSString stringWithFormat:@"%li",[components day]];
        notificationtime = [components day]+1; //[daysDiffString longLongValue];
    }else{

        remDate = [date dateByAddingTimeInterval:(60*60*24*notificationtime)];

    }
    
   
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSDateComponents *timeComponents = [calendar components:( NSCalendarUnitYear |  NSCalendarUnitMonth |  NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond )
                                                   fromDate:remDate];
    [timeComponents setHour:7];
    [timeComponents setMinute:00];
    [timeComponents setSecond:0];
    
    NSDate *dtFinal = [calendar dateFromComponents:timeComponents];

    NSString* alertBody = [NSString stringWithFormat:@"%@ %@ %@",[self.servicedetails objectForKey:@"name"], NSLocalizedString(@"noti_msg_veh", @"Overdue for"), [[NSUserDefaults standardUserDefaults]objectForKey:@"vehname"]];
    
    if ([dtFinal compare:[NSDate date]] == NSOrderedAscending) {
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:NSLocalizedString(@"overdue_noti", @"Overdue Service")
                                              message:alertBody
                                              preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"ok", @"OK action")
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       
                                   }];
        [alertController addAction:okAction];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:alertController animated:YES completion:nil];

        });

    }
    

    NSString* jrnKey = [[[self.servicedetails objectForKey:@"name"] stringByAppendingString:@","] stringByAppendingString:[[NSUserDefaults standardUserDefaults]objectForKey:@"vehname"]];
    [[JRNLocalNotificationCenter defaultCenter] cancelLocalNotificationForKey:jrnKey];
    //Engine Oil,Varansi Mahindra TUV300 T4
    [[JRNLocalNotificationCenter defaultCenter] postNotificationOn:dtFinal                                                            forKey:jrnKey alertBody:[NSString stringWithFormat:@"Pull or swipe to interact. %@", alertBody]
                                                       alertAction:@"Open"
                                                         soundName:nil
                                                       launchImage:nil
                                                          userInfo:@{@"DueDate": dtFinal}
                                                        badgeCount:0
                                                     //repeatInterval:NO
                                                    repeatInterval:NSCalendarUnitDay
                                                          category:@"DayReminder"];
    
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"showPage"];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)odometercheck:(id)sender {
    
    checkedstatus = @"odo";
    //UIImage *image = [UIImage imageNamed:@"check1"];
    
    [self.odocheck setImage:[UIImage imageNamed:@"check"] forState:UIControlStateNormal];
    self.odocheck.tintColor = [UIColor whiteColor];
    [self.daysButton setImage:[UIImage imageNamed:@"uncheck"] forState:UIControlStateNormal];
    [self.noreminderButton setImage:[UIImage imageNamed:@"uncheck"] forState:UIControlStateNormal];
    [self.comesfirstButton setImage:[UIImage imageNamed:@"uncheck"] forState:UIControlStateNormal];
    
    self.odotext.enabled = YES;
    self.odotext.textColor = [UIColor whiteColor];
     self.durationButton.enabled = NO;
    self.daystext.enabled = NO;
     self.daystext.textColor = [UIColor lightGrayColor];
    
    
}

- (IBAction)dayscheck:(id)sender {
    checkedstatus = @"days";
    [self.odocheck setImage:[UIImage imageNamed:@"uncheck"] forState:UIControlStateNormal];
   
   // UIImage *image = [[UIImage imageNamed:@"check1"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
     [self.daysButton setImage:[UIImage imageNamed:@"check"] forState:UIControlStateNormal];
    self.daysButton.tintColor = [UIColor whiteColor];
    [self.noreminderButton setImage:[UIImage imageNamed:@"uncheck"] forState:UIControlStateNormal];
    [self.comesfirstButton setImage:[UIImage imageNamed:@"uncheck"] forState:UIControlStateNormal];
    
    self.odotext.enabled = NO;
    self.odotext.textColor = [UIColor lightGrayColor];
     self.durationButton.enabled = YES;
    self.daystext.enabled = YES;
    self.daystext.textColor = [UIColor whiteColor];
    
}

- (IBAction)whichevercomesfirst:(id)sender {
    checkedstatus = @"comesfirst";
    [self.odocheck setImage:[UIImage imageNamed:@"uncheck"] forState:UIControlStateNormal];
    [self.daysButton setImage:[UIImage imageNamed:@"uncheck"] forState:UIControlStateNormal];
    [self.noreminderButton setImage:[UIImage imageNamed:@"uncheck"] forState:UIControlStateNormal];
  //  UIImage *image = [[UIImage imageNamed:@"check1"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    [self.comesfirstButton setImage:[UIImage imageNamed:@"check"]forState:UIControlStateNormal];
    self.comesfirstButton.tintColor = [UIColor whiteColor];
    self.odotext.enabled = YES;
    self.odotext.textColor = [UIColor whiteColor];
    self.daystext.enabled = YES;
    self.daystext.textColor = [UIColor whiteColor];
     self.durationButton.enabled = YES;
}
- (IBAction)noreminder:(id)sender {
    
    checkedstatus = @"no";
    [self.odocheck setImage:[UIImage imageNamed:@"uncheck"] forState:UIControlStateNormal];
    [self.daysButton setImage:[UIImage imageNamed:@"uncheck"] forState:UIControlStateNormal];
   // UIImage *image = [[UIImage imageNamed:@"check1"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    [self.noreminderButton setImage:[UIImage imageNamed:@"check"] forState:UIControlStateNormal];
    self.noreminderButton.tintColor = [UIColor whiteColor];
    [self.comesfirstButton setImage:[UIImage imageNamed:@"uncheck"] forState:UIControlStateNormal];
    
    self.odotext.enabled = NO;
    self.odotext.textColor = [UIColor lightGrayColor];
    self.durationButton.enabled = NO;
    self.daystext.enabled = NO;
    self.daystext.textColor = [UIColor lightGrayColor];
    
}

#pragma mark - Fetch Vehicle
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
        NSString *savedName = [[NSUserDefaults standardUserDefaults]objectForKey:@"vehname"];
        NSString *vehName = [NSString stringWithFormat:@"%@ %@",vehicle.make,vehicle.model];

        NSString *lastSpaceTrim = [vehName substringFromIndex:vehName.length-1];

        NSString *finalVehName;
        if([lastSpaceTrim isEqualToString:@" "]){

            finalVehName = [vehName substringToIndex:vehName.length-1];
        }else{
            finalVehName = vehName;
        }
        if([savedName isEqualToString:finalVehName]){

            _veh_id = vehicle.iD;
        }
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


#pragma mark - Duration Picker
-(void)setdurationpicker {
    [_picker removeFromSuperview];
    _picker = [[UIPickerView alloc]init];
    AppDelegate *App = [AppDelegate sharedAppDelegate];
    _picker.frame = CGRectMake(App.result.width/2-130,App.result.height/2-220, 260, 270);
    _picker.backgroundColor=[UIColor grayColor];
    
    _picker.clipsToBounds=YES;
    _picker.delegate =self;
    _picker.dataSource=self;
    _picker.tag=-8;
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
    [_setbutton setTitle:@"Set" forState:UIControlStateNormal];
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
        return  self.durationarray.count;
    }
    else
        return 0;
}


- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if(pickerView.tag==-8)
    {
        return [self.durationarray objectAtIndex:row];
    }
    else
        
        return 0;
}


-(void)donelabel
{
 
    [self.durationButton setTitle:[self.durationarray objectAtIndex:[self.picker selectedRowInComponent:0]] forState:UIControlStateNormal];
    [self.picker removeFromSuperview];
    [self.setbutton removeFromSuperview];
}


#pragma mark CLOUD SYNC METHODS

//Swapnil NEW_6

//Save rowID, tableName, and type in phones Sync table
- (void)writeToSyncTableWithRowID: (NSNumber *)rowID tableName: (NSString *)tableName andType: (NSString *)type{

    NSManagedObjectContext *context = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSError *err;
    Sync_Table *syncData = [NSEntityDescription insertNewObjectForEntityForName:@"Sync_Table" inManagedObjectContext:context];
    
    syncData.rowID = rowID;
    syncData.tableName = tableName;
    syncData.type = type;
    syncData.processing = @0;
    
    if([context hasChanges]){
        
        BOOL saved = [context save:&err];
        if (!saved) {
            // do some real error handling
            //CLSLog(@“Could not save Data due to %@“, error);
        }
        [[CoreDataController sharedInstance] saveMasterContext];
        //Upload data from common methods
        commonMethods *common = [[commonMethods alloc] init];
        [common checkNetworkForCloudStorage:@"isService"];
        

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
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"tableName == 'SERVICE_TABLE'"];
    
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

            [self setType:type andRowID:syncData.rowID andTableName:syncData.tableName];
        }
    }
}

//Loop thr' the specified tableName and get record for specified rowID
- (void)setType: (NSString *)type andRowID: (NSNumber *)rowID andTableName: (NSString *)tableName{

    NSManagedObjectContext *context = [[CoreDataController sharedInstance] backgroundManagedObjectContext];
    NSError *err;
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Services_Table"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"iD == %d", [rowID intValue]];
    
    [request setPredicate:predicate];
    NSArray *dataValue = [context executeFetchRequest:request error:&err];
    
    Services_Table *serviceData = [dataValue firstObject];
    
    NSFetchRequest *vehRequest = [[NSFetchRequest alloc] initWithEntityName:@"Veh_Table"];
    NSPredicate *vehPredicate = [NSPredicate predicateWithFormat:@"iD == %d", [serviceData.vehid intValue]];
    [vehRequest setPredicate:vehPredicate];
    
    NSArray *vehData = [context executeFetchRequest:vehRequest error:&err];
    
    Veh_Table *vehicleData = [vehData firstObject];
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    if(rowID != nil){
        [dictionary setObject:rowID forKey:@"_id"];
    } else {
        [dictionary setObject:@"" forKey:@"_id"];
    }
    
    if(type != nil){
        [dictionary setObject:type forKey:@"type"];
    } else {
        [dictionary setObject:type forKey:@"type"];
    }
    [dictionary setObject:[def objectForKey:@"UserEmail"] forKey:@"email"];
    [dictionary setObject:[def objectForKey:@"UserDeviceId"] forKey:@"androidId"];
    [dictionary setObject:@"phone" forKey:@"source"];
    
    
    if(vehicleData.vehid != nil){
        [dictionary setObject:vehicleData.vehid forKey:@"vehid"];
    } else {
        [dictionary setObject:@"" forKey:@"vehid"];
    }
    
    if(serviceData.type != nil){
        [dictionary setObject:serviceData.type forKey:@"rec_type"];
    } else {
        [dictionary setObject:@"" forKey:@"rec_type"];
    }
    
    if(serviceData.serviceName != nil){
        [dictionary setObject:serviceData.serviceName forKey:@"serviceName"];
    } else {
        [dictionary setObject:@"" forKey:@"serviceName"];
    }
    
    if(serviceData.recurring != nil){
        [dictionary setObject:serviceData.recurring forKey:@"recurring"];
    } else {
        [dictionary setObject:@"" forKey:@"recurring"];
    }
    
    if(serviceData.dueMiles != nil){
        [dictionary setObject:serviceData.dueMiles forKey:@"dueMiles"];
    } else {
        [dictionary setObject:@"" forKey:@"dueMiles"];
    }
    
    if(serviceData.dueDays != nil){
        [dictionary setObject:serviceData.dueDays forKey:@"dueDays"];
    } else {
        [dictionary setObject:@"" forKey:@"dueDays"];
    }
    
    if(serviceData.lastOdo != nil){
        [dictionary setObject:serviceData.lastOdo forKey:@"lastOdo"];
    } else {
        [dictionary setObject:@"" forKey:@"lastOdo"];
    }
    
    commonMethods *common = [[commonMethods alloc] init];
    NSDictionary *epochDictionary = [common getDayMonthYrFromStringDate:serviceData.lastDate];
    
    [dictionary setObject:[epochDictionary valueForKey:@"epochTime"] forKey:@"lastDate"];
    
    //NSLog(@"service val : %@", dictionary);
    
    NSData *postData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:&err];
    [def setBool:YES forKey:@"updateTimeStamp"];
    //Pass paramters dictionary and URL of script to get response
    [common saveToCloud:postData urlString:kServiceDataScript success:^(NSDictionary *responseDict) {
        //NSLog(@"Service responseDict : %@", responseDict);
        
        if([[responseDict objectForKey:@"message"] isEqualToString:@"Success"]){
            
            [common clearPhoneSyncTableWithID:rowID tableName:tableName andType:type];
            
        }
    } failure:^(NSError *error) {
      //  NSLog(@"%@", error.localizedDescription);
    }];
    
}

@end
