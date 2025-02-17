//
//  Sync_Table.h
//  FuelBuddy
//
//  Created by Swapnil on 15/09/17.
//  Copyright © 2017 Oraganization. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface Sync_Table : NSManagedObject

@property (nonatomic, retain) NSString *tableName;
@property (nonatomic, retain) NSString *type;
@property (nonatomic, retain) NSNumber *rowID;
@property (nonatomic, retain) NSNumber *processing;
@property (nonatomic, retain) NSString *originalSource;

@end
