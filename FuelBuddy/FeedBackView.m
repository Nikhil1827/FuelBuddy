//
//  FeedBackView.m
//  FuelBuddy
//
//  Created by Nikhil on 08/07/19.
//  Copyright © 2019 Oraganization. All rights reserved.
//

#import "FeedBackView.h"
#import "commonMethods.h"
#import "WebServiceURL's.h"
#import "Reachability.h"
#import "CheckReachability.h"
#import "CoreDataController.h"
#import "T_Fuelcons.h"
#import "SERVICE_CENTER_RATING+CoreDataClass.h"
#import "Sync_Table.h"

@implementation FeedBackView{

    NSNumber *rating;
    
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{

    self = [super initWithCoder:aDecoder];

    if(self){

        [self customInit];
    }

    return self;

}

-(instancetype)initWithFrame:(CGRect)frame{

    self = [super initWithFrame:frame];

    if(self){

        [self customInit];
    }

    return self;
}

-(void)customInit{

    rating = @3;
    self.cmntsTextView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    self.feedBackDataDict = [[NSMutableDictionary alloc] init];
    [[NSBundle mainBundle] loadNibNamed:@"FeedbackView" owner:self options:nil];
    [self addSubview:self.contentView];
    self.contentView.frame = self.bounds;

}

- (IBAction)closeTapped:(id)sender {

    [self removeFromSuperview];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"feedBackViewDismissed"
                                                        object:nil];
}

- (IBAction)rating1Tapped:(id)sender {

    //NSLog(@"rating 1 Tapped");
    rating = @1;
    [self.rating1OLT setImage:[UIImage imageNamed:@"ic_star_rate_yes"] forState: UIControlStateNormal];
   // NSLog(@"star image yes :- %@",[UIImage imageNamed:@"ic_star_rate_yes"]);
    [self.rating2OLT setImage:[UIImage imageNamed:@"ic_star_rate_no"] forState: UIControlStateNormal];
  //  NSLog(@"star image no :- %@",[UIImage imageNamed:@"ic_star_rate_no"]);
    [self.rating3OLT setImage:[UIImage imageNamed:@"ic_star_rate_no"] forState: UIControlStateNormal];
    [self.rating4OLT setImage:[UIImage imageNamed:@"ic_star_rate_no"] forState: UIControlStateNormal];
    [self.rating5OLT setImage:[UIImage imageNamed:@"ic_star_rate_no"] forState: UIControlStateNormal];
}

- (IBAction)rating2Tapped:(id)sender {

   // NSLog(@"rating 2 Tapped");
    rating = @2;
    [self.rating1OLT setImage:[UIImage imageNamed:@"ic_star_rate_yes"] forState: UIControlStateNormal];
    [self.rating2OLT setImage:[UIImage imageNamed:@"ic_star_rate_yes"] forState: UIControlStateNormal];
    [self.rating3OLT setImage:[UIImage imageNamed:@"ic_star_rate_no"] forState: UIControlStateNormal];
    [self.rating4OLT setImage:[UIImage imageNamed:@"ic_star_rate_no"] forState: UIControlStateNormal];
    [self.rating5OLT setImage:[UIImage imageNamed:@"ic_star_rate_no"] forState: UIControlStateNormal];

}

- (IBAction)rating3Tapped:(id)sender {

   // NSLog(@"rating 3 Tapped");
    rating = @3;
    [self.rating1OLT setImage:[UIImage imageNamed:@"ic_star_rate_yes"] forState: UIControlStateNormal];
    [self.rating2OLT setImage:[UIImage imageNamed:@"ic_star_rate_yes"] forState: UIControlStateNormal];
    [self.rating3OLT setImage:[UIImage imageNamed:@"ic_star_rate_yes"] forState: UIControlStateNormal];
    [self.rating4OLT setImage:[UIImage imageNamed:@"ic_star_rate_no"] forState: UIControlStateNormal];
    [self.rating5OLT setImage:[UIImage imageNamed:@"ic_star_rate_no"] forState: UIControlStateNormal];
}
- (IBAction)rating4Tapped:(id)sender {

   // NSLog(@"rating 4 Tapped");
    rating = @4;
    [self.rating1OLT setImage:[UIImage imageNamed:@"ic_star_rate_yes"] forState: UIControlStateNormal];
    [self.rating2OLT setImage:[UIImage imageNamed:@"ic_star_rate_yes"] forState: UIControlStateNormal];
    [self.rating3OLT setImage:[UIImage imageNamed:@"ic_star_rate_yes"] forState: UIControlStateNormal];
    [self.rating4OLT setImage:[UIImage imageNamed:@"ic_star_rate_yes"] forState: UIControlStateNormal];
    [self.rating5OLT setImage:[UIImage imageNamed:@"ic_star_rate_no"] forState: UIControlStateNormal];
}
- (IBAction)rating5Tapped:(id)sender {

  //  NSLog(@"rating 5 Tapped");
    rating = @5;
    [self.rating1OLT setImage:[UIImage imageNamed:@"ic_star_rate_yes"] forState: UIControlStateNormal];
    [self.rating2OLT setImage:[UIImage imageNamed:@"ic_star_rate_yes"] forState: UIControlStateNormal];
    [self.rating3OLT setImage:[UIImage imageNamed:@"ic_star_rate_yes"] forState: UIControlStateNormal];
    [self.rating4OLT setImage:[UIImage imageNamed:@"ic_star_rate_yes"] forState: UIControlStateNormal];
    [self.rating5OLT setImage:[UIImage imageNamed:@"ic_star_rate_yes"] forState: UIControlStateNormal];
}
- (IBAction)submitTapped:(id)sender {

    //changeDateToDateString


    NSTimeInterval unixTimeStamp = [[_feedBackDataDict objectForKey:@"date"] timeIntervalSince1970];
    NSString *unixTime = [NSString stringWithFormat:@"%.0f", unixTimeStamp];

    if(unixTime != nil){
        [_feedBackDataDict setObject:unixTime forKey:@"date"];
    } else {
        [_feedBackDataDict setObject:@"" forKey:@"date"];
    }

    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [self.feedBackDataDict setObject:[def objectForKey:@"curr_unit"] forKey:@"curr"];
    [self.feedBackDataDict setObject:rating forKey:@"rating"];
    [self.feedBackDataDict setObject:_cmntsTextView.text forKey:@"comments"];
   // NSLog(@"feedBackDataDict:- %@",_feedBackDataDict);

    [self saveDataIntoDatabase:_feedBackDataDict];

//    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
//    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];

//    if(networkStatus == NotReachable){
//
//        [CheckReachability.sharedManager startNetworkMonitoring];
//        [self saveDataIntoDatabase:_feedBackDataDict];
//
//    } else {
//
//        // send data to server
//        commonMethods *common = [[commonMethods alloc] init];
//        NSError *err;
//        [def setBool:NO forKey:@"updateTimeStamp"];
//        NSLog(@"_feedBackDataDict:- %@",_feedBackDataDict);
//        NSData *postData = [NSJSONSerialization dataWithJSONObject:self.feedBackDataDict options:NSJSONWritingPrettyPrinted error:&err];
//        //Pass paramters dictionary and URL of script to get response
//        [common saveToCloud:postData urlString:kServiceRatingScript success:^(NSDictionary *responseDict) {
//            //  NSLog(@"responseDict LOG : %@", responseDict);
//
//            if([[responseDict objectForKey:@"message"] isEqualToString:@"Success"]){
//
//                NSLog(@"rating sent");
//
//            }
//        } failure:^(NSError *error) {
//            //  NSLog(@"%@", error.localizedDescription);
//        }];
//
//    }

    [self removeFromSuperview];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"feedBackViewDismissed"
                                                        object:nil];
}

-(void)saveDataIntoDatabase:(NSMutableDictionary *)dict{

    NSManagedObjectContext *contex = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSError *err;

    SERVICE_CENTER_RATING *dataval=[NSEntityDescription insertNewObjectForEntityForName:@"SERVICE_CENTER_RATING" inManagedObjectContext:contex];

    //  {"email":"testermrigaen@gmail.com","name":"Pep Boys Auto Parts & Service","address":"East El Camino Real, Sunnyvale, CA, USA","lat":37.364555,"long":-122.0296526,"rating":3.5,"comments":"Bad waiting.","services":"unification","cost":80,"curr":"GEL","date":1562568273,"phone_num":"+1 408-774-0159","website":"https:\/\/stores.pepboys.com\/ca\/sunnyvale\/170-e-el-camino-blvd.html"}

    if([dict objectForKey:@"email"]){

        dataval.email = [dict objectForKey:@"email"];
    }

    if([dict objectForKey:@"name"]){

        dataval.name = [dict objectForKey:@"name"];
    }

    if([dict objectForKey:@"address"]){

        dataval.address = [dict objectForKey:@"address"];
    }

    if([dict objectForKey:@"lat"]){

        dataval.lat = [dict objectForKey:@"lat"];
    }

    if([dict objectForKey:@"long"]){

        dataval.longi = [dict objectForKey:@"long"];
    }

    if([dict objectForKey:@"rating"]){

        dataval.rating = [dict objectForKey:@"rating"];
    }

    if([dict objectForKey:@"comments"]){

        dataval.comments = [dict objectForKey:@"comments"];
    }

    if([dict objectForKey:@"services"]){

        dataval.services = [dict objectForKey:@"services"];
    }

    if([dict objectForKey:@"cost"]){

        dataval.cost = [dict objectForKey:@"cost"];
    }

    if([dict objectForKey:@"curr"]){

        dataval.curr = [dict objectForKey:@"curr"];
    }

    if([dict objectForKey:@"date"]){

        double timestampval =  [[dict objectForKey:@"date"] doubleValue]/1000;
        NSTimeInterval timestamp = (NSTimeInterval)timestampval;
        NSDate *updatetimestamp = [NSDate dateWithTimeIntervalSince1970:timestamp];

        dataval.date = updatetimestamp;
    }

    if([dict objectForKey:@"phone_num"]){

        dataval.phone_number = [dict objectForKey:@"phone_num"];
    }

    if([dict objectForKey:@"website"]){

        dataval.website = [dict objectForKey:@"website"];
    }

    if ([contex hasChanges])
    {
        BOOL saved = [contex save:&err];
        if (!saved) {
            // do some real error handling
            //CLSLog(@“Could not save Data due to %@“, error);
        }
        [[CoreDataController sharedInstance] saveMasterContext];
        [self writeToSyncTableWithRowID:[dict objectForKey:@"rowID"] tableName:@"SERVICE_CENTER_RATING" andType:@"add"];
    }

}

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
        [common checkNetworkForCloudStorage:@"isServiceRating"];
        [[CoreDataController sharedInstance] saveMasterContext];

    }
}

@end

