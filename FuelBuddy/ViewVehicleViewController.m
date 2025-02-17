//
//  ViewVehicleViewController.m
//  FuelBuddy
//
//  Copyright (c) 2015 Oraganization. All rights reserved.
//

#import "ViewVehicleViewController.h"
#import "AppDelegate.h"
#import "Veh_Table.h"
#import "VehicleViewTableViewCell.h"
#import "VehicleaddViewController.h"
#import "T_Fuelcons.h"
#import "Services_Table.h"
#import <Crashlytics/Crashlytics.h>
#import "Sync_Table.h"
#import "commonMethods.h"
#import "T_Trip.h"
#import "Reachability.h"
#import "WebServiceURL's.h"
#import "CheckReachability.h"


@interface ViewVehicleViewController ()

@end

//Swapnil 15 Mar-17
//static GADMasterViewController *shared;
@implementation ViewVehicleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
         [self.tabBarController.tabBar setHidden:NO];
    AppDelegate *App = [AppDelegate sharedAppDelegate];
    App.tabbutton.hidden=NO;
    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"odovalue"];
    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"odofilter"];
    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"datevalue"];
    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"datefilter"];
    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"notefilter"];
    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"recordfilter"];
    self.vehiclearray =[[NSMutableArray alloc]init];
    self.tableview.delegate=self;
    self.tableview.dataSource=self;
   // self.tableview.hidden=YES;
    self.tableview.tableFooterView=[UIView new];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
   self.urlstring = [paths firstObject];
    self.navigationController.navigationBar.barTintColor = [self colorFromHexString:@"#0098AB"];
    self.navigationController.navigationBar.tintColor =[UIColor whiteColor];
    
    //NSString *veh_tv = @"Vehicles";
    self.navigationController.navigationBar.topItem.title=[NSLocalizedString(@"veh_tv", @"Vehicles") capitalizedString];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor] , NSFontAttributeName: [UIFont fontWithName:@"Helvetica-Light" size:18.0] }];
    
    self.view.backgroundColor = [self colorFromHexString:@"#2c2c2c"];
    self.tableview.backgroundColor =[self colorFromHexString:@"#2c2c2c"];
    self.checkedarray=[[NSMutableArray alloc]init];
    NSUserDefaults *def =[NSUserDefaults standardUserDefaults];
    if([def objectForKey:@"checked"]!=nil)
    {
        self.checkedarray=[[NSMutableArray alloc]initWithArray:[[def arrayForKey:@"checked"]mutableCopy]];
        //NSLog(@"Checked Array contains::::%@",self.checkedarray);
   }
    
    UIImage *buttonImage = [UIImage imageNamed:@"nav_back"];
    
    UIButton *Button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [Button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    
    Button.frame = CGRectMake(0.0, 0.0, buttonImage.size.width,buttonImage.size.height);
    
    UIBarButtonItem *BarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:Button];
    
    [Button addTarget:self action:@selector(backbuttonclick) forControlEvents:UIControlEventTouchUpInside];
    
    [self.navigationItem setLeftBarButtonItem:BarButtonItem];
    //self.automaticallyAdjustsScrollViewInsets = NO;
    //self.tableViewScrollOffset = self.tableview.contentOffset;
}


-(void)backbuttonclick {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)viewDidDisappear:(BOOL)animated
{
   // NSLog(@"called disappear");
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
    
        
}

-(void)viewWillDisappear:(BOOL)animated
{
    //NSLog(@"view disappear");
    if(self.vehiclearray.count>0)
    {
        NSMutableDictionary *vehicle = [[NSMutableDictionary alloc]init];
       // NSLog(@"vehicle arr : %@", self.vehiclearray);
       // NSLog(@"checked array %@",self.checkedarray);
        if(self.checkedarray.count>0 && [[self.checkedarray firstObject]integerValue] < self.vehiclearray.count)
        {
           // CLS_LOG(@"vehicle array beyond bounds : %@", self.vehiclearray);
           // CLS_LOG(@"checked array beyond bounds : %@", self.checkedarray);
            vehicle = [self.vehiclearray objectAtIndex:[[self.checkedarray firstObject]integerValue]];
        }
        else
        { // BUG_67 Nupur
            vehicle = [self.vehiclearray firstObject];
        }
        NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
        [def setObject:[vehicle objectForKey:@"Id"] forKey:@"idvalue"];
        [def setObject:[NSString stringWithFormat:@"%@ %@",[vehicle objectForKey:@"Make"],[vehicle objectForKey:@"Model"]] forKey:@"vehname"];
        [def setObject:[NSString stringWithFormat:@"%@",[vehicle objectForKey:@"Id"]] forKey:@"fillupid"];
        [def setObject:[vehicle objectForKey:@"Picture"] forKey:@"vehimage"];
       // NSLog(@"vehicle %@",vehicle);
       // NSLog(@" name-----%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"vehname"]);
    }
    
    else
    {
        NSUserDefaults *def = [NSUserDefaults standardUserDefaults];

        [def setObject:nil forKey:@"idvalue"];
        [def setObject:nil forKey:@"vehname"];
        [def setObject:nil forKey:@"fillupid"];
        [def setObject:nil forKey:@"vehimage"];
    }

   

    //NSLog(@"id value %@",[[NSUserDefaults standardUserDefaults]objectForKey:@"Id"]);
   // NSLog(@"vehicle name %@",[[NSUserDefaults standardUserDefaults]objectForKey:@"vehname"]);
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

-(void)viewDidAppear:(BOOL)animated
{
     [self.tabBarController.tabBar setHidden:NO];
    AppDelegate *App = [AppDelegate sharedAppDelegate];
    App.tabbutton.hidden=NO;

    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addclick)];
    
                                             
    [self fetchdata];
    if(self.vehiclearray.count!=0)
    {
      //  self.tableview.hidden=NO;
    [self.tableview reloadData];
    }
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    
}


-(BOOL)shouldAutorotate
{
    return NO;
}


-(void)addclick
{    //ENH_58 Nikhil 25july2018 add unlimited vehicles
    BOOL platinumUser = [[NSUserDefaults standardUserDefaults] boolForKey:@"isSubscribed"];
    BOOL goldUser = [[NSUserDefaults standardUserDefaults] boolForKey:@"isAdDisabled"];
    if(platinumUser || self.vehiclearray.count < 4){
        
        NSUserDefaults *def =[NSUserDefaults standardUserDefaults];
        [def setObject:@"Add" forKey:@"save"];
        VehicleaddViewController *vehicleadd = (VehicleaddViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"addveh"];
        vehicleadd.modalPresentationStyle = UIModalPresentationFullScreen;
        [self.navigationController pushViewController:vehicleadd animated: YES];
        
    }else if(goldUser && self.vehiclearray.count < 7){
        //NSLog(@"no of vehicles:- %lu",(unsigned long)self.vehiclearray.count);
        NSUserDefaults *def =[NSUserDefaults standardUserDefaults];
        [def setObject:@"Add" forKey:@"save"];
        VehicleaddViewController *vehicleadd = (VehicleaddViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"addveh"];
        vehicleadd.modalPresentationStyle = UIModalPresentationFullScreen;
        [self.navigationController pushViewController:vehicleadd animated: YES];
    }else{
        //"go_pro_unltd_vehicles_title"="Add Unlimited Vehicles"
        [self showAlert:NSLocalizedString(@"go_pro_more_vehicles_title", @"Add More Vehicles") message:NSLocalizedString(@"go_pro_for_more_vehicles", @"The free version lets you add up to 4 vehicles.\n\nTo add up to 7 vehicles please purchase the Gold version.\n\nTo add unlimited, please purchase the Platinum version.")];

    }
    
    
}

- (void)showAlert:(NSString *)title message:(NSString *)message {
    
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:title
                                          message:message
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"ok", @"OK action")
                               style:UIAlertActionStyleDefault
                               handler:nil];
    
    
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
    
}


//fetchdata from Veh_table
-(void)fetchdata
{
    self.vehiclearray =[[NSMutableArray alloc]init];

    NSManagedObjectContext *contex = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSFetchRequest *requset=[[NSFetchRequest alloc] initWithEntityName:@"Veh_Table"];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"iD"
                                                                   ascending:YES];
    NSError *err;
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [requset setSortDescriptors:sortDescriptors];

    NSArray *data=[contex executeFetchRequest:requset error:&err];
    
    for(int i =0;i<data.count;i++)
    {
        Veh_Table *vehicle = [data objectAtIndex:i];
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
        //NSLog(@"vehicle id %@",vehicle.iD);
        [dictionary setObject:vehicle.make forKey:@"Make"];
        [dictionary setObject:vehicle.model forKey:@"Model"];
        [dictionary setObject:vehicle.iD forKey:@"Id"];
       // [dictionary setObject:vehicle.picture forKey:@"vehimage"];
       
      
        NSString *fillupid = [[NSUserDefaults standardUserDefaults]objectForKey:@"fillupid"];
        //NSLog(@"fill up id %@",fillupid);
        if([vehicle.iD integerValue]==[fillupid integerValue])
        {
            self.checkedarray =[[NSMutableArray alloc]init];
            [self.checkedarray removeAllObjects];
            //NSLog(@"checked i = %d",i);
            [self.checkedarray addObject:[NSString stringWithFormat:@"%d",i]];
            //NSLog(@"CHECKED ARRAY IS ::%@",self.checkedarray);
        }
       
        
        
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
        
        //Swapnil 22-May-17
        if(vehicle.notes != nil){
            [dictionary setObject:vehicle.notes forKey:@"Notes"];
        } else {
            [dictionary setObject:@"" forKey:@"Notes"];
        }
        
        //Swapnil ENH_21
        if(vehicle.insuranceNo != nil){
            [dictionary setObject:vehicle.insuranceNo forKey:@"Insurance"];
        } else {
            [dictionary setObject:@"" forKey:@"Insurance"];
        }
        
        //Swapnil ENH_30
        if(vehicle.customSpecs != nil){
            [dictionary setObject:vehicle.customSpecs forKey:@"CustomSpecs"];
        } else {
            [dictionary setObject:@"" forKey:@"CustomSpecs"];
        }
        
        if(vehicle.fuel_type != nil){
            [dictionary setObject:vehicle.fuel_type forKey:@"FuelType"];
        } else {
            [dictionary setObject:@"" forKey:@"FuelType"];
        }
        
        [self.vehiclearray addObject:dictionary];
    }

}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
   return  self.vehiclearray.count;
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
         VehicleViewTableViewCell *cell = (VehicleViewTableViewCell *)[self.tableview dequeueReusableCellWithIdentifier:@"Cell"];
        NSMutableDictionary *vehicle = [[NSMutableDictionary alloc]init];
        vehicle = [self.vehiclearray objectAtIndex:indexPath.row];
       if(![[vehicle objectForKey:@"Picture"]isEqualToString:@""])
       {
        NSString *vehiclepic = [NSString stringWithFormat:@"%@/%@",self.urlstring,[vehicle objectForKey:@"Picture"]];
        cell.imageview.image= [UIImage imageWithContentsOfFile:vehiclepic];
           //NSLog(@"url string %@",vehiclepic);
       }
        else
        {
            cell.imageview.image = [UIImage imageNamed:@"car4.jpg"];
            
        }
        cell.checkmark.tag=indexPath.row;
        
        
         [cell.checkmark setImage:[UIImage imageNamed:@"check"] forState:UIControlStateSelected];
        [cell.checkmark setImage:[UIImage imageNamed:@"uncheck"] forState:UIControlStateNormal];
        if([self.checkedarray containsObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]])
        {
            //[cell.checkmark setImage:[UIImage imageNamed:@"checkmark01"] forState:UIControlStateNormal];
            cell.checkmark.selected=YES;
        }
        
        else if(![self.checkedarray containsObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]])
        {
            
            cell.checkmark.selected=NO;
        }
        
       if(self.checkedarray.count==0)
        {
            if(indexPath.row==0)
            {
                [cell.checkmark setImage:[UIImage imageNamed:@"check"] forState:UIControlStateNormal];
                cell.checkmark.selected=YES;
            }
        }

        //cell.checkmark.imageView.contentMode=UIViewContentModeScaleAspectFit;
        [cell.checkmark addTarget:self action:@selector(checkclick:) forControlEvents:UIControlEventTouchUpInside];
        cell.imageview.contentMode = UIViewContentModeScaleAspectFill;
        cell.imageview.clipsToBounds = YES;
        cell.vehiclename.text = [NSString stringWithFormat:@"%@ %@",[vehicle objectForKey:@"Make"],[vehicle objectForKey:@"Model"]];
        [cell.checkmark addTarget:self action:@selector(checkclick:) forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
    }
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSUserDefaults *def =[NSUserDefaults standardUserDefaults];
    [def setObject:@"Edit" forKey:@"save"];
    VehicleaddViewController *vehicleadd = (VehicleaddViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"addveh"];
    NSDictionary *vehicle = [[NSDictionary alloc]init];
     vehicle = [self.vehiclearray objectAtIndex:indexPath.row];
     vehicleadd.ID = [vehicle objectForKey:@"Id"];
     vehicleadd.makestring = [vehicle objectForKey:@"Make"];
     vehicleadd.modelstring = [vehicle objectForKey:@"Model"];
     vehicleadd.vinstring = [vehicle objectForKey:@"Vin"];
     vehicleadd.yearstring = [vehicle objectForKey:@"Year"];
     vehicleadd.lincestring = [vehicle objectForKey:@"Lic"];
     vehicleadd.imagestring = [vehicle objectForKey:@"Picture"];
    vehicleadd.fuelTypeString = [vehicle objectForKey:@"FuelType"];
    
    //Swapnil 22-May-17
    vehicleadd.noteString = [vehicle objectForKey:@"Notes"];
    
    //Swapnil ENH_21
    vehicleadd.insuranceString = [vehicle objectForKey:@"Insurance"];
    
    //Swapnil ENH_30
    //Pass selected vehicles data (customSpecsString) to vehicleaddVC
    vehicleadd.customSpecsString = [vehicle objectForKey:@"CustomSpecs"];
    vehicleadd.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController pushViewController:vehicleadd animated: YES];
}

-(void)checkclick : (id)sender
{
    
    CGPoint touchPoint = [sender convertPoint:CGPointZero toView:self.tableview];
    NSIndexPath *indexPath = [self.tableview indexPathForRowAtPoint:touchPoint];
    
   VehicleViewTableViewCell *Cell = (VehicleViewTableViewCell *)[self.tableview cellForRowAtIndexPath:indexPath];
    
    if(Cell.checkmark.selected == YES)
    {
        //[Cell.checkmark setImage:[UIImage imageNamed:@"checkmark02"] forState:UIControlStateNormal];
        [Cell.checkmark setSelected:NO];
     
        [self.checkedarray removeObject:[NSString stringWithFormat:@"%ld",(long)Cell.checkmark.tag]];
        //NSLog(@"checked array %@",self.checkedarray);
    }
    
    else if(Cell.checkmark.selected == NO)
    {
        [Cell.checkmark setSelected:YES];
        //[Cell.checkmark setImage:[UIImage imageNamed:@"checkmark01"] forState:UIControlStateSelected];
        self.checkedarray = [[NSMutableArray alloc]init];
        [self.checkedarray addObject:[NSString stringWithFormat:@"%ld",(long)Cell.checkmark.tag]];
         //NSLog(@"checked array %@",self.checkedarray);
    }

    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setObject:self.checkedarray forKey:@"checked"];
    [self.tableview reloadData];
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    NSManagedObjectContext *contex = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSFetchRequest *requset=[[NSFetchRequest alloc] initWithEntityName:@"Veh_Table"];
    NSError *err;
    NSArray *data=[contex executeFetchRequest:requset error:&err];
    if(data.count==1)
    {
        return NO;
    }
    else
    return YES;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSUserDefaults *Def = [NSUserDefaults standardUserDefaults];
    AppDelegate *app= (AppDelegate*)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *contex = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSFetchRequest *requset=[[NSFetchRequest alloc] initWithEntityName:@"Veh_Table"];
    NSError *err;
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
    dictionary = [self.vehiclearray objectAtIndex:indexPath.row];
    NSPredicate *p=[NSPredicate predicateWithFormat:@"iD == %@",[dictionary objectForKey:@"Id"]];
    [requset setPredicate:p];
    NSArray *data=[contex executeFetchRequest:requset error:&err];
    
    //NSLog(@"vehid....%@",[dictionary objectForKey:@"Id"]);
    NSManagedObjectContext *contex1 = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSFetchRequest *requset1=[[NSFetchRequest alloc] initWithEntityName:@"T_Fuelcons"];
    NSError *err1;
    NSPredicate *p1=[NSPredicate predicateWithFormat:@"vehid == %@",[dictionary objectForKey:@"Id"]];
    [requset1 setPredicate:p1];
    //NIKHIL BUG_155 crash Resolved changed contex to contex1 crash #225
    NSArray *data1=[contex1 executeFetchRequest:requset1 error:&err1];
    
    NSManagedObjectContext *contex2 = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSFetchRequest *requset2=[[NSFetchRequest alloc] initWithEntityName:@"Services_Table"];
    NSError *err2;

    NSPredicate *p2=[NSPredicate predicateWithFormat:@"vehid == %@ AND (type==1 OR type==2)",[dictionary objectForKey:@"Id"]];
   
    [requset2 setPredicate:p2];
    NSArray *data2=[contex2 executeFetchRequest:requset2 error:&err2];
    
    NSManagedObjectContext *contex3 = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSFetchRequest *requset3 = [[NSFetchRequest alloc] initWithEntityName:@"T_Trip"];
    NSError *err3;
    NSPredicate *p3 = [NSPredicate predicateWithFormat:@"vehId == %@",[dictionary objectForKey:@"Id"]];
    [requset3 setPredicate:p3];
    NSArray *data3 = [contex3 executeFetchRequest:requset3 error:&err3];

    // NSLog(@"data value %d",data1.count);
    
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        for (NSManagedObject *product in data) {
            
            //Swapnil NEW_6
            NSString *userEmail = [Def objectForKey:@"UserEmail"];
            
            //If user is signed In, then only do the sync process..
            if(userEmail != nil && userEmail.length > 0){
            
                [self writeToSyncTableWithRowID:[dictionary objectForKey:@"Id"] tableName:@"VEH_TABLE" andType:@"del"];
                [self checkNetworkForCloudStorage];
            }
            [contex deleteObject:product];
           
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
        NSError *error = nil;
        if (![contex save:&error]) {
            //NSLog(@"Can't Delete! %@ %@", error, [error localizedDescription]);
            return;
        }
        
        [self.vehiclearray removeObjectAtIndex:indexPath.row];
        
        
    if([[self.checkedarray firstObject]integerValue] != 0)
        {
            NSLog(@"checked value....%@",self.checkedarray);
            int check = [[self.checkedarray firstObject]intValue];
            [self.checkedarray removeAllObjects];
            [self.checkedarray addObject:[NSString stringWithFormat:@"%d",check-1]];
            NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
            [def setObject:self.checkedarray forKey:@"checked"];
        }
       
        NSLog(@"checked in commitEditingStyle:- %@",self.checkedarray);

        [self.tableview deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
      
    }
    
    //Delete records from T_FUELCONS for deleted vehicle
    for (T_Fuelcons *product in data1) {
        //NSLog(@"delete %@",product.vehid);
        [contex1 deleteObject:product];
        
        if ([contex1 hasChanges])
        {
            BOOL saved = [contex save:&err];
            if (!saved) {
                // do some real error handling
                //CLSLog(@“Could not save Data due to %@“, error);
            }
            [[CoreDataController sharedInstance] saveMasterContext];
        }
    }
    
    NSError *error1 = nil;
    if (![contex1 save:&error1]) {
        //NSLog(@"Can't Delete! %@ %@", error1, [error1 localizedDescription]);
        return;
    }
    
    [[CoreDataController sharedInstance] saveMasterContext];
    //Delete records from Services_Table for deleted vehicle
    for (Services_Table *product in data2) {
        // NSLog(@"delete %@",product.vehid);
        
        [contex2 deleteObject:product];
        
        if ([contex2 hasChanges])
        {
            BOOL saved = [contex save:&err];
            if (!saved) {
                // do some real error handling
                //CLSLog(@“Could not save Data due to %@“, error);
            }
            [[CoreDataController sharedInstance] saveMasterContext];
        }
    }
    
    
    NSError *error2 = nil;
    if (![contex2 save:&error2]) {
       // NSLog(@"Can't Delete! %@ %@", error2, [error2 localizedDescription]);
        return;
    }
    
    [[CoreDataController sharedInstance] saveMasterContext];
    
    //Swapnil
    //Delete records from T_Trip table for deleted vehicle
    for (T_Trip *product in data3) {
        
        [contex3 deleteObject:product];
        
        if ([contex3 hasChanges])
        {
            BOOL saved = [contex save:&err];
            if (!saved) {
                // do some real error handling
                //CLSLog(@“Could not save Data due to %@“, error);
            }
            [[CoreDataController sharedInstance] saveMasterContext];
        }
    }
    
    NSError *error3 = nil;
    if (![contex3 save:&error3]) {
       // NSLog(@"Can't Delete! %@ %@", error3, [error3 localizedDescription]);
        return;
    }
    
    [[CoreDataController sharedInstance] saveMasterContext];
    //Cancel all notifications related to this vehicle
    
    [app expireOldNotifications];
  

}

//Swapnil NEW_6
#pragma mark CLOUD SYNC METHODS

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
        ////Upload data from common methods
        commonMethods *common = [[commonMethods alloc] init];
        [common checkNetworkForCloudStorage:@"isDeleteVehicle"];
    }

}


- (void)checkNetworkForCloudStorage{
    
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    
    if(networkStatus == NotReachable){
        
       [CheckReachability.sharedManager startNetworkMonitoring];
    } else {
        
      //  [self performSelectorInBackground:@selector(fetchDataFromSyncTable) withObject:nil];
    }
}

//Loop through the Sync table, fetch table name, type (add, edit, del) and rowID of record
- (void)fetchDataFromSyncTable{

    NSManagedObjectContext *context = [[CoreDataController sharedInstance] backgroundManagedObjectContext];
    NSError *err;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Sync_Table"];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"tableName == 'VEH_TABLE'"];
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

//Loop thr' the specified tableName and delete record for specified rowID
- (void)setParametersWithType: (NSString *)type andRowID: (NSNumber *)rowID andTableName: (NSString *)tableName{
    
    commonMethods *common = [[commonMethods alloc] init];
    
    NSMutableDictionary *parametersDictionary = [[NSMutableDictionary alloc] init];
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    
    [parametersDictionary setObject:[def objectForKey:@"UserEmail"] forKey:@"email"];
    [parametersDictionary setObject:@"phone" forKey:@"source"];
    [parametersDictionary setObject:type forKey:@"type"];
    [parametersDictionary setObject:rowID forKey:@"_id"];
    [parametersDictionary setObject:[def objectForKey:@"UserDeviceId"] forKey:@"androidId"];
    
    
  //  NSLog(@"Log params dict : %@", parametersDictionary);
    [def setBool:YES forKey:@"updateTimeStamp"];
    NSError *err;
    NSData *postData = [NSJSONSerialization dataWithJSONObject:parametersDictionary options:NSJSONWritingPrettyPrinted error:&err];
    //Pass paramters dictionary and URL of script to get response
    [common saveToCloud:postData urlString:kVehDataScript success:^(NSDictionary *responseDict) {
     //   NSLog(@"vehicle responseDict LOG : %@", responseDict);
        
        if([[responseDict objectForKey:@"message"] isEqualToString:@"Success"]){
            
            [common clearPhoneSyncTableWithID:rowID tableName:tableName andType:type];
        }
    } failure:^(NSError *error) {
       // NSLog(@"%@", error.localizedDescription);
    }];
        
    
}


@end
