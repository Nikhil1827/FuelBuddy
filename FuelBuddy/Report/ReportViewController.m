//
//  ReportViewController.m
//  FuelBuddy
//
//  Created by Nikhil on 08/08/18.
//  Copyright © 2018 Oraganization. All rights reserved.
//

#import "ReportViewController.h"
#import "AutomatedReportsViewController.h"
#import "AppDelegate.h"
#import "T_Fuelcons.h"
#import "T_Trip.h"
#import "Veh_Table.h"
#import "Services_Table.h"
#import "GoProViewController.h"
#import "commonMethods.h"
#import "WebServiceURL's.h"
#import "MBProgressHUD.h"
#import "LogViewController.h"

@interface ReportViewController (){
    
    NSString *previousEmailString;
    BOOL validEmail, timePressed;
    NSString *timeSelected,*emailText,*fromText,*toText;
    BOOL rawValue, pdfValue, csvValue, includeReceipt;
    NSMutableArray *dataArray,*allTripDataArray,*vehNameArray,*fillUpDataArray, *serviceDataArray, *expenseDataArray, *tripDataArray, *receiptsArray;
    NSMutableDictionary *vehiclePDFDict, *fillUpPDFDict, *servicePDFDict, *expensePDFDict, *tripPDFDict;
    BOOL sendSuccess;
}
@property int selPickerRow;

@end

@implementation ReportViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.context = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    self.navigationController.navigationBar.barTintColor = [self colorFromHexString:@"#0098AB"];
    self.navigationController.navigationBar.tintColor =[UIColor whiteColor];
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.topItem.title= NSLocalizedString(@"report", @"Report");
   
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor] , NSFontAttributeName: [UIFont fontWithName:@"Helvetica-Light" size:18.0] }];
    self.view.backgroundColor = [self colorFromHexString:@"#2c2c2c"];
    UIImage *buttonImage = [[UIImage imageNamed:@"nav_back"] resizableImageWithCapInsets:UIEdgeInsetsMake(20,10,10,10)];
    UIButton *Button = [UIButton buttonWithType:UIButtonTypeCustom];
    [Button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    Button.frame = CGRectMake(0.0, 10.0, buttonImage.size.width+4,buttonImage.size.height+4);
    UIBarButtonItem *BarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:Button];
    [Button addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setLeftBarButtonItem:BarButtonItem];
    previousEmailString = [def objectForKey:@"toSendEmail"];
    self.emailThisLabel.text = NSLocalizedString(@"email_to", @"Email this report to");
    if(previousEmailString != nil && previousEmailString.length > 0){
        self.emailTextField.text = previousEmailString;
        self.emailThisLabel.hidden = NO;
    }else{
        self.emailTextField.placeholder = NSLocalizedString(@"email_to", @"Email this report to");
        self.emailThisLabel.hidden = YES;
    }
    self.emailTextField.backgroundColor = [self colorFromHexString:@"#2c2c2c"];
    self.includeDataLabel.text = NSLocalizedString(@"report_dates", @"Include data for:");
    self.timeSelectLabel.titleLabel.text = NSLocalizedString(@"report_date_range_0", @"All Time");
    timeSelected = NSLocalizedString(@"report_date_range_0", @"All Time");
    self.fromLabel.text = NSLocalizedString(@"from_date_head", @"From:");
    self.fromLabel.hidden = YES;
    self.fromTextField.backgroundColor = [self colorFromHexString:@"#2c2c2c"];
    self.fromTextField.text = NSLocalizedString(@"from_date_head", @"From:");
    self.fromTextField.textColor = [UIColor lightGrayColor];
    self.fromTextField.userInteractionEnabled = NO;
    self.toLabel.text = NSLocalizedString(@"to_date_head", @"To:");
    self.toLabel.hidden = YES;
    self.toTextField.backgroundColor = [self colorFromHexString:@"#2c2c2c"];
    self.toTextField.text = NSLocalizedString(@"to_date_head", @"To:");
    self.toTextField.textColor = [UIColor lightGrayColor];
    self.toTextField.userInteractionEnabled = NO;
    self.includeRawLabel.text = NSLocalizedString(@"include_raw_data", @"Include raw data");
    self.fileTypeLabel.text = NSLocalizedString(@"file_type", @"File type:");
    self.fileTypeLabel.textColor = [UIColor darkGrayColor];
    self.pdfLabel.textColor = [UIColor darkGrayColor];
    self.csvLabel.textColor = [UIColor darkGrayColor];
    self.includeReceiptLabel.text = NSLocalizedString(@"include_receipts", @"Include receipts");
    self.generateReportLabel.titleLabel.text = NSLocalizedString(@"gen_report", @"Generate Report");
    self.automatedLabel.titleLabel.text = NSLocalizedString(@"automated_report", @"Automated Reports");
    [self.includeRawOutlet setImage:[UIImage imageNamed:@"uncheck"] forState:UIControlStateNormal];
    [self.includeReceiptOutlet setImage:[UIImage imageNamed:@"uncheck"] forState:UIControlStateNormal];
    [self.pdfOutlet setImage:[UIImage imageNamed:@"uncheck"] forState:UIControlStateNormal];
    [self.csvOutlet setImage:[UIImage imageNamed:@"uncheck"] forState:UIControlStateNormal];
    
    UITextField *text = [[UITextField alloc]init];
    text = self.emailTextField;
    text.delegate = self;
    [self textfieldsetting:text];
    
    self.timePickerArray = [[NSMutableArray alloc]initWithObjects:NSLocalizedString(@"report_date_range_0",@"All Time"),NSLocalizedString(@"report_date_range_1",@"This month"),NSLocalizedString(@"report_date_range_2",@"Last month"),NSLocalizedString(@"report_date_range_3",@"Last 90 days"),NSLocalizedString(@"report_date_range_4",@"This year"),NSLocalizedString(@"report_date_range_5",@"Last year"),NSLocalizedString(@"report_date_range_6",@"Custom Dates"), nil];
    
    dataArray = [[NSMutableArray alloc]init];
    allTripDataArray = [[NSMutableArray alloc]init];
    vehNameArray = [[NSMutableArray alloc]init];
    fillUpDataArray = [[NSMutableArray alloc]init];
    serviceDataArray = [[NSMutableArray alloc]init];
    expenseDataArray = [[NSMutableArray alloc]init];
    tripDataArray = [[NSMutableArray alloc]init];
    receiptsArray = [[NSMutableArray alloc]init];
    vehiclePDFDict = [[NSMutableDictionary alloc]init];
    fillUpPDFDict = [[NSMutableDictionary alloc]init];
    servicePDFDict = [[NSMutableDictionary alloc]init];
    expensePDFDict = [[NSMutableDictionary alloc]init];
    tripPDFDict = [[NSMutableDictionary alloc]init];

    sendSuccess = NO;
    
    [def setBool:NO forKey:@"sendAutoReport"];
    
    [self fetchVehiclesData];
    
    NSDictionary *dictionary = [[NSDictionary alloc]init];
    dictionary = [self.vehiclearray lastObject];
    //to reset to first vehicle
    [def setObject:[dictionary objectForKey:@"Id"] forKey:@"vehicleId"];
    [self fetchvalue:NSLocalizedString(@"report_date_range_0",@"All Time")];
    timePressed = YES;
    
    self.vehicleImage.contentMode = UIViewContentModeScaleAspectFill;
    self.vehicleImage.layer.borderWidth=0;
    self.vehicleImage.layer.masksToBounds=YES;
    self.vehicleImage.layer.cornerRadius = 18;
    self.vehicleName.text = [NSString stringWithFormat:@"%@ %@",[dictionary objectForKey:@"Make"],[dictionary objectForKey:@"Model"]];
    if([[dictionary objectForKey:@"Picture"] isEqualToString:@""])
    {
        self.vehicleImage.image=[UIImage imageNamed:@"car4.jpg"];
    }
    
    else
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *urlstring = [paths firstObject];
        NSString *vehiclepic = [NSString stringWithFormat:@"%@/%@",urlstring,[dictionary objectForKey:@"Picture"]];
        self.vehicleImage.image =[UIImage imageWithContentsOfFile:vehiclepic];
    }
    
    
}

-(void)startProgressHUD:(NSString *)loadingText{
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.offset = CGPointMake(0,85);
    AppDelegate *App = [AppDelegate sharedAppDelegate];
    if(App.result.height == 480) {
        hud.offset = CGPointMake(0,120);
    }else{
        hud.offset = CGPointMake(0,-30);
    }
    hud.label.text = loadingText;
    hud.label.textColor = [self colorFromHexString:@"#FFCA1D"];
    hud.bezelView.backgroundColor = [UIColor clearColor];
    hud.bezelView.alpha =0.6;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - GENERAL METHODS

-(UIColor *)colorFromHexString:(NSString *)hexString
{
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1];
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

- (IBAction)backButtonPressed: (id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

#pragma mark - TextField Methods

-(void)textfieldsetting: (UITextField *)textfield{

    //[textfield setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    NSMutableAttributedString *placeholderAttributedString = [[NSMutableAttributedString alloc] initWithAttributedString:textfield.attributedPlaceholder];
    [placeholderAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:NSMakeRange(0, [placeholderAttributedString length])];
    textfield.attributedPlaceholder = placeholderAttributedString;
    
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
    [self paddingTextFields:textField];
    self.emailThisLabel.hidden = NO;
    self.emailTextField.placeholder = @"                                  ";
    textField.returnKeyType = UIReturnKeyDone;
}

- (void) paddingTextFields: (UITextField *)textField{
    
    UIView *padding = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 4.8, 20)];
    textField.leftView = padding;
    textField.leftViewMode = UITextFieldViewModeAlways;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    validEmail = [self validateEmail];
    
    if(validEmail){
        
        self.generateReportLabel.userInteractionEnabled = YES;
        
    }else{
        
        NSString *message = NSLocalizedString(@"enter_valid_email",@"Please enter proper email address"); 
        NSString *title = NSLocalizedString(@"invalid_email",@"Invalid Email");
        [self showAlert:title :message];
        self.generateReportLabel.userInteractionEnabled = NO;
    }
    
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField reason:(UITextFieldDidEndEditingReason)reason{
    
    if(textField.text.length == 0){
        self.emailThisLabel.hidden = YES;
        self.emailTextField.placeholder = NSLocalizedString(@"email_to", @"Email this report to");
    }else{
        self.emailThisLabel.hidden = NO;
    }
}

-(BOOL)validateEmail{
    NSString *emailRegEx = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
    if ([emailTest evaluateWithObject:self.emailTextField.text] == YES)
    {
        
        return YES;
    }
    else
    {
      
        return NO;
    }
}

#pragma mark - Picker methods
-(void)openUnitPicker{
    
    [_picker removeFromSuperview];
    [_setbutton removeFromSuperview];
    
    self.generateReportLabel.userInteractionEnabled = NO;
    
    _picker = [[UIPickerView alloc]init];
    AppDelegate *App = [AppDelegate sharedAppDelegate];
    _picker.frame = CGRectMake(App.result.width/2-130,App.result.height/2-220, 260, 270);
    _picker.backgroundColor=[UIColor grayColor];
    
    _picker.clipsToBounds=YES;
    _picker.delegate =self;
    _picker.dataSource=self;
    _picker.tag=-4;
    
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

-(void)donelabel
{
    [dataArray removeAllObjects];
    [allTripDataArray removeAllObjects];
    [fillUpDataArray removeAllObjects];
    [serviceDataArray removeAllObjects];
    [expenseDataArray removeAllObjects];
    [tripDataArray removeAllObjects];
    [receiptsArray removeAllObjects];
    [self.setbutton removeFromSuperview];
    [self.picker removeFromSuperview];
    timeSelected = [[NSString alloc]init];
    timeSelected = [self.timePickerArray objectAtIndex:[self.picker selectedRowInComponent:0]];
    self.timeSelectLabel.titleLabel.text = timeSelected;
    
    //change from to according to selected time
    NSDateFormatter *dFormat=[[NSDateFormatter alloc] init];
    [dFormat setDateFormat:@"dd-MMM-yyyy"];
    timePressed = YES;
    [self setfilter];
    self.generateReportLabel.userInteractionEnabled = YES;
}

-(void)setfilter
{
    
    [self.timeSelectLabel setTitle:[self.timePickerArray objectAtIndex:[self.picker selectedRowInComponent:0]] forState:UIControlStateNormal];
    
    
    if(![[self.timePickerArray objectAtIndex:[self.picker selectedRowInComponent:0]] isEqualToString:NSLocalizedString(@"report_date_range_6", @"Custom Dates")])
    {
        [self.picker removeFromSuperview];
        [self.setbutton removeFromSuperview];
        
        [self fetchvalue: [self.timePickerArray objectAtIndex:[self.picker selectedRowInComponent:0]]];
        
    }
    else
    {
        [self.picker removeFromSuperview];
        [self.setbutton removeFromSuperview];
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:NSLocalizedString(@"report_date_range_6", @"Custom Dates")
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
                
                                           [self.timeSelectLabel setTitle:NSLocalizedString(@"graph_date_range_0", @"All Time")  forState:UIControlStateNormal];
                                           
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
    if([[format dateFromString:self.startdate.text] compare:[format dateFromString:self.enddate.text]]==NSOrderedAscending || [[format dateFromString:self.startdate.text] compare:[format dateFromString:self.enddate.text]]==NSOrderedSame)
    {
        
        [self fetchvalue:NSLocalizedString(@"report_date_range_6", @"Custom Dates")];
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

-(void)fetchvalue :(NSString *) filterstring
{
    NSDate *compareDate = [NSDate date];
    NSUserDefaults *def =[NSUserDefaults standardUserDefaults];
    BOOL autoReport = [def boolForKey:@"sendAutoReport"];
    NSNumber *selectedVehicleID;
    if(autoReport){

        self.context = [[CoreDataController sharedInstance] backgroundManagedObjectContext];
        dataArray = [[NSMutableArray alloc]init];
        allTripDataArray = [[NSMutableArray alloc]init];
        vehNameArray = [[NSMutableArray alloc]init];
        fillUpDataArray = [[NSMutableArray alloc]init];
        serviceDataArray = [[NSMutableArray alloc]init];
        expenseDataArray = [[NSMutableArray alloc]init];
        tripDataArray = [[NSMutableArray alloc]init];
        receiptsArray = [[NSMutableArray alloc]init];
        vehiclePDFDict = [[NSMutableDictionary alloc]init];
        fillUpPDFDict = [[NSMutableDictionary alloc]init];
        servicePDFDict = [[NSMutableDictionary alloc]init];
        expensePDFDict = [[NSMutableDictionary alloc]init];
        tripPDFDict = [[NSMutableDictionary alloc]init];
        fromText = [[NSString alloc]init];
        toText = [[NSString alloc]init];
        
        selectedVehicleID = [def objectForKey:@"autoVehicleId"];
    }else{
        
        selectedVehicleID = [def objectForKey:@"vehicleId"];
    }
    NSManagedObjectContext *vehContext = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSError *vehError;
    NSFetchRequest *vehreq = [[NSFetchRequest alloc] initWithEntityName:@"Veh_Table"];
    NSArray *vehArray = [vehContext executeFetchRequest:vehreq error:&vehError];
    
    NSString *vehicleMake = [[NSString alloc]init];
    NSString *vehicleModel = [[NSString alloc]init];
    for(NSArray *currentRecord in self.vehiclearray){
        
        if([selectedVehicleID isEqual:[currentRecord valueForKey:@"Id"]]){
            
            vehicleMake = [NSString stringWithFormat:@"%@",[currentRecord valueForKey:@"Make"]];
            vehicleModel = [NSString stringWithFormat:@"%@",[currentRecord valueForKey:@"Model"]];
        }
    }
    if(![vehicleMake isEqualToString:NSLocalizedString(@"all", @"All")] && ![vehicleModel isEqualToString:NSLocalizedString(@"veh_tv", @"Vehicles")]){
        
        //T_Fuelcons for selected vehicle
        NSError *err;
        NSString *compareString;
        if(autoReport){
            compareString = [NSString stringWithFormat:@"%@",[def objectForKey:@"autoVehicleId"]];
        }else{
            compareString = [NSString stringWithFormat:@"%@",[def objectForKey:@"vehicleId"]];
        }
        
        NSFetchRequest *request=[[NSFetchRequest alloc] initWithEntityName:@"T_Fuelcons"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"vehid==%@",compareString];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"odo" ascending:YES];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
        [request setPredicate:predicate];
        [request setSortDescriptors:sortDescriptors];
        
        NSArray *datavaluefilter = [[NSArray alloc]init];
        NSMutableArray *datavalue= [[NSMutableArray alloc]init];
        datavaluefilter =[self.context  executeFetchRequest:request error:&err];
        
        
        NSDateFormatter *Uniformater=[[NSDateFormatter alloc] init];
        [Uniformater setDateFormat:@"dd MMM yyyy"];
        NSDateFormatter *formaterMON=[[NSDateFormatter alloc] init];
        [formaterMON setDateFormat:@"MMM"];
        
        
        if([filterstring isEqualToString:NSLocalizedString(@"report_date_range_0",@"All Time")])
        {
            
            datavalue = [[NSMutableArray alloc]initWithArray:datavaluefilter];
            NSDateFormatter *formater2=[[NSDateFormatter alloc] init];
            [formater2 setDateFormat:@"dd-MM-yyyy"];
            
            NSMutableArray *FuelArray = [datavalue firstObject];
            NSDate *minDate = [FuelArray valueForKey:@"stringDate"];
            if([compareDate compare:minDate] == NSOrderedDescending)
            {
                compareDate = minDate;
            }
            
            NSString *startDateString = [formater2 stringFromDate:compareDate];
            
            self.fromTextField.text = startDateString;
            self.fromLabel.hidden = NO;
            self.fromTextField.textColor = [UIColor whiteColor];
            self.toLabel.hidden = NO;
            NSDate *today1 = [[NSDate alloc] init];
            self.toTextField.text = [formater2 stringFromDate:today1];
            toText = [formater2 stringFromDate:today1];
            self.toTextField.textColor = [UIColor whiteColor];
            
        }
        
        else if([filterstring isEqualToString:NSLocalizedString(@"report_date_range_1",@"This month")] || [filterstring isEqualToString:NSLocalizedString(@"report_schedule_1",@"Monthly")])
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
            NSDate *today = [[NSDate alloc] init];
            NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            
            NSDateComponents *components = [gregorian components:NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitYear fromDate:today];
            components.day = 1;
            NSDate *dayOneInCurrentMonth = [gregorian dateFromComponents:components];
            NSDateFormatter *formater2=[[NSDateFormatter alloc] init];
            [formater2 setDateFormat:@"dd-MM-yyyy"];
            NSString *currentMonth = [formater2 stringFromDate:dayOneInCurrentMonth];
            self.fromLabel.hidden = NO;
            self.fromTextField.text = currentMonth;
            fromText = currentMonth;
            self.fromTextField.textColor = [UIColor whiteColor];
            self.toLabel.hidden = NO;
            NSDate *today1 = [[NSDate alloc] init];
            self.toTextField.text = [formater2 stringFromDate:today1];
            toText = [formater2 stringFromDate:today1];
            self.toTextField.textColor = [UIColor whiteColor];
        }
        
        else if([filterstring isEqualToString:NSLocalizedString(@"report_date_range_2",@"Last month")])
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
            
            
            if(components.month!=12)
            {
                for(T_Fuelcons *fuel in datavaluefilter)
                {
                    
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
            //from
            NSCalendar *calendar1 = [NSCalendar currentCalendar];
            NSDateComponents *comps1 = [NSDateComponents new];
            comps1.month = -1;
            comps1.day   = 1;
            NSDate *date1 = [calendar1 dateByAddingComponents:comps1 toDate:[NSDate date] options:0];
            NSDateComponents *components1 = [gregorian components:NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitYear fromDate:date1];
            components1.day = 1;
            NSDate *dayOneInLastMonth = [gregorian dateFromComponents:components1];
            NSDateFormatter *formater2=[[NSDateFormatter alloc] init];
            [formater2 setDateFormat:@"dd-MM-yyyy"];
            NSString *firstDaylastMonth = [formater2 stringFromDate:dayOneInLastMonth];
            
            self.fromLabel.hidden = NO;
            self.fromTextField.text = firstDaylastMonth;
            self.fromTextField.textColor = [UIColor whiteColor];
            
            //to
            NSDateComponents *comps2 = [NSDateComponents new];
            comps2.month = -1;
            comps2.day   = 1;
            NSDate *date2 = [calendar1 dateByAddingComponents:comps2 toDate:[NSDate date] options:0];
            NSDateComponents *components2 = [gregorian components:NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitYear fromDate:date2];
            NSRange range = [gregorian rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date1];
            NSUInteger numberOfDaysInMonth = range.length;
            components2.day = numberOfDaysInMonth;
            NSDate *lastDayOfLastMonth = [gregorian dateFromComponents:components2];
            [formater2 setDateFormat:@"dd-MM-yyyy"];
            NSString *lastDaylastMonth = [formater2 stringFromDate:lastDayOfLastMonth];
            self.toLabel.hidden = NO;
            self.toTextField.text = lastDaylastMonth;
            self.toTextField.textColor = [UIColor whiteColor];
            
            
            
        }
        else if ([filterstring isEqualToString:NSLocalizedString(@"report_date_range_3",@"Last 90 days")]){
            
            NSDateFormatter *formater=[[NSDateFormatter alloc] init];
            [formater setDateFormat:@"dd MM yyyy"];
            
            //3rd Month
            NSCalendar *calendar = [NSCalendar currentCalendar];
            NSDateComponents *components = [calendar components:NSCalendarUnitMonth|NSCalendarUnitDay fromDate:[NSDate date]];
            
            NSDate *today = [[NSDate alloc] init];
            NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
            [offsetComponents setDay:-90];
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
                for(T_Fuelcons *fuel in datavaluefilter)
                {
                    
                    if((([last90thday compare:fuel.stringDate] == NSOrderedAscending && [today compare:fuel.stringDate] == NSOrderedDescending) || ([last90thday compare:fuel.stringDate] == NSOrderedSame) || ([today compare:fuel.stringDate] == NSOrderedSame)) && [[formater1 stringFromDate:fuel.stringDate] isEqualToString:currentyear])
                    {
                        [datavalue addObject: fuel];
                    }
                }
                
            }
            
            else
            {
                for(T_Fuelcons *fuel in datavaluefilter)
                {
                    if((([last90thday compare:fuel.stringDate] == NSOrderedAscending && [today compare:fuel.stringDate] == NSOrderedDescending) || ([last90thday compare:fuel.stringDate] == NSOrderedSame) || ([today compare:fuel.stringDate] == NSOrderedSame)) && [[formater1 stringFromDate:fuel.stringDate] isEqualToString:[formater1 stringFromDate:lastYear]])
                    {
                        [datavalue addObject: fuel];
                    }
                }
            }
            
            //To display dates
            
            NSDateFormatter *formater2=[[NSDateFormatter alloc] init];
            [formater2 setDateFormat:@"dd-MM-yyyy"];
            NSString *last90thDay = [formater2 stringFromDate:last90thday];
            self.fromLabel.hidden = NO;
            self.fromTextField.text = last90thDay;
            self.fromTextField.textColor = [UIColor whiteColor];
            self.toLabel.hidden = NO;
            self.toTextField.text = [formater2 stringFromDate:today1];
            self.toTextField.textColor = [UIColor whiteColor];
            
        }
        else if([filterstring isEqualToString:NSLocalizedString(@"report_schedule_0",@"Weekly")]){
            
            NSDateFormatter *formater=[[NSDateFormatter alloc] init];
            [formater setDateFormat:@"dd MM yyyy"];
            
            //7th day
            NSCalendar *calendar = [NSCalendar currentCalendar];
            NSDateComponents *components = [calendar components:NSCalendarUnitMonth|NSCalendarUnitDay fromDate:[NSDate date]];
            
            NSDate *today = [[NSDate alloc] init];
            NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
            [offsetComponents setDay:-6];
            NSDate *last7thday = [gregorian dateByAddingComponents:offsetComponents toDate:today options:0];
            
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
                for(T_Fuelcons *fuel in datavaluefilter)
                {
                    
                    if((([last7thday compare:fuel.stringDate] == NSOrderedAscending && [today compare:fuel.stringDate] == NSOrderedDescending) || ([last7thday compare:fuel.stringDate] == NSOrderedSame) || ([today compare:fuel.stringDate] == NSOrderedSame)) && [[formater1 stringFromDate:fuel.stringDate] isEqualToString:currentyear])
                    {
                        [datavalue addObject: fuel];
                    }
                }
                
            }
            
            else
            {
                for(T_Fuelcons *fuel in datavaluefilter)
                {
                    if((([last7thday compare:fuel.stringDate] == NSOrderedAscending && [today compare:fuel.stringDate] == NSOrderedDescending) || ([last7thday compare:fuel.stringDate] == NSOrderedSame) || ([today compare:fuel.stringDate] == NSOrderedSame)) && [[formater1 stringFromDate:fuel.stringDate] isEqualToString:[formater1 stringFromDate:lastYear]])
                    {
                        [datavalue addObject: fuel];
                    }
                }
            }
            
            NSDateFormatter *formater2=[[NSDateFormatter alloc] init];
            [formater2 setDateFormat:@"dd-MM-yyyy"];
            NSString *last7thDay = [formater2 stringFromDate:last7thday];
            fromText = last7thDay;
            toText = [formater2 stringFromDate:today1];
        }
        
        else if([filterstring isEqualToString:NSLocalizedString(@"report_date_range_4",@"This year")])
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
            //To display dates
            
            NSDate *today = [[NSDate alloc] init];
            NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            
            NSDateComponents *components = [gregorian components:NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitYear fromDate:today];
            components.day = 1;
            components.month = 1;
            NSDate *dayOneInCurrentMonth = [gregorian dateFromComponents:components];
            NSDateFormatter *formater2=[[NSDateFormatter alloc] init];
            [formater2 setDateFormat:@"dd-MM-yyyy"];
            NSString *currentMonth = [formater2 stringFromDate:dayOneInCurrentMonth];
            self.fromLabel.hidden = NO;
            self.fromTextField.text = currentMonth;
            fromText = currentMonth;
            self.fromTextField.textColor = [UIColor whiteColor];
            
            
            self.toLabel.hidden = NO;
            self.toTextField.text = [formater2 stringFromDate:today];
            toText = [formater2 stringFromDate:today];
            self.toTextField.textColor = [UIColor whiteColor];
            
            
            
        }
        else if([filterstring isEqualToString:NSLocalizedString(@"report_date_range_5",@"Last year")])
        {
            NSDateFormatter *formater=[[NSDateFormatter alloc] init];
            [formater setDateFormat:@"yyyy"];
            
            NSDate *today = [[NSDate alloc] init];
            NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
            [offsetComponents setYear:-1];
            NSDate *lastYear = [gregorian dateByAddingComponents:offsetComponents toDate:today options:0];
            
            for(T_Fuelcons *fuel in datavaluefilter)
            {
                if([[formater stringFromDate:fuel.stringDate] isEqualToString:[formater stringFromDate:lastYear]])
                {
                    [datavalue addObject: fuel];
                    
                }
            }
            
            NSCalendar *calendar1 = [NSCalendar currentCalendar];
            NSDateComponents *comps1 = [NSDateComponents new];
            comps1.year = -1;
            NSDate *date1 = [calendar1 dateByAddingComponents:comps1 toDate:[NSDate date] options:0];
            NSDateComponents *components1 = [gregorian components:NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitYear fromDate:date1];
            components1.day = 1;
            components1.month = 1;
            NSDate *dayOneInLastMonth = [gregorian dateFromComponents:components1];
            NSDateFormatter *formater2=[[NSDateFormatter alloc] init];
            [formater2 setDateFormat:@"dd-MM-yyyy"];
            NSString *firstDaylastMonth = [formater2 stringFromDate:dayOneInLastMonth];
            
            self.fromLabel.hidden = NO;
            self.fromTextField.text = firstDaylastMonth;
            self.fromTextField.textColor = [UIColor whiteColor];
            
            //to
            NSDateComponents *comps2 = [NSDateComponents new];
            comps2.year = -1;
            NSDate *date2 = [calendar1 dateByAddingComponents:comps2 toDate:[NSDate date] options:0];
            NSDateComponents *components2 = [gregorian components:NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitYear fromDate:date2];
            components2.day = 31;
            components2.month = 12;
            NSDate *lastDayOfLastMonth = [gregorian dateFromComponents:components2];
            [formater2 setDateFormat:@"dd-MM-yyyy"];
            NSString *lastDaylastMonth = [formater2 stringFromDate:lastDayOfLastMonth];
            self.toLabel.hidden = NO;
            self.toTextField.text = lastDaylastMonth;
            self.toTextField.textColor = [UIColor whiteColor];
            
            
            
        }
        else
        {
            //Custom dates
            NSDateFormatter *formater=[[NSDateFormatter alloc] init];
            [formater setDateFormat:@"dd-MM-yyyy"];
            for(T_Fuelcons *fuel in datavaluefilter)
            {
                if(([[formater dateFromString:self.startdate.text] compare:[formater dateFromString:[formater stringFromDate:fuel.stringDate]]] == NSOrderedAscending && [[formater dateFromString:self.enddate.text] compare:[formater dateFromString:[formater stringFromDate:fuel.stringDate]]] == NSOrderedDescending) || ([[formater dateFromString:self.startdate.text] compare:[formater dateFromString:[formater stringFromDate:fuel.stringDate]]] == NSOrderedSame) || ([[formater dateFromString:self.enddate.text] compare:[formater dateFromString:[formater stringFromDate:fuel.stringDate]]] == NSOrderedSame))
                {
                    
                    [datavalue addObject: fuel];
                    
                    
                }
            }
            
            self.fromLabel.hidden = NO;
            self.fromTextField.text = self.startdate.text;
            self.fromTextField.textColor = [UIColor whiteColor];
            
            self.toLabel.hidden = NO;
            self.toTextField.text = self.enddate.text;
            self.toTextField.textColor = [UIColor whiteColor];
        }
        
        [dataArray addObject:datavalue];
       
    }
    else if([vehicleMake isEqualToString:NSLocalizedString(@"all", @"All")] && [vehicleModel isEqualToString:NSLocalizedString(@"veh_tv", @"Vehicles")]){
        
       for (Veh_Table *vehicles in vehArray){
            
            //T_Fuelcons for all vehicles
            NSError *err;
            NSString *compareString = [NSString stringWithFormat:@"%@",vehicles.iD];
            NSFetchRequest *request=[[NSFetchRequest alloc] initWithEntityName:@"T_Fuelcons"];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"vehid==%@",compareString];
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"odo" ascending:YES];
            NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
            [request setPredicate:predicate];
            [request setSortDescriptors:sortDescriptors];
            
            NSArray *datavaluefilter = [[NSArray alloc]init];
            NSMutableArray *datavalue= [[NSMutableArray alloc]init];
            datavaluefilter =[self.context  executeFetchRequest:request error:&err];
            
            
            NSDateFormatter *Uniformater=[[NSDateFormatter alloc] init];
            [Uniformater setDateFormat:@"dd MMM yyyy"];
            NSDateFormatter *formaterMON=[[NSDateFormatter alloc] init];
            [formaterMON setDateFormat:@"MMM"];
            
            
            if([filterstring isEqualToString:NSLocalizedString(@"report_date_range_0",@"All Time")])
            {
                
                datavalue = [[NSMutableArray alloc]initWithArray:datavaluefilter];
                NSDateFormatter *formater2=[[NSDateFormatter alloc] init];
                [formater2 setDateFormat:@"dd-MM-yyyy"];
                
                NSMutableArray *FuelArray = [datavalue firstObject];
                NSDate *minDate = [FuelArray valueForKey:@"stringDate"];
                if([compareDate compare:minDate] == NSOrderedDescending)
                {
                    compareDate = minDate;
                }
                
                NSString *startDateString = [formater2 stringFromDate:compareDate];
                
                self.fromTextField.text = startDateString;
                self.fromLabel.hidden = NO;
                self.fromTextField.textColor = [UIColor whiteColor];
                self.toLabel.hidden = NO;
                NSDate *today1 = [[NSDate alloc] init];
                self.toTextField.text = [formater2 stringFromDate:today1];
                toText = [formater2 stringFromDate:today1];
                self.toTextField.textColor = [UIColor whiteColor];
                
            }
            
            else if([filterstring isEqualToString:NSLocalizedString(@"report_date_range_1",@"This month")] || [filterstring isEqualToString:NSLocalizedString(@"report_schedule_1",@"Monthly")])
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
                NSDate *today = [[NSDate alloc] init];
                NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
                
                NSDateComponents *components = [gregorian components:NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitYear fromDate:today];
                components.day = 1;
                NSDate *dayOneInCurrentMonth = [gregorian dateFromComponents:components];
                NSDateFormatter *formater2=[[NSDateFormatter alloc] init];
                [formater2 setDateFormat:@"dd-MM-yyyy"];
                NSString *currentMonth = [formater2 stringFromDate:dayOneInCurrentMonth];
                self.fromLabel.hidden = NO;
                self.fromTextField.text = currentMonth;
                fromText = currentMonth;
                self.fromTextField.textColor = [UIColor whiteColor];
                self.toLabel.hidden = NO;
                NSDate *today1 = [[NSDate alloc] init];
                self.toTextField.text = [formater2 stringFromDate:today1];
                toText = [formater2 stringFromDate:today1];
                self.toTextField.textColor = [UIColor whiteColor];
            }
            
            else if([filterstring isEqualToString:NSLocalizedString(@"report_date_range_2",@"Last month")])
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
                
                
                if(components.month!=12)
                {
                    for(T_Fuelcons *fuel in datavaluefilter)
                    {
                        
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
                //from
                NSCalendar *calendar1 = [NSCalendar currentCalendar];
                NSDateComponents *comps1 = [NSDateComponents new];
                comps1.month = -1;
                comps1.day   = 1;
                NSDate *date1 = [calendar1 dateByAddingComponents:comps1 toDate:[NSDate date] options:0];
                NSDateComponents *components1 = [gregorian components:NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitYear fromDate:date1];
                components1.day = 1;
                NSDate *dayOneInLastMonth = [gregorian dateFromComponents:components1];
                NSDateFormatter *formater2=[[NSDateFormatter alloc] init];
                [formater2 setDateFormat:@"dd-MM-yyyy"];
                NSString *firstDaylastMonth = [formater2 stringFromDate:dayOneInLastMonth];
                
                self.fromLabel.hidden = NO;
                self.fromTextField.text = firstDaylastMonth;
                self.fromTextField.textColor = [UIColor whiteColor];
                
                //to
                NSDateComponents *comps2 = [NSDateComponents new];
                comps2.month = -1;
                comps2.day   = 1;
                NSDate *date2 = [calendar1 dateByAddingComponents:comps2 toDate:[NSDate date] options:0];
                NSDateComponents *components2 = [gregorian components:NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitYear fromDate:date2];
                NSRange range = [gregorian rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date1];
                NSUInteger numberOfDaysInMonth = range.length;
                components2.day = numberOfDaysInMonth;
                NSDate *lastDayOfLastMonth = [gregorian dateFromComponents:components2];
                [formater2 setDateFormat:@"dd-MM-yyyy"];
                NSString *lastDaylastMonth = [formater2 stringFromDate:lastDayOfLastMonth];
                self.toLabel.hidden = NO;
                self.toTextField.text = lastDaylastMonth;
                self.toTextField.textColor = [UIColor whiteColor];
                
                
                
            }
            else if ([filterstring isEqualToString:NSLocalizedString(@"report_date_range_3",@"Last 90 days")]){
                
                NSDateFormatter *formater=[[NSDateFormatter alloc] init];
                [formater setDateFormat:@"dd MM yyyy"];
                
                //3rd Month
                NSCalendar *calendar = [NSCalendar currentCalendar];
                NSDateComponents *components = [calendar components:NSCalendarUnitMonth|NSCalendarUnitDay fromDate:[NSDate date]];
                
                NSDate *today = [[NSDate alloc] init];
                NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
                NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
                [offsetComponents setDay:-90];
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
                    for(T_Fuelcons *fuel in datavaluefilter)
                    {
                        
                        if((([last90thday compare:fuel.stringDate] == NSOrderedAscending && [today compare:fuel.stringDate] == NSOrderedDescending) || ([last90thday compare:fuel.stringDate] == NSOrderedSame) || ([today compare:fuel.stringDate] == NSOrderedSame)) && [[formater1 stringFromDate:fuel.stringDate] isEqualToString:currentyear])
                        {
                            [datavalue addObject: fuel];
                        }
                    }
                    
                }
                
                else
                {
                    for(T_Fuelcons *fuel in datavaluefilter)
                    {
                        if((([last90thday compare:fuel.stringDate] == NSOrderedAscending && [today compare:fuel.stringDate] == NSOrderedDescending) || ([last90thday compare:fuel.stringDate] == NSOrderedSame) || ([today compare:fuel.stringDate] == NSOrderedSame)) && [[formater1 stringFromDate:fuel.stringDate] isEqualToString:[formater1 stringFromDate:lastYear]])
                        {
                            [datavalue addObject: fuel];
                        }
                    }
                }
                
                //To display dates
                
                NSDateFormatter *formater2=[[NSDateFormatter alloc] init];
                [formater2 setDateFormat:@"dd-MM-yyyy"];
                NSString *last90thDay = [formater2 stringFromDate:last90thday];
                self.fromLabel.hidden = NO;
                self.fromTextField.text = last90thDay;
                self.fromTextField.textColor = [UIColor whiteColor];
                self.toLabel.hidden = NO;
                self.toTextField.text = [formater2 stringFromDate:today1];
                self.toTextField.textColor = [UIColor whiteColor];
                
            }
            else if([filterstring isEqualToString:NSLocalizedString(@"report_schedule_0",@"Weekly")]){
                
                NSDateFormatter *formater=[[NSDateFormatter alloc] init];
                [formater setDateFormat:@"dd MM yyyy"];
                
                //7th day
                NSCalendar *calendar = [NSCalendar currentCalendar];
                NSDateComponents *components = [calendar components:NSCalendarUnitMonth|NSCalendarUnitDay fromDate:[NSDate date]];
                
                NSDate *today = [[NSDate alloc] init];
                NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
                NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
                [offsetComponents setDay:-6];
                NSDate *last7thday = [gregorian dateByAddingComponents:offsetComponents toDate:today options:0];
                
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
                    for(T_Fuelcons *fuel in datavaluefilter)
                    {
                        
                        if((([last7thday compare:fuel.stringDate] == NSOrderedAscending && [today compare:fuel.stringDate] == NSOrderedDescending) || ([last7thday compare:fuel.stringDate] == NSOrderedSame) || ([today compare:fuel.stringDate] == NSOrderedSame)) && [[formater1 stringFromDate:fuel.stringDate] isEqualToString:currentyear])
                        {
                            [datavalue addObject: fuel];
                        }
                    }
                    
                }
                
                else
                {
                    for(T_Fuelcons *fuel in datavaluefilter)
                    {
                        if((([last7thday compare:fuel.stringDate] == NSOrderedAscending && [today compare:fuel.stringDate] == NSOrderedDescending) || ([last7thday compare:fuel.stringDate] == NSOrderedSame) || ([today compare:fuel.stringDate] == NSOrderedSame)) && [[formater1 stringFromDate:fuel.stringDate] isEqualToString:[formater1 stringFromDate:lastYear]])
                        {
                            [datavalue addObject: fuel];
                        }
                    }
                }
                
                NSDateFormatter *formater2=[[NSDateFormatter alloc] init];
                [formater2 setDateFormat:@"dd-MM-yyyy"];
                NSString *last7thDay = [formater2 stringFromDate:last7thday];
                fromText = last7thDay;
                toText = [formater2 stringFromDate:today1];
            }
            
            else if([filterstring isEqualToString:NSLocalizedString(@"report_date_range_4",@"This year")])
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
                //To display dates
                
                NSDate *today = [[NSDate alloc] init];
                NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
                
                NSDateComponents *components = [gregorian components:NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitYear fromDate:today];
                components.day = 1;
                components.month = 1;
                NSDate *dayOneInCurrentMonth = [gregorian dateFromComponents:components];
                NSDateFormatter *formater2=[[NSDateFormatter alloc] init];
                [formater2 setDateFormat:@"dd-MM-yyyy"];
                NSString *currentMonth = [formater2 stringFromDate:dayOneInCurrentMonth];
                self.fromLabel.hidden = NO;
                self.fromTextField.text = currentMonth;
                fromText = currentMonth;
                self.fromTextField.textColor = [UIColor whiteColor];
                
                
                self.toLabel.hidden = NO;
                self.toTextField.text = [formater2 stringFromDate:today];
                toText = [formater2 stringFromDate:today];
                self.toTextField.textColor = [UIColor whiteColor];
                
                
                
            }
            else if([filterstring isEqualToString:NSLocalizedString(@"report_date_range_5",@"Last year")])
            {
                NSDateFormatter *formater=[[NSDateFormatter alloc] init];
                [formater setDateFormat:@"yyyy"];
                
                NSDate *today = [[NSDate alloc] init];
                NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
                NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
                [offsetComponents setYear:-1];
                NSDate *lastYear = [gregorian dateByAddingComponents:offsetComponents toDate:today options:0];
                
                for(T_Fuelcons *fuel in datavaluefilter)
                {
                    if([[formater stringFromDate:fuel.stringDate] isEqualToString:[formater stringFromDate:lastYear]])
                    {
                        [datavalue addObject: fuel];
                        
                    }
                }
                
                NSCalendar *calendar1 = [NSCalendar currentCalendar];
                NSDateComponents *comps1 = [NSDateComponents new];
                comps1.year = -1;
                NSDate *date1 = [calendar1 dateByAddingComponents:comps1 toDate:[NSDate date] options:0];
                NSDateComponents *components1 = [gregorian components:NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitYear fromDate:date1];
                components1.day = 1;
                components1.month = 1;
                NSDate *dayOneInLastMonth = [gregorian dateFromComponents:components1];
                NSDateFormatter *formater2=[[NSDateFormatter alloc] init];
                [formater2 setDateFormat:@"dd-MM-yyyy"];
                NSString *firstDaylastMonth = [formater2 stringFromDate:dayOneInLastMonth];
                
                self.fromLabel.hidden = NO;
                self.fromTextField.text = firstDaylastMonth;
                self.fromTextField.textColor = [UIColor whiteColor];
                
                //to
                NSDateComponents *comps2 = [NSDateComponents new];
                comps2.year = -1;
                NSDate *date2 = [calendar1 dateByAddingComponents:comps2 toDate:[NSDate date] options:0];
                NSDateComponents *components2 = [gregorian components:NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitYear fromDate:date2];
                components2.day = 31;
                components2.month = 12;
                NSDate *lastDayOfLastMonth = [gregorian dateFromComponents:components2];
                [formater2 setDateFormat:@"dd-MM-yyyy"];
                NSString *lastDaylastMonth = [formater2 stringFromDate:lastDayOfLastMonth];
                self.toLabel.hidden = NO;
                self.toTextField.text = lastDaylastMonth;
                self.toTextField.textColor = [UIColor whiteColor];
                
                
                
            }
            else
            {
                //Custom dates
                NSDateFormatter *formater=[[NSDateFormatter alloc] init];
                [formater setDateFormat:@"dd-MM-yyyy"];
                for(T_Fuelcons *fuel in datavaluefilter)
                {
                    if(([[formater dateFromString:self.startdate.text] compare:[formater dateFromString:[formater stringFromDate:fuel.stringDate]]] == NSOrderedAscending && [[formater dateFromString:self.enddate.text] compare:[formater dateFromString:[formater stringFromDate:fuel.stringDate]]] == NSOrderedDescending) || ([[formater dateFromString:self.startdate.text] compare:[formater dateFromString:[formater stringFromDate:fuel.stringDate]]] == NSOrderedSame) || ([[formater dateFromString:self.enddate.text] compare:[formater dateFromString:[formater stringFromDate:fuel.stringDate]]] == NSOrderedSame))
                    {
                        
                        [datavalue addObject: fuel];
                        
                        
                    }
                }
                
                self.fromLabel.hidden = NO;
                self.fromTextField.text = self.startdate.text;
                self.fromTextField.textColor = [UIColor whiteColor];
                
                self.toLabel.hidden = NO;
                self.toTextField.text = self.enddate.text;
                self.toTextField.textColor = [UIColor whiteColor];
            }
            
            [dataArray addObject:datavalue];
            
            
        }
    }
    
    [self fetchTripStats:filterstring];
}

-(void)fetchTripStats:(NSString*) filterString
{

    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSManagedObjectContext *vehContext = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSError *vehError;
    
    NSFetchRequest *vehreq = [[NSFetchRequest alloc] initWithEntityName:@"Veh_Table"];
    NSArray *vehArray = [vehContext executeFetchRequest:vehreq error:&vehError];
    BOOL autoReport = [def boolForKey:@"sendAutoReport"];
    NSNumber *selectedVehicleID;
    if(autoReport){
        
        selectedVehicleID = [def objectForKey:@"autoVehicleId"];
    }else{
        
        selectedVehicleID = [def objectForKey:@"vehicleId"];
    }
    
    NSString *vehicleMake = [[NSString alloc]init];
    NSString *vehicleModel = [[NSString alloc]init];
    for(NSArray *currentRecord in self.vehiclearray){
        
        if([selectedVehicleID isEqual:[currentRecord valueForKey:@"Id"]]){
            
            vehicleMake = [NSString stringWithFormat:@"%@",[currentRecord valueForKey:@"Make"]];
            vehicleModel = [NSString stringWithFormat:@"%@",[currentRecord valueForKey:@"Model"]];
        }
    }
    if(![vehicleMake isEqualToString:NSLocalizedString(@"all", @"All")] && ![vehicleModel isEqualToString:NSLocalizedString(@"veh_tv", @"Vehicles")]){
        
        //T_Trip selected vehicle
        NSError *err;
        NSString *compareString;
        if(autoReport){
            compareString = [NSString stringWithFormat:@"%@",[def objectForKey:@"autoVehicleId"]];
        }else{
            compareString = [NSString stringWithFormat:@"%@",[def objectForKey:@"vehicleId"]];
        }
        
        NSFetchRequest *request=[[NSFetchRequest alloc] initWithEntityName:@"T_Trip"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"tripComplete == 1 AND vehId = %@", compareString];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"depOdo" ascending:YES];
        
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
        [request setPredicate:predicate];
        [request setSortDescriptors:sortDescriptors];
        
        NSArray *datavaluefilter = [[NSArray alloc]init];
        NSMutableArray *datavalue= [[NSMutableArray alloc]init];
        datavaluefilter =[self.context  executeFetchRequest:request error:&err];
        
        NSDateFormatter *Uniformater=[[NSDateFormatter alloc] init];
        [Uniformater setDateFormat:@"dd MMM yyyy"];
        NSDateFormatter *formaterMON=[[NSDateFormatter alloc] init];
        [formaterMON setDateFormat:@"MMM"];
        
        if([filterString isEqualToString:NSLocalizedString(@"report_date_range_0",@"All Time")])
        {
            datavalue = [[NSMutableArray alloc]initWithArray:datavaluefilter];
        }
        else if([filterString isEqualToString:NSLocalizedString(@"report_date_range_1",@"This month")] || [filterString isEqualToString:NSLocalizedString(@"report_schedule_1",@"Monthly")])
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
        
        else if([filterString isEqualToString:NSLocalizedString(@"report_date_range_2",@"Last month")])
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
            
            if(components.month!=12)
            {
                for(T_Trip *trip in datavaluefilter)
                {
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
        else if ([filterString isEqualToString:NSLocalizedString(@"report_date_range_3",@"Last 90 days")]){
            
            NSDateFormatter *formater=[[NSDateFormatter alloc] init];
            [formater setDateFormat:@"dd MM yyyy"];
            
            //3rd Month
            NSCalendar *calendar = [NSCalendar currentCalendar];
            NSDateComponents *components = [calendar components:NSCalendarUnitMonth|NSCalendarUnitDay fromDate:[NSDate date]];
            
            NSDate *today = [[NSDate alloc] init];
            NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
            [offsetComponents setDay:-90];
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
                for(T_Trip *trip in datavaluefilter)
                {
                    if((([last90thday compare:trip.depDate] == NSOrderedAscending && [today compare:trip.depDate] == NSOrderedDescending) || ([last90thday compare:trip.depDate] == NSOrderedSame) || ([today compare:trip.depDate] == NSOrderedSame)) && [[formater1 stringFromDate:trip.depDate] isEqualToString:currentyear])
                    {
                        [datavalue addObject: trip];
                    }
                }
                
            }
            
            else
            {
                for(T_Trip *trip in datavaluefilter)
                {
                    if((([last90thday compare:trip.depDate] == NSOrderedAscending && [today compare:trip.depDate] == NSOrderedDescending) || ([last90thday compare:trip.depDate] == NSOrderedSame) || ([today compare:trip.depDate] == NSOrderedSame)) && [[formater1 stringFromDate:trip.depDate] isEqualToString:[formater1 stringFromDate:lastYear]])
                    {
                        [datavalue addObject: trip];
                    }
                }
            }
            
        }
        else if ([filterString isEqualToString:NSLocalizedString(@"report_schedule_0",@"Weekly")]){
            
            NSDateFormatter *formater=[[NSDateFormatter alloc] init];
            [formater setDateFormat:@"dd MM yyyy"];
            
            //7th Day
            NSCalendar *calendar = [NSCalendar currentCalendar];
            NSDateComponents *components = [calendar components:NSCalendarUnitMonth|NSCalendarUnitDay fromDate:[NSDate date]];
            
            NSDate *today = [[NSDate alloc] init];
            NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
            [offsetComponents setDay:-6];
            NSDate *last7thday = [gregorian dateByAddingComponents:offsetComponents toDate:today options:0];
            
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
                for(T_Trip *trip in datavaluefilter)
                {
                    if((([last7thday compare:trip.depDate] == NSOrderedAscending && [today compare:trip.depDate] == NSOrderedDescending) || ([last7thday compare:trip.depDate] == NSOrderedSame) || ([today compare:trip.depDate] == NSOrderedSame)) && [[formater1 stringFromDate:trip.depDate] isEqualToString:currentyear])
                    {
                        [datavalue addObject: trip];
                    }
                }
                
            }
            
            else
            {
                for(T_Trip *trip in datavaluefilter)
                {
                    if((([last7thday compare:trip.depDate] == NSOrderedAscending && [today compare:trip.depDate] == NSOrderedDescending) || ([last7thday compare:trip.depDate] == NSOrderedSame) || ([today compare:trip.depDate] == NSOrderedSame)) && [[formater1 stringFromDate:trip.depDate] isEqualToString:[formater1 stringFromDate:lastYear]])
                    {
                        [datavalue addObject: trip];
                    }
                }
            }
            
        }
        else if([filterString isEqualToString:NSLocalizedString(@"report_date_range_3",@"This year")])
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
        else if([filterString isEqualToString:NSLocalizedString(@"report_date_range_5",@"Last year")])
        {
            
            NSDateFormatter *formater=[[NSDateFormatter alloc] init];
            [formater setDateFormat:@"yyyy"];
            
            NSDate *today = [[NSDate alloc] init];
            NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
            [offsetComponents setYear:-1];
            NSDate *lastYear = [gregorian dateByAddingComponents:offsetComponents toDate:today options:0];
            
            for(T_Trip *trip in datavaluefilter)
            {
                if([[formater stringFromDate:trip.depDate] isEqualToString:[formater stringFromDate:lastYear]])
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
        
        [allTripDataArray addObject:datavalue];
        
    }
    else if([vehicleMake isEqualToString:NSLocalizedString(@"all", @"All")] && [vehicleModel isEqualToString:NSLocalizedString(@"veh_tv", @"Vehicles")]){
        
        for (Veh_Table *vehicles in vehArray) {
            
            //T_Trip for all vehicles
            NSError *err;
            NSString *compareString = [NSString stringWithFormat:@"%@",vehicles.iD];
            
            NSFetchRequest *request=[[NSFetchRequest alloc] initWithEntityName:@"T_Trip"];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"tripComplete == 1 AND vehId = %@", compareString];
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"depOdo" ascending:YES];
            
            NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
            [request setPredicate:predicate];
            [request setSortDescriptors:sortDescriptors];
            
            NSArray *datavaluefilter = [[NSArray alloc]init];
            NSMutableArray *datavalue= [[NSMutableArray alloc]init];
            datavaluefilter =[self.context  executeFetchRequest:request error:&err];
            
            NSDateFormatter *Uniformater=[[NSDateFormatter alloc] init];
            [Uniformater setDateFormat:@"dd MMM yyyy"];
            NSDateFormatter *formaterMON=[[NSDateFormatter alloc] init];
            [formaterMON setDateFormat:@"MMM"];
            
            if([filterString isEqualToString:NSLocalizedString(@"report_date_range_0",@"All Time")])
            {
                datavalue = [[NSMutableArray alloc]initWithArray:datavaluefilter];
            }
            else if([filterString isEqualToString:NSLocalizedString(@"report_date_range_1",@"This month")] || [filterString isEqualToString:NSLocalizedString(@"report_schedule_1",@"Monthly")])
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
            
            else if([filterString isEqualToString:NSLocalizedString(@"report_date_range_2",@"Last month")])
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
                
                if(components.month!=12)
                {
                    for(T_Trip *trip in datavaluefilter)
                    {
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
            else if ([filterString isEqualToString:NSLocalizedString(@"report_date_range_3",@"Last 90 days")]){
                
                NSDateFormatter *formater=[[NSDateFormatter alloc] init];
                [formater setDateFormat:@"dd MM yyyy"];
                
                //3rd Month
                NSCalendar *calendar = [NSCalendar currentCalendar];
                NSDateComponents *components = [calendar components:NSCalendarUnitMonth|NSCalendarUnitDay fromDate:[NSDate date]];
                
                NSDate *today = [[NSDate alloc] init];
                NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
                NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
                [offsetComponents setDay:-90];
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
                    for(T_Trip *trip in datavaluefilter)
                    {
                        if((([last90thday compare:trip.depDate] == NSOrderedAscending && [today compare:trip.depDate] == NSOrderedDescending) || ([last90thday compare:trip.depDate] == NSOrderedSame) || ([today compare:trip.depDate] == NSOrderedSame)) && [[formater1 stringFromDate:trip.depDate] isEqualToString:currentyear])
                        {
                            [datavalue addObject: trip];
                        }
                    }
                    
                }
                
                else
                {
                    for(T_Trip *trip in datavaluefilter)
                    {
                        if((([last90thday compare:trip.depDate] == NSOrderedAscending && [today compare:trip.depDate] == NSOrderedDescending) || ([last90thday compare:trip.depDate] == NSOrderedSame) || ([today compare:trip.depDate] == NSOrderedSame)) && [[formater1 stringFromDate:trip.depDate] isEqualToString:[formater1 stringFromDate:lastYear]])
                        {
                            [datavalue addObject: trip];
                        }
                    }
                }
                
            }
            else if ([filterString isEqualToString:NSLocalizedString(@"report_schedule_0",@"Weekly")]){
                
                NSDateFormatter *formater=[[NSDateFormatter alloc] init];
                [formater setDateFormat:@"dd MM yyyy"];
                
                //7th Day
                NSCalendar *calendar = [NSCalendar currentCalendar];
                NSDateComponents *components = [calendar components:NSCalendarUnitMonth|NSCalendarUnitDay fromDate:[NSDate date]];
                
                NSDate *today = [[NSDate alloc] init];
                NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
                NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
                [offsetComponents setDay:-6];
                NSDate *last7thday = [gregorian dateByAddingComponents:offsetComponents toDate:today options:0];
                
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
                    for(T_Trip *trip in datavaluefilter)
                    {
                        if((([last7thday compare:trip.depDate] == NSOrderedAscending && [today compare:trip.depDate] == NSOrderedDescending) || ([last7thday compare:trip.depDate] == NSOrderedSame) || ([today compare:trip.depDate] == NSOrderedSame)) && [[formater1 stringFromDate:trip.depDate] isEqualToString:currentyear])
                        {
                            [datavalue addObject: trip];
                        }
                    }
                    
                }
                
                else
                {
                    for(T_Trip *trip in datavaluefilter)
                    {
                        if((([last7thday compare:trip.depDate] == NSOrderedAscending && [today compare:trip.depDate] == NSOrderedDescending) || ([last7thday compare:trip.depDate] == NSOrderedSame) || ([today compare:trip.depDate] == NSOrderedSame)) && [[formater1 stringFromDate:trip.depDate] isEqualToString:[formater1 stringFromDate:lastYear]])
                        {
                            [datavalue addObject: trip];
                        }
                    }
                }
                
            }
            else if([filterString isEqualToString:NSLocalizedString(@"report_date_range_3",@"This year")])
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
            else if([filterString isEqualToString:NSLocalizedString(@"report_date_range_5",@"Last year")])
            {
                
                NSDateFormatter *formater=[[NSDateFormatter alloc] init];
                [formater setDateFormat:@"yyyy"];
                
                NSDate *today = [[NSDate alloc] init];
                NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
                NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
                [offsetComponents setYear:-1];
                NSDate *lastYear = [gregorian dateByAddingComponents:offsetComponents toDate:today options:0];
                
                for(T_Trip *trip in datavaluefilter)
                {
                    if([[formater stringFromDate:trip.depDate] isEqualToString:[formater stringFromDate:lastYear]])
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
            
            [allTripDataArray addObject:datavalue];
            
        }
    }
    
    [self separteData];
    
}

#pragma mark pickerView Delegate methods
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
        
        return self.timePickerArray.count;
    }
    else
        return 0;
    
}


- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if(pickerView.tag==-8)
    {
        NSDictionary *dictionary = [[NSDictionary alloc]init];
        dictionary = [self.vehiclearray objectAtIndex:row];
        return [NSString stringWithFormat:@"%@ %@",[dictionary objectForKey:@"Make"],[dictionary objectForKey:@"Model"]];
    }
    
    if(pickerView.tag==-4)
    {
        NSString *currentType = [[NSString alloc]init];
        currentType = [self.timePickerArray objectAtIndex:row];
        return currentType;
    }
    else
        
        return 0;
    
    
}


-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    _selPickerRow = (int)[pickerView selectedRowInComponent:0];
    NSUserDefaults *setRowValue = [NSUserDefaults standardUserDefaults];
    [setRowValue setInteger:_selPickerRow forKey:@"rowValue"];
}

-(void)showAlert:(NSString *)title :(NSString *) message{
    
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
    [_picker selectRow:self.vehiclearray.count-1 inComponent:0 animated:NO];
    
    self.pickerval = @"Select";
    
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
    [_setbutton addTarget:self action:@selector(setVehicle) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_setbutton];
    
}

-(void)setVehicle
{
    [dataArray removeAllObjects];
    [allTripDataArray removeAllObjects];
    [fillUpDataArray removeAllObjects];
    [serviceDataArray removeAllObjects];
    [expenseDataArray removeAllObjects];
    [tripDataArray removeAllObjects];
    [receiptsArray removeAllObjects];
    NSUserDefaults *def =[NSUserDefaults standardUserDefaults];
    [self.picker removeFromSuperview];
    [self.setbutton removeFromSuperview];
    NSDictionary *dictionary = [[NSDictionary alloc]init];
    dictionary = [self.vehiclearray objectAtIndex:[self.picker selectedRowInComponent:0]];
    
    [def setObject:[dictionary objectForKey:@"Id"] forKey:@"vehicleId"];
    
    if(![[dictionary objectForKey:@"Make"] isEqualToString:NSLocalizedString(@"all", @"All")] && ![[dictionary objectForKey:@"Model"] isEqualToString:NSLocalizedString(@"veh_tv", @"Vehicles")]){
        
        if([[dictionary objectForKey:@"Picture"] isEqualToString:@""])
        {
            self.vehicleImage.image=[UIImage imageNamed:@"car4.jpg"];
        }
        
        else
        {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            
            NSString *urlstring = [paths firstObject];
            
            NSString *vehiclepic = [NSString stringWithFormat:@"%@/%@",urlstring,[dictionary objectForKey:@"Picture"]];
            self.vehicleImage.image =[UIImage imageWithContentsOfFile:vehiclepic];
        }
    }
    
    self.vehicleName.text = [NSString stringWithFormat:@"%@ %@",[dictionary objectForKey:@"Make"],[dictionary objectForKey:@"Model"]];
    
    
    timePressed = NO;
    
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
    
    NSMutableDictionary *lastDictionary = [[NSMutableDictionary alloc]init];
    [lastDictionary setObject:NSLocalizedString(@"all", @"All") forKey:@"Make"];
    [lastDictionary setObject:NSLocalizedString(@"veh_tv", @"Vehicles") forKey:@"Model"];
    [lastDictionary setObject:@"" forKey:@"Picture"];
    NSNumber *vehId = 0;
    for(NSArray *currentVehicleID in self.vehiclearray){
        
        if(vehId < [currentVehicleID valueForKey:@"Id"]){
            
            vehId = [currentVehicleID valueForKey:@"Id"];
        }
        
    }
    double vehID = [vehId doubleValue]+1;
    [lastDictionary setValue:[NSNumber numberWithDouble:vehID] forKey:@"Id"];
    [self.vehiclearray addObject:lastDictionary];
    //NSLog(@"self.vehiclearray:- %@",self.vehiclearray);
}

- (IBAction)vehicleDropDownClick:(UIButton *)sender {
    
    [self openVehiclePicker];
}

- (IBAction)vehicleClick:(UIButton *)sender {
    
    [self openVehiclePicker];
}


- (IBAction)timeSelectButton:(UIButton *)sender {
    
    [self openUnitPicker];
}

- (IBAction)timeDropDownButton:(UIButton *)sender {
    
    [self openUnitPicker];
}

- (IBAction)includeRawButton:(UIButton *)sender {
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"isAdDisabled"]){
       
        if(sender.selected == YES){
           
            sender.selected = NO;
            self.fileTypeLabel.textColor = [UIColor darkGrayColor];
            self.pdfLabel.textColor = [UIColor darkGrayColor];
            self.csvLabel.textColor = [UIColor darkGrayColor];
            self.pdfOutlet.selected = NO;
            [self.pdfOutlet setImage:[UIImage imageNamed:@"uncheck"] forState:UIControlStateNormal];
            pdfValue = NO;
            rawValue = NO;
            
        }else{
            
            sender.selected = YES;
            self.fileTypeLabel.textColor = [UIColor lightGrayColor];
            self.pdfLabel.textColor = [UIColor lightGrayColor];
            self.csvLabel.textColor = [UIColor lightGrayColor];
            self.pdfOutlet.selected = YES;
            [self.pdfOutlet setImage:[UIImage imageNamed:@"checkmark01"] forState:UIControlStateSelected];
            pdfValue = YES;
            rawValue = YES;
        }
        [self.includeRawOutlet setImage:[UIImage imageNamed:@"check"] forState:UIControlStateSelected];
        [self.includeRawOutlet setImage:[UIImage imageNamed:@"uncheck"] forState:UIControlStateNormal];
        
        
    }else{
        
        [self goProAlertBox];
        
    }
    
}

- (void)goProAlertBox{
    
    NSString *title = NSLocalizedString(@"upgrade", @"Upgrade");
    NSString *message = NSLocalizedString(@"upgrade_gp_err", @"To attach raw data and csv files please purchase an upgrade");
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:title
                                          message:message
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"cancel", @"Cancel action")
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       
                                       [self.includeRawOutlet setImage:[UIImage imageNamed:@"uncheck"] forState:UIControlStateNormal];
                                       [self.includeRawOutlet setSelected:NO];
                                       
                                   }];
    
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
    
    [alertController addAction:cancelAction];
    [alertController addAction:goproAction];
    
    
    [self presentViewController:alertController animated:YES completion:nil];
    
    
}


- (IBAction)PDFButton:(UIButton *)sender {
    
    if(rawValue){
        
        if(sender.selected == YES){
            sender.selected = NO;
            pdfValue = NO;
            csvValue = YES;
            
        }else{
            
            sender.selected = YES;
            pdfValue = YES;
            csvValue = NO;
            self.csvOutlet.selected = NO;
            [self.csvOutlet setImage:[UIImage imageNamed:@"uncheck"] forState:UIControlStateNormal];
        }
        [self.pdfOutlet setImage:[UIImage imageNamed:@"checkmark01"] forState:UIControlStateSelected];
        [self.pdfOutlet setImage:[UIImage imageNamed:@"uncheck"] forState:UIControlStateNormal];
        
    }
    
}

- (IBAction)CSVButton:(UIButton *)sender {
    
    if(rawValue){
        
        if(sender.selected == YES){
            sender.selected = NO;
            pdfValue = YES;
            csvValue = NO;
            
        }else{
            
            sender.selected = YES;
            pdfValue = NO;
            csvValue = YES;
            self.pdfOutlet.selected = NO;
            [self.pdfOutlet setImage:[UIImage imageNamed:@"uncheck"] forState:UIControlStateNormal];
        }
        [self.csvOutlet setImage:[UIImage imageNamed:@"checkmark01"] forState:UIControlStateSelected];
        [self.csvOutlet setImage:[UIImage imageNamed:@"uncheck"] forState:UIControlStateNormal];
        
    }
    
}

- (IBAction)includeReceiptButton:(UIButton *)sender {
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"isAdDisabled"]){
        
        if(sender.selected == YES){
            sender.selected = NO;
            includeReceipt = NO;
        }else{
            
            sender.selected = YES;
            includeReceipt = YES;
        }
        [self.includeReceiptOutlet setImage:[UIImage imageNamed:@"check"] forState:UIControlStateSelected];
        [self.includeReceiptOutlet setImage:[UIImage imageNamed:@"uncheck"] forState:UIControlStateNormal];
        
        
    }else{
        
        [self goProAlertBox];
        
    }
}
- (IBAction)generateReportButton:(UIButton *)sender {
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    if([previousEmailString isEqualToString:self.emailTextField.text]){
        validEmail = YES;
    }
    if(validEmail){
       
        [def setObject:self.emailTextField.text forKey:@"toSendEmail"];
        if(!timePressed){
            [self fetchvalue:NSLocalizedString(@"report_date_range_0",@"All Time")];
            timePressed = YES;
        }
        [self startProgressHUD:NSLocalizedString(@"generating_email", @"Generating email")];
        emailText = self.emailTextField.text;
        fromText = self.fromTextField.text;
        toText = self.toTextField.text;
        [self performSelectorInBackground:@selector(callEmailBody) withObject:nil];
        
    }else{
        
        NSString *message = NSLocalizedString(@"enter_valid_email",@"Please enter proper email address");
        NSString *title = NSLocalizedString(@"invalid_email",@"Invalid Email");
        [self showAlert:title :message];
    }
    
}

-(void)callEmailBody{
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    emailText = [def objectForKey:@"toSendEmail"];
    BOOL autoCsv = [def boolForKey:@"autoCsvValue"];
    BOOL autoPdf = [def boolForKey:@"autoPdfValue"];
    BOOL autoReceipt = [def boolForKey:@"autoIncludeReceiptValue"];
    BOOL autoReport = [def boolForKey:@"sendAutoReport"];
    
    if(!autoReport){
        
        autoCsv = NO;
        autoPdf = NO;
        autoReceipt = NO;
    }
    
    if(csvValue || autoCsv){
        
        if(!autoReport){
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [self startProgressHUD:NSLocalizedString(@"generating_csv", @"Generating CSV")];
            });
        }
        
        
        [self sendVehicleData];
        
        if(sendSuccess){
            
            sendSuccess = NO;
            [self sendFillUpData];
            [self sendServiceData];
            [self sendExpenseData];
            [self sendTripData];
            [self sendCompletedYes];
            
        }else{
            
            NSString *message = NSLocalizedString(@"error_report", @"Error generating report");
            NSString *title = @"";
            
            if(!autoReport){
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showAlert:title :message];
                });
            }
        }
        
    }else if(pdfValue || autoPdf){
        
        if(!autoReport){
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [self startProgressHUD:NSLocalizedString(@"generating_pdf", @"Generating PDF")];
            });
        }
        
        
        [self sendVehicleData];
        [self sendFillUpData];
        [self sendServiceData];
        [self sendExpenseData];
        [self sendTripData];
        [self sendPDF];
        
    }
    
    
    if(includeReceipt || autoReceipt){
        
        if(!autoReport){
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [self startProgressHUD:NSLocalizedString(@"generating_receipts", @"Generating receipts")];
            });
            
        }
        
        if(csvValue || pdfValue || autoCsv || autoPdf){
            
            if(sendSuccess){
                
                if([def objectForKey:@"UserEmail"] != nil){
                    
                    [self sendReceipts];
                }else{
                    
                    NSString *finalString = [[NSString alloc]init];
                    finalString = [self getImagesString];
                    [self sendImageData:finalString];
                    
                }
                
                
            }else{
                
                NSString *message = NSLocalizedString(@"error_report", @"Error generating report");
                NSString *title = @"";
                if(!autoReport){
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self showAlert:title :message];
                    });
                }
                
            }
            
        }else{
            
            if([def objectForKey:@"UserEmail"] != nil){
                
                [self sendReceipts];
            }else{
                
                NSString *finalString = [[NSString alloc]init];
                finalString = [self getImagesString];
                [self sendImageData:finalString];
                
            }
            
        }
    }
    
    if(!autoReport){
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [self startProgressHUD:NSLocalizedString(@"generating_graphs", @"Generating graphs")];
        });
    }
    
    if(csvValue || pdfValue || autoCsv || autoPdf){
        
        [self sendGraphs];
        [self sendEmailBodyWithReminders];
        
    }else{
        
        [self sendVehicleData];
        [self sendFillUpData];
        [self sendServiceData];
        [self sendExpenseData];
        [self sendTripData];
        [self sendGraphs];
        [self sendEmailBodyWithReminders];
        
    }
    
    
}


#pragma mark Data sending methods


-(void)separteData{
    
    for(NSArray *logArray in dataArray){
        
        for(T_Fuelcons *logData in logArray){
            
            if([logData.type isEqual:@0]){
                
                [fillUpDataArray addObject:logData];
                
                if(logData.receipt != nil && ![logData.receipt isEqualToString:@""]){
                    
                    [receiptsArray addObject:logData];
                }
               
            }else if ([logData.type isEqual:@1]){
                
                [serviceDataArray addObject:logData];
                
                if(logData.receipt != nil && ![logData.receipt isEqualToString:@""]){
                    
                    [receiptsArray addObject:logData];
                }
                
            }else if ([logData.type isEqual:@2]){
                
                [expenseDataArray addObject:logData];
                
                if(logData.receipt != nil && ![logData.receipt isEqualToString:@""]){
                    
                    [receiptsArray addObject:logData];
                }
                
            }
        }
    }
    
    for(NSArray *tripArray in allTripDataArray){
        
        for(T_Trip *tripData in tripArray){
            
           [tripDataArray addObject:tripData];
        }
    }
    
}

-(void)sendVehicleData{
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *sendDict = [[NSMutableDictionary alloc] init];
    NSString *email = emailText;
    [sendDict setObject:email forKey:@"email"];
    [sendDict setObject:@"Vehicles" forKey:@"csv_type"];
    [sendDict setObject:@"no" forKey:@"completed"];
    
    NSManagedObjectContext *contex = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSFetchRequest *request=[[NSFetchRequest alloc] initWithEntityName:@"Veh_Table"];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"iD"
                                                                   ascending:YES];
    NSError *err1;
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptors];
    
    NSArray *vehicle=[contex executeFetchRequest:request error:&err1];
    
    NSMutableArray *allResults = [[NSMutableArray alloc] init];
    NSMutableArray *copyResults;
    
    if(vehicle != nil){
        
        NSArray *firstrow = [[NSArray alloc] initWithObjects:NSLocalizedString(@"vehicle", @"Vehicle"),NSLocalizedString(@"make_tv", @"Make"),NSLocalizedString(@"model_tv", @"Model"),NSLocalizedString(@"year", @"Year"),NSLocalizedString(@"vin", @"VIN"),NSLocalizedString(@"lic_no_tv", @"Licence No."),NSLocalizedString(@"insurance_no", @"Insurance #"),NSLocalizedString(@"notes_tv", @"Notes"),NSLocalizedString(@"specification_tv", @"Specifications"),nil];
        
        copyResults = [[NSMutableArray alloc] initWithArray:firstrow copyItems:YES];
        [allResults addObject:copyResults];
        
        for(Veh_Table *veh in vehicle)
        {
            NSString *VehicleName = [NSString stringWithFormat:@"%@ %@",veh.make,veh.model];
            [vehNameArray addObject:VehicleName];
            NSMutableArray *results = [NSMutableArray new];
            
            if(VehicleName != nil){
                [results addObject:VehicleName];
            }else{
                [results addObject:@""];
            }
            if(veh.make != nil){
                [results addObject:[NSString stringWithFormat:@"%@", veh.make]];
            }else{
                [results addObject:@""];
            }
            if(veh.model != nil){
                [results addObject:[NSString stringWithFormat:@"%@", veh.model]];
            }else{
                [results addObject:@""];
            }
            if(veh.year != nil){
                [results addObject:[NSString stringWithFormat:@"%@", veh.year]];
            }else{
                [results addObject:@""];
            }
            if(veh.lic != nil){
                [results addObject:[NSString stringWithFormat:@"%@", veh.lic]];
            }else{
                [results addObject:@""];
            }
            if(veh.vin != nil){
                [results addObject:[NSString stringWithFormat:@"%@", veh.vin]];
            }else{
                [results addObject:@""];
            }
            if(veh.insuranceNo != nil){
                [results addObject:[NSString stringWithFormat:@"%@", veh.insuranceNo]];
            }else{
                [results addObject:@""];
            }
            if(veh.notes != nil){
                [results addObject:[NSString stringWithFormat:@"%@", veh.notes]];
            }else{
                [results addObject:@""];
            }
            if(veh.customSpecs != nil){
                [results addObject:[NSString stringWithFormat:@"%@", veh.customSpecs]];
            }else{
                [results addObject:@""];
            }
            
            copyResults = [[NSMutableArray alloc] initWithArray:results copyItems:YES];
            [allResults addObject:copyResults];
        }
        [sendDict setObject:allResults forKey:@"data"];
        vehiclePDFDict = [sendDict mutableCopy];
        
    }else{
        
        NSString *message = NSLocalizedString(@"no_veh_id", @"No Vehicle Found");
        NSString *title = @"";
        
        BOOL autoReport = [def boolForKey:@"sendAutoReport"];
        if(!autoReport){
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showAlert:title :message];
            });
        }
    }
    
    BOOL autoCSV = [def boolForKey:@"autoCsvValue"];
    BOOL autoReport = [def boolForKey:@"sendAutoReport"];
    
    if(!autoReport){
        
        autoCSV = NO;
    }
    if(csvValue || autoCSV){
        
        NSData *postData = [NSJSONSerialization dataWithJSONObject:sendDict options:NSJSONWritingPrettyPrinted error:&err1];
        commonMethods *common = [[commonMethods alloc] init];
        [def setBool:NO forKey:@"updateTimeStamp"];
        [common saveToCloud:postData urlString:kReportCSVScript success:^(NSDictionary *responseDict) {
            
            //NSLog(@"veh CSV Response:- %@", responseDict);
            sendSuccess = YES;
            
        } failure:^(NSError *error) {
            
            //NSLog(@"Error:- %@",err1.localizedDescription);
            
        }];
        
    }
    
}

-(void)sendFillUpData{
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *sendDict = [[NSMutableDictionary alloc] init];
    NSString *email = emailText;
    [sendDict setObject:email forKey:@"email"];
    [sendDict setObject:@"Fill-ups" forKey:@"csv_type"];
    [sendDict setObject:@"no" forKey:@"completed"];
    
    NSMutableArray *allResults = [[NSMutableArray alloc] init];
    NSMutableArray *copyResults;

    NSArray *firstrow = [[NSArray alloc] initWithObjects:NSLocalizedString(@"vehicle", @"Vehicle"),NSLocalizedString(@"date", @"Date"),NSLocalizedString(@"odometer", @"Odometer"),NSLocalizedString(@"dist_tv", @"Distance"),NSLocalizedString(@"qty_tv", @"Quantity"),NSLocalizedString(@"tc_tv", @"Total Cost"),NSLocalizedString(@"fuel_tv", @"Fuel Efficiency"),NSLocalizedString(@"pf_tv", @"Partial Tank"),NSLocalizedString(@"mf_tv", @"Missed fill up"),NSLocalizedString(@"fs_tv", @"Filling Station"),NSLocalizedString(@"fb_tv", @"Fuel Brand"),NSLocalizedString(@"octane", @"Octane"),NSLocalizedString(@"notes_tv", @"Notes"),NSLocalizedString(@"receipt", @"Receipt"),NSLocalizedString(@"record_type", @"Record Type"),nil];
    
    copyResults = [[NSMutableArray alloc] initWithArray:firstrow copyItems:YES];
    [allResults addObject:copyResults];
    
    for(T_Fuelcons *fillUpData in fillUpDataArray)
    {
        NSString *vehicleName = [[NSString alloc]init];
        for(NSArray *currentRecord in self.vehiclearray){
            
            if([fillUpData.vehid isEqualToString:[NSString stringWithFormat:@"%@",[currentRecord valueForKey:@"Id"]]]){
                
                vehicleName = [NSString stringWithFormat:@"%@ %@",[currentRecord valueForKey:@"Make"],[currentRecord valueForKey:@"Model"]];
            }
        }
            NSMutableArray *results = [NSMutableArray new];
            
            if(vehicleName != nil){
                [results addObject:vehicleName];
            }else{
                [results addObject:@""];
            }
            
            if(fillUpData.stringDate != nil){
                [results addObject:[NSString stringWithFormat:@"%@", fillUpData.stringDate]];
            }else{
                [results addObject:@""];
            }
            
            if(fillUpData.odo != nil){
                [results addObject:[NSString stringWithFormat:@"%@", fillUpData.odo]];
            }else{
                [results addObject:@""];
            }
            
            if(fillUpData.dist != nil){
                [results addObject:[NSString stringWithFormat:@"%@", fillUpData.dist]];
            }else{
                [results addObject:@""];
            }
            
            if(fillUpData.qty != nil){
                [results addObject:[NSString stringWithFormat:@"%@", fillUpData.qty]];
            }else{
                [results addObject:@""];
            }
            
            if(fillUpData.cost != nil){
                [results addObject:[NSString stringWithFormat:@"%@", fillUpData.cost]];
            }else{
                [results addObject:@""];
            }
            
            if(fillUpData.cons != nil){
                [results addObject:[NSString stringWithFormat:@"%@", fillUpData.cons]];
            }else{
                [results addObject:@""];
            }
            
            if(fillUpData.pfill != nil){
                [results addObject:[NSString stringWithFormat:@"%@", fillUpData.pfill]];
            }else{
                [results addObject:@""];
            }
            
            if(fillUpData.mfill != nil){
                [results addObject:[NSString stringWithFormat:@"%@", fillUpData.mfill]];
            }else{
                [results addObject:@""];
            }
            
            if(fillUpData.fillStation != nil){
                [results addObject:[NSString stringWithFormat:@"%@", fillUpData.fillStation]];
            }else{
                [results addObject:@""];
            }
            
            if(fillUpData.fuelBrand != nil){
                [results addObject:[NSString stringWithFormat:@"%@", fillUpData.fuelBrand]];
            }else{
                [results addObject:@""];
            }
            
            if(fillUpData.octane != nil){
                [results addObject:[NSString stringWithFormat:@"%@", fillUpData.octane]];
            }else{
                [results addObject:@""];
            }
            
            if(fillUpData.notes != nil){
                [results addObject:[NSString stringWithFormat:@"%@", fillUpData.notes]];
            }else{
                [results addObject:@""];
            }
            
            if(fillUpData.receipt != nil){
                [results addObject:[NSString stringWithFormat:@"%@", fillUpData.receipt]];
            }else{
                [results addObject:@""];
            }
            
            if(fillUpData.type != nil){
                [results addObject:[NSString stringWithFormat:@"%@", fillUpData.type]];
            }else{
                [results addObject:@""];
            }

        [allResults addObject: results];
    }
    
    [sendDict setObject:allResults forKey:@"data"];
    fillUpPDFDict = [sendDict mutableCopy];
    NSArray *data = [sendDict objectForKey:@"data"];
    
    BOOL autoCSV = [def boolForKey:@"autoCsvValue"];
    BOOL autoReport = [def boolForKey:@"sendAutoReport"];
    
    if(!autoReport){
        
        autoCSV = NO;
    }
    if((csvValue || autoCSV) && data.count>1){
        
        NSError *err1;
        NSData *postData = [NSJSONSerialization dataWithJSONObject:sendDict options:NSJSONWritingPrettyPrinted error:&err1];
        commonMethods *common = [[commonMethods alloc] init];
        [def setBool:NO forKey:@"updateTimeStamp"];
        [common saveToCloud:postData urlString:kReportCSVScript success:^(NSDictionary *responseDict) {
            
            //NSLog(@"fill-up CSV Response:- %@", responseDict);
            
        } failure:^(NSError *error) {
            
           // NSLog(@"Error:- %@",err1.localizedDescription);
            
        }];
        
    }
    
}

-(void)sendServiceData{
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *sendDict = [[NSMutableDictionary alloc] init];
    NSString *email = emailText;
    [sendDict setObject:email forKey:@"email"];
    [sendDict setObject:@"Services" forKey:@"csv_type"];
    [sendDict setObject:@"no" forKey:@"completed"];
    
    NSMutableArray *allResults = [[NSMutableArray alloc] init];
    NSMutableArray *copyResults;
    
    NSArray *firstrow = [[NSArray alloc] initWithObjects:NSLocalizedString(@"tot_services", @"Services"),NSLocalizedString(@"vehicle", @"Vehicle"),NSLocalizedString(@"date", @"Date"),NSLocalizedString(@"odometer", @"Odometer"),NSLocalizedString(@"tc_tv", @"Total Cost"),NSLocalizedString(@"Vendor", @"Vendor"),NSLocalizedString(@"notes_tv", @"Notes"),NSLocalizedString(@"receipt", @"Receipt"),nil];
    
    copyResults = [[NSMutableArray alloc] initWithArray:firstrow copyItems:YES];
    [allResults addObject:copyResults];

    
    for(T_Fuelcons *serviceData in serviceDataArray)
    {
        NSString *vehicleName = [[NSString alloc]init];
        for(NSArray *currentRecord in self.vehiclearray){
            
            if([serviceData.vehid isEqualToString:[NSString stringWithFormat:@"%@",[currentRecord valueForKey:@"Id"]]]){
                
                vehicleName = [NSString stringWithFormat:@"%@ %@",[currentRecord valueForKey:@"Make"],[currentRecord valueForKey:@"Model"]];
            }
        }
        NSMutableArray *results = [NSMutableArray new];
        
        if(serviceData.serviceType != nil){
            NSString *allServices = serviceData.serviceType;
            NSString *colonString = [allServices stringByReplacingOccurrencesOfString:@"," withString:@":::"];
            [results addObject:[NSString stringWithFormat:@"%@", colonString]];
        }else{
            [results addObject:@""];
        }
        
        if(vehicleName != nil){
            [results addObject:vehicleName];
        }else{
            [results addObject:@""];
        }
        
        if(serviceData.stringDate != nil){
            [results addObject:[NSString stringWithFormat:@"%@", serviceData.stringDate]];
        }else{
            [results addObject:@""];
        }
        
        if(serviceData.odo != nil){
            [results addObject:[NSString stringWithFormat:@"%@", serviceData.odo]];
        }else{
            [results addObject:@""];
        }
        
        if(serviceData.cost != nil){
            [results addObject:[NSString stringWithFormat:@"%@", serviceData.cost]];
        }else{
            [results addObject:@""];
        }
        
        if(serviceData.fillStation != nil){
            [results addObject:[NSString stringWithFormat:@"%@", serviceData.fillStation]];
        }else{
            [results addObject:@""];
        }
        
        if(serviceData.notes != nil){
            [results addObject:[NSString stringWithFormat:@"%@", serviceData.notes]];
        }else{
            [results addObject:@""];
        }
        
        if(serviceData.receipt != nil){
            [results addObject:[NSString stringWithFormat:@"%@", serviceData.receipt]];
        }else{
            [results addObject:@""];
        }
        
        [allResults addObject: results];
    }
    
    [sendDict setObject:allResults forKey:@"data"];
    servicePDFDict = [sendDict mutableCopy];
    NSArray *data = [sendDict objectForKey:@"data"];
    
    BOOL autoCSV = [def boolForKey:@"autoCsvValue"];
    BOOL autoReport = [def boolForKey:@"sendAutoReport"];
    
    if(!autoReport){
        
        autoCSV = NO;
    }
    if((csvValue || autoCSV) && data.count>1){
        
        NSError *err1;
        NSData *postData = [NSJSONSerialization dataWithJSONObject:sendDict options:NSJSONWritingPrettyPrinted error:&err1];
        commonMethods *common = [[commonMethods alloc] init];
        [def setBool:NO forKey:@"updateTimeStamp"];
        [common saveToCloud:postData urlString:kReportCSVScript success:^(NSDictionary *responseDict) {
            
            //NSLog(@"service CSV Response:- %@", responseDict);
            
        } failure:^(NSError *error) {
            
           // NSLog(@"Error:- %@",err1.localizedDescription);
            
        }];
        
    }
    
}

-(void)sendExpenseData{
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *sendDict = [[NSMutableDictionary alloc] init];
    NSString *email = emailText;
    [sendDict setObject:email forKey:@"email"];
    [sendDict setObject:@"Other Expenses" forKey:@"csv_type"];
    [sendDict setObject:@"no" forKey:@"completed"];
    
    NSMutableArray *allResults = [[NSMutableArray alloc] init];
    NSMutableArray *copyResults;
    
    NSArray *firstrow = [[NSArray alloc] initWithObjects:NSLocalizedString(@"tot_expense_cost", @"Other Expenses"),NSLocalizedString(@"vehicle", @"Vehicle"),NSLocalizedString(@"date", @"Date"),NSLocalizedString(@"odometer", @"Odometer"),NSLocalizedString(@"tc_tv", @"Total Cost"),NSLocalizedString(@"Vendor", @"Vendor"),NSLocalizedString(@"notes_tv", @"Notes"),NSLocalizedString(@"receipt", @"Receipt"),nil];
    
    copyResults = [[NSMutableArray alloc] initWithArray:firstrow copyItems:YES];
    [allResults addObject:copyResults];
    
    for(T_Fuelcons *expenseData in expenseDataArray)
    {
        NSString *vehicleName = [[NSString alloc]init];
        for(NSArray *currentRecord in self.vehiclearray){
            
            if([expenseData.vehid isEqualToString:[NSString stringWithFormat:@"%@",[currentRecord valueForKey:@"Id"]]]){
                
                vehicleName = [NSString stringWithFormat:@"%@ %@",[currentRecord valueForKey:@"Make"],[currentRecord valueForKey:@"Model"]];
            }
        }
        NSMutableArray *results = [NSMutableArray new];
        
        if(expenseData.serviceType != nil){
            NSString *allServices = expenseData.serviceType;
            NSString *colonString = [allServices stringByReplacingOccurrencesOfString:@"," withString:@":::"];
            [results addObject:[NSString stringWithFormat:@"%@", colonString]];
        }else{
            [results addObject:@""];
        }
        
        if(vehicleName != nil){
            [results addObject:vehicleName];
        }else{
            [results addObject:@""];
        }
        
        if(expenseData.stringDate != nil){
            [results addObject:[NSString stringWithFormat:@"%@", expenseData.stringDate]];
        }else{
            [results addObject:@""];
        }
        
        if(expenseData.odo != nil){
            [results addObject:[NSString stringWithFormat:@"%@", expenseData.odo]];
        }else{
            [results addObject:@""];
        }
        
        if(expenseData.cost != nil){
            [results addObject:[NSString stringWithFormat:@"%@", expenseData.cost]];
        }else{
            [results addObject:@""];
        }
        
        if(expenseData.fillStation != nil){
            [results addObject:[NSString stringWithFormat:@"%@", expenseData.fillStation]];
        }else{
            [results addObject:@""];
        }
        
        if(expenseData.notes != nil){
            [results addObject:[NSString stringWithFormat:@"%@", expenseData.notes]];
        }else{
            [results addObject:@""];
        }
        
        if(expenseData.receipt != nil){
            [results addObject:[NSString stringWithFormat:@"%@", expenseData.receipt]];
        }else{
            [results addObject:@""];
        }
        
        [allResults addObject: results];
    }
    [sendDict setObject:allResults forKey:@"data"];
    expensePDFDict = [sendDict mutableCopy];
    
    NSArray *data = [sendDict objectForKey:@"data"];
    
    BOOL autoCSV = [def boolForKey:@"autoCsvValue"];
    BOOL autoReport = [def boolForKey:@"sendAutoReport"];
    
    if(!autoReport){
        
        autoCSV = NO;
    }
    if((csvValue || autoCSV) && data.count>1){
        
        NSError *err1;
        NSData *postData = [NSJSONSerialization dataWithJSONObject:sendDict options:NSJSONWritingPrettyPrinted error:&err1];
        commonMethods *common = [[commonMethods alloc] init];
        [def setBool:NO forKey:@"updateTimeStamp"];
        [common saveToCloud:postData urlString:kReportCSVScript success:^(NSDictionary *responseDict) {
            
           // NSLog(@"expense CSV Response:- %@", responseDict);
            
        } failure:^(NSError *error) {
            
           // NSLog(@"Error:- %@",err1.localizedDescription);
            
        }];
    }
    
}

-(void)sendTripData{
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *sendDict = [[NSMutableDictionary alloc] init];
    NSString *email = emailText;
    [sendDict setObject:email forKey:@"email"];
    [sendDict setObject:@"Trips" forKey:@"csv_type"];
    [sendDict setObject:@"no" forKey:@"completed"];
    
    NSMutableArray *allResults = [[NSMutableArray alloc] init];
    NSMutableArray *copyResults;
    
    NSArray *firstrow = [[NSArray alloc] initWithObjects:NSLocalizedString(@"edit_trip_type_hint", @"Trip Type"),NSLocalizedString(@"vehicle", @"Vehicle"),NSLocalizedString(@"dep_date", @"Departure Date"),NSLocalizedString(@"dep_odo", @"Departure Odo"),NSLocalizedString(@"dep_loc", @"Departure Loc"),NSLocalizedString(@"arr_date", @"Arrival Date"),NSLocalizedString(@"arr_odo", @"Arrival Odo"),NSLocalizedString(@"arr_loc", @"Arrival Loc"),NSLocalizedString(@"dist_traveled", @"Distance Traveled"),NSLocalizedString(@"time_traveled", @"Time Traveled"),NSLocalizedString(@"parking", @"Parking"),@"Toll",NSLocalizedString(@"tax_deduction_amount", @"Tax Deducted"),NSLocalizedString(@"notes_tv", @"Notes"),nil];
    
    copyResults = [[NSMutableArray alloc] initWithArray:firstrow copyItems:YES];
    [allResults addObject:copyResults];
    
    for(T_Trip *tripData in tripDataArray)
    {
        NSString *vehicleName = [[NSString alloc]init];
        for(NSArray *currentRecord in self.vehiclearray){
            
            if([tripData.vehId isEqualToString:[NSString stringWithFormat:@"%@",[currentRecord valueForKey:@"Id"]]]){
                
                vehicleName = [NSString stringWithFormat:@"%@ %@",[currentRecord valueForKey:@"Make"],[currentRecord valueForKey:@"Model"]];
            }
        }
        NSMutableArray *results = [NSMutableArray new];
        
        if(tripData.tripType != nil){
            [results addObject:[NSString stringWithFormat:@"%@", tripData.tripType]];
        }else{
            [results addObject:@""];
        }
        
        if(vehicleName != nil){
            [results addObject:vehicleName];
        }else{
            [results addObject:@""];
        }
        
        if(tripData.depDate != nil){
            [results addObject:[NSString stringWithFormat:@"%@", tripData.depDate]];
        }else{
            [results addObject:@""];
        }
        
        if(tripData.depOdo != nil){
            [results addObject:[NSString stringWithFormat:@"%@", tripData.depOdo]];
        }else{
            [results addObject:@""];
        }
        
        if(tripData.depLocn != nil){
            [results addObject:[NSString stringWithFormat:@"%@", tripData.depLocn]];
        }else{
            [results addObject:@""];
        }
        
        if(tripData.arrDate != nil){
            [results addObject:[NSString stringWithFormat:@"%@", tripData.arrDate]];
        }else{
            [results addObject:@""];
        }
        
        if(tripData.arrOdo != nil){
            [results addObject:[NSString stringWithFormat:@"%@", tripData.arrOdo]];
        }else{
            [results addObject:@""];
        }
        
        if(tripData.arrLocn != nil){
            [results addObject:[NSString stringWithFormat:@"%@", tripData.arrLocn]];
        }else{
            [results addObject:@""];
        }
        
        float distTraveled = [tripData.depOdo floatValue] - [tripData.arrOdo floatValue];
        
        if(distTraveled != 0){
            [results addObject:[NSString stringWithFormat:@"%f", distTraveled]];
        }else{
            [results addObject:@"0"];
        }
        
        NSDate* stDate = tripData.depDate;
        NSDate* endDate = tripData.depDate;
        NSTimeInterval distanceBetweenDates = [endDate timeIntervalSinceDate:stDate];
        
        double secondsInAnHour = 3600;
        NSInteger hours = distanceBetweenDates / secondsInAnHour;
        
        NSString* totalTime = @"";
        NSInteger minutes = (distanceBetweenDates - (hours*3600))/60;
        
        NSString* hr = [NSString stringWithFormat: @"%ld", (long)hours];
        NSString* min = [NSString stringWithFormat: @"%ld", (long)minutes];
        
        totalTime = [[[hr stringByAppendingString:@"h "] stringByAppendingString: min] stringByAppendingString:@"m"] ;
        
        if([totalTime isEqualToString:@"0h 0m"]){
            
            [results addObject:@"0h 0m"];
        }else{
            
            [results addObject:[NSString stringWithFormat:@"%@", totalTime]];
        }
    
        if(tripData.parkingAmt != nil){
            [results addObject:[NSString stringWithFormat:@"%@", tripData.parkingAmt]];
        }else{
            [results addObject:@""];
        }
        
        if(tripData.tollAmt != nil){
            [results addObject:[NSString stringWithFormat:@"%@", tripData.tollAmt]];
        }else{
            [results addObject:@""];
        }
        
        if(tripData.taxDedn != nil){
            [results addObject:[NSString stringWithFormat:@"%@", tripData.taxDedn]];
        }else{
            [results addObject:@""];
        }
        
        if(tripData.notes != nil){
            [results addObject:[NSString stringWithFormat:@"%@", tripData.notes]];
        }else{
            [results addObject:@""];
        }
        
        [allResults addObject: results];
    }
    [sendDict setObject:allResults forKey:@"data"];
    tripPDFDict = [sendDict mutableCopy];
    
    NSArray *data = [sendDict objectForKey:@"data"];
    
    BOOL autoCSV = [def boolForKey:@"autoCsvValue"];
    BOOL autoReport = [def boolForKey:@"sendAutoReport"];
    
    if(!autoReport){
        
        autoCSV = NO;
    }
    if((csvValue || autoCSV) && data.count>1){
        
        NSError *err1;
        NSData *postData = [NSJSONSerialization dataWithJSONObject:sendDict options:NSJSONWritingPrettyPrinted error:&err1];
        commonMethods *common = [[commonMethods alloc] init];
        [def setBool:NO forKey:@"updateTimeStamp"];
        [common saveToCloud:postData urlString:kReportCSVScript success:^(NSDictionary *responseDict) {
            
           // NSLog(@"trip CSV Response:- %@", responseDict);
            
        } failure:^(NSError *error) {
            
           // NSLog(@"Error:- %@",err1.localizedDescription);
            
        }];
        
    }
  
}

-(void)sendCompletedYes{
    
    NSMutableDictionary *sendDict = [[NSMutableDictionary alloc] init];
    NSString *email = emailText;
    [sendDict setObject:email forKey:@"email"];
    [sendDict setObject:@"yes" forKey:@"completed"];
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    
    NSError *err1;
    NSData *postData = [NSJSONSerialization dataWithJSONObject:sendDict options:NSJSONWritingPrettyPrinted error:&err1];
    commonMethods *common = [[commonMethods alloc] init];
    [def setBool:NO forKey:@"updateTimeStamp"];
    [common saveToCloud:postData urlString:kReportCSVScript success:^(NSDictionary *responseDict) {
        
       // NSLog(@"final Response:- %@", responseDict);
        sendSuccess = YES;
        
    } failure:^(NSError *error) {
        
       // NSLog(@"Error:- %@",err1.localizedDescription);
        
    }];
    
}

-(void)sendPDF{
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    
    NSMutableArray *pdfArray = [[NSMutableArray alloc]initWithObjects:vehiclePDFDict,fillUpPDFDict,servicePDFDict,expensePDFDict,tripPDFDict, nil];
    NSArray *dataInFillUpDict = [fillUpPDFDict objectForKey:@"data"];
    NSArray *dataInServiceDict = [servicePDFDict objectForKey:@"data"];
    NSArray *dataInExpenseDict = [expensePDFDict objectForKey:@"data"];
    NSArray *dataInTripDict = [tripPDFDict objectForKey:@"data"];
    
    
    
    if(dataInFillUpDict.count>1 && dataInServiceDict.count>1 && dataInExpenseDict.count>1 && dataInTripDict.count>1){
        
        NSError *err1;
        NSData *postData = [NSJSONSerialization dataWithJSONObject:pdfArray options:NSJSONWritingPrettyPrinted error:&err1];
        commonMethods *common = [[commonMethods alloc] init];
        [def setBool:NO forKey:@"updateTimeStamp"];
        [common saveToCloud:postData urlString:kReportPDFScript success:^(NSDictionary *responseDict) {
            
           // NSLog(@"PDF Response:- %@", responseDict);
            sendSuccess = YES;
            
        } failure:^(NSError *error) {
            
          //  NSLog(@"Error:- %@",err1.localizedDescription);
            
        }];
    }else{
        sendSuccess = YES;
    }
}


-(void)sendReceipts{
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *sendDict = [[NSMutableDictionary alloc]init];
    NSString *email = emailText;
    [sendDict setObject:email forKey:@"email"];
    [sendDict setObject:@"no" forKey:@"continue"];
    [sendDict setObject:@"no" forKey:@"temp"];
    [sendDict setObject:@"" forKey:@"remainingimagename"];
    [sendDict setObject:@"" forKey:@"remainingimage"];
    NSString *finalString = [[NSString alloc]init];
    finalString = [self getImagesString];
   
    [sendDict setObject:finalString forKey:@"receipt"];
    
    if(finalString.length > 0){
        
        NSError *err1;
        NSData *postData = [NSJSONSerialization dataWithJSONObject:sendDict options:NSJSONWritingPrettyPrinted error:&err1];
        commonMethods *common = [[commonMethods alloc] init];
        [def setBool:NO forKey:@"updateTimeStamp"];
        [common saveToCloud:postData urlString:kReportReceiptScript success:^(NSDictionary *responseDict) {
            
          //  NSLog(@"Receipt Response:- %@", responseDict);
            
            if([[responseDict objectForKey:@"message"] isEqualToString:@"image not exist"] && ![[responseDict objectForKey:@"imagenotexist"] isEqualToString:@""]){
                
                NSString *imagenotexist = [responseDict objectForKey:@"imagenotexist"];
                [self sendImageData:imagenotexist];
                
            }
            
            
        } failure:^(NSError *error) {
            
           // NSLog(@"Error:- %@",err1.localizedDescription);
            
        }];
        
    }
    
    
   
}

-(NSString *)getImagesString{
    
    NSString *email = emailText;
    NSString *originalString = [[NSString alloc]init];
    NSString *wholeImageString = [[NSString alloc]init];
    NSString *finalString = [[NSString alloc]init];
    
    for(T_Fuelcons *fillUpData in receiptsArray){
        
        NSArray *originalArray = [fillUpData.receipt componentsSeparatedByString:@":::"];
        
        for(NSString *currentString in originalArray){
            
            originalString = [NSString stringWithFormat:@"%@.%@",email,currentString];
            wholeImageString = [wholeImageString stringByAppendingString:originalString];
            wholeImageString = [wholeImageString stringByAppendingString:@":::"];
            
            if(wholeImageString.length > 0){
                int lastThree =(int)wholeImageString.length-3;
                finalString = [wholeImageString substringToIndex:lastThree];
            }
            
        }
        
    }
    
    return finalString;
}

-(NSString *)contentTypeForImageData:(NSData *)data {
    uint8_t c;
    [data getBytes:&c length:1];
    
    switch (c) {
        case 0xFF:
            return @"jpg";
        case 0x89:
            return @"png";
        case 0x47:
            return @"gif";
        
    }
    return nil;
}

-(void)sendImageData:(NSString *)imagenotexist{
    
   
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *sendDict = [[NSMutableDictionary alloc]init];
    NSString *email = emailText;
    [sendDict setObject:email forKey:@"email"];
    
    NSString *lastColontrimmedString;

    if(imagenotexist.length>3){

        //imagenotexist = [imagenotexist stringByAppendingString:@":::"];
        NSString *lastThreeDigits = [imagenotexist substringFromIndex:imagenotexist.length-3];

        if([lastThreeDigits containsString:@":::"]){

            lastColontrimmedString = [imagenotexist substringToIndex:imagenotexist.length-3];

        }else{
            lastColontrimmedString = imagenotexist;
        }

        NSArray *separatedImages = [lastColontrimmedString componentsSeparatedByString:@":::"];

        for(int i=0;i<separatedImages.count-1;i++){

            [sendDict setObject:@"" forKey:@"receipt"];
            [sendDict setObject:@"yes" forKey:@"continue"];
            [sendDict setObject:@"no" forKey:@"temp"];


            if(![separatedImages[i] isEqualToString:@""]){

                NSString *trimmedString;
                if([separatedImages[i] containsString:@"cac"]){
                    NSRange range = [separatedImages[i] rangeOfString:@"cac"];
                    trimmedString = [separatedImages[i] substringFromIndex:range.location];
                }else{
                    trimmedString = separatedImages[i];
                }


                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *documentsDirectory = [paths firstObject];
                NSString *completeImgPath = [documentsDirectory stringByAppendingString:[NSString stringWithFormat:@"/%@", trimmedString]];

                UIImage *receiptImage = [UIImage imageWithContentsOfFile:completeImgPath];

                NSData *imageData = UIImagePNGRepresentation(receiptImage);

                float imgSizeInMB = [imageData length] / 1024.0f / 1024.0f;

                NSString *imageString;

                //If images are > than 1.5 MB, compress them and then send to server
                if(imgSizeInMB > 1.5){

                    UIImage *smallImg = [[commonMethods class] imageWithImage:receiptImage scaledToSize:CGSizeMake(300.0, 300.0)];
                    NSData *compressedImg = UIImagePNGRepresentation(smallImg);
                    imageString = [compressedImg base64EncodedStringWithOptions:0];

                } else {


                    imageString = [imageData base64EncodedStringWithOptions:0];
                }

                if (imageString != nil) {

                    [sendDict setObject:separatedImages[i] forKey:@"remainingimagename"];
                    [sendDict setObject:imageString forKey:@"remainingimage"];

                    //NSLog(@"Receipts params : %@", sendDict);

                    NSError *err;
                    NSData *postDataArray = [NSJSONSerialization dataWithJSONObject:sendDict options:NSJSONWritingPrettyPrinted error:&err];
                    [def setBool:NO forKey:@"updateTimeStamp"];
                    commonMethods *common = [[commonMethods alloc] init];
                    [common saveToCloud:postDataArray urlString:kReportReceiptScript success:^(NSDictionary *responseDict) {

                        //  NSLog(@"receipt Images Response : %@", responseDict);


                    } failure:^(NSError *error) {

                        //  NSLog(@"failed to get receipt response");
                    }];
                }

            }
        }

        if(![separatedImages.lastObject isEqualToString:@""]){

            [sendDict setObject:@"no" forKey:@"continue"];
            [sendDict setObject:@"yes" forKey:@"temp"];
            [sendDict setObject:imagenotexist forKey:@"receipt"];

            NSString *trimmedString;
            if([separatedImages.lastObject containsString:@"cac"]){
                NSRange range = [separatedImages.lastObject rangeOfString:@"cac"];
                trimmedString = [separatedImages.lastObject substringFromIndex:range.location];
            }else{
                trimmedString = separatedImages.lastObject;
            }


            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths firstObject];
            NSString *completeImgPath = [documentsDirectory stringByAppendingString:[NSString stringWithFormat:@"/%@", trimmedString]];

            UIImage *receiptImage = [UIImage imageWithContentsOfFile:completeImgPath];

            NSData *imageData = UIImagePNGRepresentation(receiptImage);

            float imgSizeInMB = [imageData length] / 1024.0f / 1024.0f;

            NSString *imageString;

            if(imgSizeInMB > 1.5){

                UIImage *smallImg = [[commonMethods class] imageWithImage:receiptImage scaledToSize:CGSizeMake(300.0, 300.0)];
                NSData *compressedImg = UIImagePNGRepresentation(smallImg);
                imageString = [compressedImg base64EncodedStringWithOptions:0];

            } else {


                imageString = [imageData base64EncodedStringWithOptions:0];
            }

            [sendDict setObject:separatedImages.lastObject forKey:@"remainingimagename"];
            if(imageString != nil){

                [sendDict setObject:imageString forKey:@"remainingimage"];
            }else{

                [sendDict setObject:@"" forKey:@"remainingimage"];
            }


            //NSLog(@"Receipts params : %@", sendDict);

            NSError *err;
            NSData *postDataArray = [NSJSONSerialization dataWithJSONObject:sendDict options:NSJSONWritingPrettyPrinted error:&err];
            [def setBool:NO forKey:@"updateTimeStamp"];
            commonMethods *common = [[commonMethods alloc] init];
            [common saveToCloud:postDataArray urlString:kReportReceiptScript success:^(NSDictionary *responseDict) {

                // NSLog(@"receipt Images Response : %@", responseDict);


            } failure:^(NSError *error) {

                //  NSLog(@"failed to get receipt response");
            }];

        }
    }
  
}

-(void)sendGraphs{
    
    NSMutableDictionary *statsDict = [[NSMutableDictionary alloc]init];
    NSMutableDictionary *smallStatsDict = [[NSMutableDictionary alloc]init];
    NSMutableDictionary *sendDict = [[NSMutableDictionary alloc]init];
    NSMutableDictionary *sendSmallDict = [[NSMutableDictionary alloc]init];
    NSString *email = emailText;
    
    
    NSMutableArray *datax = [[NSMutableArray alloc]init];
    NSMutableArray *datay = [[NSMutableArray alloc]init];
    
    for(int i=1;i<=vehNameArray.count;i++){
        
        for(T_Fuelcons *fillUpData in fillUpDataArray)
        {
            if([fillUpData.vehid isEqualToString:[NSString stringWithFormat:@"%d",i]]){
                
                NSString *vehicleName = [[NSString alloc]init];
                for(NSArray *currentRecord in self.vehiclearray){
                    
                    if([fillUpData.vehid isEqualToString:[NSString stringWithFormat:@"%@",[currentRecord valueForKey:@"Id"]]]){
                        
                        vehicleName = [NSString stringWithFormat:@"%@ %@",[currentRecord valueForKey:@"Make"],[currentRecord valueForKey:@"Model"]];
                    }
                }
                [sendDict setObject:vehicleName forKey:@"veh_name"];
                [sendDict setObject:email forKey:@"email"];
                [sendDict setObject:@"Fuel Efficiency" forKey:@"gname"];
                [sendDict setObject:@"FUEL COST ANALYSIS" forKey:@"gtitle"];
                
                NSTimeInterval unixTimeStamp = 0;
                if([fillUpData.cons floatValue]!=0 && fillUpData.cons!=NULL)
                {
                    NSDateFormatter *formater = [[NSDateFormatter alloc] init];
                    [formater setDateFormat:@"dd-MMM-yyyy"];
                    unixTimeStamp = [fillUpData.stringDate timeIntervalSince1970];
                    NSString *dateString = [NSString stringWithFormat:@"%f",unixTimeStamp];
                    NSString *dataXString = [dateString substringToIndex:10];
                    
                    if(dataXString != nil){
                        [datax addObject:dataXString];
                        
                        if([[[NSUserDefaults standardUserDefaults] objectForKey:@"con_unit"] isEqualToString:NSLocalizedString(@"disp_lp100kms", @"L/100km")]){
                            
                            [datay addObject:[NSString stringWithFormat:@"%.2f", 100 / [fillUpData.cons floatValue]]];
                        } else {
                            [datay addObject:[NSString stringWithFormat:@"%.2f",[fillUpData.cons floatValue]]];
                        }
                    }
                    
                    
                    [sendDict setObject:datax forKey:@"datax"];
                    [sendDict setObject:datay forKey:@"datay"];
                    
                }else{
                    [sendDict setObject:@"0" forKey:@"datax"];
                    [sendDict setObject:@"0" forKey:@"datay"];
                }
               
            }
            
        }
        
       
        NSMutableDictionary *copyFuelDict = [[NSMutableDictionary alloc]initWithDictionary:sendDict copyItems:YES];
       // NSMutableDictionary *copystatsDict = [[NSMutableDictionary alloc]initWithDictionary:statsDict copyItems:YES];
        if(copyFuelDict.count > 0){
            [statsDict setObject:copyFuelDict forKey:@"Avg Fuel Eff"];
        }
        
        [sendDict removeAllObjects];
        [datax removeAllObjects];
        [datay removeAllObjects];
        
        NSMutableArray *uniqueTriptypes = [[NSMutableArray alloc]init];
        NSMutableDictionary *sendTripDict = [[NSMutableDictionary alloc]init];
        
        NSNumber *uniqueSum, *taxDedn = 0;
        NSMutableArray *typeDataArray = [[NSMutableArray alloc]init];
     
        for(T_Trip *tripData in tripDataArray){
            
            if([tripData.vehId isEqualToString:[NSString stringWithFormat:@"%d",i]]){
                
                [sendTripDict setObject:email forKey:@"email"];
                [sendTripDict setObject:@"Tax Ded by Trip Type (AUD)" forKey:@"gname"];
                [sendTripDict setObject:@"Trips" forKey:@"gtitle"];
                
                if(![uniqueTriptypes containsObject:tripData.tripType]){
                    
                    [uniqueTriptypes addObject:tripData.tripType];
                    uniqueSum = [NSNumber numberWithFloat:[tripData.taxDedn floatValue]];
                    [typeDataArray addObject:uniqueSum];
                    
                }else{
                    
                    taxDedn = tripData.taxDedn;
                    if(taxDedn != nil){
                        
                        uniqueSum = [NSNumber numberWithFloat:([uniqueSum floatValue] + [tripData.taxDedn floatValue])];
                        NSUInteger indexValue = [uniqueTriptypes indexOfObject:tripData.tripType];
                        [typeDataArray replaceObjectAtIndex:indexValue withObject:uniqueSum];
                        
                    }
                    
                }
                
                //NSLog(@"self.vehiclearray:- %@",self.vehiclearray);
                NSString *vehicleName = [[NSString alloc]init];
                for(NSArray *currentRecord in self.vehiclearray){
                    
                    if([tripData.vehId isEqualToString:[NSString stringWithFormat:@"%@",[currentRecord valueForKey:@"Id"]]]){
                        
                        vehicleName = [NSString stringWithFormat:@"%@ %@",[currentRecord valueForKey:@"Make"],[currentRecord valueForKey:@"Model"]];
                    }
                }
                [sendTripDict setObject:vehicleName forKey:@"veh_name"];
                
                [sendTripDict setObject:typeDataArray forKey:@"data"];
                [sendTripDict setObject:uniqueTriptypes forKey:@"legends"];
     
            }
        }
      
        NSMutableDictionary *copyTripDict = [[NSMutableDictionary alloc]initWithDictionary:sendTripDict copyItems:YES];
        if(copyTripDict.count > 0){
           [statsDict setObject:copyTripDict forKey:@"Trips"];
        }
        
        NSMutableDictionary *copystatsDict = [[NSMutableDictionary alloc]initWithDictionary:statsDict copyItems:YES];
        [statsDict removeAllObjects];
        [sendTripDict removeAllObjects];
        [typeDataArray removeAllObjects];
        [uniqueTriptypes removeAllObjects];
        
        if(copystatsDict.count > 0){
            
            NSError *err;
            NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
            NSData *postDataArray = [NSJSONSerialization dataWithJSONObject:copystatsDict options:NSJSONWritingPrettyPrinted error:&err];
            [def setBool:NO forKey:@"updateTimeStamp"];
            commonMethods *common = [[commonMethods alloc] init];
            [common saveToCloud:postDataArray urlString:kReportBigGraphScript success:^(NSDictionary *responseDict) {
                
              //  NSLog(@"report Big graph Response : %@", responseDict);
                
                
            } failure:^(NSError *error) {
                
              //  NSLog(@"failed to get receipt response");
            }];
            
        }
        
       
        
    }
    
    for(int i=1;i<=vehNameArray.count;i++){
        
        //Avg Price\\Ltr
        for(T_Fuelcons *fillUpData in fillUpDataArray)
        {
            if([fillUpData.vehid isEqualToString:[NSString stringWithFormat:@"%d",i]]){
                
                NSString *vehicleName = [[NSString alloc]init];
                for(NSArray *currentRecord in self.vehiclearray){
                    
                    if([fillUpData.vehid isEqualToString:[NSString stringWithFormat:@"%@",[currentRecord valueForKey:@"Id"]]]){
                        
                        vehicleName = [NSString stringWithFormat:@"%@ %@",[currentRecord valueForKey:@"Make"],[currentRecord valueForKey:@"Model"]];
                    }
                }
                [sendSmallDict setObject:vehicleName forKey:@"veh_name"];
                [sendSmallDict setObject:email forKey:@"email"];
                [sendSmallDict setObject:@"Avg Price\\Ltr" forKey:@"gtitle"];
                
                NSTimeInterval unixTimeStamp = 0;
                if([fillUpData.cost floatValue]!=0 && fillUpData.cost!=NULL)
                {
                    NSDateFormatter *formater = [[NSDateFormatter alloc] init];
                    [formater setDateFormat:@"dd-MMM-yyyy"];
                    unixTimeStamp = [fillUpData.stringDate timeIntervalSince1970];
                    NSString *dateString = [NSString stringWithFormat:@"%f",unixTimeStamp];
                    NSString *dataXString = [dateString substringToIndex:10];
                    
                    if(dataXString != nil){
                        [datax addObject:dataXString];
                        float price = [fillUpData.cost floatValue] /[fillUpData.qty floatValue];
                        [datay addObject:[NSString stringWithFormat:@"%.2f",price]];
                        
                    }
                    [sendSmallDict setObject:datax forKey:@"datax"];
                    [sendSmallDict setObject:datay forKey:@"datay"];
                    
                }else{
                    [sendSmallDict setObject:@"0" forKey:@"datax"];
                    [sendSmallDict setObject:@"0" forKey:@"datay"];
                }
                
            }
            
        }
        
        NSMutableDictionary *copysmallDict = [[NSMutableDictionary alloc]initWithDictionary:sendSmallDict copyItems:YES];
        if(copysmallDict.count > 0){
            [smallStatsDict setObject:copysmallDict forKey:@"Avg Price\\Ltr"];
        }
        NSMutableDictionary *copySmallStatsDict = [[NSMutableDictionary alloc]initWithDictionary:smallStatsDict copyItems:YES];
        
        [smallStatsDict removeAllObjects];
        [sendSmallDict removeAllObjects];
        [datax removeAllObjects];
        [datay removeAllObjects];
        
        if(copySmallStatsDict.count > 0){
            
            NSError *err;
            NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
            NSData *postDataArray = [NSJSONSerialization dataWithJSONObject:copySmallStatsDict options:NSJSONWritingPrettyPrinted error:&err];
            [def setBool:NO forKey:@"updateTimeStamp"];
            commonMethods *common = [[commonMethods alloc] init];
            [common saveToCloud:postDataArray urlString:kReportSmallGraphScript success:^(NSDictionary *responseDict) {
                
              //  NSLog(@"report Small graph Response : %@", responseDict);
                
                
            } failure:^(NSError *error) {
                
              //  NSLog(@"failed to get receipt response");
            }];
            
        }
        
    }
        
}

-(void)sendEmailBodyWithReminders{
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *emailBodyDict = [[NSMutableDictionary alloc]init];
    NSMutableArray *vehicleDataKeyArray = [[NSMutableArray alloc]init];
    NSMutableDictionary *fuelCostAnalysis = [[NSMutableDictionary alloc]init];
    NSMutableDictionary *servicesDict = [[NSMutableDictionary alloc]init];
    NSMutableDictionary *tripsDict = [[NSMutableDictionary alloc]init];
    NSMutableDictionary *allDataDict = [[NSMutableDictionary alloc]init];
    NSString *email = emailText;
    NSString *vehicleName;
    NSString *toSendVehicleNames = [[NSString alloc]init];
    NSDate *compareDate = [NSDate date];
    
    for(int i=1;i<=vehNameArray.count;i++){
        
        float qty=0.0;
        float cost =0.0;
        float dist=0.0;
        float costperdist =0.0, distpercost =0.0;
        float qtyeff =0.0, disteff=0.0;
        int qtyrecord=0;
        float pricepergal =0.0;
        int filluprecord = 0;
        int totalcostrecord =0;
        
        NSString *curr_unit;
        
        NSArray *array = [[[NSUserDefaults standardUserDefaults]objectForKey:@"curr_unit"] componentsSeparatedByString:@"-"];
        NSString *string = [array lastObject];
        curr_unit = string;
        
        NSString *con_unit;
        NSArray *array1 = [[[NSUserDefaults standardUserDefaults]objectForKey:@"con_unit"] componentsSeparatedByString:@" "];
        NSString *string1 = [array1 firstObject];
        con_unit= string1;
        
        
        for(T_Fuelcons *fillUpData in fillUpDataArray)
        {
            if([fillUpData.vehid isEqualToString:[NSString stringWithFormat:@"%d",i]]){
                
                for(NSArray *currentRecord in self.vehiclearray){
                    
                    if([fillUpData.vehid isEqualToString:[NSString stringWithFormat:@"%@",[currentRecord valueForKey:@"Id"]]]){
                        
                        vehicleName = [NSString stringWithFormat:@"%@ %@",[currentRecord valueForKey:@"Make"],[currentRecord valueForKey:@"Model"]];
                    }
                }
                
                [vehicleDataKeyArray addObject:fillUpData];
                
                qty = qty + [fillUpData.qty floatValue];
                cost = cost + [fillUpData.cost floatValue];
                dist = dist + [fillUpData.dist floatValue];
                if([fillUpData.cost floatValue]!=0 && fillUpData.cost!=NULL)
                {
                    pricepergal = pricepergal + [fillUpData.cost floatValue];
                    qtyrecord = qtyrecord+1;
                }
                
                if([fillUpData.dist floatValue]!=0)
                {
                    filluprecord =filluprecord+1;
                }
                
                if([fillUpData.cons floatValue]!=0 && fillUpData.cons!=NULL)
                {
                    qtyeff = qtyeff + [fillUpData.qty floatValue];
                    disteff = disteff + [fillUpData.dist floatValue];
                }
                
                if([fillUpData.qty floatValue] * [fillUpData.cost floatValue]!=0)
                {
                    totalcostrecord =totalcostrecord+1;
                }

                if([fillUpData.dist floatValue]!=0 && [fillUpData.cost floatValue]!=0 && [fillUpData.cons floatValue]!=0 && fillUpData.cons!=NULL && fillUpData.cost!=NULL && fillUpData.dist != NULL)
                {
                    costperdist = costperdist + [fillUpData.cost floatValue];
                    distpercost =distpercost + [fillUpData.dist floatValue];
                }
                
                
            }
            
        }
        
        NSMutableArray *copyVehicleDataKeyArray = [[NSMutableArray alloc]initWithArray:vehicleDataKeyArray];

        NSNumber *totalFillups = [NSNumber numberWithUnsignedInteger: copyVehicleDataKeyArray.count];
        [fuelCostAnalysis setObject:totalFillups forKey:@"Total Fillups"];
        
        NSNumber *totalCost = [NSNumber numberWithFloat:pricepergal];
        [fuelCostAnalysis setObject:totalCost forKey:@"Fuel Cost"];
        
        NSString *aveFuelEff;
        
        float dist_fact= 1;
        float vol_fact =1;

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
        if([con_unit containsString:@"100"])
        {
            double divider = ((disteff *dist_fact)/(qtyeff*vol_fact));
            aveFuelEff = [NSString stringWithFormat:@"%.2f %@",100/divider,con_unit];
            [fuelCostAnalysis setObject:aveFuelEff forKey:@"Avg Fuel Eff"];
            
        }
        //Average Fuel Efficiency
        else
        {
            
            aveFuelEff = [NSString stringWithFormat:@"%.2f %@",(disteff *dist_fact)/(qtyeff*vol_fact),con_unit];
            [fuelCostAnalysis setObject:aveFuelEff forKey:@"Avg Fuel Eff"];
            
        }
        
     
        //Average Price/gal
        if(pricepergal!=0 && qty!=0)
        {
            
            NSString *str1=[NSString stringWithFormat:@"%.3f",(pricepergal/qtyrecord)];
            NSMutableArray *arr1=[[NSMutableArray alloc]init];
            NSArray *arr2=[[NSArray alloc]init];
            
            arr2 = [str1 componentsSeparatedByString:@"."];
            NSString *decimalval1 = [NSString stringWithFormat:@"%@",[arr2 lastObject]];
            
            for(int i=0;i<decimalval1.length;i++)
            {
                [arr1 addObject:[NSString stringWithFormat:@"%c",[decimalval1 characterAtIndex:i]]];
            }
            
            NSString *avePrice;
            if([[arr1 lastObject] intValue]==0 && [[arr1 objectAtIndex:1]intValue]==0 && [[arr1 firstObject]intValue]!=0)
            {
                avePrice = [NSString stringWithFormat:@"%.2f %@",(pricepergal/qty),curr_unit];
                [fuelCostAnalysis setObject:avePrice forKey:@"Avg Price\\Ltr"];
            }
            
            else if([[arr1 firstObject] intValue]==0 && [[arr1 objectAtIndex:1]intValue]==0 && [[arr1 lastObject]intValue]==0)
            {
                avePrice = [NSString stringWithFormat:@"%.2f %@",(pricepergal/qty),curr_unit];
                [fuelCostAnalysis setObject:avePrice forKey:@"Avg Price\\Ltr"];
            }
            
            
            else if([[arr1 lastObject] intValue]==0 && [[arr1 objectAtIndex:1]intValue]!=0)
            {
                avePrice = [NSString stringWithFormat:@"%.2f %@",(pricepergal/qty),curr_unit];
                [fuelCostAnalysis setObject:avePrice forKey:@"Avg Price\\Ltr"];
            }
            
            
            
            else
            {
                avePrice = [NSString stringWithFormat:@"%.3f %@",(pricepergal/qty),curr_unit];
                [fuelCostAnalysis setObject:avePrice forKey:@"Avg Price\\Ltr"];
            }
        }
        
        
        //Fuel Cost per mi
        NSString *costPerMi;
        if(costperdist!=0)
        {
            costPerMi = [NSString stringWithFormat:@"%.2f %@",costperdist/distpercost,curr_unit];
            [fuelCostAnalysis setObject:costPerMi forKey:@"Fuel Cost\\km"];
        }else{
            [fuelCostAnalysis setObject:@(0.0) forKey:@"Fuel Cost\\km"];
        }
        
        //Fuel Cost per day
        NSDate *minDate = [[copyVehicleDataKeyArray firstObject] valueForKey:@"stringDate"];
        NSDate *maxDate = [[copyVehicleDataKeyArray lastObject] valueForKey:@"stringDate"];
        
        NSCalendar *cal = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *comp;
        if(minDate!=nil&&maxDate!=nil){
            comp = [cal components:NSCalendarUnitDay fromDate:minDate toDate:maxDate options:NSCalendarWrapComponents];
        }
        
        NSString *costPerDay;
        if(cost!=0 && comp.day>0)
        {
            costPerDay = [NSString stringWithFormat:@"%.2f %@",cost/(comp.day+1),curr_unit];
            [fuelCostAnalysis setObject:costPerDay forKey:@"Fuel Cost\\Day"];
        }else{
            [fuelCostAnalysis setObject:@(0.0) forKey:@"Fuel Cost\\Day"];
        }
        
        if(vehicleDataKeyArray.count > 0){
            
            NSMutableDictionary *copyfuelCostAnalysis = [[NSMutableDictionary alloc]initWithDictionary:fuelCostAnalysis copyItems:YES];
            if(copyfuelCostAnalysis.count > 0){
                [allDataDict setObject:copyfuelCostAnalysis forKey:@"FUEL COST ANALYSIS"];
            }
            
        }
        
        
        [fuelCostAnalysis removeAllObjects];
        [vehicleDataKeyArray removeAllObjects];
        
        //Services
        float serviceCost = 0.0;
        for(T_Fuelcons *serviceData in serviceDataArray){
            
            if([serviceData.vehid isEqualToString:[NSString stringWithFormat:@"%d",i]]){
                
                for(NSArray *currentRecord in self.vehiclearray){
                    
                    if([serviceData.vehid isEqualToString:[NSString stringWithFormat:@"%@",[currentRecord valueForKey:@"Id"]]]){
                        
                        vehicleName = [NSString stringWithFormat:@"%@ %@",[currentRecord valueForKey:@"Make"],[currentRecord valueForKey:@"Model"]];
                    }
                }
                
                [vehicleDataKeyArray addObject:serviceData];
                if([serviceData.cost floatValue]!=0 && serviceData.cost!=NULL)
                {
                    serviceCost = serviceCost + [serviceData.cost floatValue];
                }
            }
            
        }
        
        NSNumber *totalServices = [NSNumber numberWithInteger:vehicleDataKeyArray.count];
        
        [servicesDict setObject:totalServices forKey:@"Total Services"];
        
        NSNumber *totalServiceCost = [NSNumber numberWithFloat:serviceCost];
        
        [servicesDict setObject:totalServiceCost forKey:@"Total Service Cost"];
        
        float servicedist=0.0;
        T_Fuelcons *maxodoserv = [vehicleDataKeyArray lastObject];
        T_Fuelcons *minodoserv = [vehicleDataKeyArray firstObject];
        
        servicedist = [maxodoserv.odo floatValue]-[minodoserv.odo floatValue];
        
        NSString *serviceCostperKm;
        if(servicedist != 0)
        {
            serviceCostperKm = [NSString stringWithFormat:@"%.2f %@",serviceCost/servicedist,curr_unit];
            [servicesDict setObject:serviceCostperKm forKey:@"Service Cost\\km"];
        }
        
        if(vehicleDataKeyArray.count > 0){
            
            NSMutableDictionary *copyservicesDict = [[NSMutableDictionary alloc]initWithDictionary:servicesDict copyItems:YES];
            if(copyservicesDict.count > 0){
                [allDataDict setObject:copyservicesDict forKey:@"Services"];
            }
            
        }
        
        [vehicleDataKeyArray removeAllObjects];
        [servicesDict removeAllObjects];
        
        //Trips
        float totalTaxDed = 0.0;
        float totalDist = 0.0;
        double tripArrOdo = 0.0;
        double tripDepOdo = 0.0;
        for(T_Trip *tripData in tripDataArray){
            
            if([tripData.vehId isEqualToString:[NSString stringWithFormat:@"%d",i]]){
                
                for(NSArray *currentRecord in self.vehiclearray){
                    
                    if([tripData.vehId isEqualToString:[NSString stringWithFormat:@"%@",[currentRecord valueForKey:@"Id"]]]){
                        
                        vehicleName = [NSString stringWithFormat:@"%@ %@",[currentRecord valueForKey:@"Make"],[currentRecord valueForKey:@"Model"]];
                    }
                }
                
                [vehicleDataKeyArray addObject:tripData];
                if([tripData.taxDedn floatValue]!=0 && tripData.taxDedn!=NULL)
                {
                    totalTaxDed = totalTaxDed + [tripData.taxDedn floatValue];
                    tripArrOdo = [tripData.arrOdo doubleValue];
                    tripDepOdo = [tripData.depOdo doubleValue];
                    totalDist = totalDist + (tripArrOdo-tripDepOdo);
                }
            }
            
        }
        
        NSNumber *totalTrips = [NSNumber numberWithInteger:vehicleDataKeyArray.count];
        
        [tripsDict setObject:totalTrips forKey:@"Total Trips"];
        
        NSNumber *totalTaxDeduc = [NSNumber numberWithFloat:totalTaxDed];
        
        [tripsDict setObject:totalTaxDeduc forKey:@"Total Tax Deduction"];
        
        NSNumber *totalTripDist = [NSNumber numberWithFloat:totalDist];
        
        [tripsDict setObject:totalTripDist forKey:@"Total Trip Distance"];
        
        if(vehicleDataKeyArray.count > 0){
            
            NSMutableDictionary *copytripsDict = [[NSMutableDictionary alloc]initWithDictionary:tripsDict copyItems:YES];
            if(copytripsDict.count > 0){
                [allDataDict setObject:copytripsDict forKey:@"Trips"];
            }
            
        }
        
        [vehicleDataKeyArray removeAllObjects];
        [tripsDict removeAllObjects];
        
        //reminders
        NSMutableDictionary *returnDictionary = [[NSMutableDictionary alloc]init];
        returnDictionary = [self checkRemindersToSend:i];
        
        if(returnDictionary.count>0){
            
            [allDataDict setObject:returnDictionary forKey:@"UPCOMING REMINDERS"];
        }
        
        NSMutableDictionary *copyAllDataDict = [[NSMutableDictionary alloc]initWithDictionary:allDataDict copyItems:YES];
        
        if(copyAllDataDict.count>0){
            
            [emailBodyDict setObject:copyAllDataDict forKey:[NSString stringWithFormat:@"data_%@",vehicleName]];
            
            toSendVehicleNames = [toSendVehicleNames stringByAppendingString:vehicleName];
            toSendVehicleNames = [toSendVehicleNames stringByAppendingString:@":::"];
            [emailBodyDict setObject:toSendVehicleNames forKey:@"veh_names"];
        }
        
        [allDataDict removeAllObjects];
        [servicesDict removeAllObjects];
        [vehicleDataKeyArray removeAllObjects];
        
        if([compareDate compare:minDate] == NSOrderedDescending)
        {
            compareDate = minDate;
        }
    }
    
    if(emailBodyDict.count > 0){
        
        if([timeSelected isEqualToString:NSLocalizedString(@"report_date_range_0", @"All Time")]){
            
            NSDate *startDate = compareDate;
            NSDate *endDate =  [NSDate date];
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"MMM-dd-yyyy"];
            
            NSString *startDateString = [dateFormatter stringFromDate:startDate];
            NSString *endDateString = [dateFormatter stringFromDate:endDate];
            
            [emailBodyDict setObject:startDateString forKey:@"from_date"];
            [emailBodyDict setObject:endDateString forKey:@"to_date"];
            
            
        }else{
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"dd-MM-yyyy"];
            
            NSDate *startDate = [dateFormatter dateFromString:fromText];
            NSDate *endDate =  [dateFormatter dateFromString:toText];
            
            dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"MMM-dd-yyyy"];
            
            NSString *startDateString = [dateFormatter stringFromDate:startDate];
            NSString *endDateString = [dateFormatter stringFromDate:endDate];
            
            [emailBodyDict setObject:startDateString forKey:@"from_date"];
            [emailBodyDict setObject:endDateString forKey:@"to_date"];
            
        }
     
        [emailBodyDict setObject:email forKey:@"email"];
       
        //NSLog(@"emailBodyDict:- %@",emailBodyDict);
        NSError *err;
        NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
        NSData *postDataArray = [NSJSONSerialization dataWithJSONObject:emailBodyDict options:NSJSONWritingPrettyPrinted error:&err];
        [def setBool:NO forKey:@"updateTimeStamp"];
        
        
        commonMethods *common = [[commonMethods alloc] init];
        [common saveToCloud:postDataArray urlString:kReportEmailBodyScript success:^(NSDictionary *responseDict) {
            
            NSLog(@"email body Response : %@", responseDict);
            if([[responseDict objectForKey:@"success"]  isEqual: @1]){
                if(![def boolForKey:@"sendAutoReport"]){
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                        [self showAlert:@"":NSLocalizedString(@"report_success_msg", @"Your report has been emailed")];
                    });
                }
            }else{
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    [self showAlert:@"":NSLocalizedString(@"error_report", @"Error generating report")];
                });
            }
            [vehNameArray removeAllObjects];
            
        } failure:^(NSError *error) {
          
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [self showAlert:@"":NSLocalizedString(@"error_report", @"Error generating report")];
            });
        }];
        
    }else{
        
        
        if(![def boolForKey:@"sendAutoReport"]){
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [self showAlert:@"" :NSLocalizedString(@"no_records_found", @"No records found")]; 
            });
        }
       
    }
}


-(NSMutableDictionary *)checkRemindersToSend:(int )vehID{
    
    NSManagedObjectContext *context = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSError *error;
    NSFetchRequest *vehreq = [[NSFetchRequest alloc] initWithEntityName:@"Services_Table"];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"dueMiles" ascending:NO];
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"dueDays" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor,sortDescriptor1, nil];
    [vehreq setSortDescriptors:sortDescriptors];
    NSArray *serviceArray = [context executeFetchRequest:vehreq error:&error];
    
    NSMutableArray *serviceRecordsArray = [[NSMutableArray alloc]init];
    NSMutableArray *percentArray = [[NSMutableArray alloc]init];
    NSMutableDictionary *toSendDict = [[NSMutableDictionary alloc]init];
    NSMutableDictionary *dataDict = [[NSMutableDictionary alloc]init];
    NSString *givenVehID = [NSString stringWithFormat:@"%d",vehID];
    float dueMiles;
    NSInteger dueDays;
    
    for(Services_Table *services in serviceArray){
        
        dueMiles = [services.dueMiles floatValue];
        dueDays = [services.dueDays integerValue];
        
        if([services.vehid isEqualToString:givenVehID] && (dueMiles > 0 || dueDays > 0)){
            
            [serviceRecordsArray addObject:services];
    
        }
    }
    
    NSMutableArray *topFiveRecords = [[NSMutableArray alloc]init];
    NSMutableArray *toSendFiveRecords = [[NSMutableArray alloc]init];
    if(serviceRecordsArray.count > 5){
        
        for(int i=0;i<5;i++){
            
            [topFiveRecords addObject:[serviceRecordsArray objectAtIndex:i]];
        }
        
    }else{
        
        topFiveRecords = serviceRecordsArray;
    }
    
    for(Services_Table *topfive in topFiveRecords){
        
        [toSendFiveRecords addObject:topfive];
    }
    
    percentArray = [self progressValue:toSendFiveRecords:vehID];
    
    NSString *unit;
    
    if([[[NSUserDefaults standardUserDefaults]objectForKey:@"dist_unit"] isEqualToString:NSLocalizedString(@"disp_miles", @"Miles")])
    {
        unit = NSLocalizedString(@"mi", @"mi");
    }
    
    else
    {
        unit = NSLocalizedString(@"kms", @"km");
    }
    
    NSMutableArray *singleArray = [[NSMutableArray alloc]init];
    for(int i=0;i<percentArray.count;i++){
        
        singleArray = [percentArray objectAtIndex:i];
        NSDateFormatter *formater=[[NSDateFormatter alloc] init];
        [formater setDateFormat:@"dd-MMM-yyyy"];
        NSDate *lastdate = [singleArray valueForKey:@"lastDate"];
        NSInteger dueDays =[[singleArray valueForKey:@"dueDays"] integerValue];
        NSDate* dueDate  = [lastdate dateByAddingTimeInterval:(24*3600)*dueDays];
        
        
        if([[singleArray valueForKey:@"dueMiles"] longValue] != 0 && [[singleArray valueForKey:@"dueDays"] longValue] != 0){
            
            [formater setDateFormat:@"MMM-dd-yyyy"];
            NSString *dateString = [formater stringFromDate:dueDate];
            NSString *toDateString = [NSString stringWithFormat:@"%ld%@ /%@", [[singleArray valueForKey:@"dueMiles"]integerValue] + [[singleArray valueForKey:@"lastOdo"]integerValue],unit,dateString];
            [toSendDict setObject:toDateString forKey:@"value"];
        }else if([[singleArray valueForKey:@"dueMiles"] longValue] == 0 && [[singleArray valueForKey:@"dueDays"] longValue] != 0){
            
            [formater setDateFormat:@"MMM-dd-yyyy"];
            NSString *dateString = [formater stringFromDate:dueDate];
            NSString *toDateString = [NSString stringWithFormat:@"%@",dateString];
            [toSendDict setObject:toDateString forKey:@"value"];
        }else if([[singleArray valueForKey:@"dueMiles"] longValue] != 0 && [[singleArray valueForKey:@"dueDays"] longValue] == 0){
            
            NSString *toDateString = [NSString stringWithFormat:@"%ld%@", [[singleArray valueForKey:@"dueMiles"]integerValue] + [[singleArray valueForKey:@"lastOdo"]integerValue],unit];
            [toSendDict setObject:toDateString forKey:@"value"];
        }
        
        NSString *percentage = [NSString stringWithFormat:@"%0.f",[[singleArray valueForKey:@"progress"]floatValue] *100];
        [toSendDict setObject:percentage forKey:@"percentage"];
        NSMutableDictionary *copyToSendDict = [[NSMutableDictionary alloc]initWithDictionary:toSendDict];
        [dataDict setObject:copyToSendDict forKey:[singleArray valueForKey:@"serviceName"]];

        [toSendDict removeAllObjects];
    }
    
    return dataDict;
}

-(NSMutableArray *)progressValue:(NSMutableArray *)topFiveArray :(int)vehID{
    
    NSMutableArray *sortArray = [[NSMutableArray alloc]init];
    NSMutableArray *toReturnSortedArray = [[NSMutableArray alloc]init];
    float maxOdo;
    for (int i=0;i<topFiveArray.count;i++){
        
        NSMutableDictionary *toSortdict = [[NSMutableDictionary alloc] init];
        NSMutableDictionary *sortedDict = [[NSMutableDictionary alloc] init];
        
        NSMutableArray *topRecordArray = [[NSMutableArray alloc] init];
        NSString *serviceName;
        toSortdict = [topFiveArray objectAtIndex:i];
        
        serviceName = [toSortdict valueForKey:@"serviceName"];
        [sortedDict setValue:serviceName forKey:@"serviceName"];
        [sortedDict setValue:[toSortdict valueForKey:@"dueDays"] forKey:@"dueDays"];
        [sortedDict setValue:[toSortdict valueForKey:@"dueMiles"] forKey:@"dueMiles"];
        [sortedDict setValue:[toSortdict valueForKey:@"lastOdo"] forKey:@"lastOdo"];
        [sortedDict setValue:[toSortdict valueForKey:@"lastDate"] forKey:@"lastDate"];
        //sortedDict = [toSortdict mutableCopy];
            
        NSMutableArray *allRecordArray = [[NSMutableArray alloc] init];
        
        for(T_Fuelcons *topRecord in fillUpDataArray){
            
            if([topRecord.vehid isEqualToString:[NSString stringWithFormat:@"%d",vehID]]){
                
                [allRecordArray addObject:topRecord];
                
            }
        }
        
        if(allRecordArray.count > 0){
            
            NSMutableArray *copyTopRecordArray = [[NSMutableArray alloc]initWithArray:allRecordArray];
            topRecordArray = [copyTopRecordArray lastObject];
            maxOdo = [[topRecordArray valueForKey:@"odo"] floatValue];
            
            NSDateFormatter *formater=[[NSDateFormatter alloc] init];
            [formater setDateFormat:@"dd-MMM-yyyy"];
            
            NSDate *lastdate = [toSortdict valueForKey:@"lastDate"];
            float lastMilesInt= [[toSortdict valueForKey:@"lastOdo"]integerValue];
            NSInteger dueDays =[[toSortdict valueForKey:@"dueDays"] integerValue];
            float dueMiles = [[toSortdict valueForKey:@"dueMiles"]integerValue];
            
            //for ProgressBar
            float y = 0.000f;
            float z = 0.000f;
            if (dueMiles > 0 || dueDays > 0 ) {
                
                float diffToday = maxOdo -lastMilesInt;
                
                NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
                NSDateComponents *components = [gregorianCalendar components:NSCalendarUnitDay
                                                                    fromDate:lastdate
                                                                      toDate:[NSDate date]
                                                                     options:NSCalendarWrapComponents];
                
                NSInteger diffDay = [components day];
                float progressDay = dueDays > 0 ? (float) diffDay/dueDays : 0;
                float progressMiles = dueMiles > 0 ? (float) diffToday/dueMiles : 0;
                
                y = progressDay > progressMiles ? progressDay : progressMiles;
                
                [sortedDict setValue:[NSNumber numberWithFloat:y] forKey:@"progress"];
                [sortArray addObject:sortedDict];
            }else{
                [sortedDict setValue:[NSNumber numberWithFloat:z] forKey:@"progress"];
                [sortArray addObject:sortedDict];
            }
        }
        
    }
    
    [toReturnSortedArray addObjectsFromArray: sortArray];
    [toReturnSortedArray sortUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"progress" ascending:NO], nil]];
    return toReturnSortedArray;
}


- (IBAction)automatedButton:(UIButton *)sender {
    
    AutomatedReportsViewController *autoReport =(AutomatedReportsViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"automatedReportsView"];
    autoReport.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:autoReport animated:YES completion:nil];
    
}
- (IBAction)automatedDropButton:(UIButton *)sender {
   
    AutomatedReportsViewController *autoReport =(AutomatedReportsViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"automatedReportsView"];
    autoReport.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:autoReport animated:YES completion:nil];
    
}


@end

@implementation NSString (Something)

- (NSString *)removeQoutes {
    return [self stringByReplacingOccurrencesOfString:@"\"" withString:@""];
}

@end
