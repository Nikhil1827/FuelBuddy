//
//  FullSyncViewController.m
//  FuelBuddy
//
//  Created by Nikhil on 02/05/18.
//  Copyright © 2018 Oraganization. All rights reserved.
//

#import "FullSyncViewController.h"
#import "FullSyncTableViewControllerCellTableViewCell.h"
#import "SSZipArchive.h"
#import "Reachability.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"
#import "commonMethods.h"
#import "Veh_Table.h"
#import "T_Fuelcons.h"
#import "Services_Table.h"
#import "T_Trip.h"
#import "ResyncVC.h"
#import "LoggedInVC.h"

@interface FullSyncViewController ()

@end

BOOL Success;

@implementation FullSyncViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [self colorFromHexString:@"#2c2c2c"];
    self.navigationController.navigationBar.barTintColor = [self colorFromHexString:@"#0098AB"];
    self.navigationController.navigationBar.tintColor =[UIColor whiteColor];
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor] , NSFontAttributeName: [UIFont fontWithName:@"Helvetica-Light" size:18.0] }];
  
    //For back button
    UIImage *buttonImage = [UIImage imageNamed:@"nav_back"];
    UIButton *Button = [UIButton buttonWithType:UIButtonTypeCustom];
    [Button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    Button.frame = CGRectMake(0.0, 0.0, buttonImage.size.width+5,buttonImage.size.height+5);
    UIBarButtonItem *BarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:Button];
    [Button addTarget:self action:@selector(backbuttonclick) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setLeftBarButtonItem:BarButtonItem];
    
    //FULL SYNC TABLEVIEW
    self.fullSyncTableView.delegate = self;
    self.fullSyncTableView.dataSource = self;
    self.fullSyncTableView.backgroundColor = [self colorFromHexString:@"#2c2c2c"];
    self.fullSyncTableView.separatorColor = [UIColor clearColor];
    [self setFullSyncArray];
    [self.fullSyncTableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    
    if(self.fullSyncArray.count>0){
        
        self.pendingLabel.hidden = YES;
        
    }
    
}

-(void)viewDidAppear:(BOOL)animated{
   
    NSString *title = NSLocalizedString(@"full_sync_requests",@"Full Sync Requests");
    self.navigationController.navigationBar.topItem.title= title;
    
}

-(void)viewWillDisappear:(BOOL)animated{
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"doSignIn"];
    
}

-(UIColor *)colorFromHexString:(NSString *)hexString
{
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

-(void)backbuttonclick
{
   
//    [self dismissViewControllerAnimated:NO completion:^{
//        [self dismissViewControllerAnimated:YES completion:NULL];
//    }];
    [self.view.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
    //[self.presentingViewController dismissViewControllerAnimated:NO completion:NULL];
    //[self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];

}


-(void)setFullSyncArray{
    
    self.fullSyncArray = [[NSMutableArray alloc]init];
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSMutableArray *syncFriendArray = [[NSMutableArray alloc]init];
    syncFriendArray = [def objectForKey:@"syncFriends"];
   // NSLog(@"syncFriendArray is ::%@",syncFriendArray);
    
    for(NSDictionary *name in syncFriendArray){
        
        [self.fullSyncArray addObject: [name objectForKey:@"name"]];
        
    }
}

-(void)updateFullSyncArray:(NSString *)delName{
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSMutableArray *syncFriendArray = [[NSMutableArray alloc]init];
    syncFriendArray = [[def objectForKey:@"syncFriends"] mutableCopy];
    //NSLog(@"syncFriendArray:- %@",syncFriendArray);
    for(NSDictionary *name in syncFriendArray){
        
        if([[name objectForKey:@"name"] isEqualToString:delName]){
            [syncFriendArray removeObject:name];
        }
        
   }
    [def setObject:syncFriendArray forKey:@"syncFriends"];
    //to remove red dot
    if(syncFriendArray.count == 0){
        [def setBool:NO forKey:@"redRequest"];
    }
   // NSLog(@"syncFriends:- %@",[def objectForKey:@"syncFriends"]);
}

#pragma mark TableView Delegate Datasource Methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.fullSyncArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 72;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    FullSyncTableViewControllerCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"syncCell"];
    if (cell == nil) {
        cell = [[FullSyncTableViewControllerCellTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"syncCell"] ;
        
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
   // NSLog(@"fullSyncArray is ::%@",self.fullSyncArray);
    NSString *friendname = [[NSString alloc]init];
    friendname = [self.fullSyncArray objectAtIndex:indexPath.row];
    //NSLog(@"friendname is ::%@",friendname);
    if(![friendname isEqual:@""] || friendname != nil){
        cell.nameLabel.text = friendname;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
   
//    commonMethods *common = [[commonMethods alloc]init];
//    [common startHUD];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.offset = CGPointMake(0,85);
    AppDelegate *App = [AppDelegate sharedAppDelegate];
    if(App.result.height == 480) {
        hud.offset = CGPointMake(0,120);
    }
    hud.label.text = @"";
    hud.label.textColor = [self colorFromHexString:@"#FFCA1D"];
    hud.bezelView.backgroundColor = [UIColor clearColor];
    hud.bezelView.alpha =0.6;
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    
    //take zipFileName from userDefaults
    NSMutableDictionary *friendDict = [[NSMutableDictionary alloc]init];
    NSMutableArray *friendArray = [[NSMutableArray alloc]init];

    friendArray = [def objectForKey:@"syncFriends"];
    friendDict = [friendArray objectAtIndex:indexPath.row];
    
    NSString *zipFileName = [friendDict objectForKey:@"syncFileName"];
    //NSLog(@"zipFileName::-%@",zipFileName);
    
    NSString *alertTitle = @"Full Sync";
    NSString *message = @"Do you want to overwrite your Simply Auto data with this data?";
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alertTitle
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"OK")
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
                                                         [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                         
                                                         MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                                                         hud.mode = MBProgressHUDModeIndeterminate;
                                                         hud.offset = CGPointMake(0,85);
                                                         AppDelegate *App = [AppDelegate sharedAppDelegate];
                                                         if(App.result.height == 480) {
                                                             hud.offset = CGPointMake(0,120);
                                                         }
                                                         hud.label.text = @"Downloading..";
                                                         hud.label.textColor = [self colorFromHexString:@"#FFCA1D"];
                                                         hud.bezelView.backgroundColor = [UIColor clearColor];
                                                         hud.bezelView.alpha =0.6;
                                                         if([self checkForNetwork]){
                                                             [self performSelectorInBackground:@selector(downloadZipFile:) withObject:zipFileName];
                                                              [self updateFullSyncArray:[self.fullSyncArray objectAtIndex:indexPath.row]];
                                                             [self.fullSyncArray removeObjectAtIndex:indexPath.row];
                                                            
                                                         }
   
                                                     }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"Cancel")
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                              [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                         }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
}

 -(void)downloadZipFile:(NSString *)fileName{
     //New_8 changesDone
    NSString *stringURL = [NSString stringWithFormat:@"https://simplyauto.app/FullSyncFiles/%@",fileName];
    NSURL  *url = [NSURL URLWithString:stringURL];
    NSData *urlData = [NSData dataWithContentsOfURL:url];
    
    //NSLog(@"Got the data!");
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths  objectAtIndex:0];
 
    //Save the data
    //NSLog(@"Saving");
    NSString *dataPath = [path stringByAppendingPathComponent:fileName];
    dataPath = [dataPath stringByStandardizingPath];
    [urlData writeToFile:dataPath atomically:YES];
     
     NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
     NSString *zipPath = [documentsPath stringByAppendingPathComponent:fileName];
     [SSZipArchive unzipFileAtPath:zipPath toDestination:documentsPath];
     
     NSError *error;
     [[NSFileManager defaultManager] removeItemAtPath:zipPath error:&error];
     
     NSString *vehFilePath = [documentsPath stringByAppendingPathComponent:@"Vehicles.csv"];
     NSString *fuelFilePath = [documentsPath stringByAppendingPathComponent:@"Fuel_Log.csv"];
     NSString *serFilePath = [documentsPath stringByAppendingPathComponent:@"Services.csv"];
     NSString *tripFilePath = [documentsPath stringByAppendingPathComponent:@"Trip_Log.csv"];
     
     dispatch_async(dispatch_get_main_queue(),^{
      [self readvehicledata:vehFilePath];
      if(Success){

          [self readservicedata:serFilePath];
          if(Success){
            [self readfueldata:fuelFilePath];
              
              if(Success){
                  
                  [self readTripData:tripFilePath];
                  
                  NSError *error;
                  [[NSFileManager defaultManager] removeItemAtPath:vehFilePath error:&error];
                  [[NSFileManager defaultManager] removeItemAtPath:fuelFilePath error:&error];
                  [[NSFileManager defaultManager] removeItemAtPath:serFilePath error:&error];
                  
                  
                  [[CoreDataController sharedInstance] saveMasterContext];
                  [MBProgressHUD hideHUDForView:self.view animated:YES];
                  [self.fullSyncTableView reloadData];
                  
                  if(self.fullSyncArray.count==0){
                      
                      self.pendingLabel.hidden = NO;
                      
                  }
                  [self showAlert:@"" message:@"Data has been successfully synced."];
                  [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"doSignIn"];
                  commonMethods *common = [[commonMethods alloc] init];
                  NSNumber *maxNumber = [common getMaxFuelID];
                  NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
                  [def setObject:maxNumber forKey:@"maxFuelID"];
                  [self performSelectorInBackground:@selector(uploadDataToServer) withObject:nil];
                  
              }else{
                  
                  [self showAlert:@"" message:@"Failed to sync Fuel Logs. Please contact support at support-ios@simplyauto.app."];
              }
              
          }else{
               //New_8 changesDone
               [self showAlert:@"" message:@"Failed to sync Services. Please contact support at support-ios@simplyauto.app."];
              
          }
      }else{
          //New_8 changesDone
          [self showAlert:@"" message:@"Failed to sync Vehicles. Please contact support at support-ios@simplyauto.app."];
          
      }
     
     });
 
 }

- (void)uploadDataToServer{
    
    UIApplication *app = [UIApplication sharedApplication];
    __block UIBackgroundTaskIdentifier bgTask;
    
    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        
        [app endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        ResyncVC *resync = [[ResyncVC alloc] init];
        [resync fullUpload];

    });
}

#pragma mark Saving friend data into table
-(void)readvehicledata:(NSString*)path
{
    
    NSString* content = [NSString stringWithContentsOfFile:path
                                                  encoding:NSUTF8StringEncoding
                                                     error:NULL];
   
    NSArray *datavalue = [[NSArray alloc]init];
    datavalue = [content componentsSeparatedByString:@"\n"];
    //NSLog(@"filedata:-- %@",datavalue);
    NSManagedObjectContext *context = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSFetchRequest *requset=[[NSFetchRequest alloc] initWithEntityName:@"Veh_Table"];
    NSError *err;
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"iD"
                                                                    ascending:YES];
    
    NSArray *sortDescriptors1 = [[NSArray alloc] initWithObjects:sortDescriptor1, nil];
    [requset setSortDescriptors:sortDescriptors1];
    
    
    NSArray *data=[context executeFetchRequest:requset error:&err];
    
    for (NSManagedObject *product in data) {
        [context deleteObject:product];
        
    }
   
    @try {
        
        for(int i=1;i<datavalue.count;i++)
        {
            NSString *recordvalue = [datavalue objectAtIndex:i];
            NSArray *mainArray = [[NSArray alloc]init];
            mainArray = [recordvalue componentsSeparatedByString:@","];
            NSMutableArray *recordarray = [[NSMutableArray alloc] initWithArray:mainArray];
            
            NSString *firstString = [datavalue firstObject];
            
            if(![firstString containsString:@"Fuel Type"]){
                
                [recordarray insertObject:@"Fuel Type" atIndex:3];
            }
            
            //NSLog(@"values of record array %@ at index %d",recordarray,i);
            Veh_Table *data=[NSEntityDescription insertNewObjectForEntityForName:@"Veh_Table" inManagedObjectContext:context];
            
            NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
            
            data.iD = [NSNumber numberWithInt:[[recordarray firstObject] intValue]];
            
            [def setObject:data.iD forKey:@"idvalue"];
            data.make = [recordarray objectAtIndex:1];
            data.model = [recordarray objectAtIndex:2];
            data.fuel_type = [recordarray objectAtIndex:3];
            data.lic = [recordarray objectAtIndex:5];
            data.vin = [recordarray objectAtIndex:6];
            data.year = [recordarray objectAtIndex:4];
            data.insuranceNo = [recordarray objectAtIndex:7];
            data.notes = [recordarray objectAtIndex:8];
            data.vehid = [NSString stringWithFormat:@"%@ %@",[recordarray objectAtIndex:1],[recordarray objectAtIndex:2]];
            data.vehid = [recordarray objectAtIndex:10];

            NSMutableArray *custSpecArr = [[NSMutableArray alloc] init];
            for(int i = 10; i < recordarray.count; i++){
                [custSpecArr addObject:[recordarray objectAtIndex:i]];
            }
            //NSLog(@"restore arr = %@", custSpecArr);
            NSString *customSpec = [custSpecArr componentsJoinedByString:@","];
            
            data.customSpecs = customSpec;
           
            NSArray *datavalue=[context executeFetchRequest:requset error:&err];
            Veh_Table *firstrecord = [datavalue firstObject];
            Veh_Table *lastrecord = [datavalue lastObject];
            
            [def setObject:[NSString stringWithFormat:@"%ld",(long)[lastrecord.iD integerValue]] forKey:@"idvalue"];
            //BUG_172 Changed from firstrecord to lastrecord
            [def setObject:lastrecord.vehid forKey:@"vehname"];
            [def setObject:[NSString stringWithFormat:@"%ld",(long)[firstrecord.iD integerValue]] forKey:@"fillupid"];
        }
        
    } @catch (NSException *exception) {
        if (exception.name == NSRangeException) {
            //NSLog(@"Caught an NSRangeException");
            
        } else {
            //NSLog(@"Ignored a %@ exception", exception);
            @throw;
        }
        
        if ([context hasChanges])
        {
            [context rollback];
           // NSLog(@"Rolled back changes.");
        }
        
        
        //New_8 changesDone
        [self showAlert:@"" message:NSLocalizedString(@"imp_err_msg", @"Failed to restore file. Please contact support at support-ios@simplyauto.app.")];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        
    } @finally {
      //  NSLog(@"Executing finally block");
        if ([context hasChanges])
        {
            BOOL saved = [context save:&err];
            if (!saved) {
                // do some real error handling
                //CLSLog(@“Could not save Data due to %@“, error);
            }
            //NSLog(@"Context saved");
             [[CoreDataController sharedInstance] saveMasterContext];
            
        }
        Success = YES;
        
    }
    
    
}

-(void)readservicedata:(NSString*)path
{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSString* content = [NSString stringWithContentsOfFile:path
                                                  encoding:NSUTF8StringEncoding
                                                     error:NULL];
    
    NSArray *datavalue = [[NSArray alloc]init];
    datavalue = [content componentsSeparatedByString:@"\n"];
    //NSLog(@"filedata %@",datavalue);
    NSManagedObjectContext *context = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSError *err;
    NSFetchRequest *requset=[[NSFetchRequest alloc] initWithEntityName:@"Services_Table"];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"iD"
                                                                   ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [requset setSortDescriptors:sortDescriptors];
    
    
    NSArray *fuel=[context executeFetchRequest:requset error:&err];
    for (NSManagedObject *product in fuel) {
        [context deleteObject:product];
        
    }
 
    NSFetchRequest *requset1=[[NSFetchRequest alloc] initWithEntityName:@"Veh_Table"];
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"iD"
                                                                    ascending:YES];
    NSError *err1;
    NSArray *sortDescriptors1 = [[NSArray alloc] initWithObjects:sortDescriptor1, nil];
    [requset1 setSortDescriptors:sortDescriptors1];
    
    NSArray *vehicle=[context executeFetchRequest:requset1 error:&err1];
    
    
    
    NSDateFormatter *formater=[[NSDateFormatter alloc] init];
    [formater setDateFormat:@"dd/MM/yyyy"];
    
    @try
    {
        for(int i=1;i<datavalue.count;i++)
        {
            NSString *recordvalue = [datavalue objectAtIndex:i];
            NSArray *recordarray = [[NSArray alloc]init];
            recordarray = [recordvalue componentsSeparatedByString:@","];
            //NSLog(@"values of record array %@ at index %d",recordarray,i);
            Services_Table *dataval=[NSEntityDescription insertNewObjectForEntityForName:@"Services_Table" inManagedObjectContext:context];
            NSString *vehidvalue;
            
            for(Veh_Table *vehdata in vehicle)
            {
                //NSLog(@"value of record 1 %@",[recordarray objectAtIndex:1]);
                //  NSLog(@"value of vehdata %@",vehdata.vehid);
                if([[recordarray objectAtIndex:1] isEqualToString:vehdata.vehid])
                {
                    vehidvalue = [vehdata.iD stringValue];
                    break;
                }
            }
            
            NSString *lastdate = [recordarray objectAtIndex:8];
            NSTimeInterval timeInterval;
            
            //NSLog(@"last date %@",lastdate);
            if([[lastdate substringToIndex:1] isEqualToString:@"0"])
            {
                timeInterval = 0;
            }
            else
            {
                
                NSString *subStr = [lastdate substringToIndex:10 ];
                timeInterval = [subStr doubleValue];
                //NSLog(@"timeInterval : %f", timeInterval);
                
            }
            
            dataval.type = @([[recordarray objectAtIndex:2]integerValue]);
            
            if ([dataval.type  isEqualToNumber:@3]) {
                dataval.vehid = [recordarray objectAtIndex:1];
            }
            else
                dataval.vehid = vehidvalue;
            
           
            dataval.iD = @([[recordarray objectAtIndex:0] floatValue]);
            
            [def setObject:dataval.iD forKey:@"maxServiceID"];
            
            dataval.serviceName = [recordarray objectAtIndex:3];
            
            if(timeInterval != 0){
                dataval.lastDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
            }
            dataval.recurring = [NSNumber numberWithInteger: [[recordarray objectAtIndex:4] integerValue]];
            dataval.type = @([[recordarray objectAtIndex:2]integerValue]);
            dataval.lastOdo =@([[recordarray objectAtIndex:7] floatValue]) ;
            dataval.dueDays =@([[recordarray objectAtIndex:6] integerValue]);
            dataval.dueMiles = @([[recordarray objectAtIndex:5] floatValue]);
        }
        
    } @catch (NSException *exception) {
        if (exception.name == NSRangeException) {
            //NSLog(@"Caught an NSRangeException");
            
        } else {
           // NSLog(@"Ignored a %@ exception", exception);
            @throw;
        }
        
        if ([context hasChanges])
        {
           // NSLog(@"Context rollback");
            [context rollback];
            
        }
        
        Success = NO;
        
    } @finally {
        NSLog(@"Executing finally block");
        if ([context hasChanges])
        {
            BOOL saved = [context save:&err];
            if (!saved) {
                // do some real error handling
                //CLSLog(@“Could not save Data due to %@“, error);
            }
            //NSLog(@"Context saved");
            [[CoreDataController sharedInstance] saveMasterContext];
            
        }
        
        Success = YES;
        
    }
    
}


-(void)readfueldata:(NSString*)path
{
    NSString* actionMessage;
    NSString* content = [NSString stringWithContentsOfFile:path
                                                  encoding:NSUTF8StringEncoding
                                                     error:NULL];
    NSArray *datavalue = [[NSArray alloc]init];
    datavalue = [content componentsSeparatedByString:@"\n"];
   //NSLog(@"data to save %@",datavalue);
    
    //Fuel Contex backgroundManagedObjectContext
    NSManagedObjectContext *context = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSError *err;
    NSFetchRequest *requset=[[NSFetchRequest alloc] initWithEntityName:@"T_Fuelcons"];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"odo"
                                                                   ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [requset setSortDescriptors:sortDescriptors];
    
    NSArray *fuel=[context executeFetchRequest:requset error:&err];
    for (NSManagedObject *product in fuel) {
        [context deleteObject:product];
        
    }
    
    //Veh contex
    NSFetchRequest *requset1=[[NSFetchRequest alloc] initWithEntityName:@"Veh_Table"];
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"iD"
                                                                    ascending:YES];
    NSError *err1;
    NSArray *sortDescriptors1 = [[NSArray alloc] initWithObjects:sortDescriptor1, nil];
    [requset1 setSortDescriptors:sortDescriptors1];
    
    NSArray *vehicle=[context executeFetchRequest:requset1 error:&err1];
    
    NSDateFormatter *formater=[[NSDateFormatter alloc] init];
    [formater setDateFormat:@"dd/MM/yyyy"];
    
    @try {
       
        actionMessage = @"Reading Fuel Data";
        for(int i=1;i<datavalue.count;i++)
        {
           
            NSString *recordvalue = [datavalue objectAtIndex:i];
            //NSArray *recordarray = [[NSArray alloc]init];
            //recordarray = [recordvalue componentsSeparatedByString:@","];
          //  NSLog(@"values of record array at index %d ::- %@",i,recordarray);
            NSArray *mainArray = [[NSArray alloc]init];
            mainArray = [recordvalue componentsSeparatedByString:@","];
            
            NSMutableArray *recordarray = [[NSMutableArray alloc] initWithArray:mainArray];
            
            //Row ID 0,Vehicle ID 1,Odometer 2,Qty 3,Partial Tank 4,Missed Fill Up 5,Total Cost 6,Distance Travelled 7,Eff 8,Octane 9,Fuel Brand 10,Filling Station 11,Notes 12,Day 13,Month 14,Year 15,Receipt Path 16,Latitude 17,Longitude 18,Record Type 19,Record Desc 20
            
            if(recordarray.count==19){
                
                [recordarray insertObject:@"0" atIndex:17];
                [recordarray insertObject:@"0" atIndex:18];
            }
            
            //separate trip records in tripdatavalue
//            int recordtype = [[recordarray objectAtIndex:19] intValue];
//            if(recordtype != 3 ){
            
                T_Fuelcons *dataval=[NSEntityDescription insertNewObjectForEntityForName:@"T_Fuelcons" inManagedObjectContext:context];
                NSString *datestring = [NSString stringWithFormat:@"%@/%@/%@",[recordarray objectAtIndex:13],[recordarray objectAtIndex:14],[recordarray objectAtIndex:15]];
                 //NSLog(@"date string value %@",datestring);
                NSString *vehidvalue;
                for(Veh_Table *vehdata in vehicle)
                {
                    if([[recordarray objectAtIndex:1] isEqual:vehdata.vehid])
                    {
                        vehidvalue = [vehdata.iD stringValue];
                        break;
                    }
                }
                
                //Get all  comma separated services
                
                NSString* services = [recordarray objectAtIndex:20] ;
                
                if (recordarray.count > 21) {
                    
                    services = [services stringByAppendingString:@","];
                    
                    for (int j = 21; j < recordarray.count; j++) {
                        
                        NSString *trimmedString = [[recordarray objectAtIndex:j] stringByTrimmingCharactersInSet:
                                                   [NSCharacterSet whitespaceCharacterSet]];
                        
                        services = [services stringByAppendingString:[trimmedString stringByAppendingString:@","]];
                        
                    }
                    services = [services substringToIndex:[services length] - 1];
                    
                }
                
                NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
                dataval.iD = @([[recordarray objectAtIndex:0] intValue]);
               // [def setObject:dataval.iD forKey:@"maxFuelID"];
                
                dataval.odo =@([[recordarray objectAtIndex:2] floatValue]);
                dataval.vehid = vehidvalue;
                dataval.qty = @([[recordarray objectAtIndex:3] floatValue]);
                dataval.stringDate= [formater dateFromString:datestring];
                dataval.type = @([[recordarray objectAtIndex:19]integerValue]);
                dataval.serviceType = services;
                dataval.cost = @([[recordarray objectAtIndex:6] floatValue]);
                dataval.octane = @([[recordarray objectAtIndex:9] floatValue]);
                dataval.fuelBrand = [recordarray objectAtIndex:10];
                dataval.fillStation = [recordarray objectAtIndex:11];
                dataval.longitude = [NSNumber numberWithDouble:[[recordarray objectAtIndex:18] doubleValue]];
                dataval.latitude = [NSNumber numberWithDouble:[[recordarray objectAtIndex:17] doubleValue]];
                dataval.notes =[recordarray objectAtIndex:12];
                dataval.dist =@([[recordarray objectAtIndex:7]floatValue]);
                dataval.pfill = @([[recordarray objectAtIndex:4]integerValue]);
                dataval.mfill = @([[recordarray objectAtIndex:5]integerValue]);
                dataval.cons = @([[recordarray objectAtIndex:8]floatValue]);
                
                dataval.receipt = nil;

        }

    } @catch (NSException *exception) {
        if (exception.name == NSRangeException) {
            //NSLog(@"Caught an NSRangeException");
            
        } else {
           // NSLog(@"Ignored a %@ exception", exception);
            @throw;
        }
        
        if ([context hasChanges])
        {
           // NSLog(@"context rollbacked due to exception.name:-%@",exception.name);
            [context rollback];
            
        }
        Success = NO;
        
    } @finally {
        if ([context hasChanges])
        {
            BOOL saved = [context save:&err];
            if (!saved) {
                // do some real error handling
                //CLSLog(@“Could not save Data due to %@“, error);
            }
          //  NSLog(@"Context saved");
             [[CoreDataController sharedInstance] saveMasterContext];
            
        }
      
        commonMethods *commMethod = [[commonMethods alloc] init];
        NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
        for(Veh_Table *veh in vehicle){
            [def setObject:veh.iD forKey:@"fillupid"];
            [commMethod updateDistance:0];
            [commMethod updateConsumption:0];
        }
        Success = YES;
    }

}

-(void)readTripData:(NSString*)path
{
    
    NSString* content = [NSString stringWithContentsOfFile:path
                                                  encoding:NSUTF8StringEncoding
                                                     error:NULL];
    // NSLog(@"filedata %@",content);
    NSArray *datavalue = [[NSArray alloc]init];
    //NSLog(@"string value %@",content);
    datavalue = [content componentsSeparatedByString:@"\n"];
    
    NSManagedObjectContext *contex = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSError *err;
    NSFetchRequest *requset=[[NSFetchRequest alloc] initWithEntityName:@"T_Trip"];
    // NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type==1 OR type==2"];
    // [requset setPredicate:predicate];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"iD"
                                                                   ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [requset setSortDescriptors:sortDescriptors];
    
    
    NSArray *trip=[contex executeFetchRequest:requset error:&err];
    for (NSManagedObject *product in trip) {
        [contex deleteObject:product];
        
    }
    
    NSFetchRequest *requset1=[[NSFetchRequest alloc] initWithEntityName:@"Veh_Table"];
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"iD"
                                                                    ascending:YES];
    NSError *err1;
    NSArray *sortDescriptors1 = [[NSArray alloc] initWithObjects:sortDescriptor1, nil];
    [requset1 setSortDescriptors:sortDescriptors1];
    
    NSArray *vehicle=[contex executeFetchRequest:requset1 error:&err1];
    
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *arrDateComponents = [[NSDateComponents alloc] init];
    NSDateComponents *depDateComponents = [[NSDateComponents alloc] init];

    @try
    {
       // NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
       // int maxFuelID = [[def objectForKey:@"maxFuelID"] intValue];
        for(int i=1;i<datavalue.count;i++)
        {
            NSString *recordvalue = [datavalue objectAtIndex:i];
            //            NSArray *recordarray = [[NSArray alloc]init];
            //            recordarray = [recordvalue componentsSeparatedByString:@","];
            
            NSArray *mainArray = [[NSArray alloc]init];
            mainArray = [recordvalue componentsSeparatedByString:@","];
            
            NSMutableArray *recordarray = [[NSMutableArray alloc] initWithArray:mainArray];
            
            if(recordarray.count==21){
                
                [recordarray insertObject:@"0" atIndex:20];
                [recordarray insertObject:@"0" atIndex:21];
                [recordarray insertObject:@"0" atIndex:22];
                [recordarray insertObject:@"0" atIndex:23];
            }
            
            // NSLog(@"values of record array %@ at index %d",recordarray,i);
            T_Trip *dataval=[NSEntityDescription insertNewObjectForEntityForName:@"T_Trip" inManagedObjectContext:contex];
            NSString *vehidvalue;
            
            for(Veh_Table *vehdata in vehicle)
            {
                //                NSLog(@"value of record 1 %@",[recordarray objectAtIndex:1]);
                //                NSLog(@"value of vehdata %@",vehdata.vehid);
                if([[recordarray objectAtIndex:1] isEqual:vehdata.vehid])
                {
                    vehidvalue = [vehdata.iD stringValue];
                    break;
                }
            }
         //   NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
            dataval.iD = @([[recordarray objectAtIndex:0] intValue]);
         //   int compareTemp = [dataval.iD intValue];
         //   if(compareTemp > maxFuelID){
         //       maxFuelID = compareTemp;
         //   }
            
         //   [def setInteger:maxFuelID forKey:@"maxFuelID"];
            //NSLog(@"maxFuelID = %@",[def objectForKey:@"maxFuelID"]);
            dataval.vehId = vehidvalue;
            dataval.arrLocn = [recordarray objectAtIndex:5];
            dataval.arrOdo = [NSNumber numberWithFloat: [[recordarray objectAtIndex:3] floatValue]];
            dataval.depLocn=[recordarray objectAtIndex:4] ;
            dataval.depOdo =[NSNumber numberWithFloat: [[recordarray objectAtIndex:2] floatValue]];
            //   NSNumber *iD    =[NSNumber numberWithInteger: [[recordarray objectAtIndex:] integerValue]];
            dataval.notes =[recordarray objectAtIndex:19] ;
            dataval.parkingAmt=[NSNumber numberWithFloat: [[recordarray objectAtIndex:16] floatValue]];
            dataval.taxDedn=[NSNumber numberWithFloat: [[recordarray objectAtIndex:18] floatValue]];
            dataval.tollAmt=[NSNumber numberWithFloat: [[recordarray objectAtIndex:17] floatValue]];
            dataval.tripType = [recordarray objectAtIndex:24];
            dataval.depLatitude = [NSNumber numberWithDouble:[[recordarray objectAtIndex:20] doubleValue]];
            dataval.depLongitude = [NSNumber numberWithDouble:[[recordarray objectAtIndex:21] doubleValue]];
            dataval.arrLatitude = [NSNumber numberWithDouble:[[recordarray objectAtIndex:22] doubleValue]];
            dataval.arrLongitude = [NSNumber numberWithDouble:[[recordarray objectAtIndex:23] doubleValue]];
            arrDateComponents.day = [[recordarray objectAtIndex:11] integerValue];
            arrDateComponents.month = [[recordarray objectAtIndex:12] integerValue];
            arrDateComponents.year = [[recordarray objectAtIndex:13] integerValue];
            arrDateComponents.hour = [[recordarray objectAtIndex:14] integerValue];
            arrDateComponents.minute= [[recordarray objectAtIndex:15] integerValue];
            dataval.arrDate = [gregorianCalendar dateFromComponents:arrDateComponents];
            depDateComponents.day = [[recordarray objectAtIndex:6] integerValue];
            depDateComponents.month = [[recordarray objectAtIndex:7] integerValue];
            depDateComponents.year = [[recordarray objectAtIndex:8] integerValue];
            depDateComponents.hour = [[recordarray objectAtIndex:9] integerValue];
            depDateComponents.minute= [[recordarray objectAtIndex:10] integerValue];
            //NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            dataval.depDate = [gregorianCalendar dateFromComponents:depDateComponents];
            
            if (dataval.depOdo > 0 && dataval.arrOdo > 0 ) {
                dataval.tripComplete = YES;
            }
            
        }
        
    } @catch (NSException *exception) {
        if (exception.name == NSRangeException) {
            NSLog(@"Caught an NSRangeException");
            
        } else {
            NSLog(@"Ignored a %@ exception", exception);
            @throw;
        }
        
        if ([contex hasChanges])
        {
            NSLog(@"Context rollback");
            [contex rollback];
            
        }
        
        Success = NO;
        
        
    } @finally {
        NSLog(@"Executing finally block");
        if ([contex hasChanges])
        {
            BOOL saved = [contex save:&err];
            if (!saved) {
                // do some real error handling
                //CLSLog(@“Could not save Data due to %@“, error);
            }
            NSLog(@"Context saved");
            [[CoreDataController sharedInstance] saveMasterContext];
        }
        Success = YES;
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
                               handler:^(UIAlertAction *action)
                               {
                                   
                                   
                               }];
    
    
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
    
}

- (BOOL)checkForNetwork{
    
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    
    if(networkStatus == NotReachable){
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [self showAlertAndDismiss:@"Failed to Search" message:@"Please check your internet connection and try again later"];
        });
        return NO;
    } else {
        
        return YES;
        
    }
}

- (void)showAlertAndDismiss: (NSString *)title message:(NSString *)message{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"OK") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }];
    
    //    UIAlertAction *canel = [UIAlertAction actionWithTitle:NSLocalizedString(@"no", @"No") style:UIAlertActionStyleDefault handler:nil];
    
    [alert addAction:ok];
    //[alert addAction:canel];
    [self presentViewController:alert animated:YES completion:nil];
    
}




@end
