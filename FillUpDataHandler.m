//
//  FillUpDataHandler.m
//  FuelBuddy
//
//  Created by Nikhil on 14/05/18.
//  Copyright © 2018 Oraganization. All rights reserved.
//

#import "FillUpDataHandler.h"
#import "CoreDataController.h"
#import "commonMethods.h"
#import "T_Fuelcons.h"
#import "Veh_Table.h"
#import "AddFillupViewController.h"
#import "ServiceViewController.h"
#import "Services_Table.h"
#import "JRNLocalNotificationCenter.h"


@implementation FillUpDataHandler

-(void)addFillUp:(int)contextType {
    
    NSManagedObjectContext *context;
    NSError *error;
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    if(contextType == 1){
       context = [[CoreDataController sharedInstance] newManagedObjectContext];
    }else{
       context = [[CoreDataController sharedInstance] backgroundManagedObjectContext];
    }
    
    
    //from driver
    NSFetchRequest *vehRequest = [[NSFetchRequest alloc] initWithEntityName:@"Veh_Table"];
    NSError *vehErr;
    NSPredicate *vehPredicate = [NSPredicate predicateWithFormat:@"vehid == %@", self.vehid];
    [vehRequest setPredicate:vehPredicate];
    NSArray *vehArray = [context executeFetchRequest:vehRequest error:&vehErr];
    
    Veh_Table *vehData = [vehArray firstObject];
    
    
    NSFetchRequest *logRequest = [[NSFetchRequest alloc] initWithEntityName:@"T_Fuelcons"];
    NSError *logErr;
    NSPredicate *logPred = [NSPredicate predicateWithFormat:@"iD == %@", self.iD];
    [logRequest setPredicate:logPred];
    NSArray *logResult = [context executeFetchRequest:logRequest error:&logErr];
    T_Fuelcons *log = [logResult firstObject];
    
    //If rowId is not present then only add new one (unique constraint check)
    if(!log){
       T_Fuelcons *datavalue = [NSEntityDescription insertNewObjectForEntityForName:@"T_Fuelcons" inManagedObjectContext:context];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"dd-MMM-yyyy"];
        NSString *thisDate = [NSString stringWithFormat:@"%@", self.stringDate];
        NSTimeInterval dateTime = [thisDate doubleValue] / 1000;
        NSString *dateString = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:dateTime]];
        NSDate *date = [formatter dateFromString:dateString];
        datavalue.iD = @([self.iD intValue]);
        datavalue.odo = @([self.odo floatValue]);
        datavalue.cost = @([self.cost floatValue]);
        datavalue.qty = @([self.qty floatValue]);
        datavalue.octane = @([self.octane intValue]);
        datavalue.fuelBrand = self.fuelBrand;
        datavalue.fillStation = self.fillStation;
        datavalue.longitude = @([self.longitude floatValue]);
        datavalue.latitude = @([self.latitude floatValue]);
        datavalue.notes = self.notes;
        datavalue.receipt = self.receipt;
        datavalue.vehid = [vehData.iD stringValue];
        datavalue.mfill = @([self.mfill intValue]);
        datavalue.pfill = @([self.pfill intValue]);
        datavalue.day = @(0);
        datavalue.month = @(0);
        datavalue.year = @(0);
        datavalue.stringDate = date;
        datavalue.serviceType = self.serviceType;
        datavalue.type = @([self.type intValue]);
        datavalue.latitude = @([self.latitude floatValue]);
        datavalue.longitude = @([self.longitude floatValue]);
        
         //NSLog(@"type::- %@",datavalue.type);
         NSMutableDictionary *serUpdateDict = [[NSMutableDictionary alloc]init];
         [serUpdateDict setObject:self.odo forKey:@"ODO"];
         [serUpdateDict setObject:self.stringDate forKey:@"DATE"];
         [serUpdateDict setObject:self.serviceType forKey:@"SERVICE_TYPE"];
        
        if ([context hasChanges])
        {
           BOOL saved = [context save:&error];
           if (!saved) {
               // do some real error handling
               //CLSLog(@“Could not save Data due to %@“, error);
           }
            [def setObject:self.iD forKey:@"maxFuelID"];
          if(contextType == 1){
              
                [[CoreDataController sharedInstance] saveMasterContext];
          }else{
              
              [[CoreDataController sharedInstance] saveBackgroundContext];
          }
           dispatch_async(dispatch_get_main_queue(), ^{
               [[CoreDataController sharedInstance] saveMasterContext];
           });
       }
      
      [def setObject:[vehData.iD stringValue] forKey:@"fillupid"];
      commonMethods *common = [[commonMethods alloc]init];
      [common updateDistance:1];
      [common updateConsumption:1];
        
       
            
            if([datavalue.type intValue] == 1 || [datavalue.type intValue] == 2){
                
                ServiceViewController *serviceVC = [[ServiceViewController alloc] init];
                [serviceVC insertservice: 0];
                [self updateservice:serUpdateDict];
            }
            [self getOdoServicesWithOdo:[[serUpdateDict valueForKey:@"ODO"] floatValue]];
       
        
    }
}

-(void)editFillUp:(NSDictionary *)editDict :(int)contextType{
    
    NSManagedObjectContext *context;
    NSError *error;
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    if(contextType == 1){
        context = [[CoreDataController sharedInstance] newManagedObjectContext];
    }else{
        context = [[CoreDataController sharedInstance] backgroundManagedObjectContext];
    }
    
    //NSLog(@"userinfo :- %@",editDict);
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"T_Fuelcons"];
    int logId = [[editDict objectForKey:@"id"] intValue];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"iD == %i",logId];
    [request setPredicate:predicate];
    NSArray *fetchedData = [context executeFetchRequest:request error:&error];
    
    T_Fuelcons *logData = [fetchedData firstObject];
    
    
    NSFetchRequest *vehRequest = [[NSFetchRequest alloc] initWithEntityName:@"Veh_Table"];
    NSError *vehErr;
    NSPredicate *vehPredicate = [NSPredicate predicateWithFormat:@"vehid == %@", [editDict objectForKey:@"vehid"]];
    [vehRequest setPredicate:vehPredicate];
    NSArray *vehArray = [context executeFetchRequest:vehRequest error:&vehErr];
    
    Veh_Table *vehData = [vehArray firstObject];
    
    //Convert UNIX time to local date/time
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd-MMM-yyyy"];
    NSString *thisDate = [NSString stringWithFormat:@"%@", [editDict objectForKey:@"date"]];
    NSTimeInterval dateTime = [thisDate doubleValue] / 1000;
    NSString *dateString = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:dateTime]];
    NSDate *date = [formatter dateFromString:dateString];
    
    if(logData){
      
        logData.vehid = [vehData.iD stringValue];
        logData.type = @([[editDict valueForKey:@"type"] intValue]);
        logData.odo = @([[editDict valueForKey:@"odo"] floatValue]);
        logData.qty = @([[editDict valueForKey:@"qty"] floatValue]);
        logData.cost = @([[editDict valueForKey:@"cost"] floatValue]);
        logData.fillStation = [editDict valueForKey:@"fillStation"];
        logData.fuelBrand = [editDict valueForKey:@"fuelBrand"];
        logData.mfill = @([[editDict valueForKey:@"mfill"] intValue]);
        logData.pfill = @([[editDict valueForKey:@"pfill"] intValue]);
        logData.notes = [editDict valueForKey:@"notes"];
        logData.octane = @([[editDict valueForKey:@"octane"] intValue]);
        logData.serviceType = [editDict valueForKey:@"serviceType"];
        logData.stringDate = date;
        logData.day = @(0);
        logData.month = @(0);
        logData.year = @(0);
        logData.receipt = self.receipt;
        
        NSMutableDictionary *serUpdateDict = [[NSMutableDictionary alloc]init];
        [serUpdateDict setObject:logData.odo forKey:@"ODO"];
        [serUpdateDict setObject:[editDict valueForKey:@"date"] forKey:@"DATE"];
        [serUpdateDict setObject:logData.serviceType forKey:@"SERVICE_TYPE"];
        
        if ([context hasChanges])
        {
            BOOL saved = [context save:&error];
            if (!saved) {
                // do some real error handling
               //CLSLog(@“Could not save Data due to %@“, error);
            }
           if(contextType == 1){
               
                 //NSLog(@"Context Saved");
                 [[CoreDataController sharedInstance] saveMasterContext];
            }else{
                
                 //NSLog(@"Context Saved in BG");
                 [[CoreDataController sharedInstance] saveBackgroundContext];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[CoreDataController sharedInstance] saveMasterContext];
            });
        }
    
      [def setObject:[vehData.iD stringValue] forKey:@"fillupid"];
      commonMethods *common = [[commonMethods alloc]init];
      [common updateDistance:1];
      [common updateConsumption:1];
        
        
        if([logData.type intValue] == 1 || [logData.type intValue] == 2){
            
            ServiceViewController *serviceVC = [[ServiceViewController alloc] init];
            [serviceVC insertservice: 0];
            [self updateservice:serUpdateDict];
        }
        [self getOdoServicesWithOdo:[[serUpdateDict valueForKey:@"ODO"] floatValue]];
        
    }else{
        
        //NSLog(@"no record found..!");
    }
}


-(void)deleteFillUp:(int)contextType{
    
    NSManagedObjectContext *context;
    NSError *error;
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    if(contextType == 1){
        context = [[CoreDataController sharedInstance] newManagedObjectContext];
    }else{
        context = [[CoreDataController sharedInstance] backgroundManagedObjectContext];
    }
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"T_Fuelcons"];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"iD == %@", self.iD];
    [request setPredicate:predicate];
    NSArray *fetchedData = [context executeFetchRequest:request error:&error];
    
    T_Fuelcons *logData = [fetchedData firstObject];
    
    if(!logData){
       // NSLog(@"Log id did not match!");
    }
    NSFetchRequest *vehRequest = [[NSFetchRequest alloc] initWithEntityName:@"Veh_Table"];
    NSError *vehErr;
    NSPredicate *vehPredicate = [NSPredicate predicateWithFormat:@"vehid == %@", self.vehid];
    [vehRequest setPredicate:vehPredicate];
    NSArray *vehArray = [context executeFetchRequest:vehRequest error:&vehErr];
    
    Veh_Table *vehData = [vehArray firstObject];
    
    if(logData != nil){
        
        //First delete receipt from users documents directory (if it exists)
        if(logData.receipt.length > 0){
            
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *docPath = [paths firstObject];
            NSString *receiptName = logData.receipt;
            
            NSString *completeImgPath = [docPath stringByAppendingString:[NSString stringWithFormat:@"/%@", receiptName]];
            NSError *error;
            
            BOOL imageExist = [fileManager fileExistsAtPath:completeImgPath];
            
            if(imageExist){
                
                [fileManager removeItemAtPath:completeImgPath error:&error];
            }
        }
        
        [def setObject:vehData.vehid forKey:@"fillupid"];
        
        [context deleteObject:logData];
    }
    
    if ([context hasChanges])
    {
        BOOL saved = [context save:&error];
        if (!saved) {
            // do some real error handling
            //CLSLog(@“Could not save Data due to %@“, error);
        }
        if(contextType == 1){
            
          //  NSLog(@"Context Saved");
            [[CoreDataController sharedInstance] saveMasterContext];
        }else{
            
         //   NSLog(@"Context Saved in BG");
            [[CoreDataController sharedInstance] saveBackgroundContext];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[CoreDataController sharedInstance] saveMasterContext];
        });
    }
    
    [def setObject:[vehData.iD stringValue] forKey:@"fillupid"];
    commonMethods *common = [[commonMethods alloc]init];
    [common updateDistance:1];
    [common updateConsumption:1];
   
}


-(void)updateservice: (NSDictionary *)dictionary
{
    NSUserDefaults *Def =[NSUserDefaults standardUserDefaults];
    NSString *comparestring = [NSString stringWithFormat:@"%@",[Def objectForKey:@"fillupid"]];
    
    NSString *Service = [dictionary valueForKey:@"SERVICE_TYPE"];
    NSString *odometer = [dictionary valueForKey:@"ODO"];
   
    NSNumber *odoNum = @([odometer floatValue]);

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd-MMM-yyyy"];
    NSTimeInterval dateTime = [[dictionary valueForKey:@"DATE"] doubleValue] / 1000;
    NSString *dateString = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:dateTime] ];
    
    NSDate *date = [formatter dateFromString:dateString];
    
    NSArray* selServices = [Service componentsSeparatedByString:@","];
    
    NSManagedObjectContext *context = [[CoreDataController sharedInstance] backgroundManagedObjectContext];
    NSError *err;
    NSFetchRequest *requset=[[NSFetchRequest alloc] initWithEntityName:@"Services_Table"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"vehid == %@ AND type==1",comparestring];
    [requset setPredicate:predicate];
    NSArray *datavalue=[context executeFetchRequest:requset error:&err];
    
    for ( Services_Table *service in datavalue)
    {
        
        for (NSString* selServiceName in selServices ) {
            if([service.serviceName isEqualToString:selServiceName])
            {
                service.lastOdo = odoNum;
                service.lastDate =  date;
            if ([context hasChanges])
                {
                    BOOL saved = [context save:&err];
                    if (!saved) {
                        // do some real error handling
                        //CLSLog(@“Could not save Data due to %@“, error);
                    }
                    [[CoreDataController sharedInstance] saveBackgroundContext];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[CoreDataController sharedInstance] saveMasterContext];
                });
            }
        }
        
    }
    
}

-(void)getOdoServicesWithOdo: (float)odo {
    
    NSManagedObjectContext *context = [[CoreDataController sharedInstance] backgroundManagedObjectContext];
    NSError *err;
    NSUserDefaults *Def =[NSUserDefaults standardUserDefaults];
    NSString *comparestring = [NSString stringWithFormat:@"%@",[Def objectForKey:@"fillupid"]];
    
    NSFetchRequest *requset=[[NSFetchRequest alloc] initWithEntityName:@"Services_Table"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"vehid==%@ AND (type==1 OR type==2)",comparestring];
    
    [requset setPredicate:predicate];
    NSArray *datavalue=[context executeFetchRequest:requset error:&err];
    NSDateFormatter *formater=[[NSDateFormatter alloc] init];
    [formater setDateFormat:@"dd-MMM-yyyy"];
    
    
    NSMutableArray *serviceArray = [[NSMutableArray alloc]init];
    for(Services_Table *fuelrecord in datavalue)
    {
        if(odo >= ([fuelrecord.dueMiles floatValue]+ [fuelrecord.lastOdo floatValue]) && [fuelrecord.dueMiles floatValue]!=0) {
            NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
            [dictionary setValue:fuelrecord.vehid forKey:@"vehid"];
            [dictionary setValue:[formater stringFromDate:fuelrecord.lastDate] forKey:@"lastdate"];
            [dictionary setValue:fuelrecord.serviceName forKey:@"name"];
            [dictionary setValue:fuelrecord.recurring  forKey:@"recurring"];
            [dictionary setValue:fuelrecord.type forKey:@"type"];
            [dictionary setValue:fuelrecord.dueDays forKey:@"duedays"];
            [dictionary setValue:fuelrecord.dueMiles forKey:@"duemiles"];
            [serviceArray addObject:dictionary];
            
            NSString* jrnKey = [[[dictionary objectForKey:@"name"] stringByAppendingString:@","] stringByAppendingString:[[NSUserDefaults standardUserDefaults]objectForKey:@"vehname"]];
            
            [[JRNLocalNotificationCenter defaultCenter] cancelLocalNotificationForKey:jrnKey];
            //NSString *noti_msg_veh = @"Overdue for";
            [[JRNLocalNotificationCenter defaultCenter] postNotificationOn:[NSDate dateWithTimeIntervalSinceNow:1] forKey:jrnKey alertBody:[NSString stringWithFormat:@"%@ %@ %@",[dictionary objectForKey:@"name"], NSLocalizedString(@"noti_msg_veh", @"Overdue for"),[[NSUserDefaults standardUserDefaults]objectForKey:@"vehname"]] alertAction:@"Open" soundName:nil launchImage:nil userInfo:@{@"time":[NSString stringWithFormat:@"%@ Overdue for %@",[dictionary objectForKey:@"name"],[[NSUserDefaults standardUserDefaults]objectForKey:@"vehname"]]} badgeCount:1 repeatInterval:NO category:nil];
            
            [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"showPage"];

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
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [[CoreDataController sharedInstance] saveMasterContext];
    });
}


@end
