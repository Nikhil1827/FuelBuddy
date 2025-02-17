//
//  SettingsViewController.m
//  FuelBuddy
//
//  Created by Surabhi on 07/12/15.
//  Copyright (c) 2015 Oraganization. All rights reserved.
//

#import "SettingsViewController.h"
#import "SettingsTableViewCell.h"
#import "SettingsDetailViewController.h"
#import "CustomiseViewController.h"
#import "AppDelegate.h"
#import "T_Fuelcons.h"
#import  "FaqViewController.h"
#import "Services_Table.h"
#import "T_Trip.h"
#import "AddFillupViewController.h"
#import "commonMethods.h"
#import "Veh_Table.h"
#import "Sync_Table.h"
#import "Reachability.h"
#import "WebServiceURL's.h"
#import "CheckReachability.h"
#import "TaxDeductionViewController.h"

@interface SettingsViewController ()
{
    BOOL distUnitChanged;
}
@end

//Swapnil 15 Mar-17
//static GADMasterViewController *shared;
@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableview.delegate=self;
    self.tableview.dataSource=self;
    self.titlearray = [[NSMutableArray alloc]initWithObjects:
                       NSLocalizedString(@"dist_tv", @"Distance"),
                       NSLocalizedString(@"vol_head", @"Volume"),
                       NSLocalizedString(@"cons_head", @"Consumption"),
                       NSLocalizedString(@"curr_head", @"Currency"),
                       NSLocalizedString(@"cust_fus_head", @"Customise Fill-Up Screen"),
                       NSLocalizedString(@"cust_db_head", @"Customise Stats & Charts"),NSLocalizedString(@"tac_rate_settings", @"Mileage Rate Settings"),nil];

    //"tac_rate_settings_desc"="Set mileage rates for tax deductions";
    self.tableview.backgroundColor = [self colorFromHexString:@"#2c2c2c"];
    self.view.backgroundColor = [self colorFromHexString:@"#303030"];
    self.navigationController.navigationBar.barTintColor = [self colorFromHexString:@"#0098AB"];
    self.navigationController.navigationBar.tintColor =[UIColor whiteColor];
    self.navigationController.navigationBar.topItem.title=NSLocalizedString(@"settings_tv", @"Settings");
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor] , NSFontAttributeName: [UIFont fontWithName:@"Helvetica-Light" size:18.0] }];
    self.tableview.separatorColor =[UIColor darkGrayColor];
   

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated
{

    self.distance = [[NSUserDefaults standardUserDefaults]objectForKey:@"dist_unit"];
    self.volume =[[NSUserDefaults standardUserDefaults]objectForKey:@"vol_unit"];
    self.consump =[[NSUserDefaults standardUserDefaults]objectForKey:@"con_unit"];
    self.currency = [[NSUserDefaults standardUserDefaults]objectForKey:@"curr_unit"];

    //NSLog(@"Dist : %@\nVol : %@\nCons : %@\nCurr : %@", self.distance, self.volume, self.consump, self.currency);
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    
    UIImage *buttonImage = [[UIImage imageNamed:@"nav_back"] resizableImageWithCapInsets:UIEdgeInsetsMake(20,10,10,10)];
    
    UIButton *Button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [Button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    
    Button.frame = CGRectMake(0.0, 10.0, buttonImage.size.width+4,buttonImage.size.height+4);
    
    UIBarButtonItem *BarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:Button];
    
    [Button addTarget:self action:@selector(backbuttonclick) forControlEvents:UIControlEventTouchUpInside];
    
    [self.navigationItem setLeftBarButtonItem:BarButtonItem];
    [self.tableview reloadData];
    

    if(![self.distance isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"dist_unit"]])
    {
        distUnitChanged = YES;
        [self showAlert:NSLocalizedString(@"convert_yes_btn", @"Convert Existing Fuel Records?") message:@""];
    }
    
   else if(![self.volume isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"vol_unit"]])
    {

        if(![self.volume isEqualToString:NSLocalizedString(@"disp_kilowatt_hour", @"Kilowatt-Hour")]){

            [self showAlert:NSLocalizedString(@"convert_yes_btn", @"Convert Existing Fuel Records?") message:@""];
        }
    }
    
  else if(![self.consump isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"con_unit"]])
    {
        //Swapnil BUG_73
        //[self convertvalue];
        //[self updatedistance];
        
        self.distance = [[NSUserDefaults standardUserDefaults]objectForKey:@"dist_unit"];
        self.volume =[[NSUserDefaults standardUserDefaults]objectForKey:@"vol_unit"];
        
        //Swapnil NEW_6
        NSString *userEmail = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserEmail"];
        
        //If user is signed In, then only do the sync process..
        if(userEmail != nil && userEmail.length > 0){
            
            NSString *newValue = [self convertLocalizedStringToConstant:[[NSUserDefaults standardUserDefaults] objectForKey:@"con_unit"]];
            
            [self writeToSyncTableWithRowID:@5 tableName:@"SETTINGS" andNewVal:newValue];
          //  [self checkNetworkForCloudStorage];
        }
        
        self.consump =[[NSUserDefaults standardUserDefaults]objectForKey:@"con_unit"];
        if(![self.consump isEqualToString:@"km/kWh"] && ![self.consump isEqualToString:@"m/kWh"]){

            [self updateconsumption];
        }

    }
    
    else if(![self.currency isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"curr_unit"]])
    {
        
        //Swapnil NEW_6
        NSString *userEmail = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserEmail"];
        
        //If user is signed In, then only do the sync process..
        if(userEmail != nil && userEmail.length > 0){
            
            NSString *newValue = [[NSUserDefaults standardUserDefaults] objectForKey:@"curr_unit"];
            NSArray *currency = [newValue componentsSeparatedByString:@" - "];
            NSString *currShort = [currency lastObject];
            
            [self writeToSyncTableWithRowID:@6 tableName:@"SETTINGS" andNewVal:currShort];
          //  [self checkNetworkForCloudStorage];
        }
        
        self.currency =[[NSUserDefaults standardUserDefaults]objectForKey:@"curr_unit"];
        
    }
    
    AppDelegate *App = (AppDelegate *)[UIApplication sharedApplication].delegate;
     App.tabbutton.hidden=NO;
    
}



-(BOOL)shouldAutorotate
{
    return NO;
}

//-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//   if(buttonIndex != [alertView cancelButtonIndex])
//    {
//        //NSLog(@"convert value");
//        [self convertvalue];
//        [self updatedistance];
//        
//        self.distance = [[NSUserDefaults standardUserDefaults]objectForKey:@"dist_unit"];
//        self.volume =[[NSUserDefaults standardUserDefaults]objectForKey:@"vol_unit"];
//        self.consump =[[NSUserDefaults standardUserDefaults]objectForKey:@"con_unit"];
//        [self updateconsumption];
//    }
//    
//    else
//    {
//        self.distance = [[NSUserDefaults standardUserDefaults]objectForKey:@"dist_unit"];
//        self.volume =[[NSUserDefaults standardUserDefaults]objectForKey:@"vol_unit"];
//        self.consump =[[NSUserDefaults standardUserDefaults]objectForKey:@"con_unit"];
//        [self updateconsumption];
//
//    }
//    
//}


- (void)showAlert:(NSString *)title message:(NSString *)message {
    
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:title
                                          message:message
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"yes", @"OK action")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   [self convertvalue];
                                   
                                   //Swapnil BUG_73
                                   if(distUnitChanged){
                                       [self updatedistance];
                                       distUnitChanged = NO;
                                   }
                                   
                                   //Swapnil NEW_6
                                   NSString *userEmail = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserEmail"];
                                   
                                   //If user is signed In, then only do the sync process..
                                   if(userEmail != nil && userEmail.length > 0){
                                   
                                       if(![self.distance isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"dist_unit"]]){
                                       
                                           NSString *newValue = [self convertLocalizedStringToConstant:[[NSUserDefaults standardUserDefaults] objectForKey:@"dist_unit"]];
                                       
                                           [self writeToSyncTableWithRowID:@1 tableName:@"SETTINGS" andNewVal:newValue];
                                          // [self checkNetworkForCloudStorage];
                                       }
                                   }
                                   self.distance = [[NSUserDefaults standardUserDefaults]objectForKey:@"dist_unit"];
                                   //NSLog(@"self->distance : %@", self.distance);
                                   
                                   //Swapnil NEW_6
                                   //If user is signed In, then only do the sync process..
                                   if(userEmail != nil && userEmail.length > 0){
                                       
                                       if(![self.volume isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"vol_unit"]]){
                                       
                                           NSString *newValue = [self convertLocalizedStringToConstant:[[NSUserDefaults standardUserDefaults] objectForKey:@"vol_unit"]];
                                       
                                           [self writeToSyncTableWithRowID:@3 tableName:@"SETTINGS" andNewVal:newValue];
                                          // [self checkNetworkForCloudStorage];
                                       }
                                   }
                                   
                                   self.volume =[[NSUserDefaults standardUserDefaults]objectForKey:@"vol_unit"];
                                  // NSLog(@"self->distance : %@", self.volume);
                                   self.consump =[[NSUserDefaults standardUserDefaults]objectForKey:@"con_unit"];
                                  // NSLog(@"self->distance : %@", self.consump);
                                   if(![self.consump isEqualToString:@"km/kWh"] && ![self.consump isEqualToString:@"m/kWh"]){

                                        [self updateconsumption];
                                   }

                               }];
    
    
    UIAlertAction *cancelAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"no", @"Cancel action")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   
                                   //Swapnil NEW_6
                                   NSString *userEmail = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserEmail"];
                                   
                                   //If user is signed In, then only do the sync process..
                                   if(userEmail != nil && userEmail.length > 0){
                                   
                                       if(![self.distance isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"dist_unit"]]){
                                       
                                            NSString *newValue = [self convertLocalizedStringToConstant:[[NSUserDefaults standardUserDefaults] objectForKey:@"dist_unit"]];
                                       
                                            [self writeToSyncTableWithRowID:@2 tableName:@"SETTINGS" andNewVal:newValue];
                                           // [self checkNetworkForCloudStorage];
                                        }
                                   }
                                   self.distance = [[NSUserDefaults standardUserDefaults]objectForKey:@"dist_unit"];
                                   
                                   //Swapnil NEW_6
                                   //If user is signed In, then only do the sync process..
                                   if(userEmail != nil && userEmail.length > 0){
                                       
                                       if(![self.volume isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"vol_unit"]]){
                                       
                                           NSString *newValue = [self convertLocalizedStringToConstant:[[NSUserDefaults standardUserDefaults] objectForKey:@"vol_unit"]];
                                       
                                           [self writeToSyncTableWithRowID:@4 tableName:@"SETTINGS" andNewVal:newValue];
                                        //   [self checkNetworkForCloudStorage];
                                       }
                                   }
                                   
                                   self.volume =[[NSUserDefaults standardUserDefaults]objectForKey:@"vol_unit"];
                                   self.consump =[[NSUserDefaults standardUserDefaults]objectForKey:@"con_unit"];
                                    if(![self.consump isEqualToString:@"km/kWh"] && ![self.consump isEqualToString:@"m/kWh"]){

                                        [self updateconsumption];
                                    }
                               }];

    
    
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
    
}

- (NSString *)convertLocalizedStringToConstant: (NSString *)localizedString{
    
    NSString *constantString;
    if([localizedString isEqualToString:NSLocalizedString(@"disp_kilometers", @"Kilometers")]){
        
        constantString = @"Kilometers";
    } else if ([localizedString isEqualToString:NSLocalizedString(@"disp_miles", @"Miles")]){
        
        constantString = @"Miles";

    } else if([localizedString isEqualToString:NSLocalizedString(@"disp_kilowatt_hour", @"Kilowatt-Hour")]){

        constantString = @"Kilowatt-Hour";
    }else if ([localizedString isEqualToString:NSLocalizedString(@"disp_litre", @"Litre")]){
        
        constantString = @"Litre";
    } else if ([localizedString isEqualToString:NSLocalizedString(@"disp_gal_us", @"Gallon (US)")]){
        
        constantString = @"Gallon(US)";
    } else if ([localizedString isEqualToString:NSLocalizedString(@"disp_gal_uk", @"Gallon (UK)")]){
        
        constantString = @"Gallon(UK)";

    } else if ([localizedString isEqualToString:NSLocalizedString(@"disp_kmpkwh", @"km/kWh")]){

        constantString = @"km/kWh";
    } else if ([localizedString isEqualToString:NSLocalizedString(@"disp_mpkwh", @"m/kWh")]){

        constantString = @"m/kWh";
    } else if ([localizedString isEqualToString:NSLocalizedString(@"disp_kmpl", @"km/L")]){
        
        constantString = @"km/L";
    } else if ([localizedString isEqualToString:NSLocalizedString(@"disp_lp100kms", @"L/100km")]){
        
        constantString = @"L/100km";
    } else if ([localizedString isEqualToString:NSLocalizedString(@"disp_mpg_us", @"mpg (US)")]){
        
        constantString = @"mpg(US)";
    } else if ([localizedString isEqualToString:NSLocalizedString(@"disp_mpg_uk", @"mpg (UK)")]){
        
        constantString = @"mpg(UK)";
    }
    
    return constantString;
}


-(void) convertvalue
{
    NSManagedObjectContext *contex = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSError *err;
    NSUserDefaults *Def =[NSUserDefaults standardUserDefaults];
    NSString *comparestring = [NSString stringWithFormat:@"%@",[Def objectForKey:@"fillupid"]];
    
    NSFetchRequest *requset=[[NSFetchRequest alloc] initWithEntityName:@"T_Fuelcons"];
    
    NSFetchRequest *serviceRequest = [[NSFetchRequest alloc] initWithEntityName:@"Services_Table"];
    
    //Swapnil BUG_73
    NSFetchRequest *tripRequest = [[NSFetchRequest alloc] initWithEntityName:@"T_Trip"];
    
    //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"vehid==%@",comparestring];
    
    //NSPredicate *tripPredicate = [NSPredicate predicateWithFormat:@"vehId==%@",comparestring];

    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"odo"
                                                                   ascending:YES];
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"lastOdo"
                                                                   ascending:YES];
    
    //Swapnil BUG_73
    NSSortDescriptor *sortDescriptor3 = [[NSSortDescriptor alloc] initWithKey:@"depOdo"
                                                                    ascending:YES];

    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    NSArray *serviceDescriptor = [[NSArray alloc] initWithObjects:sortDescriptor2, nil];
    
    //Swapnil BUG_73
    NSArray *tripDescriptor = [[NSArray alloc] initWithObjects:sortDescriptor3, nil];
    
   // [requset setPredicate:predicate];
    [requset setSortDescriptors:sortDescriptors];
    
   // [serviceRequest setPredicate:predicate];
    [serviceRequest setSortDescriptors:serviceDescriptor];
    
    //Swapnil BUG_73
    //[tripRequest setPredicate:tripPredicate];
    [tripRequest setSortDescriptors:tripDescriptor];
    
    NSArray *datavalue=[contex executeFetchRequest:requset error:&err];
    
    NSArray *serviceData = [contex executeFetchRequest:serviceRequest error:&err];
    
    //Swapnil BUG_73
    NSArray *tripData = [contex executeFetchRequest:tripRequest error:&err];
    
    NSDateFormatter *formater=[[NSDateFormatter alloc] init];
    [formater setDateFormat:@"dd/MM/yyyy"];
    for(T_Fuelcons *fuelrecord in datavalue)
    {
        
        if([self.distance isEqualToString:NSLocalizedString(@"disp_miles", @"Miles")] && [[[NSUserDefaults standardUserDefaults] objectForKey:@"dist_unit"] isEqualToString:NSLocalizedString(@"disp_kilometers", @"Kilometers")])
        {
            fuelrecord.odo = @([fuelrecord.odo floatValue] * 1.61);
        }
        
        else if([self.distance isEqualToString:NSLocalizedString(@"disp_kilometers", @"Kilometers")] && [[[NSUserDefaults standardUserDefaults] objectForKey:@"dist_unit"] isEqualToString:NSLocalizedString(@"disp_miles", @"Miles")])
        {
            fuelrecord.odo = @([fuelrecord.odo floatValue]/ 1.61);
        }
        
        if([self.volume isEqualToString:NSLocalizedString(@"disp_litre", @"Litre")] && [[[NSUserDefaults standardUserDefaults] objectForKey:@"vol_unit"] isEqualToString:NSLocalizedString(@"disp_gal_us", @"Gallon (US)")])
        {
            fuelrecord.qty = @([fuelrecord.qty floatValue]/3.79);
        }
        
       else if([self.volume isEqualToString:NSLocalizedString(@"disp_litre", @"Litre")] && [[[NSUserDefaults standardUserDefaults] objectForKey:@"vol_unit"] isEqualToString:NSLocalizedString(@"disp_gal_uk", @"Gallon (UK)")])
        {
            fuelrecord.qty = @([fuelrecord.qty floatValue]/4.55);
        }
        
       else if([self.volume isEqualToString:NSLocalizedString(@"disp_gal_us", @"Gallon (US)")] && [[[NSUserDefaults standardUserDefaults] objectForKey:@"vol_unit"] isEqualToString:NSLocalizedString(@"disp_litre", @"Litre")])
       {
           fuelrecord.qty = @([fuelrecord.qty floatValue]*3.79);
       }
        
       else if([self.volume isEqualToString:NSLocalizedString(@"disp_gal_uk", @"Gallon (UK)")] && [[[NSUserDefaults standardUserDefaults] objectForKey:@"vol_unit"] isEqualToString:NSLocalizedString(@"disp_litre", @"Litre")])
       {
           fuelrecord.qty = @([fuelrecord.qty floatValue]*4.55);
       }
        
       else if([self.volume isEqualToString:NSLocalizedString(@"disp_gal_uk", @"Gallon (UK)")] && [[[NSUserDefaults standardUserDefaults] objectForKey:@"vol_unit"] isEqualToString:NSLocalizedString(@"disp_gal_us", @"Gallon (US)")])
       {
           fuelrecord.qty = @([fuelrecord.qty floatValue]*1.2);
       }
        
       else if([self.volume isEqualToString:NSLocalizedString(@"disp_gal_us", @"Gallon (US)")] && [[[NSUserDefaults standardUserDefaults] objectForKey:@"vol_unit"] isEqualToString:NSLocalizedString(@"disp_gal_uk", @"Gallon (UK)")])
       {
           fuelrecord.qty = @([fuelrecord.qty floatValue]/1.2);
       }

    }
    
    for(Services_Table *serviceRec in serviceData){
        
        if([self.distance isEqualToString:NSLocalizedString(@"disp_miles", @"Miles")] && [[[NSUserDefaults standardUserDefaults] objectForKey:@"dist_unit"] isEqualToString:NSLocalizedString(@"disp_kilometers", @"Kilometers")])
        {
            serviceRec.lastOdo = @([serviceRec.lastOdo floatValue] * 1.61);
            
            //Swapnil BUG_73
            serviceRec.dueMiles = @([serviceRec.dueMiles floatValue] * 1.61);
        }
        
        else if([self.distance isEqualToString:NSLocalizedString(@"disp_kilometers", @"Kilometers")] && [[[NSUserDefaults standardUserDefaults] objectForKey:@"dist_unit"] isEqualToString:NSLocalizedString(@"disp_miles", @"Miles")])
        {
            serviceRec.lastOdo = @([serviceRec.lastOdo floatValue]/ 1.61);
            
            //Swapnil BUG_73
            serviceRec.dueMiles = @([serviceRec.dueMiles floatValue]/ 1.61);
        }
    }
    
    //Swapnil BUG_73
    for(T_Trip *tripRec in tripData){
        
        if([self.distance isEqualToString:NSLocalizedString(@"disp_miles", @"Miles")] && [[[NSUserDefaults standardUserDefaults] objectForKey:@"dist_unit"] isEqualToString:NSLocalizedString(@"disp_kilometers", @"Kilometers")]){
            
            tripRec.depOdo = @([tripRec.depOdo floatValue] * 1.61);
            tripRec.arrOdo = @([tripRec.arrOdo floatValue] * 1.61);

        } else if([self.distance isEqualToString:NSLocalizedString(@"disp_kilometers", @"Kilometers")] && [[[NSUserDefaults standardUserDefaults] objectForKey:@"dist_unit"] isEqualToString:NSLocalizedString(@"disp_miles", @"Miles")]){
            
            tripRec.depOdo = @([tripRec.depOdo floatValue] / 1.61);
            tripRec.arrOdo = @([tripRec.arrOdo floatValue] / 1.61);
        }


    }
    
    if ([contex hasChanges])
    {
        BOOL saved = [contex save:&err];
        if (!saved) {
            // do some real error handling
            //CLSLog(@“Could not save Data due to %@“, error);
        }
        [[CoreDataController sharedInstance] saveMasterContext];
    }
}

-(void)updatedistance

{
    //Swapnil BUG_73
    NSManagedObjectContext *contex = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSFetchRequest *requset1=[[NSFetchRequest alloc] initWithEntityName:@"Veh_Table"];
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"iD"
                                                                    ascending:YES];
    NSError *err1;
    NSArray *sortDescriptors1 = [[NSArray alloc] initWithObjects:sortDescriptor1, nil];
    [requset1 setSortDescriptors:sortDescriptors1];
    
    NSArray *vehicle=[contex executeFetchRequest:requset1 error:&err1];
    commonMethods *commMethods = [[commonMethods alloc] init];
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    for(Veh_Table *veh in vehicle){
        [def setObject:veh.iD forKey:@"fillupid"];
        [commMethods updateDistance:0];
    }
}


-(void)backbuttonclick
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    
    return 20;
}

-(UIColor *)colorFromHexString:(NSString *)hexString
{
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //NIKHIL BUG_142 removing FAQs from settings
//   if(section == 0)
//   {
//       return self.titlearray.count;
//   }
//
//    else
//        return self.titlesection2.count;
     return self.titlearray.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  
   SettingsTableViewCell *cell =(SettingsTableViewCell *)[self.tableview dequeueReusableCellWithIdentifier:@"cell"];
    
    cell.selectionStyle =UITableViewCellSelectionStyleNone;
    cell.backgroundColor=[UIColor clearColor];
    cell.titlelabel.textColor =[UIColor whiteColor];
    cell.desclabel.textColor = [UIColor lightGrayColor];
    //self.tableview.style =UITableViewStyleGrouped;
    if(tableView==self.tableview)
    {
        cell.backgroundColor = [self colorFromHexString:@"#303030"];
        //NIKHIL BUG_142 removing FAQs from settings
//        if (indexPath.section==0)
//        {
            cell.unitlabel.textColor =[UIColor lightGrayColor];
            if(indexPath.row==0)
            {
                cell.unitlabel.text = [[NSUserDefaults standardUserDefaults]objectForKey:@"dist_unit"];
            }
            
            if(indexPath.row==1)
            {
                cell.unitlabel.text = [[NSUserDefaults standardUserDefaults]objectForKey:@"vol_unit"];
            }
            
            if(indexPath.row==2)
            {
                cell.unitlabel.text = [[NSUserDefaults standardUserDefaults]objectForKey:@"con_unit"];
            }
            
            if(indexPath.row==3)
            {
                cell.unitlabel.text = [[NSUserDefaults standardUserDefaults]objectForKey:@"curr_unit"];
            }
            
            cell.titlelabel.text = [self.titlearray objectAtIndex:indexPath.row];
            cell.desclabel.text=@"";
    
    }
    
    
    return cell;
    
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   
    if(indexPath.section==0)
    {
     SettingsDetailViewController *setting = (SettingsDetailViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"settingsdetails"];
     setting.unittype = [self.titlearray objectAtIndex:indexPath.row];
    
    if(indexPath.row==0)
    {
    
        setting.selectvalue =[[NSMutableArray alloc]initWithObjects:
                              NSLocalizedString(@"disp_miles", @"Miles"),
                              NSLocalizedString(@"disp_kilometers", @"Kilometers"), nil];
       setting.modalPresentationStyle = UIModalPresentationFullScreen;
        [self.navigationController pushViewController:setting animated:YES];
    }
    
   
    if(indexPath.row==1)
    {
        
        setting.selectvalue =[[NSMutableArray alloc]initWithObjects:
                              NSLocalizedString(@"disp_litre", @"Litre"),
                              NSLocalizedString(@"disp_gal_us", @"Gallon (US)"),
                              NSLocalizedString(@"disp_gal_uk", @"Gallon (UK)"),
                              NSLocalizedString(@"disp_kilowatt_hour",@"Kilowatt-Hour"),nil];
        setting.modalPresentationStyle = UIModalPresentationFullScreen;
        [self.navigationController pushViewController:setting animated:YES];
    }

    
    if(indexPath.row==2)
    {
        if([self.volume isEqualToString:NSLocalizedString(@"disp_kilowatt_hour",@"Kilowatt-Hour")]){

            setting.selectvalue =[[NSMutableArray alloc]initWithObjects:
                                  NSLocalizedString(@"disp_kmpkwh", @"km/kWh"),
                                  NSLocalizedString(@"disp_mpkwh", @"m/kWh"),nil];
        }else {

            setting.selectvalue =[[NSMutableArray alloc]initWithObjects:
                                  NSLocalizedString(@"disp_kmpl", @"km/L"),
                                  NSLocalizedString(@"disp_lp100kms", @"L/100km"),
                                  NSLocalizedString(@"disp_mpg_us", @"mpg (US)"),
                                  NSLocalizedString(@"disp_mpg_uk", @"mpg (UK)"),nil];
        }
//        setting.selectvalue =[[NSMutableArray alloc]initWithObjects:
//                              NSLocalizedString(@"disp_kmpl", @"km/L"),
//                              NSLocalizedString(@"disp_lp100kms", @"L/100km"),
//                              NSLocalizedString(@"disp_mpg_us", @"mpg (US)"),
//                              NSLocalizedString(@"disp_mpg_uk", @"mpg (UK)"),
//                              NSLocalizedString(@"disp_kmpkwh", @"km/kWh"),
//                              NSLocalizedString(@"disp_mpkwh", @"m/kWh"),nil];
        setting.modalPresentationStyle = UIModalPresentationFullScreen;
        [self.navigationController pushViewController:setting animated:YES];
    }

    
    if(indexPath.row==3)
    {
     
        setting.selectvalue =[[NSMutableArray alloc]initWithObjects:@"Afghan afghani - AFN",
                              @"Albanian lek - ALL",
                              @"Algerian dinar - DZD",
                              @"Angolan kwanza - AOA",
                              @"Argentine peso - ARS",
                              @"Armenian dram - AMD",
                              @"Aruban florin - AWG",
                              @"Australian dollar - AUD",
                              @"Azerbaijani manat - AZN",
                              @"Bahamian dollar - BSD",
                              @"Bahraini dinar - BHD",
                              @"Bangladeshi taka - BDT",
                              @"Barbadian dollar - BBD",
                              @"Belarusian ruble - BYR",
                              @"Belize dollar - BZD",
                              @"Bhutanese ngultrum - BTN",
                              @"Bolivian boliviano - BOB",
                              @"Bosnia and Herzegovina konvertibilna marka - BAM",
                              @"Botswana pula - BWP",
                              @"Brazilian real - BRL",
                              @"British pound - GBP",
                              @"Brunei dollar - BND",
                              @"Bulgarian lev - BGN",
                              @"Burundi franc - BIF",
                              @"Cambodian riel - KHR",
                              @"Canadian dollar - CAD",
                              @"Cape Verdean escudo - CVE",
                              @"Cayman Islands dollar - KYD",
                              @"Central African CFA franc - XAF",
                              @"Central African CFA franc - GQE",
                              @"CFP franc - XPF",
                              @"Chilean peso - CLP",
                              @"Chinese renminbi - CNY",
                              @"Colombian peso - COP",
                              @"Comorian franc - KMF",
                              @"Congolese franc - CDF",
                              @"Costa Rican colon - CRC",
                              @"Croatian kuna - HRK",
                              @"Cuban peso - CUC",
                              @"Czech koruna - CZK",
                              @"Danish krone - DKK",
                              @"Djiboutian franc - DJF",
                              @"Dominican peso - DOP",
                              @"East Caribbean dollar - XCD",
                              @"Egyptian pound - EGP",
                              @"Eritrean nakfa - ERN",
                              @"Estonian kroon - EEK",
                              @"Ethiopian birr - ETB",
                              @"European euro - EUR",
                              @"Falkland Islands pound - FKP",
                              @"Fijian dollar - FJD",
                              @"Gambian dalasi - GMD",
                              @"Georgian lari - GEL",
                              @"Ghanaian cedi - GHS",
                              @"Gibraltar pound - GIP",
                              @"Guatemalan quetzal - GTQ",
                              @"Guinean franc - GNF",
                              @"Guyanese dollar - GYD",
                              @"Haitian gourde - HTG",
                              @"Honduran lempira - HNL",
                              @"Hong Kong dollar - HKD",
                              @"Hungarian forint - HUF",
                              @"Icelandic krona - ISK",
                              @"Indian rupee - INR",
                              @"Indonesian rupiah - IDR",
                              @"Iranian rial - IRR",
                              @"Iraqi dinar - IQD",
                              @"Israeli new sheqel - ILS",
                              @"Jamaican dollar - JMD",
                              @"Japanese yen - JPY",
                              @"Jordanian dinar - JOD",
                              @"Kazakhstani tenge - KZT",
                              @"Kenyan shilling - KES",
                              @"Kuwaiti dinar - KWD",
                              @"Kyrgyzstani som - KGS",
                              @"Lao kip - LAK",
                              @"Latvian lats - LVL",
                              @"Lebanese lira - LBP",
                              @"Lesotho loti - LSL",
                              @"Liberian dollar - LRD",
                              @"Libyan dinar - LYD",
                              @"Lithuanian litas - LTL",
                              @"Macanese pataca - MOP",
                              @"Macedonian denar - MKD",
                              @"Malagasy ariary - MGA",
                              @"Malawian kwacha - MWK",
                              @"Malaysian ringgit - MYR",
                              @"Maldivian rufiyaa - MVR",
                              @"Mauritanian ouguiya - MRO",
                              @"Mauritian rupee - MUR",
                              @"Mexican peso - MXN",
                              @"Moldovan leu - MDL",
                              @"Mongolian tugrik - MNT",
                              @"Moroccan dirham - MAD",
                              @"Mozambican metical - MZM",
                              @"Myanma kyat - MMK",
                              @"Namibian dollar - NAD",
                              @"Nepalese rupee - NPR",
                              @"Netherlands Antillean gulden - ANG",
                              @"New Taiwan dollar - TWD",
                              @"New Zealand dollar - NZD",
                              @"Nicaraguan cordoba - NIO",
                              @"Nigerian naira - NGN",
                              @"North Korean won - KPW",
                              @"Norwegian krone - NOK",
                              @"Omani rial - OMR",
                              @"Paanga - TOP",
                              @"Pakistani rupee - PKR",
                              @"Panamanian balboa - PAB",
                              @"Papua New Guinean kina - PGK",
                              @"Paraguayan guarani - PYG",
                              @"Peruvian nuevo sol - PEN",
                              @"Philippine peso - PHP",
                              @"Polish zloty - PLN",
                              @"Qatari riyal - QAR",
                              @"Romanian leu - RON",
                              @"Russian ruble - RUB",
                              @"Rwandan franc - RWF",
                              @"Saint Helena pound - SHP",
                              @"Samoan tala - WST",
                              @"Sao Tome and Principe dobra - STD",
                              @"Saudi riyal - SAR",
                              @"Serbian dinar - RSD",
                              @"Seychellois rupee - SCR",
                              @"Sierra Leonean leone - SLL",
                              @"Singapore dollar - SGD",
                              @"Slovak koruna - SKK",
                              @"Solomon Islands dollar - SBD",
                              @"Somali shilling - SOS",
                              @"South African rand - ZAR",
                              @"South Korean won - KRW",
                              @"Special Drawing Rights - XDR",
                              @"Sri Lankan rupee - LKR",
                              @"Sudanese pound - SDG",
                              @"Surinamese dollar - SRD",
                              @"Swazi lilangeni - SZL",
                              @"Swedish krona - SEK",
                              @"Swiss Franc - CHF",
                              @"Syrian pound - SYP",
                              @"Tajikistani somoni - TJS",
                              @"Tanzanian shilling - TZS",
                              @"Thai baht - THB",
                              @"Trinidad and Tobago dollar - TTD",
                              @"Tunisian dinar - TND",
                              @"Turkish new lira - TRY",
                              @"Turkmen manat - TMM",
                              @"UAE dirham - AED",
                              @"Ugandan shilling - UGX",
                              @"Ukrainian hryvnia - UAH",
                              @"Uruguayan peso - UYU",
                              @"U.S. Dollar - USD",
                              @"Uzbekistani som - UZS",
                              @"Vanuatu vatu - VUV",
                              @"Venezuelan bolivar - VEB",
                              @"Vietnamese dong - VND",
                              @"West African CFA franc - XOF",
                              @"Yemeni rial - YER",
                              @"Zambian kwacha - ZMK",
                              @"Zimbabwean dollar - ZWD",
                              nil];
        setting.modalPresentationStyle = UIModalPresentationFullScreen;
        [self.navigationController pushViewController:setting animated:YES];
    }
    
    if(indexPath.row == 4)
    {
        CustomiseViewController *custom = (CustomiseViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"customise"];
        custom.modalPresentationStyle = UIModalPresentationFullScreen;
        [self.navigationController pushViewController:custom animated:YES];
    }
        
    if(indexPath.row==5)
    {
        CustomDashViewController *cust = (CustomDashViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"custdash"];
            cust.modalPresentationStyle = UIModalPresentationFullScreen;
            [self.navigationController pushViewController:cust animated:YES];
    }

    if(indexPath.row==6)
    {
        TaxDeductionViewController *taxScreen =(TaxDeductionViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"taxDeduction"];
        taxScreen.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:taxScreen animated:YES completion:nil];

    }
        
        
    
    }

}

-(void)updateconsumption
{
    
    //Swapnil BUG_73
    NSManagedObjectContext *contex = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSFetchRequest *requset1=[[NSFetchRequest alloc] initWithEntityName:@"Veh_Table"];
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"iD"
                                                                    ascending:YES];
    NSError *err1;
    NSArray *sortDescriptors1 = [[NSArray alloc] initWithObjects:sortDescriptor1, nil];
    [requset1 setSortDescriptors:sortDescriptors1];
    
    NSArray *vehicle=[contex executeFetchRequest:requset1 error:&err1];
    
    commonMethods *commMethods = [[commonMethods alloc] init];
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    for(Veh_Table *veh in vehicle){
        [def setObject:veh.iD forKey:@"fillupid"];
        [commMethods updateConsumption:0];
    }
}

#pragma mark CLOUD SYNC METHODS

//Save rowID, tableName, and new Val(Kilometers/Miles...) in phones Sync table
- (void)writeToSyncTableWithRowID: (NSNumber *)rowID tableName: (NSString *)tableName andNewVal: (NSString *)newVal{

    NSManagedObjectContext *context = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSError *err;
    Sync_Table *syncData = [NSEntityDescription insertNewObjectForEntityForName:@"Sync_Table" inManagedObjectContext:context];
    
    syncData.rowID = rowID;
    syncData.tableName = tableName;
    syncData.type = newVal;
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
        [common checkNetworkForCloudStorage:@"isSettings"];
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

//Loop through the Phone Sync table, fetch table name, new Val and rowID of record
- (void)fetchDataFromSyncTable{

    NSManagedObjectContext *context = [[CoreDataController sharedInstance] backgroundManagedObjectContext];
    NSError *error;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Sync_Table"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"tableName == 'SETTINGS'"];
    [request setPredicate:predicate];
    NSArray *dataArray = [context executeFetchRequest:request error:&error];
    
    for(Sync_Table *syncData in dataArray){
        
        NSString *newVal = syncData.type;
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

            [self setParametersWithNewVal:newVal andRowID:syncData.rowID andTableName:syncData.tableName];
        }

    }
}

//Loop thr' the specified tableName and get record for specified rowID
- (void)setParametersWithNewVal: (NSString *)newVal andRowID: (NSNumber *)rowID andTableName: (NSString *)tableName{

    NSMutableDictionary *parametersDictionary = [[NSMutableDictionary alloc] init];
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSError *err;
    
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
    
    if(rowID != nil){
        [parametersDictionary setObject:rowID forKey:@"_id"];
    } else {
        [parametersDictionary setObject:@"" forKey:@"_id"];
    }
    
    if(newVal != nil){
        [parametersDictionary setObject:newVal forKey:@"new_val"];
    } else {
        [parametersDictionary setObject:@"" forKey:@"new_val"];
    }
    
    //NSLog(@"Params Dict : %@", parametersDictionary);
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:parametersDictionary options:NSJSONWritingPrettyPrinted error:&err];
    
    //NSString *dataInString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    //NSLog(@"Json data in string : %@", dataInString);
    [def setBool:YES forKey:@"updateTimeStamp"];
    commonMethods *common = [[commonMethods alloc] init];
    //Pass paramters dictionary and URL of script to get response
    [common saveToCloud:jsonData urlString:kSettingsScript success:^(NSDictionary *responseDict) {
     //   NSLog(@"responseDict Settings : %@", responseDict);
        
        if([[responseDict objectForKey:@"message"] isEqualToString:@"Success"]){
            
            [common clearPhoneSyncTableWithID:rowID tableName:tableName andType:newVal];
        }
    } failure:^(NSError *error) {
        //NSLog(@"%@", error.localizedDescription);
    }];
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
