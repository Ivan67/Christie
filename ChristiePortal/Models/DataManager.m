//
//  CoreDataManager.m
//  TimeChat
//
//  Created by K.Mavlitov on
//  Copyright (c) K.Mavlitov 2014. All rights reserved.
//

#import "DataManager.h"
#import "Pharmacy.h"

@implementation DataManager

+ (instancetype)sharedManager {
    static DataManager *sharedManager;
    static dispatch_once_t once;
    
    dispatch_once(&once, ^{
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSURL *documentDirectoryURL = [fileManager URLsForDirectory: NSDocumentDirectory inDomains:NSUserDomainMask][0];
        
        NSURL *storeURL = [documentDirectoryURL URLByAppendingPathComponent:@"CVS"];
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"CVS" withExtension:@"momd"];
        
        NSManagedObjectModel *objectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
        NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:objectModel];
        
        NSError *error;
        [coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:0 error:&error];
        if (error != nil) {
            NSLog(@"Failed to create persistent store: %@", error);
            return;
        }
        
        NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        managedObjectContext.persistentStoreCoordinator = coordinator;
        
        sharedManager = [[DataManager alloc] initWithManagedObjectContext:managedObjectContext];
    });
    
    return sharedManager;
}

- (instancetype)initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    if (self = [super init]) {
        _managedObjectContext = managedObjectContext;
    }
    return self;
}

- (NSArray *)fetchUsingRequest:(NSFetchRequest *)fetchRequest {
    NSError *error;
    NSArray *data = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error != nil) {
        NSLog(@"DataManager: Failed to execute fetch requet %@: %@", fetchRequest, error);
    }
    return data;
}

- (NSArray<Pharmacy *> *)fetchPharmacies {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:[Pharmacy entityName]];
    return [self fetchUsingRequest:fetchRequest];
}

- (NSArray<Pharmacy *> *)fetchPharmaciesNearLocation:(CLLocation *)location {
    NSArray<Pharmacy *> *pharmacies = [self fetchPharmacies];
    return [pharmacies sortedArrayUsingComparator:^NSComparisonResult(Pharmacy *pharamcy1, Pharmacy *pharamcy2) {
        CLLocationDistance distance1 = [pharamcy1 distanceToLocation:location];
        CLLocationDistance distance2 = [pharamcy2 distanceToLocation:location];
        if (distance1 < distance2) {
            return NSOrderedAscending;
        } else if (distance1 > distance2) {
            return NSOrderedDescending;
        } else {
            return NSOrderedSame;
        }
    }];
}

- (Pharmacy *)fetchPharmacyWithID:(NSInteger)pharmacyID {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:[Pharmacy entityName]];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"id == %ld", (long)pharmacyID];
    fetchRequest.fetchLimit = 1;
    return [[self fetchUsingRequest:fetchRequest] firstObject];
}

- (void)saveChanges {
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"DataManager: Failed to save changes: %@", error);
    }
}

@end
