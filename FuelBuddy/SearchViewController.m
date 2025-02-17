//
//  SearchViewController.m
//  FuelBuddy
//
//  Created by surabhi on 01/03/16.
//  Copyright © 2016 Oraganization. All rights reserved.
//

#import "SearchViewController.h"
#import "Veh_Table.h"
#import "AppDelegate.h"

@interface SearchViewController ()

@end

// static GADMasterViewController *shared;
@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    
    [self.tabBarController.tabBar setHidden:YES];
    AppDelegate *App = [AppDelegate sharedAppDelegate];
    App.tabbutton.hidden=YES;

    _vehimage.layer.borderWidth=0;
    _vehimage.layer.masksToBounds=YES;
    self.vehimage.layer.cornerRadius = 21;
    
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
    [self.selectveh addTarget:self action:@selector(openselectpicker) forControlEvents:UIControlEventTouchUpInside];
    UITapGestureRecognizer *Tap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(openselectpicker)];
    [_vehdropdown addGestureRecognizer:Tap];
     [self.Datefilter addTarget:self action:@selector(opendatefilter) forControlEvents:UIControlEventTouchUpInside];
    
    UITapGestureRecognizer *Tap1 =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(opendatefilter)];
    [_datedropdown addGestureRecognizer:Tap1];
     [self.Odofilter addTarget:self action:@selector(openodofilter) forControlEvents:UIControlEventTouchUpInside];
    
    UITapGestureRecognizer *Tap2 =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(openodofilter)];
    [_ododropdown addGestureRecognizer:Tap2];
    [self.Pickdate addTarget:self action:@selector(openpicker:) forControlEvents:UIControlEventTouchUpInside];
    [self.Recordtype addTarget:self action:@selector(openrecordfilter)
              forControlEvents:UIControlEventTouchUpInside];
    UITapGestureRecognizer *Tap3 =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(openrecordfilter)];
    [_recorddropdown addGestureRecognizer:Tap3];
   //self.Datefilter.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
   // self.Odofilter.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.view.backgroundColor = [self colorFromHexString:@"#2c2c2c"];
    UIColor *color = [UIColor darkGrayColor];
    NSString *string;
    if([[[NSUserDefaults standardUserDefaults]objectForKey:@"dist_unit"] isEqualToString:NSLocalizedString(@"disp_miles", @"Miles")])
    {
        string = NSLocalizedString(@"mi", @"mi");
    }
    
    else
    {
       string = NSLocalizedString(@"kms", @"km");
    }

    NSString *odostring = [NSString stringWithFormat:@"%@ (%@)", NSLocalizedString(@"odometer", @"Odometer") ,string];
   self.Odotext.attributedPlaceholder = [[NSAttributedString alloc] initWithString:odostring attributes:@{NSForegroundColorAttributeName: color}];
    
   //NSString *search_notes_hint = @"Notes Containing (separate with comma)";
    
    self.Notetext.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"search_notes_hint", @"notes containing") attributes:@{NSForegroundColorAttributeName: color}];
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.barStyle = UIBarStyleDefault;
    numberToolbar.backgroundColor =[UIColor whiteColor];
    numberToolbar.items = [NSArray arrayWithObjects:[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad)],
                           nil];
    
    [numberToolbar sizeToFit];
    self.Odotext.inputAccessoryView = numberToolbar;
    self.Odotext.delegate=self;
    self.Notetext.delegate=self;
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,20, 20)];
   self.Odotext.leftView = paddingView;
   self.Odotext.leftViewMode = UITextFieldViewModeAlways;
    
    UIView *paddingView1 = [[UIView alloc] initWithFrame:CGRectMake(0,0,20,20)];
    self.Notetext.leftView = paddingView1;
    self.Notetext.leftViewMode = UITextFieldViewModeAlways;
    UIImage *buttonImage = [UIImage imageNamed:@"nav_back"];
    
    UIButton *Button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [Button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    
    Button.frame = CGRectMake(0.0, 0.0, buttonImage.size.width,buttonImage.size.height);
    
    UIBarButtonItem *BarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:Button];
    
    [Button addTarget:self action:@selector(backbuttonclick) forControlEvents:UIControlEventTouchUpInside];
    
    [self.navigationItem setLeftBarButtonItem:BarButtonItem];
    
    //NSString *search_rec = @"Search Record";
    self.title = NSLocalizedString(@"search_rec", @"Search Record");

    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"search", @"Search") style:UIBarButtonItemStylePlain target:self action:@selector(addsearch)];
    
    if([[NSUserDefaults standardUserDefaults]objectForKey:@"odovalue"]!=nil)
    {
        self.Odotext.text = [[NSUserDefaults standardUserDefaults]objectForKey:@"odovalue"];
    }
    
    if([[NSUserDefaults standardUserDefaults]objectForKey:@"datevalue"]!=nil)
    {
        [self.Pickdate setTitle:[[NSUserDefaults standardUserDefaults]objectForKey:@"datevalue"] forState:UIControlStateNormal];
    }
    
    if([[NSUserDefaults standardUserDefaults]objectForKey:@"notefilter"]!=nil)
    {
        self.Notetext.text = [[NSUserDefaults standardUserDefaults]objectForKey:@"notefilter"];
    }
    
    if([[NSUserDefaults standardUserDefaults]objectForKey:@"odofilter"]!=nil)
    {
       [self.Odofilter setTitle:[[NSUserDefaults standardUserDefaults]objectForKey:@"odofilter"] forState:UIControlStateNormal];
    }
    
    if([[NSUserDefaults standardUserDefaults]objectForKey:@"recordfilter"]!=nil)
    {
        self.recordlabel.text = [[NSUserDefaults standardUserDefaults]objectForKey:@"recordfilter"];
    }
    
    if([[NSUserDefaults standardUserDefaults]objectForKey:@"datefilter"]!=nil)
    {
        self.DateLabel.text = [[NSUserDefaults standardUserDefaults]objectForKey:@"datefilter"];
    }

}


-(void)addsearch
{
    
    if(self.Odotext.text.length !=0)
    {
        [[NSUserDefaults standardUserDefaults]setObject:self.Odotext.text forKey:@"odovalue"];
        [[NSUserDefaults standardUserDefaults]setObject:self.Odofilter.titleLabel.text forKey:@"odofilter"];
    }
    
    //NSLog(@"date text %@",self.Datefilter.titleLabel.text);
    if(![self.Pickdate.titleLabel.text isEqualToString:NSLocalizedString(@"date", @"Date")])
    {
        [[NSUserDefaults standardUserDefaults]setObject:self.Pickdate.titleLabel.text forKey:@"datevalue"];
        [[NSUserDefaults standardUserDefaults]setObject:self.DateLabel.text forKey:@"datefilter"];
    }
    
    if(self.Notetext.text.length!=0)
    {
         [[NSUserDefaults standardUserDefaults]setObject:self.Notetext.text forKey:@"notefilter"];
    }
    
    if(![self.recordlabel.text isEqualToString:NSLocalizedString(@"record_type", @"Record Type")])
    {
         [[NSUserDefaults standardUserDefaults]setObject:self.recordlabel.text forKey:@"recordfilter"];
    }
    [self.navigationController popViewControllerAnimated:YES];
}



-(void)backbuttonclick
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)doneWithNumberPad
{
    [self.Odotext resignFirstResponder];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if(self.Odotext.text.length ==0)
    {
        [[NSUserDefaults standardUserDefaults]setObject:nil
                                                 forKey:@"odovalue"];
        [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"odofilter"];
    }
    
    if(self.Notetext.text.length ==0)
    {
        [[NSUserDefaults standardUserDefaults]setObject:nil
                                                 forKey:@"notefilter"];
       
    }
}
-(UIColor *)colorFromHexString:(NSString *)hexString
{
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

-(void)opendatefilter
{
    
    self.filtervalue =[[NSMutableArray alloc]initWithObjects:NSLocalizedString(@"search_date_filter_0", @"Date greater than"),NSLocalizedString(@"search_date_filter_1", @"Date less than"), nil];
    
//    _timesetale=[[UIAlertView alloc] initWithTitle:@"Select" message:nil delegate:self cancelButtonTitle:@"SET" otherButtonTitles:nil];
//    [_picker removeFromSuperview];
//    _picker = [[UIPickerView alloc]init];
//    _picker.backgroundColor=[UIColor grayColor];
//    _picker.layer.cornerRadius=5.0f;
//    _picker.clipsToBounds=YES;
//    _picker.delegate =self;
//    _picker.dataSource=self;
//    _picker.tag=-7;
//    self.pickerval = @"Select";
//    [_timesetale setTitle:@"Select"];
//    _timesetale.tag =2;
//    [_timesetale setValue:_picker forKey:@"accessoryView"];
//    [_timesetale show];
    
    
    [_picker removeFromSuperview];
    _picker = [[UIPickerView alloc]init];
    AppDelegate *App = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    _picker.frame = CGRectMake(App.result.width/2-130,App.result.height/2-220, 260, 270);
    _picker.backgroundColor=[UIColor grayColor];
    
    _picker.clipsToBounds=YES;
    _picker.delegate =self;
    _picker.dataSource=self;
    _picker.tag=-7;
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
    [self.view addSubview:_picker];
    _setbutton =[[UIButton alloc]init];
    _setbutton.frame = CGRectMake(App.result.width/2-130,(App.result.height/2-220)+270, 260, 40);
    //button.titleLabel.text = @"Set" ;
    [_setbutton setBackgroundColor:[UIColor lightGrayColor]];
    [_setbutton setTitle:NSLocalizedString(@"set", @"Set") forState:UIControlStateNormal];
    [_setbutton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    //_setbutton.layer.cornerRadius = 5;
    [_setbutton addTarget:self action:@selector(setvalue) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_setbutton];

}


-(void)openodofilter
{
    //"search_odo_filter_0" = "Odometer greater than";
    //"search_odo_filter_1" = "Odometer less than";
    self.filtervalue =[[NSMutableArray alloc]initWithObjects:NSLocalizedString(@"search_odo_filter_0", @"Odometer greater than"),NSLocalizedString(@"search_odo_filter_1", @"Odometer less than"), nil];

    [_picker removeFromSuperview];
    _picker = [[UIPickerView alloc]init];
    AppDelegate *App = [AppDelegate sharedAppDelegate];
    _picker.frame = CGRectMake(App.result.width/2-130,App.result.height/2-220, 260, 270);
    _picker.backgroundColor=[UIColor grayColor];
    
    _picker.clipsToBounds=YES;
    _picker.delegate =self;
    _picker.dataSource=self;
    _picker.tag=-7;
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
    [self.view addSubview:_picker];
    _setbutton =[[UIButton alloc]init];
    _setbutton.frame = CGRectMake(App.result.width/2-130,(App.result.height/2-220)+270, 260, 40);
    //button.titleLabel.text = @"Set" ;
    [_setbutton setBackgroundColor:[UIColor lightGrayColor]];
    [_setbutton setTitle:NSLocalizedString(@"set", @"Set") forState:UIControlStateNormal];
    [_setbutton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    //_setbutton.layer.cornerRadius = 5;
    [_setbutton addTarget:self action:@selector(setvalue1) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_setbutton];
    
}

-(void)viewDidAppear:(BOOL)animated
{

    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];

}
-(void)openrecordfilter
{
//    NSString *f_u_tv = @"Fillup";
//    NSString *tot_services = @"Services";
//    NSString *expense_cost_tv = @"Other Expenses";
//    NSString *trp = @"Trip";
    
    self.filtervalue =[[NSMutableArray alloc]initWithObjects:
                       NSLocalizedString(@"all", @"All"),
                       NSLocalizedString(@"f_u_tv", @"Fillup"),
                       NSLocalizedString(@"tot_services", @"Services"),
                       NSLocalizedString(@"tot_expense_cost", @"Other Expenses"),
                       NSLocalizedString(@"trp", @"Trip"), nil];
    
    [_picker removeFromSuperview];
    _picker = [[UIPickerView alloc]init];
    AppDelegate *App = [AppDelegate sharedAppDelegate];
    _picker.frame = CGRectMake(App.result.width/2-130,App.result.height/2-220, 260, 270);
    _picker.backgroundColor=[UIColor grayColor];
    
    _picker.clipsToBounds=YES;
    _picker.delegate =self;
    _picker.dataSource=self;
    _picker.tag=-7;
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
    //button.titleLabel.text = @"Set" ;
    [_setbutton setBackgroundColor:[UIColor lightGrayColor]];
    [_setbutton setTitle:NSLocalizedString(@"set", @"Set") forState:UIControlStateNormal];
    [_setbutton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    //_setbutton.layer.cornerRadius = 5;
    [_setbutton addTarget:self action:@selector(recordclick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_setbutton];
    
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


-(void)openpicker:(UIButton *)btn
{
    [_pic removeFromSuperview];
    
    
    _pic=[[UIDatePicker alloc] init];
    NSString *str;
    AppDelegate *App = [AppDelegate sharedAppDelegate];
    _pic.frame = CGRectMake(App.result.width/2-130,App.result.height/2-220, 260, 270);
    _pic.backgroundColor=[self colorFromHexString:@"#edebeb"];
    
    UIBezierPath *maskPath;
    maskPath = [UIBezierPath bezierPathWithRoundedRect:_pic.bounds
                                     byRoundingCorners:(UIRectCornerTopLeft|UIRectCornerTopRight)
                                           cornerRadii:CGSizeMake(5.0, 5.0)];
    
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.view.frame;
    maskLayer.path = maskPath.CGPath;
    _pic.layer.mask = maskLayer;
    _pic.timeZone=[NSTimeZone localTimeZone];
    _pic.datePickerMode=UIDatePickerModeDate;
    //NSString *date_hint = @"Set Date";
    
    str=NSLocalizedString(@"date_hint", @"Set Date");
    self.pickerval= NSLocalizedString(@"date", @"Date");
    
    //UIView *topview = (UIView*)[self.view viewWithTag:-2];
    [self.view addSubview:_pic];
    _setbutton =[[UIButton alloc]init];
    _setbutton.frame = CGRectMake(App.result.width/2-130,(App.result.height/2-220)+270, 260, 40);
    [_setbutton setBackgroundColor:[UIColor lightGrayColor]];
    [_setbutton setTitle:NSLocalizedString(@"set", @"Set") forState:UIControlStateNormal];
    [_setbutton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_setbutton addTarget:self action:@selector(doneclick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_setbutton];

}





-(void)doneclick
{
    if([self.pickerval isEqualToString:NSLocalizedString(@"date", @"Date")])
    {
        [self.picker removeFromSuperview];
        [self.pic removeFromSuperview];
        [self.setbutton removeFromSuperview];
        NSDateFormatter *f=[[NSDateFormatter alloc] init];
        [f setDateFormat:@"dd-MMM-yyyy"];
        NSString *date=[f stringFromDate:_pic.date];
        //NSLog(@"picker date....%@",[f stringFromDate:_pic.date]);
        [self.Pickdate setTitle:date forState:UIControlStateNormal];
    }
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
        return self.filtervalue.count;
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
    else
        
        return [self.filtervalue objectAtIndex:row];
}


//-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    if(alertView.tag==0)
//    {
//        [self donelabel];
//    }
//    
//    if (alertView.tag == 2)
//    {
//        [self setvalue];
//    }
//    
//    if (alertView.tag == 3)
//    {
//        [self setvalue1];
//    }
//    if (alertView.tag == 5)
//    {
//        [self doneclick];
//    }
//    
//    if (alertView.tag == 6)
//    {
//        [self recordclick];
//    }
//}


-(void)setvalue
{
    //[self.Datefilter setTitle: [self.filtervalue objectAtIndex:[self.picker selectedRowInComponent:0]] forState:UIControlStateNormal];
    [self.picker removeFromSuperview];
    [self.setbutton removeFromSuperview];
    [self.pic removeFromSuperview];
    self.DateLabel.text = [self.filtervalue objectAtIndex:[self.picker selectedRowInComponent:0]];
}

-(void)setvalue1
{
    [self.picker removeFromSuperview];
    [self.setbutton removeFromSuperview];
    [self.pic removeFromSuperview];
    [self.Odofilter setTitle: [self.filtervalue objectAtIndex:[self.picker selectedRowInComponent:0]] forState:UIControlStateNormal];
}

-(void)recordclick
{
   // [self.Recordtype setTitle: [self.filtervalue objectAtIndex:[self.picker selectedRowInComponent:0]] forState:UIControlStateNormal];
    [self.picker removeFromSuperview];
    [self.setbutton removeFromSuperview];
    [self.pic removeFromSuperview];
    self.recordlabel.text = [self.filtervalue objectAtIndex:[self.picker selectedRowInComponent:0]];
}
-(void)donelabel
{
    [self.picker removeFromSuperview];
    [self.setbutton removeFromSuperview];
    [self.pic removeFromSuperview];
    NSUserDefaults *def =[NSUserDefaults standardUserDefaults];
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
