//
//  CoreDataController.h
//  SignificantDates
//
//  Created by Chris Wagner on 5/14/12.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CoreDataController : NSObject

+ (id)sharedInstance;

- (NSURL *)applicationDocumentsDirectory;

- (NSManagedObjectContext *)masterManagedObjectContext;
- (NSManagedObjectContext *)backgroundManagedObjectContext;
- (NSManagedObjectContext *)newManagedObjectContext;
- (void)saveMasterContext;
- (void)saveBackgroundContext;
- (NSManagedObjectModel *)managedObjectModel;
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;

@end
