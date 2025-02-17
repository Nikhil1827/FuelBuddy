//
//  VehicleaddViewController.m
//  FuelBuddy
//
//  Copyright (c) 2015 Oraganization. All rights reserved.
//

#import "VehicleaddViewController.h"
#import "AppDelegate.h"
#import "Veh_Table.h"
#import "Services_Table.h"
#import "CustomSpecificationsController.h"
#import "AddSpecifications.h"
#import "Loc_Table.h"
#import "Sync_Table.h"
#import "Reachability.h"
#import "commonMethods.h"
#import "WebServiceURL's.h"
#import "CheckReachability.h"


@interface VehicleaddViewController ()
{
    NSMutableDictionary *dataDictionary;
    NSArray * fuelTypeArray;
}
@end

//Swapnil 15 Mar-17
//static GADMasterViewController *shared;
@implementation VehicleaddViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.fuelTypeTableView.hidden = YES;
    // Do any additional setup after loading the view.
    [self.tabBarController.tabBar setHidden:YES];
    AppDelegate *App = [AppDelegate sharedAppDelegate];
    App.tabbutton.hidden=YES;

    //Swapnil 22-May-17
    self.notesView.delegate = self;
    
    //Swapnil ENH_21
    self.insurance.delegate = self;
    
    fuelTypeArray = [[NSArray alloc]initWithObjects:NSLocalizedString(@"petrol", @"Petrol"),NSLocalizedString(@"diesel", @"Diesel"),NSLocalizedString(@"cng", @"CNG"),NSLocalizedString(@"other", @"Other"), nil];
    
    self.make.delegate=self;
    self.model.delegate=self;
    self.vin.delegate=self;
    self.year.delegate=self;
    self.licence.delegate=self;
    NSUserDefaults *def =[NSUserDefaults standardUserDefaults];
    self.imagedata =[[NSData alloc]init];
    self.imagedata = UIImageJPEGRepresentation(self.imageview.image, 0.7);
    
    self.view.backgroundColor = [self colorFromHexString:@"#2c2c2c"];
    
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(pictureclick)];
    [tap1 setCancelsTouchesInView:NO];
    self.defaultimage.userInteractionEnabled = YES;
    [self.defaultimage addGestureRecognizer:tap1];
    
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                           action:@selector(pictureclick)];
    [tap2 setCancelsTouchesInView:NO];
    self.imageview.userInteractionEnabled =YES;
    [self.imageview addGestureRecognizer:tap2];
    [self textfieldsetting:self.make];
    [self textfieldsetting:self.model];
    [self textfieldsetting:self.vin];
    [self textfieldsetting:self.year];
    [self textfieldsetting:self.licence];
    [self textfieldsetting:self.fuelType];
    
    //Swapnil ENH_21
    [self textfieldsetting:self.insurance];
   
    self.topview.backgroundColor =[self colorFromHexString:@"#313131"];
    self.topimage.contentMode = UIViewContentModeScaleAspectFill;
    self.topimage.clipsToBounds = YES;
    self.imageview.contentMode = UIViewContentModeScaleAspectFill;
    self.imageview.clipsToBounds = YES;

   // NSUserDefaults *def =[NSUserDefaults standardUserDefaults];
    NSString *titletext= [def objectForKey:@"save"];
//    UILabel *title=[[UILabel alloc]initWithFrame:CGRectMake(20,5,70,20)];
//    title.text=[titletext capitalizedString];
//    title.textAlignment =NSTextAlignmentCenter;
//    title.textColor=[UIColor whiteColor];
//    self.navigationItem.titleView=title;
    
    self.navigationController.navigationBar.tintColor =[UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor] , NSFontAttributeName: [UIFont fontWithName:@"Helvetica-Light" size:18.0] }];
    self.navigationItem.title=[titletext capitalizedString];
    
    UIImage *buttonImage = [[UIImage imageNamed:@"nav_back"] resizableImageWithCapInsets:UIEdgeInsetsMake(20,10,10,10)];
    
    UIButton *Button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [Button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    
    Button.frame = CGRectMake(0.0, 10.0, buttonImage.size.width+4,buttonImage.size.height+4);
    
    UIBarButtonItem *BarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:Button];
    
    [Button addTarget:self action:@selector(backbuttonclick) forControlEvents:UIControlEventTouchUpInside];
    
    [self.navigationItem setLeftBarButtonItem:BarButtonItem];

    [self.addphotobutton addTarget:self action:@selector(pictureclick) forControlEvents:UIControlEventTouchUpInside];
    [self.clickimage addTarget:self action:@selector(pictureclick) forControlEvents:UIControlEventTouchUpInside];

    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.barStyle = UIBarStyleDefault;
    numberToolbar.backgroundColor =[UIColor whiteColor];
    numberToolbar.items = [NSArray arrayWithObjects:[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad)],
                           nil];
    
    [numberToolbar sizeToFit];
    self.year.inputAccessoryView = numberToolbar;
//    if([def objectForKey:@"idvalue"]==nil)
//    {
//        
//        [def setObject:@"1" forKey:@"idvalue"];
//    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(dismissKeyboard)];
    [tap setCancelsTouchesInView:NO];
    self.editbutton.hidden=YES;
    
    [self.view addGestureRecognizer:tap];
    if([[def objectForKey:@"save"]isEqualToString:@"Edit"])
    {
        self.editbutton.hidden=NO;
        [self.editbutton addTarget:self action:@selector(pictureclick) forControlEvents:UIControlEventTouchUpInside];
        self.make.text=self.makestring;
        self.model.text=self.modelstring;
        self.vin.text=self.vinstring;
        self.year.text=self.yearstring;
        self.licence.text=self.lincestring;
        if(self.fuelTypeString.length>0){

            self.fuelType.text=self.fuelTypeString;
        }else{

            self.fuelType.text=NSLocalizedString(@"fuel_type", @"Fuel Type");
        }
        
        //Swapnil 22-May-17
        self.notesView.text = self.noteString;
        
        //Swapnil ENH_21
        self.insurance.text = self.insuranceString;
        
        self.fuelType.userInteractionEnabled = NO;
        
        if(self.make.text.length>0)
        {
            
            self.namelab.hidden=NO;
        }
        if(self.model.text.length>0)
        {
            
            self.modellab.hidden=NO;
        }
        if(self.year.text.length>0)
        {
            
            self.yearlab.hidden=NO;
        }
        if(self.vin.text.length>0)
        {
            
            self.vinlab.hidden=NO;
        }
        if(self.licence.text.length>0)
        {
            
            self.licencelab.hidden=NO;
        }
        
        //Swapnil ENH_21
        if(self.insurance.text.length > 0){
            
            self.insuranceLab.hidden = NO;
        }
        self.addphotobutton.hidden=YES;
        self.topimage.userInteractionEnabled=YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(pictureclick)];
        
        [tap setCancelsTouchesInView:NO];
        [self.topimage addGestureRecognizer:tap];
        
      

        if(self.imagestring.length!=0)
        {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            
        //Swapnil ENH_24
        NSString * urlstring = [paths firstObject];

        self.imagepath = [NSString stringWithFormat:@"%@",self.imagestring];
        
        self.topimage.image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",urlstring,self.imagestring]];
        self.imagedata =[[NSData alloc]init];
        self.imagedata = UIImageJPEGRepresentation(self.topimage.image, 0.7);
          //NSLog(@"imagepath save %@",self.imagestring);
            self.defaultimage.hidden=YES;
        }
        
        else
        {
            self.topimage.image =[UIImage imageNamed:@"car4.jpg"];
            //self.addphotobutton.hidden=YES;

            self.defaultimage.hidden=YES;
        }
    } else {
        
        //Swapnil ENH_30
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"customArray"];
    }
    
    self.custArr = [[NSMutableArray alloc] init];
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"entriesChanged"];
    
    //nikhil 02/08/2018 added add photo label
    [self.addPhotoLabel setTitle:NSLocalizedString(@"add_photo", @"Add Photo") forState:UIControlStateNormal];
    //
}

-(void)viewDidAppear:(BOOL)animated
{
    
    self.fuelTypeTableView.hidden = YES;
    self.fuelTypeTableView.layer.cornerRadius = 5;
    self.fuelTypeTableView.clipsToBounds = YES;
    self.fuelTypeTableView.delegate = self;
    self.fuelTypeTableView.dataSource = self;
    
     self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"save", @"Save")  style:UIBarButtonItemStylePlain target:self action:@selector(saveclick)];
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    
}

-(BOOL)shouldAutorotate
{
    return NO;
}


-(void)backbuttonclick
{
    
    //Swapnil ENH_30
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"entriesChanged"] == YES){
        
        [self showAlert:@"Are you sure you want to exit without saving?" message:@""];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)showAlert: (NSString *)title message:(NSString *)message{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"yes", @"Yes") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        tempArray = [[[NSUserDefaults standardUserDefaults] objectForKey:@"customArray"] mutableCopy];
        [tempArray removeAllObjects];
        [[NSUserDefaults standardUserDefaults] setObject:tempArray forKey:@"customArray"];
        
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    UIAlertAction *canel = [UIAlertAction actionWithTitle:NSLocalizedString(@"no", @"No") style:UIAlertActionStyleDefault handler:nil];
    
    [alert addAction:ok];
    [alert addAction:canel];
    [self presentViewController:alert animated:YES completion:nil];

}

-(void)doneWithNumberPad{
    
    [self.year resignFirstResponder];
    
}

-(void)dismissKeyboard
{
   
    [self.make resignFirstResponder];
    [self.model resignFirstResponder];
    [self.year resignFirstResponder];
    [self.vin resignFirstResponder];
    [self.licence resignFirstResponder];
    
    //Swapnil 22-May-17
    [self.notesView resignFirstResponder];
    
    //Swapnil ENH_21
    [self.insurance resignFirstResponder];
 
}

- (void)viewDidLayoutSubviews{
    self.scrollview.contentSize = CGSizeMake(320,620);
    [self.scrollview setScrollEnabled:YES];
    self.notesView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);

}


-(void)textfieldsetting: (UITextField *)textfield
{
    CALayer *border = [CALayer layer];
    CGFloat borderWidth = 0;
    border.borderColor = [UIColor darkGrayColor].CGColor;
    border.frame = CGRectMake(0, textfield.frame.size.height - borderWidth, textfield.frame.size.width, textfield.frame.size.height);
    border.borderWidth = borderWidth;
    [textfield.layer addSublayer:border];
    textfield.layer.masksToBounds = YES;
    // UIColor *color = [UIColor darkGrayColor];
    //[textfield setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    NSMutableAttributedString *placeholderAttributedString = [[NSMutableAttributedString alloc] initWithAttributedString:textfield.attributedPlaceholder];
    [placeholderAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:NSMakeRange(0, [placeholderAttributedString length])];
    textfield.attributedPlaceholder = placeholderAttributedString;
}

//color setting
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


#pragma mark UITEXTFIELD DELEGATE METHODS

//Textfield delegate methods
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    [textField resignFirstResponder];
    return YES;
}


-(void)textFieldDidBeginEditing:(UITextField *)textField
{
   
    if(textField==self.model)
    {
        [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y-80, self.view.frame.size.width, self.view.frame.size.height)];
        
    }
    
    if(textField == self.make)
    {
        [self labelanimatetoshow:self.namelab];
        textField.placeholder=@"";
        [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y-20, self.view.frame.size.width, self.view.frame.size.height)];

        
    }
    
    if(textField == self.model)
    {
        [self labelanimatetoshow:self.modellab];
        textField.placeholder=@"";

    }
    
    if(textField == self.vin)
    {
        [self labelanimatetoshow:self.vinlab];
        textField.placeholder=@"";
        [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y-140, self.view.frame.size.width, self.view.frame.size.height)];


    }
    if(textField == self.licence)
    {
        [self labelanimatetoshow:self.licencelab];
        textField.placeholder=@"";
        [self.view setFrame:CGRectMake(self.view.frame.origin.x,self.view.frame.origin.y-180, self.view.frame.size.width, self.view.frame.size.height)];

    }
    if(textField == self.year)
    {
        [self labelanimatetoshow:self.yearlab];
        textField.placeholder=@"";
          [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y-140, self.view.frame.size.width, self.view.frame.size.height)];

    }
    
    //Swapnil ENH_21
    if(textField == self.insurance)
    {
        [self labelanimatetoshow:self.insuranceLab];
        textField.placeholder=@"";
        [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y-120, self.view.frame.size.width, self.view.frame.size.height)];
        
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

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if(textField == self.make){
        
        if([textField.text containsString:@","]){
            
            //NSString *mk_model_comma_err = @"Make and model cannot accept commas";
            UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"mk_model_comma_err", @"error") message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"ok action") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                
            }];
            [alertControl addAction:ok];
            [self presentViewController:alertControl animated:YES completion:nil];
            NSString *Stringval = [textField.text stringByReplacingOccurrencesOfString:@"," withString:@""];
            textField.text = Stringval;
        }
    }
    
    if(textField == self.model){
        
        if([textField.text containsString:@","]){
            
            //NSString *mk_model_comma_err = @"Make and model cannot accept commas";
            UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"mk_model_comma_err", @"error") message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"ok action") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                
            }];
            [alertControl addAction:ok];
            [self presentViewController:alertControl animated:YES completion:nil];
            NSString *Stringval = [textField.text stringByReplacingOccurrencesOfString:@"," withString:@""];
            textField.text = Stringval;
        }
    }
    
    if(textField == self.vin){
        
        if([textField.text containsString:@","]){
            
            UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:@"Vin cannot accept commas" message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"ok action") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                
            }];
            [alertControl addAction:ok];
            [self presentViewController:alertControl animated:YES completion:nil];
            NSString *Stringval = [textField.text stringByReplacingOccurrencesOfString:@"," withString:@""];
            textField.text = Stringval;
        }
    }
    
    if(textField == self.licence){
        
        if([textField.text containsString:@","]){
            
            UIAlertController *alertControl = [UIAlertController alertControllerWithTitle: [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"lic_no_tv", @"Licence No."), NSLocalizedString(@"comma_err", @"cannot accept commas")] message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"ok action") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                
            }];
            [alertControl addAction:ok];
            [self presentViewController:alertControl animated:YES completion:nil];
            NSString *Stringval = [textField.text stringByReplacingOccurrencesOfString:@"," withString:@""];
            textField.text = Stringval;
        }
    }
    
    //Swapnil ENH_21
    if(textField == self.insurance){
        
        if([textField.text containsString:@","]){
            
            UIAlertController *alertControl = [UIAlertController alertControllerWithTitle: [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"insurance_no", @"Insurance #"), NSLocalizedString(@"comma_err", @"cannot accept commas")] message:nil preferredStyle:UIAlertControllerStyleAlert];
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



-(void)textFieldDidEndEditing:(UITextField *)textField
{
      [self.view setFrame:CGRectMake(self.view.frame.origin.x, 0, self.view.frame.size.width, self.view.frame.size.height)];
   
   
    
    if(textField == self.make)
    {
        if(textField.text.length==0)
        {
        [self labelanimatetohide:self.namelab];
            
        //NSString *make_tv = @"Make";
        textField.placeholder=NSLocalizedString(@"make_tv", @"make");
           //  [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y+20, self.view.frame.size.width, self.view.frame.size.height)];
        }
        if([textField.text containsString:@","]){
            
            //NSString *mk_model_comma_err = @"Make and model cannot accept commas";
            UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"mk_model_comma_err", @"error") message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"ok action") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                
            }];
            [alertControl addAction:ok];
            [self presentViewController:alertControl animated:YES completion:nil];
            NSString *Stringval = [textField.text stringByReplacingOccurrencesOfString:@"," withString:@""];
            textField.text = Stringval;
        }
    }
    
    if(textField == self.model)
    {
        if(textField.text.length==0)
        {
        [self labelanimatetohide: self.modellab];
        textField.placeholder=NSLocalizedString(@"model_tv", @"Model");
        }
        if([textField.text containsString:@","]){
            
            //NSString *mk_model_comma_err = @"Make and model cannot accept commas";
            UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"mk_model_comma_err", @"error") message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"ok action") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                
            }];
            [alertControl addAction:ok];
            [self presentViewController:alertControl animated:YES completion:nil];
            NSString *Stringval = [textField.text stringByReplacingOccurrencesOfString:@"," withString:@""];
            textField.text = Stringval;
        }
    }
    
    if(textField == self.vin)
    {
          // [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y+140, self.view.frame.size.width, self.view.frame.size.height)];
        if(textField.text.length==0)
        {
        [self labelanimatetohide: self.vinlab];
        textField.placeholder=NSLocalizedString(@"vin", @"VIN");
        }
        if([textField.text containsString:@","]){
            UIAlertController *alertControl = [UIAlertController alertControllerWithTitle: [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"vin", @"VIN"), NSLocalizedString(@"comma_err", @"cannot accept commas")] message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"ok action") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                
            }];
            [alertControl addAction:ok];
            [self presentViewController:alertControl animated:YES completion:nil];
            NSString *Stringval = [textField.text stringByReplacingOccurrencesOfString:@"," withString:@""];
            textField.text = Stringval;
        }
    }
    if(textField == self.licence)
    {
        if(textField.text.length==0)
        {
        [self labelanimatetohide: self.licencelab];
            
        //NSString *lic_no_tv = @"Licence No.";
        textField.placeholder=NSLocalizedString(@"lic_no_tv", @"Lic no");
         //    [self.view setFrame:CGRectMake(self.view.frame.origin.x,self.view.frame.origin.y+180, self.view.frame.size.width, self.view.frame.size.height)];
        }
        
        if([textField.text containsString:@","]){
            UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"lic_no_tv", @"Licence No."), NSLocalizedString(@"comma_err", @"cannot accept commas")] message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"ok action") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                
            }];
            [alertControl addAction:ok];
            [self presentViewController:alertControl animated:YES completion:nil];
            NSString *Stringval = [textField.text stringByReplacingOccurrencesOfString:@"," withString:@""];
            textField.text = Stringval;
        }
    }
    if(textField == self.year)
    {
          // [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y+140, self.view.frame.size.width, self.view.frame.size.height)];
        if(textField.text.length==0)
        {
        [self labelanimatetohide: self.yearlab];
        textField.placeholder = NSLocalizedString(@"year", @"Year");
        }
    }
    
    //Swapnil ENH_21
    if(textField == self.insurance)
    {
        if(textField.text.length==0)
        {
            [self labelanimatetohide: self.insuranceLab];
            
            
            textField.placeholder= NSLocalizedString(@"insurance_no", @"Insurance #");
            //    [self.view setFrame:CGRectMake(self.view.frame.origin.x,self.view.frame.origin.y+180, self.view.frame.size.width, self.view.frame.size.height)];
        }
        
        if([textField.text containsString:@","]){
            UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"insurance_no", @"Insurance #"), NSLocalizedString(@"comma_err", @"cannot accept commas")] message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"ok action") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                
            }];
            [alertControl addAction:ok];
            [self presentViewController:alertControl animated:YES completion:nil];
            NSString *Stringval = [textField.text stringByReplacingOccurrencesOfString:@"," withString:@""];
            textField.text = Stringval;
        }
    }
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

//Swapnil 22-May-17
#pragma mark UITEXTVIEW DELEGATE METHODS

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    if ([text isEqualToString:@"\n"]) {
        
        [textView resignFirstResponder];
        // Return FALSE so that the final '\n' character doesn't get added
        return NO;
    }
    if([textView.text containsString:@","]){
        UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"comma_enter_err", @"Notes cannot accept commas") message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"ok action") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            
        }];
        [alertControl addAction:ok];
        [self presentViewController:alertControl animated:YES completion:nil];
        NSString *Stringval = [textView.text stringByReplacingOccurrencesOfString:@"," withString:@""];
        textView.text = Stringval;
    }
    return YES;
}

-(void)textViewDidBeginEditing:(UITextView *)textView{
    
    if(textView == self.notesView){
        [self.view setFrame:CGRectMake(self.view.frame.origin.x,self.view.frame.origin.y-180, self.view.frame.size.width, self.view.frame.size.height)];
        self.notesView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);

    }
}

-(void)textViewDidEndEditing:(UITextView *)textView{
    
    [self.view setFrame:CGRectMake(self.view.frame.origin.x, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    if([textView.text containsString:@","]){
        UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"comma_enter_err", @"Notes cannot accept commas") message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"ok action") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            
        }];
        [alertControl addAction:ok];
        [self presentViewController:alertControl animated:YES completion:nil];
        NSString *Stringval = [textView.text stringByReplacingOccurrencesOfString:@"," withString:@""];
        textView.text = Stringval;
    }
    
    self.notesView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);

}


-(void)saveclick
{
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    if([[def objectForKey:@"save"]isEqualToString:@"Add"])
    {
        [self savetolocaldatabase];
        
    }
    else
    {
        [self editdata];
        
    }
}


//Edit
-(void)editdata
{
    NSUserDefaults *Def = [NSUserDefaults standardUserDefaults];
    //NSLog(@"self.id = %@", self.ID);
    if(self.make.text.length!=0 || self.model.text.length!=0)
    {
        NSManagedObjectContext *contex = [[CoreDataController sharedInstance] newManagedObjectContext];
        NSFetchRequest *requset=[[NSFetchRequest alloc] initWithEntityName:@"Veh_Table"];
        NSError *err;
        //NSPredicate *pre=[NSPredicate predicateWithFormat:@"iD == %@",self.ID];
        //[requset setPredicate:pre];
        NSArray *vehicle=[contex executeFetchRequest:requset error:&err];
      NSString *string = @"notpresent";
       for(Veh_Table *data in vehicle)
       {
          
         if([self.ID integerValue] != [data.iD integerValue] && [data.vehid isEqualToString:[NSString stringWithFormat:@"%@ %@",self.make.text,self.model.text]])
             {
                 string =@"present";
//                 UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Same vehicle already exist please enter other make/model name" message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//                 [alert show];
                 
                 UIAlertController *alertController = [UIAlertController
                                                       alertControllerWithTitle:@"Same vehicle already exists. Please enter another make/model"
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

    else if([self.ID integerValue]== [data.iD integerValue] && [string isEqualToString:@"notpresent"])
       {
        //NSLog(@"data id %@",data.iD);
        data.make = self.make.text;
        data.model = self.model.text;
        data.lic = self.licence.text;
        data.vin = self.vin.text;
        data.year = self.year.text;
        //Swapnil 22-May-17
        data.notes = self.notesView.text;
        //Swapnil ENH_21
        data.insuranceNo = self.insurance.text;
        
        if([self.fuelType.text isEqualToString:@""]){
            data.fuel_type = @"";
        }else{
            data.fuel_type = self.fuelType.text;
        }
        
           
           
           
        //Swapnil ENH_30
           NSString *customSpecString = [self convertCustomSpecToString];
            data.customSpecs = customSpecString;
           
           
           if(self.imagepath!=nil)
           {
               //NSLog(@"imagepath save %@",self.imagepath);
               data.picture =self.imagepath;
           }
           else
           {
               
               data.picture=nil;
           }
        data.vehid = [NSString stringWithFormat:@"%@ %@",self.make.text,self.model.text];
           
           
           
           if ([contex hasChanges])
           {
               BOOL saved = [contex save:&err];
               if (!saved) {
                   // do some real error handling
                   //CLSLog(@“Could not save Data due to %@“, error);
               }
               [[CoreDataController sharedInstance] saveMasterContext];
               //NSLog(@"saved");
             
               //Swapnil NEW_6
               NSString *userEmail = [Def objectForKey:@"UserEmail"];
               
               //If user is signed In, then only do the sync process..
               if(userEmail != nil && userEmail.length > 0){
                   
                   [self writeToSyncTableWithRowID:data.iD tableName:@"VEH_TABLE" andType:@"edit"];
                 //  [self checkNetworkForCloudStorage];
               }
                [self.navigationController popViewControllerAnimated:YES];
           }

        }
        
    }
       
    }
    
    else
    {
        
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:NSLocalizedString(@"invalid_veh_msg1", @"Both Make and Model Cannot be left Blank")
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

//Swapnil ENH_30
- (NSString *)convertCustomSpecToString{
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSMutableArray *customSpecsArray = [[def objectForKey:@"customArray"] mutableCopy];
    //NSLog(@"customSpecsArr = %@", customSpecsArray);
    
    NSString *customSpecString;
    if(customSpecsArray.count != 0){
        
        NSMutableArray *nameValueArray = [[NSMutableArray alloc] init];
        for(int i = 0; i < customSpecsArray.count; i++){
            
            
            NSString *name = [[customSpecsArray objectAtIndex:i] objectForKey:@"name"];
            NSString *value = [[customSpecsArray objectAtIndex:i] objectForKey:@"value"];
            NSString *nameValue = [NSString stringWithFormat:@"%@:::%@", name, value];
            [nameValueArray addObject:nameValue];
        }
        customSpecString = [nameValueArray componentsJoinedByString:@","];
        //NSLog(@"stringname = %@", customSpecString);
    }
    return customSpecString;

}

//This method saves data to Veh_Table table
-(void)savetolocaldatabase
{
    
    if(self.make.text.length!=0 || self.model.text.length!=0)
    {
    NSManagedObjectContext *contex = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSError *err;
    NSFetchRequest *requset=[[NSFetchRequest alloc] initWithEntityName:@"Veh_Table"];
    NSArray *datavalue=[contex executeFetchRequest:requset error:&err];
    
       
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"iD" ascending:NO];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
        [requset setSortDescriptors:sortDescriptors];
        
        [requset setFetchLimit:1];
        
        NSError *error = nil;
        NSArray *results = [contex executeFetchRequest:requset error:&error];
        
        if (results == nil) {
            NSLog(@"error fetching the results: %@",error);
        }
        
        int maxId = 0;
        if (results.count == 1) {
            
            //Swapnil ENH_24
            Veh_Table *result = (Veh_Table*)[results firstObject];
            maxId =  [result.iD intValue];
            //NSLog(@"maxId:- %i",maxId);
        }
        
        //NSLog(@"maxId : %ld", (long)maxId);
        NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
        [def setObject:[NSNumber numberWithInt:maxId+1] forKey:@"maxVehId"];
        [def synchronize];
        
        
        
   // NSLog(@"object id %@",requset)
     NSString *string = @"notpresent";
    for(Veh_Table *vehicle in datavalue)
    {
     
     if([vehicle.vehid isEqualToString:[NSString stringWithFormat:@"%@ %@",self.make.text,self.model.text]])
     {
        string = @"present";
         
     }
    
    
    }
        
    if([string isEqualToString:@"notpresent"])
    {
    Veh_Table *data=[NSEntityDescription insertNewObjectForEntityForName:@"Veh_Table" inManagedObjectContext:contex];
     
    data.iD = [NSNumber numberWithInt:maxId+1] ;
    data.make = self.make.text;
    data.model = self.model.text;
    data.lic = self.licence.text;
    data.vin = self.vin.text;
    data.year = self.year.text;
    if([self.fuelType.text isEqualToString:@""]){
        data.fuel_type = @"";
    }else{
        data.fuel_type = self.fuelType.text;
    }
        
    //Swapnil 22-May-17
    data.notes = self.notesView.text;
        
    //Swapnil ENH_21
    data.insuranceNo = self.insurance.text;
        
    //Swapnil ENH_30
    NSString *customSpecString = [self convertCustomSpecToString];
    data.customSpecs = customSpecString;
        

        
        
        if(self.imageview.image==nil)
        {
            data.picture = nil;
        }
        else
        {
            
            data.picture = self.imagepath;
        }
    data.vehid = [NSString stringWithFormat:@"%@ %@",self.make.text,self.model.text];
    
    
    if ([contex hasChanges])
    {
        BOOL saved = [contex save:&err];
        if (!saved) {
            // do some real error handling
            //CLSLog(@“Could not save Data due to %@“, error);
        }
        [[CoreDataController sharedInstance] saveMasterContext];
        //NSLog(@"saved");
 
        //Swapnil NEW_6
        NSString *userEmail = [def objectForKey:@"UserEmail"];
        
        //If User is signed In, then only do the Sync Process..
        if(userEmail != nil && userEmail.length > 0){
            
            [self writeToSyncTableWithRowID:data.iD tableName:@"VEH_TABLE" andType:@"add"];
           // [self checkNetworkForCloudStorage];
        }

        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        tempArray = [[[NSUserDefaults standardUserDefaults] objectForKey:@"customArray"] mutableCopy];
        [tempArray removeAllObjects];
        [[NSUserDefaults standardUserDefaults] setObject:tempArray forKey:@"customArray"];
        [self.navigationController popViewControllerAnimated:YES];
        
    }
    }
        
     else
     {
         UIAlertController *alertController = [UIAlertController
                                               alertControllerWithTitle:@"Same vehicle already exists. Please enter another make/model"
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
    else
    {
        
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:NSLocalizedString(@"invalid_veh_msg1", @"Both Make and Model Cannot be left Blank")
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
    
    [self saveservice];
    [self saveexpense];
}

#pragma mark Fuel type table view methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return fuelTypeArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"fuelTypeCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"fuelTypeCell"] ;
        
    }
    
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    cell.textLabel.text = [fuelTypeArray objectAtIndex:indexPath.row];
    //cell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    return  cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    self.fuelType.text = [fuelTypeArray objectAtIndex:indexPath.row];
    self.fuelTypeTableView.hidden = YES;
    self.scrollView.scrollEnabled = YES;
    self.scrollView.userInteractionEnabled = YES;
    //self.contentView.userInteractionEnabled = YES;
}

#pragma mark Picture methods

//open picture popup
- (void)pictureclick{
    
    UIAlertController* alert = [UIAlertController
                                alertControllerWithTitle:nil
                                message:nil
                                preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* button0 = [UIAlertAction
                              actionWithTitle:NSLocalizedString(@"cancel", @"Cancel")
                              style:UIAlertActionStyleCancel
                              handler:^(UIAlertAction * action)
                              {
                                  
                              }];
    
    UIAlertAction* button1 = [UIAlertAction
                              actionWithTitle:@"Take a new photo"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                  [self takeNewPhotoFromCamera];
                              }];
    
    UIAlertAction* button2 = [UIAlertAction
                              actionWithTitle:@"Choose from existing"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                  [self choosePhotoFromExistingImages];
                              }];
    
    [alert addAction:button0];
    [alert addAction:button1];
    [alert addAction:button2];
    [self presentViewController:alert animated:YES completion:nil];
}


- (void)takeNewPhotoFromCamera
{
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *controller = [[UIImagePickerController alloc] init];
        controller.sourceType = UIImagePickerControllerSourceTypeCamera;
        controller.allowsEditing = NO;
       // controller.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType: UIImagePickerControllerSourceTypeCamera];
        controller.delegate = self;
        [self presentViewController:controller animated:YES completion:nil];
        
    }
}

-(void)choosePhotoFromExistingImages
{
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypePhotoLibrary])
    {
        UIImagePickerController *controller = [[UIImagePickerController alloc] init];
        controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        controller.allowsEditing = NO;
        //controller.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType: UIImagePickerControllerSourceTypePhotoLibrary];
        controller.delegate = self;
        [self presentViewController:controller animated:YES completion:nil];
    }
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self.navigationController dismissViewControllerAnimated: YES completion: nil];
    UIImage *image = [info valueForKey: UIImagePickerControllerOriginalImage];
    
    NSData *imageData = UIImageJPEGRepresentation(image, 0.7);
    if(picker.sourceType == UIImagePickerControllerSourceTypeCamera)
    {
        
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
        
    }

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    //Swapnil ENH_24
    NSString *documentsDirectory = [paths firstObject];
    
    // NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSString *UniqueName = [NSString stringWithFormat:@"image-%f",[[NSDate date] timeIntervalSince1970]];
    NSString *imagePath =[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@.png",@"cached",UniqueName]];
    
    
    if (![imageData writeToFile:imagePath atomically:NO])
    {
        //NSLog((@"Failed to cache image data to disk"));
    }
    else
    {
      
        self.imagepath= [NSString stringWithFormat:@"cached%@.png",UniqueName];
         // NSLog(@"the cachedImagedPath is %@",self.imagepath);
        self.defaultimage.hidden=YES;
    }
    
    self.imagedata= imageData;
    NSUserDefaults *def =[NSUserDefaults standardUserDefaults];
    if([[def objectForKey:@"save"]isEqualToString:@"Edit"])
    {
        self.topimage.image= [UIImage imageWithData:imageData];
    }
    else
    {
    self.imageview.image =[UIImage imageWithData:imageData];
    }
}

-(void)saveservice
{
    NSManagedObjectContext *contex = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSError *err;
    
    NSUserDefaults *Def = [NSUserDefaults standardUserDefaults];
    //NSFetchRequest *requset=[[NSFetchRequest alloc] initWithEntityName:@"Veh_Table"];
    //NSArray *datavalue=[contex executeFetchRequest:requset error:&err];
    NSMutableArray *servicearray = [[NSMutableArray alloc]initWithObjects:
                                    @"Engine Oil",
                                    @"Battery",
                                    @"Tire Rotation",
                                    @"Wheel Alignment",
                                    @"Spark Plugs",
                                    @"Timing Belt", nil];
    
    NSFetchRequest *requset=[[NSFetchRequest alloc] initWithEntityName:@"Services_Table"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type==1 OR type==2"];
    [requset setPredicate:predicate];
    
    NSArray *datavalue=[contex executeFetchRequest:requset error:&err];
    
    for(Services_Table *service in datavalue)
    {
        if([service.type floatValue]==1)
        {
        if(![servicearray containsObject:service.serviceName])
        {
            [servicearray addObject:service.serviceName];
        }
        }
    }
    
    
    
    
    
    for(int i =0;i<servicearray.count;i++)
    {
        //Swapnil NEW_6
        int serviceID;
        if([Def objectForKey:@"maxServiceID"] != nil){
            
            serviceID = [[Def objectForKey:@"maxServiceID"] intValue];
        } else {
            
            serviceID = 0;
        }
        Services_Table *data=[NSEntityDescription insertNewObjectForEntityForName:@"Services_Table" inManagedObjectContext:contex];
        
        data.iD = [NSNumber numberWithInt:serviceID + 1];
        [Def setObject:data.iD forKey:@"maxServiceID"];
        data.vehid = [[[NSUserDefaults standardUserDefaults]objectForKey: @"maxVehId"]stringValue];
        data.serviceName = [servicearray objectAtIndex:i];
        data.recurring = @(1);
        data.type=@(1);
        if ([contex hasChanges])
        {
            BOOL saved = [contex save:&err];
            if (!saved) {
                // do some real error handling
                //CLSLog(@“Could not save Data due to %@“, error);
            }
            //NSLog(@"saved");
            [[CoreDataController sharedInstance] saveMasterContext];
  
            //Swapnil NEW_6
            NSString *userEmail = [Def objectForKey:@"UserEmail"];
            
            //If user is signed In, then only do the sync process..
            if(userEmail != nil && userEmail.length > 0){
                [self writeToSyncTableWithRowID:data.iD tableName:@"SERVICE_TABLE" andType:@"add"];
               // [self checkNetworkForCloudStorage];
            }
           
        }
    }

}

-(void)saveexpense
{
    NSManagedObjectContext *contex = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSError *err;
    //NSFetchRequest *requset=[[NSFetchRequest alloc] initWithEntityName:@"Veh_Table"];
    //NSArray *datavalue=[contex executeFetchRequest:requset error:&err];
    NSMutableArray *servicearray = [[NSMutableArray alloc]initWithObjects:
                                    @"Fine",
                                    @"Insurance",
                                    @"MOT",
                                    @"Toll",
                                    @"Tax",
                                    @"Parking",nil];
    
    NSFetchRequest *requset=[[NSFetchRequest alloc] initWithEntityName:@"Services_Table"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type==1 OR type==2"];
    [requset setPredicate:predicate];
    
    NSArray *datavalue=[contex executeFetchRequest:requset error:&err];
    NSUserDefaults *Def = [NSUserDefaults standardUserDefaults];

    
    
    for(Services_Table *service in datavalue)
    {
        if([service.type floatValue]==2)
        {
        if(![servicearray containsObject:service.serviceName])
        {
            [servicearray addObject:service.serviceName];
        }
        }
    }
    
    for(int i =0;i<servicearray.count;i++)
    {
        //Swapnil NEW_6
        int serviceID;
        if([Def objectForKey:@"maxServiceID"] != nil){
            
            serviceID = [[Def objectForKey:@"maxServiceID"] intValue];
        } else {
            
            serviceID = 0;
        }
        Services_Table *data=[NSEntityDescription insertNewObjectForEntityForName:@"Services_Table" inManagedObjectContext:contex];
        
        data.iD = [NSNumber numberWithInt:serviceID + 1];
        [Def setObject:data.iD forKey:@"maxServiceID"];
        
        data.vehid = [[[NSUserDefaults standardUserDefaults]objectForKey: @"maxVehId"]stringValue];
        data.serviceName = [servicearray objectAtIndex:i];
        data.recurring = @(0);
        data.type=@(2);
        if ([contex hasChanges])
        {
            BOOL saved = [contex save:&err];
            if (!saved) {
                // do some real error handling
                //CLSLog(@“Could not save Data due to %@“, error);
            }
             //NSLog(@"saved");
             [[CoreDataController sharedInstance] saveMasterContext];
        
            //Swapnil NEW_6
            NSString *userEmail = [Def objectForKey:@"UserEmail"];
            
            //If user is signed In, then only do the sync process..
            if(userEmail != nil && userEmail.length > 0){
                
                [self writeToSyncTableWithRowID:data.iD tableName:@"SERVICE_TABLE" andType:@"add"];
            }
            
        }
    }
    
   // [self performSelectorInBackground:@selector(checkNetworkForCloudStorage) withObject:nil];

}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker;
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

//Swapnil ENH_30

- (IBAction)fuelTypeClicked:(UIButton *)sender {
    
    self.scrollView.scrollEnabled = NO;
    self.fuelTypeTableView.hidden = NO;
    [self.view bringSubviewToFront:self.fuelTypeTableView];
    self.fuelTypeTableView.allowsSelection = YES;
    [self.fuelTypeTableView reloadData];
}

- (IBAction)addSpecsButton:(id)sender {
    
    //self.customSpecsString coming from ViewVehicleVC
    //NSLog(@"self.customSpecsString : %@", self.customSpecsString);
    
    //For empty strings put as nil or else it will be considered as a record
    if([self.customSpecsString isEqualToString:@""]){
        self.customSpecsString = nil;
    }
    
    //Pass self.customSpecsString to custSpec String of AddSpecificationsVC
    AddSpecifications *addSpecsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"addSpecs"];
    addSpecsVC.custSpec = self.customSpecsString;
    addSpecsVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController pushViewController:addSpecsVC animated:YES];
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
    
    if ([context hasChanges])
    {
        BOOL saved = [context save:&err];
        if (!saved) {
            // do some real error handling
            //CLSLog(@“Could not save Data due to %@“, error);
        }
       [[CoreDataController sharedInstance] saveMasterContext];
        //Upload data from common methods
        commonMethods *common = [[commonMethods alloc] init];
        [common checkNetworkForCloudStorage:@"isVehicle"];
    }
    
    
}


- (void)checkNetworkForCloudStorage{
    
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    
    if(networkStatus == NotReachable){
        
        [CheckReachability.sharedManager startNetworkMonitoring];
    } else {


       // [self performSelectorInBackground:@selector(fetchDataFromSyncTable) withObject:nil];
    }
}

//Loop through the Sync table, fetch table name, type (add, edit, del) and rowID of record
- (void)fetchDataFromSyncTable{

    NSManagedObjectContext *context =  [[CoreDataController sharedInstance] backgroundManagedObjectContext];
    NSError *err;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Sync_Table"];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"tableName == 'VEH_TABLE' OR tableName == 'SERVICE_TABLE'"];
    
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
    
    if([tableName isEqualToString:@"VEH_TABLE"]){
        
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Veh_Table"];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"iD == %d", [rowID intValue]];
        
        [request setPredicate:predicate];
        NSArray *dataValue = [context executeFetchRequest:request error:&err];
        
        
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
        for (Veh_Table *veh in dataValue) {
            
            //Make dictionary of parameters to be passed to the script
            if(rowID != nil){
                [dictionary setObject:rowID forKey:@"_id"];
            } else {
                [dictionary setObject:@"" forKey:@"_id"];
            }
            
            if(type != nil){
                [dictionary setObject:type forKey:@"type"];
            } else {
                [dictionary setObject:@"" forKey:@"type"];
            }
            
            if([def objectForKey:@"UserEmail"] != nil){
                [dictionary setObject:[def objectForKey:@"UserEmail"] forKey:@"email"];
            } else {
                [dictionary setObject:@"" forKey:@"email"];
            }
            
            if([def objectForKey:@"UserDeviceId"] != nil){
                [dictionary setObject:[def objectForKey:@"UserDeviceId"] forKey:@"androidId"];
            } else {
                [dictionary setObject:@"" forKey:@"androidId"];
            }
            [dictionary setObject:@"phone" forKey:@"source"];
            
            [dictionary setObject:veh.make forKey:@"make"];
            [dictionary setObject:veh.model forKey:@"model"];
            
            if(veh.vehid != nil){
                [dictionary setObject:veh.vehid forKey:@"vehid"];
            } else {
                [dictionary setObject:@"" forKey:@"vehid"];
            }
            
            if(veh.year != nil){
                [dictionary setObject:veh.year forKey:@"year"];
            } else {
                [dictionary setObject:@"" forKey:@"year"];
            }
            
            if(veh.lic != nil){
                [dictionary setObject:veh.lic forKey:@"lic"];
            } else {
                [dictionary setObject:@"" forKey:@"lic"];
            }
            
            if(veh.vin != nil){
                [dictionary setObject:veh.vin forKey:@"vin"];
            } else {
                [dictionary setObject:@"" forKey:@"vin"];
            }
            
            if(veh.insuranceNo != nil){
                [dictionary setObject:veh.insuranceNo forKey:@"insuranceNo"];
            } else {
                [dictionary setObject:@"" forKey:@"insuranceNo"];
            }
            
            if(veh.notes != nil){
                [dictionary setObject:veh.notes forKey:@"notes"];
            } else {
                [dictionary setObject:@"" forKey:@"notes"];
            }
            
            if(veh.fuel_type != nil){
                [dictionary setObject:veh.fuel_type forKey:@"fuelType"];
            } else {
                [dictionary setObject:@"" forKey:@"fuelType"];
            }
            
            if(veh.customSpecs != nil){
                
                [dictionary setObject:veh.customSpecs forKey:@"customSpecifications"];
            } else {
                
                [dictionary setObject:@"" forKey:@"customSpecifications"];
            }
            //Start here for making single syncfree4june2018
            BOOL proUser = [[NSUserDefaults standardUserDefaults] boolForKey:@"isAdDisabled"];
            if(veh.picture != nil && veh.picture.length > 0 && proUser){
                
                NSString *imageName = veh.picture;
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                
                NSString *docPath = [paths firstObject];
                NSString *completeImgPath = [docPath stringByAppendingString:[NSString stringWithFormat:@"/%@", imageName]];
                
                UIImage *vehImage = [UIImage imageWithContentsOfFile:completeImgPath];
                
                //NSLog(@"width = %f, height = %f", vehImage.size.width, vehImage.size.height);
                
//                UIImage *smallImg = [[commonMethods class] imageWithImage:vehImage scaledToSize:CGSizeMake(500.0, 500.0)];
                
                NSData *imageData = UIImagePNGRepresentation(vehImage);
                //NSLog(@"actual img size : %ld", [imageData length]);
                float imgSizeInMB = [imageData length] / 1024.0f / 1024.0f;
                
                NSString *imageString;
                
                //If images are > than 1.5 MB, compress them and then send to server
                if(imgSizeInMB > 1.5){
                    
                    UIImage *smallImg = [[commonMethods class] imageWithImage:vehImage scaledToSize:CGSizeMake(300.0, 300.0)];
                    NSData *compressedImg = UIImagePNGRepresentation(smallImg);
                    imageString = [compressedImg base64EncodedStringWithOptions:0];
                   // NSLog(@"compressed img of size : %ld", [compressedImg length]);
                    
                } else {
                
                   // NSLog(@"full img of size : %ld", [imageData length]);
                
                    imageString = [imageData base64EncodedStringWithOptions:0];
                }
                
                [dictionary setObject:imageString forKey:@"img_file"];
                [dictionary setObject:veh.picture forKey:@"picture"];
            } else {
                
                [dictionary setObject:@"" forKey:@"img_file"];
                [dictionary setObject:@"" forKey:@"picture"];
            }
            
            
        }
        
        
        
       // NSLog(@"data val : %@", dictionary);
        
        //JSON encode paramters dictionary to be passed to script
        NSData *postData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:&err];
        [def setBool:YES forKey:@"updateTimeStamp"];
        //Pass paramters dictionary and URL of script to get response
        commonMethods *common = [[commonMethods alloc] init];
        [common saveToCloud:postData urlString:kVehDataScript success:^(NSDictionary *responseDict) {
            //    NSLog(@"Vehicle responseDict : %@", responseDict);
        
                if([[responseDict objectForKey:@"message"] isEqualToString:@"Success"]){
                    
                    //If response is succes, clear that record from phone sync table
                    [common clearPhoneSyncTableWithID:rowID tableName:tableName andType:type];
        
                }
            } failure:^(NSError *error) {
                //NSLog(@"%@", error.localizedDescription);
            }];

        
    } else if ([tableName isEqualToString:@"SERVICE_TABLE"]){
        
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
        
        //Make dictionary of parameters to be passed to the script
        if(rowID != nil){
            [dictionary setObject:rowID forKey:@"_id"];
        } else {
            [dictionary setObject:@"" forKey:@"_id"];
        }
        
        if(type != nil){
            [dictionary setObject:type forKey:@"type"];
        } else {
            [dictionary setObject:@"" forKey:@"type"];
        }
        
        if([def objectForKey:@"UserEmail"] != nil){
            [dictionary setObject:[def objectForKey:@"UserEmail"] forKey:@"email"];
        } else {
            [dictionary setObject:@"" forKey:@"email"];
        }
        
        if([def objectForKey:@"UserDeviceId"] != nil){
            [dictionary setObject:[def objectForKey:@"UserDeviceId"] forKey:@"androidId"];
        } else {
            [dictionary setObject:@"" forKey:@"androidId"];
        }
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
        
      //  NSLog(@"service val : %@", dictionary);
        
        //JSON encode paramters dictionary to be passed to script
        NSData *postData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:&err];
        [def setBool:YES forKey:@"updateTimeStamp"];
        //Pass paramters dictionary and URL of script to get response
        [common saveToCloud:postData urlString:kServiceDataScript success:^(NSDictionary *responseDict) {
                //    NSLog(@"Service responseDict : %@", responseDict);
                    
                    if([[responseDict objectForKey:@"message"] isEqualToString:@"Success"]){
                        
                        //If response is succes, clear that record from phone sync table
                        [common clearPhoneSyncTableWithID:rowID tableName:tableName andType:type];
                        
                    }
                } failure:^(NSError *error) {
                    //NSLog(@"%@", error.localizedDescription);
                }];
        
    }
    
}



@end
