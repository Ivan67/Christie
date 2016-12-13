//
//  LocationMonitorTests.m
//  ChristiePortal
//
//  Created by Sergey on 11/11/15.
//  Copyright © 2015 Rhinoda. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "LocationMonitor.h"

@interface LocationMonitorTests : XCTestCase

@property (nonatomic) id locationManagerMock;
@property (nonatomic) LocationMonitor *locationMonitor;

@end

@implementation LocationMonitorTests

- (void)setUp {
    [super setUp];
    
    self.locationManagerMock = OCMClassMock([CLLocationManager class]);
    self.locationMonitor = [[LocationMonitor alloc] initWithLocationManager:self.locationManagerMock];
}

- (void)testThatItSetsLocationManagerDelegate {
    id locationManagerMock = OCMClassMock([CLLocationManager class]);
    LocationMonitor *locationMonitor = [[LocationMonitor alloc] initWithLocationManager:locationManagerMock];
    
    OCMVerify([locationManagerMock setDelegate:locationMonitor]);
}

- (void)testThatSharedMonitorReturnValueIsNotNil {
    LocationMonitor *locationMonitor = [LocationMonitor sharedMonitor];
    
    XCTAssertNotNil(locationMonitor);
}

- (void)testThatSharedMonitorReturnValueIsConsistent {
    LocationMonitor *locationMonitor1 = [LocationMonitor sharedMonitor];
    LocationMonitor *locationMonitor2 = [LocationMonitor sharedMonitor];
    
    XCTAssertEqual(locationMonitor1, locationMonitor2);
}

- (void)testThatItCallsDidEnterRegionOnDelegate {
    id<LocationMonitorDelegate> locationMonitorDelegateMock = OCMProtocolMock(@protocol(LocationMonitorDelegate));
    self.locationMonitor.delegate = locationMonitorDelegateMock;
    
    CLCircularRegion *region = [[CLCircularRegion alloc] init];
    [self.locationMonitor locationManager:self.locationManagerMock didEnterRegion:region];
    
    OCMVerify([locationMonitorDelegateMock locationMonitor:self.locationMonitor didEnterRegion:region]);
}

- (void)testThatItCallsDidExitRegionOnDelegate {
    id<LocationMonitorDelegate> locationMonitorDelegateMock = OCMProtocolMock(@protocol(LocationMonitorDelegate));
    self.locationMonitor.delegate = locationMonitorDelegateMock;
    
    CLCircularRegion *region = [[CLCircularRegion alloc] init];
    [self.locationMonitor locationManager:self.locationManagerMock didExitRegion:region];
    
    OCMVerify([locationMonitorDelegateMock locationMonitor:self.locationMonitor didExitRegion:region]);
}

- (void)testThatItGetsRegionsFromDataSource {
    OCMStub([self.locationManagerMock isMonitoringAvailableForClass:[OCMArg any]]).andReturn(YES);
    
    CLLocation *firstLocation = [[CLLocation alloc] init];
    CLLocation *lastLocation = [[CLLocation alloc] init];
    
    id<LocationMonitorDataSource> dataSourceMock = OCMProtocolMock(@protocol(LocationMonitorDataSource));
    self.locationMonitor.dataSource = dataSourceMock;
    
    [self.locationMonitor locationManager:self.locationManagerMock didUpdateLocations:@[firstLocation, lastLocation]];
    
    OCMVerify([dataSourceMock locationMonitor:self.locationMonitor regionsForLocation:lastLocation]);
}

- (void)testThatItStartsMonitoringForSignificantLocationChanges {
    [self.locationMonitor startMonitoringForLocationChanges];
    
    OCMVerify([self.locationManagerMock startMonitoringSignificantLocationChanges]);
}

- (void)testThatItUpdatesLocation {
    CLLocation *location = [[CLLocation alloc] init];
    [self.locationMonitor locationManager:self.locationManagerMock didUpdateLocations:@[location]];
    
    XCTAssertEqual(self.locationMonitor.location, location);
}

- (void)testThatItPostsLocationChangeNotification {
    CLLocation *location = [[CLLocation alloc] init];
    
    id notificationCenterMock = OCMPartialMock([[NSNotificationCenter alloc] init]);
    OCMStub([notificationCenterMock defaultCenter]).andReturn(notificationCenterMock);
    
    id observerMock = OCMObserverMock();
    [[NSNotificationCenter defaultCenter] addMockObserver:observerMock name:LocationMonitorLocationDidChangeNotification object:nil];
    [[observerMock expect] notificationWithName:LocationMonitorLocationDidChangeNotification object:[OCMArg any] userInfo:[OCMArg checkWithBlock:^BOOL(NSDictionary *userInfo) {
        XCTAssertEqual(userInfo[LocationMonitorLocationKey], location);
        return YES;
    }]];
    
    [self.locationMonitor locationManager:self.locationManagerMock didUpdateLocations:@[location]];
    
    OCMVerifyAll(observerMock);
}

- (void)testThatItStartsMonitoringForRegionsSuppliedByDataSource {
    OCMStub([self.locationManagerMock isMonitoringAvailableForClass:[OCMArg any]]).andReturn(YES);
    
    CLLocation *location = [[CLLocation alloc] init];
    NSArray<CLRegion *> *regions = @[
        [[CLCircularRegion alloc] init],
        [[CLCircularRegion alloc] init],
        [[CLCircularRegion alloc] init]
    ];
    
    id<LocationMonitorDataSource> dataSourceMock = OCMProtocolMock(@protocol(LocationMonitorDataSource));
    OCMStub([dataSourceMock locationMonitor:self.locationMonitor regionsForLocation:location]).andReturn(regions);
    self.locationMonitor.dataSource = dataSourceMock;
    
    [self.locationMonitor locationManager:self.locationManagerMock didUpdateLocations:@[location]];
    
    for (CLRegion *region in regions) {
        OCMVerify([self.locationManagerMock startMonitoringForRegion:region]);
    }
}

- (void)testThatItDoesNotStartMonitoringIfRegionMonitoringIsNotSupported {
    OCMStub([self.locationManagerMock isMonitoringAvailableForClass:[OCMArg any]]).andReturn(NO);
    
    id<LocationMonitorDataSource> dataSourceMock = OCMProtocolMock(@protocol(LocationMonitorDataSource));
    self.locationMonitor.dataSource = dataSourceMock;
    
    CLLocation *location = [[CLLocation alloc] init];
    CLRegion *region = [[CLCircularRegion alloc] initWithCenter:location.coordinate radius:0 identifier:@"Fixture region"];
    OCMStub([self.locationManagerMock monitoredRegions]).andReturn(@[region]);
    OCMStub([dataSourceMock locationMonitor:self.locationMonitor regionsForLocation:location]).andReturn(@[region]);
    
    [[self.locationManagerMock reject] startMonitoringForRegion:region];
    
    [self.locationMonitor locationManager:self.locationManagerMock didUpdateLocations:@[location]];
}

- (void)testThatItDropsExcessRegions {
    OCMStub([self.locationManagerMock isMonitoringAvailableForClass:[OCMArg any]]).andReturn(YES);
    
    CLLocation *location = [[CLLocation alloc] init];
    NSMutableArray<CLRegion *> *regions = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < LocationMonitorMaxNumberOfRegions; i++) {
        [regions addObject:[[CLCircularRegion alloc] init]];
    }
    CLRegion *excessRegion = [[CLCircularRegion alloc] initWithCenter:CLLocationCoordinate2DMake(0, 0) radius:0 identifier:@"Not monitored"];
    [regions addObject:excessRegion];
    
    [[self.locationManagerMock reject] startMonitoringForRegion:excessRegion];
    
    id<LocationMonitorDataSource> dataSourceMock = OCMProtocolMock(@protocol(LocationMonitorDataSource));
    OCMStub([dataSourceMock locationMonitor:self.locationMonitor regionsForLocation:location]).andReturn(regions);
    self.locationMonitor.dataSource = dataSourceMock;
    
    [self.locationMonitor locationManager:self.locationManagerMock didUpdateLocations:@[location]];
}

- (void)testThatItDoesNotStartMonitoringForAlreadyMonitoredRegions {
    OCMStub([self.locationManagerMock isMonitoringAvailableForClass:[OCMArg any]]).andReturn(YES);
    
    id<LocationMonitorDataSource> dataSourceMock = OCMProtocolMock(@protocol(LocationMonitorDataSource));
    self.locationMonitor.dataSource = dataSourceMock;

    CLLocation *location = [[CLLocation alloc] init];
    NSArray<CLRegion *> *oldRegions = @[
        [[CLCircularRegion alloc] initWithCenter:location.coordinate radius:0 identifier:@"Fixture region 1"],
        [[CLCircularRegion alloc] initWithCenter:location.coordinate radius:0 identifier:@"Fixture region 2"],
        [[CLCircularRegion alloc] initWithCenter:location.coordinate radius:0 identifier:@"Fixture region 3"]
    ];
    OCMStub([self.locationManagerMock monitoredRegions]).andReturn(oldRegions);
    
    NSArray<CLRegion *> *newRegions = @[
        [[CLCircularRegion alloc] initWithCenter:location.coordinate radius:0 identifier:@"Fixture region 1"],
        [[CLCircularRegion alloc] initWithCenter:location.coordinate radius:0 identifier:@"Fixture region 2"],
        [[CLCircularRegion alloc] initWithCenter:location.coordinate radius:0 identifier:@"Fixture region 3"]
    ];
    OCMStub([dataSourceMock locationMonitor:self.locationMonitor regionsForLocation:location]).andReturn(newRegions);
    
    for (CLRegion *region in newRegions) {
        [[self.locationManagerMock reject] startMonitoringForRegion:region];
    }
    
    [self.locationMonitor locationManager:self.locationManagerMock didUpdateLocations:@[location]];
}

- (void)testThatItStopsMonitoringForOldRegions {
    OCMStub([self.locationManagerMock isMonitoringAvailableForClass:[OCMArg any]]).andReturn(YES);
    
    id<LocationMonitorDataSource> dataSourceMock = OCMProtocolMock(@protocol(LocationMonitorDataSource));
    self.locationMonitor.dataSource = dataSourceMock;

    CLLocation *location = [[CLLocation alloc] init];
    CLRegion *oldRegion = [[CLCircularRegion alloc] initWithCenter:location.coordinate radius:0 identifier:@"Old fixture region"];
    OCMStub([self.locationManagerMock monitoredRegions]).andReturn(@[oldRegion]);
    
    CLRegion *newRegion = [[CLCircularRegion alloc] initWithCenter:location.coordinate radius:0 identifier:@"New fixture region"];
    OCMStub([dataSourceMock locationMonitor:self.locationMonitor regionsForLocation:location]).andReturn(@[newRegion]);
    
    [self.locationMonitor locationManager:self.locationManagerMock didUpdateLocations:@[location]];
    
    OCMVerify([self.locationManagerMock stopMonitoringForRegion:oldRegion]);
}

@end
