 //
//  ResyncVC.m
//  FuelBuddy
//
//  Created by Swapnil on 12/11/17.
//  Copyright © 2017 Oraganization. All rights reserved.
//

#import "ResyncVC.h"
#import "commonMethods.h"
#import "WebServiceURL's.h"
#import "SettingsViewController.h"
#import "Loc_Table.h"
#import "Veh_Table.h"
#import "T_Fuelcons.h"
#import "T_Trip.h"
#import "Services_Table.h"
#import "SlideOutVC.h"
#import "Sync_Table.h"
#import "LoggedInVC.h"

@interface ResyncVC ()

@end

@implementation ResyncVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setObject:@"no" forKey:@"slideOutOn"];
    [self.mainView.layer setCornerRadius:7.0f];
    //self.view.backgroundColor = [self colorFromHexString:@"#2c2c2c"];
    // border
    [self.mainView.layer setBorderColor:[UIColor darkGrayColor].CGColor];
    [self.mainView.layer setBorderWidth:0.5f];
    
    //self.mainView.backgroundColor = [self colorFromHexString:@"#2c2c2c"];
    
    // @"resyncPopup" values (coming from LoggedInVC) are -
    //detectedDataFirstTime : First time user signs in and data for that email already exists on cloud
    //detectedData : When a full upload is done from other device and its not downloaded on the phone(means it is on cloud)
    //userClicked : User clicks the Resync option himself

    NSDictionary *dateNString = [def objectForKey:@"resyncPopup1"];
    NSString *whichData = [dateNString objectForKey:@"data"];
    NSDate *dateFromServer1 = [dateNString objectForKey:@"dateFromServer1"];

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd-MMM-yyyy"];
    NSString *dateString = [formatter stringFromDate:dateFromServer1];

    //Made changes of new log date here
    if([whichData isEqualToString:@"OlderData"]){

        NSString *descLabelString = [NSString stringWithFormat:@"%@ %@",(NSLocalizedString(@"sync_file_found_old_max_date", @"Data on the cloud exists up till ")),dateString];
        self.resyncLabel.text = NSLocalizedString(@"sync_file_found_old_max_date_title", @"Older data exists on cloud");

        self.descLabel.text = descLabelString;

        self.labelYes.text = NSLocalizedString(@"sync_file_found_old_max_date_yes", @"Overwrite my phone with this older data");

        self.labelNo.text = NSLocalizedString(@"sync_file_found_old_max_date_no", @"Overwrite the cloud with my phone's newer data");

        self.descLabel2.text = NSLocalizedString(@"sync_file_found_old_max_date_footnote", @"(If you are not sure of what option to choose hit the Deregister option, for now, and contact support at support-ios@simplyauto.app)");

        [self.buttonCancel setTitle:NSLocalizedString(@"sync_deregister_title", @"Deregister") forState:UIControlStateNormal];

        self.buttonCancel.titleLabel.textColor = [UIColor yellowColor];

    }else if([whichData isEqualToString:@"NoDataExists"]){

        self.resyncLabel.text = NSLocalizedString(@"sync_file_found_old_max_date_blank_title", @"No data exists on cloud");

        self.descLabel.text = NSLocalizedString(@"sync_file_found_old_max_date_blank", @"We've found no data on the cloud.");

        self.labelYes.text = NSLocalizedString(@"sync_file_found_old_max_date_blank_no", @"Upload my phone's data on the cloud");

        self.checkYes.selected = YES;
        [self.checkYes setImage:[UIImage imageNamed:@"check"] forState:UIControlStateSelected];

        self.labelNo.hidden = YES;
        self.checkNo.hidden = YES;

        self.descLabel2.text = NSLocalizedString(@"sync_file_found_old_max_date_blank_footnote", @"(Get in touch with support-ios@simplyauto.app in case of any questions)");

        [self.buttonCancel setTitle:NSLocalizedString(@"sync_deregister_title", @"Deregister") forState:UIControlStateNormal];

        self.buttonCancel.titleLabel.textColor = [UIColor yellowColor];

    } else if([whichData isEqualToString:@"NewerData"]){

        NSString *descLabelString = [NSString stringWithFormat:@"%@ %@",(NSLocalizedString(@"sync_file_found_new_max_date", @"Newer data exists on cloud up till ")),dateString];

        self.resyncLabel.text = NSLocalizedString(@"sync_new_data_on_server_title", @"Newer data exists on the cloud");

        self.descLabel.text = descLabelString;

        self.labelYes.text = NSLocalizedString(@"sync_new_data_on_server_yes", @"Overwrite my phone with this newer data");

        self.labelNo.text = NSLocalizedString(@"sync_new_data_on_server_no", @"Overwrite the cloud with my phone's older data");

        self.descLabel2.text = NSLocalizedString(@"sync_new_data_on_server_footnote", @"(If you are not sure of what option to choose hit the Deregister option, for now, and contact support at support-ios@simplyauto.app)");

        [self.buttonCancel setTitle:NSLocalizedString(@"sync_deregister_title", @"Deregister") forState:UIControlStateNormal];

        self.buttonCancel.titleLabel.textColor = [UIColor yellowColor];

    }else if([whichData isEqualToString:@"detectedData"]){
        
        self.resyncLabel.text = NSLocalizedString(@"sync_data_exists_on_cloud", @"Data exists on Cloud");
        
        self.descLabel.text = NSLocalizedString(@"sync_new_data_on_server", @"Newer data has been detected on the cloud. Would you like to overwrite data on this phone with the data available on the cloud?");
        
        [self.buttonCancel setTitle:NSLocalizedString(@"sync_deregister_title", @"Deregister") forState:UIControlStateNormal];

        self.buttonCancel.titleLabel.textColor = [UIColor yellowColor];
        
    } else if ([[def objectForKey:@"resyncPopup"] isEqualToString:@"detectedDataFirstTime"]){
        
        self.resyncLabel.text = NSLocalizedString(@"sync_data_exists_on_cloud", @"Data exists on Cloud");
        self.descLabel.text = NSLocalizedString(@"descLabelFirstTime", @"Description");
        self.descLabel2.text = NSLocalizedString(@"descLabel2", @"Description2");
        
        [self.buttonCancel setTitle:NSLocalizedString(@"sync_deregister_title", @"Deregister") forState:UIControlStateNormal];
        
    } else {
    
        self.resyncLabel.text = NSLocalizedString(@"resync", @"Resync");
        self.descLabel.text = NSLocalizedString(@"descLabel1", @"Description");
        self.descLabel2.text = NSLocalizedString(@"descLabel2", @"Description2");
    
        [self.buttonCancel setTitle:NSLocalizedString(@"cancel", @"cancel") forState:UIControlStateNormal];
        //self.buttonCancel.titleLabel.text = NSLocalizedString(@"cancel", @"cancel");
    }

    self.labelYes.text = NSLocalizedString(@"sync_overwrite_phone", @"Overwrite data on this phone");
    self.labelNo.text = NSLocalizedString(@"sync_overwrite_cloud", @"Overwrite data on cloud");
    
    [self.checkYes.layer setCornerRadius:8.0f];
    [self.checkNo.layer setCornerRadius:8.0f];
    
    [self.checkYes.layer setBorderWidth:1.0f];
    [self.checkNo.layer setBorderWidth:1.0f];
    
    [self.checkYes.layer setBorderColor:[UIColor blackColor].CGColor];
    [self.checkNo.layer setBorderColor:[UIColor blackColor].CGColor];
    //[self.checkYes setBackgroundColor:[UIColor whiteColor]];
    
    self.checkYes.selected = YES;
    [self.checkYes setImage:[UIImage imageNamed:@"check"] forState:UIControlStateSelected];
    
    self.checkNo.selected = NO;
    [self.checkNo setImage:[UIImage imageNamed:@"uncheck"] forState:UIControlStateNormal];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)checkYesPressed:(id)sender {
    
    [sender setSelected:YES];
    [self.checkNo setSelected:NO];
    [self.checkYes setImage:[UIImage imageNamed:@"check"] forState:UIControlStateSelected];
    [self.checkNo setImage:[UIImage imageNamed:@"uncheck"] forState:UIControlStateNormal];
    
}

- (IBAction)checkNoPressed:(id)sender {
    
    [sender setSelected:YES];
    [self.checkYes setSelected:NO];
    [self.checkNo setImage:[UIImage imageNamed:@"check"] forState:UIControlStateSelected];
    [self.checkYes setImage:[UIImage imageNamed:@"uncheck"] forState:UIControlStateNormal];
}

- (IBAction)buttonOkPressed:(id)sender {
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];

    [def setObject:@"userClicked" forKey:@"resyncPopup"];
    
    if(self.checkYes.isSelected){
    //NIKHIL BUG_147
    [commonMethods startActivitySpinner:@"Starting Download"];

        [self dismissViewController:nil message:@""];
        
    } else if (self.checkNo.isSelected){

        [self dismissViewControllerForUpload:nil message:@""];
    }
}

- (void)saveToDB{
    
    //[self perf]
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"vehicleFinish" object:nil];
    AppDelegate *app = [[AppDelegate alloc] init];
    [app saveCloudDataInBg:1];
}

- (IBAction)buttonCancelPressed:(id)sender {
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    if([[def objectForKey:@"resyncPopup"] isEqualToString:@"detectedData"] || [[def objectForKey:@"resyncPopup"] isEqualToString:@"detectedDataFirstTime"]){
        
        [self dismissViewControllerForDeregister:nil message:@""];
        
    } else {
    
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}


- (void)dismissViewControllerForDeregister:(id)sender message:(NSString*) message{
    
    [self dismissViewControllerAnimated:YES completion:^{
        
//        SlideOutVC *slideVC = [[SlideOutVC alloc] init];
//        [slideVC deregisterPopup];
        self.onDeregisterDismiss(self, message);
    }];
}


- (void)startSpinner: (NSString *)name{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:name object:nil];
}


- (void)dismissViewController:(id)sender message:(NSString*) message
{
    [self dismissViewControllerAnimated:YES completion:^
     {
         //NIKHIL BUG_147
      //   [[NSNotificationCenter defaultCenter] postNotificationName:@"downloadStarted"
      //                                                       object:nil];
         // MAKE THIS CALL
         self.onDismiss(self, message);
         
         NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
         NSError *error;
         //[def setObject:@"userClicked" forKey:@"resyncPopup"];
         //[self performSelectorOnMainThread:@selector(startSpinner:) withObject:@"downloadStarted" waitUntilDone:NO];
         //[[NSNotificationCenter defaultCenter] postNotificationName:@"downloadStarted" object:nil];
         NSMutableDictionary *parametersDictionary = [[NSMutableDictionary alloc] init];
         //NSMutableArray *postDataArr = [[NSMutableArray alloc] init];
         
         [parametersDictionary setObject:[def objectForKey:@"UserDeviceId"] forKey:@"androidId"];
         [parametersDictionary setObject:@"full_pull_loud" forKey:@"full_pull_type"];
         [parametersDictionary setObject:@"phone" forKey:@"sent_from"];
         
         //[postDataArr addObject:parametersDictionary];
         [def setBool:YES forKey:@"updateTimeStamp"];
         NSData *postData = [NSJSONSerialization dataWithJSONObject:parametersDictionary options:NSJSONWritingPrettyPrinted error:&error];
         commonMethods *common = [[commonMethods alloc] init];
         [common saveToCloud:postData urlString:kFullDownloadScript success:^(NSDictionary *responseDict) {
             
             //NSLog(@"full download response : %@", responseDict);
             if([[responseDict objectForKey:@"message"] isEqualToString:@"Success"]){
                 
                // NSLog(@"full download called successfully");
                 
                 if([[responseDict objectForKey:@"type"] isEqualToString:@"full_pull_loud"]){
                     
                     //[self performSelectorOnMainThread:@selector(startSpinner:) withObject:@"downloadFinish" waitUntilDone:NO];
                     //[[NSNotificationCenter defaultCenter] postNotificationName:@"downloadFinish" object:nil];
                     //DBDeletionFlag = 1;
                     [[NSUserDefaults standardUserDefaults] setObject:@"full_pull_loud" forKey:@"responseType"];
                     
                     //NIKHIL BUG_138
                     //Added following code as the task was not assigned to background
                     UIApplication *app = [UIApplication sharedApplication];
                     __block UIBackgroundTaskIdentifier bgTask;
                     
                     bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
                         
                         [app endBackgroundTask:bgTask];
                         bgTask = UIBackgroundTaskInvalid;
                         [[CoreDataController sharedInstance] saveMasterContext];

                      }];
                     
                     
                     dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                          
                         //[self saveToDB];
                         [self performSelectorInBackground:@selector(saveToDB) withObject:nil];
                       });
                    }
                } else {
               //  NSLog(@"full download failed");
             }
             
         } failure:^(NSError *error) {
             
             NSLog(@"full download failed due to error:-%@",error);
             [[NSNotificationCenter defaultCenter] postNotificationName:@"failError" object:nil userInfo:@{@"message":@"Failed to download data"}];
         }];
     }];
   
   
    //[self dismissViewControllerAnimated:NO completion:nil];
}

- (void)dismissViewControllerForUpload:(id)sender message:(NSString*) message
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"upload" object:nil];
    [self dismissViewControllerAnimated:YES completion:^
     {
         
         // MAKE THIS CALL
         self.onDismiss(self, message);
         [self fullUpload];
     }];
    
    [self dismissViewControllerAnimated:NO completion:nil];
}


#pragma mark FULL UPLOAD

- (void)fullUpload{
    //NIKHIL BUG_144
    NSUserDefaults *isSuccess = [NSUserDefaults standardUserDefaults];
    BOOL success;
    [self clearPhoneSyncTable];
    
    [self uploadSettings];
    success = [isSuccess boolForKey:@"uploadStatus"];
    if (!success){
        //NIKHIL BUG_149
        [[NSNotificationCenter defaultCenter] postNotificationName:@"failError" object:nil userInfo:@{@"message":@"Failed to upload Settings"}];
        return;
    }
    
    [self uploadVehicles];
    success = [isSuccess boolForKey:@"uploadStatus"];
    if(!success){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"failError" object:nil userInfo:@{@"message":@"Failed to upload Vehicles"}];
        return;
    }
    
    [self uploadServices];
    success = [isSuccess boolForKey:@"uploadStatus"];
    if(!success){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"failError" object:nil userInfo:@{@"message":@"Failed to upload Services"}];
        return;
    }
    
    [self uploadLog];
    success = [isSuccess boolForKey:@"uploadStatus"];
    if(!success){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"failError" object:nil userInfo:@{@"message":@"Failed to upload Log"}];
    }
}

- (void)clearPhoneSyncTable{
    
    //clear phone's sync table first if it contains any records.
    //BUG_156
    NSManagedObjectContext *context = [[CoreDataController sharedInstance] newManagedObjectContext];
    
    NSError *syncTblError;
    NSFetchRequest *syncTblReq = [[NSFetchRequest alloc] initWithEntityName:@"Sync_Table"];
    NSArray *syncTblArray = [context  executeFetchRequest:syncTblReq error:&syncTblError];
    NSError *err;
    for (Sync_Table *syncData in syncTblArray) {
        
        [context  deleteObject:syncData];
    }

    if([context  hasChanges]){
        
        BOOL saved = [context  save:&err];
        if (!saved) {
            // do some real error handling
            //CLSLog(@“Could not save Data due to %@“, error);
        }
        [[CoreDataController sharedInstance] saveMasterContext];
    }
}


- (void)uploadSettings{
    
    //NIKHIL BUG_144
    NSUserDefaults *isSuccess = [NSUserDefaults standardUserDefaults];
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *androidID = [[NSMutableDictionary alloc] init];
    
    if([def objectForKey:@"UserDeviceId"] != nil){
        
        [androidID setObject:[def objectForKey:@"UserDeviceId"] forKey:@"androidId"];
        
    } else {
        
        [androidID setObject:@"" forKey:@"androidId"];
    }
    
    
    NSMutableDictionary *tableName = [[NSMutableDictionary alloc] init];
    [tableName setObject:@"SETTINGS" forKey:@"tableName"];
    
    SettingsViewController *settingsVC = [[SettingsViewController alloc] init];
    
    NSString *dist = [settingsVC convertLocalizedStringToConstant:[def objectForKey:@"dist_unit"]];
    NSString *vol = [settingsVC convertLocalizedStringToConstant:[def objectForKey:@"vol_unit"]];
    NSString *consumption = [settingsVC convertLocalizedStringToConstant:[def objectForKey:@"con_unit"]];
    
    NSString *currValue = [[NSUserDefaults standardUserDefaults] objectForKey:@"curr_unit"];
    NSArray *currency = [currValue componentsSeparatedByString:@" - "];
    NSString *currShort = [currency lastObject];
    
    NSMutableArray *countArray = [[NSMutableArray alloc] init];
    NSMutableDictionary *parametersDictionary = [[NSMutableDictionary alloc] init];
    if(dist.length>0){
        [parametersDictionary setObject:dist forKey:@"dist"];
    }else{
        [countArray addObject: @"dist"];
    }
    if(vol.length>0){
        
        [parametersDictionary setObject:vol forKey:@"vol"];
    }else{
        [countArray addObject: @"vol"];
    }
    if(consumption.length>0){
        
        [parametersDictionary setObject:consumption forKey:@"cons"];
    }else{
        [countArray addObject: @"cons"];
    }
    if(currShort.length>0){
        
        [parametersDictionary setObject:currShort forKey:@"curr"];
    }else{
        [countArray addObject: @"curr"];
    }
    
    if(parametersDictionary.count==4){
        
        NSMutableArray *settingsParamaters = [[NSMutableArray alloc] init];
        [settingsParamaters addObject:androidID];
        [settingsParamaters addObject:tableName];
        [settingsParamaters addObject:parametersDictionary];
        
        //NSLog(@"settingsParams : %@", settingsParamaters);
        
        NSError *err;
        NSData *postDataArray = [NSJSONSerialization dataWithJSONObject:settingsParamaters options:NSJSONWritingPrettyPrinted error:&err];
        [def setBool:NO forKey:@"updateTimeStamp"];
        commonMethods *common = [[commonMethods alloc] init];
        [common saveToCloud:postDataArray urlString:kFullUploadScript success:^(NSDictionary *responseDict) {
            
            //NSLog(@"settings Response : %@", responseDict);
            
            //[self showAlert:@"Settings uploaded successfully" message:@""];
            
            //Wait for Settings Response, then upload Location table
            if([[responseDict objectForKey:@"message"] isEqualToString:@"Success"]){
                //NIKHIL BUG_144
                [self uploadLocation];
                [isSuccess setBool:YES forKey:@"uploadStatus"];
                
            } else {
                //NIKHIL BUG_149
                // [[NSNotificationCenter defaultCenter] postNotificationName:@"failError" object:nil];
                //[self showAlert:@"Failed to upload Settings" msg:@"Try again later"];
                [isSuccess setBool:NO forKey:@"uploadStatus"];
            }
            
            
        } failure:^(NSError *error) {
            
            // [[NSNotificationCenter defaultCenter] postNotificationName:@"failError" object:nil];
            //[self showAlert:@"Failed to upload Settings" msg:@"Try again later"];
            //  NSLog(@"failed to get response");
            [isSuccess setBool:NO forKey:@"uploadStatus"];
        }];
    }else{
     
        NSLog(@"%@ are missing",countArray);
        [isSuccess setBool:NO forKey:@"uploadStatus"];
    }
    
    
}


- (void)uploadLocation{

    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSMutableArray *locationParams = [[NSMutableArray alloc] init];
    NSMutableDictionary *androidID = [[NSMutableDictionary alloc] init];
    
    //BUG_156
    NSManagedObjectContext *context  = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSError *locError;
    NSFetchRequest *locRequest = [[NSFetchRequest alloc] initWithEntityName:@"Loc_Table"];
    NSArray *locationData = [context  executeFetchRequest:locRequest error:&locError];
    //NIKHIL BUG_153
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"!(lat == %@) AND !(lat==%@)",@0,nil];
    NSArray *filteredLoc = [locationData filteredArrayUsingPredicate:predicate];
    
    //NSLog(@"####locationData : %@", locationData);
    //NSLog(@"####filteredArray : %@", filteredLoc);
    
 //   NSLog(@"filteredLoc.count::%lu",(unsigned long)filteredLoc.count);
    if(filteredLoc.count != 0){
    
       if([def objectForKey:@"UserDeviceId"] != nil){
        
            [androidID setObject:[def objectForKey:@"UserDeviceId"] forKey:@"androidId"];
        
        } else {
        
            [androidID setObject:@"" forKey:@"androidId"];
        }
     
        //NIKHIL BUG_151
        commonMethods *common = [[commonMethods alloc]init];
        NSNumberFormatter *lformatter = [common decimalFormatter];
    
       NSMutableDictionary *tableName = [[NSMutableDictionary alloc] init];
       [tableName setObject:@"LOC_TABLE" forKey:@"tableName"];
    
       [locationParams addObject:androidID];
       [locationParams addObject:tableName];
    
        for (Loc_Table *location in filteredLoc) {
        
         NSMutableDictionary *parametersDictionary = [[NSMutableDictionary alloc] init];
        
         if(location.iD != nil){
             [parametersDictionary setObject:location.iD forKey:@"id"];
          } else {
             [parametersDictionary setObject:@"" forKey:@"id"];
          }
        
         if([location.lat floatValue] != 0.0){
             //NIKHIL BUG_151
             NSString *latString = [lformatter stringFromNumber: location.lat];
             NSString *longiString = [lformatter stringFromNumber: location.longitude];
             location.lat = [NSNumber numberWithDouble:[latString doubleValue]];
             location.longitude = [NSNumber numberWithDouble:[longiString doubleValue]];
             
             [parametersDictionary setObject:location.lat forKey:@"lat"];
       //      NSLog(@"#### LatValue while uploading to Cloud:::%@",location.lat);
         } else {
             [parametersDictionary setObject:@"" forKey:@"lat"];
            
         }
        
         if([location.longitude floatValue] != 0.0){
             [parametersDictionary setObject:location.longitude forKey:@"long"];
         } else {
             [parametersDictionary setObject:@"" forKey:@"long"];
         }
        
         if(location.address != nil){
             [parametersDictionary setObject:location.address forKey:@"address"];
         } else {
             [parametersDictionary setObject:@"" forKey:@"address"];
         }
        
         if(location.brand != nil){
             [parametersDictionary setObject:location.brand forKey:@"brand"];
         } else {
             [parametersDictionary setObject:@"" forKey:@"brand"];
         }
        
         [locationParams addObject:parametersDictionary];
      }
    
  //    NSLog(@"location params : %@",locationParams);
    
      NSError *err;
      NSData *postDataArray = [NSJSONSerialization dataWithJSONObject:locationParams options:NSJSONWritingPrettyPrinted error:&err];
    
     //if(locationParams.count > 2){
//       NSString *latValue = [locationParams objectAtIndex:2];
//       NSLog(@"lat value : %@", latValue);
//       NSString *emptyData = @"";
//       if([latValue valueForKey:@"lat"] != emptyData){
        [def setBool:NO forKey:@"updateTimeStamp"];
         [common saveToCloud:postDataArray urlString:kFullUploadScript success:^(NSDictionary *responseDict) {
        
   //        NSLog(@"location Response : %@", responseDict);
        
          } failure:^(NSError *error) {
        
   //          NSLog(@"failed to get response");
            }];
       //}
     //}
    }
}

- (void)uploadVehicles{
    
    
    //NIKHIL BUG_144
    NSUserDefaults *isSuccess = [NSUserDefaults standardUserDefaults];
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    
    NSMutableArray *vehicleParams = [[NSMutableArray alloc] init];
    NSMutableDictionary *androidID = [[NSMutableDictionary alloc] init];
    
    if([def objectForKey:@"UserDeviceId"] != nil){
        
        [androidID setObject:[def objectForKey:@"UserDeviceId"] forKey:@"androidId"];
        
    } else {
        
        [androidID setObject:@"" forKey:@"androidId"];
    }
    
    
    NSMutableDictionary *tableName = [[NSMutableDictionary alloc] init];
    [tableName setObject:@"VEH_TABLE" forKey:@"tableName"];
    
    [vehicleParams addObject:androidID];
    [vehicleParams addObject:tableName];
    
    //BUG_156
    NSManagedObjectContext *context  = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSError *vehError;
    
    NSFetchRequest *vehReq = [[NSFetchRequest alloc] initWithEntityName:@"Veh_Table"];
    NSArray *vehData = [context  executeFetchRequest:vehReq error:&vehError];
    
    for (Veh_Table *vehicles in vehData) {
        
        NSMutableDictionary *parametersDictionary = [[NSMutableDictionary alloc] init];
        
        if(vehicles.iD != nil){
            [parametersDictionary setObject:vehicles.iD forKey:@"id"];
        } else {
            [parametersDictionary setObject:@"" forKey:@"id"];
        }
        
        [parametersDictionary setObject:vehicles.make forKey:@"make"];
        [parametersDictionary setObject:vehicles.model forKey:@"model"];
        
        if(vehicles.vehid != nil){
            [parametersDictionary setObject:vehicles.vehid forKey:@"vehid"];
        } else {
            [parametersDictionary setObject:@"" forKey:@"vehid"];
        }
        
        if(vehicles.year != nil){
            [parametersDictionary setObject:vehicles.year forKey:@"year"];
        } else {
            [parametersDictionary setObject:@"" forKey:@"year"];
        }
        
        if(vehicles.lic != nil){
            [parametersDictionary setObject:vehicles.lic forKey:@"lic"];
        } else {
            [parametersDictionary setObject:@"" forKey:@"lic"];
        }
        
        if(vehicles.vin != nil){
            [parametersDictionary setObject:vehicles.vin forKey:@"vin"];
        } else {
            [parametersDictionary setObject:@"" forKey:@"vin"];
        }
        
        if(vehicles.insuranceNo != nil){
            [parametersDictionary setObject:vehicles.insuranceNo forKey:@"insuranceNo"];
        } else {
            [parametersDictionary setObject:@"" forKey:@"insuranceNo"];
        }
        
        if(vehicles.notes != nil){
            [parametersDictionary setObject:vehicles.notes forKey:@"notes"];
        } else {
            [parametersDictionary setObject:@"" forKey:@"notes"];
        }
        
        if(vehicles.fuel_type != nil){
            [parametersDictionary setObject:vehicles.fuel_type forKey:@"fuelType"];
        } else {
            [parametersDictionary setObject:@"" forKey:@"fuelType"];
        }
        
        if(vehicles.customSpecs != nil){
            
            [parametersDictionary setObject:vehicles.customSpecs forKey:@"customSpecifications"];
        } else {
            
            [parametersDictionary setObject:@"" forKey:@"customSpecifications"];
        }
        BOOL proUser = [[NSUserDefaults standardUserDefaults] boolForKey:@"isAdDisabled"];
        if(vehicles.picture != nil && vehicles.picture.length > 0 && proUser){
            
            [parametersDictionary setObject:vehicles.picture forKey:@"picture"];
        } else {
            
            [parametersDictionary setObject:@"" forKey:@"picture"];
        }
        
        [vehicleParams addObject:parametersDictionary];
    }
    
    //NSLog(@"vehicle Params : %@", vehicleParams);
    
    NSError *err;
    NSData *postDataArray = [NSJSONSerialization dataWithJSONObject:vehicleParams options:NSJSONWritingPrettyPrinted error:&err];
    [def setBool:NO forKey:@"updateTimeStamp"];
    commonMethods *common = [[commonMethods alloc] init];
    [common saveToCloud:postDataArray urlString:kFullUploadScript success:^(NSDictionary *responseDict) {
        
      //NSLog(@"vehicle Response : %@", responseDict);
        //Wait for Vehicles Response, then upload vehicle images
        if([[responseDict objectForKey:@"message"] isEqualToString:@"Success"]){
            
            //[self performSelectorInBackground:@selector(uploadVehicleImages) withObject:nil];
            //NIKHIL BUG_144
            //making sync free 1june2018 nikhil // not allowing vehicle images if not pro
            BOOL proUser = [[NSUserDefaults standardUserDefaults] boolForKey:@"isAdDisabled"];
            
            if(proUser){
                [self uploadVehicleImages];
            }
            
            [isSuccess setBool:YES forKey:@"uploadStatus"];
           
        } else {
            //NIKHIL BUG_149
          //  [[NSNotificationCenter defaultCenter] postNotificationName:@"failError" object:nil];
            //[self showAlert:@"Failed to upload Vehicles" msg:@"Try again later"];
            [isSuccess setBool:NO forKey:@"uploadStatus"];
        }
        
        
    } failure:^(NSError *error) {
        
        //[[NSNotificationCenter defaultCenter] postNotificationName:@"failError" object:nil];
        //[self showAlert:@"Failed to upload Vehicles" msg:@"Try again later"];
   //     NSLog(@"failed to get response");
        [isSuccess setBool:NO forKey:@"uploadStatus"];
    }];

}


- (void)uploadVehicleImages{
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    //BUG_156
    NSManagedObjectContext *context  = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSError *vehError;
    
    NSFetchRequest *vehReq = [[NSFetchRequest alloc] initWithEntityName:@"Veh_Table"];
    NSArray *vehData = [context  executeFetchRequest:vehReq error:&vehError];
    
    for (Veh_Table *vehicles in vehData) {
        
        NSMutableDictionary *paramDictionary = [[NSMutableDictionary alloc] init];
        
        [paramDictionary setObject:[def objectForKey:@"UserEmail"] forKey:@"email"];
        
        if(vehicles.picture != nil && vehicles.picture.length > 0){
            
            NSString *imageName = vehicles.picture;
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            
            NSString *docPath = [paths firstObject];
            NSString *completeImgPath = [docPath stringByAppendingString:[NSString stringWithFormat:@"/%@", imageName]];
            
            UIImage *vehImage = [UIImage imageWithContentsOfFile:completeImgPath];
            
            NSData *imageData = UIImagePNGRepresentation(vehImage);
            
            float imgSizeInMB = [imageData length] / 1024.0f / 1024.0f;
            
            NSString *imageString;
            
            //If images are > than 1.5 MB, compress them and then send to server
            if(imgSizeInMB > 1.5){
                
                UIImage *smallImg = [[commonMethods class] imageWithImage:vehImage scaledToSize:CGSizeMake(300.0, 300.0)];
                NSData *compressedImg = UIImagePNGRepresentation(smallImg);
                imageString = [compressedImg base64EncodedStringWithOptions:0];
                //NSLog(@"compressed img of size : %ld", [compressedImg length]);
               // NSLog(@"imageString:::%@",imageString);
                
            } else {
                
               //NSLog(@"full img of size : %ld", [imageData length]);
                
                imageString = [imageData base64EncodedStringWithOptions:0];
                //NSLog(@"imageString:::%@",imageString);
            }
            
            //NSLog(@"imageString:::%@",imageString);
            [paramDictionary setObject:imageName forKey:@"img_name"];
            [paramDictionary setObject:@"image" forKey:@"img_type"];
            if(imageString){
                [paramDictionary setObject:imageString forKey:@"img_file"];
            }else{
                [paramDictionary setObject:@"" forKey:@"img_file"];
            }
            //NSLog(@"vehImage params : %@", paramDictionary);
            
        } else {
            
            [paramDictionary setObject:@"" forKey:@"img_file"];
            [paramDictionary setObject:@"" forKey:@"img_name"];
            [paramDictionary setObject:@"image" forKey:@"img_type"];
        }
        
        
        //NSLog(@"vehImage params : %@", paramDictionary);
        
        
        NSError *err;
        NSData *postDataArray = [NSJSONSerialization dataWithJSONObject:paramDictionary options:NSJSONWritingPrettyPrinted error:&err];
        [def setBool:NO forKey:@"updateTimeStamp"];
        NSString *emptyImgFile = @"";
        if([paramDictionary objectForKey:@"img_file"] != emptyImgFile){
        commonMethods *common = [[commonMethods alloc] init];
        [common saveToCloud:postDataArray urlString:kImageUploadScript success:^(NSDictionary *responseDict) {
            
          //  NSLog(@"vehicle Image Response : %@", responseDict);
            
           } failure:^(NSError *error) {
            
      //       NSLog(@"failed to get response");

        }];
       }
     }
    
}

- (void)uploadServices{
    
    //NIKHIL BUG_144
    NSUserDefaults *isSuccess = [NSUserDefaults standardUserDefaults];
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSMutableArray *serviceParams = [[NSMutableArray alloc] init];
    NSMutableDictionary *androidID = [[NSMutableDictionary alloc] init];
    
    if([def objectForKey:@"UserDeviceId"] != nil){
        
        [androidID setObject:[def objectForKey:@"UserDeviceId"] forKey:@"androidId"];
        
    } else {
        
        [androidID setObject:@"" forKey:@"androidId"];
    }
    
    
    NSMutableDictionary *tableName = [[NSMutableDictionary alloc] init];
    [tableName setObject:@"SERVICE_TABLE" forKey:@"tableName"];
    
    [serviceParams addObject:androidID];
    [serviceParams addObject:tableName];
    
    //BUG_156
    NSManagedObjectContext *context  = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSError *servErr;
    
    NSFetchRequest *servReq = [[NSFetchRequest alloc] initWithEntityName:@"Services_Table"];
    NSArray *serviceData = [context  executeFetchRequest:servReq error:&servErr];
    
    for (Services_Table *services in serviceData) {
        
        NSMutableDictionary *paramDict = [[NSMutableDictionary alloc] init];
        
        NSFetchRequest *vehRequest = [[NSFetchRequest alloc] initWithEntityName:@"Veh_Table"];
        NSError *err;
        NSPredicate *vehPredicate = [NSPredicate predicateWithFormat:@"iD == %d", [services.vehid intValue]];
        [vehRequest setPredicate:vehPredicate];
        
        NSArray *vehData = [context  executeFetchRequest:vehRequest error:&err];
        
        Veh_Table *vehicleData = [vehData firstObject];
        
        if(services.iD != nil){
            [paramDict setObject:services.iD forKey:@"id"];
        } else {
            [paramDict setObject:@"" forKey:@"id"];
        }
        
        
        if([services.type intValue] == 3){
            
            [paramDict setObject:@"All" forKey:@"vehid"];
            
        }else {
            
            if(vehicleData.vehid != nil){
                [paramDict setObject:vehicleData.vehid forKey:@"vehid"];
            } else {
                [paramDict setObject:@"" forKey:@"vehid"];
            }
        }
        
        if(services.type != nil){
            [paramDict setObject:services.type forKey:@"type"];
        } else {
            [paramDict setObject:@"" forKey:@"type"];
        }
        
        if(services.serviceName != nil){
            [paramDict setObject:services.serviceName forKey:@"serviceName"];
        } else {
            [paramDict setObject:@"" forKey:@"serviceName"];
        }
        
        if(services.recurring != nil){
            [paramDict setObject:services.recurring forKey:@"recurring"];
        } else {
            [paramDict setObject:@"" forKey:@"recurring"];
        }
        
        if(services.dueMiles != nil){
            [paramDict setObject:services.dueMiles forKey:@"dueMiles"];
        } else {
            [paramDict setObject:@"" forKey:@"dueMiles"];
        }
        
        if(services.dueDays != nil){
            [paramDict setObject:services.dueDays forKey:@"dueDays"];
        } else {
            [paramDict setObject:@"" forKey:@"dueDays"];
        }
        
        if(services.lastOdo != nil){
            [paramDict setObject:services.lastOdo forKey:@"lastOdo"];
        } else {
            [paramDict setObject:@"" forKey:@"lastOdo"];
        }
        
        commonMethods *common = [[commonMethods alloc] init];
        NSDictionary *epochDictionary = [common getDayMonthYrFromStringDate:services.lastDate];
        
        [paramDict setObject:[epochDictionary valueForKey:@"epochTime"] forKey:@"lastDate"];
        
        [serviceParams addObject:paramDict];
    }
    
    //NSLog(@"Service params : %@", serviceParams);
    
    NSError *err;
    NSData *postDataArray = [NSJSONSerialization dataWithJSONObject:serviceParams options:NSJSONWritingPrettyPrinted error:&err];
    [def setBool:NO forKey:@"updateTimeStamp"];
    commonMethods *common = [[commonMethods alloc] init];
    [common saveToCloud:postDataArray urlString:kFullUploadScript success:^(NSDictionary *responseDict) {
        
       //NSLog(@"services Response : %@", responseDict);
        
        if(!responseDict){
           [isSuccess setBool:NO forKey:@"uploadStatus"];
        }
        
    } failure:^(NSError *error) {
        //NIKHIL BUG_144
        //NSLog(@"failed to get response");
        [isSuccess setBool:NO forKey:@"uploadStatus"];
    }];
    
}

- (void)uploadLog{
    
    //NIKHIL BUG_144
    NSUserDefaults *isSuccess = [NSUserDefaults standardUserDefaults];
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSMutableArray *LogParams = [[NSMutableArray alloc] init];
    NSMutableDictionary *androidID = [[NSMutableDictionary alloc] init];
    
    if([def objectForKey:@"UserDeviceId"] != nil){
        
        [androidID setObject:[def objectForKey:@"UserDeviceId"] forKey:@"androidId"];
        
    } else {
        
        [androidID setObject:@"" forKey:@"androidId"];
    }
    
    
    NSMutableDictionary *tableName = [[NSMutableDictionary alloc] init];
    [tableName setObject:@"LOG_TABLE" forKey:@"tableName"];
    
    [LogParams addObject:androidID];
    [LogParams addObject:tableName];

    //BUG_156
    NSManagedObjectContext *context  = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSError *logErr;
    
    NSFetchRequest *req = [[NSFetchRequest alloc] initWithEntityName:@"T_Fuelcons"];
    NSArray *logData = [context  executeFetchRequest:req error:&logErr];
    commonMethods *common = [[commonMethods alloc] init];
    
    for (T_Fuelcons *log in logData) {
        NSMutableDictionary *parametersDictionary = [[NSMutableDictionary alloc] init];
        
        NSFetchRequest *vehRequest = [[NSFetchRequest alloc] initWithEntityName:@"Veh_Table"];
        NSError *error;
        NSPredicate *vehPredicate = [NSPredicate predicateWithFormat:@"iD == %d", [log.vehid intValue]];
        [vehRequest setPredicate:vehPredicate];
        
        NSArray *vehData = [context  executeFetchRequest:vehRequest error:&error];
        
        Veh_Table *vehicleData = [vehData firstObject];
        
        NSDictionary *epochDictionary = [common getDayMonthYrFromStringDate:log.stringDate];
        
        if(log.iD != nil){
            [parametersDictionary setObject:log.iD forKey:@"id"];
        } else {
            [parametersDictionary setObject:@"" forKey:@"id"];
        }
        
        [parametersDictionary setObject:[epochDictionary valueForKey:@"day"] forKey:@"day"];
        [parametersDictionary setObject:[epochDictionary valueForKey:@"month"] forKey:@"month"];
        [parametersDictionary setObject:[epochDictionary valueForKey:@"year"] forKey:@"year"];
        [parametersDictionary setObject:[epochDictionary valueForKey:@"epochTime"] forKey:@"date"];
        
        if(log.type != nil){
            [parametersDictionary setObject:log.type forKey:@"type"];
        } else {
            [parametersDictionary setObject:@"" forKey:@"type"];
        }
        
        if(vehicleData.vehid != nil){
            [parametersDictionary setObject:vehicleData.vehid forKey:@"vehid"];
        } else {
            [parametersDictionary setObject:@"" forKey:@"vehid"];
        }
        
        if(log.odo != nil){
            [parametersDictionary setObject:log.odo forKey:@"odo"];
        } else {
            [parametersDictionary setObject:@"" forKey:@"odo"];
        }
        
        if(log.qty != nil){
            [parametersDictionary setObject:log.qty forKey:@"qty"];
        } else {
            [parametersDictionary setObject:@"" forKey:@"qty"];
        }
        
        if(log.pfill != nil){
            [parametersDictionary setObject:log.pfill forKey:@"pfill"];
        } else {
            [parametersDictionary setObject:@"" forKey:@"pfill"];
        }
        
        if(log.mfill != nil){
            [parametersDictionary setObject:log.mfill forKey:@"mfill"];
        } else {
            [parametersDictionary setObject:@"" forKey:@"mfill"];
        }
        
        if(log.cost != nil){
            [parametersDictionary setObject:log.cost forKey:@"cost"];
        } else {
            [parametersDictionary setObject:@"" forKey:@"cost"];
        }
        
        if(log.cons != nil){
            [parametersDictionary setObject:log.cons forKey:@"cons"];
        } else {
            [parametersDictionary setObject:@"" forKey:@"cons"];
        }
        
        if(log.dist != nil){
            [parametersDictionary setObject:log.dist forKey:@"dist"];
        } else {
            [parametersDictionary setObject:@"" forKey:@"dist"];
        }
        
        //BUG_157 NIKHIL keyName octane changed to ocatne
        if(log.octane != nil){
            [parametersDictionary setObject:log.octane forKey:@"ocatne"];
        } else {
            [parametersDictionary setObject:@"" forKey:@"ocatne"];
        }
        
        if(log.fuelBrand != nil){
            [parametersDictionary setObject:log.fuelBrand forKey:@"fuelBrand"];
        } else {
            [parametersDictionary setObject:@"" forKey:@"fuelBrand"];
        }
        
        if(log.fillStation != nil){
            [parametersDictionary setObject:log.fillStation forKey:@"fillStation"];
        } else {
            [parametersDictionary setObject:@"" forKey:@"fillStation"];
        }
        
        if(log.notes != nil){
            [parametersDictionary setObject:log.notes forKey:@"notes"];
        } else {
            [parametersDictionary setObject:@"" forKey:@"notes"];
        }
        
        if(log.serviceType != nil){
            [parametersDictionary setObject:log.serviceType forKey:@"serviceType"];
        } else {
            [parametersDictionary setObject:@"" forKey:@"serviceType"];
        }
        BOOL proUser = [[NSUserDefaults standardUserDefaults] boolForKey:@"isAdDisabled"];
        if(log.receipt != nil && log.receipt.length > 0 && proUser){
            //NSLog(@"log.receipt:- %@",log.receipt);
            [parametersDictionary setObject:log.receipt forKey:@"receipt"];
        } else {
            [parametersDictionary setObject:@"" forKey:@"receipt"];
        }
        
        if(log.longitude != nil){
            
            [parametersDictionary setObject:log.longitude forKey:@"depLong"];
        }
        if(log.latitude != nil){
            
            [parametersDictionary setObject:log.latitude forKey:@"depLat"];
        }
        
        [LogParams addObject:parametersDictionary];
    }
    
    NSFetchRequest *tripReq = [[NSFetchRequest alloc] initWithEntityName:@"T_Trip"];
    NSError *tripErr;
    NSArray *tripData = [context  executeFetchRequest:tripReq error:&tripErr];
    
    for (T_Trip *trips in tripData) {
        
        NSMutableDictionary *parametersDictionary = [[NSMutableDictionary alloc] init];
        NSFetchRequest *vehRequest = [[NSFetchRequest alloc] initWithEntityName:@"Veh_Table"];
        NSError *error;
        NSPredicate *vehPredicate = [NSPredicate predicateWithFormat:@"iD == %d", [trips.vehId intValue]];
        [vehRequest setPredicate:vehPredicate];
        
        NSArray *vehData = [context  executeFetchRequest:vehRequest error:&error];
        
        Veh_Table *vehicleData = [vehData firstObject];
        
        NSDictionary *epochDictionary = [common getDayMonthYrFromStringDate:trips.depDate];
        
        if(trips.iD != nil){
            [parametersDictionary setObject:trips.iD forKey:@"id"];
        } else {
            [parametersDictionary setObject:@"" forKey:@"id"];
        }
        
        [parametersDictionary setObject:[epochDictionary valueForKey:@"day"] forKey:@"day"];
        [parametersDictionary setObject:[epochDictionary valueForKey:@"month"] forKey:@"month"];
        [parametersDictionary setObject:[epochDictionary valueForKey:@"year"] forKey:@"year"];
        [parametersDictionary setObject:[epochDictionary valueForKey:@"epochTime"] forKey:@"date"];
        [parametersDictionary setObject:@"3" forKey:@"type"];
        
        
        if(vehicleData.vehid != nil){
            [parametersDictionary setObject:vehicleData.vehid forKey:@"vehid"];
        } else {
            [parametersDictionary setObject:@"" forKey:@"vehid"];
        }
        
        if(trips.depOdo != nil){
            [parametersDictionary setObject:trips.depOdo forKey:@"odo"];
        } else {
            [parametersDictionary setObject:@"" forKey:@"odo"];
        }
        
        if(trips.arrOdo != nil){
            [parametersDictionary setObject:trips.arrOdo forKey:@"qty"];
        } else {
            [parametersDictionary setObject:@"" forKey:@"qty"];
        }
        
        //Convert dep time to dep hour and dep min
        NSDictionary *depDT = [common getDayMonthYrFromStringDate:trips.depDate];
        
        if([depDT valueForKey:@"hours"] != nil){
            [parametersDictionary setObject:[depDT valueForKey:@"hours"] forKey:@"pfill"];
        } else {
            [parametersDictionary setObject:@"" forKey:@"pfill"];
        }
        
        if([depDT valueForKey:@"minutes"] != nil){
            [parametersDictionary setObject:[depDT valueForKey:@"minutes"] forKey:@"mfill"];
        } else {
            [parametersDictionary setObject:@"" forKey:@"mfill"];
        }
        
        if(trips.taxDedn != nil){
            [parametersDictionary setObject:trips.taxDedn forKey:@"cost"];
        } else {
            [parametersDictionary setObject:@"" forKey:@"cost"];
        }
        
        if(trips.parkingAmt != nil){
            [parametersDictionary setObject:trips.parkingAmt forKey:@"dist"];
        } else {
            [parametersDictionary setObject:@"" forKey:@"dist"];
        }
        
        if(trips.arrDate != nil){
            
            //Convert arr date/time in epoch
            NSDictionary *epochArrival = [common getDayMonthYrFromStringDate:trips.arrDate];
            [parametersDictionary setObject:[epochArrival valueForKey:@"epochTime"] forKey:@"cons"];
            
        } else {
            [parametersDictionary setObject:@"" forKey:@"cons"];
        }
        
        //NIKHIL BUG_157 octane keyname changed to ocatne
        if(trips.tollAmt != nil){
            [parametersDictionary setObject:trips.tollAmt forKey:@"ocatne"];
        } else {
            [parametersDictionary setObject:@"" forKey:@"ocatne"];
        }
        
        if(trips.depLocn != nil){
            [parametersDictionary setObject:trips.depLocn forKey:@"fuelBrand"];
        } else {
            [parametersDictionary setObject:@"" forKey:@"fuelBrand"];
        }
        
        if(trips.arrLocn != nil){
            [parametersDictionary setObject:trips.arrLocn forKey:@"fillStation"];
        } else {
            [parametersDictionary setObject:@"" forKey:@"fillStation"];
        }
        
        if(trips.notes != nil){
            [parametersDictionary setObject:trips.notes forKey:@"notes"];
        } else {
            [parametersDictionary setObject:@"" forKey:@"notes"];
        }
        
        if(trips.depLongitude != nil){
            [parametersDictionary setObject:trips.depLongitude forKey:@"depLong"];
        } else {
            [parametersDictionary setObject:@0 forKey:@"depLong"];
        }
        
        if(trips.depLatitude != nil){
            [parametersDictionary setObject:trips.depLatitude forKey:@"depLat"];
        } else {
            [parametersDictionary setObject:@0 forKey:@"depLat"];
        }
        
        if(trips.arrLongitude != nil){
            [parametersDictionary setObject:trips.arrLongitude forKey:@"arrLong"];
        } else {
            [parametersDictionary setObject:@0 forKey:@"arrLong"];
        }
        
        if(trips.arrLatitude != nil){
            [parametersDictionary setObject:trips.tripType forKey:@"arrLat"];
        } else {
            [parametersDictionary setObject:@0 forKey:@"arrLat"];
        }
        
        if(trips.tripType != nil){
            [parametersDictionary setObject:trips.tripType forKey:@"serviceType"];
        } else {
            [parametersDictionary setObject:@"" forKey:@"serviceType"];
        }
        
        [LogParams addObject:parametersDictionary];
    }
    
    if(LogParams.count == 2){
        
        //means only androidID and tableName is present. No log records are there in DB
        [self endUpload];
    }
    
    else {
        
        //printf("log params : %s", [[NSString stringWithFormat:@"%@", LogParams] UTF8String]);
        
        NSLog(@"LogParams from uploadLog :::::%@",LogParams);
        
        NSError *err;
        NSData *postDataArray = [NSJSONSerialization dataWithJSONObject:LogParams options:NSJSONWritingPrettyPrinted error:&err];
        //NSString *strData = [[NSString alloc]initWithData:postDataArray encoding:NSUTF8StringEncoding];
        //NSLog(@"postDataArray :::::%@",strData);
        [def setBool:NO forKey:@"updateTimeStamp"];
        [common saveToCloud:postDataArray urlString:kFullUploadScript success:^(NSDictionary *responseDict) {
        
               //NSLog(@"log Response from upload Log: %@", responseDict);
        
                //Wait for log response, then upload receipts
            if([[responseDict objectForKey:@"message"] isEqualToString:@"Success"]){

                
                //ENH_54 making sync free 1june2018 nikhil // not allowing vehicle images if not pro
                BOOL proUser = [[NSUserDefaults standardUserDefaults] boolForKey:@"isAdDisabled"];
                
                if(proUser){
                    [self uploadReceipts];
                }else{
                    [self endUpload];
                }
            
            } else {
            
                //NIKHIL BUG_149
               // [[NSNotificationCenter defaultCenter] postNotificationName:@"failError" object:nil];
           // [self showAlert:@"Failed to Upload Log" msg:@""];
            }
        } failure:^(NSError *error) {
        
          //  [[NSNotificationCenter defaultCenter] postNotificationName:@"failError" object:nil];
          //  [self showAlert:@"Failed to Upload Log" msg:@""];
            //NSLog(@"failed to get log response");
            [isSuccess setBool:NO forKey:@"uploadStatus"];

        }];
    }
}

- (void)uploadReceipts{
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    //BUG_156
    NSManagedObjectContext *context  = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSError *error;
    
    NSFetchRequest *req = [[NSFetchRequest alloc] initWithEntityName:@"T_Fuelcons"];
    NSArray *data = [context  executeFetchRequest:req error:&error];
    
    for (T_Fuelcons *logData in data) {
        
        NSMutableDictionary *parametersDictionary = [[NSMutableDictionary alloc] init];
        [parametersDictionary setObject:[def objectForKey:@"UserEmail"] forKey:@"email"];
        
        if(logData.receipt != nil && logData.receipt.length > 0){
            
            NSString *imagePath = logData.receipt;
            NSArray *separatedPaths = [imagePath componentsSeparatedByString:@":::"];
    
            //ENH_57 separate each receipt path
            
            for(NSString *currentString in separatedPaths){
                

                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *documentsDirectory = [paths firstObject];
                NSString *completeImgPath = [documentsDirectory stringByAppendingString:[NSString stringWithFormat:@"/%@", currentString]];
                //NSLog(@"completeImgPath:- %@",completeImgPath);
                
                UIImage *receiptImage = [UIImage imageWithContentsOfFile:completeImgPath];
                
                NSData *imageData = UIImagePNGRepresentation(receiptImage);
                
                float imgSizeInMB = [imageData length] / 1024.0f / 1024.0f;
                
                NSString *imageString;
                
                //If images are > than 1.5 MB, compress them and then send to server
                if(imgSizeInMB > 1.5){
                    
                    UIImage *smallImg = [[commonMethods class] imageWithImage:receiptImage scaledToSize:CGSizeMake(300.0, 300.0)];
                    NSData *compressedImg = UIImagePNGRepresentation(smallImg);
                    imageString = [compressedImg base64EncodedStringWithOptions:0];
                    // NSLog(@"compressed img of size : %ld", (unsigned long)[compressedImg length]);
                    
                } else {
                    
                    // NSLog(@"full img of size : %ld", (unsigned long)[imageData length]);
                    
                    imageString = [imageData base64EncodedStringWithOptions:0];
                }
                
                [parametersDictionary setObject:currentString forKey:@"img_name"];
                [parametersDictionary setObject:@"receipt" forKey:@"img_type"];
                if(imageString){
                    [parametersDictionary setObject:imageString forKey:@"img_file"];
                }else{
                    [parametersDictionary setObject:@"" forKey:@"img_file"];
                }
                //NSLog(@"Receipts params : %@", parametersDictionary);
                
                
                NSError *err;
                NSData *postDataArray = [NSJSONSerialization dataWithJSONObject:parametersDictionary options:NSJSONWritingPrettyPrinted error:&err];
                [def setBool:NO forKey:@"updateTimeStamp"];
                commonMethods *common = [[commonMethods alloc] init];
                [common saveToCloud:postDataArray urlString:kImageUploadScript success:^(NSDictionary *responseDict) {
                    
                    //NSLog(@"receipt Images Response : %@", responseDict);
                    
                    
                } failure:^(NSError *error) {
                    
                  //  NSLog(@"failed to get receipt response");
                }];
                
            }
        }
           
    }
    [self endUpload];
    
}

- (void)endUpload{
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *androidID = [[NSMutableDictionary alloc] init];
    
    if([def objectForKey:@"UserDeviceId"] != nil){
        
        [androidID setObject:[def objectForKey:@"UserDeviceId"] forKey:@"androidId"];
        
    } else {
        
        [androidID setObject:@"" forKey:@"androidId"];
    }
    
    
    NSMutableDictionary *tableName = [[NSMutableDictionary alloc] init];
    [tableName setObject:@"endUpload" forKey:@"tableName"];
    
    NSMutableArray *endUploadParams = [[NSMutableArray alloc] init];
    [endUploadParams addObject:androidID];
    [endUploadParams addObject:tableName];
    
    //NSLog(@"endUploadParams : %@", endUploadParams);
    
    NSError *err;
    NSData *postDataArray = [NSJSONSerialization dataWithJSONObject:endUploadParams options:NSJSONWritingPrettyPrinted error:&err];
    [def setBool:YES forKey:@"updateTimeStamp"];
    commonMethods *common = [[commonMethods alloc] init];
    [common saveToCloud:postDataArray urlString:kFullUploadScript success:^(NSDictionary *responseDict) {
        
        //NSLog(@"endUpload success:- %@",responseDict);
        //[self.loadingView removeFromSuperview];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"uploadFinish" object:nil];
        NSDate *date = [[NSDate alloc] init];
        //NSLog(@"localTS : %@", date);
        [[NSUserDefaults standardUserDefaults] setObject:date forKey:@"localTimeStamp"];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"timeStamp"
                                                            object:nil];
        
    } failure:^(NSError *error) {
        
       // NSLog(@"failed to get response");
    }];
}



@end
