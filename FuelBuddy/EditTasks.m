//
//  EditTasks.m
//  FuelBuddy
//
//  Created by Nupur on 13/06/16.
//  Copyright © 2016 Oraganization. All rights reserved.
//

#import "EditTasks.h"
#import "Services_Table.h"
#import "AppDelegate.h"
#import "Reachability.h"
#import "Sync_Table.h"
#import "commonMethods.h"
#import "Veh_Table.h"
#import "JRNLocalNotificationCenter.h"
#import "WebServiceURL's.h"
#import "Veh_Table.h"
#import "CheckReachability.h"


@interface EditTasks ()
{
    NSNumber* taskTypeNum;
    NSString* oldServiceName;
}
@end

@implementation EditTasks

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view
    
    //NSLog(@"Service Dictionary : %@", _serviceRec);
    
    //NSLog(@"service arr : %@", self.serviceArray);
    
    //NSString *add_service = @"Add Service";
    //NSString *edit_service = @"Edit Service";
    self.recurringLabel.text = NSLocalizedString(@"recurring_string", @"You can set reminders for recurring tasks only");
    self.recurringLabel.font = [UIFont systemFontOfSize:10];
    [self.recurringLabel setNumberOfLines:2];
    
    if ([self.taskType isEqualToString:@"Service"])
    {
        taskTypeNum = @1;
        _taskNameLabel.text = NSLocalizedString(@"service_task_name", @"Service Task Name");
        if ([_operation isEqualToString:@"Add"]) {
            _titleLabel.text = NSLocalizedString(@"add_service", @"Add Service");
        }
        else if ([_operation isEqualToString:@"Edit"]) {
            oldServiceName = [self.serviceRec objectForKey:@"ServiceName"];
            _titleLabel.text = NSLocalizedString(@"edit_service", @"Edit Service");
            _taskNameField.text = [self.serviceRec objectForKey:@"ServiceName"];
            _recurringSwitch.on = [[self.serviceRec objectForKey:@"Recurring"] boolValue];
            _forAllVehicleSwitch.on = TRUE;
        }

    }
    
    if ([self.taskType isEqualToString:@"Expense"])
    {

        taskTypeNum = @2;
        _taskNameLabel.text = NSLocalizedString(@"expense_task_name", @"Expense Task Name");

        if ([_operation isEqualToString:@"Add"]) {
            _recurringSwitch.on = NO;
            _titleLabel.text = NSLocalizedString(@"add_expenses", @"Add expenses");
        }
        else if ([_operation isEqualToString:@"Edit"]) {
            
            oldServiceName = [self.serviceRec objectForKey:@"ServiceName"];
            _titleLabel.text = NSLocalizedString(@"edit_expenses", @"Edit Expenses");
            _taskNameField.text = [self.serviceRec objectForKey:@"ServiceName"];
            _recurringSwitch.on = [[self.serviceRec objectForKey:@"Recurring"] boolValue];
            _forAllVehicleSwitch.on = TRUE;

        }
        
    }
    
    _taskNameField.delegate =self;
    
    
    [_bgView.layer setCornerRadius:5.0f];
    
    // border
    [_bgView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [_bgView.layer setBorderWidth:0.5f];
    
    [self.cancelButton.layer setCornerRadius:5.0f];
    [self.cancelButton.layer setBorderWidth:1.0f];
    [self.cancelButton.layer setBorderColor:[UIColor blackColor].CGColor];
    
    [self.saveButton.layer setCornerRadius:5.0f];
    [self.saveButton.layer setBorderWidth:1.0f];
    [self.saveButton.layer setBorderColor:[UIColor blackColor].CGColor];
    [self.saveButton setTitle:NSLocalizedString(@"save", @"Save") forState:UIControlStateNormal];
}

- (IBAction)deleteButtonPressed:(id)sender {
}

- (IBAction)cancelButtonPressed:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)updateButtonPressed:(id)sender {

    if(_taskNameField.text.length!=0 && [_operation isEqualToString:@"Add"] && [self.taskType isEqualToString:@"Service"])
        {
          //  NSLog(@"Add Service task");
       
              if (![[NSUserDefaults standardUserDefaults] boolForKey:@"isAdDisabled"] && self.serviceArray.count == 8)
              {
                  
                  [self dismissViewController:nil message:NSLocalizedString(@"pro_messsage_add_custom", @"Adding unlimited service tasks is available in the Pro Version")];              }
       
              else
              { //NSLog(@"Username: %@", servicename.text);
                  [self addServiceOrExpense:_taskNameField.text recurring:[NSNumber numberWithBool:_recurringSwitch.on ] forAllSwitch:[NSNumber numberWithBool:_forAllVehicleSwitch.on ] forType:@1];
              }
          }
    
    if(_taskNameField.text.length!=0 && [_operation isEqualToString:@"Edit"] && [self.taskType isEqualToString:@"Service"])
    {
      //  NSLog(@"Edit Service task");
        [self updateservice:_taskNameField.text recurring:[NSNumber numberWithBool:_recurringSwitch.on ] forAllSwitch:[NSNumber numberWithBool:_forAllVehicleSwitch.on ]];
    }
    
    if(_taskNameField.text.length!=0 && [_operation isEqualToString:@"Edit"] && [self.taskType isEqualToString:@"Expense"])
    {
      //  NSLog(@"Edit Expense task");
        [self updateservice:_taskNameField.text recurring:[NSNumber numberWithBool:_recurringSwitch.on ] forAllSwitch:[NSNumber numberWithBool:_forAllVehicleSwitch.on ]];
    }
    
    if(_taskNameField.text.length!=0 && [_operation isEqualToString:@"Add"] && [self.taskType isEqualToString:@"Expense"])
    {
      //  NSLog(@"Add Expense task");
        
            if (![[NSUserDefaults standardUserDefaults] boolForKey:@"isAdDisabled"] && self.expenseArray.count == 8)
            {
                //[self showAlert:@"Update to pro version to add more Expenses" message:@""];
                 [self dismissViewController:nil message:NSLocalizedString(@"pro_messsage_add_expense", @"Adding unlimited expenses is available in the Pro Version")];
            }
            
            else
            {
                [self addServiceOrExpense:_taskNameField.text recurring:[NSNumber numberWithBool:_recurringSwitch.on ] forAllSwitch:[NSNumber numberWithBool:_forAllVehicleSwitch.on ] forType:@2];
            }
        
    }
    
    [self dismissViewController:nil message:@""];
    //[self dismissViewControllerAnimated:YES completion:nil];
    //[self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}


// your dismiss function
- (void)dismissViewController:(id)sender message:(NSString*) message
{
    
    [self dismissViewControllerAnimated:YES completion:^
     {
         // MAKE THIS CALL
         self.onDismiss(self, message);
     }];
}



-(void)addServiceOrExpense: (NSString*)servicename recurring:(NSNumber*) recurflag forAllSwitch:(NSNumber*) forAllSwitch forType: (NSNumber*) type
{

    NSManagedObjectContext *contex = [[CoreDataController sharedInstance] newManagedObjectContext];
    //Swapnil BUG_101
    NSFetchRequest *vehRequest = [[NSFetchRequest alloc] initWithEntityName:@"Veh_Table"];
    NSError *vehErr;
    NSArray *vehData = [contex executeFetchRequest:vehRequest error:&vehErr];

    NSString *vehName = [[NSUserDefaults standardUserDefaults]objectForKey:@"vehname"];
    NSString *lastCharVehName = [vehName substringFromIndex:vehName.length-1];

    NSString * finalVehName;
    if([lastCharVehName isEqualToString:@" "]){

        finalVehName = [vehName substringToIndex:vehName.length-1];
    }else{
        finalVehName = vehName;
    }
    NSString *vehId;

    for(Veh_Table *vehicle in vehData){

        NSString *vehicleName = vehicle.vehid;

        if([vehicleName isEqualToString:finalVehName]){

            vehId = [NSString stringWithFormat:@"%@",vehicle.iD];

        }else{

            NSLog(@"did not find the vehicle");
        }
    }

    NSUserDefaults *Def = [NSUserDefaults standardUserDefaults];
    NSFetchRequest *requset=[[NSFetchRequest alloc] initWithEntityName:@"Services_Table"];
    //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type==1 OR type==2"];
    //[requset setPredicate:predicate];
    
    NSError *err;
    //NSArray *datavalue=[contex executeFetchRequest:requset error:&err];
    //Check if any service exists in FuelCons Table

    NSPredicate *pred = [NSPredicate predicateWithFormat:@"serviceName == [cd] %@", servicename];
    NSPredicate *pred2 = [NSPredicate predicateWithFormat:@"vehid == %@", vehId];
    NSPredicate *predicate = [NSCompoundPredicate orPredicateWithSubpredicates:@[pred2, pred]];
    // NSLog(@"Predicate is: %@", pred);
    [requset setPredicate:predicate];
    //[requset setPredicate:pred2];

    //NSError *error = nil;

    NSArray *data=[contex  executeFetchRequest:requset error:&err];
    NSUInteger count = 0;
    for(Services_Table *service in data)
    {

        NSLog(@"serviceName:- %@",service.serviceName);
        NSLog(@"service:- %@",service);

        if([service.serviceName isEqualToString:servicename] && [service.vehid isEqualToString:vehId]){

            count = count+1;
        }
    }

    //NSUInteger count = [contex countForFetchRequest:requset error:&error];

    if (count > 0) {
        //Service with a same name exists
        [self dismissViewController:nil message:@"Service or Expense exists. Make sure you input a unique name"];
        
    }
    else
    {

        NSMutableArray *vehicleid = [[NSMutableArray alloc]init];
        
        //Swapnil BUG_101
        if([forAllSwitch  isEqual: @1]){

            for(Veh_Table *veh in vehData)
            {
                //  NSLog(@"service.vehid :%@", veh.iD);

                if(![vehicleid containsObject:[veh.iD stringValue]])
                {
                    [vehicleid addObject:[veh.iD stringValue]];
                }
            }
        }else if([forAllSwitch  isEqual: @0]){

            for(Veh_Table *vehicle in vehData){

                NSString *vehicleName = vehicle.vehid;

                if([vehicleName isEqualToString:finalVehName]){

                    [vehicleid addObject:[vehicle.iD stringValue]];
                }
            }

        }

        NSLog(@"%@",vehicleid);
        for (int i =0; i<vehicleid.count;i++)
        {

            //Swapnil NEW_6
            int serviceID;
            if([Def objectForKey:@"maxServiceID"] != nil){

                serviceID = [[Def objectForKey:@"maxServiceID"] intValue];
            } else {

                serviceID = 0;
            }

            Services_Table *data=[NSEntityDescription insertNewObjectForEntityForName:@"Services_Table" inManagedObjectContext:contex];
            // NSLog(@"servicename %@", servicename);

            //  data.vehid = [[NSUserDefaults standardUserDefaults]objectForKey: @"fillupid"];
            // NSLog(@"id value %@",data.vehid);

            data.iD = [NSNumber numberWithInt:serviceID + 1];
            [Def setObject:data.iD forKey:@"maxServiceID"];
            data.vehid = [vehicleid objectAtIndex:i];;
            data.serviceName = servicename;
            data.recurring =recurflag;
            data.type=type;
            if ([contex hasChanges])
            {
                BOOL saved = [contex save:&err];
                if (!saved) {
                    // do some real error handling
                    //CLSLog(@“Could not save Data due to %@“, error);
                }
                // NSLog(@"saved");
                [[CoreDataController sharedInstance] saveMasterContext];

                //Swapnil NEW_6
                NSString *userEmail = [Def objectForKey:@"UserEmail"];

                //If user is signed In, then only do the sync process..
                if(userEmail != nil && userEmail.length > 0){

                    [self writeToSyncTableWithRowID:data.iD tableName:@"SERVICE_TABLE" andType:@"add"];
                }
            }
        }
        NSString *userEmail = [Def objectForKey:@"UserEmail"];
        
        //If user is signed In, then only do the sync process..
        if(userEmail != nil && userEmail.length > 0){
            
            // [self checkNetworkForCloudStorage];
        }
        

    }
}

-(void)updateservice:(NSString*)servicename recurring:(NSNumber*) recurflag forAllSwitch:(NSNumber*) forAllSwitch
{

    NSManagedObjectContext *contex = [[CoreDataController sharedInstance] newManagedObjectContext];
    //Swapnil BUG_101
    NSFetchRequest *vehRequest = [[NSFetchRequest alloc] initWithEntityName:@"Veh_Table"];
    NSError *vehErr;
    NSArray *vehData = [contex executeFetchRequest:vehRequest error:&vehErr];

    NSString *vehName = [[NSUserDefaults standardUserDefaults]objectForKey:@"vehname"];

    NSString *lastCharVehName = [vehName substringFromIndex:vehName.length-1];

    NSString * finalVehName;
    if([lastCharVehName isEqualToString:@" "]){

        finalVehName = [vehName substringToIndex:vehName.length-1];
    }else{
        finalVehName = vehName;
    }
    NSString *vehId;

    for(Veh_Table *vehicle in vehData){

        if([vehicle.vehid isEqualToString:finalVehName]){

            vehId = [NSString stringWithFormat:@"%@",vehicle.iD];
            NSLog(@"vehId :- %@",vehId);
        }else{

            NSLog(@"did not find the vehicle");
        }
    }

    NSUserDefaults *Def = [NSUserDefaults standardUserDefaults];
    NSFetchRequest *requset=[[NSFetchRequest alloc] initWithEntityName:@"Services_Table"];
    //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type==1 OR type==2"];
    //[requset setPredicate:predicate];

    NSError *err;
    //NSArray *datavalue=[contex executeFetchRequest:requset error:&err];
    //Check if any service exists in FuelCons Table

    NSPredicate *pred = [NSPredicate predicateWithFormat:@"serviceName == [cd] %@", [self.serviceRec objectForKey:@"ServiceName"]];
    NSPredicate *pred2;
    NSPredicate *predicate;
    if([forAllSwitch isEqual: @0]){

        pred2 = [NSPredicate predicateWithFormat:@"vehid == %@", vehId];
        predicate = [NSCompoundPredicate orPredicateWithSubpredicates:@[pred, pred2]];
    }else{
        predicate = pred;
    }
    // NSLog(@"Predicate is: %@", pred);
    [requset setPredicate:predicate];
    //[requset setPredicate:pred2];

    //NSError *error = nil;

    NSArray *data=[contex  executeFetchRequest:requset error:&err];
    NSUInteger count = 0;
    for(Services_Table *service in data)
    {

        NSLog(@"serviceName:- %@",service.serviceName);
        //NSLog(@"service:- %@",service);
        //NSLog(@"servicename:- %@",servicename);
        if([service.serviceName isEqualToString:servicename] && [service.vehid isEqualToString:vehId]){

            count = count+1;
        }
    }

    NSArray *datavalue=[contex executeFetchRequest:requset error:&err];

    if (count > 0 && ![oldServiceName isEqualToString:servicename]) {
        //Service with a same name exists
        [self dismissViewController:nil message:@"Service or Expense exists. Make sure you input a unique name"];
        
    }
    else
    {

        for (Services_Table *service in datavalue)
        {
            if([forAllSwitch isEqual: @0]) {

                if([service.serviceName isEqualToString:[self.serviceRec objectForKey:@"ServiceName"]] && [service.vehid isEqualToString:vehId]) {

                    service.serviceName = servicename;
                    service.recurring = recurflag;

                    if([recurflag  isEqual: @1]){

                        NSString* jrnKey = [[service.serviceName stringByAppendingString:@","] stringByAppendingString:[[NSUserDefaults standardUserDefaults]objectForKey:@"vehname"]];

                        [[JRNLocalNotificationCenter defaultCenter] cancelLocalNotificationForKey:jrnKey];
                    }

                    if ([contex hasChanges])
                    {
                        BOOL saved = [contex save:&err];
                        if (!saved) {
                            // do some real error handling
                            //CLSLog(@“Could not save Data due to %@“, error);
                        }
                        // NSLog(@"saved");
                        [[CoreDataController sharedInstance] saveMasterContext];

                        //Swapnil NEW_6
                        NSString *userEmail = [Def objectForKey:@"UserEmail"];

                        //If user is signed In, then only do the sync process..
                        if(userEmail != nil && userEmail.length > 0){

                            [self writeToSyncTableWithRowID:service.iD tableName:@"SERVICE_TABLE" andType:@"edit"];
                            // [self checkNetworkForCloudStorage];
                        }
                    }
                }
            }else{

                if([service.serviceName isEqualToString:[self.serviceRec objectForKey:@"ServiceName"]])
                {
                    service.serviceName = servicename;
                    service.recurring = recurflag;

                    if([recurflag  isEqual: @1]){

                        NSString* jrnKey = [[service.serviceName stringByAppendingString:@","] stringByAppendingString:[[NSUserDefaults standardUserDefaults]objectForKey:@"vehname"]];

                        [[JRNLocalNotificationCenter defaultCenter] cancelLocalNotificationForKey:jrnKey];
                    }

                    if ([contex hasChanges])
                    {
                        BOOL saved = [contex save:&err];
                        if (!saved) {
                            // do some real error handling
                            //CLSLog(@“Could not save Data due to %@“, error);
                        }
                        // NSLog(@"saved");
                        [[CoreDataController sharedInstance] saveMasterContext];

                        //Swapnil NEW_6
                        NSString *userEmail = [Def objectForKey:@"UserEmail"];

                        //If user is signed In, then only do the sync process..
                        if(userEmail != nil && userEmail.length > 0){

                            [self writeToSyncTableWithRowID:service.iD tableName:@"SERVICE_TABLE" andType:@"edit"];
                            // [self checkNetworkForCloudStorage];
                        }
                    }
                }
            }
        }

    }
    
}



#pragma mark TEXTFIELD delegate methods

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    
    
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    
    if(textField == _taskNameField){
        
        if([textField.text containsString:@","]){
            UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"comma_err", @"cannot accept commas") message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"ok action") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                
            }];
            [alertControl addAction:ok];
            [self presentViewController:alertControl animated:YES completion:nil];
            NSString *Stringval = [textField.text stringByReplacingOccurrencesOfString:@"," withString:@""];
            textField.text = Stringval;
        }
    }
    
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if(textField == _taskNameField){
        if([textField.text containsString:@","]){
            
            UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"comma_err", @"cannot accept commas") message:nil preferredStyle:UIAlertControllerStyleAlert];
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


- (IBAction)forAllVehicleSwitchChanged:(id)sender {



}


- (IBAction)switchChanged:(id)sender {



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
    
    if([context hasChanges]){
        BOOL saved = [context save:&err];
        if (!saved) {
            // do some real error handling
            //CLSLog(@“Could not save Data due to %@“, error);
        }
        [[CoreDataController sharedInstance] saveMasterContext];
        //Upload data from common methods
        commonMethods *common = [[commonMethods alloc] init];
        [common checkNetworkForCloudStorage:@"isService"];
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

    NSManagedObjectContext *context =[[CoreDataController sharedInstance] backgroundManagedObjectContext];
    NSError *err;
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];

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
    [dictionary setObject:[def objectForKey:@"UserEmail"] forKey:@"email"];
    [dictionary setObject:[def objectForKey:@"UserDeviceId"] forKey:@"androidId"];
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
    
   // NSLog(@"service val : %@", dictionary);
    
    NSData *postData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:&err];
    [def setBool:YES forKey:@"updateTimeStamp"];
    //Pass paramters dictionary and URL of script to get response
    [common saveToCloud:postData urlString:kServiceDataScript success:^(NSDictionary *responseDict) {
      //  NSLog(@"Service responseDict : %@", responseDict);
        
        if([[responseDict objectForKey:@"message"] isEqualToString:@"Success"]){
            
            [common clearPhoneSyncTableWithID:rowID tableName:tableName andType:type];
            
        }
    } failure:^(NSError *error) {
       // NSLog(@"%@", error.localizedDescription);
    }];
    
}

@end
