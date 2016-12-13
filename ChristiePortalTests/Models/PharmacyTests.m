//
//  PharmacyTests.m
//  ChristiePortal
//
//  Created by Sergey on 26/11/15.
//  Copyright © 2015 Rhinoda. All rights reserved.
//

#import <DateTools.h>
#import "PharmacyTests.h"

@implementation PharmacyTests

- (void)setUp {
    [super setUp];
    
    NSManagedObjectModel *managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:[NSBundle allBundles]];
    NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
    [persistentStoreCoordinator addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:nil error:nil];
    
    NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator;
    
    self.pharmacy = [NSEntityDescription insertNewObjectForEntityForName:[Pharmacy entityName] inManagedObjectContext:managedObjectContext];
}

- (void)testThatItReturnsCorrectLocation {
    self.pharmacy.latitude = @1.0;
    self.pharmacy.longitude = @2.0;
    
    CLLocation *location = self.pharmacy.location;
    
    XCTAssertEqual(location.coordinate.latitude, [self.pharmacy.latitude doubleValue]);
    XCTAssertEqual(location.coordinate.longitude, [self.pharmacy.longitude doubleValue]);
}

- (void)testThatItSetsLatitudeAndLongitudeWhenSettingLocation {
    self.pharmacy.location = [[CLLocation alloc] initWithLatitude:1.0 longitude:2.0];
    
    XCTAssertEqualObjects(self.pharmacy.latitude, @1.0);
    XCTAssertEqualObjects(self.pharmacy.longitude, @2.0);
}

- (void)testThatItReturnsCorrectDisplayName {
    self.pharmacy.numericCode = @123;
    
    NSString *displayName = self.pharmacy.displayName;
    
    XCTAssertEqualObjects(displayName, @"CVS Store #123");
}

- (void)testThatItReturnsCorrectShortAddress {
    self.pharmacy.address = @"Short address, City, State";
    
    NSString *shortAddress = self.pharmacy.shortAddress;
    
    XCTAssertEqualObjects(shortAddress, @"Short address");
}

- (void)testThatItReturnsCorrectDistanceToLocation {
    self.pharmacy.location = [[CLLocation alloc] initWithLatitude:0 longitude:0];
    
    CLLocationDistance distance = [self.pharmacy distanceToLocation:[[CLLocation alloc] initWithLatitude:1 longitude:1]];
    
    XCTAssertEqualWithAccuracy(distance, 157000, 1000);
}

@end
