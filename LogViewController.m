//
//  LogViewController.m
//  FuelBuddy
//
//  Created by Surabhi on 16/11/15.
//  Copyright (c) 2015 Oraganization. All rights reserved.
//

#import "LogViewController.h"
#import "AppDelegate.h"
#import "T_Fuelcons.h"
#import "LogTableViewCell.h"
#import "Veh_Table.h"
#import "AddFillupViewController.h"
#import "AddExpenseViewController.h"
#import "AddTripViewController.h"
#import "ServiceViewController.h"
#import "Services_Table.h"
#import "SearchViewController.h"
#import "T_Trip.h"
#import <Crashlytics/Crashlytics.h>
#import "StoreKit/StoreKit.h"
#import "commonMethods.h"
#import "LocationServices.h"
#import "Sync_Table.h"
#import "Reachability.h"
#import "WebServiceURL's.h"
#import "CheckReachability.h"
#import "MBProgressHUD.h"
@import GoogleMobileAds;

#define SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)


@interface LogViewController ()
{
    NSDateFormatter* f;
}

//NIKHIL BUG_131 //added property
@property int selPickerRow;

@end

//Swapnil 15 Mar-17
 //static GADMasterViewController *shared;
@implementation LogViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    f=[[NSDateFormatter alloc] init];
    [f setDateStyle:NSDateFormatterLongStyle];
    
    [f setDateFormat:@"dd-MMM-yyyy hh:mm aa"];
    [f setAMSymbol:@"AM"];
    [f setPMSymbol:@"PM"];
    //Changed the object type bcuz it is causing langaue issues
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"filluptype"]==nil)
    {
        //[[NSUserDefaults standardUserDefaults] setObject:NSLocalizedString(@"odometer", @"Odometer") forKey:@"filluptype"];
        [[NSUserDefaults standardUserDefaults] setObject:@"odometer" forKey:@"filluptype"];
    }
    
    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"odovalue"];
    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"odofilter"];
    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"datevalue"];
    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"datefilter"];
    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"notefilter"];
    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"recordfilter"];

    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
      [self.tabBarController.tabBar setHidden:NO];
    
    AppDelegate *App = [AppDelegate sharedAppDelegate];
    App.tabbutton.hidden=NO;
    self.navigationController.navigationBar.barTintColor = [self colorFromHexString:@"#0098AB"];
    self.navigationController.navigationBar.tintColor =[UIColor whiteColor];
    self.navigationController.navigationBar.topItem.title=@"Simply Auto";
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor] , NSFontAttributeName: [UIFont fontWithName:@"Helvetica-Light" size:18.0] }];
    self.view.backgroundColor = [self colorFromHexString:@"#2c2c2c"];
    UIImage *buttonImage = [[UIImage imageNamed:@"nav_back"] resizableImageWithCapInsets:UIEdgeInsetsMake(20,10,10,10)];
    UIButton *Button = [UIButton buttonWithType:UIButtonTypeCustom];
    [Button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    Button.frame = CGRectMake(0.0, 10.0, buttonImage.size.width+4,buttonImage.size.height+4);
    UIBarButtonItem *BarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:Button];
    [Button addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setLeftBarButtonItem:BarButtonItem];
  
    //[self homescreensettings];
    // Do any additional setup after loading the view.
    self.vehimg.hidden=YES;
    self.distlab.hidden=YES;
    self.getstarted.hidden=YES;
    self.set.hidden=YES;
    self.addveh.hidden=YES;
    self.vehname.hidden =YES;
    self.vehiclebutton.hidden =YES;
    self.vehimage.hidden=YES;
    //self.tableview.hidden=YES;
    self.lineview.hidden=YES;
    self.tableview.backgroundColor = [self colorFromHexString:@"#2c2c2c"];
    self.tableview.delegate=self;
    self.tableview.dataSource=self;
    [self.vehiclebutton addTarget:self action:@selector(openselectpicker) forControlEvents:UIControlEventTouchUpInside];
    [self.dropdownButton addTarget:self action:@selector(openselectpicker) forControlEvents:UIControlEventTouchUpInside];
    
}

- (IBAction)backButtonPressed: (id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

-(void)addsearch
{
    SearchViewController *search = (SearchViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"addsearch"];
    search.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController pushViewController:search animated:YES];
}


-(void)viewDidDisappear:(BOOL)animated
{
    AppDelegate *App = [AppDelegate sharedAppDelegate];
    App.result = [[UIScreen mainScreen] bounds].size;
    [App.blurview removeFromSuperview];
    [App.tabbutton setImage:[UIImage imageNamed:@"tab_add_new"] forState:UIControlStateNormal];
    
    [App.expense removeFromSuperview];
    [App.trip removeFromSuperview];
    [App.services removeFromSuperview];
    [App.fillup removeFromSuperview];
    [App.expenselab removeFromSuperview];
    [App.filluplab removeFromSuperview];
    [App.serviceslab removeFromSuperview];
    [App.tripLab removeFromSuperview];
    App.services.selected=NO;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidBecomeActiveNotification
                                                  object:nil];
    
}


-(UIColor *)colorFromHexString:(NSString *)hexString
{
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

-(void)viewDidAppear:(BOOL)animated
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(outOfSyncPopup)
                                                 name:@"notifyOutOfSync"
                                               object:nil];
    
    
    //[self testConstraints];
    //NSLog(@"install date : %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"installDate"]);
    [self.tabBarController.tabBar setHidden:NO];
    AppDelegate *App = [AppDelegate sharedAppDelegate];
    App.tabbutton.hidden=NO;
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    if([[[NSUserDefaults standardUserDefaults]objectForKey:@"dist_unit"] isEqualToString:NSLocalizedString(@"disp_miles", @"Miles")])
    {
        self.dist = NSLocalizedString(@"mi", @"mi");
    }
    
    else
    {
        self.dist = NSLocalizedString(@"kms", @"km");
    }
   
    if([[[NSUserDefaults standardUserDefaults]objectForKey:@"vol_unit"] isEqualToString:NSLocalizedString(@"disp_kilowatt_hour", @"Kilowatt-Hour")]){

        self.vol = NSLocalizedString(@"kwh", @"kWh");

    }else if([[[NSUserDefaults standardUserDefaults]objectForKey:@"vol_unit"] isEqualToString:NSLocalizedString(@"disp_litre", @"Litre")])
    {
        self.vol = NSLocalizedString(@"ltr", @"Ltr");
        
    }
    
    else
    {
       self.vol = NSLocalizedString(@"gal", @"gal");
    }

    _vehimage.contentMode = UIViewContentModeScaleAspectFill;
    _vehimage.layer.borderWidth=0;
    _vehimage.layer.masksToBounds=YES;
    _vehimage.layer.cornerRadius = 21;
    
    [self fetchallfillup];
    [self fetchdata];
    
    if([[NSUserDefaults standardUserDefaults]objectForKey:@"odovalue"]!=nil || [[NSUserDefaults standardUserDefaults]objectForKey:@"datevalue"]!=nil || [[NSUserDefaults standardUserDefaults]objectForKey:@"notefilter"]!=nil || [[NSUserDefaults standardUserDefaults]objectForKey:@"recordfilter"]!=nil )
    {
        self.navigationItem.rightBarButtonItem =nil;
        
        self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"Reset" style:UIBarButtonItemStylePlain target:self action:@selector(resetsearch)];
    }

}

-(void)resetsearch
{
    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"odovalue"];
    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"odofilter"];
    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"datevalue"];
    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"datefilter"];
    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"notefilter"];
    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"recordfilter"];

    [self fetchallfillup];

    self.navigationItem.rightBarButtonItem = nil;
    UIImage *buttonImage = [UIImage imageNamed:@"nav_search"];
    
    UIButton *Button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [Button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    
    Button.frame = CGRectMake(0.0, 0.0, buttonImage.size.width,buttonImage.size.height);
    
    UIBarButtonItem *BarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:Button];
    
    [Button addTarget:self action:@selector(addsearch) forControlEvents:UIControlEventTouchUpInside];
    
    [self.navigationItem setRightBarButtonItem:BarButtonItem];

}

- (BOOL)shouldAutorotate {
    
    return NO;
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED < 90000
- (NSUInteger)supportedInterfaceOrientations
#else
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
#endif
{
    return UIInterfaceOrientationMaskPortrait;
}

-(void)viewWillAppear:(BOOL)animated
{
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateUIAfterSync)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    //NSLog(@"kai ahe hyat?:- %ld", (long)[def integerForKey:@"quit"]);
    //ENH_53 show alert to user for new data!
    NSString *userEmail = [def objectForKey:@"UserEmail"];
    if([def boolForKey:@"newDataAvailable"] && userEmail != nil && userEmail.length > 0){
        
        [self showAlert:@"Syncing" message:@"Newer data is being downloaded in background"];
        [def setBool:NO forKey:@"newDataAvailable"];
    }

}

- (void)showAlert: (NSString *)title message:(NSString *)message{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"OK") style:UIAlertActionStyleCancel handler:nil];
  
    [alert addAction:ok];
  
    [self presentViewController:alert animated:YES completion:nil];
    
}

- (void)updateUIAfterSync{
    
    [self fetchallfillup];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.detailsarray.count == 1){
        [self createPageVC];
       // if(self.interstitial.isReady){
       //     [self.interstitial presentFromRootViewController:self];
       // }
    }
    
    return  self.detailsarray.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"] ;
        
    }
    
    
    if(tableView==self.tableview)
    {
        // NSLog(@"called reload");
        LogTableViewCell *cell = (LogTableViewCell *)[self.tableview dequeueReusableCellWithIdentifier:@"Cell"];

        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        NSDictionary *dictionary = [[NSDictionary alloc]init];
        dictionary = [self.detailsarray objectAtIndex:indexPath.row];
        //NSLog(@"dictionary %@",dictionary);
        if([[dictionary objectForKey:@"type"]integerValue]==0)
        {
        cell.date.text = [dictionary objectForKey:@"date"];
            
            NSString *str=[NSString stringWithFormat:@"%.2f",[[dictionary objectForKey:@"odo"]floatValue]];
            NSArray *arr=[[NSArray alloc]init];
            arr = [str componentsSeparatedByString:@"."];
            int temp=[[arr lastObject] intValue];
           // NSLog(@"temp value %@",arr);
            NSString *decimalval = [NSString stringWithFormat:@"%d",temp];
            //NSString *odo_short = @"Odo";
            
            if(temp==0)
            {
            
                cell.odo.text =  [NSString stringWithFormat:@"%@: %ld", NSLocalizedString(@"odo_short", @"Odo"), [[dictionary objectForKey:@"odo"] integerValue]];
            }
            else if(![[decimalval substringFromIndex:1]isEqualToString:@"0"])
            {
                cell.odo.text =  [NSString stringWithFormat:@"%@: %.2f", NSLocalizedString(@"odo_short", @"Odo: "),[[dictionary objectForKey:@"odo"] floatValue]];
            }
            
            else
            {
                cell.odo.text =  [NSString stringWithFormat:@"%@: %.1f", NSLocalizedString(@"odo_short", @"Odo: "), [[dictionary objectForKey:@"odo"] floatValue]];
            }


            NSString *str1=[NSString stringWithFormat:@"%.3f",[[dictionary objectForKey:@"qty"]floatValue]];
            NSMutableArray *arr1=[[NSMutableArray alloc]init];
            NSArray *arr2=[[NSArray alloc]init];

            arr2 = [str1 componentsSeparatedByString:@"."];
           // int temp1=[[arr1 lastObject] intValue];
           // NSLog(@"arr2 %@",arr2);
            NSString *decimalval1 = [NSString stringWithFormat:@"%@",[arr2 lastObject]];
    
            for(int i=0;i<decimalval1.length;i++)
            {
                [arr1 addObject:[NSString stringWithFormat:@"%c",[decimalval1 characterAtIndex:i]]];
            }
            //NSLog(@"array value %@",arr1);
            if([[dictionary objectForKey:@"partial"]integerValue]==1)
            {
                //Swapnil ENH_24
                if([[arr1 lastObject] intValue]==0 && [[arr1 objectAtIndex:1]intValue]==0 && [[arr1 firstObject]intValue]!=0)
                {
        cell.qty.text = [NSString stringWithFormat:@"%.1f %@ (P)",[[dictionary objectForKey:@"qty"]floatValue],self.vol];
            }
            
            else if([[arr1 lastObject] intValue]==0 && [[arr1 objectAtIndex:1]intValue]!=0)
            {
               cell.qty.text = [NSString stringWithFormat:@"%.2f %@ (P)",[[dictionary objectForKey:@"qty"] floatValue],self.vol];
            }
            
            else if([[arr1 firstObject] intValue]==0 && [[arr1 objectAtIndex:1]intValue]==0 && [[arr1 lastObject]intValue]==0)
            {
        
                 cell.qty.text = [NSString stringWithFormat:@"%d %@ (P)",[[dictionary objectForKey:@"qty"]intValue],self.vol];
            }
                
            else
            {
                cell.qty.text = [NSString stringWithFormat:@"%.3f %@ (P)",[[dictionary objectForKey:@"qty"]floatValue],self.vol];
            }
            }
            
            else
            {
                //Swapnil ENH_24
                if([[arr1 lastObject] intValue]==0 && [[arr1 objectAtIndex:1]intValue]==0 && [[arr1 firstObject] intValue]!=0)
                {
                    cell.qty.text = [NSString stringWithFormat:@"%.1f %@",[[dictionary objectForKey:@"qty"]floatValue],self.vol];
                }
                
                else if([[arr1 lastObject] intValue]==0 && [[arr1 objectAtIndex:1]intValue]!=0)
                {
                    cell.qty.text = [NSString stringWithFormat:@"%.2f %@",[[dictionary objectForKey:@"qty"] floatValue],self.vol];
                }
                
                
                else if([[arr1 firstObject] intValue]==0 && [[arr1 objectAtIndex:1]intValue]==0 && [[arr1 lastObject]intValue]==0)
                {
                    
                    cell.qty.text = [NSString stringWithFormat:@"%d %@",[[dictionary objectForKey:@"qty"]intValue],self.vol];
                }
                
                else
                {
                    cell.qty.text = [NSString stringWithFormat:@"%.3f %@",[[dictionary objectForKey:@"qty"]floatValue],self.vol];
                }
            }
        if([dictionary objectForKey:@"dist"]!=NULL && ![[dictionary objectForKey:@"mfill"] isEqual:@1 ])
        {
        //cell.dist.text = [NSString stringWithFormat:@"(+%.2f) %@",[[dictionary objectForKey:@"dist"] floatValue],self.dist];
            NSString *str=[NSString stringWithFormat:@"%.2f",[[dictionary objectForKey:@"dist"]floatValue]];
            NSArray *arr=[[NSArray alloc]init];
            arr = [str componentsSeparatedByString:@"."];
            int temp=[[arr lastObject] intValue];
            // NSLog(@"temp value %@",arr);
            NSString *decimalval = [NSString stringWithFormat:@"%d",temp];

            
            if(temp==0)
            {
                cell.dist.text = [NSString stringWithFormat:@"(+%@) %@",[dictionary objectForKey:@"dist"],self.dist];
            }
            else if(![[decimalval substringFromIndex:1]isEqualToString:@"0"])
            {
               cell.dist.text = [NSString stringWithFormat:@"(+%.2f) %@",[[dictionary objectForKey:@"dist"] floatValue],self.dist];
            }
            
            else
            {
                cell.dist.text = [NSString stringWithFormat:@"(+%.1f) %@",[[dictionary objectForKey:@"dist"] floatValue],self.dist];
            }


        }
            else if ([[dictionary objectForKey:@"mfill"] isEqual:@1 ])
            {
                cell.dist.text = NSLocalizedString(@"missed_fillup", @"Missed Fill Up");
            
            }
        
       else
       {
           //NSString *not_applicable = @"n/a";
           cell.dist.text = NSLocalizedString(@"not_applicable", @"n/a");
       }
        if([dictionary objectForKey:@"eff"]!=NULL && ![[dictionary objectForKey:@"eff"] isEqualToString:@"0.00"])
        {
            NSString *str=[NSString stringWithFormat:@"%.2f",[[dictionary objectForKey:@"eff"]floatValue]];
            NSArray *arr=[[NSArray alloc]init];
            arr = [str componentsSeparatedByString:@"."];
            int temp=[[arr lastObject] intValue];
            // NSLog(@"temp value %@",arr);
            NSString *decimalval = [NSString stringWithFormat:@"%d",temp];
            
            
            if(temp==0)
            {
                cell.eff.text = [NSString stringWithFormat:@"%d %@",[[dictionary objectForKey:@"eff"]intValue],self.con];
            }
            else if(![[decimalval substringFromIndex:1]isEqualToString:@"0"])
            {
               cell.eff.text = [NSString stringWithFormat:@"%.2f %@",[[dictionary objectForKey:@"eff"]floatValue],self.con];
            }
            
            else
            {
                cell.eff.text = [NSString stringWithFormat:@"%.1f %@",[[dictionary objectForKey:@"eff"]floatValue],self.con];
            }

        }
        
            else
            {
                //NSString *not_applicable = @"n/a";
                cell.eff.text = NSLocalizedString(@"not_applicable", @"n/a");
            }
            
           // NSLog(@"value of cost %@",[dictionary objectForKey:@"cost"]);
        if([dictionary objectForKey:@"cost"]!=NULL && [[dictionary objectForKey:@"cost"]floatValue]!=0)
        {
    
        cell.price.text =[NSString stringWithFormat:@"%.2f %@",[[dictionary objectForKey:@"cost"]floatValue],self.curr];
        }
        else
        {
            //NSString *not_applicable = @"n/a";
            cell.price.text = NSLocalizedString(@"not_applicable", @"n/a");
        }
        cell.imageview.image = [UIImage imageNamed:@"fill_up_icon"];
            
            return cell;
        }
        
        
     else  if([[dictionary objectForKey:@"type"]integerValue]==1)
        {
            cell.date.text = [dictionary objectForKey:@"date"];
            
            NSString *str=[NSString stringWithFormat:@"%.2f",[[dictionary objectForKey:@"odo"]floatValue]];
            NSArray *arr=[[NSArray alloc]init];
            arr = [str componentsSeparatedByString:@"."];
            int temp=[[arr lastObject] intValue];
           // NSLog(@"temp value %@",arr);
            NSString *decimalval = [NSString stringWithFormat:@"%d",temp];
            //NSString *odo_short = @"Odo";
            
            if(temp==0)
            {
                cell.odo.text =  [NSString stringWithFormat:@"%@: %d", NSLocalizedString(@"odo_short", @"Odo: "), [[dictionary objectForKey:@"odo"]intValue]];
            }
            else if(![[decimalval substringFromIndex:1]isEqualToString:@"0"])
            {
                cell.odo.text =  [NSString stringWithFormat:@"%@: %.2f", NSLocalizedString(@"odo_short", @"Odo: ") ,[[dictionary objectForKey:@"odo"] floatValue]];
            }
            
            else
            {
                cell.odo.text =  [NSString stringWithFormat:@"%@: %.1f", NSLocalizedString(@"odo_short", @"Odo: ") , [[dictionary objectForKey:@"odo"] floatValue]];
            }

      
            if([dictionary objectForKey:@"cost"]!=NULL & [[dictionary objectForKey:@"cost"]floatValue]!=0)
            {
                  cell.price.text =[NSString stringWithFormat:@"%.2f %@",[[dictionary objectForKey:@"cost"]floatValue],self.curr];
            }
            else
            {
                //NSString *not_applicable = @"n/a";
                cell.price.text = NSLocalizedString(@"not_applicable", @"n/a");
            }
            
            if([dictionary objectForKey:@"filling"]!=NULL)
            {
                cell.qty.text =[NSString stringWithFormat:@"%@",[dictionary objectForKey:@"filling"]];
            }
            cell.eff.text = @"";
            if(![[dictionary objectForKey:@"service"]isEqualToString:@"Fuel Record"])
            {
            cell.dist.text = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"service"]];
               // NSLog(@"called......");
            }
            cell.imageview.image = [UIImage imageNamed:@"service_icon"];
            return cell;
        }

        
     else if([[dictionary objectForKey:@"type"]integerValue]==2)
        {
            cell.date.text = [dictionary objectForKey:@"date"];
            NSString *str=[NSString stringWithFormat:@"%.2f",[[dictionary objectForKey:@"odo"]floatValue]];
            NSArray *arr=[[NSArray alloc]init];
            arr = [str componentsSeparatedByString:@"."];
            int temp=[[arr lastObject] intValue];
           // NSLog(@"temp value %@",arr);
            NSString *decimalval = [NSString stringWithFormat:@"%d",temp];
            //NSString *odo_short = @"Odo";
            
            if(temp==0)
            {
                cell.odo.text =  [NSString stringWithFormat:@"%@: %ld", NSLocalizedString(@"odo_short", @"Odo: "), [[dictionary objectForKey:@"odo"] longValue]];
            }
            else if(![[decimalval substringFromIndex:1]isEqualToString:@"0"])
            {
                cell.odo.text =  [NSString stringWithFormat:@"%@: %.2f",  NSLocalizedString(@"odo_short", @"Odo: "), [[dictionary objectForKey:@"odo"] floatValue]];
            }
            
            else
            {
                cell.odo.text =  [NSString stringWithFormat:@"%@: %.1f", NSLocalizedString(@"odo_short", @"Odo: ") , [[dictionary objectForKey:@"odo"] floatValue]];
            }
            
            if([dictionary objectForKey:@"cost"]!=NULL & [[dictionary objectForKey:@"cost"]floatValue]!=0)
            {
                  cell.price.text =[NSString stringWithFormat:@"%.2f %@",[[dictionary objectForKey:@"cost"]floatValue],self.curr];
            }

            else
            {
                cell.price.text = NSLocalizedString(@"not_applicable", @"n/a");
            }
            
            cell.eff.text = @"";
            if([dictionary objectForKey:@"filling"]!=NULL)
            {
                cell.qty.text =[NSString stringWithFormat:@"%@",[dictionary objectForKey:@"filling"]];
            }
            
            if(![[dictionary objectForKey:@"service"]isEqualToString:@"Fuel Record"])
            {

            cell.dist.text = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"service"]];
                
            }
            cell.imageview.image = [UIImage imageNamed:@"expense_icon"];
            return cell;
        }

     else if([[dictionary objectForKey:@"type"] isEqual:@3])
     {
         
         
         cell.imageview.image = [UIImage imageNamed:@"trip_icon"];
         cell.odo.text =  [[[dictionary objectForKey:@"depLocn"] stringByAppendingString:@"-" ] stringByAppendingString:[dictionary objectForKey:@"arrLocn"]];
         cell.price.text =[NSString stringWithFormat:@"%.2f %@",[[dictionary objectForKey:@"cost"]floatValue],self.curr];
         cell.date.text = [dictionary objectForKey:@"date"];
         cell.qty.text = [dictionary objectForKey:@"tripType"];
         
         if ([[dictionary objectForKey:@"dist"] floatValue] == 0) {
             cell.dist.text = NSLocalizedString(@"in_progress", @"In Progress");
         }
         else
         {  cell.dist.text = [NSString stringWithFormat:@"(+%.1f) %@",[[dictionary objectForKey:@"dist"] floatValue],self.dist];
         }

         cell.eff.text = @"";
         
         
         
         return cell;
     }

    }
    
    return cell;
}



-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewRowAction *button = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:NSLocalizedString(@"delete", @"Delete") handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
                            {
                                
                                MBProgressHUD *_hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                                _hud.mode = MBProgressHUDModeIndeterminate;
                                _hud.label.text = NSLocalizedString(@"loading_msg", @"Loading");
                                _hud.offset = CGPointMake(0,85);
                                AppDelegate *App = [AppDelegate sharedAppDelegate];
                                if(App.result.height == 480) {
                                    _hud.offset = CGPointMake(0,120);
                                }
                                
                                _hud.label.textColor = [self colorFromHexString:@"#FFCA1D"];
                                _hud.bezelView.backgroundColor = [UIColor clearColor];
                                _hud.bezelView.alpha =0.6;
                                NSLog(@"HUD created");
                                    NSDictionary* delDictObj = [self.detailsarray objectAtIndex:indexPath.row];
                                
                                    NSManagedObjectContext *contex = [[CoreDataController sharedInstance] newManagedObjectContext];
                                    NSError *err;
                                    NSUserDefaults *Def =[NSUserDefaults standardUserDefaults];
                                    NSString *comparestring = [NSString stringWithFormat:@"%@",[Def objectForKey:@"fillupid"]];
                                
                                NSDateFormatter* formatter =[[NSDateFormatter alloc] init];
                                [formatter setDateFormat:@"dd-MMM-yyyy"];
                                
                                        
                                        // Check if Fuel, service or Expense records.
                                if ([[delDictObj objectForKey:@"type"] integerValue] == 1 ||[[delDictObj objectForKey:@"type"] integerValue] == 2 ||[[delDictObj objectForKey:@"type"] integerValue] == 0 )
                                        {
                                            NSFetchRequest *requset=[[NSFetchRequest alloc] initWithEntityName:@"T_Fuelcons"];
                                            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"vehid == %@ AND odo == %f AND stringDate == %@",comparestring, [[delDictObj objectForKey:@"odo"] floatValue] ,[formatter dateFromString:[delDictObj objectForKey:@"date"]] ];
                                            [requset setPredicate:predicate];
                                            
                                        NSArray *datavalue=[contex executeFetchRequest:requset error:&err];
                                        //NSLog(@"data count %d",datavalue.count);
                                            
                                        //BUG # FB 51
                                        CLS_LOG(@"predicate is %@",predicate);
                                            
                                        //Swapnil ENH_24
                                        T_Fuelcons *fuel = [datavalue firstObject];
                                            
                                        if([fuel.type integerValue] == 1 || [fuel.type integerValue] == 2)
                                        {
                                             NSArray *filluprecord = [[NSArray alloc]init];
                                            filluprecord= [fuel.serviceType componentsSeparatedByString:@","];
                                           
                                                
                                            [self updateServiceOdo:fuel.vehid :filluprecord andiD:fuel.iD];
                                        }
                                        
                                            //Swapnil NEW_6
                                            NSString *userEmail = [Def objectForKey:@"UserEmail"];
                                            //new_7  2018may
                                            //If user is signed In, then only do the sync process..
                                            if(userEmail != nil && userEmail.length > 0){
                                                
                                                NSMutableDictionary *delDict = [[NSMutableDictionary alloc]init];
                                                if(fuel.odo != nil){

                                                    [delDict setObject:fuel.odo forKey:@"odo"];
                                                }else{

                                                    [self showAlert:@"Odometer is nil" message:@"Error occured while deleting. Please contact support-ios@simplyauto.app"];
                                                }

                                                if(fuel.iD != nil && fuel.serviceType != nil) {

                                                    [delDict setObject:fuel.iD forKey:@"id"];
                                                    [delDict setObject:fuel.vehid forKey:@"vehid"];
                                                    [delDict setObject:fuel.type forKey:@"type"];
                                                    [delDict setObject:fuel.serviceType forKey:@"serviceType"];

                                                    //   [self sendUpdatedRecordToFriend:delDict];
                                                    //Deleting from cloud
                                                    [self writeToSyncTableWithRowID:fuel.iD tableName:@"LOG_TABLE" andType:@"del" andOS:@"self"];

                                                }


                                            }
                                        
                                            if(fuel != nil){
                                        
                                                //Delete from T_Fuelcons table
                                                [contex deleteObject:fuel];
                                                [[CoreDataController sharedInstance] saveMasterContext];
                                            } else {
                                                
                                                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@""
                                                                                                               message:@"Failed to delete." preferredStyle:UIAlertControllerStyleAlert];
                                                UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel
                                                                                           handler:nil];
                                                
                                                [alert addAction:ok];
                                                [self presentViewController:alert animated:YES completion:nil];
                                            }
                                        
                                        NSError *error1 = nil;
                                        if (![contex save:&error1]) {
                                           // NSLog(@"Can't Delete! %@ %@", error1, [error1 localizedDescription]);
                                            return;
                                        }
                                        
                                        [self updatedistance];
                                        [self updateconvalue];
                                        [[CoreDataController sharedInstance] saveMasterContext];
                                }
                                else // If record to be deleted is a Trip Record
                                {
                                    NSFetchRequest *requset=[[NSFetchRequest alloc] initWithEntityName:@"T_Trip"];
                                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"vehId == %@ AND depOdo == %f AND arrOdo == %f",comparestring, [[delDictObj objectForKey:@"odo"] floatValue], [[delDictObj objectForKey:@"arrOdo"] floatValue] ];
                                    [requset setPredicate:predicate];
                                    
                                    NSArray *datavalue=[contex executeFetchRequest:requset error:&err];
                                    //NSLog(@"data count %d",datavalue.count);
                                    
                                    //Swapnil ENH_24
                                    T_Trip *tripRec = [datavalue firstObject];
                                    
                                    //Swapnil NEW_6
                                    NSString *userEmail = [Def objectForKey:@"UserEmail"];
                                    
                                    //If user is signed In, then only do the sync process..
                                    if(userEmail != nil && userEmail.length > 0){
                                        
                                        NSMutableDictionary *delDict = [[NSMutableDictionary alloc]init];
                                        [delDict setObject:tripRec.depOdo forKey:@"odo"];
                                        [delDict setObject:tripRec.iD forKey:@"id"];
                                        [delDict setObject:tripRec.vehId forKey:@"vehid"];
                                        [delDict setObject:@3 forKey:@"type"];
                                        [delDict setObject:tripRec.tripType forKey:@"serviceType"];
                                        
                               //         [self sendUpdatedRecordToFriend:delDict];
                                    
                                        //Deleting from cloud
                                        [self writeToSyncTableWithRowID:tripRec.iD tableName:@"LOG_TABLE" andType:@"del" andOS:@"self"];
                                    }
                                    
                                    
                                    //Delete from Trip table
                                    [contex deleteObject:tripRec];
                                    [[CoreDataController sharedInstance] saveMasterContext];
                                    //Swapnil NEW_5
                                    //Stop updating location (even in background) if record deleted while trip in progress
                                    if([Def boolForKey:@"gpsSelect"] == YES){
                                        
                                        [[LocationServices sharedInstance].locationManager stopUpdatingLocation];
                                        [LocationServices sharedInstance].locationManager.allowsBackgroundLocationUpdates = NO;
                                        //[Def setBool:NO forKey:@"gpsSelect"];
                                        //NSLog(@"location update stopped");
                                    }
                                    
                                    NSError *error1 = nil;
                                    if (![contex save:&error1]) {
                                       // NSLog(@"Can't Delete! %@ %@", error1, [error1 localizedDescription]);
                                        return;
                                    }
                                    [[CoreDataController sharedInstance] saveMasterContext];
                                    
                                }
                                
                                        
                                        [self.detailsarray removeObjectAtIndex:indexPath.row];
                                        
                                        [self.tableview beginUpdates];
                                        [self.tableview deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                                        [self.tableview endUpdates];
                                        [self fetchallfillup];
                                


                                    }];
    button.backgroundColor = [self colorFromHexString:@"#C65E5E"];
    UITableViewRowAction *button1 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:NSLocalizedString(@"edit", @"Edit") handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
                                     {
                                  
                                         NSMutableDictionary *detail = [[NSMutableDictionary alloc]init];
                                         detail = [self.detailsarray objectAtIndex:indexPath.row];
                                         //NSLog(@"detail : %@", detail);
                                         // Check if Fuel, service or Expense records.
                                         
                                         [detail setValue:[NSString stringWithFormat:@"%ld",(long)indexPath.row] forKey:@"valueindex"];
                                         if([[detail objectForKey:@"type"] integerValue]==0)
                                         {
                                             AddFillupViewController *add = (AddFillupViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"addfillup"];
                                             
                                             [[NSUserDefaults standardUserDefaults]setObject :detail forKey:@"editdetails"];
                                             add.modalPresentationStyle = UIModalPresentationFullScreen;
                                             [self.navigationController presentViewController:add animated:YES completion:nil];
                                         }
                                         
                                         else if([[detail objectForKey:@"type"] integerValue]==2)
                                         {
                                             AddExpenseViewController *add = (AddExpenseViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"expense"];
                                             // add.details = [[NSDictionary alloc]initWithDictionary:detail];
                                        [[NSUserDefaults standardUserDefaults]setObject:detail forKey:@"editdetails"];
                                             add.modalPresentationStyle = UIModalPresentationFullScreen;
                                             [self presentViewController:add animated:YES completion:nil];
                                         }
                                         
                                         else  if([[detail objectForKey:@"type"] integerValue]==1)
                                         {
                                             ServiceViewController *add = (ServiceViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"service"];
                                             [[NSUserDefaults standardUserDefaults]setObject:detail forKey:@"editdetails"];
                                             add.modalPresentationStyle = UIModalPresentationFullScreen;
                                             [self presentViewController:add animated:YES completion:nil];
                                             
                                         }
                                         else  if([[detail objectForKey:@"type"] integerValue]==3)

                                        {
                                            AddTripViewController *add = (AddTripViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"AddTrip"];
                                            [[NSUserDefaults standardUserDefaults]setObject:detail forKey:@"editdetails"];
                                            add.modalPresentationStyle = UIModalPresentationFullScreen;
                                            [self presentViewController:add animated:YES completion:nil];
                                          
                                          }
                                

                                     }];
    button1.backgroundColor = [self colorFromHexString:@"#FFC107"];
    
    return @[button, button1];
}
////new_7 2018may nikhil
//-(void)sendUpdatedRecordToFriend:(NSDictionary *)friendDict{
//
//    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
//    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
//
//    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
//    commonMethods *common = [[commonMethods alloc]init];
//    NSMutableDictionary *parametersDict = [[NSMutableDictionary alloc]init];
//    parametersDict = [friendDict mutableCopy];
//
//    //TO get vehid
//    NSManagedObjectContext *contex = [[CoreDataController sharedInstance] newManagedObjectContext];
//    NSError *err;
//    int vehidentifier = [[friendDict objectForKey:@"vehid"] intValue];
//    NSFetchRequest *vehRequest = [[NSFetchRequest alloc] initWithEntityName:@"Veh_Table"];
//    NSPredicate *vehPredicate = [NSPredicate predicateWithFormat:@"iD == %i",vehidentifier];
//    [vehRequest setPredicate:vehPredicate];
//    NSArray *vehData = [contex executeFetchRequest:vehRequest error:&err];
//
//    Veh_Table *vehicleData = [vehData firstObject];
//    //till here
//
//    NSString *vehid = vehicleData.vehid;
//    //NSLog(@"gadiname:- %@",vehid);
//
//
//   //Add filluptype
//    //Changed the object type bcuz it is causing langaue issues
//    if([[friendDict objectForKey:@"type"]  isEqual: @0]){
//      //  if([[def objectForKey:@"filluptype"] isEqualToString:NSLocalizedString(@"odometer", @"Odometer")])
//        if([[def objectForKey:@"filluptype"] isEqualToString:@"odometer"])
//        {
//
//            [parametersDict setObject:@"Odometer" forKey:@"OT"];
//        //Changed the object type bcuz it is causing langaue issues
//        }else if([[def objectForKey:@"filluptype"] isEqualToString:@"Trip"]){
//
//            [parametersDict setObject:@"Trip" forKey:@"OT"];
//
//        }
//    }else if([[friendDict objectForKey:@"type"]  isEqual: @3]){
//        [parametersDict setObject:@"" forKey:@"OT"];
//    }else{
//        [parametersDict setObject:@"Odometer" forKey:@"OT"];
//    }
//    //NSLog(@"friendDict:-%@",friendDict);
//
//    [parametersDict setObject:vehid forKey:@"vehid"];
//    [parametersDict setObject:[def objectForKey:@"UserName"] forKey:@"name"];
//    [parametersDict setObject:[def objectForKey:@"UserEmail"] forKey:@"email"];
//    [parametersDict setObject:@"delete" forKey:@"action"];
//
//    //NSLog(@"Friend dict to be sent, has arrived here,  woohoo::- %@",parametersDict);
//
//    if(networkStatus == NotReachable){
//
//        NSMutableArray *saveArray = [[NSMutableArray alloc] init];
//        saveArray = [def objectForKey:@"pendingFriendRecord"];
//        [saveArray addObject:parametersDict];
//        [def setObject:saveArray forKey:@"pendingFriendRecord"];
//
//    } else {
//
//        NSData *postDataArray = [NSJSONSerialization dataWithJSONObject:parametersDict options:NSJSONWritingPrettyPrinted error:&err];
//
//        [def setBool:NO forKey:@"updateTimeStamp"];
//        [common saveToCloud:postDataArray urlString:kFriendSyncDataScript success:^(NSDictionary *responseDict) {
//
//            // NSLog(@"ResponseDict is : %@", responseDict);
//
//            if([[responseDict valueForKey:@"success"]  isEqual: @1]){
//
//                //NSLog(@"%@",[responseDict valueForKey:@"success"]);
//
//
//            }else{
//
//                AppDelegate *app = [[AppDelegate alloc]init];
//                NSString* alertBody = @"Failed to send data to your friends";
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

//updServiceOdo
-(void)updateServiceOdo: (NSString *)vehid : (NSArray *)servicename andiD: (NSNumber *)rowID
{
    NSManagedObjectContext *contex = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSError *err;

    //Query from T_fuelcons table with predicate : vehid & service name and sort on stringDate Desc (max on top)
    
    for(int i = 0; i < servicename.count; i++){
    
    
    NSFetchRequest *fuelRequest = [[NSFetchRequest alloc] initWithEntityName:@"T_Fuelcons"];
    NSPredicate *fuelPredicate = [NSPredicate predicateWithFormat:@"vehid == %@ AND serviceType == %@ AND iD != %@", vehid,[servicename objectAtIndex:i], rowID];
    
    NSSortDescriptor *fuelSort = [[NSSortDescriptor alloc] initWithKey:@"stringDate" ascending:NO];
    NSArray *fuelSortArray = [[NSArray alloc] initWithObjects:fuelSort, nil];
    
    [fuelRequest setPredicate:fuelPredicate];
    [fuelRequest setSortDescriptors:fuelSortArray];
    
        
        //[fuelRequest setResultType:NSDictionaryResultType];
    NSArray *fuelCondataval = [contex executeFetchRequest:fuelRequest error:&err];
        //NSLog(@"fuelCondataval : %@", fuelCondataval);
    NSNumber *newOdo;
    NSDate *newLastDate;
    
    if(fuelCondataval.count > 0){
        
        //Swapnil ENH_24
        T_Fuelcons *result = [fuelCondataval firstObject];

        newOdo = result.odo;
        NSLog(@"LogViewController line number 1006:- %@",result.stringDate);
        newLastDate = result.stringDate;
    }
    else {
        newOdo = 0;
        newLastDate = nil;
    }
    
    NSFetchRequest *requset=[[NSFetchRequest alloc] initWithEntityName:@"Services_Table"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type==1 OR type==2"];
    [requset setPredicate:predicate];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"iD"
                                                                   ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [requset setSortDescriptors:sortDescriptors];
    NSArray *servicearray=[contex executeFetchRequest:requset error:&err];
    
    for (Services_Table *service in servicearray)
    {
        if ([service.vehid isEqualToString:vehid])
        {
//            for (NSString *name in servicename)
//            {
            
                if([service.serviceName isEqualToString:[servicename objectAtIndex:i]])
                {
                   NSLog(@"LogViewController line number 1033:- %@",newLastDate);
                   service.lastDate = newLastDate;
                   service.lastOdo = newOdo;
                }
           // }
        }
    }
    
    if ([contex hasChanges])
    {
        BOOL saved = [contex save:&err];
        if (!saved) {
            // do some real error handling
            //CLSLog(@“Could not save Data due to %@“, error);
        }
        NSLog(@"saved");
        [[CoreDataController sharedInstance] saveMasterContext];
    }
   }
    
}

-(void)fetchallfillup

{
    
    NSArray *array = [[[NSUserDefaults standardUserDefaults]objectForKey:@"curr_unit"] componentsSeparatedByString:@"-"];
    NSString *string = [array lastObject];
    self.curr = string;
    
    NSArray *array1 = [[[NSUserDefaults standardUserDefaults]objectForKey:@"con_unit"] componentsSeparatedByString:@" "];
    NSString *string1 = [array1 firstObject];
    self.con = string1;
    
    f=[[NSDateFormatter alloc] init];
    [f setDateStyle:NSDateFormatterLongStyle];
    
    [f setDateFormat:@"dd-MMM-yyyy hh:mm aa"];
    [f setAMSymbol:@"AM"];
    [f setPMSymbol:@"PM"];
    
    NSManagedObjectContext *contex = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSError *err;
    NSUserDefaults *Def =[NSUserDefaults standardUserDefaults];
    NSString *comparestring = [NSString stringWithFormat:@"%@",[Def objectForKey:@"fillupid"]];
    
    //Fill up
    NSFetchRequest *requset=[[NSFetchRequest alloc] initWithEntityName:@"T_Fuelcons"];
   // NSLog(@"compare string %@",comparestring);
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"vehid==%@ AND (type==1 OR type==0 OR type==2)",comparestring];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"odo"
                                                                   ascending:NO];
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"stringDate"
                                                                   ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor,sortDescriptor1, nil];
   //  NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [requset setPredicate:predicate];
    [requset setSortDescriptors:sortDescriptors];
    
    NSArray *datavalue=[contex executeFetchRequest:requset error:&err];
    NSDateFormatter *formater=[[NSDateFormatter alloc] init];
    [formater setDateFormat:@"dd-MMM-yyyy"];
    
    // Vehicle Data
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSManagedObjectContext *managedObjectContext = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Veh_Table" inManagedObjectContext:managedObjectContext];
    [request setEntity:entity];
    
    NSError *error = nil;
    NSArray *datavalue1=[managedObjectContext executeFetchRequest:request error:&error];
    
    
    
    //Trip Data

    NSFetchRequest *trip_request = [[NSFetchRequest alloc] init];
    NSManagedObjectContext *tripContext = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSEntityDescription *tripEntity = [NSEntityDescription entityForName:@"T_Trip" inManagedObjectContext:tripContext];
    [trip_request setEntity:tripEntity];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"vehId==%@",comparestring];
    [trip_request setPredicate:pred];
    
    NSError *terror = nil;
    NSArray *tripDataRecs=[tripContext executeFetchRequest:trip_request error:&terror];
    
    
    //Swapnil ENH_24
    Veh_Table *vehicle = [datavalue1 firstObject];
    if(datavalue.count>0 || tripDataRecs.count >0)
    {
        self.tableview.hidden = NO;
        self.dropdownButton.hidden = NO;
        self.vehimg.hidden=YES;
        self.distlab.hidden=YES;
        self.getstarted.hidden=YES;
        self.set.hidden=YES;
        self.addveh.hidden=YES;
        self.vehname.hidden =NO;
        self.vehiclebutton.hidden =NO;
        self.vehimage.hidden=NO;
        self.lineview.hidden=NO;
        
        self.navigationItem.rightBarButtonItem = nil;
        UIImage *buttonImage = [UIImage imageNamed:@"nav_search"];
        
        UIButton *Button = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [Button setBackgroundImage:buttonImage forState:UIControlStateNormal];
        
        Button.frame = CGRectMake(0.0, 0.0, buttonImage.size.width,buttonImage.size.height);
        
        UIBarButtonItem *BarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:Button];
        
        [Button addTarget:self action:@selector(addsearch) forControlEvents:UIControlEventTouchUpInside];
        
        [self.navigationItem setRightBarButtonItem:BarButtonItem];
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

        
    }
    
    else if ((datavalue1.count == 1 && [vehicle.vehid isEqualToString:NSLocalizedString(@"def_car", @"Default Car")] && datavalue.count == 0 && tripDataRecs.count==0))
    {
        self.tableview.hidden = YES;
        self.dropdownButton.hidden = YES;
        self.vehname.hidden =YES;
        self.vehiclebutton.hidden =YES;
        self.vehimage.hidden=YES;
        self.vehimg.hidden=NO;
        self.distlab.hidden=NO;
        self.getstarted.hidden=NO;
        self.set.hidden=NO;
        self.addveh.hidden=NO;
        self.lineview.hidden=YES;
    }
    
    
    else
    {
        self.tableview.hidden = NO;
        self.dropdownButton.hidden =NO;
        self.vehimg.hidden=YES;
        self.distlab.hidden=YES;
        self.getstarted.hidden=YES;
        self.set.hidden=YES;
        self.addveh.hidden=YES;
        self.vehname.hidden =NO;
        self.vehiclebutton.hidden =NO;
        self.vehimage.hidden=NO;
        self.lineview.hidden=NO;
        
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

    }
    
    self.detailsarray =[[NSMutableArray alloc]init];
    for(T_Fuelcons *fuelrecord in datavalue)
    {
        
        NSMutableDictionary *dictionary  = [[NSMutableDictionary alloc]init];
        [dictionary setValue:[formater stringFromDate:fuelrecord.stringDate] forKey:@"date"];
        [dictionary setValue:fuelrecord.odo forKey:@"odo"];
        [dictionary setValue:fuelrecord.qty forKey:@"qty"];
        [dictionary setValue:fuelrecord.dist forKey:@"dist"];
        if ([self.con containsString:@"100"])
        {
        [dictionary setValue:[NSString stringWithFormat:@"%.2f",100/[fuelrecord.cons floatValue]] forKey:@"eff"];
        }
        else
        {
            [dictionary setValue:[NSString stringWithFormat:@"%.2f",[fuelrecord.cons floatValue]] forKey:@"eff"];
        }
        [dictionary setValue:fuelrecord.type forKey:@"type"];
        [dictionary setValue:fuelrecord.fillStation forKey:@"filling"];
        [dictionary setValue:fuelrecord.serviceType forKey:@"service"];
        [dictionary setValue:fuelrecord.cost forKey:@"cost"];
        [dictionary setValue:fuelrecord.pfill forKey:@"partial"];
        [dictionary setValue:fuelrecord.mfill forKey:@"mfill"];
        //BUG_157 NIKHIL keyName octane changed to ocatne
        [dictionary setValue:fuelrecord.octane forKey:@"octane"];
        [dictionary setValue:fuelrecord.notes forKey:@"notes"];
        [dictionary setValue:fuelrecord.receipt forKey:@"receipt"];
        [dictionary setValue:fuelrecord.fuelBrand forKey:@"brand"];
        [dictionary setValue:fuelrecord.dist forKey:@"distance"];
        [self.detailsarray addObject:dictionary];
        //NSLog(@"dictionary value %@",self.detailsarray);

    }
    
    for(T_Trip *tripRec in tripDataRecs)
    {
        
        NSMutableDictionary *dictionary  = [[NSMutableDictionary alloc]init];
        
        if ([tripRec.arrOdo floatValue] > 0) {
            float distance = [tripRec.arrOdo floatValue] - [tripRec.depOdo floatValue];
            [dictionary setValue:@(distance) forKey:@"dist"];
        }
        else
            [dictionary setValue:@0 forKey:@"dist"];
        
       
        [dictionary setValue:[f stringFromDate:tripRec.depDate] forKey:@"date"];
        [dictionary setValue:tripRec.depOdo forKey:@"odo"];
        [dictionary setValue:tripRec.tripType forKey:@"tripType"];
        [dictionary setValue:tripRec.arrOdo forKey:@"arrOdo"];
        [dictionary setValue:tripRec.taxDedn forKey:@"cost"];
        [dictionary setValue:tripRec.arrDate forKey:@"arrDate"];
        [dictionary setValue:tripRec.parkingAmt forKey:@"parkingAmt"];
        [dictionary setValue:tripRec.tollAmt forKey:@"tollAmt"];
        [dictionary setValue:tripRec.notes forKey:@"notes"];
        
        
        if (tripRec.depLocn.length > 0) {
            [dictionary setValue:tripRec.depLocn forKey:@"depLocn"];
        }
        else
        {
            [dictionary setValue:@"n/a" forKey:@"depLocn"];
        }
        
        if (tripRec.arrLocn.length > 0) {
            [dictionary setValue:tripRec.arrLocn forKey:@"arrLocn"];
        }
        else
        {
            [dictionary setValue:@"n/a" forKey:@"arrLocn"];
        }

        
        [dictionary setValue:@"Trip"  forKey:@"service"];
        [dictionary setValue:@3 forKey:@"type"];
        [dictionary setValue:[NSNumber numberWithBool:tripRec.tripComplete] forKey:@"isComplete"];


        [self.detailsarray addObject:dictionary];
        // NSLog(@"dictionary value %@",self.detailsarray);

    }
    //NSLog(@"dictionary value %@",self.detailsarray);
 
    NSString *recordtype =  [[NSUserDefaults standardUserDefaults]objectForKey:@"recordfilter"];
    NSMutableArray *detailcopy = [[NSMutableArray alloc]initWithArray:self.detailsarray];
    if([[NSUserDefaults standardUserDefaults]objectForKey:@"recordfilter"]!=nil)
    {
        if([recordtype isEqualToString:@"Fillup"])
        {
            for(NSDictionary *dictionary in detailcopy)
            {
                //remove other types
              if([[dictionary objectForKey:@"type"]integerValue]==1 || [[dictionary objectForKey:@"type"]integerValue]==2 || [[dictionary objectForKey:@"type"]integerValue]==3)
              {
                  [self.detailsarray removeObject:dictionary];
              }
            }
        }
        
        if([recordtype isEqualToString:@"Other Expenses"])
        {
            for(NSDictionary *dictionary in detailcopy)
            {   //remove other types
                if([[dictionary objectForKey:@"type"]integerValue]==0 || [[dictionary objectForKey:@"type"]integerValue]==1|| [[dictionary objectForKey:@"type"]integerValue]==3)
                {
                    [self.detailsarray removeObject:dictionary];
                }
            }
        }
        
        if([recordtype isEqualToString:@"Services"])
        {
            for(NSDictionary *dictionary in detailcopy)
            {   //remove other types
                if([[dictionary objectForKey:@"type"]integerValue]==0 || [[dictionary objectForKey:@"type"]integerValue]==2 || [[dictionary objectForKey:@"type"]integerValue]==3)
                {
                    [self.detailsarray removeObject:dictionary];
                }
            }
        }
        if([recordtype isEqualToString:@"Trip"])
        {
            for(NSDictionary *dictionary in detailcopy)
            {   //remove other types
                if([[dictionary objectForKey:@"type"]integerValue]==0 || [[dictionary objectForKey:@"type"]integerValue]==2 || [[dictionary objectForKey:@"type"]integerValue]==1)
                {
                    [self.detailsarray removeObject:dictionary];
                }
            }
        }

    }
    
    NSString *odometer = [[NSUserDefaults standardUserDefaults]objectForKey:@"odovalue"];
     NSMutableArray *odofilter = [[NSMutableArray alloc]initWithArray:self.detailsarray];
    if([[NSUserDefaults standardUserDefaults]objectForKey:@"odovalue"]!=nil)
    {
        NSString *odotype = [[NSUserDefaults standardUserDefaults]objectForKey:@"odofilter"];
    
        for(NSDictionary *dictionary in odofilter)
        {
            if ([odotype isEqualToString:NSLocalizedString(@"search_odo_filter_0", @"Odometer greater than")])
            {
                if([[dictionary objectForKey:@"odo"]floatValue] < [odometer floatValue])
                {
                    [self.detailsarray removeObject:dictionary];
                }
            }
            
            if ([odotype isEqualToString:NSLocalizedString(@"search_odo_filter_1", @"Odometer less than")])
            {
                if([[dictionary objectForKey:@"odo"]floatValue] > [odometer floatValue])
                {
                    [self.detailsarray removeObject:dictionary];
                }
            }

        }
    }
    
    if([[NSUserDefaults standardUserDefaults]objectForKey:@"notefilter"]!=nil)
    {
        NSArray *array = [[[NSUserDefaults standardUserDefaults]objectForKey:@"notefilter"] componentsSeparatedByString:@","];
       // NSLog(@"array value %@",array);
         NSMutableArray *notefilter = [[NSMutableArray alloc]initWithArray:self.detailsarray];
        NSMutableArray *notearray =[[NSMutableArray alloc]init];
        
        for(NSDictionary *dictionary in notefilter)
        {
            for(int i =0 ;i <array.count;i++)
            {
                if([[[dictionary objectForKey:@"notes"] lowercaseString] containsString:[[array objectAtIndex:i] lowercaseString]])
                {
                    //[self.detailsarray removeObject:dictionary];
                    [notearray addObject:dictionary];
                }
            }
        }
        
        
        self.detailsarray = [[NSMutableArray alloc]initWithArray:notearray];
    }
    
    
    if([[NSUserDefaults standardUserDefaults]objectForKey:@"datevalue"]!=nil)
    {
        NSString *datefilter = [[NSUserDefaults standardUserDefaults]objectForKey:@"datefilter"];
        NSString *datevalue = [[NSUserDefaults standardUserDefaults]objectForKey:@"datevalue"];
       
       // "search_date_filter_1" = "Date less than";
         NSMutableArray *datearray = [[NSMutableArray alloc]initWithArray:self.detailsarray];
        if([datefilter isEqualToString:NSLocalizedString(@"search_date_filter_0", @"Date greater than")])
        {
            for(NSDictionary *dictionary in datearray)
            {
            if([[formater dateFromString:datevalue] compare:[formater dateFromString:[dictionary objectForKey:@"date"]]]== NSOrderedDescending)
            {
                [self.detailsarray removeObject:dictionary];
            }
        }
        }
            if([datefilter isEqualToString:NSLocalizedString(@"search_date_filter_1", @"Date less than")])
            {
                for(NSDictionary *dictionary in datearray)
                {
                    if([[formater dateFromString:datevalue] compare:[formater dateFromString:[dictionary objectForKey:@"date"]]]== NSOrderedAscending)
                    {
                        [self.detailsarray removeObject:dictionary];
                    }
                }
            }
    }
    
    //ENH_59 sorting Log only with date, if same date sorted with odo within them
    NSArray *highOdoArray = [ NSArray arrayWithArray:self.detailsarray];
    //NSSortDescriptor *highOdoSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"odo" ascending:NO];
    //NSSortDescriptor *sortDescriptorDate = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];


    highOdoArray = [highOdoArray sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setLocale:[NSLocale currentLocale]];
        [formatter setTimeZone:[NSTimeZone systemTimeZone]];
        NSString *date1 = obj1[@"date"];
        NSString *date2 = obj2[@"date"];
        if ([date1 containsString:@"AM"] || [date1 containsString:@"PM"]) {
            [formatter setDateFormat:@"dd-MMM-yyyy hh:mm a"];
        } else {
            [formatter setDateFormat:@"dd-MMM-yyyy"];
        }
        
        NSDate *d1 = [formatter dateFromString:obj1[@"date"]];
        
        if ([date2 containsString:@"AM"] || [date2 containsString:@"PM"]) {
            [formatter setDateFormat:@"dd-MMM-yyyy hh:mm a"];
        } else {
            [formatter setDateFormat:@"dd-MMM-yyyy"];
        }

        NSDate *d2 = [formatter dateFromString:obj2[@"date"]];
        
        //ENH_59 if date are same sort using odo between them only
        
        if([d1 isEqualToDate:d2]){
            
            if(obj1[@"odo"] < obj2[@"odo"]){
                return [d2 compare:d1];
            }else{
               
                return [d1 compare:d2];
            }
            
        }else{
            
            return [d2 compare:d1]; //descending
        }
    }];
   
    self.detailsarray = [highOdoArray mutableCopy];
    //NSLog(@"self.detailsarray:-%@", self.detailsarray);
    [[NSUserDefaults standardUserDefaults] setObject:self.detailsarray forKey:@"SortedLog"];
    
    dispatch_async(dispatch_get_main_queue(), ^{

        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSLog(@"HUD Hided");
    });
    [self.tableview reloadData];
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setBool:YES forKey:@"editPageOpen"];
    NSMutableDictionary *detail = [[NSMutableDictionary alloc]init];
    detail = [self.detailsarray objectAtIndex:indexPath.row];
    //NSLog(@"details array %@",self.detailsarray);
    [detail setValue:[NSString stringWithFormat:@"%ld",(long)indexPath.row] forKey:@"valueindex"];
    if([[detail objectForKey:@"type"] integerValue]==0)
    {
        AddFillupViewController *add = (AddFillupViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"addfillup"];
        
        [[NSUserDefaults standardUserDefaults]setObject :detail forKey:@"editdetails"];
        dispatch_async(dispatch_get_main_queue(), ^{
            add.modalPresentationStyle = UIModalPresentationFullScreen;
            [self.navigationController presentViewController:add animated:YES completion:nil];
        });
        
    }
    
   else if([[detail objectForKey:@"type"] integerValue]==2)
    {
        AddExpenseViewController *add = (AddExpenseViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"expense"];
        // add.details = [[NSDictionary alloc]initWithDictionary:detail];
        //NSLog(@"details %@",detail);
        [[NSUserDefaults standardUserDefaults]setObject:detail forKey:@"editdetails"];
        dispatch_async(dispatch_get_main_queue(), ^{
            add.modalPresentationStyle = UIModalPresentationFullScreen;
            [self presentViewController:add animated:YES completion:nil];

        });
           }
    
  else  if([[detail objectForKey:@"type"] integerValue]==1)
    {
        ServiceViewController *add = (ServiceViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"service"];
        [[NSUserDefaults standardUserDefaults]setObject:detail forKey:@"editdetails"];

        dispatch_async(dispatch_get_main_queue(), ^{
            add.modalPresentationStyle = UIModalPresentationFullScreen;
            [self presentViewController:add animated:YES completion:nil];
            
        });
    }
  else  if([[detail objectForKey:@"type"] integerValue]==3)
  {
      AddTripViewController *add = (AddTripViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"AddTrip"];
      [[NSUserDefaults standardUserDefaults]setObject:detail forKey:@"editdetails"];
      
      dispatch_async(dispatch_get_main_queue(), ^{
          add.modalPresentationStyle = UIModalPresentationFullScreen;
          [self presentViewController:add animated:YES completion:nil];
          
      });
  }
    
}


- (void)vehiclefetch{
    
    // NSLog(@"record checking*******");;
    // NSManagedObjectContext *contex=app.managedObjectContext;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSManagedObjectContext *managedObjectContext = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Veh_Table" inManagedObjectContext:managedObjectContext];
    [request setEntity:entity];
    
    NSError *error = nil;
     NSArray *datavalue=[managedObjectContext executeFetchRequest:request error:&error];
    
    self.vehiclearray = [[NSMutableArray alloc]init];
            for(Veh_Table *vehicle in datavalue)
            {
 
                [self.vehiclearray addObject:vehicle.vehid];
           }
    
    //NSLog(@"vehicle array %@",self.vehiclearray);
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
   
     self.pickerval = @"Select";
    
    UIBezierPath *maskPath;
    maskPath = [UIBezierPath bezierPathWithRoundedRect:_picker.bounds
                                     byRoundingCorners:(UIRectCornerTopLeft|UIRectCornerTopRight)
                                           cornerRadii:CGSizeMake(5.0, 5.0)];
    
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.view.frame;
    maskLayer.path = maskPath.CGPath;
    _picker.layer.mask = maskLayer;
    
    //NIKHIL BUG_131 //added below line
    NSUserDefaults *setRowValue = [NSUserDefaults standardUserDefaults];
    int picRowId = (int)[setRowValue integerForKey:@"rowValue"];
    [_picker selectRow:picRowId inComponent:0 animated:NO];
    
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
        //NSLog(@"VEhicleArray.count:%lu",(unsigned long)_vehiclearray.count);
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
    //NSLog(@"%i",_selPickerRow);
    
}

//-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    if(alertView.tag!=1)
//    {
//        [self donelabel];
//    }
//    
//}


-(void)donelabel
{
    [self.picker removeFromSuperview];
    [self.pic removeFromSuperview];
    [self.setbutton removeFromSuperview];
        NSUserDefaults *def =[NSUserDefaults standardUserDefaults];
        NSDictionary *dictionary = [[NSDictionary alloc]init];
        dictionary = [self.vehiclearray objectAtIndex:[self.picker selectedRowInComponent:0]];
    
       // NSLog(@"id value for vehid %@",[dictionary objectForKey:@"Id"]);
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
    
    [def synchronize];
        
        [self fetchallfillup];
    
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


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {

           return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
}


-(void)updatedistance
{
    //Swapnil BUG_73
    commonMethods *commMethods = [[commonMethods alloc] init];
    [commMethods updateDistance:0];
}

-(void)updateconvalue
{
    //Swapnil BUG_73
    commonMethods *commMethods = [[commonMethods alloc] init];
    [commMethods updateConsumption:0];
}

//Swapnil 7 Mar-17

- (void)createPageVC{
    
    if(![@"1" isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"logLaunch"]]){
        
        [[NSUserDefaults standardUserDefaults] setValue:@"1" forKey:@"logLaunch"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        navigationOverlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
        navigationOverlay.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.65];
        
        tabbarOverlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
        tabbarOverlay.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.65];
        
        [self.navigationController.view addSubview:navigationOverlay];
        [self.tabBarController.tabBar addSubview:tabbarOverlay];

        
        self.pageTitles = @[@"Tap to edit record. Swipe to delete"];
        self.imagesArray = @[@"arrowleft.png"];
        //Create page view controller
        
        self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"LogPageViewController"];
        self.pageViewController.dataSource = self;
        LogPageContentViewController *startingViewController = [self viewControllerAtIndex:0];
        NSArray *viewControllers = @[startingViewController];
        [self.pageViewController setViewControllers:viewControllers
                                          direction:UIPageViewControllerNavigationDirectionForward
                                           animated:YES
                                         completion:nil];
        
        //change size of page view controller
        self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height + 48);
        [self addChildViewController:self.pageViewController];
        [self.view addSubview:self.pageViewController.view];
        [self.pageViewController didMoveToParentViewController:self];
        
        UITapGestureRecognizer *tapToDissmiss = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dissmissAction)];
        [self.pageViewController.view addGestureRecognizer:tapToDissmiss];
    }
    
}


//Swapnil NEW_6
#pragma mark CLOUD SYNC METHODS


//Save rowID, tableName, and type in phones Sync table
- (void)writeToSyncTableWithRowID: (NSNumber *)rowID tableName: (NSString *)tableName andType: (NSString *)type andOS:(NSString *)originalSource{
  
    NSManagedObjectContext *context = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSError *err;
    Sync_Table *syncData = [NSEntityDescription insertNewObjectForEntityForName:@"Sync_Table" inManagedObjectContext:context];
    
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
       //[self performSelectorInBackground:@selector(checkNetworkForCloudStorage) withObject:nil];
       // [self checkNetworkForCloudStorage];
        ///Upload data from common methods
        commonMethods *common = [[commonMethods alloc] init];
        [common checkNetworkForCloudStorage:@"isDel"];

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
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"tableName == 'LOG_TABLE'"];
    [request setPredicate:predicate];
    NSArray *dataArray = [context executeFetchRequest:request error:&err];
    for(Sync_Table *syncData in dataArray){
        
        NSString *type = syncData.type;
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

//Loop thr' the specified tableName and delete record for specified rowID
- (void)setParametersWithType: (NSString *)type andRowID: (NSNumber *)rowID andTableName: (NSString *)tableName{
    
    commonMethods *common = [[commonMethods alloc] init];
        
    NSMutableDictionary *parametersDictionary = [[NSMutableDictionary alloc] init];
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    
    [parametersDictionary setObject:[def objectForKey:@"UserEmail"] forKey:@"email"];
    [parametersDictionary setObject:@"phone" forKey:@"source"];
    if(type){
       [parametersDictionary setObject:type forKey:@"type"];
    }else{
       [parametersDictionary setObject:@"" forKey:@"type"];
    }

    //Added new parameter for friend stuff
    [parametersDictionary setObject:@"self" forKey:@"originalSource"];

    //NSLog(@"rowID::%@ or type::%@",rowID,type);
    [parametersDictionary setObject:rowID forKey:@"_id"];
    [parametersDictionary setObject:[def objectForKey:@"UserDeviceId"] forKey:@"androidId"];
    

    //NSLog(@"Log params dict : %@", parametersDictionary);
    
    NSError *err;
    NSData *postData = [NSJSONSerialization dataWithJSONObject:parametersDictionary options:NSJSONWritingPrettyPrinted error:&err];
    [def setBool:YES forKey:@"updateTimeStamp"];
    //Pass paramters dictionary and URL of script to get response
    [common saveToCloud:postData urlString:kLogDataScript success:^(NSDictionary *responseDict) {
      //  NSLog(@"responseDict LOG : %@", responseDict);
        
        if([[responseDict objectForKey:@"message"] isEqualToString:@"Success"]){
            
            [common clearPhoneSyncTableWithID:rowID tableName:tableName andType:type];
        }
    } failure:^(NSError *error) {
      //  NSLog(@"%@", error.localizedDescription);
    }];
}


- (void)outOfSyncPopup{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Data Out of Sync"
                                                                             message:@"The data on this device seems to be out of sync with your data on the cloud. Please use the resync option in 'My Cloud Account' to sync data with the cloud."
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"Ok")
                                                       style:UIAlertActionStyleCancel
                                                     handler:nil];
    
    [alertController addAction:okAction]; 
    [self presentViewController:alertController animated:YES completion:^{
        
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:@"notifyOutOfSync"
                                                      object:nil];
    }];
}


#pragma mark - PAGEVIEWCONTROLLER Delegate methods

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController{
    
    NSUInteger index = ((LogPageContentViewController *) viewController).pageIndex;
    if ((index == 0) || (index == NSNotFound)){
        
        return nil;
    }
    index--;
    return [self viewControllerAtIndex:index];
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController{
    
    NSUInteger index = ((LogPageContentViewController*) viewController).pageIndex;
    
    if (index == NSNotFound){
        return nil;
    }
    
    index++;
    
    if (index == [self.pageTitles count]){
        
        //NSLog(@"%lu", [self.pageTitles count]);

        return nil;
    }
    
    
    return [self viewControllerAtIndex:index];
}

- (void)dissmissAction{
    
    [self.pageViewController.view removeFromSuperview];
    [self.pageViewController removeFromParentViewController];
    [navigationOverlay removeFromSuperview];
    [tabbarOverlay removeFromSuperview];
}

-(LogPageContentViewController *)viewControllerAtIndex:(NSUInteger)index{
    
    if (([self.pageTitles count] == 0) || (index >= [self.pageTitles count])) {

        return nil;
    }
    
    LogPageContentViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"LogPageContentViewController"];
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
