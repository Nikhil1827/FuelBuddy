//
//  EmailLogViewController.m
//  FuelBuddy
//
//  Created by Swapnil on 16/03/17.
//  Copyright © 2017 Oraganization. All rights reserved.
//

#import "EmailLogViewController.h"
#import "AutorotateNavigation.h"
#import "AppDelegate.h"
#import "Veh_Table.h"
#import "FillupFieldViewController.h"
#import "T_Fuelcons.h"
#import "T_Trip.h"
#import "Services_Table.h"
#import "GoProViewController.h"

@interface EmailLogViewController ()
{
    NSDateFormatter *f;
    NSInteger detailType;
    NSArray *selectedFillups;
    NSArray *selectedFillupsDB;
    NSMutableDictionary *selectedFillupsDB0, *selectedFillupsDB1,  *selectedFillupsDB2;
    NSMutableArray *propertiesToFetch, *tripDate, *detailArray, *sequencedTrips;
    NSArray *FillupSelected;
    NSArray *sortedFillupsDB0, *sortedFillupsDB1, *sortedFillupsDB2;
    
    NSArray *dataArray, *vehData;
    NSArray *dataValues;
    NSMutableArray *checkedTrips;
    int fillupCount, serviceCount, expenseCount;
    
    //Database arrays
    NSArray *tripData, *fillUpdata;
    
    NSInteger firstCount, mailCount;
    BOOL isProUser, isCsvSelected, csvChekmarked;

}
//@property NSString *fieldLabel;
//NIKHIL BUG_131 //added property
@property int selPickerRow;
@end

@implementation EmailLogViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    

    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    
    UIImage *buttonImage = [[UIImage imageNamed:@"nav_back"] resizableImageWithCapInsets:UIEdgeInsetsMake(20,10,10,10)];
    UIImage *sendImage = [UIImage imageNamed:@"send.png"];
    
    UIButton *Button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIButton *emailButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [Button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [emailButton setBackgroundImage:sendImage forState:UIControlStateNormal];
    
    Button.frame = CGRectMake(0.0, 10.0, buttonImage.size.width+4,buttonImage.size.height+4);
    emailButton.frame = CGRectMake(0.0, 0.0, sendImage.size.width,sendImage.size.height);

    
    UIBarButtonItem *BarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:Button];
    UIBarButtonItem *emailButtonItem = [[UIBarButtonItem alloc] initWithCustomView:emailButton];

    
    [Button addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [emailButton addTarget:self action:@selector(showEmail:) forControlEvents:UIControlEventTouchUpInside];

    
    [self.navigationItem setLeftBarButtonItem:BarButtonItem];
    [self.navigationItem setRightBarButtonItem:emailButtonItem];

    
    self.navigationController.navigationBar.barTintColor = [self colorFromHexString:@"#0098AB"];
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.tintColor =[UIColor whiteColor];
    self.navigationController.navigationBar.topItem.title= NSLocalizedString(@"email_btn", @"Email Log") ;
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor] , NSFontAttributeName: [UIFont fontWithName:@"Helvetica-Light" size:18.0] }];
    
    self.view.backgroundColor = [self colorFromHexString:@"#2c2c2c"];
    
    _vehImage.contentMode = UIViewContentModeScaleAspectFill;
    _vehImage.layer.borderWidth=0;
    _vehImage.layer.masksToBounds=YES;
    _vehImage.layer.cornerRadius = 21;
    
    self.startDate.backgroundColor = [self colorFromHexString:@"#2c2c2c"];
    self.endDate.backgroundColor = [self colorFromHexString:@"#2c2c2c"];

    [self textfieldSetting:self.endDate];
    [self textfieldSetting:self.startDate];

    self.dateRangeView.backgroundColor = [self colorFromHexString:@"#2c2c2c"];

    
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

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [self colorFromHexString:@"#2c2c2c"];
    
    self.startDate.delegate = self;
    self.endDate.delegate = self;
    self.startDate.userInteractionEnabled = YES;
    self.endDate.userInteractionEnabled = YES;

    
    //set Date
    f=[[NSDateFormatter alloc] init];
    [f setDateStyle:NSDateFormatterLongStyle];
    
    [f setDateFormat:@"dd-MMM-yyyy"];
    //[f setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    [f setAMSymbol:@"AM"];
    [f setPMSymbol:@"PM"];
    
    
    //NSString *today=[f stringFromDate:[NSDate date ]];
    
    self.fieldTitlesarray = [[NSMutableArray alloc] initWithObjects:
                             NSLocalizedString(@"f_u_tv", @"Fill-Ups"),
                             NSLocalizedString(@"tot_services", @"Services"),
                             NSLocalizedString(@"tv_expenses", @"Expenses"),
                             NSLocalizedString(@"trips", @"Trips"),
                             NSLocalizedString(@"attach_csv", @"Attach CSV's"), nil];
    
    self.emailDataFillup = [[NSMutableDictionary alloc] init];
    
    detailArray = [[NSMutableArray alloc] init];
    
    isProUser = [[NSUserDefaults standardUserDefaults] boolForKey:@"isAdDisabled"];
    
    if(isProUser == false){
        mailCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"emailSentCount"];
        [self goProAlert];
    }

    self.csvCell = [NSMutableArray array];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{

    [self.tableView reloadData];
    
}

-(void)viewDidAppear:(BOOL)animated{
    
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([segue.identifier isEqualToString:@"fillupField"]){
        //NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        FillupFieldViewController *destVC = segue.destinationViewController;
        destVC.rowSelected = self.selectedRow;
    }
}



#pragma mark - AUTOROTATION OFF

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

#pragma mark VEHICLE PICKER METHODS

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
    
}

-(void)openVehiclePicker
{
    [self fetchVehiclesData];
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
    //NIKHIL BUG_134 //added setbutton removefromsuperview
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

-(void)donelabel
{
    
    NSUserDefaults *def =[NSUserDefaults standardUserDefaults];
    [self.picker removeFromSuperview];
    [self.setbutton removeFromSuperview];
    NSDictionary *dictionary = [[NSDictionary alloc]init];
    dictionary = [self.vehiclearray objectAtIndex:[self.picker selectedRowInComponent:0]];
    [[NSUserDefaults standardUserDefaults]setObject:[dictionary objectForKey:@"Id"] forKey:@"fillupid"];
    [def setObject:[def objectForKey:@"fillupid"] forKey:@"oldFillupid"];

    [[NSUserDefaults standardUserDefaults]setObject:[NSString stringWithFormat:@"%@ %@",[dictionary objectForKey:@"Make"],[dictionary objectForKey:@"Model"]] forKey:@"fillupmake"];
    
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
    
    // Change the maxOdo as per the vehicle selected
    
//    _depOdoField.text=@"";
//    [self setMaxOdo];
    
    
    
    //[self fetchvalue: self.selectpicker.titleLabel.text];
    
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
    else
        
        return 0;
}

//NIKHIL BUG_131 added below method
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    _selPickerRow = (int)[pickerView selectedRowInComponent:0];
    NSUserDefaults *setRowValue = [NSUserDefaults standardUserDefaults];
    [setRowValue setInteger:_selPickerRow forKey:@"rowValue"];
}




- (IBAction)vehButton:(id)sender {

    [self openVehiclePicker];
}

- (IBAction)vehFilterClick:(id)sender {

    [self openVehiclePicker];

}

#pragma mark - UITEXTFIELD DELEGATE METHODS

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    
    if(textField == _startDate || textField == _endDate){
        
        [self openDatepickerforTag:textField.tag] ;
        [textField resignFirstResponder];

    }
}

-(void)textfieldSetting:(UITextField *)textField{

    NSMutableAttributedString *placeholderAttributedString = [[NSMutableAttributedString alloc] initWithAttributedString:textField.attributedPlaceholder];
    [placeholderAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:NSMakeRange(0, [placeholderAttributedString length])];
    textField.attributedPlaceholder = placeholderAttributedString;
}

#pragma mark - DATEPICKER METHODS

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
    _datePicker.datePickerMode=UIDatePickerModeDate;
    str= NSLocalizedString(@"date_hint", @"Set Date");
    
    //[textfield setInputView:_datePicker];
    if (tag == 50) {
        self.pickerval= @"startDate";
    }
    else
        self.pickerval= @"endDate";
    
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
    
    if([self.pickerval isEqualToString:@"startDate"])
    {
        _startDate.text = date;
        
        
    }
    if([self.pickerval isEqualToString:@"endDate"])
    {
        
        _endDate.text = date;

    }

}


#pragma mark - TABLE VIEW DATASOURCE METHODS

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.fieldTitlesarray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"] ;
        
    }
    //tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType =  UITableViewCellAccessoryDisclosureIndicator;
    cell.backgroundColor=[UIColor clearColor];
    cell.textLabel.text = [self.fieldTitlesarray objectAtIndex:indexPath.row];
    cell.textLabel.textColor = [UIColor whiteColor];
    
    if(indexPath.row == 0){
        if([[NSUserDefaults standardUserDefaults]objectForKey:@"selectFillup"] != nil)
        {
            self.fillUparray = [[[NSUserDefaults standardUserDefaults]objectForKey:@"selectFillup"]mutableCopy];
            self.sortedFillsArr = [[[NSUserDefaults standardUserDefaults] objectForKey:@"sortedFills"]mutableCopy];
            if(self.fillUparray.count != 0){
                cell.detailTextLabel.text = [self.sortedFillsArr componentsJoinedByString:@", "];
                cell.detailTextLabel.textColor = [UIColor whiteColor];
            }
            if(self.fillUparray.count == 0){
                cell.detailTextLabel.text = NSLocalizedString(@"sel_fields", @"Select Fields");
                cell.detailTextLabel.textColor = [UIColor whiteColor];
            }
        }
        if([[NSUserDefaults standardUserDefaults]objectForKey:@"selectFillup"] == nil){
            cell.detailTextLabel.text = NSLocalizedString(@"sel_fields", @"Select Fields");
            cell.detailTextLabel.textColor = [UIColor whiteColor];

        }
        if(![cell.detailTextLabel.text isEqualToString:NSLocalizedString(@"sel_fields", @"Select Fields")]){
            
            if(![detailArray containsObject:@0]){
            
                [detailArray addObject:@0];
            }
            
        }
        if([cell.detailTextLabel.text isEqualToString:NSLocalizedString(@"sel_fields", @"Select Fields")]){
            
            if([detailArray containsObject:@0]){
                
                [detailArray removeObject:@0];
            }
            
        }
        
        
    }
    
    if(indexPath.row == 1){
        if([[NSUserDefaults standardUserDefaults]objectForKey:@"selectService"] != nil)
        {
            self.fillUparray = [[[NSUserDefaults standardUserDefaults]objectForKey:@"selectService"]mutableCopy];
            self.sortedServiceArr = [[[NSUserDefaults standardUserDefaults]objectForKey:@"sortedService"]mutableCopy];

            if(self.fillUparray.count != 0){
                cell.detailTextLabel.text = [self.sortedServiceArr componentsJoinedByString:@", "];
                cell.detailTextLabel.textColor = [UIColor whiteColor];
            }
            if(self.fillUparray.count == 0){
                cell.detailTextLabel.text = NSLocalizedString(@"sel_fields", @"Select Fields");
                cell.detailTextLabel.textColor = [UIColor whiteColor];
            }
            
        }
        if([[NSUserDefaults standardUserDefaults]objectForKey:@"selectService"] == nil){
            cell.detailTextLabel.text = NSLocalizedString(@"sel_fields", @"Select Fields");
            cell.detailTextLabel.textColor = [UIColor whiteColor];
            
        }
        if(![cell.detailTextLabel.text isEqualToString:NSLocalizedString(@"sel_fields", @"Select Fields")]){
            
            if(![detailArray containsObject:@1]){
                
                [detailArray addObject:@1];
            }
            
        }
        if([cell.detailTextLabel.text isEqualToString:NSLocalizedString(@"sel_fields", @"Select Fields")]){
            
            if([detailArray containsObject:@1]){
                
                [detailArray removeObject:@1];
            }
            
        }
    }
    
    if(indexPath.row == 2){
        if([[NSUserDefaults standardUserDefaults]objectForKey:@"selectExpense"] != nil)
        {

            self.fillUparray = [[[NSUserDefaults standardUserDefaults]objectForKey:@"selectExpense"]mutableCopy];
            self.sortedExpenseArr = [[[NSUserDefaults standardUserDefaults]objectForKey:@"sortedExpense"]mutableCopy];
            if(self.fillUparray.count != 0){
                cell.detailTextLabel.text = [self.sortedExpenseArr componentsJoinedByString:@", "];
                cell.detailTextLabel.textColor = [UIColor whiteColor];
            }
            if(self.fillUparray.count == 0){
                cell.detailTextLabel.text = NSLocalizedString(@"sel_fields", @"Select Fields");
                cell.detailTextLabel.textColor = [UIColor whiteColor];
            }
        }
        if([[NSUserDefaults standardUserDefaults]objectForKey:@"selectExpense"] == nil){
            cell.detailTextLabel.text = NSLocalizedString(@"sel_fields", @"Select Fields");
            cell.detailTextLabel.textColor = [UIColor whiteColor];
            
        }
        if(![cell.detailTextLabel.text isEqualToString:NSLocalizedString(@"sel_fields", @"Select Fields")]){
            
            if(![detailArray containsObject:@2]){
                
                [detailArray addObject:@2];
            }
            
        }
        if([cell.detailTextLabel.text isEqualToString:NSLocalizedString(@"sel_fields", @"Select Fields")]){
            
            if([detailArray containsObject:@2]){
                
                [detailArray removeObject:@2];
            }
            
        }
    }
    
    if(indexPath.row == 3){
        
        if([[NSUserDefaults standardUserDefaults]objectForKey:@"selectTrip"] != nil)
        {
            self.tripArray = [[[NSUserDefaults standardUserDefaults]objectForKey:@"selectTrip"]mutableCopy];
            self.sortedTripsArr = [[[NSUserDefaults standardUserDefaults]objectForKey:@"sortedTrips"]mutableCopy];
            if(self.tripArray.count != 0){
                
                cell.detailTextLabel.text = [self.sortedTripsArr componentsJoinedByString:@", "];
                cell.detailTextLabel.textColor = [UIColor whiteColor];
            }
            if(self.tripArray.count == 0){
                cell.detailTextLabel.text = NSLocalizedString(@"sel_fields", @"Select Fields");
                cell.detailTextLabel.textColor = [UIColor whiteColor];
            }
        }
        if([[NSUserDefaults standardUserDefaults]objectForKey:@"selectTrip"] == nil){
            cell.detailTextLabel.text = NSLocalizedString(@"sel_fields", @"Select Fields");
            cell.detailTextLabel.textColor = [UIColor whiteColor];
            
        }
    }
    
    if(indexPath.row == 4){
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        csvChekmarked = [[NSUserDefaults standardUserDefaults] boolForKey:@"attachCsvSelected"];
        if(csvChekmarked)
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            isCsvSelected = YES;
            
        }
        else
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
            isCsvSelected = NO;

        }
        
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 80;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //if(indexPath.row == 0){
        
    self.selectedRow = indexPath.row;
    if(self.selectedRow == 4){
        if(csvChekmarked)
        {
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"attachCsvSelected"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            csvChekmarked = [[NSUserDefaults standardUserDefaults] boolForKey:@"attachCsvSelected"];
        }
        else
        {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"attachCsvSelected"];
            [[NSUserDefaults standardUserDefaults] synchronize];

            csvChekmarked = [[NSUserDefaults standardUserDefaults] boolForKey:@"attachCsvSelected"];
        }
    }
    else {
        [self performSegueWithIdentifier:@"fillupField" sender:self];

    }
    [tableView reloadData];
}


#pragma mark - EMAIL METHODS

- (IBAction)showEmail:(id)sender{
    
    NSArray *selectFillup = [[NSUserDefaults standardUserDefaults] valueForKey:@"sortedFills"];
    NSArray *selectServices = [[NSUserDefaults standardUserDefaults] valueForKey:@"sortedService"];
    NSArray *selectExpenses = [[NSUserDefaults standardUserDefaults] valueForKey:@"sortedExpense"];

    
    BOOL isDateValidated = [self dateValidationForEmail];
    BOOL isFieldsValidated = [self fieldsValidation];

    if(isDateValidated == YES && isFieldsValidated == YES){
        [self fetchDataForEmailLog];
        
        if(selectFillup.count != 0 || selectServices.count != 0 || selectExpenses.count != 0){

            [self fetchFillupDataForAll];
        }
        [self fetchTripData];


    }
    
    
    BOOL isRecordPresent = YES;
    if([[self.emailDataFillup valueForKey:@"Fill-Ups"] count] == 0 && [[self.emailDataFillup valueForKey:@"servicesData"] count] == 0 && [[self.emailDataFillup valueForKey:@"expenseData"] count] == 0 && tripData.count == 0){
        isRecordPresent = [self alertForEmptyRecords];
    }

    if(isRecordPresent == YES){
    
    NSString *subjectString = [NSString stringWithFormat:@"Data for %@ from %@ to %@", self.vehicleFetched,_startDate.text, _endDate.text];
    
    NSString *messageBody;
    NSMutableArray *completeString = [[NSMutableArray alloc] init];
    NSMutableArray *completeString2 = [[NSMutableArray alloc] init];
    NSMutableArray *completeString3 = [[NSMutableArray alloc] init];
    NSMutableArray *completeString4 = [[NSMutableArray alloc] init];

    NSString *fillupHeading;
    NSString *serviceHeading;
    NSString *expenseHeading;
    NSString *tripHeading;
    
    if(selectFillup.count != 0){
        fillupHeading = [NSString stringWithFormat:@"<b><u>%@</u></b><br/>", NSLocalizedString(@"f_u_tv", @"Fill-ups")] ;
    } else {
        fillupHeading = @"";
    }
        
    if(selectServices.count != 0){
        serviceHeading = [NSString stringWithFormat:@"<br/><b><u>%@</u></b><br/>", NSLocalizedString(@"tot_services", @"Services")] ;
    } else {
        serviceHeading = @"";
    }
        
    if(selectExpenses.count != 0){
        expenseHeading = [NSString stringWithFormat:@"<br/><b><u>%@</u></b><br/>", NSLocalizedString(@"tv_expenses", @"Expenses")];
    } else {
        expenseHeading = @"";
    }
    
    if(self.tripArray.count != 0){
        tripHeading = [NSString stringWithFormat:@"<br/><b><u>%@</u></b><br/>", NSLocalizedString(@"trips", @"Trips")] ;
    } else {
        tripHeading = @"";
    }

    
    NSString *stringWithHeadingFillup;
    NSString *stringWithHeadingServices;
    NSString *stringWithHeadingExpenses;
    NSString *stringWithHeadingTrips;


    NSString *fillupAndService;
    NSString *fillupAndServiceAndExpense;
    NSString *fillupAndServiceAndExpenseAndTrip;

   
    MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];

    //Fill-ups
    if(selectFillup.count != 0){
   for(int i = 0; i < fillupCount; i++){
       for(int j = 0; j < selectFillup.count; j++){
           
           if(j == 0){
               NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
               [formatter setDateFormat:@"dd-MMM-yyyy"];
               NSString *fillupDate = [formatter stringFromDate:[[[self.emailDataFillup valueForKey:@"Fill-Ups"] objectAtIndex:i] valueForKey:@"stringDate"]];
               fillupDate = [NSString stringWithFormat:@"<br/><u>%@</u><br/>", fillupDate];
               
               if([[selectFillup objectAtIndex:j] isEqualToString:NSLocalizedString(@"odometer", @"Odometer")] || [[selectFillup objectAtIndex:j] isEqualToString:NSLocalizedString(@"dist_tv", @"Distance")]){
                   
                   NSString *unitString = [[NSUserDefaults standardUserDefaults] valueForKey:@"dist_unit"];
                   if([unitString isEqualToString:NSLocalizedString(@"disp_miles", @"Miles")]){
                       unitString = [unitString stringByReplacingOccurrencesOfString:NSLocalizedString(@"disp_miles", @"Miles") withString:NSLocalizedString(@"mi", @"mi")];
                   }
                   if([unitString isEqualToString:NSLocalizedString(@"disp_kilometers", @"Kilometers")]){
                       unitString = [unitString stringByReplacingOccurrencesOfString:NSLocalizedString(@"disp_kilometers", @"Kilometers") withString:NSLocalizedString(@"kms", @"km")];
                   }
                   
                   //Swapnil ENH_24
                   NSString *roundupValue = [NSString stringWithFormat:@"%.2f %@",[[[[self.emailDataFillup valueForKey:@"Fill-Ups"] objectAtIndex:i] valueForKey:[selectedFillupsDB0 valueForKey:[[sortedFillupsDB0 firstObject] objectAtIndex:j]]] floatValue], unitString];
                   messageBody = [fillupDate stringByAppendingString:[NSString stringWithFormat:@"<b>&nbsp&nbsp%@ :</b> %@<br/>", [selectFillup objectAtIndex:j], roundupValue]];
                   
               } else if ([[selectFillup objectAtIndex:j] isEqualToString:NSLocalizedString(@"qty_tv", @"Quantity")]){
                   
                   NSString *unitString = [[NSUserDefaults standardUserDefaults] valueForKey:@"vol_unit"];
                   if([unitString isEqualToString:NSLocalizedString(@"disp_litre", @"Litre")]){
                       unitString = [unitString stringByReplacingOccurrencesOfString:NSLocalizedString(@"disp_litre", @"Litre") withString:NSLocalizedString(@"ltr", @"Ltr")];
                   }
                   if([unitString isEqualToString:NSLocalizedString(@"disp_gal_us", @"Gallon (US)")]){
                       unitString = [unitString stringByReplacingOccurrencesOfString:NSLocalizedString(@"disp_gal_us", @"Gallon (US)") withString:NSLocalizedString(@"gal", @"gal")];
                   }
                   if([unitString isEqualToString:NSLocalizedString(@"disp_gal_uk", @"Gallon (UK)")]){
                       unitString = [unitString stringByReplacingOccurrencesOfString:NSLocalizedString(@"disp_gal_uk", @"Gallon (UK)") withString:NSLocalizedString(@"gal", @"gal")];
                   }

                   if([unitString isEqualToString:NSLocalizedString(@"disp_kilowatt_hour", @"Kilowatt-Hour")]){
                       unitString = [unitString stringByReplacingOccurrencesOfString:NSLocalizedString(@"disp_kilowatt_hour", @"Kilowatt-Hour") withString:NSLocalizedString(@"kwh", @"kWh")];
                   }
                   
                   //Swapnil ENH_24
                   NSString *roundupValue = [NSString stringWithFormat:@"%.3f %@",[[[[self.emailDataFillup valueForKey:@"Fill-Ups"] objectAtIndex:i] valueForKey:[selectedFillupsDB0 valueForKey:[[sortedFillupsDB0 firstObject] objectAtIndex:j]]] floatValue], unitString];
                   messageBody = [fillupDate stringByAppendingString:[NSString stringWithFormat:@"<b>&nbsp&nbsp%@ :</b> %@<br/>", [selectFillup objectAtIndex:j], roundupValue]];
                   
               } else if ([[selectFillup objectAtIndex:j] isEqualToString:NSLocalizedString(@"tc_tv", @"Total Cost")]){
                   
                   NSArray *unitArr = [[[NSUserDefaults standardUserDefaults] valueForKey:@"curr_unit"] componentsSeparatedByString:@"-"];
                   NSString *unitString = [unitArr lastObject];
                   
                   //Swapnil ENH_24
                   NSString *roundupValue = [NSString stringWithFormat:@"%.2f %@",[[[[self.emailDataFillup valueForKey:@"Fill-Ups"] objectAtIndex:i] valueForKey:[selectedFillupsDB0 valueForKey:[[sortedFillupsDB0 firstObject] objectAtIndex:j]]] floatValue], unitString];
                   messageBody = [fillupDate stringByAppendingString:[NSString stringWithFormat:@"<b>&nbsp&nbsp%@ :</b> %@<br/>", [selectFillup objectAtIndex:j], roundupValue]];
               } else if ([[selectFillup objectAtIndex:j] isEqualToString:NSLocalizedString(@"cons_head", @"Consumption")]){
                   NSString *unitString = [[NSUserDefaults standardUserDefaults] valueForKey:@"con_unit"];
                   NSString *consRoundup = [NSString stringWithFormat:@"%.2f %@", [[[[self.emailDataFillup valueForKey:@"Fill-Ups"] objectAtIndex:i] valueForKey:[selectedFillupsDB0 valueForKey:[[sortedFillupsDB0 firstObject] objectAtIndex:j]]] floatValue], unitString];
                   
                   if([[[NSUserDefaults standardUserDefaults] valueForKey:@"con_unit"] isEqual:@"L/100km"]){
                       
                       consRoundup = [NSString stringWithFormat:@"%.2f %@", 100/[consRoundup floatValue], unitString];
                   }
                   messageBody = [fillupDate stringByAppendingString:[NSString stringWithFormat:@"<b>&nbsp&nbsp%@ :</b> %@<br/>", [selectFillup objectAtIndex:j], consRoundup]];


               }//Swapnil ENH_24
               else if ([[selectFillup objectAtIndex:j] isEqualToString:NSLocalizedString(@"attach_receipt", @"Attach Receipt")]){
                   messageBody = [fillupDate stringByAppendingString:[NSString stringWithFormat:@"<b>&nbsp&nbspReceipt :</b> %@<br/>", [[[self.emailDataFillup valueForKey:@"Fill-Ups"] objectAtIndex:i] valueForKey:[selectedFillupsDB0 valueForKey:[[sortedFillupsDB0 firstObject] objectAtIndex:j]]]]];

               }
               else {   //Swapnil ENH_24
                messageBody = [fillupDate stringByAppendingString:[NSString stringWithFormat:@"<b>&nbsp&nbsp%@ :</b> %@<br/>", [selectFillup objectAtIndex:j], [[[self.emailDataFillup valueForKey:@"Fill-Ups"] objectAtIndex:i] valueForKey:[selectedFillupsDB0 valueForKey:[[sortedFillupsDB0 firstObject] objectAtIndex:j]]]]];
               }

           }
           if(j != 0){
               if([[selectFillup objectAtIndex:j] isEqualToString:NSLocalizedString(@"cons_head", @"Consumption")]){
                   
                   //Swapnil ENH_24
                   NSString *unitString = [[NSUserDefaults standardUserDefaults] valueForKey:@"con_unit"];
                   NSString *consRoundup = [NSString stringWithFormat:@"%.2f %@", [[[[self.emailDataFillup valueForKey:@"Fill-Ups"] objectAtIndex:i] valueForKey:[selectedFillupsDB0 valueForKey:[[sortedFillupsDB0 firstObject] objectAtIndex:j]]] floatValue], unitString];
                   
                   if([[[NSUserDefaults standardUserDefaults] valueForKey:@"con_unit"] isEqual:@"L/100km"]){
                       
                       consRoundup = [NSString stringWithFormat:@"%.2f %@", 100/[consRoundup floatValue], unitString];
                   }
                   
                   messageBody = [NSString stringWithFormat:@"<b>&nbsp&nbsp%@ :</b> %@<br/>", [selectFillup objectAtIndex:j], consRoundup];

               }
               if([[selectFillup objectAtIndex:j] isEqualToString:NSLocalizedString(@"odometer", @"Odometer")] || [[selectFillup objectAtIndex:j] isEqualToString:NSLocalizedString(@"dist_tv", @"Distance")]){
                   
                   NSString *unitString = [[NSUserDefaults standardUserDefaults] valueForKey:@"dist_unit"];
                   if([unitString isEqualToString:NSLocalizedString(@"disp_miles", @"Miles")]){
                       unitString = [unitString stringByReplacingOccurrencesOfString:NSLocalizedString(@"disp_miles", @"Miles") withString:NSLocalizedString(@"mi", @"mi")];
                   }
                   if([unitString isEqualToString:NSLocalizedString(@"disp_kilometers", @"Kilometers")]){
                       unitString = [unitString stringByReplacingOccurrencesOfString:NSLocalizedString(@"disp_kilometers", @"Kilometers") withString:NSLocalizedString(@"kms", @"km")];
                   }
                   //Swapnil ENH_24
                   NSString *roundupValue = [NSString stringWithFormat:@"%.2f %@",[[[[self.emailDataFillup valueForKey:@"Fill-Ups"] objectAtIndex:i] valueForKey:[selectedFillupsDB0 valueForKey:[[sortedFillupsDB0 firstObject] objectAtIndex:j]]] floatValue], unitString];
                   messageBody = [NSString stringWithFormat:@"<b>&nbsp&nbsp%@ :</b> %@<br/>", [selectFillup objectAtIndex:j], roundupValue];
               }
               if ([[selectFillup objectAtIndex:j] isEqualToString:NSLocalizedString(@"qty_tv", @"Quantity")]){
                   
                   NSString *unitString = [[NSUserDefaults standardUserDefaults] valueForKey:@"vol_unit"];
                   if([unitString isEqualToString:NSLocalizedString(@"disp_litre", @"Litre")]){
                       unitString = [unitString stringByReplacingOccurrencesOfString:NSLocalizedString(@"disp_litre", @"Litre") withString:NSLocalizedString(@"ltr", @"Ltr")];
                   }
                   if([unitString isEqualToString:NSLocalizedString(@"disp_gal_us", @"Gallon (US)")]){
                       unitString = [unitString stringByReplacingOccurrencesOfString:NSLocalizedString(@"disp_gal_us", @"Gallon (US)") withString:NSLocalizedString(@"gal", @"gal")];
                   }
                   if([unitString isEqualToString:NSLocalizedString(@"disp_gal_uk", @"Gallon (UK)")]){
                       unitString = [unitString stringByReplacingOccurrencesOfString:NSLocalizedString(@"disp_gal_uk", @"Gallon (UK)") withString:NSLocalizedString(@"gal", @"gal")];
                   }
                   if([unitString isEqualToString:NSLocalizedString(@"disp_kilowatt_hour", @"Kilowatt-Hour")]){
                       unitString = [unitString stringByReplacingOccurrencesOfString:NSLocalizedString(@"disp_kilowatt_hour", @"Kilowatt-Hour") withString:NSLocalizedString(@"kwh", @"kWh")];
                   }
                   //Swapnil ENH_24
                   NSString *roundupValue = [NSString stringWithFormat:@"%.3f %@",[[[[self.emailDataFillup valueForKey:@"Fill-Ups"] objectAtIndex:i] valueForKey:[selectedFillupsDB0 valueForKey:[[sortedFillupsDB0 firstObject] objectAtIndex:j]]] floatValue], unitString];
                   messageBody = [NSString stringWithFormat:@"<b>&nbsp&nbsp%@ :</b> %@<br/>", [selectFillup objectAtIndex:j], roundupValue];
               }
               if ([[selectFillup objectAtIndex:j] isEqualToString:NSLocalizedString(@"tc_tv", @"Total Cost")]){
                   
                   NSArray *unitArr = [[[NSUserDefaults standardUserDefaults] valueForKey:@"curr_unit"] componentsSeparatedByString:@"-"];
                   NSString *unitString = [unitArr lastObject];
                   
                   //Swapnil ENH_24
                   NSString *roundupValue = [NSString stringWithFormat:@"%.2f %@",[[[[self.emailDataFillup valueForKey:@"Fill-Ups"] objectAtIndex:i] valueForKey:[selectedFillupsDB0 valueForKey:[[sortedFillupsDB0 firstObject] objectAtIndex:j]]] floatValue], unitString];
                   messageBody = [NSString stringWithFormat:@"<b>&nbsp&nbsp%@ :</b> %@<br/>", [selectFillup objectAtIndex:j], roundupValue];
               }

               
               
               if([[selectFillup objectAtIndex:j] isEqualToString:NSLocalizedString(@"attach_receipt", @"Attach Receipt")]){
                   //Swapnil ENH_24
                   if([[[self.emailDataFillup valueForKey:@"Fill-Ups"] objectAtIndex:i] valueForKey:[selectedFillupsDB0 valueForKey:[[sortedFillupsDB0 firstObject] objectAtIndex:j]]] != nil)
                   {
                       NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                       
                       //Swapnil ENH_24
                       NSString *documentsDirectory = [paths firstObject];
                       
                       //Swapnil ENH_24
                       NSString *selectedReceiptPath = [[[self.emailDataFillup valueForKey:@"Fill-Ups"] objectAtIndex:i] valueForKey:[selectedFillupsDB0 valueForKey:[[sortedFillupsDB0 firstObject] objectAtIndex:j]]];
                       //ENH_57 nikhil 16/7/2018
                       NSArray *separateArray = [[NSArray alloc] init];
                       if([selectedReceiptPath containsString:@":::"]){
                            separateArray = [selectedReceiptPath componentsSeparatedByString:@":::"];
                      
                         for(int k=0;k<separateArray.count;k++){
                           
                            NSString *completeReceiptPath = [documentsDirectory stringByAppendingPathComponent:[separateArray objectAtIndex:k]];
                           
                            NSData *fileData = [NSData dataWithContentsOfFile:completeReceiptPath];
                           
                            //MIME type 
                            NSString *mimeType = @"image/png";
                            [mailComposer addAttachmentData:fileData mimeType:mimeType fileName:@"Fill-up Receipt"];
                           
                         }
                       }else if(![selectedReceiptPath isEqualToString:@""]){
                           NSString *completeReceiptPath = [documentsDirectory stringByAppendingPathComponent:selectedReceiptPath];
                           
                           NSData *fileData = [NSData dataWithContentsOfFile:completeReceiptPath];
                           
                           //MIME type
                           NSString *mimeType = @"image/png";
                           [mailComposer addAttachmentData:fileData mimeType:mimeType fileName:@"Fill-up Receipt"];
                       }
                   }
                   //Swapnil ENH_24
                       messageBody = [NSString stringWithFormat:@"<b>&nbsp&nbspReceipt :</b> %@<br/>", [[[self.emailDataFillup valueForKey:@"Fill-Ups"] objectAtIndex:i] valueForKey:[selectedFillupsDB0 valueForKey:[[sortedFillupsDB0 firstObject] objectAtIndex:j]]]];
                   
                   

               }
               //Swapnil ENH_24
               else if([[selectFillup objectAtIndex:j] isEqualToString:NSLocalizedString(@"pf_tv", @"Partial Tank")] || [[selectFillup objectAtIndex:j] isEqualToString:NSLocalizedString(@"octane", @"Octane")] || [[selectFillup objectAtIndex:j] isEqualToString:NSLocalizedString(@"fb_tv", @"Fuel Brand")] || [[selectFillup objectAtIndex:j] isEqualToString:NSLocalizedString(@"fs_tv", @"Filling Station") ] || [[selectFillup objectAtIndex:j] isEqualToString:NSLocalizedString(@"notes_tv", @"Notes")]){
                   messageBody = [NSString stringWithFormat:@"<b>&nbsp&nbsp%@ :</b> %@<br/>", [selectFillup objectAtIndex:j], [[[self.emailDataFillup valueForKey:@"Fill-Ups"] objectAtIndex:i] valueForKey:[selectedFillupsDB0 valueForKey:[[sortedFillupsDB0 firstObject] objectAtIndex:j]]]];
               }

           }
           if([messageBody containsString:@"(null)"]){
               messageBody = [messageBody stringByReplacingOccurrencesOfString:@"(null)" withString:@"n/a"];

           }
           if([messageBody containsString:@"inf"]){
               messageBody = [messageBody stringByReplacingOccurrencesOfString:@"inf" withString:@"0.00"];

           }
           
           
           [completeString addObject:messageBody];
        }
    }
        if(selectFillup.count == 0){
            stringWithHeadingFillup = @"";
        } else {
            stringWithHeadingFillup = [fillupHeading stringByAppendingString:[completeString componentsJoinedByString:@""]];
        }
    }
        
    //Services
    
    if(selectServices.count != 0){
    for(int i = 0; i < serviceCount; i++){
        //NSString *dateString;
        for(int j = 0; j < selectServices.count; j++){
            if(j == 0){
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"dd-MMM-yyyy"];
                NSString *fillupDate = [formatter stringFromDate:[[[self.emailDataFillup valueForKey:@"servicesData"] objectAtIndex:i] valueForKey:@"stringDate"]];
                fillupDate = [NSString stringWithFormat:@"<br/><u>%@</u><br/>", fillupDate];
                
                if([[selectServices objectAtIndex:j] isEqualToString:NSLocalizedString(@"odometer", @"Odometer")]){
                    
                    NSString *unitString = [[NSUserDefaults standardUserDefaults] valueForKey:@"dist_unit"];
                    if([unitString isEqualToString:NSLocalizedString(@"disp_miles", @"Miles")]){
                        unitString = [unitString stringByReplacingOccurrencesOfString:NSLocalizedString(@"disp_miles", @"Miles") withString:NSLocalizedString(@"mi", @"mi")];
                    }
                    if([unitString isEqualToString:NSLocalizedString(@"disp_kilometers", @"Kilometers")]){
                        unitString = [unitString stringByReplacingOccurrencesOfString:NSLocalizedString(@"disp_kilometers", @"Kilometers") withString:NSLocalizedString(@"kms", @"km")];
                    }//Swapnil ENH_24
                    NSString *roundupValue = [NSString stringWithFormat:@"%.2f %@",[[[[self.emailDataFillup valueForKey:@"servicesData"] objectAtIndex:i] valueForKey:[selectedFillupsDB1 valueForKey:[[sortedFillupsDB1 firstObject] objectAtIndex:j]]] floatValue], unitString];
                    messageBody = [fillupDate stringByAppendingString:[NSString stringWithFormat:@"<b>&nbsp&nbsp%@ :</b> %@<br/>", [selectServices objectAtIndex:j], roundupValue]];
                }
                else if ([[selectServices objectAtIndex:j] isEqualToString:NSLocalizedString(@"tc_tv", @"Total Cost")]){
                    //Swapnil ENH_24
                    NSArray *unitArr = [[[NSUserDefaults standardUserDefaults] valueForKey:@"curr_unit"] componentsSeparatedByString:@"-"];
                    NSString *unitString = [unitArr lastObject];
                    NSString *roundupValue = [NSString stringWithFormat:@"%.2f %@",[[[[self.emailDataFillup valueForKey:@"servicesData"] objectAtIndex:i] valueForKey:[selectedFillupsDB1 valueForKey:[[sortedFillupsDB1 firstObject] objectAtIndex:j]]] floatValue], unitString];
                    messageBody = [fillupDate stringByAppendingString:[NSString stringWithFormat:@"<b>&nbsp&nbsp%@ :</b> %@<br/>", [selectServices objectAtIndex:j], roundupValue]];
                } else if ([[selectServices objectAtIndex:j] isEqualToString:NSLocalizedString(@"attach_receipt", @"Attach Receipt")]){
                    
                    //Swapnil ENH_24
                    messageBody = [fillupDate stringByAppendingString:[NSString stringWithFormat:@"<b>&nbsp&nbspReceipt :</b> %@<br/>", [[[self.emailDataFillup valueForKey:@"servicesData"] objectAtIndex:i] valueForKey:[selectedFillupsDB1 valueForKey:[[sortedFillupsDB1 firstObject] objectAtIndex:j]]]]];

                }
                else {
                //Swapnil ENH_24
                messageBody = [fillupDate stringByAppendingString:[NSString stringWithFormat:@"<b>&nbsp&nbsp%@ :</b> %@<br/>", [selectServices objectAtIndex:j], [[[self.emailDataFillup valueForKey:@"servicesData"] objectAtIndex:i] valueForKey:[selectedFillupsDB1 valueForKey:[[sortedFillupsDB1 firstObject] objectAtIndex:j]]]]];
                }
            }
            if(j != 0){
                
                
                if([[selectServices objectAtIndex:j] isEqualToString:NSLocalizedString(@"attach_receipt", @"Attach Receipt")]){
                    //Swapnil ENH_24
                    if([[[self.emailDataFillup valueForKey:@"servicesData"] objectAtIndex:i] valueForKey:[selectedFillupsDB1 valueForKey:[[sortedFillupsDB1 firstObject] objectAtIndex:j]]] != nil)
                    {
                        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                        
                        //Swapnil ENH_24
                        NSString *documentsDirectory = [paths firstObject];
                        
                        NSString *selectedReceiptPath = [[[self.emailDataFillup valueForKey:@"servicesData"] objectAtIndex:i] valueForKey:[selectedFillupsDB1 valueForKey:[[sortedFillupsDB1 firstObject] objectAtIndex:j]]];
                        NSString *completeReceiptPath = [documentsDirectory stringByAppendingPathComponent:selectedReceiptPath];
                        
                        //File name
//                        NSArray *filePart = [completeReceiptPath componentsSeparatedByString:@"."];
//                        
//                        //Swapnil ENH_24
//                        NSString *filePart0 = [filePart firstObject];
//                        
//                        NSString *filePart1 = [filePart objectAtIndex:1];
//                        NSString *fileName = [filePart0 stringByAppendingFormat:@".%@", filePart1];
                        
                        NSData *fileData = [NSData dataWithContentsOfFile:completeReceiptPath];
                        
                        //MIME type
                        NSString *mimeType = @"image/png";
                        
                        //Swapnil ENH_24
                        [mailComposer addAttachmentData:fileData mimeType:mimeType fileName:@"Service Receipt"];
                        messageBody = [NSString stringWithFormat:@"<b>&nbsp&nbspReceipt :</b> %@<br/>", [[[self.emailDataFillup valueForKey:@"servicesData"] objectAtIndex:i] valueForKey:[selectedFillupsDB1 valueForKey:[[sortedFillupsDB1 firstObject] objectAtIndex:j]]]];

                    } else {
                        //Swapnil ENH_24
                        messageBody = [NSString stringWithFormat:@"<b>&nbsp&nbspReceipt :</b> %@<br/>", [[[self.emailDataFillup valueForKey:@"servicesData"] objectAtIndex:i] valueForKey:[selectedFillupsDB1 valueForKey:[[sortedFillupsDB1 firstObject] objectAtIndex:j]]]];
                        
                    }
                    
                }
                else if([[selectServices objectAtIndex:j] isEqualToString:NSLocalizedString(@"odometer", @"Odometer")]){
                    
                    NSString *unitString = [[NSUserDefaults standardUserDefaults] valueForKey:@"dist_unit"];
                    if([unitString isEqualToString:NSLocalizedString(@"disp_miles", @"Miles")]){
                        unitString = [unitString stringByReplacingOccurrencesOfString:NSLocalizedString(@"disp_miles", @"Miles") withString:NSLocalizedString(@"mi", @"mi")];
                    }
                    if([unitString isEqualToString:NSLocalizedString(@"disp_kilometers", @"Kilometers")]){
                        unitString = [unitString stringByReplacingOccurrencesOfString:NSLocalizedString(@"disp_kilometers", @"Kilometers") withString:NSLocalizedString(@"kms", @"km")];
                    }
                    //Swapnil ENH_24
                    NSString *roundupValue = [NSString stringWithFormat:@"%.2f %@",[[[[self.emailDataFillup valueForKey:@"servicesData"] objectAtIndex:i] valueForKey:[selectedFillupsDB1 valueForKey:[[sortedFillupsDB1 firstObject] objectAtIndex:j]]] floatValue], unitString];
                    messageBody = [NSString stringWithFormat:@"<b>&nbsp&nbsp%@ :</b> %@<br/>", [selectServices objectAtIndex:j], roundupValue];
                }
                else if ([[selectServices objectAtIndex:j] isEqualToString:NSLocalizedString(@"tc_tv", @"Total Cost")]){
                    //Swapnil ENH_24
                    NSArray *unitArr = [[[NSUserDefaults standardUserDefaults] valueForKey:@"curr_unit"] componentsSeparatedByString:@"-"];
                    NSString *unitString = [unitArr lastObject];
                    NSString *roundupValue = [NSString stringWithFormat:@"%.2f %@",[[[[self.emailDataFillup valueForKey:@"servicesData"] objectAtIndex:i] valueForKey:[selectedFillupsDB1 valueForKey:[[sortedFillupsDB1 firstObject] objectAtIndex:j]]] floatValue], unitString];
                    messageBody = [NSString stringWithFormat:@"<b>&nbsp&nbsp%@ :</b> %@<br/>", [selectServices objectAtIndex:j], roundupValue];
                }
                else {
                //Swapnil ENH_24
                messageBody = [NSString stringWithFormat:@"<b>&nbsp&nbsp%@ :</b> %@<br/>", [selectServices objectAtIndex:j], [[[self.emailDataFillup valueForKey:@"servicesData"] objectAtIndex:i] valueForKey:[selectedFillupsDB1 valueForKey:[[sortedFillupsDB1 firstObject] objectAtIndex:j]]]];
                }
        
                
            }
            
            [completeString2 addObject:messageBody];
        }
    }
    
    }
        if(selectServices.count == 0){
            stringWithHeadingServices = @"";
        } else {
            stringWithHeadingServices = [serviceHeading stringByAppendingString:[completeString2 componentsJoinedByString:@""]];
        }
        if(stringWithHeadingFillup.length == 0){
            stringWithHeadingFillup = @"";
        }
        fillupAndService = [stringWithHeadingFillup stringByAppendingString:stringWithHeadingServices];
    
        
    //Expenses
    
    if(selectExpenses.count != 0){
    for(int i = 0; i < expenseCount; i++){
        //NSString *dateString;
        for(int j = 0; j < selectExpenses.count; j++){
            if(j == 0){
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"dd-MMM-yyyy"];
                NSString *fillupDate = [formatter stringFromDate:[[[self.emailDataFillup valueForKey:@"expenseData"] objectAtIndex:i] valueForKey:@"stringDate"]];
                fillupDate = [NSString stringWithFormat:@"<br/><u>%@</u><br/>", fillupDate];
                
                if([[selectExpenses objectAtIndex:j] isEqualToString:NSLocalizedString(@"odometer", @"Odometer")]){
                    
                    NSString *unitString = [[NSUserDefaults standardUserDefaults] valueForKey:@"dist_unit"];
                    if([unitString isEqualToString:NSLocalizedString(@"disp_miles", @"Miles")]){
                        unitString = [unitString stringByReplacingOccurrencesOfString:NSLocalizedString(@"disp_miles", @"Miles") withString:NSLocalizedString(@"mi", @"mi")];
                    }
                    if([unitString isEqualToString:NSLocalizedString(@"disp_kilometers", @"Kilometers")]){
                        unitString = [unitString stringByReplacingOccurrencesOfString:NSLocalizedString(@"disp_kilometers", @"Kilometers") withString:NSLocalizedString(@"kms", @"km")];
                    }
                    //Swapnil ENH_24
                    NSString *roundupValue = [NSString stringWithFormat:@"%.2f %@",[[[[self.emailDataFillup valueForKey:@"expenseData"] objectAtIndex:i] valueForKey:[selectedFillupsDB2 valueForKey:[[sortedFillupsDB2 firstObject] objectAtIndex:j]]] floatValue], unitString];
                    messageBody = [fillupDate stringByAppendingString:[NSString stringWithFormat:@"<b>&nbsp&nbsp%@ :</b> %@<br/>", [selectExpenses objectAtIndex:j], roundupValue]];
                }
                else if ([[selectExpenses objectAtIndex:j] isEqualToString:NSLocalizedString(@"tc_tv", @"Total Cost")]){
                    
                    NSArray *unitArr = [[[NSUserDefaults standardUserDefaults] valueForKey:@"curr_unit"] componentsSeparatedByString:@"-"];
                    NSString *unitString = [unitArr lastObject];
                    
                    //Swapnil ENH_24
                    NSString *roundupValue = [NSString stringWithFormat:@"%.2f %@",[[[[self.emailDataFillup valueForKey:@"expenseData"] objectAtIndex:i] valueForKey:[selectedFillupsDB2 valueForKey:[[sortedFillupsDB2 firstObject] objectAtIndex:j]]] floatValue], unitString];
                    
                    messageBody = [fillupDate stringByAppendingString:[NSString stringWithFormat:@"<b>&nbsp&nbsp%@ :</b> %@<br/>", [selectExpenses objectAtIndex:j], roundupValue]];
                }//Swapnil ENH_24
                else if ([[selectExpenses objectAtIndex:j] isEqualToString:NSLocalizedString(@"attach_receipt", @"Attach Receipt")]){
                    messageBody = [fillupDate stringByAppendingString:[NSString stringWithFormat:@"<b>&nbsp&nbsp%@ :</b> %@<br/>", NSLocalizedString(@"receipt", @"Receipt"), [[[self.emailDataFillup valueForKey:@"expenseData"] objectAtIndex:i] valueForKey:[selectedFillupsDB2 valueForKey:[[sortedFillupsDB2 firstObject] objectAtIndex:j]]]]];

                }
                else {
                //Swapnil ENH_24
                messageBody = [fillupDate stringByAppendingString:[NSString stringWithFormat:@"<b>&nbsp&nbsp%@ :</b> %@<br/>", [selectExpenses objectAtIndex:j], [[[self.emailDataFillup valueForKey:@"expenseData"] objectAtIndex:i] valueForKey:[selectedFillupsDB2 valueForKey:[[sortedFillupsDB2 firstObject] objectAtIndex:j]]]]];
                }
            }
            if(j != 0){
                
                if([[selectExpenses objectAtIndex:j] isEqualToString:NSLocalizedString(@"attach_receipt", @"Attach Receipt")]){
                    //Swapnil ENH_24
                    if([[[self.emailDataFillup valueForKey:@"expenseData"] objectAtIndex:i] valueForKey:[selectedFillupsDB2 valueForKey:[[sortedFillupsDB2 firstObject] objectAtIndex:j]]] != nil)
                    {
                        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                        
                        //Swapnil ENH_24
                        NSString *documentsDirectory = [paths firstObject];
                        
                        NSString *selectedReceiptPath = [[[self.emailDataFillup valueForKey:@"expenseData"] objectAtIndex:i] valueForKey:[selectedFillupsDB2 valueForKey:[[sortedFillupsDB2 firstObject] objectAtIndex:j]]];
                        NSString *completeReceiptPath = [documentsDirectory stringByAppendingPathComponent:selectedReceiptPath];
                        
                        //File name
//                        NSArray *filePart = [completeReceiptPath componentsSeparatedByString:@"."];
//                        
//                        //Swapnil ENH_24
//                        NSString *filePart0 = [filePart firstObject];
//                        
//                        NSString *filePart1 = [filePart objectAtIndex:1];
//                        NSString *fileName = [filePart0 stringByAppendingFormat:@".%@", filePart1];
                        
                        NSData *fileData = [NSData dataWithContentsOfFile:completeReceiptPath];
                        
                        //MIME type
                        NSString *mimeType = @"image/png";
                        [mailComposer addAttachmentData:fileData mimeType:mimeType fileName:@"Expense Receipt"];
                    } else {
                        //Swapnil ENH_24
                        messageBody = [NSString stringWithFormat:@"<b>&nbsp&nbspReceipt :</b> %@<br/>", [[[self.emailDataFillup valueForKey:@"expenseData"] objectAtIndex:i] valueForKey:[selectedFillupsDB2 valueForKey:[[sortedFillupsDB2 firstObject] objectAtIndex:j]]]];
                        
                    }
                    
                }
                else if([[selectExpenses objectAtIndex:j] isEqualToString:NSLocalizedString(@"odometer", @"Odometer")]){
                    
                    NSString *unitString = [[NSUserDefaults standardUserDefaults] valueForKey:@"dist_unit"];
                    if([unitString isEqualToString:NSLocalizedString(@"disp_miles", @"Miles")]){
                        unitString = [unitString stringByReplacingOccurrencesOfString:NSLocalizedString(@"disp_miles", @"Miles") withString:NSLocalizedString(@"mi", @"mi")];
                    }
                    if([unitString isEqualToString:NSLocalizedString(@"disp_kilometers", @"Kilometers")]){
                        unitString = [unitString stringByReplacingOccurrencesOfString:NSLocalizedString(@"disp_kilometers", @"Kilometers") withString:NSLocalizedString(@"kms", @"km")];
                    }
                    //Swapnil ENH_24
                    NSString *roundupValue = [NSString stringWithFormat:@"%.2f %@",[[[[self.emailDataFillup valueForKey:@"expenseData"] objectAtIndex:i] valueForKey:[selectedFillupsDB2 valueForKey:[[sortedFillupsDB2 firstObject] objectAtIndex:j]]] floatValue], unitString];
                    messageBody = [NSString stringWithFormat:@"<b>&nbsp&nbsp%@ :</b> %@<br/>", [selectExpenses objectAtIndex:j], roundupValue];
                }
                else if ([[selectExpenses objectAtIndex:j] isEqualToString:NSLocalizedString(@"tc_tv", @"Total Cost")]){
                    
                    NSArray *unitArr = [[[NSUserDefaults standardUserDefaults] valueForKey:@"curr_unit"] componentsSeparatedByString:@"-"];
                    NSString *unitString = [unitArr lastObject];
                    
                    //Swapnil ENH_24
                    NSString *roundupValue = [NSString stringWithFormat:@"%.2f %@",[[[[self.emailDataFillup valueForKey:@"expenseData"] objectAtIndex:i] valueForKey:[selectedFillupsDB2 valueForKey:[[sortedFillupsDB2 firstObject] objectAtIndex:j]]] floatValue], unitString];
                    
                    messageBody = [NSString stringWithFormat:@"<b>&nbsp&nbsp%@ :</b> %@<br/>", [selectExpenses objectAtIndex:j], roundupValue];
                }
                else {
                //Swapnil ENH_24
                messageBody = [NSString stringWithFormat:@"<b>&nbsp&nbsp%@ :</b> %@<br/>", [selectExpenses objectAtIndex:j], [[[self.emailDataFillup valueForKey:@"expenseData"] objectAtIndex:i] valueForKey:[selectedFillupsDB2 valueForKey:[[sortedFillupsDB2 firstObject] objectAtIndex:j]]]];
                }
                
            }
            [completeString3 addObject:messageBody];
        }
    }
    }
        if(selectExpenses.count == 0){
            stringWithHeadingExpenses = @"";
        } else {
            stringWithHeadingExpenses = [expenseHeading stringByAppendingString:[completeString3 componentsJoinedByString:@""]];
        }
        
        if(fillupAndService.length == 0){
            fillupAndService = @"";
        }
        fillupAndServiceAndExpense = [fillupAndService stringByAppendingString:stringWithHeadingExpenses];

    //Trips
    if(sequencedTrips.count != 0){
        for(int i = 0; i < checkedTrips.count; i++){
            NSString *fillupDate;
            int count = 0;
            int depCount = 0;

            for(int j = 0; j < sequencedTrips.count; j++){
                
            if(j == 0){
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"dd-MMM-yyyy"];
                fillupDate = [formatter stringFromDate:[[tripDate objectAtIndex:i] valueForKey:@"departDate"]];
                fillupDate = [NSString stringWithFormat:@"<br/><u>%@</u><br/>", fillupDate];
                
                if([[sequencedTrips objectAtIndex:j] isEqualToString:NSLocalizedString(@"type", @"Type")]){
                    messageBody = [fillupDate stringByAppendingString:[NSString stringWithFormat:@"<b>&nbsp&nbsp&nbsp%@ :</b> %@<br/>", [sequencedTrips objectAtIndex:j], [[checkedTrips objectAtIndex:i] valueForKey:[sequencedTrips objectAtIndex:j]]]];
                }
                if([[sequencedTrips objectAtIndex:j] isEqualToString:NSLocalizedString(@"date_time", @"Date/Time")] || [[sequencedTrips objectAtIndex:j] isEqualToString:NSLocalizedString(@"odometer", @"Odometer")] || [[sequencedTrips objectAtIndex:j] isEqualToString:NSLocalizedString(@"location", @"Location")]){
                    messageBody = [NSString stringWithFormat:@"<b>&nbsp&nbsp&nbsp&nbsp&nbsp%@ :</b> %@<br/>", [sequencedTrips objectAtIndex:j], [[checkedTrips objectAtIndex:i] valueForKey:[sequencedTrips objectAtIndex:j]]];
                    if(depCount == 0){
                        NSString *departString = [NSString stringWithFormat:@"&nbsp&nbsp&nbsp<u>%@</u><br/>", NSLocalizedString(@"departure", @"Departure")] ;
                        messageBody = [departString stringByAppendingString:messageBody];
                        depCount = depCount + 1;
                    }
                    messageBody = [fillupDate stringByAppendingString:messageBody];
                }
                else {
                    if([[sequencedTrips objectAtIndex:j] isEqualToString:NSLocalizedString(@"Date/Time.", @"Date/Time.")] || [[sequencedTrips objectAtIndex:j] isEqualToString:NSLocalizedString(@"Odometer.", @"Odometer.")] || [[sequencedTrips objectAtIndex:j] isEqualToString:NSLocalizedString(@"Location.", @"Location.")]){
                        if(count == 0){
                            NSString *arrString = [NSString stringWithFormat:@"&nbsp&nbsp&nbsp<u>%@</u><br/>", NSLocalizedString(@"arrival", @"Arrival")] ;
                            messageBody = [arrString stringByAppendingString:[NSString stringWithFormat:@"<b>&nbsp&nbsp&nbsp&nbsp&nbsp%@ :</b> %@<br/>", [sequencedTrips objectAtIndex:j], [[checkedTrips objectAtIndex:i] valueForKey:[sequencedTrips objectAtIndex:j]]]];
                            count = count + 1;
                        }
                    }else {
                    messageBody = [fillupDate stringByAppendingString:[NSString stringWithFormat:@"<b>&nbsp&nbsp&nbsp%@ :</b> %@<br/>", [sequencedTrips objectAtIndex:j], [[checkedTrips objectAtIndex:i] valueForKey:[sequencedTrips objectAtIndex:j]]]];
                    if(depCount == 0){
                        NSString *departString;
                        if([sequencedTrips containsObject:NSLocalizedString(@"date_time", @"Date/Time")] || [sequencedTrips containsObject:NSLocalizedString(@"odometer", @"Odometer")] || [sequencedTrips containsObject:NSLocalizedString(@"location", @"Location")]){
                            departString = [NSString stringWithFormat:@"&nbsp&nbsp&nbsp<u>%@</u><br/>", NSLocalizedString(@"departure", @"Departure")];
                        } else {
                            departString = @"";
                        }
                        messageBody = [messageBody stringByAppendingString:departString];
                        depCount = depCount + 1;
                    }
                    }
                }
            }
                
            if(j != 0){
                
                
                if([[sequencedTrips objectAtIndex:j] isEqualToString:NSLocalizedString(@"dist_traveled", @"Distance Traveled")] || [[sequencedTrips objectAtIndex:j] isEqualToString:NSLocalizedString(@"time_traveled", @"Time Traveled")] || [[sequencedTrips objectAtIndex:j] isEqualToString:NSLocalizedString(@"tax_deduction_rate", @"Tax Deduction Rate")] || [[sequencedTrips objectAtIndex:j] isEqualToString: @"Parking"] || [[sequencedTrips objectAtIndex:j] isEqualToString:@"Toll"] || [[sequencedTrips objectAtIndex:j] isEqualToString:NSLocalizedString(@"tax_deduction_amount", @"Tax Deducted")] || [[sequencedTrips objectAtIndex:j] isEqualToString:NSLocalizedString(@"notes_tv", @"Notes")]){
                    messageBody = [NSString stringWithFormat:@"<b>&nbsp&nbsp&nbsp%@ :</b> %@<br/>", [sequencedTrips objectAtIndex:j], [[checkedTrips objectAtIndex:i] valueForKey:[sequencedTrips objectAtIndex:j]]];
                
                } else {
                    
                messageBody = [NSString stringWithFormat:@"<b>&nbsp&nbsp&nbsp&nbsp&nbsp%@ :</b> %@<br/>", [sequencedTrips objectAtIndex:j], [[checkedTrips objectAtIndex:i] valueForKey:[sequencedTrips objectAtIndex:j]]];
                
                }
                

                if([[sequencedTrips objectAtIndex:j] isEqualToString:NSLocalizedString(@"Date/Time.", @"Date/Time.")] || [[sequencedTrips objectAtIndex:j] isEqualToString:NSLocalizedString(@"Odometer.", @"Odometer.")] || [[sequencedTrips objectAtIndex:j] isEqualToString:NSLocalizedString(@"Location.", @"Location.")]){
                    if(count == 0){
                        NSString *arrString = [NSString stringWithFormat:@"&nbsp&nbsp&nbsp<u>%@</u><br/>", NSLocalizedString(@"arrival", @"Arrival")] ;
                        messageBody = [arrString stringByAppendingString:messageBody];
                        count = count + 1;
                    }
                }
                
            }
                
            [completeString4 addObject:messageBody];
        }
        }
        

    }
        
        if(sequencedTrips.count == 0){
            stringWithHeadingTrips = @"";
        } else {
            stringWithHeadingTrips = [tripHeading stringByAppendingString:[completeString4 componentsJoinedByString:@""]];
        }
        
        if(fillupAndServiceAndExpense.length == 0){
            fillupAndServiceAndExpense = @"";
        }
        fillupAndServiceAndExpenseAndTrip = [fillupAndServiceAndExpense stringByAppendingString:stringWithHeadingTrips];
    
        if([fillupAndServiceAndExpenseAndTrip containsString:@"(null)"]){
            fillupAndServiceAndExpenseAndTrip = [fillupAndServiceAndExpenseAndTrip stringByReplacingOccurrencesOfString:@"(null)" withString:@"n/a"];
        }
        if([self.tripArray containsObject:NSLocalizedString(@"trip_by_type_tv", @"Dist by Type")] || [self.tripArray containsObject:NSLocalizedString(@"tax_ded_by_type_tv", @"Tax Ded by type")]){
            
            NSString *tripTotString = [NSString stringWithFormat:@"<br/><b><u>Trip Totals</u></b><br/>", NSLocalizedString(@"total", @"Trip Totals")] ;
            fillupAndServiceAndExpenseAndTrip = [fillupAndServiceAndExpenseAndTrip stringByAppendingString:tripTotString];
            if([self.tripArray containsObject:NSLocalizedString(@"trip_by_type_tv", @"Dist by Type")]){
                NSString *distHeading = [NSString stringWithFormat:@"<br/><u>%@</u><br/>", NSLocalizedString(@"trip_by_type_tv", @"Dist by type")]  ;
                fillupAndServiceAndExpenseAndTrip = [fillupAndServiceAndExpenseAndTrip stringByAppendingString:distHeading];
                
                NSString *unitString = [[NSUserDefaults standardUserDefaults] valueForKey:@"dist_unit"];
                if([unitString isEqualToString:NSLocalizedString(@"disp_miles", @"Miles")]){
                    unitString = [unitString stringByReplacingOccurrencesOfString:NSLocalizedString(@"disp_miles", @"Miles") withString:NSLocalizedString(@"mi", @"mi")];
                }
                if([unitString isEqualToString:NSLocalizedString(@"disp_kilometers", @"Kilometers")]){
                    unitString = [unitString stringByReplacingOccurrencesOfString:NSLocalizedString(@"disp_kilometers", @"Kilometers") withString:NSLocalizedString(@"kms", @"km")];
                }
                for(int i = 0; i < self.tripTypeDictArray.count; i++){
                    fillupAndServiceAndExpenseAndTrip = [fillupAndServiceAndExpenseAndTrip stringByAppendingString:[NSString stringWithFormat:@"&nbsp&nbsp<b>%@</b> : %.2f %@<br/>", [[self.tripTypeDictArray objectAtIndex:i] valueForKey:@"type"], [[[self.tripTypeDictArray objectAtIndex:i] valueForKey:@"distance"] floatValue], unitString]];
                }
            }
            
            if([self.tripArray containsObject:NSLocalizedString(@"tax_ded_by_type_tv", @"Tax Ded by type")]){
                NSString *taxHeading = [NSString stringWithFormat:@"<br/><u>%@</u><br/>", NSLocalizedString(@"tax_ded_by_type_tv", @"Tax Ded by type")] ;
                fillupAndServiceAndExpenseAndTrip = [fillupAndServiceAndExpenseAndTrip stringByAppendingString:taxHeading];
                NSArray *unitArr = [[[NSUserDefaults standardUserDefaults] valueForKey:@"curr_unit"] componentsSeparatedByString:@"-"];
                NSString *unitString = [unitArr lastObject];
                
                for(int i = 0; i < self.tripTypeDictArray.count; i++){
                    fillupAndServiceAndExpenseAndTrip = [fillupAndServiceAndExpenseAndTrip stringByAppendingString:[NSString stringWithFormat:@"&nbsp&nbsp<b>%@</b> : %.2f %@<br/>", [[self.tripTypeDictArray objectAtIndex:i] valueForKey:@"type"], [[[self.tripTypeDictArray objectAtIndex:i] valueForKey:@"tax"] floatValue], unitString]];
                }
            }
        }
        
    NSString *footerString = [NSString stringWithFormat:@"<br/><br/><i>%@</i>", NSLocalizedString(@"footnote_for_email", @"*Sent via Simply Auto")] ;
        fillupAndServiceAndExpenseAndTrip = [fillupAndServiceAndExpenseAndTrip stringByAppendingString:footerString];
        
    NSArray *toReceipts = [NSArray arrayWithObject:@""];
    if([MFMailComposeViewController canSendMail]){
        //MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];

        mailComposer.mailComposeDelegate = self;
        
        [mailComposer setSubject:subjectString];
        [mailComposer setMessageBody:fillupAndServiceAndExpenseAndTrip isHTML:YES];
        [mailComposer setToRecipients:toReceipts];
        
        
        //Attach CSV
        if(isCsvSelected){
            
            NSString *csvMimeType = @"text/csv";
            if(selectFillup.count != 0 && [[self.emailDataFillup valueForKey:@"Fill-Ups"] count] != 0){
                NSData *fillupCsvData = [NSData dataWithContentsOfFile:self.fillupFilePath];
                [mailComposer addAttachmentData:fillupCsvData mimeType:csvMimeType fileName:@"Fuel_Log.csv"];
            }
            if(selectServices.count != 0 && [[self.emailDataFillup valueForKey:@"servicesData"] count] != 0){
                NSData *serviceCsvData = [NSData dataWithContentsOfFile:self.serviceFilePath];
                [mailComposer addAttachmentData:serviceCsvData mimeType:csvMimeType fileName:@"Services.csv"];
            }
            if(selectExpenses.count != 0 && [[self.emailDataFillup valueForKey:@"expenseData"] count] != 0){
                NSData *expenseCsvData = [NSData dataWithContentsOfFile:self.expenseFilePath];
                [mailComposer addAttachmentData:expenseCsvData mimeType:csvMimeType fileName:@"Expenses.csv"];
            }
            if(self.sortedTripsArr.count != 0 && tripData.count != 0){
                NSData *tripCsvData = [NSData dataWithContentsOfFile:self.tripFilePath];
                [mailComposer addAttachmentData:tripCsvData mimeType:csvMimeType fileName:@"Trip_Log.csv"];
            }
        }
        mailComposer.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:mailComposer animated:YES completion:nil];
    }
    }
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    
    switch (result) {
        case MFMailComposeResultCancelled:{
            BOOL fillupfileExists = [[NSFileManager defaultManager] fileExistsAtPath:self.fillupFilePath];
            BOOL servicefileExists = [[NSFileManager defaultManager] fileExistsAtPath:self.serviceFilePath];
            BOOL expensefileExists = [[NSFileManager defaultManager] fileExistsAtPath:self.expenseFilePath];
            BOOL tripfileExists = [[NSFileManager defaultManager] fileExistsAtPath:self.tripFilePath];

            
            if(fillupfileExists){
                NSError *error;
                [[NSFileManager defaultManager] removeItemAtPath:self.fillupFilePath error:&error];
            }
            if(servicefileExists){
                NSError *error;
                [[NSFileManager defaultManager] removeItemAtPath:self.serviceFilePath error:&error];
            }
            if(expensefileExists){
                NSError *error;
                [[NSFileManager defaultManager] removeItemAtPath:self.expenseFilePath error:&error];
            }
            if(tripfileExists){
                NSError *error;
                [[NSFileManager defaultManager] removeItemAtPath:self.tripFilePath error:&error];
            }
        }
            break;
            
        case MFMailComposeResultSaved:
            if(isProUser == false){
                mailCount = mailCount + 1;
                [[NSUserDefaults standardUserDefaults] setInteger:mailCount forKey:@"emailSentCount"];
                mailCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"emailSentCount"];
                
            }
            break;
            
        case MFMailComposeResultSent:
            if(isProUser == false){
                mailCount = mailCount + 1;
                [[NSUserDefaults standardUserDefaults] setInteger:mailCount forKey:@"emailSentCount"];
                mailCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"emailSentCount"];
                
            }
            BOOL fillupfileExists = [[NSFileManager defaultManager] fileExistsAtPath:self.fillupFilePath];
            BOOL servicefileExists = [[NSFileManager defaultManager] fileExistsAtPath:self.serviceFilePath];
            BOOL expensefileExists = [[NSFileManager defaultManager] fileExistsAtPath:self.expenseFilePath];
            BOOL tripfileExists = [[NSFileManager defaultManager] fileExistsAtPath:self.tripFilePath];
            
            if(fillupfileExists){
                NSError *error;
                [[NSFileManager defaultManager] removeItemAtPath:self.fillupFilePath error:&error];
            }
            if(servicefileExists){
                NSError *error;
                [[NSFileManager defaultManager] removeItemAtPath:self.serviceFilePath error:&error];
            }
            if(expensefileExists){
                NSError *error;
                [[NSFileManager defaultManager] removeItemAtPath:self.expenseFilePath error:&error];
            }
            if(tripfileExists){
                NSError *error;
                [[NSFileManager defaultManager] removeItemAtPath:self.tripFilePath error:&error];
            }

            break;
            
        case MFMailComposeResultFailed:
            break;
            
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (BOOL)alertForEmptyRecords{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"no_records_found", @"No records found")  preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle: NSLocalizedString(@"ok", @"OK")  style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [alert dismissViewControllerAnimated:NO completion:nil];
    }];
    
    [alert addAction:ok];
    [self presentViewController:alert animated:NO completion:nil];
    return NO;
    
}

- (void)fetchDataForEmailLog{
    
    //self.vehiclearray = [[NSMutableArray alloc] init];
    [self fetchVehiclesData];
    NSManagedObjectContext *context = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSFetchRequest *request=[[NSFetchRequest alloc] initWithEntityName:@"Veh_Table"];
    NSMutableDictionary *vehicleDict = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *vehicleData = [[NSMutableDictionary alloc] init];

    vehicleDict = [self.vehiclearray objectAtIndex:[self.picker selectedRowInComponent:0]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"iD == %@", [vehicleDict objectForKey:@"Id"]];
    [request setPredicate:predicate];

    NSError *err;
    vehData = [context executeFetchRequest:request error:&err];
    
    //Swapnil ENH_24
    vehicleData = [vehData firstObject];
    self.vehicleFetched = [NSString stringWithFormat:@"%@%@", [vehicleData valueForKey:@"make"], [vehicleData valueForKey:@"model"]];
}

- (BOOL)dateValidationForEmail{
    
    if([_startDate.text  isEqual: @""] || [_endDate.text  isEqual: @""]){
        //[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isDateValidated"];

        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"email_user_err", @"Please make sure the dates and at least one field is selected")  preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle: NSLocalizedString(@"ok", @"OK")  style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [alert dismissViewControllerAnimated:NO completion:nil];
        }];
        [alert addAction:ok];
        [self presentViewController:alert animated:NO completion:nil];
        return NO;

    }
    
    if([[f dateFromString: _startDate.text] compare:[f dateFromString: _endDate.text]] == NSOrderedDescending){
        //[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isDateValidated"];

        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"custom_date_err", @"Please make sure that the dates are selected correctly.") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle: NSLocalizedString(@"ok", @"OK")  style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [alert dismissViewControllerAnimated:NO completion:nil];
        }];
        [alert addAction:ok];
        [self presentViewController:alert animated:NO completion:nil];
        return NO;
    }
    else
        return YES;
}

- (BOOL)fieldsValidation{
    
    NSIndexPath *indexPath0 = [NSIndexPath indexPathForRow:0 inSection:0];
    NSIndexPath *indexPath1 = [NSIndexPath indexPathForRow:1 inSection:0];
    NSIndexPath *indexPath2 = [NSIndexPath indexPathForRow:2 inSection:0];
    NSIndexPath *indexPath3 = [NSIndexPath indexPathForRow:3 inSection:0];


    UITableViewCell *cell0 = [self.tableView cellForRowAtIndexPath:indexPath0];
    UITableViewCell *cell1 = [self.tableView cellForRowAtIndexPath:indexPath1];
    UITableViewCell *cell2 = [self.tableView cellForRowAtIndexPath:indexPath2];
    UITableViewCell *cell3 = [self.tableView cellForRowAtIndexPath:indexPath3];


    
    if([cell0.detailTextLabel.text isEqualToString:NSLocalizedString(@"sel_fields", @"Select Fields")] && [cell1.detailTextLabel.text isEqualToString:NSLocalizedString(@"sel_fields", @"Select Fields")] && [cell2.detailTextLabel.text isEqualToString:NSLocalizedString(@"sel_fields", @"Select Fields")] && [cell3.detailTextLabel.text isEqualToString:NSLocalizedString(@"sel_fields", @"Select Fields")])
    {
        //[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isFieldsValidated"];

        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"email_user_err", @"Please make sure the dates and at least one field is selected") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle: NSLocalizedString(@"ok", @"OK")  style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [alert dismissViewControllerAnimated:NO completion:nil];
        }];
        
        [alert addAction:ok];
        [self presentViewController:alert animated:NO completion:nil];
        return NO;

    }
    else
        return YES;
    
}

- (void)fetchFillupDataForAll{
    
    if(detailArray.count != 0){
        for(int i = 0; i < detailArray.count; i++){
            detailType = [[detailArray objectAtIndex:i] integerValue];
            [self fetchFillUpData:detailType];
        }
    }
}


- (void)fetchFillUpData: (NSInteger)detailTypeInteger{
    
    selectedFillups = [[NSArray alloc] init];
    propertiesToFetch = [[NSMutableArray alloc] init];

    selectedFillupsDB = [[NSArray alloc] init];
    NSMutableDictionary *vehicleDict = [[NSMutableDictionary alloc] init];
    NSIndexPath *indexPath;
    if(detailTypeInteger == 0){
        indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    }
    if(detailTypeInteger == 1){
        indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    }
    if(detailTypeInteger == 2){
        indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
    }
    
    UITableViewCell *cell0 = [self.tableView cellForRowAtIndexPath:indexPath];
    if(self.fillUparray != nil){
        selectedFillupsDB = [selectedFillupsDB arrayByAddingObject:@"stringDate"];
        if([cell0.detailTextLabel.text containsString:NSLocalizedString(@"odometer", @"Odometer")]){
           selectedFillupsDB = [selectedFillupsDB arrayByAddingObject:@"odo"];
        }
        if([cell0.detailTextLabel.text containsString:NSLocalizedString(@"qty_tv", @"Quantity")]){
            selectedFillupsDB = [selectedFillupsDB arrayByAddingObject:@"qty"];
        }
        if([cell0.detailTextLabel.text containsString:NSLocalizedString(@"dist_tv", @"Distance")]){
            selectedFillupsDB = [selectedFillupsDB arrayByAddingObject:@"dist"];
        }
        if([cell0.detailTextLabel.text containsString:NSLocalizedString(@"tc_tv", @"Total Cost")]){
            selectedFillupsDB = [selectedFillupsDB arrayByAddingObject:@"cost"];
        }
        if([cell0.detailTextLabel.text containsString:NSLocalizedString(@"cons_head", @"Consumption")]){
            selectedFillupsDB = [selectedFillupsDB arrayByAddingObject:@"cons"];

        }
        if([cell0.detailTextLabel.text containsString:NSLocalizedString(@"pf_tv", @"Partial Tank")]){
           selectedFillupsDB = [selectedFillupsDB arrayByAddingObject:@"pfill"];

        }
        if([cell0.detailTextLabel.text containsString:NSLocalizedString(@"octane", @"Octane")]){
           selectedFillupsDB = [selectedFillupsDB arrayByAddingObject:@"octane"];

        }
        if([cell0.detailTextLabel.text containsString:NSLocalizedString(@"fb_tv", @"Fuel Brand")]){
            selectedFillupsDB = [selectedFillupsDB arrayByAddingObject:@"fuelBrand"];

        }
        if([cell0.detailTextLabel.text containsString:NSLocalizedString(@"fs_tv", @"Filling Station")]){
            selectedFillupsDB = [selectedFillupsDB arrayByAddingObject:@"fillStation"];

        }
        if([cell0.detailTextLabel.text containsString:NSLocalizedString(@"notes_tv", @"Notes")]){
            selectedFillupsDB = [selectedFillupsDB arrayByAddingObject:@"notes"];

        }
        if([cell0.detailTextLabel.text containsString:NSLocalizedString(@"attach_receipt", @"Attach Receipt")]){
            selectedFillupsDB = [selectedFillupsDB arrayByAddingObject:@"receipt"];

        }
        if([cell0.detailTextLabel.text containsString:NSLocalizedString(@"tot_services", @"Services")]){
            selectedFillupsDB = [selectedFillupsDB arrayByAddingObject:@"serviceType"];

        }
        if([cell0.detailTextLabel.text containsString:NSLocalizedString(@"tv_service_center", @"Service Center")]){
            selectedFillupsDB = [selectedFillupsDB arrayByAddingObject:@"fillStation"];

        }
        if([cell0.detailTextLabel.text containsString:NSLocalizedString(@"tv_expenses", @"Expenses")]){
            selectedFillupsDB = [selectedFillupsDB arrayByAddingObject:@"serviceType"];

        }
        if([cell0.detailTextLabel.text containsString:NSLocalizedString(@"tv_vendor", @"Vendor")]){
            selectedFillupsDB = [selectedFillupsDB arrayByAddingObject:@"fillStation"];

        }
        
        
    } else {
        selectedFillupsDB = [[NSArray alloc] initWithObjects:@"", nil];
    }
    
    if(detailTypeInteger == 0){
        selectedFillupsDB0 = [[NSMutableDictionary alloc] init];
        NSDictionary *dictForSort = [NSDictionary dictionaryWithObject:selectedFillupsDB forKey:[[NSUserDefaults standardUserDefaults] valueForKey:@"sortedFills"]];
        sortedFillupsDB0 = [dictForSort keysSortedByValueUsingSelector:@selector(localizedCompare:)];
        
        //Swapnil ENH_24
        if([[sortedFillupsDB0 firstObject]containsObject:NSLocalizedString(@"odometer", @"Odometer")]){
            [selectedFillupsDB0 setObject:@"odo" forKey:NSLocalizedString(@"odometer", @"Odometer")];
        }
        if([[sortedFillupsDB0 firstObject]containsObject:NSLocalizedString(@"qty_tv", @"Quantity")]){
            [selectedFillupsDB0 setObject:@"qty" forKey:NSLocalizedString(@"qty_tv", @"Quantity")];
        }
        if([[sortedFillupsDB0 firstObject]containsObject:NSLocalizedString(@"dist_tv", @"Distance")]){
            [selectedFillupsDB0 setObject:@"dist" forKey:NSLocalizedString(@"dist_tv", @"Distance")];
        }
        if([[sortedFillupsDB0 firstObject]containsObject:NSLocalizedString(@"tc_tv", @"Total Cost")]){
            [selectedFillupsDB0 setObject:@"cost" forKey:NSLocalizedString(@"tc_tv", @"Total Cost")];
        }
        if([[sortedFillupsDB0 firstObject]containsObject:NSLocalizedString(@"cons_head", @"Consumption")]){
            [selectedFillupsDB0 setObject:@"cons" forKey:NSLocalizedString(@"cons_head", @"Consumption")];
        }
        if([[sortedFillupsDB0 firstObject]containsObject:NSLocalizedString(@"pf_tv", @"Partial Tank")]){
            [selectedFillupsDB0 setObject:@"pfill" forKey:NSLocalizedString(@"pf_tv", @"Partial Tank")];
        }
        if([[sortedFillupsDB0 firstObject]containsObject:NSLocalizedString(@"octane", @"Octane")]){
            [selectedFillupsDB0 setObject:@"octane" forKey:NSLocalizedString(@"octane", @"Octane")];
        }
        if([[sortedFillupsDB0 firstObject]containsObject:NSLocalizedString(@"fb_tv", @"Fuel Brand")]){
            [selectedFillupsDB0 setObject:@"fuelBrand" forKey:NSLocalizedString(@"fb_tv", @"Fuel Brand")];
        }
        if([[sortedFillupsDB0 firstObject]containsObject:NSLocalizedString(@"fs_tv", @"Filling Station")]){
            [selectedFillupsDB0 setObject:@"fillStation" forKey:NSLocalizedString(@"fs_tv", @"Filling Station")];
        }
        if([[sortedFillupsDB0 firstObject]containsObject:NSLocalizedString(@"notes_tv", @"Notes")]){
            [selectedFillupsDB0 setObject:@"notes" forKey:NSLocalizedString(@"notes_tv", @"Notes")];
        }
        if([[sortedFillupsDB0 firstObject]containsObject:NSLocalizedString(@"attach_receipt", @"Attach Receipt")]){
            [selectedFillupsDB0 setObject:@"receipt" forKey:NSLocalizedString(@"attach_receipt", @"Attach Receipt")];
        }

    }


    if(detailTypeInteger == 1){
        selectedFillupsDB1 = [[NSMutableDictionary alloc] init];
        NSDictionary *dictForSort = [NSDictionary dictionaryWithObject:selectedFillupsDB forKey:[[NSUserDefaults standardUserDefaults] valueForKey:@"sortedService"]];
        sortedFillupsDB1 = [dictForSort keysSortedByValueUsingSelector:@selector(localizedCompare:)];
        
        //Swapnil ENH_24
        if([[sortedFillupsDB1 firstObject]containsObject:NSLocalizedString(@"odometer", @"Odometer")]){
            [selectedFillupsDB1 setObject:@"odo" forKey:NSLocalizedString(@"odometer", @"Odometer")];
        }
        if([[sortedFillupsDB1 firstObject]containsObject:NSLocalizedString(@"tot_services", @"Services")]){
            [selectedFillupsDB1 setObject:@"serviceType" forKey:NSLocalizedString(@"tot_services", @"Services")];
        }
        if([[sortedFillupsDB1 firstObject]containsObject:NSLocalizedString(@"tv_service_center", @"Service Center")]){
            [selectedFillupsDB1 setObject:@"fillStation" forKey:NSLocalizedString(@"tv_service_center", @"Service Center")];
        }
        if([[sortedFillupsDB1 firstObject]containsObject:NSLocalizedString(@"tc_tv", @"Total Cost")]){
            [selectedFillupsDB1 setObject:@"cost" forKey:NSLocalizedString(@"tc_tv", @"Total Cost")];
        }
        if([[sortedFillupsDB1 firstObject]containsObject:NSLocalizedString(@"notes_tv", @"Notes")]){
            [selectedFillupsDB1 setObject:@"notes" forKey:NSLocalizedString(@"notes_tv", @"Notes")];
        }
        if([[sortedFillupsDB1 firstObject]containsObject:NSLocalizedString(@"attach_receipt", @"Attach Receipt")]){
            [selectedFillupsDB1 setObject:@"receipt" forKey:NSLocalizedString(@"attach_receipt", @"Attach Receipt")];
        }

    }
    if(detailTypeInteger == 2){
        selectedFillupsDB2 = [[NSMutableDictionary alloc] init];
        NSDictionary *dictForSort = [NSDictionary dictionaryWithObject:selectedFillupsDB forKey:[[NSUserDefaults standardUserDefaults] valueForKey:@"sortedExpense"]];
        sortedFillupsDB2 = [dictForSort keysSortedByValueUsingSelector:@selector(localizedCompare:)];
        
        //Swapnil ENH_24
        if([[sortedFillupsDB2 firstObject]containsObject:NSLocalizedString(@"odometer", @"Odometer")]){
            [selectedFillupsDB2 setObject:@"odo" forKey:NSLocalizedString(@"odometer", @"Odometer")];
        }
        if([[sortedFillupsDB2 firstObject]containsObject:NSLocalizedString(@"tv_expenses", @"Expenses")]){
            [selectedFillupsDB2 setObject:@"serviceType" forKey:NSLocalizedString(@"tv_expenses", @"Expenses")];
        }
        if([[sortedFillupsDB2 firstObject]containsObject:NSLocalizedString(@"tv_vendor", @"Vendor")]){
            [selectedFillupsDB2 setObject:@"fillStation" forKey:NSLocalizedString(@"tv_vendor", @"Vendor")];
        }
        if([[sortedFillupsDB2 firstObject]containsObject:NSLocalizedString(@"tc_tv", @"Total Cost")]){
            [selectedFillupsDB2 setObject:@"cost" forKey:NSLocalizedString(@"tc_tv", @"Total Cost")];
        }
        if([[sortedFillupsDB2 firstObject]containsObject:NSLocalizedString(@"notes_tv", @"Notes")]){
            [selectedFillupsDB2 setObject:@"notes" forKey:NSLocalizedString(@"notes_tv", @"Notes")];
        }
        if([[sortedFillupsDB2 firstObject]containsObject:NSLocalizedString(@"attach_receipt", @"Attach Receipt")]){
            [selectedFillupsDB2 setObject:@"receipt" forKey:NSLocalizedString(@"attach_receipt", @"Attach Receipt")];
        }


    }
    
    
    [self fetchVehiclesData];
    NSManagedObjectContext *context = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"T_Fuelcons"];
    vehicleDict = [self.vehiclearray objectAtIndex:[self.picker selectedRowInComponent:0]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(vehid == %@) AND (stringDate >= %@ AND stringDate <= %@) AND (type == %ld)",[vehicleDict valueForKey:@"Id"], [f dateFromString:_startDate.text], [f dateFromString:_endDate.text], (long)detailType];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"stringDate" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    
    [request setPredicate:predicate];
    [request setSortDescriptors:sortDescriptors];
    [request setResultType:NSDictionaryResultType];
    [request setReturnsDistinctResults:YES];
    [request setPropertiesToFetch: [NSArray arrayWithArray:selectedFillupsDB]];
    
    
    
    
    
    NSError *error;
    fillUpdata = [context executeFetchRequest:request error:&error];
    
    
    if(detailTypeInteger == 0){
        [self.emailDataFillup setObject:fillUpdata forKey:@"Fill-Ups"];
        if(isCsvSelected == YES){
            [self prepareFillupFile];
        }
    }
    
    if(detailTypeInteger == 1){
        [self.emailDataFillup setObject:fillUpdata forKey:@"servicesData"];
        if(isCsvSelected == YES){
            [self prepareServiceFile];
        }
    }
    
    if(detailTypeInteger == 2){
        [self.emailDataFillup setObject:fillUpdata forKey:@"expenseData"];
        if(isCsvSelected == YES){
            [self prepareExpenseFile];
        }
    }
    
    fillupCount = [[self.emailDataFillup valueForKey:@"Fill-Ups"] count];
    
    serviceCount = [[self.emailDataFillup valueForKey:@"servicesData"] count];
    
    expenseCount = [[self.emailDataFillup valueForKey:@"expenseData"] count];

}

- (void)fetchTripData{
    
    NSMutableDictionary *vehicleDict = [[NSMutableDictionary alloc] init];
    checkedTrips = [[NSMutableArray alloc] init];
    tripDate = [[NSMutableArray alloc] init];
    sequencedTrips = [[NSMutableArray alloc] init];
    
    if([self.sortedTripsArr containsObject:NSLocalizedString(@"type", @"Type")]){
        [sequencedTrips addObject:NSLocalizedString(@"type", @"Type")];
    }
    if([self.sortedTripsArr containsObject:@"Dep Date/Time"]){
        [sequencedTrips addObject:NSLocalizedString(@"date_time", @"Date/Time")];
    }
    if([self.sortedTripsArr containsObject:@"Dep Odometer"]){
        [sequencedTrips addObject:NSLocalizedString(@"odometer", @"Odometer")];
    }
    if([self.sortedTripsArr containsObject:@"Dep Location"]){
        [sequencedTrips addObject:NSLocalizedString(@"location", @"Location")];
    }
    if([self.sortedTripsArr containsObject:@"Arr Date/Time"]){
        [sequencedTrips addObject:NSLocalizedString(@"Date/Time.", @"Date/Time.")];
    }
    if([self.sortedTripsArr containsObject:@"Arr Odometer"]){
        [sequencedTrips addObject:NSLocalizedString(@"Odometer.", @"Odometer.")];
    }
    if([self.sortedTripsArr containsObject:@"Arr Location"]){
        [sequencedTrips addObject:NSLocalizedString(@"Location.", @"Location.")];
    }
    if([self.sortedTripsArr containsObject:NSLocalizedString(@"dist_traveled", @"Distance Traveled")]){
        [sequencedTrips addObject:NSLocalizedString(@"dist_traveled", @"Distance Traveled")];
    }
    if([self.sortedTripsArr containsObject:NSLocalizedString(@"time_traveled", @"Time Traveled")]){
        [sequencedTrips addObject:NSLocalizedString(@"time_traveled", @"Time Traveled")];
    }
    if([self.sortedTripsArr containsObject:NSLocalizedString(@"tax_deduction_rate", @"Tax Deduction Rate")]){
        [sequencedTrips addObject:NSLocalizedString(@"tax_deduction_rate", @"Tax Deduction Rate")];
    }
    if([self.sortedTripsArr containsObject:@"Parking"]){
        [sequencedTrips addObject:@"Parking"];
    }
    if([self.sortedTripsArr containsObject:@"Toll"]){
        [sequencedTrips addObject:@"Toll"];
    }
    if([self.sortedTripsArr containsObject:NSLocalizedString(@"tax_deduction_amount", @"Tax Deducted")]){
        [sequencedTrips addObject:NSLocalizedString(@"tax_deduction_amount", @"Tax Deducted")];
    }
    if([self.sortedTripsArr containsObject:NSLocalizedString(@"notes_tv", @"Notes")]){
        [sequencedTrips addObject:NSLocalizedString(@"notes_tv", @"Notes")];
    }

    NSArray *selectedAndMapped = [[NSArray alloc] init];
    
    [self fetchVehiclesData];

    NSManagedObjectContext *context = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"T_Trip"];
    vehicleDict = [self.vehiclearray objectAtIndex:[self.picker selectedRowInComponent:0]];
    
    
    NSDate *endDate = [[f dateFromString:_endDate.text] dateByAddingTimeInterval:24*60*60];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(vehId == %@) AND (depDate >= %@ AND depDate < %@)",[vehicleDict valueForKey:@"Id"], [f dateFromString:_startDate.text], endDate];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"depDate" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    
    [request setPredicate:predicate];
    [request setSortDescriptors:sortDescriptors];
    
    NSError *error;
    tripData = [context executeFetchRequest:request error:&error];

    
    selectedAndMapped = [[[NSUserDefaults standardUserDefaults] valueForKey:@"tripMappedData"] mutableCopy];
    
    

        for (T_Trip *tripRec in tripData) {

            NSMutableDictionary *selectedTripsDB = [[NSMutableDictionary alloc] init];
            NSMutableDictionary *dateTimeForEmail = [[NSMutableDictionary alloc] init];
            [dateTimeForEmail setObject:tripRec.depDate forKey:@"departDate"];
            [tripDate addObject:dateTimeForEmail];

            if([self.tripArray containsObject:NSLocalizedString(@"type", @"Type")]){
                [selectedTripsDB setObject:tripRec.tripType forKey:NSLocalizedString(@"type", @"Type")];
            }
            if([self.tripArray containsObject:NSLocalizedString(@"date_time", @"Date/Time")]){
                
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"dd-MMM-yyyy hh:mm aa"];
                [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
                [dateFormatter setAMSymbol:@"AM"];
                [dateFormatter setPMSymbol:@"PM"];
                NSString *depDate = [dateFormatter stringFromDate:tripRec.depDate];
                
                [selectedTripsDB setObject:depDate forKey:NSLocalizedString(@"date_time", @"Date/Time")];
                
            }
            if([self.tripArray containsObject:NSLocalizedString(@"odometer", @"Odometer")]){
                
                NSString *unitString = [[NSUserDefaults standardUserDefaults] valueForKey:@"dist_unit"];
                if([unitString isEqualToString:NSLocalizedString(@"disp_miles", @"Miles")]){
                    unitString = [unitString stringByReplacingOccurrencesOfString:NSLocalizedString(@"disp_miles", @"Miles") withString:NSLocalizedString(@"mi", @"mi")];
                }
                if([unitString isEqualToString:NSLocalizedString(@"disp_kilometers", @"Kilometers")]){
                    unitString = [unitString stringByReplacingOccurrencesOfString:NSLocalizedString(@"disp_kilometers", @"Kilometers") withString:NSLocalizedString(@"kms", @"km")];
                }
                
                NSString *roundupValueOdo = [NSString stringWithFormat:@"%.2f %@",[tripRec.depOdo floatValue], unitString];
                [selectedTripsDB setObject:roundupValueOdo forKey:NSLocalizedString(@"odometer", @"Odometer")];
            }
            if([self.tripArray containsObject:NSLocalizedString(@"location", @"Location")]){
                [selectedTripsDB setObject:tripRec.depLocn forKey:NSLocalizedString(@"location", @"Location")];
            }
            if([self.tripArray containsObject:NSLocalizedString(@"Date/Time.", @"Date/Time.")]){
                
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"dd-MMM-yyyy hh:mm aa"];
                [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
                [dateFormatter setAMSymbol:@"AM"];
                [dateFormatter setPMSymbol:@"PM"];
                NSString *arrDate = [dateFormatter stringFromDate:tripRec.arrDate];
                
                //Swapnil BUG_74
                if(arrDate != nil){
                    [selectedTripsDB setObject:arrDate forKey:NSLocalizedString(@"Date/Time.", @"Date/Time.")];
                } else {
                    [selectedTripsDB setObject:@"" forKey:NSLocalizedString(@"Date/Time.", @"Date/Time.")];
                }
            }
            if([self.tripArray containsObject:NSLocalizedString(@"Odometer.", @"Odometer.")]){
                
                NSString *unitString = [[NSUserDefaults standardUserDefaults] valueForKey:@"dist_unit"];
                if([unitString isEqualToString:NSLocalizedString(@"disp_miles", @"Miles")]){
                    unitString = [unitString stringByReplacingOccurrencesOfString:NSLocalizedString(@"disp_miles", @"Miles") withString:NSLocalizedString(@"mi", @"mi")];
                }
                if([unitString isEqualToString:NSLocalizedString(@"disp_kilometers", @"Kilometers")]){
                    unitString = [unitString stringByReplacingOccurrencesOfString:NSLocalizedString(@"disp_kilometers", @"Kilometers") withString:NSLocalizedString(@"kms", @"km")];
                }
                
                NSString *roundupValueArrOdo = [NSString stringWithFormat:@"%.2f %@",[tripRec.arrOdo floatValue], unitString];

                [selectedTripsDB setObject:roundupValueArrOdo forKey:NSLocalizedString(@"Odometer.", @"Odometer.")];
            }
            if([self.tripArray containsObject:NSLocalizedString(@"Location.", @"Location.")]){
                [selectedTripsDB setObject:tripRec.arrLocn forKey:NSLocalizedString(@"Location.", @"Location.")];
            }
            if([self.tripArray containsObject:NSLocalizedString(@"dist_traveled", @"Distance Traveled")]){

                float startOdo = [tripRec.depOdo floatValue];
                float endOdo = [tripRec.arrOdo floatValue];
                float distance;
                
                //Swapnil BUG_74
                if(endOdo == 0.0){
                    distance = 0.0;
                } else {
                    distance = endOdo - startOdo;
                }
                NSString *unitString = [[NSUserDefaults standardUserDefaults] valueForKey:@"dist_unit"];
                if([unitString isEqualToString:NSLocalizedString(@"disp_miles", @"Miles")]){
                    unitString = [unitString stringByReplacingOccurrencesOfString:NSLocalizedString(@"disp_miles", @"Miles") withString:NSLocalizedString(@"mi", @"mi")];
                }
                if([unitString isEqualToString:NSLocalizedString(@"disp_kilometers", @"Kilometers")]){
                    unitString = [unitString stringByReplacingOccurrencesOfString:NSLocalizedString(@"disp_kilometers", @"Kilometers") withString:NSLocalizedString(@"kms", @"km")];
                }
                
                NSString *roundupValueDist;
                    roundupValueDist = [NSString stringWithFormat:@"%.2f %@", distance, unitString];
                [selectedTripsDB setObject:roundupValueDist forKey:NSLocalizedString(@"dist_traveled", @"Distance Traveled")];
    
            }
            if([self.tripArray containsObject:NSLocalizedString(@"time_traveled", @"Time Traveled")]){
                
                NSDate *startDate = tripRec.depDate;
                NSDate *endDate = tripRec.arrDate;
                NSTimeInterval distanceBetweenDates = [endDate timeIntervalSinceDate:startDate];
                double secondsInAnHour = 3600;
                NSInteger hours = distanceBetweenDates / secondsInAnHour;
                NSInteger minutes = (distanceBetweenDates - (hours*3600))/60;
                
                
                NSString* hr = [NSString stringWithFormat: @"%ld", (long)hours];
                NSString* min = [NSString stringWithFormat: @"%ld", (long)minutes];
                
                
                NSString *totalTime = [[[hr stringByAppendingString:@"h "] stringByAppendingString: min] stringByAppendingString:@"m"];
                
                [selectedTripsDB setObject:totalTime forKey:NSLocalizedString(@"time_traveled", @"Time Traveled")];

            }
            if([self.tripArray containsObject:NSLocalizedString(@"tax_deduction_rate", @"Tax Deduction Rate")]){
                
                //Swapnil BUG_74
                float dedRate;
                if([tripRec.taxDedn floatValue] == 0.0){
                    dedRate = 0.0;
                } else {
                    dedRate = ([tripRec.taxDedn floatValue] - [tripRec.parkingAmt floatValue] - [tripRec.tollAmt floatValue]) / ([tripRec.arrOdo floatValue] - [tripRec.depOdo floatValue]);
                }
                NSArray *unitArr = [[[NSUserDefaults standardUserDefaults] valueForKey:@"curr_unit"] componentsSeparatedByString:@"-"];
                NSString *unitString0 = [unitArr lastObject];
                NSString *unitString1 = [[NSUserDefaults standardUserDefaults] valueForKey:@"dist_unit"];
                if([unitString1 isEqualToString:NSLocalizedString(@"disp_miles", @"Miles")]){
                    unitString1 = [unitString1 stringByReplacingOccurrencesOfString:NSLocalizedString(@"disp_miles", @"Miles") withString:NSLocalizedString(@"mi", @"mi")];
                }
                if([unitString1 isEqualToString:NSLocalizedString(@"disp_kilometers", @"Kilometers")]){
                    unitString1 = [unitString1 stringByReplacingOccurrencesOfString:NSLocalizedString(@"disp_kilometers", @"Kilometers") withString:NSLocalizedString(@"kms", @"km")];
                }
                
                NSString *dednRate = [NSString stringWithFormat:@"%.2f %@/%@", dedRate, unitString0, unitString1];
                [selectedTripsDB setObject:dednRate forKey:NSLocalizedString(@"tax_deduction_rate", @"Tax Deduction Rate")];
            }
            if([self.tripArray containsObject:@"Parking"]){
                NSArray *unitArr = [[[NSUserDefaults standardUserDefaults] valueForKey:@"curr_unit"] componentsSeparatedByString:@"-"];
                NSString *unitString = [unitArr lastObject];
                
                NSString *roundupValueParking = [NSString stringWithFormat:@"%.2f %@",[tripRec.parkingAmt floatValue], unitString];
                [selectedTripsDB setObject:roundupValueParking forKey:@"Parking"];
            }
            if([self.tripArray containsObject:@"Toll"]){
                NSArray *unitArr = [[[NSUserDefaults standardUserDefaults] valueForKey:@"curr_unit"] componentsSeparatedByString:@"-"];
                NSString *unitString = [unitArr lastObject];
                
                NSString *roundupValueToll = [NSString stringWithFormat:@"%.2f %@",[tripRec.tollAmt floatValue], unitString];
                [selectedTripsDB setObject:roundupValueToll forKey:@"Toll"];
            }
            if([self.tripArray containsObject:NSLocalizedString(@"tax_deduction_amount", @"Tax Deducted")]){
                NSArray *unitArr = [[[NSUserDefaults standardUserDefaults] valueForKey:@"curr_unit"] componentsSeparatedByString:@"-"];
                NSString *unitString = [unitArr lastObject];
                
                NSString *roundupValueTaxDed = [NSString stringWithFormat:@"%.2f %@",[tripRec.taxDedn floatValue], unitString];
                [selectedTripsDB setObject:roundupValueTaxDed forKey:NSLocalizedString(@"tax_deduction_amount", @"Tax Deducted")];
            }
            if([self.tripArray containsObject:NSLocalizedString(@"notes_tv", @"Notes")]){
                [selectedTripsDB setObject:tripRec.notes forKey:NSLocalizedString(@"notes_tv", @"Notes")];
            }
            [checkedTrips addObject:selectedTripsDB];
    }
    
    if([self.tripArray containsObject:NSLocalizedString(@"trip_by_type_tv", @"Dist by Type")] || [self.tripArray containsObject:NSLocalizedString(@"tax_ded_by_type_tv", @"Tax Ded by type")]){
        
        float distByType = 0.0;
        float dednByType = 0.0;

        self.distByTypeArr = [[NSMutableArray alloc] init];
        self.taxDednByTypeArr = [[NSMutableArray alloc] init];
        self.tripTypeArray = [[NSMutableArray alloc] init];
        //NSMutableArray *tripTypeArr = [[NSMutableArray alloc] init];
        self.tripTypeDictArray = [[NSMutableArray alloc] init];
        
        for(T_Trip *trip in tripData){
            
            NSString *tripType = trip.tripType;
            if(![self.tripTypeArray containsObject:tripType]){
                [self.tripTypeArray addObject:tripType];
                NSMutableDictionary *tripTypeDict = [[NSMutableDictionary alloc] init];
                [tripTypeDict setValue:tripType forKey:@"type"];
                
                [self.tripTypeDictArray addObject:tripTypeDict];
            }
        }
        
        for (T_Trip *trip in tripData) {
            
            for (NSString* type in self.tripTypeArray) {
                if ([trip.tripType isEqualToString:type]) {
                    
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type == %@", type];
                    NSArray* dict = [self.tripTypeDictArray filteredArrayUsingPredicate:predicate];
                    
                    //Swapnil BUG_74
                    float distance;
                    if([trip.arrOdo floatValue] == 0.0){
                        distance = 0.0;
                    } else {
                        distance = [trip.arrOdo floatValue] - [trip.depOdo floatValue];
                    }
                    float taxDedc = [trip.taxDedn floatValue];
                    
                    distByType = [[[dict firstObject] valueForKey:@"distance"] floatValue] + distance;
                    dednByType = [[[dict firstObject] valueForKey:@"tax"] floatValue] + taxDedc;
                    
                    [[dict firstObject] setValue:[NSNumber numberWithFloat: distByType] forKey:@"distance"];
                    [[dict firstObject] setValue:[NSNumber numberWithFloat: dednByType] forKey:@"tax"];
                    
                }
            }
            
            
        }
        
        self.distByTypeArr = [self.tripTypeDictArray valueForKey:@"distance"];
        self.taxDednByTypeArr = [self.tripTypeDictArray valueForKey:@"tax"];

    }

    if(isCsvSelected == YES){
        if(checkedTrips.count != 0){
            [self prepareTripsFile];
        }
    }
}

#pragma mark - ATTACH CSV

//FILL UP
- (void)prepareFillupFile{
    
    NSString *FillString = [self exportFillupCSV];
    // Writing
    
    //Swapnil ENH_24
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    
    self.fillupFilePath = [documentsPath stringByAppendingPathComponent:@"Fuel_Log.csv"];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:self.fillupFilePath];
    NSError *error;
    
    if (fileExists)    //Does file exist?
    {
        if (![[NSFileManager defaultManager] removeItemAtPath:self.fillupFilePath error:&error])   //Delete it
        {
            //NSLog(@"Delete file error: %@", error);
        }
    }
    
    [FillString writeToFile:self.fillupFilePath atomically:YES encoding:NSUTF8StringEncoding error:NULL];
}

- (NSString *)exportFillupCSV{
    
    NSMutableArray *results = [[NSMutableArray alloc] init];
    NSArray *fillupCSV = [[NSArray alloc] init];
    NSMutableArray *selectedCSVs = [[NSMutableArray alloc] init];
    NSArray *fillsSelected = [[NSUserDefaults standardUserDefaults] valueForKey:@"sortedFills"];
    
    [selectedCSVs addObject:@"Vehicle"];
    [selectedCSVs addObject:@"Date"];

    for(int i = 0; i < fillsSelected.count; i++){
        
        if([[fillsSelected objectAtIndex:i] isEqualToString:NSLocalizedString(@"attach_receipt", @"Attach Receipt")]){
            [selectedCSVs addObject:@"Receipt"];
        } else {
            [selectedCSVs addObject:[fillsSelected objectAtIndex:i]];
        }
    }
    
    fillupCSV = [self.emailDataFillup valueForKey:@"Fill-Ups"];
    NSString *firstRow = [selectedCSVs componentsJoinedByString:@","];
    
    [results addObject:firstRow];
    
    NSDateFormatter *formater=[[NSDateFormatter alloc] init];
    [formater setDateFormat:@"dd/MM/yyyy"];
    
    for(int i = 0; i < fillupCSV.count; i++){
        
        NSMutableArray *selectedResults = [[NSMutableArray alloc] init];
        NSString *date = [formater stringFromDate:[[fillupCSV objectAtIndex:i] valueForKey:@"stringDate"]];
        NSString *odometer = [NSString stringWithFormat:@"%.2f", [[[fillupCSV objectAtIndex:i] valueForKey:@"odo"] floatValue]];
        NSString *qty = [NSString stringWithFormat:@"%.3f", [[[fillupCSV objectAtIndex:i] valueForKey:@"qty"] floatValue]];
        NSString *distance = [NSString stringWithFormat:@"%.2f", [[[fillupCSV objectAtIndex:i] valueForKey:@"dist"] floatValue]];
        NSString *cost = [NSString stringWithFormat:@"%.2f", [[[fillupCSV objectAtIndex:i] valueForKey:@"cost"] floatValue]];
        NSString *consumption = [NSString stringWithFormat:@"%.2f", [[[fillupCSV objectAtIndex:i] valueForKey:@"cons"] floatValue]];
        
        [selectedResults addObject:[NSString stringWithFormat:@"%@,%@", self.vehicleFetched, date]];
        if([selectedCSVs containsObject:NSLocalizedString(@"odometer", @"Odometer")]){
            [selectedResults addObject:odometer];
        }
        if([selectedCSVs containsObject:NSLocalizedString(@"qty_tv", @"Quantity")]){
            [selectedResults addObject:qty];
        }
        if([selectedCSVs containsObject:NSLocalizedString(@"dist_tv", @"Distance")]){
            [selectedResults addObject:distance];
        }
        if([selectedCSVs containsObject:NSLocalizedString(@"tc_tv", @"Total Cost")]){
            [selectedResults addObject:cost];
        }
        if([selectedCSVs containsObject:NSLocalizedString(@"cons_head", @"Consumption")]){
            [selectedResults addObject:consumption];
        }
        if([selectedCSVs containsObject:NSLocalizedString(@"pf_tv", @"Partial Tank")]){
            [selectedResults addObject:[[fillupCSV objectAtIndex:i] valueForKey:@"pfill"]];
        }
        //crash resolved crash #242 #248
        //BUG_157 NIKHIL keyName octane changed to ocatne
        if([selectedCSVs containsObject:NSLocalizedString(@"octane", @"Octane")]){
            [selectedResults addObject:[[fillupCSV objectAtIndex:i] valueForKey:@"octane"]];
        }
        if([selectedCSVs containsObject:NSLocalizedString(@"fb_tv", @"Fuel Brand")]){
            [selectedResults addObject:[[fillupCSV objectAtIndex:i] valueForKey:@"fuelBrand"]];
        }
        if([selectedCSVs containsObject:NSLocalizedString(@"fs_tv", @"Filling Station")]){
            [selectedResults addObject:[[fillupCSV objectAtIndex:i] valueForKey:@"fillStation"]];
        }
        if([selectedCSVs containsObject:NSLocalizedString(@"notes_tv", @"Notes")]){
            [selectedResults addObject:[[fillupCSV objectAtIndex:i] valueForKey:@"notes"]];
        }
        if([selectedCSVs containsObject:NSLocalizedString(@"receipt", @"Receipt")]){
            if([[fillupCSV objectAtIndex:i] valueForKey:@"receipt"] != nil){
                [selectedResults addObject:[[fillupCSV objectAtIndex:i] valueForKey:@"receipt"]];
            } else {
                [selectedResults addObject:@""];
            }
        }
        NSString *selectedResultString = [selectedResults componentsJoinedByString:@","];
        [results addObject:selectedResultString];
        
    }
    
    
    NSString *resultString = [results componentsJoinedByString:@"\n"];
    resultString =  [resultString stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
    
    return resultString;
    
}


//SERVICES
- (void)prepareServiceFile{
    
    NSString* str= [self exportServiceCSV];
    
    // Writing
    
    //Swapnil ENH_24
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    
    self.serviceFilePath = [documentsPath stringByAppendingPathComponent:@"Services.csv"];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:self.serviceFilePath];
    NSError *error;
    
    if (fileExists)    //Does file exist?
    {
        if (![[NSFileManager defaultManager] removeItemAtPath:self.serviceFilePath error:&error])   //Delete it
        {
            //NSLog(@"Delete file error: %@", error);
        }
    }
    
    [str writeToFile:self.serviceFilePath atomically:YES encoding:NSUTF8StringEncoding error:NULL];
}

- (NSString *)exportServiceCSV{
    
    NSMutableArray *results = [[NSMutableArray alloc] init];
    NSArray *serviceCSV = [[NSArray alloc] init];
    NSMutableArray *selectedCSVs = [[NSMutableArray alloc] init];
    NSArray *serviceSelected = [[NSUserDefaults standardUserDefaults] valueForKey:@"sortedService"];

    [selectedCSVs addObject:@"Vehicle"];
    [selectedCSVs addObject:@"Date"];
    
    if([serviceSelected containsObject:NSLocalizedString(@"odometer", @"Odometer")]){
        [selectedCSVs addObject:@"Odometer"];
    }
    if([serviceSelected containsObject:NSLocalizedString(@"tc_tv", @"Total Cost")]){
        [selectedCSVs addObject:@"Total Cost"];
    }
    if([serviceSelected containsObject:NSLocalizedString(@"tv_service_center", @"Service Center")]){
        [selectedCSVs addObject:@"Service Center"];
    }
    if([serviceSelected containsObject:NSLocalizedString(@"notes_tv", @"Notes")]){
        [selectedCSVs addObject:@"Notes"];
    }
    if([serviceSelected containsObject:NSLocalizedString(@"attach_receipt", @"Attach Receipt")]){
        [selectedCSVs addObject:@"Receipt"];
    }
    if([serviceSelected containsObject:NSLocalizedString(@"tot_services", @"Services")]){
        [selectedCSVs addObject:@"Services"];
    }

    
    
    serviceCSV = [self.emailDataFillup valueForKey:@"servicesData"];
    NSString *firstRow = [selectedCSVs componentsJoinedByString:@","];
    [results addObject:firstRow];
    
    NSDateFormatter *formater=[[NSDateFormatter alloc] init];
    [formater setDateFormat:@"dd/MM/yyyy"];
    
    for(int i = 0; i < serviceCSV.count; i++){
        
        NSMutableArray *selectedResults = [[NSMutableArray alloc] init];
        NSString *date = [formater stringFromDate:[[serviceCSV objectAtIndex:i] valueForKey:@"stringDate"]];
        NSString *odometer = [NSString stringWithFormat:@"%.2f", [[[serviceCSV objectAtIndex:i] valueForKey:@"odo"] floatValue]];
        NSString *cost = [NSString stringWithFormat:@"%.2f", [[[serviceCSV objectAtIndex:i] valueForKey:@"cost"] floatValue]];

        [selectedResults addObject:[NSString stringWithFormat:@"%@,%@", self.vehicleFetched, date]];
        if([selectedCSVs containsObject:NSLocalizedString(@"odometer", @"Odometer")]){
            [selectedResults addObject:odometer];
        }
        if([selectedCSVs containsObject:NSLocalizedString(@"tc_tv", @"Total Cost")]){
            [selectedResults addObject:cost];
        }
        if([selectedCSVs containsObject:NSLocalizedString(@"tv_service_center", @"Service Center")]){
            [selectedResults addObject:[[serviceCSV objectAtIndex:i] valueForKey:@"fillStation"]];
        }
        if([selectedCSVs containsObject:NSLocalizedString(@"notes_tv", @"Notes")]){
            [selectedResults addObject:[[serviceCSV objectAtIndex:i] valueForKey:@"notes"]];
        }
        if([selectedCSVs containsObject:NSLocalizedString(@"receipt", @"Receipt")]){
            
            if([[serviceCSV objectAtIndex:i] valueForKey:@"receipt"] != nil){
                [selectedResults addObject:[[serviceCSV objectAtIndex:i] valueForKey:@"receipt"]];
            } else {
                [selectedResults addObject:@"(null)"];
            }
        }
        if([selectedCSVs containsObject:NSLocalizedString(@"tot_services", @"Services")]){
            [selectedResults addObject:[[serviceCSV objectAtIndex:i] valueForKey:@"serviceType"]];
        }
        
        NSString *selectedResultString = [selectedResults componentsJoinedByString:@","];
        [results addObject:selectedResultString];

    }
    
    NSString *resultString = [results componentsJoinedByString:@"\n"];
    resultString =  [resultString stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
    
    return resultString;
}

//EXPENSES
- (void)prepareExpenseFile{
    
    NSString* str= [self exportExpenseCSV];
    
    // Writing
    
    //Swapnil ENH_24
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    
    self.expenseFilePath = [documentsPath stringByAppendingPathComponent:@"Expenses.csv"];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:self.expenseFilePath];
    NSError *error;
    
    if (fileExists)    //Does file exist?
    {
        if (![[NSFileManager defaultManager] removeItemAtPath:self.expenseFilePath error:&error])   //Delete it
        {
            //NSLog(@"Delete file error: %@", error);
        }
    }
    
    [str writeToFile:self.expenseFilePath atomically:YES encoding:NSUTF8StringEncoding error:NULL];
}

- (NSString *)exportExpenseCSV{
    
    NSMutableArray *results = [[NSMutableArray alloc] init];
    NSArray *expenseCSV = [[NSArray alloc] init];
    NSMutableArray *selectedCSVs = [[NSMutableArray alloc] init];
    NSArray *expenseSelected = [[NSUserDefaults standardUserDefaults] valueForKey:@"sortedExpense"];

    [selectedCSVs addObject:@"Vehicle"];
    [selectedCSVs addObject:@"Date"];

    if([expenseSelected containsObject:NSLocalizedString(@"odometer", @"Odometer")]){
        [selectedCSVs addObject:@"Odometer"];
    }
    if([expenseSelected containsObject:NSLocalizedString(@"tc_tv", @"Total Cost")]){
        [selectedCSVs addObject:@"Total Cost"];
    }
    if([expenseSelected containsObject:NSLocalizedString(@"tv_vendor", @"Vendor")]){
        [selectedCSVs addObject:@"Vendor"];
    }
    if([expenseSelected containsObject:NSLocalizedString(@"notes_tv", @"Notes")]){
        [selectedCSVs addObject:@"Notes"];
    }
    if([expenseSelected containsObject:NSLocalizedString(@"attach_receipt", @"Attach Receipt")]){
        [selectedCSVs addObject:@"Receipt"];
    }
    if([expenseSelected containsObject:NSLocalizedString(@"tv_expenses", @"Expenses")]){
        [selectedCSVs addObject:@"Expenses"];
    }
    
    
    expenseCSV = [self.emailDataFillup valueForKey:@"expenseData"];
    NSString *firstRow = [selectedCSVs componentsJoinedByString:@","];
    [results addObject:firstRow];
    
    NSDateFormatter *formater=[[NSDateFormatter alloc] init];
    [formater setDateFormat:@"dd/MM/yyyy"];
    
    for(int i = 0; i < expenseCSV.count; i++){
        
        NSMutableArray *selectedResults = [[NSMutableArray alloc] init];

        NSString *date = [formater stringFromDate:[[expenseCSV objectAtIndex:i] valueForKey:@"stringDate"]];
        NSString *odometer = [NSString stringWithFormat:@"%.2f", [[[expenseCSV objectAtIndex:i] valueForKey:@"odo"] floatValue]];
        NSString *cost = [NSString stringWithFormat:@"%.2f", [[[expenseCSV objectAtIndex:i] valueForKey:@"cost"] floatValue]];
        
        [selectedResults addObject:[NSString stringWithFormat:@"%@,%@", self.vehicleFetched, date]];
        
        if([selectedCSVs containsObject:NSLocalizedString(@"odometer", @"Odometer")]){
            [selectedResults addObject:odometer];
        }
        if([selectedCSVs containsObject:NSLocalizedString(@"tc_tv", @"Total Cost")]){
            [selectedResults addObject:cost];
        }
        if([selectedCSVs containsObject:NSLocalizedString(@"tv_vendor", @"Vendor")]){
            [selectedResults addObject:[[expenseCSV objectAtIndex:i] valueForKey:@"fillStation"]];
        }
        if([selectedCSVs containsObject:NSLocalizedString(@"notes_tv", @"Notes")]){
            [selectedResults addObject:[[expenseCSV objectAtIndex:i] valueForKey:@"notes"]];
        }
        if([selectedCSVs containsObject:NSLocalizedString(@"receipt", @"Receipt")]){
            
            if([[expenseCSV objectAtIndex:i] valueForKey:@"receipt"] != nil){
                [selectedResults addObject:[[expenseCSV objectAtIndex:i] valueForKey:@"receipt"]];
            } else {
                [selectedResults addObject:@""];
            }
        }
        if([selectedCSVs containsObject:NSLocalizedString(@"tv_expenses", @"Expenses")]){
            [selectedResults addObject:[[expenseCSV objectAtIndex:i] valueForKey:@"serviceType"]];
        }
        
        NSString *selectedResultString = [selectedResults componentsJoinedByString:@","];
        [results addObject:selectedResultString];
    }

    NSString *resultString = [results componentsJoinedByString:@"\n"];
    resultString =  [resultString stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
    
    return resultString;
}


//TRIPS

-(void) prepareTripsFile
{
    NSString* str = [self exportTripCSV];
    
    // Writing
    
    //Swapnil ENH_24
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    
    self.tripFilePath = [documentsPath stringByAppendingPathComponent:@"Trip_Log.csv"];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:self.tripFilePath];
    NSError *error;
    
    if (fileExists)    //Does file exist?
    {
        if (![[NSFileManager defaultManager] removeItemAtPath:self.tripFilePath error:&error])   //Delete it
        {
            //NSLog(@"Delete file error: %@", error);
        }
    }
    
    [str writeToFile:self.tripFilePath atomically:YES encoding:NSUTF8StringEncoding error:NULL];
}

- (NSString *)exportTripCSV{
    
    NSMutableArray *results = [[NSMutableArray alloc] init];
    NSMutableArray *selectedCSVs = [[NSMutableArray alloc] init];

    [selectedCSVs addObject:@"Vehicle"];
    
    if([self.sortedTripsArr containsObject:NSLocalizedString(@"type", @"Type")]){
        [selectedCSVs addObject:@"Type"];
    }
    if([self.sortedTripsArr containsObject:@"Dep Date/Time"]){
        [selectedCSVs addObject:@"Dep Date/Time"];
    }
    if([self.sortedTripsArr containsObject:@"Dep Odometer"]){
        [selectedCSVs addObject:@"Dep Odometer"];
    }
    if([self.sortedTripsArr containsObject:@"Dep Location"]){
        [selectedCSVs addObject:@"Dep Location"];
    }
    if([self.sortedTripsArr containsObject:@"Arr Date/Time"]){
        [selectedCSVs addObject:@"Arr Date/Time"];
    }
    if([self.sortedTripsArr containsObject:@"Arr Odometer"]){
        [selectedCSVs addObject:@"Arr Odometer"];
    }
    if([self.sortedTripsArr containsObject:@"Arr Location"]){
        [selectedCSVs addObject:@"Arr Location"];
    }
    if([self.sortedTripsArr containsObject:NSLocalizedString(@"dist_traveled", @"Distance Traveled")]){
        [selectedCSVs addObject:@"Distance Traveled"];
    }
    if([self.sortedTripsArr containsObject:NSLocalizedString(@"time_traveled", @"Time Traveled")]){
        [selectedCSVs addObject:@"Time Traveled"];
    }
    if([self.sortedTripsArr containsObject:NSLocalizedString(@"tax_deduction_rate", @"Tax Deduction Rate")]){
        [selectedCSVs addObject:@"Tax Deduction Rate"];
    }
    if([self.sortedTripsArr containsObject:@"Parking"]){
        [selectedCSVs addObject:@"Parking"];
    }
    if([self.sortedTripsArr containsObject:@"Toll"]){
        [selectedCSVs addObject:@"Toll"];
    }
    if([self.sortedTripsArr containsObject:NSLocalizedString(@"tax_deduction_amount", @"Tax Deducted")]){
        [selectedCSVs addObject:@"Tax Deducted"];
    }
    if([self.sortedTripsArr containsObject:NSLocalizedString(@"notes_tv", @"Notes")]){
        [selectedCSVs addObject:@"Notes"];
    }

    NSString *firstRow = [selectedCSVs componentsJoinedByString:@","];
    [results addObject:firstRow];
    
    for(T_Trip *tripRecord in tripData){
        
        NSMutableArray *selectedResults = [[NSMutableArray alloc] init];

        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"dd-MMM-yyyy hh:mm aa"];
        [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
        [dateFormatter setAMSymbol:@"AM"];
        [dateFormatter setPMSymbol:@"PM"];
        NSString *depDate = [dateFormatter stringFromDate:tripRecord.depDate];
        NSString *arrDate = [dateFormatter stringFromDate:tripRecord.arrDate];

        
        float startOdo = [tripRecord.depOdo floatValue];
        float endOdo = [tripRecord.arrOdo floatValue];
        float distance = endOdo - startOdo;
        NSString *distTraveled = [NSString stringWithFormat:@"%.2f", distance];
        
        NSDate *startDate = tripRecord.depDate;
        NSDate *endDate = tripRecord.arrDate;
        NSTimeInterval distanceBetweenDates = [endDate timeIntervalSinceDate:startDate];
        double secondsInAnHour = 3600;
        NSInteger hours = distanceBetweenDates / secondsInAnHour;
        NSInteger minutes = (distanceBetweenDates - (hours*3600))/60;
        
        
        NSString* hr = [NSString stringWithFormat: @"%ld", (long)hours];
        NSString* min = [NSString stringWithFormat: @"%ld", (long)minutes];
        
        
        NSString *totalTime = [[[hr stringByAppendingString:@"h "] stringByAppendingString: min] stringByAppendingString:@"m"];
        
        float dedRate = ([tripRecord.taxDedn floatValue] - [tripRecord.parkingAmt floatValue] - [tripRecord.tollAmt floatValue]) / ([tripRecord.arrOdo floatValue] - [tripRecord.depOdo floatValue]);
        NSString *taxDedRate = [NSString stringWithFormat:@"%.2f", dedRate];
        
        NSString *taxDeducted = [NSString stringWithFormat:@"%.2f", [tripRecord.taxDedn floatValue]];
        
        [selectedResults addObject:[NSString stringWithFormat:@"%@", self.vehicleFetched]];
        
        if([selectedCSVs containsObject:NSLocalizedString(@"type", @"Type")]){
            [selectedResults addObject:tripRecord.tripType];
        }
        if([selectedCSVs containsObject:@"Dep Date/Time"]){
            [selectedResults addObject:depDate];
        }
        if([selectedCSVs containsObject:@"Dep Odometer"]){
            [selectedResults addObject:tripRecord.depOdo];
        }
        if([selectedCSVs containsObject:@"Dep Location"]){
            [selectedResults addObject:tripRecord.depLocn];
        }
        if([selectedCSVs containsObject:@"Arr Date/Time"]){
            
            //Swapnil BUG_74
            if(arrDate != nil){
                [selectedResults addObject:arrDate];
            } else {
                [selectedResults addObject:@""];
            }
        }
        if([selectedCSVs containsObject:@"Arr Odometer"]){
            [selectedResults addObject:tripRecord.arrOdo];
        }
        if([selectedCSVs containsObject:@"Arr Location"]){
            [selectedResults addObject:tripRecord.arrLocn];
        }
        if([selectedCSVs containsObject:NSLocalizedString(@"dist_traveled", @"Distance Traveled")]){
            [selectedResults addObject:distTraveled];
        }
        if([selectedCSVs containsObject:NSLocalizedString(@"time_traveled", @"Time Traveled")]){
            [selectedResults addObject:totalTime];
        }
        if([selectedCSVs containsObject:NSLocalizedString(@"tax_deduction_rate", @"Tax Deduction Rate")]){
            [selectedResults addObject:taxDedRate];
        }
        if([selectedCSVs containsObject:@"Parking"]){
            [selectedResults addObject:tripRecord.parkingAmt];
        }
        if([selectedCSVs containsObject:@"Toll"]){
            [selectedResults addObject:tripRecord.tollAmt];
        }
        if([selectedCSVs containsObject:NSLocalizedString(@"tax_deduction_amount", @"Tax Deducted")]){
            [selectedResults addObject:taxDeducted];
        }
        if([selectedCSVs containsObject:NSLocalizedString(@"notes_tv", @"Notes")]){
            [selectedResults addObject:tripRecord.notes];
        }
        
        NSString *selectedResultString = [selectedResults componentsJoinedByString:@","];
        [results addObject:selectedResultString];
        
    }
    NSString *resultString = [results componentsJoinedByString:@"\n"];
    resultString =  [resultString stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
    
    return resultString;

}



#pragma mark - PRO VERSION METHODS

- (void)goProAlert{
    
    if(mailCount == 0){
        firstCount = 5;
    }
    if(mailCount == 1){
        firstCount = 4;
    }
    if(mailCount == 2){
        firstCount = 3;
    }
    if(mailCount == 3){
        firstCount = 2;
    }
    if(mailCount == 4){
        firstCount = 1;
    }
    if(mailCount == 5){
        firstCount = 0;
    }
    
    if(mailCount == 5){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Trial Period"
                                                                       message:[NSString stringWithFormat:@"Email is a PRO feature. Free Emails remaining: %ld", (long)firstCount] preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancel = [UIAlertAction actionWithTitle: NSLocalizedString(@"cancel", @"Cancel")
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action)
        {
            [alert dismissViewControllerAnimated:NO completion:nil];
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        }];
        
        UIAlertAction *goPro = [UIAlertAction actionWithTitle: NSLocalizedString(@"go_pro_btn", @"Go Pro")
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull action)
        {
            GoProViewController *gopro = (GoProViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"gopro"];
            dispatch_async(dispatch_get_main_queue(), ^{
                gopro.modalPresentationStyle = UIModalPresentationFullScreen;
                [self presentViewController:gopro animated:YES completion:nil];
            });
        }];
        
        
        
        [alert addAction:cancel];
        [alert addAction:goPro];
        
        [self presentViewController:alert animated:NO completion:nil];
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Trial Period" message:[NSString stringWithFormat:@"Email is a PRO feature. Free Emails remaining: %ld", (long)firstCount] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"Cancel") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [alert dismissViewControllerAnimated:NO completion:nil];
        }];
        UIAlertAction *goPro = [UIAlertAction actionWithTitle:NSLocalizedString(@"go_pro_btn", @"Go Pro") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            GoProViewController *gopro = (GoProViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"gopro"];
            dispatch_async(dispatch_get_main_queue(), ^{
                gopro.modalPresentationStyle = UIModalPresentationFullScreen;
                [self presentViewController:gopro animated:YES completion:nil];
            });
        }];

        
        
        [alert addAction:cancel];
        [alert addAction:goPro];

    [self presentViewController:alert animated:NO completion:nil];
    }
}


@end
