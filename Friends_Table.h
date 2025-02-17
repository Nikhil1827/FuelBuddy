//
//  Friends_Table.h
//  FuelBuddy
//
//  Created by Nikhil on 24/04/18.
//  Copyright © 2018 Oraganization. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface Friends_Table : NSManagedObject

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) NSString *status;
@property (nonatomic, retain) NSString *requested_by_me;

@end
