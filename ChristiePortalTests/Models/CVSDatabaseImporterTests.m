//
//  CVSImporterTests.m
//  ChristiePortal
//
//  Created by Sergey on 13/11/15.
//  Copyright © 2015 Rhinoda. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "CVSDatabaseImporter.h"
#import "CVSDatabaseReader.h"
#import "Pharmacy.h"

@interface CVSDatabaseImporterTests : XCTestCase

@property (nonatomic) CVSDatabaseImporter *importer;
@property (nonatomic) id readerMock;
@property (nonatomic) NSDictionary *fixtureStore;

@end

@implementation CVSDatabaseImporterTests

- (void)setUp {
    NSManagedObjectModel *managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:[NSBundle allBundles]];
    NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
    [persistentStoreCoordinator addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:nil error:nil];
    
    NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator;
    
    NSManagedObjectContext *privateManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    privateManagedObjectContext.parentContext = managedObjectContext;
    
    self.fixtureStore = @{
        @"id": @123,
        @"address": @"Fixture address",
        @"store_code": @"Store#123",
        @"phone": @"+1234567890",
        @"service": @"Fixture service",
        @"pharmacy_hours": @"Fixture pharmacy hours",
        @"photo_hours": @"Fixture photo hours",
        @"minuteclinic_hours": @"Fixture minuteclinic hours",
        @"url": @"Fixture URL",
        @"favorite": @NO,
        @"latitude": @54.986589,
        @"longitude": @73.377866,
        @"timezone": @"America/New York"
    };
    
    self.readerMock = OCMClassMock([CVSDatabaseReader class]);
    OCMStub([self.readerMock readTable:@"store" usingBlock:([OCMArg invokeBlockWithArgs:self.fixtureStore, nil])]);
    
    self.importer = [[CVSDatabaseImporter alloc] initWithDatabaseReader:self.readerMock managedObjectContext:managedObjectContext privateManagedObjectContext:privateManagedObjectContext];
}

- (NSArray<Pharmacy *> *)fetchPharmacies {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:[Pharmacy entityName]];
    return [self.importer.managedObjectContext executeFetchRequest:fetchRequest error:nil];
}

- (void)importUsingBlock:(void(^)(Pharmacy *pharmacy))block {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Import is completed"];
    
    [self.importer importCVSDataUsingProgressBlock:nil completion:^{
        Pharmacy *pharmacy = [[self fetchPharmacies] firstObject];
        block(pharmacy);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:0.5 handler:nil];
}

- (void)testThatItCalculatesProgress {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Import is completed"];
    
    static const NSInteger numberOfEntries = 10;
    OCMStub([self.readerMock numberOfEntriesInTable:@"store"]).andReturn(numberOfEntries);
    
    [self.importer importCVSDataUsingProgressBlock:^(float progress) {
        static float expectedProgress = 0;
        expectedProgress += 1.0 / numberOfEntries;
        XCTAssertEqualWithAccuracy(progress, expectedProgress, 0.01);
    } completion:^{
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:0.5 handler:nil];
}

- (void)testThatItSetsPharmacyID {
    [self importUsingBlock:^(Pharmacy *pharmacy) {
        XCTAssertEqualObjects(pharmacy.id, self.fixtureStore[@"id"]);
    }];
}

- (void)testThatItSetsPharmacyAddress {
    [self importUsingBlock:^(Pharmacy *pharmacy) {
        XCTAssertEqualObjects(pharmacy.address, self.fixtureStore[@"address"]);
    }];
}

- (void)testThatItSetsPharmacyStoreCode {
    [self importUsingBlock:^(Pharmacy *pharmacy) {
        XCTAssertEqualObjects(pharmacy.code, self.fixtureStore[@"store_code"]);
    }];
}

- (void)testThatItSetsPharmacyPhone {
    [self importUsingBlock:^(Pharmacy *pharmacy) {
        XCTAssertEqualObjects(pharmacy.phone, self.fixtureStore[@"phone"]);
    }];
}

- (void)testThatItSetsPharmacyService {
    [self importUsingBlock:^(Pharmacy *pharmacy) {
        XCTAssertEqualObjects(pharmacy.service, self.fixtureStore[@"service"]);
    }];
}

- (void)testThatItSetsPharmacyPharmacyHours {
    [self importUsingBlock:^(Pharmacy *pharmacy) {
        XCTAssertEqualObjects(pharmacy.pharmacyHours, self.fixtureStore[@"pharmacy_hours"]);
    }];
}

- (void)testThatItSetsPharmacyPhotoHours {
    [self importUsingBlock:^(Pharmacy *pharmacy) {
        XCTAssertEqualObjects(pharmacy.photoHours, self.fixtureStore[@"photo_hours"]);
    }];
}

- (void)testThatItSetsPharmacyMultiClinicHours {
    [self importUsingBlock:^(Pharmacy *pharmacy) {
        XCTAssertEqualObjects(pharmacy.minuteClinicHours, self.fixtureStore[@"minuteclinic_hours"]);
    }];
}

- (void)testThatItSetsPharmacyURL {
    [self importUsingBlock:^(Pharmacy *pharmacy) {
        XCTAssertEqualObjects(pharmacy.url, self.fixtureStore[@"url"]);
    }];
}

- (void)testThatItSetsPharmacyFavorite {
    [self importUsingBlock:^(Pharmacy *pharmacy) {
        XCTAssertEqualObjects(pharmacy.favorite, @NO);
    }];
}

- (void)testThatItSetsPharmacyLatitude {
    [self importUsingBlock:^(Pharmacy *pharmacy) {
        XCTAssertEqualWithAccuracy([pharmacy.latitude floatValue], [self.fixtureStore[@"latitude"] floatValue], 1E-6);
    }];
}

- (void)testThatItSetsPharmacyLongitude {
    [self importUsingBlock:^(Pharmacy *pharmacy) {
        XCTAssertEqualWithAccuracy([pharmacy.longitude floatValue], [self.fixtureStore[@"longitude"] floatValue], 1E-6);
    }];
}

- (void)testThatItSetsPharmacyTimezone {
    [self importUsingBlock:^(Pharmacy *pharmacy) {
        XCTAssertEqualObjects(pharmacy.timeZone, [NSTimeZone timeZoneWithName:self.fixtureStore[@"timezone"]]);
    }];
}

@end
