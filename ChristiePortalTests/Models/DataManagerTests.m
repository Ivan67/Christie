
#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>
#import "DataManager.h"
#import "Pharmacy.h"

@interface DataManagerTests : XCTestCase

@end

@implementation DataManagerTests

- (void)setUp {
    [super setUp];
}

- (Pharmacy *)insertPharmacyIntoDataManager:(DataManager *)dataManager {
    return [NSEntityDescription insertNewObjectForEntityForName:[Pharmacy entityName] inManagedObjectContext:dataManager.managedObjectContext];
}

- (void)testThatSharedManagerReturnValueIsNotNil {
    DataManager *dataManager = [DataManager sharedManager];
    
    XCTAssertNotNil(dataManager);
}

- (void)testThatSharedManagerReturnValueIsConsistent {
    DataManager *dataManager1 = [DataManager sharedManager];
    DataManager *dataManager2 = [DataManager sharedManager];
    
    XCTAssertEqual(dataManager1, dataManager2);
}

- (void)testThatItExecutesFetchRequests {
    id mockManagedObjectContext = OCMClassMock([NSManagedObjectContext class]);
    DataManager *dataManager = [[DataManager alloc] initWithManagedObjectContext:mockManagedObjectContext];
    
    [dataManager saveChanges];
    
    OCMVerify([mockManagedObjectContext save:[OCMArg setTo:nil]]);
}

- (void)testThatItSavesChanges {
    id mockManagedObjectContext = OCMClassMock([NSManagedObjectContext class]);
    id mockFetchRequest = OCMClassMock([NSFetchRequest class]);
    DataManager *dataManager = [[DataManager alloc] initWithManagedObjectContext:mockManagedObjectContext];
    
    [dataManager fetchUsingRequest:mockFetchRequest];
    
    OCMVerify([mockManagedObjectContext executeFetchRequest:mockFetchRequest error:[OCMArg setTo:nil]]);
}

- (DataManager *)dataManagerWithInMemoryContext {
    NSManagedObjectModel *managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:[NSBundle allBundles]];
    
    NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
    [persistentStoreCoordinator addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:nil error:nil];
    
    NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator;
    
    return [[DataManager alloc] initWithManagedObjectContext:managedObjectContext];
}

- (void)testThatItFetchesPharmacies {
    DataManager *dataManager = [self dataManagerWithInMemoryContext];
    Pharmacy *pharmacy = [self insertPharmacyIntoDataManager:dataManager];
    
    Pharmacy *fetchedPharmacy = [dataManager fetchPharmacies][0];
    
    XCTAssertEqual(fetchedPharmacy, pharmacy);
}

- (void)testThatItSortsPharmaciesByDistanceWhenFetchingPharmaciesByLocation {
    DataManager *dataManager = [self dataManagerWithInMemoryContext];
    Pharmacy *pharmacy1 = [self insertPharmacyIntoDataManager:dataManager];
    pharmacy1.location = [[CLLocation alloc] initWithLatitude:1 longitude:1];
    Pharmacy *pharmacy2 = [self insertPharmacyIntoDataManager:dataManager];
    pharmacy2.location = [[CLLocation alloc] initWithLatitude:3 longitude:3];
    Pharmacy *pharmacy3 = [self insertPharmacyIntoDataManager:dataManager];
    pharmacy3.location = [[CLLocation alloc] initWithLatitude:2 longitude:2];
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:0 longitude:0];
    NSArray<Pharmacy *> *fetchedPharmacies = [dataManager fetchPharmaciesNearLocation:location];

    XCTAssertEqual(fetchedPharmacies.count, 3u);
    XCTAssertEqual(fetchedPharmacies[0], pharmacy1);
    XCTAssertEqual(fetchedPharmacies[1], pharmacy3);
    XCTAssertEqual(fetchedPharmacies[2], pharmacy2);
}

- (void)testThatItFetchesPharmacyByID {
    DataManager *dataManager = [self dataManagerWithInMemoryContext];
    Pharmacy *pharmacy1 = [self insertPharmacyIntoDataManager:dataManager];
    pharmacy1.id = @1;
    Pharmacy *pharmacy2 = [self insertPharmacyIntoDataManager:dataManager];
    pharmacy2.id = @2;
    Pharmacy *pharmacy3 = [self insertPharmacyIntoDataManager:dataManager];
    pharmacy3.id = @3;
    
    Pharmacy *fetchedPharmacy = [dataManager fetchPharmacyWithID:2];
    
    XCTAssertEqualObjects(fetchedPharmacy, pharmacy2);
}

@end
