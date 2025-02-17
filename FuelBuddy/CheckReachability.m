//
//  CheckReachability.m
//  FuelBuddy
//
//  Created by Nikhil on 14/01/19.
//  Copyright © 2019 Oraganization. All rights reserved.
//

#import "CheckReachability.h"
#import "CoreDataController.h"
#import "Reachability.h"
#import "Sync_Table.h"
#import "Veh_Table.h"
#import "T_Fuelcons.h"
#import "T_Trip.h"
#import "Services_Table.h"
#import "Loc_Table.h"
#import "commonMethods.h"
#import "WebServiceURL's.h"

@implementation CheckReachability{

    bool cameHereOnce;
}
@synthesize reach;

+ (CheckReachability *)sharedManager {
    static CheckReachability *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    
    return _sharedManager;
}

-(void)reachabilityChanged:(NSNotification *)notification{
    
    //Reachability *reachability = [notification object];
    //NSParameterAssert([reachability isKindOfClass: [Reachability class]]);

    switch (reach.currentReachabilityStatus) {
        case NotReachable:
            NSLog(@"Network unavailable");
           // [self stopNetworkMonitoring];
            break;

        case ReachableViaWiFi:
            NSLog(@"Network reachable through WiFi");
            if(!cameHereOnce){

                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                    [self fetchDataFromSyncTable];
                });
                cameHereOnce = YES;
               // [self stopNetworkMonitoring];
            }

            //[self performSelectorInBackground:@selector(checkNetworkForCloudStorage) withObject:nil];
            break;

        case ReachableViaWWAN:
            NSLog(@"Network reachable through Cellular Data");
            if(cameHereOnce){

                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                    [self fetchDataFromSyncTable];
                });
                cameHereOnce = YES;
             //   [self stopNetworkMonitoring];
            }
            // [self performSelectorInBackground:@selector(checkNetworkForCloudStorage) withObject:nil];
            break;

        default:
            break;
    }

    [self startNetworkMonitoring];
}

-(void)startNetworkMonitoring{

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    
    reach = [Reachability reachabilityForInternetConnection]; //retain reach
    
    [reach startNotifier];
        
}

-(void)stopNetworkMonitoring{

//    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
//
//    [reach stopNotifier];
}

//- (void)dealloc
//{ // self.hostReachability is my property holding my Reachability instance
//    if (reach) {
//        [reach stopNotifier];
//    }
//}

#pragma mark sync methods
//Loop through the Sync table, fetch table name, type (add, edit, del) and rowID of record
- (void)fetchDataFromSyncTable{
    
    NSManagedObjectContext *context = [[CoreDataController sharedInstance] backgroundManagedObjectContext];
    NSError *err;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Sync_Table"];
    
    NSArray *dataArray = [context executeFetchRequest:request error:&err];

    //Upload data from common methods
    //commonMethods *common = [[commonMethods alloc] init];

    //NSLog(@"dataArray is %@:- ",dataArray);
    if(dataArray.count>0){

        NSLog(@"data is present in sync table so sending to to server");
    }

    for(Sync_Table *syncData in dataArray){
        
        NSString *type = syncData.type;
        
        if([syncData.tableName  isEqualToString: @"VEH_TABLE"]){

//            if([syncData.type isEqualToString:@"del"]){
//
//                [common checkNetworkForCloudStorage:@"isDeleteVehicle"];
//            }else{
//                [common checkNetworkForCloudStorage:@"isVehicle"];
//            }


           [self setVehDataType:type andRowID:syncData.rowID andTableName:syncData.tableName];
            
        }else if([syncData.tableName  isEqualToString: @"SERVICE_TABLE"]){

            //[common checkNetworkForCloudStorage:@"isService"];
            [self setServiceDataType:type andRowID:syncData.rowID andTableName:syncData.tableName];
            
        }else if([syncData.tableName  isEqualToString: @"LOG_TABLE"]){

            //[common checkNetworkForCloudStorage:@"isLog"];
            [self setFuelconDataType:type andRowID:syncData.rowID andTableName:syncData.tableName];
            
        }else if([syncData.tableName  isEqualToString: @"TRIP"]){

            //[common checkNetworkForCloudStorage:@"isTrip"];
            [self setTripDataType:type andRowID:syncData.rowID andTableName:syncData.tableName];
            
        }else if([syncData.tableName  isEqualToString: @"LOC_TABLE"]){

           // [common checkNetworkForCloudStorage:@"isLog"];
            [self setLocTableDataType:type andRowID:syncData.rowID andTableName:syncData.tableName];
            
        }else if([syncData.tableName  isEqualToString: @"SETTINGS"]){

            //[common checkNetworkForCloudStorage:@"isSetting"];
            NSString *newVal = syncData.type;
            [self setParametersWithNewVal:newVal andRowID:syncData.rowID andTableName:syncData.tableName];
            
        }
    }
   // [self sendFriendRecord];

}

-(void)setVehDataType: (NSString *)type andRowID: (NSNumber *)rowID andTableName: (NSString *)tableName{
    
    NSManagedObjectContext *context = [[CoreDataController sharedInstance] backgroundManagedObjectContext];
    NSError *err;
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Veh_Table"];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"iD == %d", [rowID intValue]];

    [request setPredicate:predicate];
    NSArray *dataValue = [context executeFetchRequest:request error:&err];

    Veh_Table *vehData = [dataValue firstObject];
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

    if(vehData.make != nil){

        [dictionary setObject:vehData.make forKey:@"make"];
    }else{

        [dictionary setObject:@"" forKey:@"make"];
    }

    if(vehData.model != nil){

        [dictionary setObject:vehData.model forKey:@"model"];
    }else{

        [dictionary setObject:@"" forKey:@"model"];
    }

    if(vehData.vehid != nil){
        [dictionary setObject:vehData.vehid forKey:@"vehid"];
    } else {
        [dictionary setObject:@"" forKey:@"vehid"];
    }

    if(vehData.year != nil){
        [dictionary setObject:vehData.year forKey:@"year"];
    } else {
        [dictionary setObject:@"" forKey:@"year"];
    }

    if(vehData.lic != nil){
        [dictionary setObject:vehData.lic forKey:@"lic"];
    } else {
        [dictionary setObject:@"" forKey:@"lic"];
    }

    if(vehData.vin != nil){
        [dictionary setObject:vehData.vin forKey:@"vin"];
    } else {
        [dictionary setObject:@"" forKey:@"vin"];
    }

    if(vehData.insuranceNo != nil){
        [dictionary setObject:vehData.insuranceNo forKey:@"insuranceNo"];
    } else {
        [dictionary setObject:@"" forKey:@"insuranceNo"];
    }

    if(vehData.notes != nil){
        [dictionary setObject:vehData.notes forKey:@"notes"];
    } else {
        [dictionary setObject:@"" forKey:@"notes"];
    }

    if(vehData.fuel_type != nil){
        [dictionary setObject:vehData.fuel_type forKey:@"fuelType"];
    } else {
        [dictionary setObject:@"" forKey:@"fuelType"];
    }

    if(vehData.customSpecs != nil){

        [dictionary setObject:vehData.customSpecs forKey:@"customSpecifications"];
    } else {

        [dictionary setObject:@"" forKey:@"customSpecifications"];
    }
    //Start here for making single syncfree4june2018
    BOOL proUser = [[NSUserDefaults standardUserDefaults] boolForKey:@"isAdDisabled"];
    if(vehData.picture != nil && vehData.picture.length > 0 && proUser){

        NSString *imageName = vehData.picture;
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

        if(imageString != nil){

            [dictionary setObject:imageString forKey:@"img_file"];
        }else{

            [dictionary setObject:@"" forKey:@"img_file"];
        }

        if(vehData.picture != nil){

            [dictionary setObject:vehData.picture forKey:@"picture"];
        }else{

            [dictionary setObject:@"" forKey:@"picture"];
        }


    } else {

        [dictionary setObject:@"" forKey:@"img_file"];
        [dictionary setObject:@"" forKey:@"picture"];
    }

    // NSLog(@"data val : %@", dictionary);

    //JSON encode paramters dictionary to be passed to script
    NSData *postData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:&err];
    [def setBool:YES forKey:@"updateTimeStamp"];
    //Pass paramters dictionary and URL of script to get response
    commonMethods *common = [[commonMethods alloc] init];
    [common saveToCloud:postData urlString:kVehDataScript success:^(NSDictionary *responseDict) {

       // NSLog(@"Vehicle responseDict : %@", responseDict);

        if([[responseDict objectForKey:@"message"] isEqualToString:@"Success"]){

            //If response is succes, clear that record from phone sync table
            if([responseDict objectForKey:@"id_changed"] != nil){

                //Change id with new id
                [self getChangedIDAndReplaceCurrentID:vehData.iD:[responseDict objectForKey:@"id_changed"]:tableName];

            }
            [common clearPhoneSyncTableWithID:rowID tableName:tableName andType:type];

        }
    } failure:^(NSError *error) {
        //NSLog(@"%@", error.localizedDescription);
    }];
}

-(void)setServiceDataType: (NSString *)type andRowID: (NSNumber *)rowID andTableName: (NSString *)tableName{
    
    NSManagedObjectContext *context = [[CoreDataController sharedInstance] backgroundManagedObjectContext];
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
            if([responseDict objectForKey:@"id_changed"] != nil){

                //Change id with new id
                [self getChangedIDAndReplaceCurrentID:serviceData.iD:[responseDict objectForKey:@"id_changed"]:tableName];

            }
            [common clearPhoneSyncTableWithID:rowID tableName:tableName andType:type];
            
        }
    } failure:^(NSError *error) {
        //NSLog(@"%@", error.localizedDescription);
    }];
    
}

-(void)setFuelconDataType: (NSString *)type andRowID: (NSNumber *)rowID andTableName: (NSString *)tableName{
    
    NSManagedObjectContext *contex = [[CoreDataController sharedInstance] backgroundManagedObjectContext];
    
    NSError *error;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"T_Fuelcons"];
    NSPredicate *iDPredicate = [NSPredicate predicateWithFormat:@"iD == %d", [rowID intValue]];
    [request setPredicate:iDPredicate];
    
    NSArray *fetchedData = [contex executeFetchRequest:request error:&error];
    
    T_Fuelcons *logData = [fetchedData firstObject];
    
    
    NSFetchRequest *vehRequest = [[NSFetchRequest alloc] initWithEntityName:@"Veh_Table"];
    NSPredicate *vehPredicate = [NSPredicate predicateWithFormat:@"iD == %d", [logData.vehid intValue]];
    [vehRequest setPredicate:vehPredicate];
    
    NSArray *vehData = [[contex executeFetchRequest:vehRequest error:&error] mutableCopy];
    
    Veh_Table *vehicleData = [vehData firstObject];
    
    commonMethods *common = [[commonMethods alloc] init];
    NSDictionary *epochDictionary = [common getDayMonthYrFromStringDate:logData.stringDate];
    
    
    NSMutableDictionary *parametersDictionary = [[NSMutableDictionary alloc] init];
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    
    
    if([def objectForKey:@"UserEmail"] != nil){
        [parametersDictionary setObject:[def objectForKey:@"UserEmail"] forKey:@"email"];
    } else {
        [parametersDictionary setObject:@"" forKey:@"email"];
    }
    [parametersDictionary setObject:@"phone" forKey:@"source"];
    
    if(type != nil){
        [parametersDictionary setObject:type forKey:@"type"];
    } else {
        [parametersDictionary setObject:@"" forKey:@"type"];
    }

    //Added new parameter for friend stuff
    [parametersDictionary setObject:@"self" forKey:@"originalSource"];

    if(rowID != nil){
        [parametersDictionary setObject:rowID forKey:@"_id"];
    } else {
        [parametersDictionary setObject:@"" forKey:@"_id"];
    }
    
    if([def objectForKey:@"UserDeviceId"] != nil){
        [parametersDictionary setObject:[def objectForKey:@"UserDeviceId"] forKey:@"androidId"];
    } else {
        [parametersDictionary setObject:@"" forKey:@"androidId"];
    }
    [parametersDictionary setObject:[epochDictionary valueForKey:@"day"] forKey:@"day"];
    [parametersDictionary setObject:[epochDictionary valueForKey:@"month"] forKey:@"month"];
    [parametersDictionary setObject:[epochDictionary valueForKey:@"year"] forKey:@"year"];
    [parametersDictionary setObject:[epochDictionary valueForKey:@"epochTime"] forKey:@"date"];
    
    if(logData.type != nil){
        [parametersDictionary setObject:logData.type forKey:@"rec_type"];
    } else {
        [parametersDictionary setObject:@"" forKey:@"rec_type"];
    }
    
    if(vehicleData.vehid != nil){
        [parametersDictionary setObject:vehicleData.vehid forKey:@"vehid"];
    } else {
        [parametersDictionary setObject:@"" forKey:@"vehid"];
    }
    
    if(logData.odo != nil){
        [parametersDictionary setObject:logData.odo forKey:@"odo"];
    } else {
        [parametersDictionary setObject:@"" forKey:@"odo"];
    }
    
    if(logData.qty != nil){
        [parametersDictionary setObject:logData.qty forKey:@"qty"];
    } else {
        [parametersDictionary setObject:@"" forKey:@"qty"];
    }
    
    if(logData.pfill != nil){
        [parametersDictionary setObject:logData.pfill forKey:@"pfill"];
    } else {
        [parametersDictionary setObject:@"" forKey:@"pfill"];
    }
    
    if(logData.mfill != nil){
        [parametersDictionary setObject:logData.mfill forKey:@"mfill"];
    } else {
        [parametersDictionary setObject:@"" forKey:@"mfill"];
    }
    
    if(logData.cost != nil){
        [parametersDictionary setObject:logData.cost forKey:@"cost"];
    } else {
        [parametersDictionary setObject:@"" forKey:@"cost"];
    }
    
    //NSLog(@"distance : %@", logData.dist);
    //NSLog(@"consump : %@", logData.cons);
    
    if(logData.dist != nil){
        [parametersDictionary setObject:logData.dist forKey:@"dist"];
    } else {
        [parametersDictionary setObject:@"" forKey:@"dist"];
    }
    
    if(logData.cons != nil){
        [parametersDictionary setObject:logData.cons forKey:@"cons"];
    } else {
        [parametersDictionary setObject:@"" forKey:@"cons"];
    }
    //BUG_157 NIKHIL keyName octane changed to ocatne
    if(logData.octane != nil){
        [parametersDictionary setObject:logData.octane forKey:@"octane"];
    } else {
        [parametersDictionary setObject:@"" forKey:@"octane"];
    }
    
    if(logData.fuelBrand != nil){
        [parametersDictionary setObject:logData.fuelBrand forKey:@"fuelBrand"];
    } else {
        [parametersDictionary setObject:@"" forKey:@"fuelBrand"];
    }
    
    if(logData.fillStation != nil){
        [parametersDictionary setObject:logData.fillStation forKey:@"fillStation"];
    } else {
        [parametersDictionary setObject:@"" forKey:@"fillStation"];
    }
    
    if(logData.notes != nil){
        [parametersDictionary setObject:logData.notes forKey:@"notes"];
    } else {
        [parametersDictionary setObject:@"" forKey:@"notes"];
    }
    
    if(logData.serviceType != nil){
        [parametersDictionary setObject:logData.serviceType forKey:@"serviceType"];
    } else {
        [parametersDictionary setObject:@"" forKey:@"serviceType"];
    }
    
    //New_11 added properties to sync
    
    if(logData.longitude != nil){
        
        [parametersDictionary setObject:logData.longitude forKey:@"depLong"];
    }
    if(logData.latitude != nil){
        
        [parametersDictionary setObject:logData.latitude forKey:@"depLat"];
    }
    
    //ENH_54 Start here for making single syncfree4june2018
    BOOL proUser = [[NSUserDefaults standardUserDefaults] boolForKey:@"isAdDisabled"];
    if(logData.receipt != nil && logData.receipt.length > 0 && proUser){
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths firstObject];
        NSString *imagePath = logData.receipt;
        NSArray *separatedArray = [imagePath componentsSeparatedByString:@":::"];
        NSString *imageString;
        NSMutableDictionary *receiptDict = [[NSMutableDictionary alloc]init];
        for(int i=0;i<separatedArray.count;i++){
            
            NSString *completeImgPath = [documentsDirectory stringByAppendingString:[NSString stringWithFormat:@"/%@", [separatedArray objectAtIndex:i]]];
            
            UIImage *receiptImage = [UIImage imageWithContentsOfFile:completeImgPath];
            
            NSData *imageData = UIImagePNGRepresentation(receiptImage);
            
            float imgSizeInMB = [imageData length] / 1024.0f / 1024.0f;
            
            
            
            //If images are > than 1.5 MB, compress them and then send to server
            if(imgSizeInMB > 1.5){
                
                UIImage *smallImg = [[commonMethods class] imageWithImage:receiptImage scaledToSize:CGSizeMake(300.0, 300.0)];
                NSData *compressedImg = UIImagePNGRepresentation(smallImg);
                imageString = [compressedImg base64EncodedStringWithOptions:0];
                //NSLog(@"compressed img of size : %ld", [compressedImg length]);
                
            } else {
                
                //NSLog(@"full img of size : %ld", [imageData length]);
                
                imageString = [imageData base64EncodedStringWithOptions:0];
            }
            NSString *receiptName = [separatedArray objectAtIndex:i];
            if(imageString != nil){

                [receiptDict setObject:imageString forKey:[NSString stringWithFormat:@"%@",receiptName]];
            }

        }
        NSString *colonString = [NSString stringWithFormat:@"%@:::",logData.receipt];
        [parametersDictionary setObject:colonString forKey:@"receipt"];
        //   if(separatedArray.count>1){
        if(receiptDict != nil){

            [parametersDictionary setObject:receiptDict forKey:@"img_file"];
        }else{

            [parametersDictionary setObject:@"" forKey:@"img_file"];
        }

        //                }else{
        //
        //                    [parametersDictionary setObject:imageString forKey:@"img_file"];
        //                }
    } else {
        
        [parametersDictionary setObject:@"" forKey:@"receipt"];
        [parametersDictionary setObject:@"" forKey:@"img_file"];
    }
    
    NSLog(@"Log params dict : %@", parametersDictionary);
    
    NSData *postData = [NSJSONSerialization dataWithJSONObject:parametersDictionary options:NSJSONWritingPrettyPrinted error:&error];
    [def setBool:YES forKey:@"updateTimeStamp"];
    //Pass paramters dictionary and URL of script to get response
    [common saveToCloud:postData urlString:kLogDataScript success:^(NSDictionary *responseDict) {

        NSLog(@"responseDict LOG : %@", responseDict);
        
        if([[responseDict objectForKey:@"message"] isEqualToString:@"Success"]){

            if([responseDict objectForKey:@"id_changed"] != nil){

                //Change id with new id
                [self getChangedIDAndReplaceCurrentID:logData.iD:[responseDict objectForKey:@"id_changed"]:tableName];

            }
            [common clearPhoneSyncTableWithID:rowID tableName:tableName andType:type];
        }
    } failure:^(NSError *error) {
        // NSLog(@"%@", error.localizedDescription);
    }];
}

-(void)setTripDataType: (NSString *)type andRowID: (NSNumber *)rowID andTableName: (NSString *)tableName{
    
    NSManagedObjectContext *context = [[CoreDataController sharedInstance] backgroundManagedObjectContext];
    NSError *err;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"T_Trip"];
    NSPredicate *iDPredicate = [NSPredicate predicateWithFormat:@"iD == %d", [rowID intValue]];
    [request setPredicate:iDPredicate];
    
    NSArray *fetchedData = [context executeFetchRequest:request error:&err];
    
    T_Trip *tripData = [fetchedData firstObject];
    
    
    NSFetchRequest *vehRequest = [[NSFetchRequest alloc] initWithEntityName:@"Veh_Table"];
    NSPredicate *vehPredicate = [NSPredicate predicateWithFormat:@"iD == %d", [tripData.vehId intValue]];
    [vehRequest setPredicate:vehPredicate];
    
    NSArray *vehData = [context executeFetchRequest:vehRequest error:&err];
    
    Veh_Table *vehicleData = [vehData firstObject];
    
    commonMethods *common = [[commonMethods alloc] init];
    NSDictionary *epochDictionary = [common getDayMonthYrFromStringDate:tripData.depDate];
    
    
    NSMutableDictionary *parametersDictionary = [[NSMutableDictionary alloc] init];
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    if([def objectForKey:@"UserEmail"] != nil){
        [parametersDictionary setObject:[def objectForKey:@"UserEmail"] forKey:@"email"];
    }else{
        [parametersDictionary setObject:@"" forKey:@"email"];
    }
    [parametersDictionary setObject:@"phone" forKey:@"source"];
    
    if(type != nil){
        [parametersDictionary setObject:type forKey:@"type"];
    } else {
        [parametersDictionary setObject:@"" forKey:@"type"];
    }

    //Added new parameter for friend stuff
    [parametersDictionary setObject:@"self" forKey:@"originalSource"];

    if(rowID != nil){
        [parametersDictionary setObject:rowID forKey:@"_id"];
    } else {
        [parametersDictionary setObject:@"" forKey:@"_id"];
    }
    [parametersDictionary setObject:[def objectForKey:@"UserDeviceId"] forKey:@"androidId"];
    
    [parametersDictionary setObject:[epochDictionary valueForKey:@"day"] forKey:@"day"];
    [parametersDictionary setObject:[epochDictionary valueForKey:@"month"] forKey:@"month"];
    [parametersDictionary setObject:[epochDictionary valueForKey:@"year"] forKey:@"year"];
    [parametersDictionary setObject:[epochDictionary valueForKey:@"epochTime"] forKey:@"date"];
    [parametersDictionary setObject:@"3" forKey:@"rec_type"];
    
    
    if(vehicleData.vehid != nil){
        [parametersDictionary setObject:vehicleData.vehid forKey:@"vehid"];
    } else {
        [parametersDictionary setObject:@"" forKey:@"vehid"];
    }
    
    if(tripData.depOdo != nil){
        [parametersDictionary setObject:tripData.depOdo forKey:@"odo"];
    } else {
        [parametersDictionary setObject:@"" forKey:@"odo"];
    }
    
    if(tripData.arrOdo != nil){
        [parametersDictionary setObject:tripData.arrOdo forKey:@"qty"];
    } else {
        [parametersDictionary setObject:@"" forKey:@"qty"];
    }
    
    //Convert dep time to dep hour and dep min
    NSDictionary *depDT = [common getDayMonthYrFromStringDate:tripData.depDate];
    
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
    
    if(tripData.taxDedn != nil){
        [parametersDictionary setObject:tripData.taxDedn forKey:@"cost"];
    } else {
        [parametersDictionary setObject:@"" forKey:@"cost"];
    }
    
    if(tripData.parkingAmt != nil){
        [parametersDictionary setObject:tripData.parkingAmt forKey:@"dist"];
    } else {
        [parametersDictionary setObject:@"" forKey:@"dist"];
    }
    
    if(tripData.arrDate != nil){
        
        //Convert arr date/time in epoch
        NSDictionary *epochArrival = [common getDayMonthYrFromStringDate:tripData.arrDate];
        [parametersDictionary setObject:[epochArrival valueForKey:@"epochTime"] forKey:@"cons"];
        
    } else {
        [parametersDictionary setObject:@"" forKey:@"cons"];
    }
    //BUG_157 NIKHIL keyName octane changed to ocatne
    if(tripData.tollAmt != nil){
        [parametersDictionary setObject:tripData.tollAmt forKey:@"octane"];
    } else {
        [parametersDictionary setObject:@"" forKey:@"octane"];
    }
    
    if(tripData.depLocn != nil){
        [parametersDictionary setObject:tripData.depLocn forKey:@"fuelBrand"];
    } else {
        [parametersDictionary setObject:@"" forKey:@"fuelBrand"];
    }
    
    if(tripData.arrLocn != nil){
        [parametersDictionary setObject:tripData.arrLocn forKey:@"fillStation"];
    } else {
        [parametersDictionary setObject:@"" forKey:@"fillStation"];
    }
    
    if(tripData.notes != nil){
        [parametersDictionary setObject:tripData.notes forKey:@"notes"];
    } else {
        [parametersDictionary setObject:@"" forKey:@"notes"];
    }
    
    if(tripData.tripType != nil){
        [parametersDictionary setObject:tripData.tripType forKey:@"serviceType"];
    } else {
        [parametersDictionary setObject:@"" forKey:@"serviceType"];
    }
    
    if(tripData.depLatitude != nil){
        [parametersDictionary setObject:tripData.depLatitude forKey:@"depLat"];
    } else {
        [parametersDictionary setObject:@0 forKey:@"depLat"];
    }
    
    if(tripData.depLongitude != nil){
        [parametersDictionary setObject:tripData.depLongitude forKey:@"depLong"];
    } else {
        [parametersDictionary setObject:@0 forKey:@"depLong"];
    }
    
    if(tripData.arrLatitude != nil){
        [parametersDictionary setObject:tripData.arrLatitude forKey:@"arrLat"];
    } else {
        [parametersDictionary setObject:@0 forKey:@"arrLat"];
    }
    
    if(tripData.arrLongitude != nil){
        [parametersDictionary setObject:tripData.arrLongitude forKey:@"arrLong"];
    } else {
        [parametersDictionary setObject:@0 forKey:@"arrLong"];
    }
    
    //NSLog(@"Log params dict : %@", parametersDictionary);
    
    NSData *postData = [NSJSONSerialization dataWithJSONObject:parametersDictionary options:NSJSONWritingPrettyPrinted error:&err];
    [def setBool:YES forKey:@"updateTimeStamp"];
    //Pass paramters dictionary and URL of script to get response
    [common saveToCloud:postData urlString:kLogDataScript success:^(NSDictionary *responseDict) {
       // NSLog(@"responseDict LOG : %@", responseDict);
        
        if([[responseDict objectForKey:@"message"] isEqualToString:@"Success"]){

            if([responseDict objectForKey:@"id_changed"] != nil){

                //Change id with new id
                [self getChangedIDAndReplaceCurrentID:tripData.iD:[responseDict objectForKey:@"id_changed"]:tableName];

            }
            [common clearPhoneSyncTableWithID:rowID tableName:tableName andType:type];
        }
    } failure:^(NSError *error) {
        //  NSLog(@"%@", error.localizedDescription);
    }];
    
        
}

-(void)setLocTableDataType: (NSString *)type andRowID: (NSNumber *)rowID andTableName: (NSString *)tableName{
    
    NSManagedObjectContext *context = [[CoreDataController sharedInstance] backgroundManagedObjectContext];
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSError *locErr;
    NSFetchRequest *locRequest = [[NSFetchRequest alloc] initWithEntityName:@"Loc_Table"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"iD == %d", [rowID intValue]];
    [locRequest setPredicate:predicate];
    
    NSArray *locArray = [context executeFetchRequest:locRequest error:&locErr];
    
    Loc_Table *locationData = [locArray firstObject];
    
    NSMutableDictionary *parametersDictionary = [[NSMutableDictionary alloc] init];
    
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
    
    if(type != nil){
        [parametersDictionary setObject:type forKey:@"type"];
    } else {
        [parametersDictionary setObject:@"" forKey:@"type"];
    }
    
    if(rowID != nil){
        [parametersDictionary setObject:rowID forKey:@"_id"];
    } else {
        [parametersDictionary setObject:@"" forKey:@"_id"];
    }
    
    if([locationData.lat floatValue] != 0.0){
        [parametersDictionary setObject:locationData.lat forKey:@"lat"];
    } else {
        [parametersDictionary setObject:@"" forKey:@"lat"];
    }
    
    if([locationData.longitude floatValue] != 0.0){
        [parametersDictionary setObject:locationData.longitude forKey:@"long"];
    } else {
        [parametersDictionary setObject:@"" forKey:@"long"];
    }
    
    if(locationData.address != nil){
        [parametersDictionary setObject:locationData.address forKey:@"address"];
    } else {
        [parametersDictionary setObject:@"" forKey:@"address"];
    }
    
    if(locationData.brand != nil){
        [parametersDictionary setObject:locationData.brand forKey:@"brand"];
    } else {
        [parametersDictionary setObject:@"" forKey:@"brand"];
    }
    
    // NSLog(@"Log params dict : %@", parametersDictionary);
    
    NSError *error;
    NSData *postData = [NSJSONSerialization dataWithJSONObject:parametersDictionary options:NSJSONWritingPrettyPrinted error:&error];
    [def setBool:YES forKey:@"updateTimeStamp"];
    commonMethods *common = [[commonMethods alloc] init];
    //Pass paramters dictionary and URL of script to get response
    [common saveToCloud:postData urlString:kLocationScript success:^(NSDictionary *responseDict) {
        // NSLog(@"responseDict LOG : %@", responseDict);
        
        if([[responseDict objectForKey:@"message"] isEqualToString:@"Success"]){
            
            [common clearPhoneSyncTableWithID:rowID tableName:tableName andType:type];
        }
    } failure:^(NSError *error) {
        //          NSLog(@"%@", error.localizedDescription);
    }];

}


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

-(void)getChangedIDAndReplaceCurrentID:(NSNumber *)oldID :(NSNumber *)changedID :(NSString *)tableName{

    NSManagedObjectContext *context =[[CoreDataController sharedInstance] backgroundManagedObjectContext];

    NSError *err;
    NSFetchRequest *request;

    if([tableName isEqualToString:@"LOG_TABLE"]){

        request = [[NSFetchRequest alloc] initWithEntityName:@"T_Fuelcons"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"iD == %@", oldID];
        [request setPredicate:predicate];
        NSArray *fetchedData = [context executeFetchRequest:request error:&err];

        if(fetchedData.count>0){

            T_Fuelcons *logData = [fetchedData firstObject];

            logData.iD = changedID;

        }


    }else if([tableName isEqualToString:@"LOC_TABLE"]){

        request = [[NSFetchRequest alloc] initWithEntityName:@"Loc_Table"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"iD == %@", oldID];
        [request setPredicate:predicate];
        NSArray *fetchedData = [context executeFetchRequest:request error:&err];

        if(fetchedData.count>0){

            Loc_Table *locData = [fetchedData firstObject];

            locData.iD = changedID;

        }

    }else if([tableName isEqualToString:@"TRIP"]){

        request = [[NSFetchRequest alloc] initWithEntityName:@"T_Trip"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"iD == %@", oldID];
        [request setPredicate:predicate];
        NSArray *fetchedData = [context executeFetchRequest:request error:&err];

        if(fetchedData.count>0){

            T_Trip *tripData = [fetchedData firstObject];

            tripData.iD = changedID;

        }

    }else if([tableName isEqualToString:@"VEH_TABLE"]){

        request = [[NSFetchRequest alloc] initWithEntityName:@"Veh_Table"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"iD == %@", oldID];
        [request setPredicate:predicate];
        NSArray *fetchedData = [context executeFetchRequest:request error:&err];

        if(fetchedData.count>0){

            Veh_Table *vehData = [fetchedData firstObject];

            vehData.iD = changedID;

        }

    }else if([tableName isEqualToString:@"SERVICE_TABLE"]){

        request = [[NSFetchRequest alloc] initWithEntityName:@"Services_Table"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"iD == %@", oldID];
        [request setPredicate:predicate];
        NSArray *fetchedData = [context executeFetchRequest:request error:&err];

        if(fetchedData.count>0){

            Services_Table *serData = [fetchedData firstObject];

            serData.iD = changedID;

        }
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

}

//-(void)sendFriendRecord{
//
//    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
//    NSError *err;
//
//    if(![[def objectForKey:@"pendingFriendRecord"] isEqualToString:@""]){
//
//        NSMutableArray *allDataArray = [def objectForKey:@"pendingFriendRecord"];
//
//        for(NSMutableDictionary *parametersDict in allDataArray){
//
//            if(parametersDict){
//
//                NSData *postDataArray = [NSJSONSerialization dataWithJSONObject:parametersDict options:NSJSONWritingPrettyPrinted error:&err];
//                commonMethods *common = [[commonMethods alloc] init];
//                [def setBool:NO forKey:@"updateTimeStamp"];
//                [common saveToCloud:postDataArray urlString:kFriendSyncDataScript success:^(NSDictionary *responseDict) {
//
//                    //NSLog(@"ResponseDict is : %@", responseDict);
//
//                    if([[responseDict valueForKey:@"success"]  isEqual: @1]){
//
//                        // NSLog(@"success:- %@",[responseDict valueForKey:@"success"]);
//
//                    }
//
//
//                } failure:^(NSError *error) {
//
//                }];
//            }
//        }
//        [def setObject:@"" forKey:@"pendingFriendRecord"];
//
//    }
//
//}

@end
