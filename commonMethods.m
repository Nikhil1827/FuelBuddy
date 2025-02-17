//
//  commonMethods.m
//  FuelBuddy
//
//  Created by Swapnil on 19/06/17.
//  Copyright © 2017 Oraganization. All rights reserved.
//

#import "commonMethods.h"
#import "AppDelegate.h"
#import "T_Fuelcons.h"
#import "Veh_Table.h"
#import "T_Trip.h"
#import "Friends_Table.h"
#import "AddTripViewController.h"
#import "AddFillupViewController.h"
#import "Sync_Table.h"
#import "Services_Table.h"
#import "Reachability.h"
#import "QNSURLConnection.h"
#import "WebServiceURL's.h"
#import "Loc_Table.h"
#import "ServiceViewController.h"
#import "LogViewController.h"
#import "JRNLocalNotificationCenter.h"
#import "SettingsViewController.h"
#import "CoreDataController.h"
#import <Crashlytics/Crashlytics.h>
#import "MBProgressHUD.h"
#import "CheckReachability.h"
#import "SERVICE_CENTER_RATING+CoreDataClass.h"
#import "Sync_Table.h"

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0)

@interface commonMethods ()
{
    float prevOdo;
    NSString *recOrder;
    NSMutableDictionary *dataDictionary;
    NSMutableArray *mainArray;
    NSString *sendByEmail;
    NSString *sendByName;
    bool sameRecord;
}
@end

@implementation commonMethods

//Nikhil_BUG_163 cons value updated separatly if odo is maxOdo
-(void)updateConsumptionMaxOdo{
    
    NSManagedObjectContext *contex = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSError *err;
    NSUserDefaults *Def =[NSUserDefaults standardUserDefaults];
    NSString *comparestring = [NSString stringWithFormat:@"%@",[Def objectForKey:@"fillupid"]];
    
    NSFetchRequest *requset=[[NSFetchRequest alloc] initWithEntityName:@"T_Fuelcons"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"vehid==%@ AND type=0",comparestring];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"odo"
                                                                   ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [requset setPredicate:predicate];
    [requset setSortDescriptors:sortDescriptors];
    
    
    NSArray *datavalue=[contex executeFetchRequest:requset error:&err];
    
    float curr_qty = 0;
    float curr_dist = 0;
    float prev_qty = 0;
    float prev_dist = 0;
    float dist_fact= 1;
    float vol_fact =1;
    
    NSString *dist_unit =[[NSUserDefaults standardUserDefaults]objectForKey:@"dist_unit"];
    NSString *vol_unit = [[NSUserDefaults standardUserDefaults]objectForKey:@"vol_unit"];
    NSString *con_unit = [[NSUserDefaults standardUserDefaults]objectForKey:@"con_unit"];
    
    if([con_unit hasPrefix:@"m"] && [dist_unit isEqualToString:NSLocalizedString(@"disp_kilometers", @"Kilometers")])
    {
        dist_fact =0.621;
    }
    
    else if(![con_unit hasPrefix:@"m"] && [dist_unit isEqualToString:NSLocalizedString(@"disp_miles", @"Miles")])
    {
        dist_fact = 1.609;
    }
    
    if([con_unit isEqualToString:NSLocalizedString(@"disp_mpg_us", @"mpg (US)")])
    {
        if([vol_unit isEqualToString:NSLocalizedString(@"disp_litre", @"Litre")])
        {
            vol_fact=0.264;
        }
        else if ([vol_unit isEqualToString:NSLocalizedString(@"disp_gal_uk", @"Gallon (UK)")])
        {
            vol_fact = 1.201;
        }
    }
    
    else  if([con_unit isEqualToString:NSLocalizedString(@"disp_mpg_uk", @"mpg (UK)")])
    {
        if([vol_unit isEqualToString:NSLocalizedString(@"disp_litre", @"Litre")])
        {
            vol_fact=0.22;
        }
        else if ([vol_unit isEqualToString:NSLocalizedString(@"disp_gal_us", @"Gallon (US)")])
        {
            vol_fact = 0.833;
        }
    }
    
    else if([con_unit isEqualToString:NSLocalizedString(@"disp_lp100kms", @"L/100km")] || [con_unit isEqualToString:@"km/L"])
    {
        if([vol_unit isEqualToString:NSLocalizedString(@"disp_gal_uk", @"Gallon (UK)")])
        {
            vol_fact= 4.546;
        }
        else if ([vol_unit isEqualToString:NSLocalizedString(@"disp_gal_us", @"Gallon (US)")])
        {
            vol_fact = 3.785;
        }
        
    }
    
    
        T_Fuelcons *record = [datavalue firstObject];
        T_Fuelcons *previousRecord;
        if(datavalue.count > 1){
           previousRecord  = [datavalue objectAtIndex:1];
        }
    
        if([record.pfill  isEqual: @1] || [record.mfill  isEqual: @1]){
                record.cons = NULL;
        }else if ([previousRecord.pfill isEqual:@1] || [previousRecord.mfill isEqual:@1]){
                [self updateConsumption:0];
        }else{
   
                curr_qty = prev_qty+[record.qty floatValue];
        
                curr_dist = prev_dist+[record.dist floatValue];
        
                prev_qty = 0;
        
                prev_dist = 0;
       
                if(curr_qty!=0)
                    {
                      float eff = (curr_dist * dist_fact)/(curr_qty*vol_fact);
                      if(isnan(eff))
                      {
                         eff=0;
                      }
                     else
                      {
                         record.cons= @(eff);
                      }
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

-(void)updateConsumption: (int)contextStatus{

    NSManagedObjectContext *contex;
    
    //If contextStatus = 1, req for save is coming from sync. So use background context
    if(contextStatus == 1){
        
        contex = [[CoreDataController sharedInstance] backgroundManagedObjectContext];
    } else {
        
        //use main context
        contex = [[CoreDataController sharedInstance] newManagedObjectContext];
    }
        NSError *err;
        NSUserDefaults *Def =[NSUserDefaults standardUserDefaults];
        NSString *comparestring = [NSString stringWithFormat:@"%@",[Def objectForKey:@"fillupid"]];
        
        NSFetchRequest *requset=[[NSFetchRequest alloc] initWithEntityName:@"T_Fuelcons"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"vehid==%@ AND type=0",comparestring];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"odo"
                                                                       ascending:YES];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
        [requset setPredicate:predicate];
        [requset setSortDescriptors:sortDescriptors];
        
        
        NSArray *datavalue=[contex executeFetchRequest:requset error:&err];
        
        float curr_qty = 0;
        float curr_dist = 0;
        float prev_qty = 0;
        float prev_dist = 0;
        BOOL  firstFullFillUp = false;
        float dist_fact= 1;
        float vol_fact =1;
        
        NSString *dist_unit =[[NSUserDefaults standardUserDefaults]objectForKey:@"dist_unit"];
        NSString *vol_unit = [[NSUserDefaults standardUserDefaults]objectForKey:@"vol_unit"];
        NSString *con_unit = [[NSUserDefaults standardUserDefaults]objectForKey:@"con_unit"];
        
        if([con_unit hasPrefix:@"m"] && [dist_unit isEqualToString:NSLocalizedString(@"disp_kilometers", @"Kilometers")])
        {
            dist_fact =0.621;
        }
        
        else if(![con_unit hasPrefix:@"m"] && [dist_unit isEqualToString:NSLocalizedString(@"disp_miles", @"Miles")])
        {
            dist_fact = 1.609;
        }
        
        if([con_unit isEqualToString:NSLocalizedString(@"disp_mpg_us", @"mpg (US)")])
        {
            if([vol_unit isEqualToString:NSLocalizedString(@"disp_litre", @"Litre")])
            {
                vol_fact=0.264;
            }
            else if ([vol_unit isEqualToString:NSLocalizedString(@"disp_gal_uk", @"Gallon (UK)")])
            {
                vol_fact = 1.201;
            }
        }
        
        else  if([con_unit isEqualToString:NSLocalizedString(@"disp_mpg_uk", @"mpg (UK)")])
        {
            if([vol_unit isEqualToString:NSLocalizedString(@"disp_litre", @"Litre")])
            {
                vol_fact=0.22;
            }
            else if ([vol_unit isEqualToString:NSLocalizedString(@"disp_gal_us", @"Gallon (US)")])
            {
                vol_fact = 0.833;
            }
        }
        
        else if([con_unit isEqualToString:NSLocalizedString(@"disp_lp100kms", @"L/100km")] || [con_unit isEqualToString:@"km/L"])
        {
            if([vol_unit isEqualToString:NSLocalizedString(@"disp_gal_uk", @"Gallon (UK)")])
            {
                vol_fact= 4.546;
            }
            else if ([vol_unit isEqualToString:NSLocalizedString(@"disp_gal_us", @"Gallon (US)")])
            {
                vol_fact = 3.785;
            }
            
        }
        
        //Missed fillup correction
        
        for(int i=0;i<datavalue.count;i++)
        {
            T_Fuelcons *record = [datavalue objectAtIndex:i];
            if([record.pfill isEqual:@(1)] )
            {
                
                curr_dist = [record.dist floatValue];
                
                //first record or missed fill-up set consumption to NULL
                if(curr_dist==0 || [record.mfill isEqual:@(1) ]){
                    
                    record.cons= NULL;
                    
                    if ([contex hasChanges])
                    {
                        if(contextStatus==1)
                        {
                            BOOL saved = [contex save:&err];
                            if (!saved) {
                                // do some real error handling
                                //CLSLog(@“Could not save Data due to %@“, error);
                            }
                            [[CoreDataController sharedInstance] saveBackgroundContext];
                            [[CoreDataController sharedInstance] saveMasterContext];
                        }else
                        {
                            BOOL saved = [contex save:&err];
                            if (!saved) {
                                // do some real error handling
                                //CLSLog(@“Could not save Data due to %@“, error);
                            }
                            [[CoreDataController sharedInstance] saveMasterContext];
         
                        }
                    }
                    
                }
                else{
                    
                    prev_qty = prev_qty+[record.qty floatValue];
                    
                    prev_dist = prev_dist+[record.dist floatValue];
                    
                    record.cons= @(-1000);
                    if ([contex hasChanges])
                    {
                        if(contextStatus==1)
                        {
                            BOOL saved = [contex save:&err];
                            if (!saved) {
                                // do some real error handling
                                //CLSLog(@“Could not save Data due to %@“, error);
                            }
                            [[CoreDataController sharedInstance] saveBackgroundContext];
                            [[CoreDataController sharedInstance] saveMasterContext];
                        }else
                        {
                            BOOL saved = [contex save:&err];
                            if (!saved) {
                                // do some real error handling
                                //CLSLog(@“Could not save Data due to %@“, error);
                            }
                            [[CoreDataController sharedInstance] saveMasterContext];
                        }
                    }
                }
            }
            
            
            
            //Regular non-partial fill-up
            else
            {
                
                curr_qty = prev_qty+[record.qty floatValue];
                
                curr_dist = prev_dist+[record.dist floatValue];
                
                prev_qty = 0;
                
                prev_dist = 0;
                
                //missed
                if ([record.mfill  isEqual: @(1)]) {
                    record.cons= @0;
                    firstFullFillUp=true;
                }
                //First regular fillup
                else if(curr_dist==0 || firstFullFillUp!=true){
                    
                    record.cons= NULL;
                    firstFullFillUp = true;
                    if ([contex hasChanges])
                    {
                        if(contextStatus==1)
                        {
                            BOOL saved = [contex save:&err];
                            if (!saved) {
                                // do some real error handling
                                //CLSLog(@“Could not save Data due to %@“, error);
                            }
                            [[CoreDataController sharedInstance] saveBackgroundContext];
                            [[CoreDataController sharedInstance] saveMasterContext];
                        }else
                        {
                            BOOL saved = [contex save:&err];
                            if (!saved) {
                                // do some real error handling
                                //CLSLog(@“Could not save Data due to %@“, error);
                            }
                            [[CoreDataController sharedInstance] saveMasterContext];
                        }
                    }
                    
                }
                // not first record
                else{
                    if(curr_qty!=0)
                    {
                        float eff = (curr_dist * dist_fact)/(curr_qty*vol_fact);
                        if(isnan(eff))
                        {
                            eff=0;
                        }
                        else
                        {
                            record.cons= @(eff);

                            if ([contex hasChanges])
                            {
                                if(contextStatus==1)
                                {
                                    BOOL saved = [contex save:&err];
                                    if (!saved) {
                                        // do some real error handling
                                        //CLSLog(@“Could not save Data due to %@“, error);
                                    }
                                    [[CoreDataController sharedInstance] saveBackgroundContext];
                                    [[CoreDataController sharedInstance] saveMasterContext];
                                }else
                                {
                                    BOOL saved = [contex save:&err];
                                    if (!saved) {
                                        // do some real error handling
                                        //CLSLog(@“Could not save Data due to %@“, error);
                                    }
                                   [[CoreDataController sharedInstance] saveMasterContext];
                                    
                                }
                            }
                        }
                    }
                    
                }
                
            }
            
            
        }
        
        
        
        // Replace -1000 by Consumption
        NSArray *reversedarray = [[datavalue reverseObjectEnumerator]allObjects];
        float curr_eff = 0;
        
        float prev_eff = 0;
        for(int i =0;i<reversedarray.count;i++)
        {
            T_Fuelcons *record = [reversedarray objectAtIndex:i];
            curr_eff = [record.cons floatValue];
            
            curr_dist = [record.dist floatValue];
            
            
            
            if(curr_eff==-1000){
                
                if(curr_dist==0){
                    record.cons=NULL;
                }
                else{
                    if(i>0)
                    {
                        T_Fuelcons *record1 = [reversedarray objectAtIndex:i-1];
                        prev_eff=[record1.cons floatValue];
                        record.cons= @(prev_eff);
                        if ([contex hasChanges])
                        {
                            if(contextStatus==1)
                            {
                                BOOL saved = [contex save:&err];
                                if (!saved) {
                                    // do some real error handling
                                    //CLSLog(@“Could not save Data due to %@“, error);
                                }
                                [[CoreDataController sharedInstance] saveBackgroundContext];
                                [[CoreDataController sharedInstance] saveMasterContext];
                            }else
                            {
                                BOOL saved = [contex save:&err];
                                if (!saved) {
                                    // do some real error handling
                                    //CLSLog(@“Could not save Data due to %@“, error);
                                }
                                [[CoreDataController sharedInstance] saveMasterContext];
                            }
                        }
                    }
                    else
                    {
                        record.cons=NULL;
                        
                    }
                }
            }
            else{
                prev_eff = curr_eff;
            }
            
        }
        
    if ([contex hasChanges])
    {
        if(contextStatus==1)
        {
            BOOL saved = [contex save:&err];
            if (!saved) {
                // do some real error handling
                //CLSLog(@“Could not save Data due to %@“, error);
            }
            [[CoreDataController sharedInstance] saveBackgroundContext];
            [[CoreDataController sharedInstance] saveMasterContext];
        }else
        {
            BOOL saved = [contex save:&err];
            if (!saved) {
                // do some real error handling
                //CLSLog(@“Could not save Data due to %@“, error);
            }
            [[CoreDataController sharedInstance] saveMasterContext];
            
        }
    }

}

-(void)updateDistance: (int)contextStatus{
    
    NSUserDefaults *Def =[NSUserDefaults standardUserDefaults];
    NSString *comparestring = [NSString stringWithFormat:@"%@",[Def objectForKey:@"fillupid"]];
    
    NSManagedObjectContext *contex;
    if(contextStatus == 1){
        //BUG_156
        contex = [[CoreDataController sharedInstance] backgroundManagedObjectContext];
    } else {
        
        contex = [[CoreDataController sharedInstance] newManagedObjectContext];
    }
    NSError *err;
    NSFetchRequest *requset=[[NSFetchRequest alloc] initWithEntityName:@"T_Fuelcons"];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"vehid==%@ AND type=0",comparestring];

    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"odo"
                                                                   ascending:YES];
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"stringDate"
                                                                    ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor,sortDescriptor1, nil];
    [requset setPredicate:predicate];
    [requset setSortDescriptors:sortDescriptors];
    NSArray *datavalue=[contex executeFetchRequest:requset error:&err];
    
    for(int i =0;i <datavalue.count;i++)
    {
        T_Fuelcons *currentrecord = [datavalue objectAtIndex:i];
        if(i==0)
        {
            currentrecord.dist = 0;
        }
        else
        {
            T_Fuelcons *previousrecord = [datavalue objectAtIndex:i-1];
            NSString *dist = [NSString stringWithFormat:@"%.2f", [currentrecord.odo floatValue] - [previousrecord.odo floatValue]];
            currentrecord.dist = @([dist floatValue]);

            
        }
        
    }
    
    if ([contex hasChanges])
    {
        if(contextStatus==1)
        {
            BOOL saved = [contex save:&err];
            if (!saved) {
                // do some real error handling
                //CLSLog(@“Could not save Data due to %@“, error);
            }
            [[CoreDataController sharedInstance] saveBackgroundContext];
            [[CoreDataController sharedInstance] saveMasterContext];
        }else
        {
            BOOL saved = [contex save:&err];
            if (!saved) {
                // do some real error handling
                //CLSLog(@“Could not save Data due to %@“, error);
            }
            [[CoreDataController sharedInstance] saveMasterContext];
        }
        [[CoreDataController sharedInstance] saveMasterContext];
    }

}

-(BOOL)checkOdo:(float)iOdo ForDate:(NSDate*)iDate
{
    recOrder=@"";
    
    NSDateFormatter *formatter=[[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd-MMM-yyyy"];
    
    NSDateFormatter* tripFormatter = [[NSDateFormatter alloc] init] ;
    //Swapnil BUG_79
    [tripFormatter setDateFormat:@"dd-MMM-yyyy"];
    
    BOOL valuesOK = false;
    
    if(iOdo>0 && iDate!= nil)
    {
        NSMutableArray *datavalue=[[[NSUserDefaults standardUserDefaults] objectForKey:@"SortedLog"] mutableCopy];
        
        if(datavalue.count>0)
        {
            //Swapnil BUG_76
            NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
            
            //If it is new save dont remove anything from sorted log (as sorted log does not contain new record to be saved)
            //If it is edit fillup remove record which is being edited from sorted log
            if([[def objectForKey:@"editdetails"] mutableCopy] != nil && ![def boolForKey:@"editPageOpen"]){
              
                NSMutableDictionary *selectedRecord = [[def objectForKey:@"editdetails"] mutableCopy];
                NSInteger indexVal = [[selectedRecord valueForKey:@"valueindex"] integerValue];
                [datavalue removeObjectAtIndex:indexVal];
            }
            
            NSDictionary *maxrecord =[datavalue firstObject];
            NSDictionary *minrecord = [datavalue lastObject];
            
            float maxOdo = [[maxrecord objectForKey:@"odo"] floatValue];
            float minOdo = [[minrecord objectForKey:@"odo"] floatValue];
            NSDate *maxDate;
            NSDate *minDate;
            if ([[maxrecord objectForKey:@"type"] integerValue] == 3)
            { //if Trip type data
                maxDate = [tripFormatter dateFromString:[maxrecord objectForKey: @"date"]];
            }
            else
            {//For service/expense and fuel data
                maxDate = [formatter dateFromString:[maxrecord objectForKey: @"date"]];
            }
            
            if ([[minrecord objectForKey:@"type"] integerValue] == 3)
            { //if Trip type data
                minDate = [tripFormatter dateFromString:[minrecord objectForKey: @"date"]];
            }
            else
            {//For service/expense and fuel data
                minDate = [formatter dateFromString:[minrecord objectForKey: @"date"]];
            }
            
            
            //greater odometer and date
            //IF  (Input Odometer and Date > Max Odo and date record)
            if (iOdo >=maxOdo && ([iDate compare: maxDate] == NSOrderedDescending || [iDate compare: maxDate] == NSOrderedSame))
            {
                valuesOK =YES;
                recOrder = @"MAX";
            }
            //if  ( iDate & iOdo < Min(record Date and Odo))
            else  if(iOdo <= minOdo && ([iDate compare: minDate] == NSOrderedAscending || [iDate compare: minDate] == NSOrderedSame )  )
            {
                valuesOK = YES;
                recOrder = @"MIN";
            }
            //less odometer and date
            // max Odo > iOdo & max date > iDate
            else if(maxOdo >= iOdo &&  ([iDate compare: maxDate] == NSOrderedAscending || [iDate compare:maxDate] == NSOrderedSame))
            {
                recOrder = @"BETWEEN";
                NSDictionary *recordPrev; //Upper boundary
                NSDictionary *recordNext; //Lower Boundary
                NSDate *prevDate;
                NSDate *nextDate;
                for (int i= 0; i < datavalue.count; i++)
                {
                    
                    NSDictionary* recordCurrent = [datavalue objectAtIndex:i];
                    float currOdo = [[recordCurrent objectForKey:@"odo"] floatValue];
                    
                    if (currOdo <iOdo )
                    { //found lower boundary record
                        
                        recordNext = recordCurrent;
                        
                        //Get Prev Date
                        if ([[recordPrev objectForKey:@"type"] integerValue] == 3)
                        { //if Trip type data
                            prevDate = [tripFormatter dateFromString:[recordPrev objectForKey: @"date"]];
                        }
                        else
                        {//For service/expense and fuel data
                            prevDate = [formatter dateFromString:[recordPrev objectForKey: @"date"]];
                        }
                        
                        
                        
                        //Get Next Date
                        
                        if ([[recordPrev objectForKey:@"type"] integerValue] == 3)
                        { //if Trip type data
                            nextDate = [tripFormatter dateFromString:[recordNext objectForKey: @"date"]];
                        }
                        else
                        {//For service/expense and fuel data
                            nextDate = [formatter dateFromString:[recordNext objectForKey: @"date"]];
                        }
                        
                        if (([prevDate compare:iDate] ==NSOrderedSame || [prevDate compare:iDate] ==NSOrderedDescending) && ([nextDate compare:iDate] ==NSOrderedSame || [nextDate compare:iDate] ==NSOrderedAscending))
                        {
                            valuesOK = YES;
                        }
                        else
                        {
                            valuesOK = NO;
                            recOrder = @"ERROR";
                            
                        }
                        
                        //Stop looping through once lower limit is found
                        
                        break;
                        
                    }
                    else
                    { //Move current record into prev and loop thru again
                        recordPrev = recordCurrent;
                        prevOdo = [[recordCurrent objectForKey:@"odo"] floatValue];
                        
                        //if looped through all records and still lower limit not found, then there is an issue with the record
                        // recOrder = @"ERROR";
                        // valuesOK = NO;
                        
                    }
                    
                }
                
                
            }
            
        }
        else
        {
            // No data in Sorted Log
            //First record
            valuesOK = YES;
            recOrder = @"MIN";
            
        }
    }
    
    //}
    else
    {
        // iOdo = 0 && iDate = nil
        
//[self showAlert:@"Please select Odometer and Date" message:@""];
        
        valuesOK = NO;
        
    }
    
    
    if (!valuesOK)
    {
        recOrder = @"ERROR";
        valuesOK = NO;
        //Record did not fit into any filter hence ValueOK not set
        //[self showAlert:@"Incorrect Odometer value for Date" message:@""];
        
    }
    [[NSUserDefaults standardUserDefaults] setFloat:prevOdo forKey:@"prevOdom"];
    [[NSUserDefaults standardUserDefaults] setObject:recOrder forKey:@"recordOrder"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return valuesOK;
    
    
}


-(void)getOdoServicesWithOdo: (float)odo {
    
    NSManagedObjectContext *context = [[CoreDataController sharedInstance] backgroundManagedObjectContext];
    NSError *err;
    NSUserDefaults *Def =[NSUserDefaults standardUserDefaults];
    NSString *comparestring = [NSString stringWithFormat:@"%@",[Def objectForKey:@"fillupid"]];
   // UITextField *odometer = (UITextField *)[self.view viewWithTag:2];
    
    NSFetchRequest *requset=[[NSFetchRequest alloc] initWithEntityName:@"Services_Table"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"vehid==%@ AND (type==1 OR type==2)",comparestring];
    
    [requset setPredicate:predicate];
    NSArray *datavalue=[context executeFetchRequest:requset error:&err];
    NSDateFormatter *formater=[[NSDateFormatter alloc] init];
    [formater setDateFormat:@"dd-MMM-yyyy"];
    
    
    NSMutableArray *serviceArray = [[NSMutableArray alloc]init];
    for(Services_Table *fuelrecord in datavalue)
    {
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
        [dictionary setValue:fuelrecord.serviceName forKey:@"name"];

        if(odo >= ([fuelrecord.dueMiles floatValue]+ [fuelrecord.lastOdo floatValue]) && [fuelrecord.dueMiles floatValue]!=0) {
            [dictionary setValue:fuelrecord.vehid forKey:@"vehid"];
            [dictionary setValue:[formater stringFromDate:fuelrecord.lastDate] forKey:@"lastdate"];
            [dictionary setValue:fuelrecord.recurring  forKey:@"recurring"];
            [dictionary setValue:fuelrecord.type forKey:@"type"];
            [dictionary setValue:fuelrecord.dueDays forKey:@"duedays"];
            [dictionary setValue:fuelrecord.dueMiles forKey:@"duemiles"];
            [serviceArray addObject:dictionary];
            
            NSString* jrnKey = [[[dictionary objectForKey:@"name"] stringByAppendingString:@","] stringByAppendingString:[[NSUserDefaults standardUserDefaults]objectForKey:@"vehname"]];
            dispatch_async(dispatch_get_main_queue(), ^{

                [[JRNLocalNotificationCenter defaultCenter] cancelLocalNotificationForKey:jrnKey];
                //NSString *noti_msg_veh = @"Overdue for";
                [[JRNLocalNotificationCenter defaultCenter] postNotificationOn:[NSDate dateWithTimeIntervalSinceNow:1] forKey:jrnKey alertBody:[NSString stringWithFormat:@"%@ %@ %@",[dictionary objectForKey:@"name"], NSLocalizedString(@"noti_msg_veh", @"Overdue for"),[[NSUserDefaults standardUserDefaults]objectForKey:@"vehname"]] alertAction:@"Open" soundName:nil launchImage:nil userInfo:@{@"time":[NSString stringWithFormat:@"%@ Overdue for %@",[dictionary objectForKey:@"name"],[[NSUserDefaults standardUserDefaults]objectForKey:@"vehname"]]} badgeCount:1 repeatInterval:NO category:nil];
                [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"showPage"];
            });

        }

        int dueDays = [fuelrecord.dueDays intValue];

        if(dueDays > 0){

            NSString* jrnKey = [[[dictionary objectForKey:@"name"] stringByAppendingString:@","] stringByAppendingString:[[NSUserDefaults standardUserDefaults]objectForKey:@"vehname"]];

            dispatch_async(dispatch_get_main_queue(), ^{

                [[JRNLocalNotificationCenter defaultCenter] cancelLocalNotificationForKey:jrnKey];
            });

            NSDateComponents *dateComponents = [NSDateComponents new];
            dateComponents.day = [fuelrecord.dueDays integerValue];
            NSDate *dueDate = [[NSCalendar currentCalendar]dateByAddingComponents:dateComponents
                                                                           toDate: fuelrecord.lastDate
                                                                          options:0];

            NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
            NSDateComponents *timeComponents = [calendar components:( NSCalendarUnitYear |  NSCalendarUnitMonth |  NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond )
                                                           fromDate:dueDate];
            [timeComponents setHour:7];
            [timeComponents setMinute:00];
            [timeComponents setSecond:0];

            NSDate *dtFinal = [calendar dateFromComponents:timeComponents];

            NSString* alertBody = [NSString stringWithFormat:@"%@ %@ %@",fuelrecord.serviceName, NSLocalizedString(@"noti_msg_veh", @"Overdue for"), [[NSUserDefaults standardUserDefaults]objectForKey:@"vehname"]];

            dispatch_async(dispatch_get_main_queue(), ^{

                [[JRNLocalNotificationCenter defaultCenter] postNotificationOn:dtFinal                                                            forKey:jrnKey alertBody:[NSString stringWithFormat:@"Pull or swipe to interact. %@", alertBody]
                                                                   alertAction:@"Open"
                                                                     soundName:nil
                                                                   launchImage:nil
                                                                      userInfo:@{@"DueDate": dtFinal}
                                                                    badgeCount:0
                                                                repeatInterval:NSCalendarUnitDay
                                                                      category:@"DayReminder"];

                [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"showPage"];
            });
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


-(void)updateservice: (NSDictionary *)dictionary
{
    NSUserDefaults *Def =[NSUserDefaults standardUserDefaults];
    NSString *comparestring = [NSString stringWithFormat:@"%@",[Def objectForKey:@"fillupid"]];
    
    NSString *Service = [dictionary valueForKey:@"SERVICE_TYPE"];
    NSString *odometer = [dictionary valueForKey:@"ODO"];
    
    //UITextField *Service = (UITextField *)[self.view viewWithTag:3];
    //UITextField *odometer = (UITextField *)[self.view viewWithTag:2];
//    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
//    f.numberStyle = NSNumberFormatterDecimalStyle;
    NSNumber *odoNum = @([odometer floatValue]);
    
//    UITextField *date = (UITextField *)[self.view viewWithTag:1];
//    NSDateFormatter *formater=[[NSDateFormatter alloc] init];
//    [formater setDateFormat:@"dd-MMM-yyyy"];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd-MMM-yyyy"];
    NSTimeInterval dateTime = [[dictionary valueForKey:@"DATE"] doubleValue] / 1000;
    NSString *dateString = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:dateTime] ];
    
    NSDate *date = [formatter dateFromString:dateString];
    NSLog(@"common Methods line number 889:- %@",date);
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
                    [[CoreDataController sharedInstance] saveMasterContext];
                }
            }
        }
        
        
        
    }
    
    
}

//NIKHIL BUG_151
-(NSNumberFormatter *)decimalFormatter {
    
    NSNumberFormatter *dformatter = [NSNumberFormatter new];
    [dformatter setRoundingMode:NSNumberFormatterRoundFloor];
    [dformatter setMaximumFractionDigits:3];
    [dformatter setPositiveFormat:@"0.###"];
    return dformatter;
}



#pragma mark GENERAL METHODS

//Swapnil NEW_6

- (NSDictionary *)getDayMonthYrFromStringDate: (NSDate *)stringDate{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    [formatter setDateFormat:@"dd"];
    NSString *day = [formatter stringFromDate:stringDate];
    
    if(day != nil){
        [dictionary setObject:day forKey:@"day"];
    } else {
        [dictionary setObject:@"" forKey:@"day"];
    }
    
    [formatter setDateFormat:@"MM"];
    NSString *month = [formatter stringFromDate:stringDate];
    
    if(month != nil){
        [dictionary setObject:month forKey:@"month"];
    } else {
        [dictionary setObject:@"" forKey:@"month"];
    }
    
    [formatter setDateFormat:@"yyyy"];
    NSString *year = [formatter stringFromDate:stringDate];
    
    if(year != nil){
        [dictionary setObject:year forKey:@"year"];
    } else {
        [dictionary setObject:@"" forKey:@"year"];
    }
    
    [formatter setDateFormat:@"hh"];
    NSString *hours = [formatter stringFromDate:stringDate];
    
    if(hours != nil){
        [dictionary setObject:hours forKey:@"hours"];
    } else {
        [dictionary setObject:@"" forKey:@"hours"];
    }
    
    [formatter setDateFormat:@"mm"];
    NSString *minutes = [formatter stringFromDate:stringDate];
    
    if(minutes != nil){
        [dictionary setObject:minutes forKey:@"minutes"];
    } else {
        [dictionary setObject:@"" forKey:@"minutes"];
    }
    
    NSTimeInterval unixTimeStamp = [stringDate timeIntervalSince1970] * 1000;
    NSString *unixTime = [NSString stringWithFormat:@"%f", unixTimeStamp];
    
    if(unixTime != nil){
        [dictionary setObject:unixTime forKey:@"epochTime"];
    } else {
        [dictionary setObject:@"" forKey:@"epochTime"];
    }
    
    return dictionary;
}

- (void)decodeBase64: (NSData *)base64String toImage: (NSString *)imageName{

    if(base64String.length > 0){

        NSData *imageData = [[NSData alloc] initWithBase64EncodedData:base64String options:NSDataBase64DecodingIgnoreUnknownCharacters];
        UIImage *receiptImage = [UIImage imageWithData:imageData];

        NSData *imgData = UIImagePNGRepresentation(receiptImage);

        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docPath = [paths firstObject];
        NSString *filePath = [docPath stringByAppendingPathComponent:imageName];
        [imgData writeToFile:filePath atomically:YES];
    }

}

+ (UIImage *)imageWithImage:(UIImage *)image
               scaledToSize:(CGSize)newSize{
    
    UIGraphicsBeginImageContext( newSize );
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

-(void)showNotification:(NSString *)alertTitle :(NSString *)alertBody{

    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];

    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc]init];

    content.title = alertTitle;
    content.body = alertBody;
    content.sound = [UNNotificationSound defaultSound];

    UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:1 repeats:NO];

    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"UYlocalNotification" content:content trigger:trigger];

    [center addNotificationRequest:request withCompletionHandler:nil];

    [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"showPage"];

}

-(void)showVehicleNotFoundNotification:(NSString *)alertTitle :(NSString *)alertBody{

    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];

    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc]init];

    content.title = alertTitle;
    content.body = alertBody;
    content.sound = [UNNotificationSound defaultSound];

    UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:1 repeats:NO];

    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"vehicleNotFound" content:content trigger:trigger];

    [center addNotificationRequest:request withCompletionHandler:nil];

    [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"showPage"];

}

-(double)getMaxNoTripOdoForAllVehicles{

    NSManagedObjectContext *context = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSFetchRequest *logRequest = [[NSFetchRequest alloc] initWithEntityName:@"T_Fuelcons"];
    NSError *logErr;

    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"odo"
                                                                   ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];

    [logRequest setSortDescriptors:sortDescriptors];

    NSArray *logResult = [context executeFetchRequest:logRequest error:&logErr];

    T_Fuelcons *record = [logResult firstObject];

    double maxOdo = [record.odo doubleValue];

    return maxOdo;
}

-(double)getMaxNoTripOdoForVehicle: (NSNumber *)vehId{

    NSManagedObjectContext *context = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSFetchRequest *logRequest = [[NSFetchRequest alloc] initWithEntityName:@"T_Fuelcons"];
    NSError *logErr;

    NSString *comparestring = [NSString stringWithFormat:@"%@",vehId];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"vehid==%@",comparestring];
    [logRequest setPredicate:predicate];

    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"odo"
                                                                   ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];

    [logRequest setSortDescriptors:sortDescriptors];

    NSArray *logResult = [context executeFetchRequest:logRequest error:&logErr];

    T_Fuelcons *record = [logResult firstObject];

    double maxOdo = [record.odo doubleValue];

    return maxOdo;
}

-(NSNumber *)getMaxFuelID{

    NSManagedObjectContext *context = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSFetchRequest *logRequest = [[NSFetchRequest alloc] initWithEntityName:@"T_Fuelcons"];
    NSError *logErr;
    NSArray *logResult = [context executeFetchRequest:logRequest error:&logErr];

    NSMutableArray *idArray = [[NSMutableArray alloc] init];

    for(T_Fuelcons *log in logResult){

        [idArray addObject:log.iD];
    }

    NSManagedObjectContext *contex = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSFetchRequest *tripRequest = [[NSFetchRequest alloc] initWithEntityName:@"T_Trip"];
    NSError *tripErr;
    NSArray *tripResult = [contex executeFetchRequest:tripRequest error:&tripErr];

    for(T_Trip *trip in tripResult){

        [idArray addObject:trip.iD];
    }

    NSNumber *maxNumber = [idArray valueForKeyPath:@"@max.self"];

    return maxNumber;
}

#pragma mark CLOUD SYNC METHODS

//Swapnil NEW_6

- (void)saveToCloud:(NSData *)postData urlString: (NSString *)urlString success: (void (^)(NSDictionary *responseDict))success failure: (void (^)(NSError *error))failure{

    NSURL *url = [NSURL URLWithString:urlString];
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    //NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    //NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/JSON" forHTTPHeaderField:@"Content-Type"];
    
    NSError *error;
    
    [request setHTTPBody:postData];
    
    NSURLResponse *response;
    NSError *returnError;
    NSData *responseData = [QNSURLConnection sendSynchronousRequest:request returningResponse:&response error:&returnError];
    dataDictionary = [[NSMutableDictionary alloc] init];
    
    //NSString *dataInString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    //NSLog(@"response data in string : %@", dataInString);
    if(responseData != nil){
        dataDictionary = [NSJSONSerialization JSONObjectWithData:responseData
                                                     options:kNilOptions
                                                       error:&error];
        
        //check for out_of_sync and notify user
        if([[dataDictionary objectForKey:@"message"] isEqualToString:@"out of sync"]){
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"notifyOutOfSync"
                                                                object:nil];
        }

        if([[dataDictionary objectForKey:@"success"] isEqual: @1]){

            //If this is coming from friend (other than syncing do not update localtimestamp)
            if([def boolForKey:@"updateTimeStamp"]){
                NSDate *date = [[NSDate alloc] init];

                [def setObject:date forKey:@"localTimeStamp"];

                [[NSNotificationCenter defaultCenter] postNotificationName:@"timeStamp"
                                                                    object:nil];
            }

        }

      }
    
    if(!returnError){
        
        success(dataDictionary);
    
    }
    else {
        
        failure(returnError);
    }
 
}

//Clears Sync table of phone
- (void)clearPhoneSyncTableWithID:(NSNumber *)rowID tableName:(NSString *)tableName andType:(NSString *)type{
    
    NSManagedObjectContext *context = [[CoreDataController sharedInstance] backgroundManagedObjectContext];
    NSError *error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Sync_Table"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"rowID == %@ AND tableName == %@ AND type == %@", rowID, tableName, type];
    NSError *err;
    [fetchRequest setPredicate:predicate];
    
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    Sync_Table *syncData = [fetchedObjects firstObject];
    
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
    
}

//Clear record from service center tabl;e as well
- (void)clearFromServiceCenterTable:(NSNumber *)rowID{

    NSManagedObjectContext *context = [[CoreDataController sharedInstance] backgroundManagedObjectContext];
    NSError *error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"SERVICE_CENTER_RATING"];
   // NSPredicate *predicate = [NSPredicate predicateWithFormat:@"rowID == %@", rowID];
    NSError *err;
 //   [fetchRequest setPredicate:predicate];

    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];

    SERVICE_CENTER_RATING *serviceData = [fetchedObjects firstObject];

    if(serviceData != nil){

        [context deleteObject:serviceData];
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

//Deleting records from Sync table on CLOUD after being saved on phone
- (int)clearCloudSyncTable: (NSMutableArray *)syncArray{

    NSError *err;
    __block int returnStatus;
    NSData *postDataArray = [NSJSONSerialization dataWithJSONObject:syncArray options:NSJSONWritingPrettyPrinted error:&err];
    [self saveToCloud:postDataArray urlString:kDeleteCloudSyncTableScript success:^(NSDictionary *responseDict) {

        if([[responseDict objectForKey:@"success"] intValue] == 1){
            
            returnStatus = 1;
        } else {
            returnStatus = 0;
        }
        
        
    } failure:^(NSError *error) {

        returnStatus = 0;
    }];

    return returnStatus;
}

//why this is new n not bg context//done!!
//NIKHIL may be crash resloved crash #220
- (void)deleteAllTablesFromDB{
    
    NSManagedObjectContext *context = [[CoreDataController sharedInstance] backgroundManagedObjectContext];
    NSError *vehError;
    
    //Delete all records from Vehicle Table
    NSFetchRequest *vehreq = [[NSFetchRequest alloc] initWithEntityName:@"Veh_Table"];
    NSArray *vehArray = [context executeFetchRequest:vehreq error:&vehError];
    
    for (Veh_Table *vehicles in vehArray) {
        
        [context deleteObject:vehicles];
    }
    
    //Delete all records from Location Table
    NSError *locError;
    NSFetchRequest *locReq = [[NSFetchRequest alloc] initWithEntityName:@"Loc_Table"];
    NSArray *locArray = [context executeFetchRequest:locReq error:&locError];
    
    for (Loc_Table *location in locArray) {
        
        [context deleteObject:location];
    }
    
    //Delete all records from T_Fuelcons Table
    NSError *logError;
    NSFetchRequest *logReq = [[NSFetchRequest alloc] initWithEntityName:@"T_Fuelcons"];
    NSArray *logArray = [context executeFetchRequest:logReq error:&logError];
    
    for (T_Fuelcons *logs in logArray) {
        
        [context deleteObject:logs];
    }
    
    //Delete all records from Trip Table
    NSError *tripError;
    NSFetchRequest *tripReq = [[NSFetchRequest alloc] initWithEntityName:@"T_Trip"];
    NSArray *tripArray = [context executeFetchRequest:tripReq error:&tripError];
    
    for (T_Trip *trips in tripArray) {
        
        [context deleteObject:trips];
    }
    
    //Delete all records from Services Table
    NSError *servError;
    NSFetchRequest *serviceReq = [[NSFetchRequest alloc] initWithEntityName:@"Services_Table"];
    NSArray *serviceArray = [context executeFetchRequest:serviceReq error:&servError];
    
    for (Services_Table *services in serviceArray) {
        
        [context deleteObject:services];
    }
    
    //Delete all records from Sync Table
    NSError *syncTblError;
    NSError *err;
    NSFetchRequest *syncTblReq = [[NSFetchRequest alloc] initWithEntityName:@"Sync_Table"];
    NSArray *syncTblArray = [context executeFetchRequest:syncTblReq error:&syncTblError];
    
    for (Sync_Table *syncData in syncTblArray) {
        
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
    
}

- (void)saveFromCloudToLocalDB: (NSDictionary *)dictionary{
    
    BOOL saveToTableflag = NO;
    
    if([[dictionary objectForKey:@"table"] isEqualToString:@"SETTINGS"]){

        [self performSelectorOnMainThread:@selector(postNotificationWithName:) withObject:@"downloadFinish" waitUntilDone:NO];
                
        saveToTableflag = [self saveSettings:dictionary];
        if(!saveToTableflag){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"failError" object:nil userInfo:@{@"message":@"Failed to download Settings"}];
            return;
        }
    } else if ([[dictionary objectForKey:@"table"] isEqualToString:@"VEH_TABLE"]){
        
        [self performSelectorOnMainThread:@selector(postNotificationWithName:) withObject:@"settingsFinish" waitUntilDone:NO];
        saveToTableflag = [self saveToVehicleTable:dictionary];
        if(!saveToTableflag){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"failError" object:nil userInfo:@{@"message":@"Failed to download Vehicles"}];
            return;
        }
        
    } else if ([[dictionary objectForKey:@"table"] isEqualToString:@"SERVICE_TABLE"]){
        
        saveToTableflag = [self saveToServiceTable:dictionary];
        if(!saveToTableflag){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"failError" object:nil userInfo:@{@"message":@"Failed to download Services"}];
            return;
        }
        
    } else if ([[dictionary objectForKey:@"table"] isEqualToString:@"LOC_TABLE"]){

        [self performSelectorOnMainThread:@selector(postNotificationWithName:) withObject:@"vehicleFinish" waitUntilDone:NO];
        [self saveToLocationTable:dictionary];
        
    } else if ([[dictionary objectForKey:@"table"] isEqualToString:@"LOG_TABLE"]){

        saveToTableflag = [self saveToLogTable:dictionary];

        if(!saveToTableflag){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"failError" object:nil userInfo:@{@"message":@"Some of your data could not be synced. Please contact support-ios@simplyauto.app."}];

            return;
        }
        
    }
    
}

- (void)postNotificationWithName: (NSString *)name{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:name object:nil];
}

//NIKHIL BUG_147
+ (void)startActivitySpinner: (NSString *)labelText {
    // [[self driveService] setAuthorizer:auth];
   AppDelegate *appd = [[AppDelegate alloc]init];
   UIView *topView = appd.topView;

    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UIView *loadingView1 = [[UIView alloc]initWithFrame:CGRectMake(app.result.width/2-50, app.result.height/2-50, 100, 100)];
    loadingView1.backgroundColor = [UIColor colorWithWhite:0. alpha:0.6];
    loadingView1.layer.cornerRadius = 5;
    loadingView1.tag = 101;
    
    UIActivityIndicatorView *activityView=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityView.center = CGPointMake(loadingView1.frame.size.width / 2.0, 35);
    
    [activityView startAnimating];
    activityView.tag = 100;
    [loadingView1 addSubview:activityView];
    
    
    UILabel* lblLoading = [[UILabel alloc]initWithFrame:CGRectMake(3, 48, 100, 50)];
    lblLoading.text = labelText;
    lblLoading.numberOfLines = 2;
    lblLoading.textColor = [UIColor whiteColor];
    lblLoading.font = [UIFont fontWithName:lblLoading.font.fontName size:13];
    lblLoading.textAlignment = NSTextAlignmentCenter;
    
    [loadingView1 addSubview:lblLoading];
    dispatch_async(dispatch_get_main_queue(), ^{
        [topView addSubview:loadingView1];
    });
}
/*
-(void)startHUD{

    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.offset = CGPointMake(0,85);
    AppDelegate *App = [AppDelegate sharedAppDelegate];
    if(App.result.height == 480) {
        hud.offset = CGPointMake(0,120);
    }
    hud.label.text = @"";
    hud.label.textColor = [self colorFromHexStringForHud:@"#FFCA1D"];
    hud.bezelView.backgroundColor = [UIColor clearColor];
    hud.bezelView.alpha =0.6;
}
*/
-(UIColor *)colorFromHexStringForHud:(NSString *)hexString
{
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

#pragma mark VEHICLE add/upd/del

-(BOOL)saveToVehicleTable:(NSDictionary *)dictionary{
    
    if([[dictionary valueForKey:@"type"] isEqualToString:@"add"]){
        
        [self addNewVehicle:dictionary];
        
    } else if ([[dictionary valueForKey:@"type"] isEqualToString:@"edit"]){
        
        [self editVehicle:dictionary];
        
    } else if([[dictionary valueForKey:@"type"] isEqualToString:@"del"]){
        
        [self deleteVehicle:dictionary];
    }
    
    return YES;
}

- (void)addNewVehicle: (NSDictionary *)dictionary{

    NSManagedObjectContext *contex = [[CoreDataController sharedInstance] backgroundManagedObjectContext];
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSError *err;
    Veh_Table *vehData = [NSEntityDescription insertNewObjectForEntityForName:@"Veh_Table" inManagedObjectContext:contex];
    
    vehData.iD = [dictionary valueForKey:@"_ID"];
    
    if([NSNull null] != [dictionary valueForKey:@"MAKE"]){
    
        vehData.make = [dictionary valueForKey:@"MAKE"];
    }
    
    if([NSNull null] != [dictionary valueForKey:@"MODEL"]){
    
        vehData.model = [dictionary valueForKey:@"MODEL"];
    }
    
    if([NSNull null] != [dictionary valueForKey:@"LIC"]){
    
        vehData.lic = [dictionary valueForKey:@"LIC"];
    }
    
    if([NSNull null] != [dictionary valueForKey:@"INSURANCE_NO"]){
    
        vehData.insuranceNo = [dictionary valueForKey:@"INSURANCE_NO"];
    }
    
    if([dictionary valueForKey:@"VEHID"] != nil){
    
        vehData.vehid = [dictionary valueForKey:@"VEHID"];
    }
    
    if([NSNull null] != [dictionary valueForKey:@"VIN"]){
    
        vehData.vin = [dictionary valueForKey:@"VIN"];
    }
    
    if([NSNull null] != [dictionary valueForKey:@"YEAR"]){
    
        vehData.year = [dictionary valueForKey:@"YEAR"];
    }
    
    if([NSNull null] != [dictionary valueForKey:@"CUSTOM_SPECIFICATIONS"]){
    
        vehData.customSpecs = [dictionary valueForKey:@"CUSTOM_SPECIFICATIONS"];
    }
    
    if([NSNull null] != [dictionary valueForKey:@"NOTES"]){
    
        vehData.notes = [dictionary valueForKey:@"NOTES"];
    }
    
    if([NSNull null] != [dictionary valueForKey:@"FUEL_TYPE"]){
        
        vehData.fuel_type = [dictionary valueForKey:@"FUEL_TYPE"];
    }
    
//    vehData.make = [dictionary valueForKey:@"_ID"];
    
    if([NSNull null] != [dictionary valueForKey:@"PICTURE"]){
        //ENH_54 making sync free 1june2018 nikhil // not allowing vehicle images if not pro
        BOOL proUser = [[NSUserDefaults standardUserDefaults] boolForKey:@"isAdDisabled"];
        
        if(proUser){
    
                 NSString *vehPicName = [dictionary valueForKey:@"PICTURE"];
    
                 if(vehPicName != nil && vehPicName.length > 0){
        
                       NSData *imageData = [dictionary valueForKey:@"PIC"];
                       if ((imageData != NULL) && ![imageData isKindOfClass:[NSNull class]])
                       {
                           [self decodeBase64:imageData toImage:vehPicName];
                       }else{

                           NSLog(@"imageData 5 data is nil hence not decoding the imageData");
                       }
                       vehData.picture = vehPicName;
                 }
        }
        
    }
    
    if ([contex hasChanges])
    {
        BOOL saved = [contex save:&err];
        if (!saved) {
            // do some real error handling
            //CLSLog(@“Could not save Data due to %@“, error);
        }
        [[CoreDataController sharedInstance] saveBackgroundContext];
        [[CoreDataController sharedInstance] saveMasterContext];
    }
    [[CoreDataController sharedInstance] saveMasterContext];
    [def setObject:[dictionary valueForKey:@"_ID"] forKey:@"maxVehId"];
    
}

- (void)editVehicle: (NSDictionary *)dictionary{
    
    NSManagedObjectContext *context = [[CoreDataController sharedInstance] backgroundManagedObjectContext];
    //NSUserDefaults *def = [NSUserDefaults standardUserDefaults];

    NSError *err;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Veh_Table"];
    
    NSPredicate *iDPredicate = [NSPredicate predicateWithFormat:@"iD == %@", [dictionary valueForKey:@"_ID"]];
    [request setPredicate:iDPredicate];
    NSArray *fetchedData = [context executeFetchRequest:request error:&err];
    
    if(fetchedData.count>0){

        Veh_Table *vehData = [fetchedData firstObject];

        vehData.iD = [dictionary valueForKey:@"_ID"];

        if([NSNull null] != [dictionary valueForKey:@"MAKE"]){

            vehData.make = [dictionary valueForKey:@"MAKE"];
        }

        if([NSNull null] != [dictionary valueForKey:@"MODEL"]){

            vehData.model = [dictionary valueForKey:@"MODEL"];
        }

        if([NSNull null] != [dictionary valueForKey:@"LIC"]){

            vehData.lic = [dictionary valueForKey:@"LIC"];
        }

        if([NSNull null] != [dictionary valueForKey:@"INSURANCE_NO"]){

            vehData.insuranceNo = [dictionary valueForKey:@"INSURANCE_NO"];
        }

        if([dictionary valueForKey:@"VEHID"] != nil){

            vehData.vehid = [dictionary valueForKey:@"VEHID"];
        }

        if([NSNull null] != [dictionary valueForKey:@"VIN"]){

            vehData.vin = [dictionary valueForKey:@"VIN"];
        }

        if([NSNull null] != [dictionary valueForKey:@"YEAR"]){

            vehData.year = [dictionary valueForKey:@"YEAR"];
        }

        if([NSNull null] != [dictionary valueForKey:@"CUSTOM_SPECIFICATIONS"]){

            vehData.customSpecs = [dictionary valueForKey:@"CUSTOM_SPECIFICATIONS"];
        }

        if([NSNull null] != [dictionary valueForKey:@"NOTES"]){

            vehData.notes = [dictionary valueForKey:@"NOTES"];
        }

        if([NSNull null] != [dictionary valueForKey:@"FUEL_TYPE"]){

            vehData.fuel_type = [dictionary valueForKey:@"FUEL_TYPE"];
        }

        if([NSNull null] != [dictionary valueForKey:@"PICTURE"]){
            //ENH_54 making sync free 1june2018 nikhil // not allowing vehicle images if not pro
            BOOL proUser = [[NSUserDefaults standardUserDefaults] boolForKey:@"isAdDisabled"];

            if(proUser){

                NSString *vehPicName = [dictionary valueForKey:@"PICTURE"];

                if(vehPicName != nil && vehPicName.length > 0){

                    NSData *imageData = [dictionary valueForKey:@"PIC"];
                    if ((imageData != NULL) && ![imageData isKindOfClass:[NSNull class]])
                    {
                        [self decodeBase64:imageData toImage:vehPicName];
                    }else{

                        NSLog(@"imageData 6 data is nil hence not decoding the imageData");
                    }

                    vehData.picture = vehPicName;
                }
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
        [[CoreDataController sharedInstance] saveMasterContext];
    }

    //Prepare dictionary of records to delete from Sync table on CLOUD after it has saved on phone
//    NSMutableDictionary *syncedDictionary = [[NSMutableDictionary alloc] init];
//    NSMutableArray *syncedArray = [[NSMutableArray alloc] init];
//    
//    [syncedDictionary setObject:[dictionary valueForKey:@"table"] forKey:@"tableName"];
//    [syncedDictionary setObject:[dictionary valueForKey:@"_ID"] forKey:@"rowID"];
//    [syncedDictionary setObject:[dictionary valueForKey:@"type"] forKey:@"type"];
//    [syncedDictionary setObject:[def objectForKey:@"UserDeviceId"] forKey:@"androidId"];
//    
//    //Add dictionaries to an array
//    [syncedArray addObject:syncedDictionary];
//    
//    [self clearCloudSyncTable:syncedArray];

    
    
    
}

- (void)deleteVehicle: (NSDictionary *)dictionary{

    NSManagedObjectContext *context = [[CoreDataController sharedInstance] backgroundManagedObjectContext];
    //NSUserDefaults *def = [NSUserDefaults standardUserDefaults];

    NSError *err;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Veh_Table"];
    NSPredicate *iDPredicate = [NSPredicate predicateWithFormat:@"iD == %@", [dictionary valueForKey:@"_ID"]];
    [request setPredicate:iDPredicate];
    NSArray *fetchedData = [context executeFetchRequest:request error:&err];

    if(fetchedData.count>0){

        Veh_Table *vehData = [fetchedData firstObject];
        //    for (Veh_Table *vehData in fetchedData) {
        //
        //        if([vehData.iD integerValue] == [[dictionary valueForKey:@"_ID"] integerValue]){
        //
        //            [context deleteObject:vehData];
        //        }
        //    }

        if(vehData != nil){

            //First delete veh picture from users documents directory (if it exists)
            if(vehData.picture.length > 0){

                NSFileManager *fileManager = [NSFileManager defaultManager];
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *docPath = [paths firstObject];
                NSString *receiptName = vehData.picture;

                NSString *completeImgPath = [docPath stringByAppendingString:[NSString stringWithFormat:@"/%@", receiptName]];
                NSError *error;

                BOOL imageExist = [fileManager fileExistsAtPath:completeImgPath];

                if(imageExist){

                    [fileManager removeItemAtPath:completeImgPath error:&error];
                }
            }

            [context deleteObject:vehData];

            //Server will not give response for deleting records from log table, service table & trip table

            //So, Delete corresponding records for deleted vehicle from T_FUELCONS
            NSError *fuelErr;
            NSFetchRequest *fuelRequest = [[NSFetchRequest alloc] initWithEntityName:@"T_Fuelcons"];
            NSPredicate *fuelPredicate = [NSPredicate predicateWithFormat:@"vehid == %@", [[dictionary valueForKey:@"_ID"] stringValue]];
            [fuelRequest setPredicate:fuelPredicate];
            NSArray *fuelArray = [context executeFetchRequest:fuelRequest error:&fuelErr];

            for (T_Fuelcons *fuelData in fuelArray) {

                [context deleteObject:fuelData];
            }

            //Delete corresponding records for deleted vehicle from Services_Table
            NSError *servErr;
            NSFetchRequest *servRequest = [[NSFetchRequest alloc] initWithEntityName:@"Services_Table"];
            NSPredicate *servPredicate = [NSPredicate predicateWithFormat:@"vehid == %@", [[dictionary valueForKey:@"_ID"] stringValue]];
            [servRequest setPredicate:servPredicate];
            NSArray *serviceArray = [context executeFetchRequest:servRequest error:&servErr];

            for (Services_Table *servicesData in serviceArray) {

                [context deleteObject:servicesData];
            }

            //Delete corresponding records for deleted vehicle from T_Trip table
            NSError *tripErr;
            NSFetchRequest *tripReq = [[NSFetchRequest alloc] initWithEntityName:@"T_Trip"];
            NSPredicate *tripPredicate = [NSPredicate predicateWithFormat:@"vehId == %@", [[dictionary valueForKey:@"_ID"] stringValue]];
            [tripReq setPredicate:tripPredicate];
            NSArray *tripArray = [context executeFetchRequest:tripReq error:&tripErr];

            for (T_Trip *tripData in tripArray) {

                [context deleteObject:tripData];
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
        [[CoreDataController sharedInstance] saveMasterContext];
    }

}

#pragma mark T_FUELCONS add/upd/del

- (BOOL)saveToLogTable:(NSDictionary *)dictionary{

    if([[dictionary valueForKey:@"sync_with"] isEqualToString:@"friend"]){

        NSManagedObjectContext *context =[[CoreDataController sharedInstance] backgroundManagedObjectContext];

       // NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
        NSError *err;

        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Friends_Table"];

        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"email == %@", [dictionary valueForKey:@"uploaded_by"]];
        [request setPredicate:predicate];
        NSArray *fetchedData = [context executeFetchRequest:request error:&err];

        Friends_Table *friendData = [fetchedData firstObject];
        sendByEmail = [dictionary valueForKey:@"uploaded_by"];
        sendByName = friendData.name;


    }
    if ([[dictionary valueForKey:@"type"] isEqualToString:@"del"]){
        
        //deleteRecord is common for types 0,1,2,3
        [self deleteRecord:dictionary];
        
    } else if ([[dictionary valueForKey:@"TYPE"] intValue] == 0 || [[dictionary valueForKey:@"TYPE"] intValue] == 1 || [[dictionary valueForKey:@"TYPE"] intValue] == 2){
    
        if([[dictionary valueForKey:@"type"] isEqualToString:@"add"]){
            [self addNewRecord:dictionary];
        } else if ([[dictionary valueForKey:@"type"] isEqualToString:@"edit"]){
            
            [self editRecord:dictionary];
        }
        
    } else if ([[dictionary valueForKey:@"TYPE"] intValue] == 3) {
        
        //Trip response will also come in LOG_TABLE
        if([[dictionary valueForKey:@"type"] isEqualToString:@"add"]){
            [self addNewTrip:dictionary];
        } else if ([[dictionary valueForKey:@"type"] isEqualToString:@"edit"]){
            [self editTrip:dictionary];
        }
    }
    return YES;
}

- (void)addNewRecord: (NSDictionary *)dictionary{

    NSManagedObjectContext *context = [[CoreDataController sharedInstance] backgroundManagedObjectContext];
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    
    NSFetchRequest *vehRequest = [[NSFetchRequest alloc] initWithEntityName:@"Veh_Table"];
    NSError *vehErr;
    NSPredicate *vehPredicate = [NSPredicate predicateWithFormat:@"vehid == %@", [dictionary objectForKey:@"VEHID"]];
    [vehRequest setPredicate:vehPredicate];
    NSArray *vehArray = [context executeFetchRequest:vehRequest error:&vehErr];

    if(vehArray.count>0){

        Veh_Table *vehData = [vehArray firstObject];

        NSFetchRequest *logRequest = [[NSFetchRequest alloc] initWithEntityName:@"T_Fuelcons"];
        NSError *logErr;
        NSPredicate *logPred = [NSPredicate predicateWithFormat:@"iD == %@", [dictionary valueForKey:@"_ID"]];
        [logRequest setPredicate:logPred];
        NSArray *logResult = [context executeFetchRequest:logRequest error:&logErr];
        T_Fuelcons *log = [logResult firstObject];

        T_Fuelcons *logData = [NSEntityDescription insertNewObjectForEntityForName:@"T_Fuelcons" inManagedObjectContext:context];

        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"dd-MMM-yyyy"];
        NSTimeInterval dateTime = [[dictionary valueForKey:@"DATE"] doubleValue] / 1000;
        NSString *dateString = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:dateTime] ];
        NSError *err;
        NSDate *date = [formatter dateFromString:dateString];

        logData.vehid = [vehData.iD stringValue];
        int fuelID;
        if([[dictionary objectForKey:@"sync_with"] isEqualToString:@"friend"]){

            if([def objectForKey:@"maxFuelID"] != nil){

                fuelID = [[def objectForKey:@"maxFuelID"] intValue];

                if(fuelID >= [[dictionary valueForKey:@"_ID"] intValue]){

                    NSString *oldOdoString = [dictionary valueForKey:@"ODO"];
                    NSString *oldSt = [dictionary valueForKey:@"SERVICE_TYPE"];
                    NSString *logDataString =[NSString stringWithFormat:@"%@",log.serviceType];
                    NSString *logDataOdoString = [NSString stringWithFormat:@"%@",log.odo];
                    NSString *oldOdoTrimString;
                    NSString *logDataOdoTrimString;
                    if([oldOdoString containsString:@"."]){

                        NSUInteger location = [oldOdoString rangeOfString:@"."].location;
                        oldOdoTrimString = [oldOdoString substringToIndex:location];
                    }else{
                        oldOdoTrimString = oldOdoString;
                    }

                    if([logDataOdoString containsString:@"."]){

                        NSUInteger location1 = [logDataOdoString rangeOfString:@"."].location;
                        logDataOdoTrimString = [logDataOdoString substringToIndex:location1];
                    }else{
                        logDataOdoTrimString = logDataOdoString;
                    }


                    if([logDataOdoTrimString isEqualToString:oldOdoTrimString]){

                        if([logDataString isEqualToString:oldSt]){

                        sameRecord = YES;
                        NSMutableArray *syncedArray = [[NSMutableArray alloc] init];
                        NSMutableDictionary *syncedDictionary = [[NSMutableDictionary alloc] init];
                        [syncedDictionary setObject:[dictionary valueForKey:@"table"] forKey:@"tableName"];
                        [syncedDictionary setObject:[dictionary valueForKey:@"_ID"] forKey:@"rowID"];
                        [syncedDictionary setObject:[dictionary valueForKey:@"type"] forKey:@"type"];
                        [syncedDictionary setObject:[def objectForKey:@"UserDeviceId"] forKey:@"androidId"];
                        [syncedDictionary setObject:[dictionary valueForKey:@"user_id"] forKey:@"userID"];
                        [syncedArray addObject:syncedDictionary];

                        [self clearCloudSyncTable:syncedArray];

                    }else{

                        sameRecord = NO;
                        logData.iD = [NSNumber numberWithInt:fuelID + 1];
                    }
                    }else{

                        sameRecord = NO;
                        logData.iD = [NSNumber numberWithInt:fuelID + 1];
                    }
                }else{

                    logData.iD = [dictionary valueForKey:@"_ID"];
                }

            }else{

                logData.iD = [dictionary valueForKey:@"_ID"];
            }

        }else{

            sameRecord = NO;
            if(!log){
                logData.iD = [dictionary valueForKey:@"_ID"];
            }else{

                sameRecord = YES;

            }
        }

        if(!sameRecord){

            logData.type = @([[dictionary valueForKey:@"TYPE"] intValue]);
            logData.odo = @([[dictionary valueForKey:@"ODO"] floatValue]);
            logData.qty = @([[dictionary valueForKey:@"QTY"] floatValue]);

            if([NSNull null] != [dictionary valueForKey:@"COST"]){

                logData.cost = @([[dictionary valueForKey:@"COST"] floatValue]);
            }
            //logData.cost = @([[dictionary valueForKey:@"COST"] floatValue]);

            if([NSNull null] != [dictionary valueForKey:@"FILLING_STATION"]){

                logData.fillStation = [dictionary valueForKey:@"FILLING_STATION"];
            }
            //logData.fillStation = [dictionary valueForKey:@"FILLING_STATION"];

            if([NSNull null] != [dictionary valueForKey:@"FUEL_BRAND"]){

                logData.fuelBrand = [dictionary valueForKey:@"FUEL_BRAND"];
            }
            // logData.fuelBrand = [dictionary valueForKey:@"FUEL_BRAND"];
            logData.mfill = @([[dictionary valueForKey:@"MISSED_FILL"] floatValue]);
            logData.pfill = @([[dictionary valueForKey:@"PARTIAL_FILL"] floatValue]);

            if([NSNull null] != [dictionary valueForKey:@"NOTES"]){

                logData.notes = [dictionary valueForKey:@"NOTES"];
            }

            if([NSNull null] != [dictionary valueForKey:@"OCTANE"]){

                logData.octane = @([[dictionary valueForKey:@"OCTANE"] floatValue]);
            }
            logData.serviceType = [dictionary valueForKey:@"SERVICE_TYPE"];
            logData.stringDate = date;

            logData.longitude = [NSNumber numberWithDouble:[[dictionary valueForKey:@"DEP_LONG"] doubleValue]];
            logData.latitude = [NSNumber numberWithDouble:[[dictionary valueForKey:@"DEP_LAT"] doubleValue]];

            if([NSNull null] != [dictionary valueForKey:@"RECEIPT"]){

                NSString *receiptName = [dictionary valueForKey:@"RECEIPT"];

                if(receiptName != nil && receiptName.length > 0){
                    //ENH_54 making sync free 1june2018 nikhil // not allowing RECEIPTs if not pro
                    BOOL proUser = [[NSUserDefaults standardUserDefaults] boolForKey:@"isAdDisabled"];
                    mainArray = [[NSMutableArray alloc]init];

                    if(proUser){
                        //ENH_57 for multiple receipts
                        NSString *lastColontrimmedString;
                        NSArray *receiptImageNames = [[NSArray alloc]init];

                        if([receiptName containsString:@":::"]){

                            lastColontrimmedString = [receiptName substringToIndex:receiptName.length-3];

                        }else{
                            lastColontrimmedString = receiptName;
                        }
                        receiptImageNames = [lastColontrimmedString componentsSeparatedByString:@":::"];

                        for(int i=0;i<receiptImageNames.count;i++){

                            NSString *trimPrefix = [receiptImageNames objectAtIndex:i];
                            NSString *trimmedString;
                            if(![trimPrefix isEqualToString:@""] && [trimPrefix containsString:@"cac"]){
                                NSRange range = [trimPrefix rangeOfString:@"cac"];
                                trimmedString = [trimPrefix substringFromIndex:range.location];
                            }else{
                                trimmedString = trimPrefix;
                            }
                            [mainArray addObject:trimmedString];


                        }
                        if(receiptName != nil && receiptName.length > 0){

                            if(mainArray.count == 1){

                                NSArray *dataDictionary = [[NSArray alloc]init];
                                dataDictionary = [dictionary valueForKey:@"PIC"];
                                NSData *separatedData = [[NSData alloc]init];

                                separatedData = [dictionary valueForKey:@"PIC"];

                                if ((separatedData != NULL) && ![separatedData isKindOfClass:[NSNull class]])
                                {
                                    [self decodeBase64:separatedData toImage:[mainArray firstObject]];

                                }

                            }else if(mainArray.count>1){

                                for(int i=0;i<mainArray.count;i++){

                                    NSArray *dataDictionary = [[NSArray alloc]init];
                                    dataDictionary = [dictionary valueForKey:@"PIC"];
                                    NSData *separatedData = [[NSData alloc]init];
                                    if(i < dataDictionary.count){
                                        separatedData = [dataDictionary objectAtIndex:i];
                                        if ((separatedData != NULL) && ![separatedData isKindOfClass:[NSNull class]])
                                        {
                                            [self decodeBase64:separatedData toImage:[mainArray objectAtIndex:i]];
                                        }
                                    }

                                }

                            }


                            NSString *wholeImageString = [[NSString alloc]init];
                            NSString *finalString = [[NSString alloc]init];
                            for(NSString *imageString in mainArray){

                                wholeImageString = [wholeImageString stringByAppendingString:imageString];
                                wholeImageString = [wholeImageString stringByAppendingString:@":::"];

                            }

                            if(wholeImageString.length > 3){
                                int lastThree =(int)wholeImageString.length-3;
                                finalString = [wholeImageString substringToIndex:lastThree];
                            }
                            logData.receipt = finalString;

                        }
                    }

                }
            }

            if ([context hasChanges])
            {
                BOOL saved = [context save:&err];
                if (!saved) {
                    // do some real error handling

                }
                [[CoreDataController sharedInstance] saveBackgroundContext];
                [[CoreDataController sharedInstance] saveMasterContext];
                //NIKHIL BUG_144
                [def setObject:logData.iD forKey:@"maxFuelID"];

                NSString *alertBody;
                NSString *alertTitle = @"Record Synced";

                if([[dictionary objectForKey:@"sync_with"] isEqualToString:@"friend"]){

                    if([[dictionary objectForKey:@"TYPE"] isEqualToString:@"0"]){

                        NSString* alertBody1 = [NSString stringWithFormat:@"%@ has just filled up %@\nPrice: %@ %@",sendByName,[dictionary objectForKey:@"VEHID"],[def objectForKey:@"curr_unit"],[dictionary objectForKey:@"COST"]];
                        alertBody = [NSString stringWithString:alertBody1];

                    }else if([[dictionary objectForKey:@"TYPE"] isEqualToString:@"1"]){

                        NSString* alertBody1 = [NSString stringWithFormat:@"%@ has just serviced %@\nServices: %@",sendByName,[dictionary objectForKey:@"VEHID"],[dictionary objectForKey:@"SERVICE_TYPE"]];
                        alertBody = [NSString stringWithString:alertBody1];

                    }else if([[dictionary objectForKey:@"TYPE"] isEqualToString:@"2"]){

                        NSString* alertBody1 = [NSString stringWithFormat:@"%@ has just added an expense for %@\nExpenses: %@",sendByName,[dictionary objectForKey:@"VEHID"],[dictionary objectForKey:@"SERVICE_TYPE"]];
                        alertBody = [NSString stringWithString:alertBody1];
                    }

                    NSMutableArray *syncedArray = [[NSMutableArray alloc] init];
                    NSMutableDictionary *syncedDictionary = [[NSMutableDictionary alloc] init];
                    [syncedDictionary setObject:[dictionary valueForKey:@"table"] forKey:@"tableName"];
                    [syncedDictionary setObject:[dictionary valueForKey:@"_ID"] forKey:@"rowID"];
                    [syncedDictionary setObject:[dictionary valueForKey:@"type"] forKey:@"type"];
                    [syncedDictionary setObject:[def objectForKey:@"UserDeviceId"] forKey:@"androidId"];
                    [syncedDictionary setObject:[dictionary valueForKey:@"user_id"] forKey:@"userID"];
                    [syncedArray addObject:syncedDictionary];

                    int success = [self clearCloudSyncTable:syncedArray];

                    if(success == 1){

                        NSString *originalSource = [dictionary objectForKey:@"uploaded_by"];

                        [self writeToSyncTableWithRowID:logData.iD tableName:@"LOG_TABLE" andType:@"add" andOS:originalSource];
                        [self checkNetworkForCloudStorage:@"isLog"];

                    }

                    [self showNotification:alertTitle :alertBody];
                    //                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    //
                    //                    //Save data on cloud too
                    //
                    //
                    //                });

                }

            }

            [[CoreDataController sharedInstance] saveMasterContext];

            [def setObject:[vehData.iD stringValue] forKey:@"fillupid"];
            [self updateDistance:1];
            [self updateConsumption:1];

            if([[def objectForKey:@"responseType"] isEqualToString:@"pull"]){

                if([[dictionary valueForKey:@"TYPE"] intValue] == 1 || [[dictionary valueForKey:@"TYPE"] intValue] == 2){

                   // ServiceViewController *serviceVC = [[ServiceViewController alloc] init];
                    [self insertservice: 0];
                    [self updateservice:dictionary];
                }
                [self getOdoServicesWithOdo:[[dictionary valueForKey:@"ODO"] floatValue]];
            }
        }

    }else{

        NSString *message = [NSString stringWithFormat:@"%@ not found",[dictionary objectForKey:@"VEHID"]];
        [self showVehicleNotFoundNotification:@"" :message];

        if([[dictionary objectForKey:@"sync_with"] isEqualToString:@"friend"]){

            NSMutableArray *syncedArray = [[NSMutableArray alloc] init];
            NSMutableDictionary *syncedDictionary = [[NSMutableDictionary alloc] init];
            [syncedDictionary setObject:[dictionary valueForKey:@"table"] forKey:@"tableName"];
            [syncedDictionary setObject:[dictionary valueForKey:@"_ID"] forKey:@"rowID"];
            [syncedDictionary setObject:[dictionary valueForKey:@"type"] forKey:@"type"];
            [syncedDictionary setObject:[def objectForKey:@"UserDeviceId"] forKey:@"androidId"];
            [syncedDictionary setObject:[dictionary valueForKey:@"user_id"] forKey:@"userID"];
            [syncedArray addObject:syncedDictionary];

            [self clearCloudSyncTable:syncedArray];
        }

    }

}

- (void)editRecord: (NSDictionary *)dictionary{
    
    NSManagedObjectContext *context =[[CoreDataController sharedInstance] backgroundManagedObjectContext];
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSError *err;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"T_Fuelcons"];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"iD == %@", [dictionary valueForKey:@"_ID"]];
    [request setPredicate:predicate];
    NSArray *fetchedData = [context executeFetchRequest:request error:&err];

    if(fetchedData.count>0){

        T_Fuelcons *logData = [fetchedData firstObject];
        NSFetchRequest *vehRequest = [[NSFetchRequest alloc] initWithEntityName:@"Veh_Table"];
        NSError *vehErr;
        NSPredicate *vehPredicate = [NSPredicate predicateWithFormat:@"vehid == %@", [dictionary objectForKey:@"VEHID"]];
        [vehRequest setPredicate:vehPredicate];
        NSArray *vehArray = [context executeFetchRequest:vehRequest error:&vehErr];
        sameRecord = YES;
        if([[dictionary objectForKey:@"sync_with"] isEqualToString:@"friend"]){

            if(logData.serviceType != nil && logData.odo != nil){

                NSString *oldOdoString = [dictionary valueForKey:@"old_odo"];
                //            double oldOdoDouble = [oldOdoString doubleValue];
                //            NSNumber *oldOdo = [NSNumber numberWithDouble:oldOdoDouble];
                NSString *oldSt = [dictionary valueForKey:@"old_st"];

                NSString *logDataString =[NSString stringWithFormat:@"%@",logData.serviceType];
                NSString *logDataOdoString = [NSString stringWithFormat:@"%@",logData.odo];

                NSString *oldOdoTrimString;
                NSString *logDataOdoTrimString;

                if(oldOdoString.length > 0 && oldOdoString != nil){

                    if([oldOdoString containsString:@"."]){

                        NSUInteger location = [oldOdoString rangeOfString:@"."].location;
                        oldOdoTrimString = [oldOdoString substringToIndex:location];
                    }else{
                        oldOdoTrimString = oldOdoString;
                    }

                    if(logDataOdoString.length > 0 && logDataOdoString != nil){

                        if([logDataOdoString containsString:@"."]){

                            NSUInteger location1 = [logDataOdoString rangeOfString:@"."].location;
                            logDataOdoTrimString = [logDataOdoString substringToIndex:location1];
                        }else{
                            logDataOdoTrimString = logDataOdoString;
                        }

                        if([logDataOdoTrimString isEqualToString:oldOdoTrimString]){

                            if([logDataString isEqualToString:oldSt]){

                                sameRecord = YES;
                            }else{

                                sameRecord = NO;
                            }


                        }else{

                            sameRecord = NO;
                        }
                    }else{

                        sameRecord = NO;
                    }

                }else{

                    sameRecord = NO;
                }
            }else{

                sameRecord = NO;
            }

        }

        if(sameRecord){

            if(vehArray.count>0){

                Veh_Table *vehData = [vehArray firstObject];

                //Convert UNIX time to local date/time
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"dd-MMM-yyyy"];
                NSTimeInterval dateTime = [[dictionary valueForKey:@"DATE"] doubleValue] / 1000;
                NSString *dateString = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:dateTime] ];

                NSDate *date = [formatter dateFromString:dateString];

                logData.vehid = [vehData.iD stringValue];
                logData.type = @([[dictionary valueForKey:@"TYPE"] floatValue]);
                logData.odo = @([[dictionary valueForKey:@"ODO"] floatValue]);
                logData.qty = @([[dictionary valueForKey:@"QTY"] floatValue]);

                if([NSNull null] != [dictionary valueForKey:@"COST"]){

                    logData.cost = @([[dictionary valueForKey:@"COST"] floatValue]);
                }
                //logData.cost = @([[dictionary valueForKey:@"COST"] floatValue]);

                if([NSNull null] != [dictionary valueForKey:@"FILLING_STATION"]){

                    logData.fillStation = [dictionary valueForKey:@"FILLING_STATION"];
                }
                //logData.fillStation = [dictionary valueForKey:@"FILLING_STATION"];

                if([NSNull null] != [dictionary valueForKey:@"FUEL_BRAND"]){

                    logData.fuelBrand = [dictionary valueForKey:@"FUEL_BRAND"];
                }
                // logData.fuelBrand = [dictionary valueForKey:@"FUEL_BRAND"];

                logData.mfill = @([[dictionary valueForKey:@"MISSED_FILL"] floatValue]);
                logData.pfill = @([[dictionary valueForKey:@"PARTIAL_FILL"] floatValue]);
                if([NSNull null] != [dictionary valueForKey:@"NOTES"]){

                    logData.notes = [dictionary valueForKey:@"NOTES"];
                }
                if([NSNull null] != [dictionary valueForKey:@"OCTANE"]){

                    logData.octane = @([[dictionary valueForKey:@"OCTANE"] floatValue]);
                }

                logData.serviceType = [dictionary valueForKey:@"SERVICE_TYPE"];
                logData.stringDate = date;
                logData.longitude = [NSNumber numberWithDouble:[[dictionary valueForKey:@"DEP_LONG"] doubleValue]];
                logData.latitude = [NSNumber numberWithDouble:[[dictionary valueForKey:@"DEP_LAT"] doubleValue]];

                if([NSNull null] != [dictionary valueForKey:@"RECEIPT"]){

                    NSString *receiptName = [dictionary valueForKey:@"RECEIPT"];
                    //If receipt name is not nil and not empty
                    if(receiptName != nil && receiptName.length > 0){
                        //ENH_54 making sync free 1june2018 nikhil // not allowing vehicle images if not pro
                        BOOL proUser = [[NSUserDefaults standardUserDefaults] boolForKey:@"isAdDisabled"];
                        mainArray = [[NSMutableArray alloc]init];

                        if(proUser){

                            //ENH_57 for multiple receipts
                            NSString *lastColontrimmedString;
                            NSArray *receiptImageNames = [[NSArray alloc]init];
                            NSString *receiptName = [dictionary valueForKey:@"RECEIPT"];
                            if([receiptName containsString:@":::"]){

                                lastColontrimmedString = [receiptName substringToIndex:receiptName.length-3];

                            }else{
                                lastColontrimmedString = receiptName;
                            }
                            receiptImageNames = [lastColontrimmedString componentsSeparatedByString:@":::"];

                            for(int i=0;i<receiptImageNames.count;i++){

                                NSString *trimPrefix = [receiptImageNames objectAtIndex:i];
                                NSString *trimmedString;
                                if(![trimPrefix isEqualToString:@""] && [trimPrefix containsString:@"cac"]){
                                    NSRange range = [trimPrefix rangeOfString:@"cac"];
                                    trimmedString = [trimPrefix substringFromIndex:range.location];
                                }else{
                                    trimmedString = trimPrefix;
                                }
                                [mainArray addObject:trimmedString];


                            }
                            if(receiptName != nil && receiptName.length > 0){

                                if(mainArray.count == 1){

                                    NSArray *dataDictionary = [[NSArray alloc]init];
                                    dataDictionary = [dictionary valueForKey:@"PIC"];
                                    NSData *separatedData = [[NSData alloc]init];
                                    separatedData = [dataDictionary firstObject];
                                    if ((separatedData != NULL) && ![separatedData isKindOfClass:[NSNull class]])
                                    {
                                        [self decodeBase64:separatedData toImage:[mainArray firstObject]];
                                    }

                                }else if(mainArray.count>1){

                                    for(int i=0;i<mainArray.count;i++){

                                        NSArray *dataDictionary = [[NSArray alloc]init];
                                        dataDictionary = [dictionary valueForKey:@"PIC"];
                                        NSData *separatedData = [[NSData alloc]init];
                                        if(i < dataDictionary.count){
                                            separatedData = [dataDictionary objectAtIndex:i];
                                            if ((separatedData != NULL) && ![separatedData isKindOfClass:[NSNull class]])
                                            {
                                                [self decodeBase64:separatedData toImage:[mainArray objectAtIndex:i]];
                                            }
                                        }


                                    }

                                }

                                NSString *wholeImageString = [[NSString alloc]init];
                                NSString *finalString = [[NSString alloc]init];
                                for(NSString *imageString in mainArray){

                                    wholeImageString = [wholeImageString stringByAppendingString:imageString];
                                    wholeImageString = [wholeImageString stringByAppendingString:@":::"];

                                }

                                if(wholeImageString.length > 3){
                                    int lastThree =(int)wholeImageString.length-3;
                                    finalString = [wholeImageString substringToIndex:lastThree];
                                }
                                logData.receipt = finalString;

                            }
                        }
                    } else {

                        //If receipt name is empty

                        //But receipt name for that record exist in DB (it is not empty in DB)
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
                                logData.receipt = nil;
                            }
                        }
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

                if([[dictionary objectForKey:@"sync_with"] isEqualToString:@"friend"]){

                    NSString *alertTitle = @"Record Synced";
                    NSString *alertBody;

                    if([[dictionary objectForKey:@"TYPE"] isEqualToString:@"0"]){

                        alertBody = [NSString stringWithFormat:@"%@ just updated a fill up for %@",sendByName,[dictionary objectForKey:@"VEHID"]];


                    }else if([[dictionary objectForKey:@"TYPE"] isEqualToString:@"1"]){

                        alertBody = [NSString stringWithFormat:@"%@ just updated a service for %@",sendByName,[dictionary objectForKey:@"VEHID"]];

                    }else if([[dictionary objectForKey:@"TYPE"] isEqualToString:@"2"]){

                        alertBody = [NSString stringWithFormat:@"%@ just updated a expense for %@",sendByName,[dictionary objectForKey:@"VEHID"]];
                    }



                    NSMutableArray *syncedArray = [[NSMutableArray alloc] init];
                    NSMutableDictionary *syncedDictionary = [[NSMutableDictionary alloc] init];
                    [syncedDictionary setObject:[dictionary valueForKey:@"table"] forKey:@"tableName"];
                    [syncedDictionary setObject:[dictionary valueForKey:@"_ID"] forKey:@"rowID"];
                    [syncedDictionary setObject:[dictionary valueForKey:@"type"] forKey:@"type"];
                    [syncedDictionary setObject:[def objectForKey:@"UserDeviceId"] forKey:@"androidId"];
                    [syncedDictionary setObject:[dictionary valueForKey:@"user_id"] forKey:@"userID"];
                    [syncedArray addObject:syncedDictionary];

                    int success = [self clearCloudSyncTable:syncedArray];

                    if(success == 1){

                        NSString *originalSource = [dictionary objectForKey:@"uploaded_by"];

                        [self writeToSyncTableWithRowID:logData.iD tableName:@"LOG_TABLE" andType:@"edit" andOS:originalSource];
                   //     [self writeToSyncTableWithRowID:logData.iD tableName:@"LOG_TABLE" andType:@"edit"];
                        [self checkNetworkForCloudStorage:@"isLog"];
                    }

                    [self showNotification:alertTitle :alertBody];
                }

                [[CoreDataController sharedInstance] saveMasterContext];
                [def setObject:[vehData.iD stringValue] forKey:@"fillupid"];
                [self updateDistance:1];
                [self updateConsumption:1];

                if([[dictionary valueForKey:@"TYPE"] intValue] == 1 || [[dictionary valueForKey:@"TYPE"] intValue] == 2){

                    //ServiceViewController *serviceVC = [[ServiceViewController alloc] init];
                    [self insertservice: 0];
                    [self updateservice:dictionary];
                }
                [self getOdoServicesWithOdo:[[dictionary valueForKey:@"ODO"] floatValue]];
            }else{

                if([[dictionary objectForKey:@"sync_with"] isEqualToString:@"friend"]){

                    NSMutableArray *syncedArray = [[NSMutableArray alloc] init];
                    NSMutableDictionary *syncedDictionary = [[NSMutableDictionary alloc] init];
                    [syncedDictionary setObject:[dictionary valueForKey:@"table"] forKey:@"tableName"];
                    [syncedDictionary setObject:[dictionary valueForKey:@"_ID"] forKey:@"rowID"];
                    [syncedDictionary setObject:[dictionary valueForKey:@"type"] forKey:@"type"];
                    [syncedDictionary setObject:[def objectForKey:@"UserDeviceId"] forKey:@"androidId"];
                    [syncedDictionary setObject:[dictionary valueForKey:@"user_id"] forKey:@"userID"];
                    [syncedArray addObject:syncedDictionary];

                    [self clearCloudSyncTable:syncedArray];
                }
                NSString *message = [NSString stringWithFormat:@"%@ not found",[dictionary objectForKey:@"VEHID"]];
                [self showVehicleNotFoundNotification:@"" :message];

            }

        }else{

            if([[dictionary objectForKey:@"sync_with"] isEqualToString:@"friend"]){

                NSMutableArray *syncedArray = [[NSMutableArray alloc] init];
                NSMutableDictionary *syncedDictionary = [[NSMutableDictionary alloc] init];
                [syncedDictionary setObject:[dictionary valueForKey:@"table"] forKey:@"tableName"];
                [syncedDictionary setObject:[dictionary valueForKey:@"_ID"] forKey:@"rowID"];
                [syncedDictionary setObject:[dictionary valueForKey:@"type"] forKey:@"type"];
                [syncedDictionary setObject:[def objectForKey:@"UserDeviceId"] forKey:@"androidId"];
                [syncedDictionary setObject:[dictionary valueForKey:@"user_id"] forKey:@"userID"];
                [syncedArray addObject:syncedDictionary];

                [self clearCloudSyncTable:syncedArray];
            }
        }

        }else{

            if([[dictionary objectForKey:@"sync_with"] isEqualToString:@"friend"]){

                NSMutableArray *syncedArray = [[NSMutableArray alloc] init];
                NSMutableDictionary *syncedDictionary = [[NSMutableDictionary alloc] init];
                [syncedDictionary setObject:[dictionary valueForKey:@"table"] forKey:@"tableName"];
                [syncedDictionary setObject:[dictionary valueForKey:@"_ID"] forKey:@"rowID"];
                [syncedDictionary setObject:[dictionary valueForKey:@"type"] forKey:@"type"];
                [syncedDictionary setObject:[def objectForKey:@"UserDeviceId"] forKey:@"androidId"];
                [syncedDictionary setObject:[dictionary valueForKey:@"user_id"] forKey:@"userID"];
                [syncedArray addObject:syncedDictionary];

                [self clearCloudSyncTable:syncedArray];
            }
        }

}


- (void)deleteRecord: (NSDictionary *)dictionary{

    NSManagedObjectContext *context = [[CoreDataController sharedInstance] backgroundManagedObjectContext];
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSError *fuelErr;
    NSError *tripErr, *err;

    //Response for delete will not give record type(0,1,2 or 3). So fetch both T_Fuelcons and T_Trip where rowId matches
    NSFetchRequest *fuelRequest = [[NSFetchRequest alloc] initWithEntityName:@"T_Fuelcons"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"iD == %@", [dictionary valueForKey:@"_ID"]];
    [fuelRequest setPredicate:predicate];
    NSUInteger fuelconsCount = [context countForFetchRequest:fuelRequest error:&fuelErr];
    
    NSFetchRequest *tripRequest = [[NSFetchRequest alloc] initWithEntityName:@"T_Trip"];
    NSPredicate *tripPredicate = [NSPredicate predicateWithFormat:@"iD == %@", [dictionary valueForKey:@"_ID"]];
    [tripRequest setPredicate:tripPredicate];
    NSUInteger tripCount = [context countForFetchRequest:tripRequest error:&tripErr];

    if(fuelconsCount > 0){
      //  NSDictionary *copyDict = [[NSDictionary alloc] init];
        NSString *TYPE; //= [[NSString alloc] init];
        NSString *VEHID; //= [[NSString alloc] init];
        NSNumber *ID; //= [[NSString alloc] init];
        //So it is record from T_Fuelcons table, delete from T_Fuelcons table
        NSArray *fetchedData = [context executeFetchRequest:fuelRequest error:&fuelErr];
        T_Fuelcons *logData = [fetchedData firstObject];

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
            
            [def setObject:logData.vehid forKey:@"fillupid"];
            if([logData.type intValue] == 1 || [logData.type intValue] == 2){
                
                NSArray *filluprecord = [[NSArray alloc]init];
                filluprecord= [logData.serviceType componentsSeparatedByString:@","];
                //LogViewController *logVC = [[LogViewController alloc] init];
                [self updateServiceOdo:logData.vehid :filluprecord andiD:logData.iD];
            }
//
//            [dictionary setValue:logData.type forKey:@"TYPE"];
//            [dictionary setValue:logData.vehid forKey:@"VEHID"];
//            [dictionary setValue:logData.iD forKey:@"_ID"];

          //  NSDictionary *copyDict = [[NSDictionary alloc] init];
          //  [copyDict setValue:logData.type forKey:@"TYPE"];
            TYPE = [logData.type stringValue];

            NSFetchRequest *vehRequest = [[NSFetchRequest alloc] initWithEntityName:@"Veh_Table"];
            NSError *vehErr;
            NSPredicate *vehPredicate = [NSPredicate predicateWithFormat:@"iD == %@", logData.vehid];
            [vehRequest setPredicate:vehPredicate];
            NSArray *vehArray = [context executeFetchRequest:vehRequest error:&vehErr];

            Veh_Table *vehData = [vehArray firstObject];
          //  [copyDict setValue:[vehData.iD stringValue] forKey:@"VEHID"];
            VEHID = vehData.vehid;
          //  [copyDict setValue:logData.iD forKey:@"_ID"];
            ID = logData.iD;

            [context deleteObject:logData];
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

        if([[dictionary objectForKey:@"sync_with"] isEqualToString:@"friend"]){

            NSString *alertTitle = @"Record Synced";
            NSString *alertBody;

            if([TYPE isEqualToString:@"0"]){

                alertBody = [NSString stringWithFormat:@"%@ just deleted a fill up for %@",sendByName,VEHID];

            }else if([TYPE isEqualToString:@"1"]){

                alertBody = [NSString stringWithFormat:@"%@ just deleted a service for %@",sendByName,VEHID];

            }else if([TYPE isEqualToString:@"2"]){

                alertBody = [NSString stringWithFormat:@"%@ just deleted a expense for %@",sendByName,VEHID];
            }


            NSMutableArray *syncedArray = [[NSMutableArray alloc] init];
            NSMutableDictionary *syncedDictionary = [[NSMutableDictionary alloc] init];
            [syncedDictionary setObject:[dictionary valueForKey:@"table"] forKey:@"tableName"];
            [syncedDictionary setObject:[dictionary valueForKey:@"_ID"] forKey:@"rowID"];
            [syncedDictionary setObject:[dictionary valueForKey:@"type"] forKey:@"type"];
            [syncedDictionary setObject:[def objectForKey:@"UserDeviceId"] forKey:@"androidId"];
            [syncedDictionary setObject:[dictionary valueForKey:@"user_id"] forKey:@"userID"];
            [syncedArray addObject:syncedDictionary];

            int success = [self clearCloudSyncTable:syncedArray];

            if(success == 1){

                NSString *originalSource = [dictionary objectForKey:@"uploaded_by"];

                [self writeToSyncTableWithRowID:ID tableName:@"LOG_TABLE" andType:@"del" andOS:originalSource];
               // [self writeToSyncTableWithRowID:ID tableName:@"LOG_TABLE" andType:@"del"];
                [self checkNetworkForCloudStorage:@"isDel"];
            }

            [self showNotification:alertTitle :alertBody];
        }
        
        [self updateDistance:1];
        [self updateConsumption:1];

    }
    
    if(tripCount > 0){

        NSString *VEHID;
        NSNumber *ID;
        //So it is record from T_Trip table, delete from T_Trip table
        NSArray *fetchedData = [context executeFetchRequest:tripRequest error:&err];
        T_Trip *tripData = [fetchedData firstObject];
        
        if(tripData != nil){
            
            [def setObject:tripData.vehId forKey:@"fillupid"];

            NSFetchRequest *vehRequest = [[NSFetchRequest alloc] initWithEntityName:@"Veh_Table"];
            NSError *vehErr;
            NSPredicate *vehPredicate = [NSPredicate predicateWithFormat:@"iD == %@", tripData.vehId];
            [vehRequest setPredicate:vehPredicate];
            NSArray *vehArray = [context executeFetchRequest:vehRequest error:&vehErr];

            Veh_Table *vehData = [vehArray firstObject];

            VEHID = vehData.vehid;
            ID = tripData.iD;

            
            [context deleteObject:tripData];
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
        [[CoreDataController sharedInstance] saveMasterContext];

        if([[dictionary objectForKey:@"sync_with"] isEqualToString:@"friend"]){

            NSString *alertTitle = @"Record Synced";
            NSString *alertBody = [NSString stringWithFormat:@"%@ has just deleted a trip for %@",sendByName,VEHID];


            NSMutableArray *syncedArray = [[NSMutableArray alloc] init];
            NSMutableDictionary *syncedDictionary = [[NSMutableDictionary alloc] init];
            [syncedDictionary setObject:[dictionary valueForKey:@"table"] forKey:@"tableName"];
            [syncedDictionary setObject:[dictionary valueForKey:@"_ID"] forKey:@"rowID"];
            [syncedDictionary setObject:[dictionary valueForKey:@"type"] forKey:@"type"];
            [syncedDictionary setObject:[def objectForKey:@"UserDeviceId"] forKey:@"androidId"];
            [syncedDictionary setObject:[dictionary valueForKey:@"user_id"] forKey:@"userID"];
            [syncedArray addObject:syncedDictionary];

            int success = [self clearCloudSyncTable:syncedArray];

            if(success == 1){

                NSString *originalSource = [dictionary objectForKey:@"uploaded_by"];

                [self writeToSyncTableWithRowID:ID tableName:@"LOG_TABLE" andType:@"del" andOS:originalSource];
              //  [self writeToSyncTableWithRowID:ID tableName:@"LOG_TABLE" andType:@"del"];
                [self checkNetworkForCloudStorage:@"isDel"];
            }

            [self showNotification:alertTitle :alertBody];
        }


        [self updateDistance:1];
        [self updateConsumption:1];

    }
    
}


#pragma mark SERVICES_TABLE add/upd/del

-(BOOL)saveToServiceTable:(NSDictionary *)dictionary{
    
    
    if ([[dictionary valueForKey:@"TYPE"] intValue] == 0 || [[dictionary valueForKey:@"TYPE"] intValue] == 1 || [[dictionary valueForKey:@"TYPE"] intValue] == 2){
    
        if ([[dictionary valueForKey:@"type"] isEqualToString:@"add"]){
            [self addService:dictionary];
        } else if ([[dictionary valueForKey:@"type"] isEqualToString:@"edit"]){
            [self editService:dictionary];
        } else if([[dictionary valueForKey:@"type"] isEqualToString:@"del"]){
            [self deleteService:dictionary];
        }
    }

    return YES;
}


- (void)addService: (NSDictionary *)dictionary{
    
    if([[dictionary valueForKey:@"TYPE"] intValue] == 1 || [[dictionary valueForKey:@"TYPE"] intValue] == 2){
 
        NSManagedObjectContext *context = [[CoreDataController sharedInstance] backgroundManagedObjectContext];
        NSError *error;

        Services_Table *serviceData = [NSEntityDescription insertNewObjectForEntityForName:@"Services_Table" inManagedObjectContext:context];
    
        NSFetchRequest *vehRequest = [[NSFetchRequest alloc] initWithEntityName:@"Veh_Table"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"vehid == %@", [dictionary valueForKey:@"VEHID"]];
    
        [vehRequest setPredicate:predicate];
    
        NSArray *vehData = [context executeFetchRequest:vehRequest error:&error];

        if(vehData.count>0){

            Veh_Table *veh = [vehData firstObject];

            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"dd-MMM-yyyy"];
            NSTimeInterval dateTime = [[dictionary valueForKey:@"LAST_DATE"] doubleValue] / 1000;
            NSString *dateString = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:dateTime] ];

            NSDate *date = [formatter dateFromString:dateString];
            NSError *err;
            if(dateTime != 0){

                serviceData.lastDate = date;
            }
            serviceData.vehid = [veh.iD stringValue];
            serviceData.iD = @([[dictionary valueForKey:@"_ID"] floatValue]);
            serviceData.serviceName = [dictionary valueForKey:@"SERVICE_NAME"];
            serviceData.type = @([[dictionary valueForKey:@"TYPE"] floatValue]);
            serviceData.dueMiles = @([[dictionary valueForKey:@"DUE_MILES"] floatValue]);
            serviceData.lastOdo = @([[dictionary valueForKey:@"LAST_ODO"] floatValue]);
            serviceData.recurring = @([[dictionary valueForKey:@"RECURRING"] floatValue]);
            serviceData.dueDays = @([[dictionary valueForKey:@"DUE_DAYS"] floatValue]);

            if(serviceData.dueDays > [NSNumber numberWithInt:0]){

                NSString* jrnKey = [[serviceData.serviceName stringByAppendingString:@","] stringByAppendingString:[[NSUserDefaults standardUserDefaults]objectForKey:@"vehname"]];

                dispatch_async(dispatch_get_main_queue(), ^{

                    [[JRNLocalNotificationCenter defaultCenter] cancelLocalNotificationForKey:jrnKey];
                });

                NSDateComponents *dateComponents = [NSDateComponents new];
                dateComponents.day = [serviceData.dueDays integerValue];
                NSDate *dueDate = [[NSCalendar currentCalendar]dateByAddingComponents:dateComponents
                                                                               toDate: serviceData.lastDate
                                                                              options:0];

                NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
                NSDateComponents *timeComponents = [calendar components:( NSCalendarUnitYear |  NSCalendarUnitMonth |  NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond )
                                                               fromDate:dueDate];
                [timeComponents setHour:7];
                [timeComponents setMinute:00];
                [timeComponents setSecond:0];

                NSDate *dtFinal = [calendar dateFromComponents:timeComponents];

                NSString* alertBody = [NSString stringWithFormat:@"%@ %@ %@",serviceData.serviceName, NSLocalizedString(@"noti_msg_veh", @"Overdue for"), [[NSUserDefaults standardUserDefaults]objectForKey:@"vehname"]];

                dispatch_async(dispatch_get_main_queue(), ^{

                    [[JRNLocalNotificationCenter defaultCenter] postNotificationOn:dtFinal                                                            forKey:jrnKey alertBody:[NSString stringWithFormat:@"Pull or swipe to interact. %@", alertBody]
                                                                       alertAction:@"Open"
                                                                         soundName:nil
                                                                       launchImage:nil
                                                                          userInfo:@{@"DueDate": dtFinal}
                                                                        badgeCount:0
                                                                    repeatInterval:NSCalendarUnitDay
                                                                          category:@"DayReminder"];

                    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"showPage"];
                });
            }

            if ([context hasChanges])
            {
                BOOL saved = [context save:&err];
                if (!saved) {
                    // do some real error handling
                    //CLSLog(@“Could not save Data due to %@“, error);
                }
                //  [[CoreDataController sharedInstance] saveBackgroundContext];
                [[CoreDataController sharedInstance] saveMasterContext];
            }

        }
        }
    
}


- (void)editService: (NSDictionary *)dictionary{
    
    NSManagedObjectContext *context = [[CoreDataController sharedInstance] backgroundManagedObjectContext];
    NSError *error;
   // NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Services_Table"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"iD == %@", [dictionary valueForKey:@"_ID"]];
    
    [request setPredicate:predicate];
    
    NSArray *fetchedData = [context executeFetchRequest:request error:&error];
    
    Services_Table *serviceData = [fetchedData firstObject];
    NSFetchRequest *vehRequest = [[NSFetchRequest alloc] initWithEntityName:@"Veh_Table"];

    NSError *vehErr;
    NSPredicate *vehPredicate = [NSPredicate predicateWithFormat:@"vehid == %@", [dictionary objectForKey:@"VEHID"]];
    [vehRequest setPredicate:vehPredicate];
    NSArray *vehArray = [context executeFetchRequest:vehRequest error:&vehErr];

    if(vehArray.count>0){

        Veh_Table *vehData = [vehArray firstObject];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"dd-MMM-yyyy"];
        NSTimeInterval dateTime = [[dictionary valueForKey:@"LAST_DATE"] doubleValue] / 1000;
        NSString *dateString = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:dateTime] ];
        NSError *err;
        NSDate *date = [formatter dateFromString:dateString];

        if(dateTime != 0){

            serviceData.lastDate = date;
        }

        serviceData.vehid = [vehData.iD stringValue];
        serviceData.iD = @([[dictionary valueForKey:@"_ID"] floatValue]);
        serviceData.serviceName = [dictionary valueForKey:@"SERVICE_NAME"];
        serviceData.type = @([[dictionary valueForKey:@"TYPE"] floatValue]);
        serviceData.dueMiles = @([[dictionary valueForKey:@"DUE_MILES"] floatValue]);
        serviceData.lastOdo = @([[dictionary valueForKey:@"LAST_ODO"] floatValue]);
        serviceData.recurring = @([[dictionary valueForKey:@"RECURRING"] floatValue]);
        serviceData.dueDays = @([[dictionary valueForKey:@"DUE_DAYS"] floatValue]);

        if([serviceData.recurring  isEqual: @0] && serviceData.dueDays > 0){

            NSString* jrnKey = [[serviceData.serviceName stringByAppendingString:@","] stringByAppendingString:[[NSUserDefaults standardUserDefaults]objectForKey:@"vehname"]];

            dispatch_async(dispatch_get_main_queue(), ^{

                [[JRNLocalNotificationCenter defaultCenter] cancelLocalNotificationForKey:jrnKey];
            });
        }

        if ([context hasChanges])
        {
            BOOL saved = [context save:&err];
            if (!saved) {
                // do some real error handling
                //CLSLog(@“Could not save Data due to %@“, error);
            }
            //   [[CoreDataController sharedInstance] saveBackgroundContext];
            [[CoreDataController sharedInstance] saveMasterContext];
        }

    }

}

- (void)deleteService: (NSDictionary *)dictionary{
    
    NSManagedObjectContext *context = [[CoreDataController sharedInstance] backgroundManagedObjectContext];
    NSError *err;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Services_Table"];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"iD == %@", [dictionary valueForKey:@"_ID"]];
    [request setPredicate:predicate];
    
    NSArray *fetchedData = [context executeFetchRequest:request error:&err];
    
    Services_Table *serviceData = [fetchedData firstObject];
    
    if(serviceData != nil){

        if([serviceData.recurring  isEqual: @0] && serviceData.dueDays > 0){

            NSString* jrnKey = [[serviceData.serviceName stringByAppendingString:@","] stringByAppendingString:[[NSUserDefaults standardUserDefaults]objectForKey:@"vehname"]];

            dispatch_async(dispatch_get_main_queue(), ^{

                [[JRNLocalNotificationCenter defaultCenter] cancelLocalNotificationForKey:jrnKey];
            });
        }
        [context deleteObject:serviceData];
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
    [[CoreDataController sharedInstance] saveMasterContext];

}

#pragma mark TRIP add/upd/del

- (void)addNewTrip: (NSDictionary *)dictionary{
    
    NSManagedObjectContext *context = [[CoreDataController sharedInstance] backgroundManagedObjectContext];
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    
    NSFetchRequest *vehRequest = [[NSFetchRequest alloc] initWithEntityName:@"Veh_Table"];
    NSError *vehErr;
    NSPredicate *vehPredicate = [NSPredicate predicateWithFormat:@"vehid == %@", [dictionary objectForKey:@"VEHID"]];
    [vehRequest setPredicate:vehPredicate];
    NSArray *vehArray = [context executeFetchRequest:vehRequest error:&vehErr];

    if(vehArray.count>0){

        Veh_Table *vehData = [vehArray firstObject];

        NSFetchRequest *tripFetch = [[NSFetchRequest alloc] initWithEntityName:@"T_Trip"];
        NSError *triperr;
        NSPredicate *tripPred = [NSPredicate predicateWithFormat:@"iD == %@", [dictionary valueForKey:@"_ID"]];
        [tripFetch setPredicate:tripPred];
        NSArray *tripArr = [context executeFetchRequest:tripFetch error:&triperr];

        T_Trip *existingTrip = [tripArr firstObject];

        T_Trip *tripData = [NSEntityDescription insertNewObjectForEntityForName:@"T_Trip" inManagedObjectContext:context];

        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"dd-MMM-yyyy hh:mm a"];

        NSDate *depDate;
        if([dictionary valueForKey:@"DATE"] != nil || ![[dictionary valueForKey:@"DATE"] isEqualToString:@""] ||
           ![[dictionary valueForKey:@"DATE"] isEqualToString:@"0.00"]){
            NSTimeInterval depDateTime = [[dictionary valueForKey:@"DATE"] doubleValue] / 1000;
            NSString *dateString = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:depDateTime] ];
            depDate = [formatter dateFromString:dateString];
        }
        else {
            depDate = nil;
        }
        NSError *err;
        NSDate *arrDate;

        if([dictionary valueForKey:@"CONSUMPTION"] != nil || ![[dictionary valueForKey:@"CONSUMPTION"] isEqualToString:@""] ||
           [[dictionary valueForKey:@"CONSUMPTION"] floatValue] != 0.00){

            NSTimeInterval arrDateTime = [[dictionary valueForKey:@"CONSUMPTION"] doubleValue] / 1000;
            NSString *arrDateString = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:arrDateTime] ];
            arrDate = [formatter dateFromString:arrDateString];

            if(arrDateTime != 0){
                tripData.arrDate = arrDate;
            }
        }
        tripData.vehId = [vehData.iD stringValue];
        int fuelID;
        if([[dictionary objectForKey:@"sync_with"] isEqualToString:@"friend"]){

            if([def objectForKey:@"maxFuelID"] != nil){

                fuelID = [[def objectForKey:@"maxFuelID"] intValue];

                if(fuelID >= [[dictionary valueForKey:@"_ID"] intValue]){

                    NSString *oldOdoDepString = [dictionary valueForKey:@"ODO"];
                    NSString *oldOdoArrString = [dictionary valueForKey:@"QTY"];
                    NSString *oldSt = [dictionary valueForKey:@"SERVICE_TYPE"];
                    NSString *logDataString =[NSString stringWithFormat:@"%@",existingTrip.tripType];
                    NSString *logDataDepOdoString = [NSString stringWithFormat:@"%@",existingTrip.depOdo];
                    NSString *logDataArrOdoString = [NSString stringWithFormat:@"%@",existingTrip.arrOdo];

                    NSString *oldOdoDepTrimString;
                    NSString *logDataDepTrimString;
                    NSString *oldOdoArrTrimString;
                    NSString *logDataArrTrimString;
                    if([oldOdoDepString containsString:@"."]){

                        NSUInteger location = [oldOdoDepString rangeOfString:@"."].location;
                        oldOdoDepTrimString = [oldOdoDepString substringToIndex:location];
                    }else{
                        oldOdoDepTrimString = oldOdoDepString;
                    }

                    if([logDataDepOdoString containsString:@"."]){

                        NSUInteger location1 = [logDataDepOdoString rangeOfString:@"."].location;
                        logDataDepTrimString = [logDataDepOdoString substringToIndex:location1];
                    }else{
                        logDataDepTrimString = logDataDepOdoString;
                    }

                    if([oldOdoArrString containsString:@"."]){

                        NSUInteger location2 = [oldOdoArrString rangeOfString:@"."].location;
                        oldOdoArrTrimString = [oldOdoArrString substringToIndex:location2];
                    }else{
                        oldOdoArrTrimString = oldOdoArrString;
                    }

                    if([logDataArrOdoString containsString:@"."]){

                        NSUInteger location3 = [logDataArrOdoString rangeOfString:@"."].location;
                        logDataArrTrimString = [logDataArrOdoString substringToIndex:location3];
                    }else{
                        logDataArrTrimString = logDataArrOdoString;
                    }

                    if([logDataDepTrimString isEqualToString:oldOdoDepTrimString]){

                        if([logDataArrTrimString isEqualToString:oldOdoArrTrimString]){

                            if([logDataString isEqualToString:oldSt]){

                                sameRecord = YES;
                                NSMutableArray *syncedArray = [[NSMutableArray alloc] init];
                                NSMutableDictionary *syncedDictionary = [[NSMutableDictionary alloc] init];
                                [syncedDictionary setObject:[dictionary valueForKey:@"table"] forKey:@"tableName"];
                                [syncedDictionary setObject:[dictionary valueForKey:@"_ID"] forKey:@"rowID"];
                                [syncedDictionary setObject:[dictionary valueForKey:@"type"] forKey:@"type"];
                                [syncedDictionary setObject:[def objectForKey:@"UserDeviceId"] forKey:@"androidId"];
                                [syncedDictionary setObject:[dictionary valueForKey:@"user_id"] forKey:@"userID"];
                                [syncedArray addObject:syncedDictionary];

                                [self clearCloudSyncTable:syncedArray];
                            }else{

                                sameRecord = NO;
                                tripData.iD = [NSNumber numberWithInt:fuelID + 1];
                            }
                        }else{

                            sameRecord = NO;
                            tripData.iD = [NSNumber numberWithInt:fuelID + 1];
                        }

                    }else{

                        sameRecord = NO;
                        tripData.iD = [NSNumber numberWithInt:fuelID + 1];
                    }

                }else{

                    tripData.iD = @([[dictionary valueForKey:@"_ID"] floatValue]);
                }

            }else{

                tripData.iD = @([[dictionary valueForKey:@"_ID"] floatValue]);
            }

        }else{

            sameRecord = NO;
            if(!existingTrip){
                tripData.iD = @([[dictionary valueForKey:@"_ID"] floatValue]);
            }else{

                sameRecord = YES;

            }
        }
        //tripData.iD = @([[dictionary valueForKey:@"_ID"] floatValue]);
        //logData.type = @([[dictionary valueForKey:@"TYPE"] floatValue]);
        tripData.depOdo = @([[dictionary valueForKey:@"ODO"] floatValue]);
        tripData.arrOdo = @([[dictionary valueForKey:@"QTY"] floatValue]);

        if([NSNull null] != [dictionary valueForKey:@"COST"]){

            tripData.taxDedn = @([[dictionary valueForKey:@"COST"] floatValue]);
        }


        if([NSNull null] != [dictionary valueForKey:@"FILLING_STATION"]){

            tripData.arrLocn = [dictionary valueForKey:@"FILLING_STATION"];
        }


        if([NSNull null] != [dictionary valueForKey:@"FUEL_BRAND"]){

            tripData.depLocn = [dictionary valueForKey:@"FUEL_BRAND"];
        }

        if([NSNull null] != [dictionary valueForKey:@"NOTES"]){

            tripData.notes = [dictionary valueForKey:@"NOTES"];
        }

        if([NSNull null] != [dictionary valueForKey:@"OCTANE"]){

            tripData.tollAmt = @([[dictionary valueForKey:@"OCTANE"] floatValue]);
        }

        tripData.tripType = [dictionary valueForKey:@"SERVICE_TYPE"];
        tripData.depDate = depDate;

        tripData.depLongitude = [NSNumber numberWithDouble:[[dictionary valueForKey:@"DEP_LONG"] doubleValue]];
        tripData.depLatitude = [NSNumber numberWithDouble:[[dictionary valueForKey:@"DEP_LAT"] doubleValue]];
        tripData.arrLongitude = [NSNumber numberWithDouble:[[dictionary valueForKey:@"ARR_LONG"] doubleValue]];
        tripData.arrLatitude = [NSNumber numberWithDouble:[[dictionary valueForKey:@"ARR_LAT"] doubleValue]];

        if([NSNull null] != [dictionary valueForKey:@"DIST"]){

            tripData.parkingAmt = @([[dictionary valueForKey:@"DIST"] floatValue]);
        }

        //If arrOdo is not there, set incomplete trip
        if([[dictionary valueForKey:@"QTY"] floatValue] == 0.0){
            tripData.tripComplete = NO;
        } else {

            //Set trip complete
            tripData.tripComplete = YES;
        }

        if ([context hasChanges])
        {
            BOOL saved = [context save:&err];
            if (!saved) {
                // do some real error handling
                //CLSLog(@“Could not save Data due to %@“, error);
            }
            [[CoreDataController sharedInstance] saveBackgroundContext];
            [def setObject:[dictionary valueForKey:@"_ID"] forKey:@"maxFuelID"];
        }
        [[CoreDataController sharedInstance] saveMasterContext];

        if([[dictionary objectForKey:@"sync_with"] isEqualToString:@"friend"]){

            NSString *alertTitle = @"Record Synced";
            NSString *alertBody = [NSString stringWithFormat:@"%@ has just added a trip for %@",sendByName,[dictionary objectForKey:@"VEHID"]];


            NSMutableArray *syncedArray = [[NSMutableArray alloc] init];
            NSMutableDictionary *syncedDictionary = [[NSMutableDictionary alloc] init];
            [syncedDictionary setObject:[dictionary valueForKey:@"table"] forKey:@"tableName"];
            [syncedDictionary setObject:[dictionary valueForKey:@"_ID"] forKey:@"rowID"];
            [syncedDictionary setObject:[dictionary valueForKey:@"type"] forKey:@"type"];
            [syncedDictionary setObject:[def objectForKey:@"UserDeviceId"] forKey:@"androidId"];
            [syncedDictionary setObject:[dictionary valueForKey:@"user_id"] forKey:@"userID"];
            [syncedArray addObject:syncedDictionary];

            int success = [self clearCloudSyncTable:syncedArray];

            if(success == 1){

                NSString *originalSource = [dictionary objectForKey:@"uploaded_by"];

                [self writeToSyncTableWithRowID:tripData.iD tableName:@"TRIP" andType:@"add" andOS:originalSource];
               // [self writeToSyncTableWithRowID:tripData.iD tableName:@"TRIP" andType:@"add"];
                [self checkNetworkForCloudStorage:@"isTrip"];
            }

            [self showNotification:alertTitle :alertBody];

        }

    }else{

        NSString *message = [NSString stringWithFormat:@"%@ not found",[dictionary objectForKey:@"VEHID"]];
        [self showVehicleNotFoundNotification:@"" :message];

        if([[dictionary objectForKey:@"sync_with"] isEqualToString:@"friend"]){

            NSMutableArray *syncedArray = [[NSMutableArray alloc] init];
            NSMutableDictionary *syncedDictionary = [[NSMutableDictionary alloc] init];
            [syncedDictionary setObject:[dictionary valueForKey:@"table"] forKey:@"tableName"];
            [syncedDictionary setObject:[dictionary valueForKey:@"_ID"] forKey:@"rowID"];
            [syncedDictionary setObject:[dictionary valueForKey:@"type"] forKey:@"type"];
            [syncedDictionary setObject:[def objectForKey:@"UserDeviceId"] forKey:@"androidId"];
            [syncedDictionary setObject:[dictionary valueForKey:@"user_id"] forKey:@"userID"];
            [syncedArray addObject:syncedDictionary];

            [self clearCloudSyncTable:syncedArray];
        }
    }

    
}

- (void)editTrip: (NSDictionary *)dictionary{
    
    NSManagedObjectContext *context = [[CoreDataController sharedInstance] backgroundManagedObjectContext];
    
    //NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSError *error;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"T_Trip"];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"iD == %@", [dictionary valueForKey:@"_ID"]];
    [request setPredicate:predicate];
    NSArray *fetchedData = [context executeFetchRequest:request error:&error];
    
    T_Trip *tripData = [fetchedData firstObject];
    
    NSFetchRequest *vehRequest = [[NSFetchRequest alloc] initWithEntityName:@"Veh_Table"];
    NSError *vehErr;
    NSPredicate *vehPredicate = [NSPredicate predicateWithFormat:@"vehid == %@", [dictionary objectForKey:@"VEHID"]];
    [vehRequest setPredicate:vehPredicate];
    NSArray *vehArray = [context executeFetchRequest:vehRequest error:&vehErr];

    sameRecord = YES;
    if([[dictionary objectForKey:@"sync_with"] isEqualToString:@"friend"]){

        NSString *oldOdoString = [dictionary valueForKey:@"old_odo"];
        NSString *oldSt = [dictionary valueForKey:@"old_st"];
        NSString *logDataString =[NSString stringWithFormat:@"%@",tripData.tripType];
        NSString *logDataOdoString = [NSString stringWithFormat:@"%@",tripData.depOdo];

        NSString *oldOdoDepTrimString;
        NSString *logDataDepTrimString;
        if([oldOdoString containsString:@"."]){

            NSUInteger location = [oldOdoString rangeOfString:@"."].location;
            oldOdoDepTrimString = [oldOdoString substringToIndex:location];
        }else{
            oldOdoDepTrimString = oldOdoString;
        }

        if([logDataOdoString containsString:@"."]){

            NSUInteger location1 = [logDataOdoString rangeOfString:@"."].location;
            logDataDepTrimString = [logDataOdoString substringToIndex:location1];
        }else{
            logDataDepTrimString = logDataOdoString;
        }

        if([logDataDepTrimString isEqualToString:oldOdoDepTrimString]){

            if([logDataString isEqualToString:oldSt]){

                sameRecord = YES;
            }else{

                sameRecord = NO;
            }

        }else{

            sameRecord = NO;
        }

    }

    if(sameRecord){

        if(vehArray.count>0){

            Veh_Table *vehData = [vehArray firstObject];

            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"dd-MMM-yyyy hh:mm a"];

            NSDate *depDate;
            if([dictionary valueForKey:@"DATE"] != nil || ![[dictionary valueForKey:@"DATE"] isEqualToString:@""] ||
               ![[dictionary valueForKey:@"DATE"] isEqualToString:@"0.00"]){
                NSTimeInterval depDateTime = [[dictionary valueForKey:@"DATE"] doubleValue] / 1000;
                NSString *dateString = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:depDateTime] ];
                depDate = [formatter dateFromString:dateString];
            } else {
                depDate = nil;
            }

            NSDate *arrDate;
            NSError *err;
            if([dictionary valueForKey:@"CONSUMPTION"] != nil || ![[dictionary valueForKey:@"CONSUMPTION"] isEqualToString:@""] ||
               ![[dictionary valueForKey:@"CONSUMPTION"] isEqualToString:@"0.00"]){

                NSTimeInterval arrDateTime = [[dictionary valueForKey:@"CONSUMPTION"] doubleValue] / 1000;
                NSString *arrDateString = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:arrDateTime] ];
                arrDate = [formatter dateFromString:arrDateString];
            } else {

                [formatter setDateFormat:@"n/a"];
                arrDate = [formatter dateFromString:@""];

            }
            tripData.vehId = [vehData.iD stringValue];
            tripData.iD = @([[dictionary valueForKey:@"_ID"] floatValue]);
            //logData.type = @([[dictionary valueForKey:@"TYPE"] floatValue]);
            tripData.depOdo = @([[dictionary valueForKey:@"ODO"] floatValue]);
            tripData.arrOdo = @([[dictionary valueForKey:@"QTY"] floatValue]);

            if([NSNull null] != [dictionary valueForKey:@"COST"]){

                tripData.taxDedn = @([[dictionary valueForKey:@"COST"] floatValue]);
            }

            //tripData.taxDedn = @([[dictionary valueForKey:@"COST"] floatValue]);

            if([NSNull null] != [dictionary valueForKey:@"FILLING_STATION"]){

                tripData.arrLocn = [dictionary valueForKey:@"FILLING_STATION"];
            }

            //tripData.arrLocn = [dictionary valueForKey:@"FILLING_STATION"];

            if([NSNull null] != [dictionary valueForKey:@"FUEL_BRAND"]){

                tripData.depLocn = [dictionary valueForKey:@"FUEL_BRAND"];
            }
            //tripData.depLocn = [dictionary valueForKey:@"FUEL_BRAND"];

            if([NSNull null] != [dictionary valueForKey:@"NOTES"]){

                tripData.notes = [dictionary valueForKey:@"NOTES"];
            }

            //tripData.notes = [dictionary valueForKey:@"NOTES"];

            if([NSNull null] != [dictionary valueForKey:@"OCTANE"]){

                tripData.tollAmt = @([[dictionary valueForKey:@"OCTANE"] floatValue]);
            }
            //logData.receipt = [dictionary valueForKey:@"RECEIPT"];

            tripData.tripType = [dictionary valueForKey:@"SERVICE_TYPE"];
            tripData.depDate = depDate;
            tripData.arrDate = arrDate;
            tripData.parkingAmt = @([[dictionary valueForKey:@"DIST"] floatValue]);

            tripData.depLongitude = [NSNumber numberWithDouble:[[dictionary valueForKey:@"DEP_LONG"] doubleValue]];
            tripData.depLatitude = [NSNumber numberWithDouble:[[dictionary valueForKey:@"DEP_LAT"] doubleValue]];
            tripData.arrLongitude = [NSNumber numberWithDouble:[[dictionary valueForKey:@"ARR_LONG"] doubleValue]];
            tripData.arrLatitude = [NSNumber numberWithDouble:[[dictionary valueForKey:@"ARR_LAT"] doubleValue]];

            //If arrOdo is not there, set incomplete trip
            if([[dictionary valueForKey:@"QTY"] floatValue] == 0.0){
                tripData.tripComplete = NO;
            } else {

                //Set trip complete
                tripData.tripComplete = YES;
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
            [[CoreDataController sharedInstance] saveMasterContext];

            if([[dictionary objectForKey:@"sync_with"] isEqualToString:@"friend"]){


                NSString *alertTitle = @"Record Synced";
                NSString *alertBody = [NSString stringWithFormat:@"%@ has just updated a trip for %@",sendByName,[dictionary objectForKey:@"VEHID"]];


                NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
                NSMutableArray *syncedArray = [[NSMutableArray alloc] init];
                NSMutableDictionary *syncedDictionary = [[NSMutableDictionary alloc] init];
                [syncedDictionary setObject:[dictionary valueForKey:@"table"] forKey:@"tableName"];
                [syncedDictionary setObject:[dictionary valueForKey:@"_ID"] forKey:@"rowID"];
                [syncedDictionary setObject:[dictionary valueForKey:@"type"] forKey:@"type"];
                [syncedDictionary setObject:[def objectForKey:@"UserDeviceId"] forKey:@"androidId"];
                [syncedDictionary setObject:[dictionary valueForKey:@"user_id"] forKey:@"userID"];
                [syncedArray addObject:syncedDictionary];

                int success = [self clearCloudSyncTable:syncedArray];

                if(success == 1){

                    NSString *originalSource = [dictionary objectForKey:@"uploaded_by"];

                    [self writeToSyncTableWithRowID:tripData.iD tableName:@"TRIP" andType:@"edit" andOS:originalSource];
                 //   [self writeToSyncTableWithRowID:tripData.iD tableName:@"TRIP" andType:@"edit"];
                    [self checkNetworkForCloudStorage:@"isTrip"];
                }

                [self showNotification:alertTitle :alertBody];
            }
        }else{

            NSString *message = [NSString stringWithFormat:@"%@ not found",[dictionary objectForKey:@"VEHID"]];
            [self showVehicleNotFoundNotification:@"" :message];

            if([[dictionary objectForKey:@"sync_with"] isEqualToString:@"friend"]){

                NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
                NSMutableArray *syncedArray = [[NSMutableArray alloc] init];
                NSMutableDictionary *syncedDictionary = [[NSMutableDictionary alloc] init];
                [syncedDictionary setObject:[dictionary valueForKey:@"table"] forKey:@"tableName"];
                [syncedDictionary setObject:[dictionary valueForKey:@"_ID"] forKey:@"rowID"];
                [syncedDictionary setObject:[dictionary valueForKey:@"type"] forKey:@"type"];
                [syncedDictionary setObject:[def objectForKey:@"UserDeviceId"] forKey:@"androidId"];
                [syncedDictionary setObject:[dictionary valueForKey:@"user_id"] forKey:@"userID"];
                [syncedArray addObject:syncedDictionary];

                [self clearCloudSyncTable:syncedArray];
            }
        }

    }

}

#pragma mark LOCATION add/upd

- (void)saveToLocationTable: (NSDictionary *)dictionary{
    
    if([[dictionary valueForKey:@"type"] isEqualToString:@"add"]){
        [self addNewLocation:dictionary];
    } else if ([[dictionary valueForKey:@"type"] isEqualToString:@"edit"]){
        [self editLocation:dictionary];
    }
}

- (void)addNewLocation: (NSDictionary *)dictionary{
    
    NSManagedObjectContext *context = [[CoreDataController sharedInstance] backgroundManagedObjectContext];
    //NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSError *err;
    Loc_Table *location = [NSEntityDescription insertNewObjectForEntityForName:@"Loc_Table" inManagedObjectContext:context];
    
    location.iD = @([[dictionary valueForKey:@"_ID"] floatValue]);
    location.lat = @([[dictionary valueForKey:@"LATITUDE"] floatValue]);
    location.longitude = @([[dictionary valueForKey:@"LONGITUDE"] floatValue]);
    location.brand = [dictionary objectForKey:@"BRAND"];
    location.address = [dictionary objectForKey:@"ADDRESS"];
    
    if ([context hasChanges])
    {
        BOOL saved = [context save:&err];
        if (!saved) {
            // do some real error handling
            //CLSLog(@"Could not save Data due to %@", err);
        }
        [[CoreDataController sharedInstance] saveBackgroundContext];
    }
    [[CoreDataController sharedInstance] saveMasterContext];

    
}

- (void)editLocation: (NSDictionary *)dictionary{
    
    NSManagedObjectContext *context = [[CoreDataController sharedInstance] backgroundManagedObjectContext];
    NSError *error;
    //NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Loc_Table"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"iD == %@", [dictionary valueForKey:@"_ID"]];
    
    [request setPredicate:predicate];
    
    NSArray *locArray = [context executeFetchRequest:request error:&error];
    NSError *err;
    Loc_Table *locationData = [locArray firstObject];
    
    locationData.iD = @([[dictionary valueForKey:@"_ID"] floatValue]);
    locationData.lat = @([[dictionary valueForKey:@"LATITUDE"] floatValue]);
    locationData.longitude = @([[dictionary valueForKey:@"LONGITUDE"] floatValue]);
    locationData.brand = [dictionary objectForKey:@"BRAND"];
    locationData.address = [dictionary objectForKey:@"ADDRESS"];
    
    if ([context hasChanges])
    {
        BOOL saved = [context save:&err];
        if (!saved) {
            // do some real error handling
            //CLSLog(@“Could not save Data due to %@“, error);
        }
        [[CoreDataController sharedInstance] saveBackgroundContext];
    }
    [[CoreDataController sharedInstance] saveMasterContext];
    
}

#pragma mark SAVE SETTINGS 

-(BOOL)saveSettings:(NSDictionary *)dictionary {
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    
    //SettingsViewController *settingsVC = [[SettingsViewController alloc] init];
    
    if([[dictionary valueForKey:@"_ID"] intValue] == 1){
        
        //Distance unit changed, convert data
        self.distance = [def objectForKey:@"dist_unit"];
        
        NSString *respUnit = [dictionary valueForKey:@"DISTANCE"];
        NSString *distanceUnit = [self convertUnitsToFull:respUnit];
        [def setObject:distanceUnit forKey:@"dist_unit"];
        
        [self convertvalue];
        [self updatedistance];

        self.distance = [def objectForKey:@"dist_unit"];

        if(![[dictionary valueForKey:@"VOLUME"] isEqualToString:NSLocalizedString(@"disp_kilowatt_hour", @"Kilowatt-Hour")]){

            [self updateconsumption];
        }
        
        
    } else if([[dictionary valueForKey:@"_ID"] intValue] == 2){
        
        //Distance unit changed, don't convert data
        self.distance = [def objectForKey:@"dist_unit"];
        
        NSString *respUnit = [dictionary valueForKey:@"DISTANCE"];
        NSString *distanceUnit = [self convertUnitsToFull:respUnit];
        [def setObject:distanceUnit forKey:@"dist_unit"];
        
        self.distance = [def objectForKey:@"dist_unit"];
        if(![[dictionary valueForKey:@"VOLUME"] isEqualToString:NSLocalizedString(@"disp_kilowatt_hour", @"Kilowatt-Hour")]){

            [self updateconsumption];
        }

        
    } else if([[dictionary valueForKey:@"_ID"] intValue] == 3){
        
        //Volume unit changed, convert data
        self.volume = [def objectForKey:@"vol_unit"];
        
        NSString *respUnit = [dictionary valueForKey:@"VOLUME"];
        NSString *volumeUnit = [self convertUnitsToFull:respUnit];
        [def setObject:volumeUnit forKey:@"vol_unit"];
        if(![self.volume isEqualToString:NSLocalizedString(@"disp_kilowatt_hour", @"Kilowatt-Hour")]){

            [self convertvalue];

            self.volume = [def objectForKey:@"vol_unit"];
            [self updateconsumption];
        }

    } else if([[dictionary valueForKey:@"_ID"] intValue] == 4){
        
        //Volume unit changed, convert data
        self.volume = [def objectForKey:@"vol_unit"];
        
        NSString *respUnit = [dictionary valueForKey:@"VOLUME"];
        NSString *volumeUnit = [self convertUnitsToFull:respUnit];
        [def setObject:volumeUnit forKey:@"vol_unit"];
        
        self.volume = [def objectForKey:@"vol_unit"];

        if(![self.volume isEqualToString:NSLocalizedString(@"disp_kilowatt_hour", @"Kilowatt-Hour")]){
            [self updateconsumption];
        }
     
    } else if([[dictionary valueForKey:@"_ID"] intValue] == 5){
        
        //Consumption unit changed
        NSString *respUnit = [dictionary valueForKey:@"CONSUMPTION"];
        if(![respUnit isEqualToString:@"km/kWh"] && ![respUnit isEqualToString:@"m/kWh"]){

            if(![respUnit isEqualToString:@"km/g(US)"] || ![respUnit isEqualToString:@"km/g(UK)"] || ![respUnit isEqualToString:@"mi/L"]){

                self.consump = [def objectForKey:@"con_unit"];

                NSString *consUnit = [self convertUnitsToFull:respUnit];
                [def setObject:consUnit forKey:@"con_unit"];

                self.consump = [def objectForKey:@"con_unit"];
                [self updateconsumption];

            }
        }else{

            [[NSUserDefaults standardUserDefaults] setObject:respUnit forKey:@"con_unit"];
        }
        
    } else if([[dictionary valueForKey:@"_ID"] intValue] == 6){
        
        //Currency unit changed
        self.currency = [def objectForKey:@"curr_unit"];
        
        NSString *respUnit = [dictionary valueForKey:@"CURRENCY"];
        NSString *currUnit = [self convertCurrency:respUnit];
        [def setObject:currUnit forKey:@"curr_unit"];
        
        self.currency = [def objectForKey:@"curr_unit"];
    }
    
      return YES;
}

- (NSString *)convertUnitsToFull: (NSString *)responseUnit{
    
    NSString *convertedUnit;
    
    if([responseUnit isEqualToString:@"mi"]){
        
        convertedUnit = @"Miles";
    } else if ([responseUnit isEqualToString:@"km"]){
        
        convertedUnit = @"Kilometers";

    } else if ([responseUnit isEqualToString:@"kWh"]){

        convertedUnit = @"Kilowatt-Hour";

    } else if ([responseUnit isEqualToString:@"Ltr"]){
        
        convertedUnit = @"Litre";
        
    } else if ([responseUnit isEqualToString:@"gal(US)"]){
        
        convertedUnit = @"Gallon (US)";
        
    } else if ([responseUnit isEqualToString:@"gal(UK)"]){
        
        convertedUnit = @"Gallon (UK)";
        
    }else if ([responseUnit isEqualToString:@"km/kWh"]){

        convertedUnit = @"km/kWh";

    }else if ([responseUnit isEqualToString:@"m/kWh"]){

        convertedUnit = @"m/kWh";

    } else if ([responseUnit isEqualToString:@"km/L"]){
        
        convertedUnit = @"km/L";
        
    } else if ([responseUnit isEqualToString:@"L/100km"]){
        
        convertedUnit = @"L/100km";
        
    } else if ([responseUnit isEqualToString:@"mpg(US)"]){
        
        convertedUnit = @"mpg (US)";
        
    } else if ([responseUnit isEqualToString:@"mpg(UK)"]){
        
        convertedUnit = @"mpg (UK)";
        
    }
    
    return convertedUnit;
    
}

//MARK: After full Download methods
-(void) convertvalue
{
    self.distance = [[NSUserDefaults standardUserDefaults]objectForKey:@"dist_unit"];
    self.volume = [[NSUserDefaults standardUserDefaults]objectForKey:@"vol_unit"];
    self.consump = [[NSUserDefaults standardUserDefaults]objectForKey:@"con_unit"];
    self.currency = [[NSUserDefaults standardUserDefaults]objectForKey:@"curr_unit"];

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
    //commonMethods *commMethods = [[commonMethods alloc] init];
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    for(Veh_Table *veh in vehicle){
        [def setObject:veh.iD forKey:@"fillupid"];
        [self updateDistance:0];
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

   // commonMethods *commMethods = [[commonMethods alloc] init];
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    for(Veh_Table *veh in vehicle){
        [def setObject:veh.iD forKey:@"fillupid"];
        [self updateConsumption:0];
    }
}

-(void)insertservice: (int)statusForUpdateService
{

    NSManagedObjectContext *contex;
    if(statusForUpdateService == 1){

        contex = [[CoreDataController sharedInstance] newManagedObjectContext];
    } else {
        contex = [[CoreDataController sharedInstance] backgroundManagedObjectContext];
    }
    NSError *err;
    NSUserDefaults *Def =[NSUserDefaults standardUserDefaults];
    NSString *comparestring = [NSString stringWithFormat:@"%@",[Def objectForKey:@"fillupid"]];

    NSFetchRequest *requset=[[NSFetchRequest alloc] initWithEntityName:@"T_Fuelcons"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"vehid==%@",comparestring];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"odo"
                                                                   ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [requset setPredicate:predicate];
    [requset setSortDescriptors:sortDescriptors];

    NSArray *datavalue=[contex executeFetchRequest:requset error:&err];
    NSDateFormatter *formater=[[NSDateFormatter alloc] init];
    [formater setDateFormat:@"dd/MM/yyyy"];

    NSManagedObjectContext *contex1 = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSFetchRequest *requset1=[[NSFetchRequest alloc] initWithEntityName:@"Services_Table"];
    NSError *err1;
    NSPredicate *p1=[NSPredicate predicateWithFormat:@"vehid == %@ AND (type==1 OR type==2)",comparestring];
    [requset1 setPredicate:p1];

    NSArray *data1=[contex1 executeFetchRequest:requset1 error:&err1];

    NSMutableArray *recordadded =[[NSMutableArray alloc]init];

    for(Services_Table *service in data1)
    {
        [recordadded addObject:service.serviceName];
    }
    for(T_Fuelcons *fuel in datavalue)
    {

        if(![fuel.serviceType isEqualToString:@"Fuel Record"])
        {
            NSArray *addedservice = [[NSArray alloc]init];

            addedservice =[fuel.serviceType componentsSeparatedByString:@","];

            for(int i =0 ;i<addedservice.count;i++)
            {

                if(data1.count>0)
                {

                    for(int j =0 ;j <data1.count;j++)
                    {

                        Services_Table *fuelrecord = [data1 objectAtIndex:j];

                        if(![fuelrecord.serviceName isEqualToString:[addedservice objectAtIndex:i]] && ![recordadded containsObject:[addedservice objectAtIndex:i]])
                        {

                            [recordadded addObject:[addedservice objectAtIndex:i]];

                            Services_Table *dataval=[NSEntityDescription insertNewObjectForEntityForName:@"Services_Table" inManagedObjectContext:contex];

                            dataval.vehid = comparestring;
                            dataval.serviceName = [addedservice objectAtIndex:i];
                            NSLog(@"common Methods line number 4035:- %@",fuel.stringDate);
                            dataval.lastDate = fuel.stringDate;


                            if ([contex1 hasChanges])
                            {
                                BOOL saved = [contex1 save:&err1];
                                if (!saved) {
                                    // do some real error handling
                                    //CLSLog(@“Could not save Data due to %@“, error);
                                }
                                [[CoreDataController sharedInstance] saveMasterContext];

                            }

                        }


                        else if ([fuelrecord.serviceName isEqualToString:[addedservice objectAtIndex:i]])

                        {

                            [recordadded addObject:[addedservice objectAtIndex:i]];
                            NSLog(@"common Methods line number 4058:- %@",fuel.stringDate);
                            fuelrecord.lastDate = fuel.stringDate;

                            if ([contex1 hasChanges])
                            {
                                BOOL saved = [contex1 save:&err1];
                                if (!saved) {
                                    // do some real error handling
                                    //CLSLog(@“Could not save Data due to %@“, error);
                                }
                                [[CoreDataController sharedInstance] saveMasterContext];

                            }


                        }

                    }
                }
                else
                {
                    Services_Table *dataval=[NSEntityDescription insertNewObjectForEntityForName:@"Services_Table" inManagedObjectContext:contex];

                    [recordadded addObject:[addedservice objectAtIndex:i]];
                    
                    dataval.vehid = comparestring;
                    dataval.serviceName = [addedservice objectAtIndex:i];
                    NSLog(@"common Methods line number 4085:- %@",fuel.stringDate);
                    dataval.lastDate = fuel.stringDate;

                    if ([contex1 hasChanges])
                    {
                        BOOL saved = [contex1 save:&err1];
                        if (!saved) {
                            // do some real error handling
                            //CLSLog(@“Could not save Data due to %@“, error);
                        }
                        [[CoreDataController sharedInstance] saveMasterContext];

                    }

                }

            }
        }
    }

}

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
                    NSLog(@"common Methods line number 4164:- %@",newLastDate);
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


- (NSString *)convertCurrency: (NSString *)responseUnit{
    
    NSString *convertedCurrency;
    
    NSMutableArray *currencyArray = [[NSMutableArray alloc]initWithObjects:@"Afghan afghani - AFN",
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
    
    for (int i = 0; i < currencyArray.count; i++) {
        
        if([[currencyArray objectAtIndex:i] hasSuffix:responseUnit]){
            
            convertedCurrency = [currencyArray objectAtIndex:i];
        }
    }
    
    return convertedCurrency;
}

//MARK: Cloud Upload methods
//Save rowID, tableName, and type in phones Sync table
- (void)writeToSyncTableWithRowID: (NSNumber *)rowID tableName: (NSString *)tableName andType: (NSString *)type andOS: (NSString *)originalSource{

    NSManagedObjectContext *context = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSError *err;
    Sync_Table *syncData = [NSEntityDescription insertNewObjectForEntityForName:@"Sync_Table" inManagedObjectContext:context];

    syncData.rowID = rowID;
    syncData.tableName = tableName;
    syncData.type = type;
    syncData.processing = @0;
    syncData.originalSource = originalSource;

    if ([context hasChanges])
    {
        BOOL saved = [context save:&err];
        if (!saved) {
            // do some real error handling
            //CLSLog(@“Could not save Data due to %@“, error);
        }
        [[CoreDataController sharedInstance] saveMasterContext];
    }
}

- (void)checkNetworkForCloudStorage:(NSString *)isTrip{

    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];

    NSUserDefaults *Def = [NSUserDefaults standardUserDefaults];
    if(networkStatus == NotReachable){

        [CheckReachability.sharedManager startNetworkMonitoring];
    } else {

        NSString *userEmail = [Def objectForKey:@"UserEmail"];

        //If user is signed In, then only do the sync process...
        if(userEmail != nil && userEmail.length > 0){

            dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{

                [self fetchDataFromSyncTable:isTrip];


            });

//            if([isTrip isEqualToString:@"isTrip"]){
//
//                [self performSelectorInBackground:@selector(fetchDataFromSyncTableForTrips) withObject:nil];
//            }else if([isTrip isEqualToString:@"isDel"]){
//
//                [self performSelectorInBackground:@selector(fetchDataFromSyncTableForDelete) withObject:nil];
//            }else if([isTrip isEqualToString:@"isVehicle"]){
//
//                [self performSelectorInBackground:@selector(fetchDataFromSyncTableForVehicle) withObject:nil];
//            }else if([isTrip isEqualToString:@"isSettings"]){
//
//                [self performSelectorInBackground:@selector(fetchDataFromSyncTableForSettings) withObject:nil];
//            }else if([isTrip isEqualToString:@"isService"]){
//
//                [self performSelectorInBackground:@selector(fetchDataFromSyncTableForServices) withObject:nil];
//            }else if([isTrip isEqualToString:@"isReminder"]){
//
//                [self performSelectorInBackground:@selector(fetchDataFromSyncTableForReminders) withObject:nil];
//            }else if([isTrip isEqualToString:@"isDeleteVehicle"]){
//
//                [self performSelectorInBackground:@selector(fetchDataFromSyncTableForDeleteVehicle) withObject:nil];
//            }else{
//
//                [self performSelectorInBackground:@selector(fetchDataFromSyncTable) withObject:nil];
//            }
        }

    }
}

//Loop through the Phone Sync table, fetch table name, type (add, edit, del) and rowID of record
- (void)fetchDataFromSyncTable:(NSString *)isTrip{

    NSManagedObjectContext *context = [[CoreDataController sharedInstance] backgroundManagedObjectContext];
    NSError *error;

    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Sync_Table"];
   // NSPredicate *predicate = [NSPredicate predicateWithFormat:@"tableName == 'LOG_TABLE' OR tableName == 'LOC_TABLE'"];
   // [request setPredicate:predicate];
    NSArray *dataArray = [context executeFetchRequest:request error:&error];

    for(Sync_Table *syncData in dataArray){

        NSString *type = syncData.type;
        //NSString *originalSource = syncData.originalSource;
        NSError *err;
        //NSInteger rowID = [syncData.rowID integerValue];
        if(syncData.rowID == nil){


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

            if([syncData.processing  isEqual: @0]){

                syncData.processing = @1;
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

                if([isTrip isEqualToString:@"isTrip"]){

                    [self setParametersWithTypeForTrips:type andRowID:syncData.rowID andTableName:syncData.tableName andOS:syncData.originalSource];
                }else if([isTrip isEqualToString:@"isDel"]){

                    [self setParametersWithTypeForDelete:type andRowID:syncData.rowID andTableName:syncData.tableName andOS:syncData.originalSource];
                }else if([isTrip isEqualToString:@"isVehicle"]){

                    [self setTypeForVehcile:type andRowID:syncData.rowID andTableName:syncData.tableName andOS:syncData.originalSource];
                }else if([isTrip isEqualToString:@"isSettings"]){

                    [self setParametersWithNewVal:syncData.type andRowID:syncData.rowID andTableName:syncData.tableName andOS:syncData.originalSource];
                }else if([isTrip isEqualToString:@"isService"]){

                    [self setTypeForServices:type andRowID:syncData.rowID andTableName:syncData.tableName andOS:syncData.originalSource];
                }else if([isTrip isEqualToString:@"isReminder"]){

                    [self setTypeForReminders:type andRowID:syncData.rowID andTableName:syncData.tableName andOS:syncData.originalSource];
                }else if([isTrip isEqualToString:@"isDeleteVehicle"]){

                     [self setParametersWithTypeForDeleteVehicle:type andRowID:syncData.rowID andTableName:syncData.tableName andOS:syncData.originalSource];
                }else if([isTrip isEqualToString:@"isServiceRating"]){

                    [self setParametersWithTypeForServiceCenter:type andRowID:syncData.rowID andTableName:syncData.tableName andOS:syncData.originalSource];
                }else{

                    [self setParametersWithType:type andRowID:syncData.rowID andTableName:syncData.tableName andOS:syncData.originalSource];
                }

            }else{

                [self clearPhoneSyncTableWithID:syncData.rowID tableName:syncData.tableName andType:type];
            }

        }

    }
}


////Loop through the Phone Sync table, fetch table name, type (add, edit, del) and rowID of record
//- (void)fetchDataFromSyncTableAdhicha{
//
//    NSManagedObjectContext *context = [[CoreDataController sharedInstance] backgroundManagedObjectContext];
//    NSError *error;
//
//    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Sync_Table"];
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"tableName == 'LOG_TABLE' OR tableName == 'LOC_TABLE'"];
//    [request setPredicate:predicate];
//    NSArray *dataArray = [context executeFetchRequest:request error:&error];
//
//    for(Sync_Table *syncData in dataArray){
//
//        NSString *type = syncData.type;
//        //NSInteger rowID = [syncData.rowID integerValue];
//        if(syncData.rowID == nil){
//
//            NSError *err;
//            if(syncData != nil){
//
//                [context deleteObject:syncData];
//            }
//
//            if ([context hasChanges])
//            {
//                BOOL saved = [context save:&err];
//                if (!saved) {
//                    // do some real error handling
//                    //CLSLog(@“Could not save Data due to %@“, error);
//                }
//                [[CoreDataController sharedInstance] saveBackgroundContext];
//                [[CoreDataController sharedInstance] saveMasterContext];
//            }
//        }else{
//
//            [self setParametersWithType:type andRowID:syncData.rowID andTableName:syncData.tableName];
//        }
//
//    }
//}

//Loop thr' the specified tableName and get record for specified rowID
- (void)setParametersWithType: (NSString *)type andRowID: (NSNumber *)rowID andTableName: (NSString *)tableName andOS:(NSString *)originalSource{

    NSManagedObjectContext *contex = [[CoreDataController sharedInstance] backgroundManagedObjectContext];

    if([tableName isEqualToString:@"LOG_TABLE"]){

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

        if(vehData.count){

            Veh_Table *vehicleData = [vehData firstObject];

            //commonMethods *common = [[commonMethods alloc] init];
            NSDictionary *epochDictionary = [self getDayMonthYrFromStringDate:logData.stringDate];

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
            if(originalSource != nil){

                [parametersDictionary setObject:originalSource forKey:@"originalSource"];
            }else{

                [parametersDictionary setObject:@"self" forKey:@"originalSource"];
            }

//            if(sendByEmail){
//
//                [parametersDictionary setObject:sendByEmail forKey:@"originalSource"];
//            }else{
//
//                [parametersDictionary setObject:@"self" forKey:@"originalSource"];
//            }


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
                    }else{

                        NSLog(@"imageString is nill in 4312 common methods setparameters");
                    }

                }
                NSString *colonString = [NSString stringWithFormat:@"%@:::",logData.receipt];
                [parametersDictionary setObject:colonString forKey:@"receipt"];
                //   if(separatedArray.count>1){
                if(receiptDict != nil){

                    [parametersDictionary setObject:receiptDict forKey:@"img_file"];
                }else{

                    NSLog(@"receiptDict is nill in 4324 common methods setparameters");
                }

                //                }else{
                //
                //                    [parametersDictionary setObject:imageString forKey:@"img_file"];
                //                }
            } else {

                [parametersDictionary setObject:@"" forKey:@"receipt"];
                [parametersDictionary setObject:@"" forKey:@"img_file"];
            }

           // NSLog(@"Log params dict : %@", parametersDictionary);

            NSData *postData = [NSJSONSerialization dataWithJSONObject:parametersDictionary options:NSJSONWritingPrettyPrinted error:&error];
            [def setBool:YES forKey:@"updateTimeStamp"];
            //Pass paramters dictionary and URL of script to get response
            [self saveToCloud:postData urlString:kLogDataScript success:^(NSDictionary *responseDict) {
                // NSLog(@"responseDict LOG : %@", responseDict);

                 if([[responseDict objectForKey:@"message"] isEqualToString:@"Success"]){

                    if([responseDict objectForKey:@"id_changed"] != nil){


                        [self getChangedIDAndReplaceCurrentID:logData.iD:[responseDict objectForKey:@"id_changed"]:tableName];

                    }

                    [self clearPhoneSyncTableWithID:rowID tableName:tableName andType:type];

                }
            } failure:^(NSError *error) {
                // NSLog(@"%@", error.localizedDescription);
            }];
        }else{

            NSLog(@"VNFSN");
        }

        //   }];

    } else if ([tableName isEqualToString:@"LOC_TABLE"]){

        NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
        NSError *locErr;
        NSFetchRequest *locRequest = [[NSFetchRequest alloc] initWithEntityName:@"Loc_Table"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"iD == %d", [rowID intValue]];
        [locRequest setPredicate:predicate];

        NSArray *locArray = [contex executeFetchRequest:locRequest error:&locErr];

        if(locArray.count>0){

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

            //NSLog(@"Log params dict : %@", parametersDictionary);

            NSError *error;
            NSData *postData = [NSJSONSerialization dataWithJSONObject:parametersDictionary options:NSJSONWritingPrettyPrinted error:&error];
            [def setBool:YES forKey:@"updateTimeStamp"];
            //commonMethods *common = [[commonMethods alloc] init];
            //Pass paramters dictionary and URL of script to get response
            [self saveToCloud:postData urlString:kLocationScript success:^(NSDictionary *responseDict) {
                //NSLog(@"responseDict LOG : %@", responseDict);

                if([[responseDict objectForKey:@"message"] isEqualToString:@"Success"]){

                    if([responseDict objectForKey:@"id_changed"] != nil){


                        [self getChangedIDAndReplaceCurrentID:locationData.iD:[responseDict objectForKey:@"id_changed"]:tableName];

                    }
                    [self clearPhoneSyncTableWithID:rowID tableName:tableName andType:type];
                }
            } failure:^(NSError *error) {
                //NSLog(@"%@", error.localizedDescription);
            }];
        }
    }
}

////FOR TRIPS
////Loop through the Sync table, fetch table name, type (add, edit, del) and rowID of record
//- (void)fetchDataFromSyncTableForTrips{
//
//    NSManagedObjectContext *context = [[CoreDataController sharedInstance] backgroundManagedObjectContext];
//    NSError *err;
//
//    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Sync_Table"];
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"tableName == 'TRIP' OR tableName == 'LOC_TABLE'"];
//    [request setPredicate:predicate];
//    NSArray *dataArray = [context executeFetchRequest:request error:&err];
//
//    for(Sync_Table *syncData in dataArray){
//
//        NSString *type = syncData.type;
//        //NSInteger rowID = [syncData.rowID integerValue];
//        if(syncData.rowID == nil){
//
//            NSError *err;
//            if(syncData != nil){
//
//                [context deleteObject:syncData];
//            }
//
//            if ([context hasChanges])
//            {
//                BOOL saved = [context save:&err];
//                if (!saved) {
//                    // do some real error handling
//                    //CLSLog(@“Could not save Data due to %@“, error);
//                }
//                [[CoreDataController sharedInstance] saveBackgroundContext];
//                [[CoreDataController sharedInstance] saveMasterContext];
//            }
//        }else{
//
//            [self setParametersWithTypeForTrips:type andRowID:syncData.rowID andTableName:syncData.tableName];
//        }
//
//    }
//}

//Loop thr' the specified tableName and get record for specified rowID
- (void)setParametersWithTypeForTrips: (NSString *)type andRowID: (NSNumber *)rowID andTableName: (NSString *)tableName andOS:(NSString *)originalSource{
    ;
    NSManagedObjectContext *context = [[CoreDataController sharedInstance] backgroundManagedObjectContext];
    NSError *err;
    if([tableName isEqualToString:@"TRIP"]){

        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"T_Trip"];
        NSPredicate *iDPredicate = [NSPredicate predicateWithFormat:@"iD == %d", [rowID intValue]];
        [request setPredicate:iDPredicate];

        NSArray *fetchedData = [context executeFetchRequest:request error:&err];

        if(fetchedData.count>0){

            T_Trip *tripData = [fetchedData firstObject];


            NSFetchRequest *vehRequest = [[NSFetchRequest alloc] initWithEntityName:@"Veh_Table"];
            NSPredicate *vehPredicate = [NSPredicate predicateWithFormat:@"iD == %d", [tripData.vehId intValue]];
            [vehRequest setPredicate:vehPredicate];

            NSArray *vehData = [context executeFetchRequest:vehRequest error:&err];


            if(vehData.count>0){

                Veh_Table *vehicleData = [vehData firstObject];


                //commonMethods *common = [[commonMethods alloc] init];
                NSDictionary *epochDictionary = [self getDayMonthYrFromStringDate:tripData.depDate];


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
                if(originalSource != nil){

                    [parametersDictionary setObject:originalSource forKey:@"originalSource"];
                }else{

                    [parametersDictionary setObject:@"self" forKey:@"originalSource"];
                }
                //[parametersDictionary setObject:originalSource forKey:@"originalSource"];
//                if(sendByEmail){
//
//                    [parametersDictionary setObject:sendByEmail forKey:@"originalSource"];
//                }else{
//
//                    [parametersDictionary setObject:@"self" forKey:@"originalSource"];
//                }


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
                NSDictionary *depDT = [self getDayMonthYrFromStringDate:tripData.depDate];

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
                    NSDictionary *epochArrival = [self getDayMonthYrFromStringDate:tripData.arrDate];
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
                [self saveToCloud:postData urlString:kLogDataScript success:^(NSDictionary *responseDict) {
                    //NSLog(@"responseDict LOG : %@", responseDict);

                    if([[responseDict objectForKey:@"message"] isEqualToString:@"Success"]){

                        if([responseDict objectForKey:@"id_changed"] != nil){


                            [self getChangedIDAndReplaceCurrentID:tripData.iD:[responseDict objectForKey:@"id_changed"]:tableName];

                        }
                        [self clearPhoneSyncTableWithID:rowID tableName:tableName andType:type];
                    }

                } failure:^(NSError *error) {
                    //  NSLog(@"%@", error.localizedDescription);
                }];
            }else{

                NSLog(@"NVFSN");
            }

        }

    } else if ([tableName isEqualToString:@"LOC_TABLE"]){

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
        //commonMethods *common = [[commonMethods alloc] init];
        //Pass paramters dictionary and URL of script to get response
        [self saveToCloud:postData urlString:kLocationScript success:^(NSDictionary *responseDict) {
            // NSLog(@"responseDict LOG : %@", responseDict);

            if([[responseDict objectForKey:@"message"] isEqualToString:@"Success"]){

                if([responseDict objectForKey:@"id_changed"] != nil){


                    [self getChangedIDAndReplaceCurrentID:locationData.iD:[responseDict objectForKey:@"id_changed"]:tableName];

                }
                [self clearPhoneSyncTableWithID:rowID tableName:tableName andType:type];
            }
        } failure:^(NSError *error) {
            //          NSLog(@"%@", error.localizedDescription);
        }];
    }
}

////For delete logs
////Loop through the Phone Sync table, fetch table name, type (add, edit, del) and rowID of record
//- (void)fetchDataFromSyncTableForDelete{
//
//    NSManagedObjectContext *context = [[CoreDataController sharedInstance] backgroundManagedObjectContext];
//    NSError *error;
//
//    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Sync_Table"];
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"tableName == 'LOG_TABLE' OR tableName == 'LOC_TABLE'"];
//    [request setPredicate:predicate];
//    NSArray *dataArray = [context executeFetchRequest:request error:&error];
//   // NSLog(@"dataArray:- %@",dataArray);
//
//    for(Sync_Table *syncData in dataArray){
//
//        NSString *type = syncData.type;
//        //NSInteger rowID = [syncData.rowID integerValue];
//        if(syncData.rowID == nil){
//
//            NSError *err;
//            if(syncData != nil){
//
//                [context deleteObject:syncData];
//            }
//
//            if ([context hasChanges])
//            {
//                BOOL saved = [context save:&err];
//                if (!saved) {
//                    // do some real error handling
//                    //CLSLog(@“Could not save Data due to %@“, error);
//                }
//                [[CoreDataController sharedInstance] saveBackgroundContext];
//                [[CoreDataController sharedInstance] saveMasterContext];
//            }
//        }else{
//
//            [self setParametersWithTypeForDelete:type andRowID:syncData.rowID andTableName:syncData.tableName];
//        }
//
//    }
//}

//Loop thr' the specified tableName and delete record for specified rowID
- (void)setParametersWithTypeForDelete: (NSString *)type andRowID: (NSNumber *)rowID andTableName: (NSString *)tableName andOS:(NSString *)originalSource{

    //commonMethods *common = [[commonMethods alloc] init];

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
    if(originalSource != nil){

        [parametersDictionary setObject:originalSource forKey:@"originalSource"];
    }else{

        [parametersDictionary setObject:@"self" forKey:@"originalSource"];
    }
    //[parametersDictionary setObject:originalSource forKey:@"originalSource"];
//    if(sendByEmail){
//
//        [parametersDictionary setObject:sendByEmail forKey:@"originalSource"];
//    }else{
//
//        [parametersDictionary setObject:@"self" forKey:@"originalSource"];
//    }

    //NSLog(@"rowID::%@ or type::%@",rowID,type);
    [parametersDictionary setObject:rowID forKey:@"_id"];
    [parametersDictionary setObject:[def objectForKey:@"UserDeviceId"] forKey:@"androidId"];


    //NSLog(@"Log params dict : %@", parametersDictionary);

    NSError *err;
    NSData *postData = [NSJSONSerialization dataWithJSONObject:parametersDictionary options:NSJSONWritingPrettyPrinted error:&err];
    [def setBool:YES forKey:@"updateTimeStamp"];
    //Pass paramters dictionary and URL of script to get response
    [self saveToCloud:postData urlString:kLogDataScript success:^(NSDictionary *responseDict) {
        //  NSLog(@"responseDict LOG : %@", responseDict);

        if([[responseDict objectForKey:@"message"] isEqualToString:@"Success"]){

            [self clearPhoneSyncTableWithID:rowID tableName:tableName andType:type];
        }
    } failure:^(NSError *error) {
        //  NSLog(@"%@", error.localizedDescription);
    }];
}

- (void)setParametersWithTypeForServiceCenter: (NSString *)type andRowID: (NSNumber *)rowID andTableName: (NSString *)tableName andOS:(NSString *)originalSource{

    NSManagedObjectContext *contex = [[CoreDataController sharedInstance] backgroundManagedObjectContext];

    NSError *error;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"SERVICE_CENTER_RATING"];
   // NSPredicate *iDPredicate = [NSPredicate predicateWithFormat:@"iD == %d", [rowID intValue]];
   // [request setPredicate:iDPredicate];

    NSArray *fetchedData = [contex executeFetchRequest:request error:&error];

    //SERVICE_CENTER_RATING *ratingData = [fetchedData firstObject];

    for(SERVICE_CENTER_RATING *ratingData in fetchedData){

        if(ratingData){

            NSMutableDictionary *parametersDictionary = [[NSMutableDictionary alloc] init];
            NSUserDefaults *def = [NSUserDefaults standardUserDefaults];

            if(ratingData.email){

                [parametersDictionary setObject:ratingData.email forKey:@"email"];
            }

            if(ratingData.name){

                [parametersDictionary setObject:ratingData.name forKey:@"name"];
            }

            if(ratingData.address){

                [parametersDictionary setObject:ratingData.address forKey:@"address"];
            }

            if(ratingData.lat){

                [parametersDictionary setObject:ratingData.lat forKey:@"lat"];
            }

            if(ratingData.longi){

                [parametersDictionary setObject:ratingData.longi forKey:@"long"];
            }

            if(ratingData.rating){

                [parametersDictionary setObject:ratingData.rating forKey:@"rating"];
            }

            if(ratingData.comments){

                [parametersDictionary setObject:ratingData.comments forKey:@"comments"];
            }

            if(ratingData.services){

                [parametersDictionary setObject:ratingData.services forKey:@"services"];
            }

            if(ratingData.cost){

                [parametersDictionary setObject:ratingData.cost forKey:@"cost"];
            }

            if(ratingData.curr){

                [parametersDictionary setObject:ratingData.curr forKey:@"curr"];
            }

            NSTimeInterval unixTimeStamp = [ratingData.date timeIntervalSince1970] * 1000;
            NSString *unixTime = [NSString stringWithFormat:@"%.0f", unixTimeStamp];

            [parametersDictionary setObject:unixTime forKey:@"date"];

            if(ratingData.phone_number){

                [parametersDictionary setObject:ratingData.phone_number forKey:@"phone_num"];
            }

            if(ratingData.website){

                [parametersDictionary setObject:ratingData.website forKey:@"website"];
            }


            NSLog(@"rating params dict : %@", parametersDictionary);

            NSData *postData = [NSJSONSerialization dataWithJSONObject:parametersDictionary options:NSJSONWritingPrettyPrinted error:&error];
            [def setBool:NO forKey:@"updateTimeStamp"];
            //Pass paramters dictionary and URL of script to get response
            [self saveToCloud:postData urlString:kServiceRatingScript success:^(NSDictionary *responseDict) {
                // NSLog(@"responseDict LOG : %@", responseDict);

                if([[responseDict objectForKey:@"message"] isEqualToString:@"Success"]){

                    [self clearPhoneSyncTableWithID:rowID tableName:tableName andType:type];
                    [self clearFromServiceCenterTable:rowID];
                }
            } failure:^(NSError *error) {
                // NSLog(@"%@", error.localizedDescription);
            }];
        }else{

            NSLog(@"VNFSN");
        }
    }

}

//Loop thr' the specified tableName and get record for specified rowID
- (void)setTypeForVehcile: (NSString *)type andRowID: (NSNumber *)rowID andTableName: (NSString *)tableName andOS:(NSString *)originalSource{

    NSManagedObjectContext *context = [[CoreDataController sharedInstance] backgroundManagedObjectContext];
    NSError *err;
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];

    if([tableName isEqualToString:@"VEH_TABLE"]){

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

            [dictionary setObject:imageString forKey:@"img_file"];
            [dictionary setObject:vehData.picture forKey:@"picture"];
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
            //    NSLog(@"Vehicle responseDict : %@", responseDict);

            if([[responseDict objectForKey:@"message"] isEqualToString:@"Success"]){

                //If response is succes, clear that record from phone sync table
                if([responseDict objectForKey:@"id_changed"] != nil){

                    [self getChangedIDAndReplaceCurrentID:vehData.iD:[responseDict objectForKey:@"id_changed"]:tableName];

                }
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
                if([responseDict objectForKey:@"id_changed"] != nil){

                    [self getChangedIDAndReplaceCurrentID:serviceData.iD:[responseDict objectForKey:@"id_changed"]:tableName];

                }
                [common clearPhoneSyncTableWithID:rowID tableName:tableName andType:type];

            }
        } failure:^(NSError *error) {
            //NSLog(@"%@", error.localizedDescription);
        }];

    }

}

//Loop thr' the specified tableName and get record for specified rowID
- (void)setParametersWithNewVal: (NSString *)newVal andRowID: (NSNumber *)rowID andTableName: (NSString *)tableName andOS:(NSString *)originalSource{

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

//Loop thr' the specified tableName and get record for specified rowID
- (void)setTypeForServices: (NSString *)type andRowID: (NSNumber *)rowID andTableName: (NSString *)tableName andOS:(NSString *)originalSource{

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

            if([responseDict objectForKey:@"id_changed"] != nil){

                [self getChangedIDAndReplaceCurrentID:serviceData.iD:[responseDict objectForKey:@"id_changed"]:tableName];

            }
            [common clearPhoneSyncTableWithID:rowID tableName:tableName andType:type];

        }
    } failure:^(NSError *error) {
        // NSLog(@"%@", error.localizedDescription);
    }];

}

//Loop thr' the specified tableName and delete record for specified rowID
- (void)setTypeForReminders: (NSString *)type andRowID: (NSNumber *)rowID andTableName: (NSString *)tableName andOS:(NSString *)originalSource{

    NSError *err;
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];

    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];

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

    commonMethods *common = [[commonMethods alloc] init];
    // NSLog(@"service val : %@", dictionary);

    NSData *postData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:&err];
    [def setBool:YES forKey:@"updateTimeStamp"];
    //Pass parameters dictionary and URL of script to get response
    [common saveToCloud:postData urlString:kServiceDataScript success:^(NSDictionary *responseDict) {
        //  NSLog(@"Service responseDict : %@", responseDict);

        if([[responseDict objectForKey:@"message"] isEqualToString:@"Success"]){


            [common clearPhoneSyncTableWithID:rowID tableName:tableName andType:type];

        }
    } failure:^(NSError *error) {
        //  NSLog(@"%@", error.localizedDescription);
    }];

}

//Loop thr' the specified tableName and delete record for specified rowID
- (void)setParametersWithTypeForDeleteVehicle: (NSString *)type andRowID: (NSNumber *)rowID andTableName: (NSString *)tableName andOS:(NSString *)originalSource{

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


@end
