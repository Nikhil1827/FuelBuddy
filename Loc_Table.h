//
//  Loc_Table.h
//  FuelBuddy
//
//  Created by Swapnil on 02/08/17.
//  Copyright © 2017 Oraganization. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface Loc_Table : NSManagedObject

@property (nonatomic, retain) NSNumber *iD;
@property (nonatomic, retain) NSString *address;
@property (nonatomic, retain) NSString *brand;
@property (nonatomic, retain) NSNumber *lat;
@property (nonatomic, retain) NSNumber *longitude;

@end
