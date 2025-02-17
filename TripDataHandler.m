//
//  TripDataHandler.m
//  FuelBuddy
//
//  Created by Nikhil on 28/05/18.
//  Copyright © 2018 Oraganization. All rights reserved.
//

#import "TripDataHandler.h"
#import "CoreDataController.h"
#import "Veh_Table.h"
#import "T_Trip.h"
#import "commonMethods.h"

@implementation TripDataHandler

-(void)addTrip:(int)contextType{
    
    NSManagedObjectContext *context;
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    if(contextType == 1){
        context = [[CoreDataController sharedInstance] newManagedObjectContext];
    }else{
        context = [[CoreDataController sharedInstance] backgroundManagedObjectContext];
    }
    
    //from driver
    NSFetchRequest *vehRequest = [[NSFetchRequest alloc] initWithEntityName:@"Veh_Table"];
    NSError *vehErr;
    NSPredicate *vehPredicate = [NSPredicate predicateWithFormat:@"vehid == %@", self.vehId];
    [vehRequest setPredicate:vehPredicate];
    NSArray *vehArray = [context executeFetchRequest:vehRequest error:&vehErr];
    
    Veh_Table *vehData = [vehArray firstObject];
    
    T_Trip *tripData = [NSEntityDescription insertNewObjectForEntityForName:@"T_Trip" inManagedObjectContext:context];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd-MMM-yyyy hh:mm a"];
    
    NSDate *depDate;
    if(self.depDate != nil || ![self.depDate  isEqual: @""] ||
       ![self.depDate   isEqual: @"0.00"]){
        
        NSString *thisDate = [NSString stringWithFormat:@"%@", self.depDate];
        NSTimeInterval depDateTime = [thisDate doubleValue] / 1000;
        NSString *dateString = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:depDateTime]];
        depDate = [formatter dateFromString:dateString];
    }
    else {
        depDate = nil;
    }
    
    NSError *err;
    NSDate *arrDate;
    //NSLog(@"arrDate is : %f", [[dictionary valueForKey:@"CONSUMPTION"] floatValue]);
    if(self.arrDate != nil || ![self.arrDate  isEqual: @""] ||
       ![self.arrDate  isEqual: @"0"]){
        
        NSString *thisDate = [NSString stringWithFormat:@"%@", self.arrDate];
        NSTimeInterval arrDateTime = [thisDate doubleValue] / 1000;
        NSString *arrDateString = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:arrDateTime]];
        arrDate = [formatter dateFromString:arrDateString];
        
        if(arrDateTime != 0){
            tripData.arrDate = arrDate;
        }
    }
    
    tripData.vehId = [vehData.iD stringValue];
    tripData.iD = @([self.iD intValue]);
    tripData.depOdo = @([self.depOdo floatValue]);
    tripData.arrOdo = @([self.arrOdo floatValue]);
    
    if(self.taxDedn != nil){
        
        tripData.taxDedn = @([self.taxDedn floatValue]);
    }
    
    if(self.arrLocn != nil){
        
        tripData.arrLocn = self.arrLocn;
    }
    
    if(self.depLocn != nil){
        
        tripData.depLocn = self.depLocn;
    }
    
    if(self.notes != nil ){
        
        tripData.notes = self.notes;
    }
    
    if(self.tollAmt != nil){
        
        tripData.tollAmt = @([self.tollAmt floatValue]);
    }
    
    tripData.tripType = self.tripType;
    tripData.depDate = depDate;
    
    if(self.parkingAmt != nil){
        
        tripData.parkingAmt = @([self.parkingAmt floatValue]);
    }
    
    //If arrOdo is not there, set incomplete trip
    if([self.arrOdo floatValue] == 0.0){
        tripData.tripComplete = NO;
        
    } else {
        
        tripData.tripComplete = YES;
    }
    
    tripData.depLongitude = @([self.depLongitude floatValue]);
    tripData.depLatitude = @([self.depLatitude floatValue]);
    tripData.arrLongitude = @([self.arrLongitude floatValue]);
    tripData.arrLatitude = @([self.arrLatitude floatValue]);
    
    if ([context hasChanges])
    {
        BOOL saved = [context save:&err];
        if (!saved) {
            // do some real error handling
            //CLSLog(@“Could not save Data due to %@“, error);
        }
        if(contextType == 1){
            [def setObject:self.iD forKey:@"maxFuelID"];
            [[CoreDataController sharedInstance] saveMasterContext];
        }else{
            [def setObject:self.iD forKey:@"maxFuelID"];
            [[CoreDataController sharedInstance] saveBackgroundContext];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [[CoreDataController sharedInstance] saveMasterContext];
        });
    }
    
}

-(void)editTrip:(NSDictionary *)editDict :(int)contextType{
    
    NSManagedObjectContext *context;
    NSError *error;
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    if(contextType == 1){
        context = [[CoreDataController sharedInstance] newManagedObjectContext];
    }else{
        context = [[CoreDataController sharedInstance] backgroundManagedObjectContext];
    }
    
    //NSLog(@"userinfo :- %@",editDict);
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"T_Trip"];
    int logId = [[editDict objectForKey:@"id"] intValue];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"iD == %i", logId];
    [request setPredicate:predicate];
    NSArray *fetchedData = [context executeFetchRequest:request error:&error];
    
    T_Trip *tripData = [fetchedData firstObject];
    
    
    NSFetchRequest *vehRequest = [[NSFetchRequest alloc] initWithEntityName:@"Veh_Table"];
    NSError *vehErr;
    NSPredicate *vehPredicate = [NSPredicate predicateWithFormat:@"vehid == %@", [editDict objectForKey:@"vehid"]];
    [vehRequest setPredicate:vehPredicate];
    NSArray *vehArray = [context executeFetchRequest:vehRequest error:&vehErr];
    
    Veh_Table *vehData = [vehArray firstObject];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd-MMM-yyyy hh:mm a"];
    
    NSDate *depDate;
    if([editDict objectForKey:@"date"] != nil || ![[editDict objectForKey:@"date"]  isEqualToString: @""] ||
       ![[editDict objectForKey:@"date"] isEqualToString: @"0.00"]){
        
        NSString *thisDate = [NSString stringWithFormat:@"%@", [editDict objectForKey:@"date"]];
        NSTimeInterval depDateTime = [thisDate doubleValue] / 1000;
        NSString *dateString = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:depDateTime]];
        depDate = [formatter dateFromString:dateString];
    }else {
        depDate = nil;
    }
    
    NSDate *arrDate;
    NSError *err;
    if([editDict objectForKey:@"octane"] != nil || ![[editDict objectForKey:@"octane"]  isEqualToString: @""] ||
       ![[editDict objectForKey:@"octane"]  isEqualToString: @"0"]){
        
        NSString *thisDate = [NSString stringWithFormat:@"%@", [editDict objectForKey:@"octane"]];
        NSTimeInterval arrDateTime = [thisDate doubleValue] / 1000;
        NSString *arrDateString = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:arrDateTime]];
        arrDate = [formatter dateFromString:arrDateString];
    } else {
        
        [formatter setDateFormat:@"n/a"];
        arrDate = [formatter dateFromString:@""];
        
    }
    tripData.vehId = [vehData.iD stringValue];
    tripData.iD = @([[editDict valueForKey:@"id"] intValue]);
    tripData.depOdo = @([[editDict valueForKey:@"odo"] floatValue]);
    tripData.arrOdo = @([[editDict valueForKey:@"qty"] floatValue]);
    
    if([editDict valueForKey:@"qty"] != nil){
        
        tripData.taxDedn = @([[editDict valueForKey:@"cost"] floatValue]);
    }
    
    if([editDict valueForKey:@"qty"] != nil){
        
        tripData.arrLocn = [editDict valueForKey:@"fillStation"];
    }
    
    if([editDict valueForKey:@"fuelBrand"] != nil){
        
        tripData.depLocn = [editDict valueForKey:@"fuelBrand"];
    }
    
    if([editDict valueForKey:@"notes"] != nil ){
        
        tripData.notes = [editDict valueForKey:@"notes"];
    }
    
    if([editDict valueForKey:@"year"] != nil){
        
        tripData.tollAmt = @([[editDict valueForKey:@"year"] floatValue]);
    }
    tripData.tripType = [editDict valueForKey:@"serviceType"];
    tripData.depDate = depDate;
    tripData.arrDate = arrDate;
    if([editDict valueForKey:@"OT"] != nil){
        
        tripData.parkingAmt = @([[editDict valueForKey:@"OT"] floatValue]);
    }
    
    //If arrOdo is not there, set incomplete trip
    if([[editDict valueForKey:@"qty"] floatValue] == 0.0){
        tripData.tripComplete = NO;
        
    } else {
       
        tripData.tripComplete = YES;
    }
    
    tripData.depLongitude = @([self.depLongitude floatValue]);
    tripData.depLatitude = @([self.depLatitude floatValue]);
    tripData.arrLongitude = @([self.arrLongitude floatValue]);
    tripData.arrLatitude = @([self.arrLatitude floatValue]);
    
    if ([context hasChanges])
    {
        BOOL saved = [context save:&err];
        if (!saved) {
            // do some real error handling
            //CLSLog(@“Could not save Data due to %@“, error);
        }
        if(contextType == 1){
            [def setObject:[editDict objectForKey:@"id"] forKey:@"maxFuelID"];
            [[CoreDataController sharedInstance] saveMasterContext];
        }else{
            [def setObject:[editDict objectForKey:@"id"] forKey:@"maxFuelID"];
            [[CoreDataController sharedInstance] saveBackgroundContext];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [[CoreDataController sharedInstance] saveMasterContext];
        });
    }
    
}
-(void)deleteTrip:(int)contextType{
    
    NSManagedObjectContext *context;
    NSError *error;
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    if(contextType == 1){
        context = [[CoreDataController sharedInstance] newManagedObjectContext];
    }else{
        context = [[CoreDataController sharedInstance] backgroundManagedObjectContext];
    }
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"T_Trip"];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"iD == %@", self.iD];
    [request setPredicate:predicate];
    NSArray *fetchedData = [context executeFetchRequest:request error:&error];
    
    T_Trip *tripData = [fetchedData firstObject];
  
    //So it is record from T_Trip table, delete from T_Trip table
    if(tripData != nil){
     
       [def setObject:tripData.iD forKey:@"fillupid"];
       [context deleteObject:tripData];
     }
     
    if ([context hasChanges])
    {
        BOOL saved = [context save:&error];
        if (!saved) {
            // do some real error handling
            //CLSLog(@“Could not save Data due to %@“, error);
        }
        if(contextType == 1){
            
           // NSLog(@"Context Saved");
            [[CoreDataController sharedInstance] saveMasterContext];
        }else{
            
          //  NSLog(@"Context Saved in BG");
            [[CoreDataController sharedInstance] saveBackgroundContext];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[CoreDataController sharedInstance] saveMasterContext];
        });
    }
    
     commonMethods *common = [[commonMethods alloc]init];
    
     [common updateDistance:1];
     [common updateConsumption:1];
     
   
}

@end
