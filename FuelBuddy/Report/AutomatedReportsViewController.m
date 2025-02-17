//
//  AutomatedReportsViewController.m
//  FuelBuddy
//
//  Created by Nikhil on 08/08/18.
//  Copyright © 2018 Oraganization. All rights reserved.
//

#import "AutomatedReportsViewController.h"
#import "WebServiceURL's.h"
#import "ReportViewController.h"
#import "AppDelegate.h"
#import "commonMethods.h"
#import "LogViewController.h"
#import "Veh_Table.h"

@interface AutomatedReportsViewController (){
    
    NSString *previousEmailString;
    BOOL validEmail;
    NSString *timeSelected,*emailText;
    BOOL rawValue, pdfValue, csvValue, includeReceipt;
}
@property int selPickerRow;

@end

@implementation AutomatedReportsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    self.navigationController.navigationBar.barTintColor = [self colorFromHexString:@"#0098AB"];
    self.navigationController.navigationBar.tintColor =[UIColor whiteColor];
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.topItem.title= NSLocalizedString(@"automated_report", @"Automated Reports");
    
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
    self.emailLabel.text = NSLocalizedString(@"emails_send_to", @"Reports will be emailed to");
    if(previousEmailString != nil && previousEmailString.length > 0){
        self.emailTextField.text = previousEmailString;
        self.emailLabel.hidden = NO;
    }else{
        self.emailTextField.placeholder = NSLocalizedString(@"emails_send_to", @"Reports will be emailed to");
        self.emailLabel.hidden = YES;
    }
    
    self.scheduleLabel.text = NSLocalizedString(@"schedule", @"Schedule:");
    [self.scheduleButtonLabel setTitle:NSLocalizedString(@"report_schedule_0", @"Weekly") forState:UIControlStateNormal];
    timeSelected = NSLocalizedString(@"report_schedule_0", @"Weekly");
    self.includeRawLabel.text = NSLocalizedString(@"include_raw_data", @"Include raw data");
    self.fileTypeLabel.text = NSLocalizedString(@"file_type", @"File type:");
    self.fileTypeLabel.textColor = [UIColor darkGrayColor];
    self.pdfLabel.textColor = [UIColor darkGrayColor];
    self.csvLabel.textColor = [UIColor darkGrayColor];
    self.includeReceiptsLabel.text = NSLocalizedString(@"include_receipts", @"Include receipts");
    [self.startScheduleLabel setTitle:NSLocalizedString(@"start_schedule", @"Start Schedule") forState:UIControlStateNormal];
    [self.includeRawOutlet setImage:[UIImage imageNamed:@"uncheck"] forState:UIControlStateNormal];
    [self.includeReceiptOutlet setImage:[UIImage imageNamed:@"uncheck"] forState:UIControlStateNormal];
    [self.pdfOutlet setImage:[UIImage imageNamed:@"uncheck"] forState:UIControlStateNormal];
    [self.csvOutlet setImage:[UIImage imageNamed:@"uncheck"] forState:UIControlStateNormal];
    
    UITextField *text = [[UITextField alloc]init];
    text = self.emailTextField;
    text.delegate = self;
    [self textfieldsetting:text];
    
    self.timePickerArray = [[NSMutableArray alloc]initWithObjects:NSLocalizedString(@"report_schedule_0",@"Weekly"),NSLocalizedString(@"report_schedule_1",@"Monthly"), nil];
    
     [self fetchVehiclesData];
    
    NSDictionary *dictionary = [[NSDictionary alloc]init];
    dictionary = [self.vehiclearray lastObject];
    //to reset to first vehicle
    [def setObject:[dictionary objectForKey:@"Id"] forKey:@"currentVehicleId"];
    
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
        
        //Swapnil ENH_24
        NSString *urlstring = [paths firstObject];
        
        NSString *vehiclepic = [NSString stringWithFormat:@"%@/%@",urlstring,[dictionary objectForKey:@"Picture"]];
        self.vehicleImage.image =[UIImage imageWithContentsOfFile:vehiclepic];
    }
    
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - GENERAL METHODS

-(UIColor *)colorFromHexString:(NSString *)hexString
{
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
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
    self.emailLabel.hidden = NO;
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
        
        self.startScheduleLabel.userInteractionEnabled = YES;
        
    }else{
        
        NSString *message = NSLocalizedString(@"enter_valid_email",@"Please enter proper email address");
        NSString *title = NSLocalizedString(@"invalid_email",@"Invalid Email");
        [self showAlert:title :message];
        self.startScheduleLabel.userInteractionEnabled = NO;
    }
    
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField reason:(UITextFieldDidEndEditingReason)reason{
    
    if(textField.text.length == 0){
        self.emailLabel.hidden = YES;
        self.emailTextField.placeholder = NSLocalizedString(@"emails_send_to", @"Reports will be emailed to");
    }else{
        self.emailLabel.hidden = NO;
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
    
    self.startScheduleLabel.userInteractionEnabled = NO;
    
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

    [self.setbutton removeFromSuperview];
    [self.picker removeFromSuperview];
    timeSelected = [[NSString alloc]init];
    timeSelected = [self.timePickerArray objectAtIndex:[self.picker selectedRowInComponent:0]];
    [self.scheduleButtonLabel setTitle:timeSelected forState:UIControlStateNormal];

    NSDateFormatter *dFormat=[[NSDateFormatter alloc] init];
    [dFormat setDateFormat:@"dd-MMM-yyyy"];
    self.startScheduleLabel.userInteractionEnabled = YES;
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
    
    NSUserDefaults *def =[NSUserDefaults standardUserDefaults];
    [self.picker removeFromSuperview];
    [self.setbutton removeFromSuperview];
    NSDictionary *dictionary = [[NSDictionary alloc]init];
    dictionary = [self.vehiclearray objectAtIndex:[self.picker selectedRowInComponent:0]];
    [def setObject:[dictionary objectForKey:@"Id"] forKey:@"currentVehicleId"];
    
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


- (IBAction)vehicleClick:(UIButton *)sender {
    
    [self openVehiclePicker];
}

- (IBAction)dropClick:(UIButton *)sender {
    
    [self openVehiclePicker];
}

- (IBAction)scheduledButton:(UIButton *)sender {
    
     [self openUnitPicker];
}

- (IBAction)scheduleDropButton:(UIButton *)sender {
    
     [self openUnitPicker];
}

- (IBAction)includeRawButton:(UIButton *)sender {
    
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

- (IBAction)includeReceiptsButton:(UIButton *)sender {
    
    if(sender.selected == YES){
        sender.selected = NO;
        includeReceipt = NO;
    }else{
        
        sender.selected = YES;
        includeReceipt = YES;
    }
    [self.includeReceiptOutlet setImage:[UIImage imageNamed:@"check"] forState:UIControlStateSelected];
    [self.includeReceiptOutlet setImage:[UIImage imageNamed:@"uncheck"] forState:UIControlStateNormal];
}

- (IBAction)startScheduleButton:(UIButton *)sender {
   
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    if([[NSUserDefaults standardUserDefaults]boolForKey:@"isSubscribed"]){
        
        if([def objectForKey:@"UserEmail"] != nil){
            
            self.startScheduleLabel.userInteractionEnabled = YES;
            [def setObject:[def objectForKey:@"currentVehicleId"] forKey:@"autoVehicleId"];
            NSMutableDictionary *scheduleDict = [[NSMutableDictionary alloc]init];
            [scheduleDict setObject:[def objectForKey:@"UserDeviceId"] forKey:@"android_id"];
            NSString *timeString;
            NSString *alertString;
            if([timeSelected isEqualToString:NSLocalizedString(@"report_schedule_0", @"Weekly")]){
                
                timeString = @"Weekly";
                alertString = NSLocalizedString(@"alarm_set_weekly", @"Thank you! Your reports will be sent out every Sunday.");
            }else{
                
                timeString = @"Monthly";
                alertString = NSLocalizedString(@"alarm_set_monthly", @"Thank you! Your reports will be sent out every last day of every month.");
            }
            [scheduleDict setObject:timeString forKey:@"duration"];
            NSString *actionString;
            if([def boolForKey:@"startAutoReport"]){
                
                [def setBool:NO forKey:@"startAutoReport"];
                actionString = @"stop";
                
            }else{
                
                [def setBool:YES forKey:@"startAutoReport"];
                actionString = @"start";
            }
            
            [scheduleDict setObject:actionString forKey:@"action"];
            [scheduleDict setObject:self.emailTextField.text forKey:@"email"];
            
            [def setBool:NO forKey:@"autoCsvValue"];
            [def setBool:NO forKey:@"autoPdfValue"];
            [def setBool:NO forKey:@"autoIncludeReceiptValue"];
            
            if([previousEmailString isEqualToString:self.emailTextField.text]){
                validEmail = YES;
            }
            
            if(validEmail){
                
                [def setObject:self.emailTextField.text forKey:@"toSendEmail"];
                [def setObject:timeSelected forKey:@"scheduledTime"];
                
                if(rawValue){
                    
                    if(csvValue){
                        
                        [def setBool:YES forKey:@"autoCsvValue"];
                    }else{
                        [def setBool:YES forKey:@"autoPdfValue"];
                    }
                }
                
                if(includeReceipt){
                    
                    [def setBool:YES forKey:@"autoIncludeReceiptValue"];
                }
                
                NSError *err;
                NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
                NSData *postDataArray = [NSJSONSerialization dataWithJSONObject:scheduleDict options:NSJSONWritingPrettyPrinted error:&err];
                [def setBool:NO forKey:@"updateTimeStamp"];
                commonMethods *common = [[commonMethods alloc] init];
                [common saveToCloud:postDataArray urlString:kReportScheduleScript success:^(NSDictionary *responseDict) {
                    
                    //NSLog(@"schedule Response : %@", responseDict);
                    if([[responseDict objectForKey:@"success"]  isEqual: @1]){
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            if([def boolForKey:@"startAutoReport"]){
                                
                                [self showAlert:@"" :alertString];
                                [self.startScheduleLabel setTitle:NSLocalizedString(@"stop_schedule", @"Stop Schedule") forState:UIControlStateNormal];
                                [def setBool:NO forKey:@"autoCsvValue"];
                                [def setBool:NO forKey:@"autoPdfValue"];
                                [def setBool:NO forKey:@"autoIncludeReceiptValue"];
                                
                            }else{
                                
                                [self showAlert:@"" :NSLocalizedString(@"alarm_stop_schedule", @"Thank you! We will stop sending you reports.")];
                                [self.startScheduleLabel setTitle:NSLocalizedString(@"start_schedule", @"Start Schedule") forState:UIControlStateNormal];
                            }
                            
                        });
                        
                        
                    }else{
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            [self showAlert:@"" :NSLocalizedString(@"failed", @"Failed")];
                            [self.startScheduleLabel setTitle:NSLocalizedString(@"start_schedule", @"Start Schedule") forState:UIControlStateNormal];
                            
                        });
                        
                    }
                    
                } failure:^(NSError *error) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [self showAlert:@"" :NSLocalizedString(@"failed", @"Failed")];
                        [self.startScheduleLabel setTitle:NSLocalizedString(@"start_schedule", @"Start Schedule") forState:UIControlStateNormal];
                        
                    });
                }];
                
            }else{
                
                NSString *message = NSLocalizedString(@"enter_valid_email",@"Please enter proper email address");
                NSString *title = NSLocalizedString(@"invalid_email",@"Invalid Email");
                [self showAlert:title :message];
            }
        }else{
            
            self.startScheduleLabel.userInteractionEnabled = NO;
            NSString *message = NSLocalizedString(@"sign_in_required",@"To schedule automated reports you need to Sign in to Cloud");
            NSString *title = NSLocalizedString(@"sign_in",@"Sign In");
            [self showAlert:title :message];
            
        }
        
    }else{
        
        self.startScheduleLabel.userInteractionEnabled = NO;
        NSString *message = NSLocalizedString(@"go_pro_auto_report_msg",@"To schedule automated reports please upgrade to Platinum membership.");
        NSString *title = NSLocalizedString(@"upgrade",@"Upgrade");
        [self showAlert:title :message];
    }
    
}

@end
