

#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>
#import "DataManager.h"
#import "LocationMonitor.h"
#import "NearbyPharmacyMonitor.h"
#import "NotificationManager.h"
#import "Pharmacy.h"
#import "SettingsManager.h"

@interface NearbyPharmacyMonitorTests : XCTestCase

@end

@implementation NearbyPharmacyMonitorTests

- (NSArray<CLRegion *> *)regionsForPharmacies:(NSArray *)pharmacies fromPharmacyMonitor:(NearbyPharmacyMonitor *)pharmacyMonitor {
    id mockLocationMonitor = OCMClassMock([LocationMonitor class]);
    CLLocation *location = [[CLLocation alloc] init];
    
    id mockDataManager = OCMClassMock([DataManager class]);
    OCMStub([mockDataManager sharedManager]).andReturn(mockDataManager);
    OCMStub([[mockDataManager ignoringNonObjectArgs] fetchPharmaciesNearLocation:location]).andReturn(pharmacies);
    
    return [pharmacyMonitor locationMonitor:mockLocationMonitor regionsForLocation:location];
}

- (void)testThatItSetsRegionCenterToPharmacyCoordinates {
    NearbyPharmacyMonitor *pharacyMonitor = [[NearbyPharmacyMonitor alloc] initWithLocationMonitor:nil regionRadius:1 settingsManager:nil notificationManager:nil];
    id mockPharmacy = OCMClassMock([Pharmacy class]);
    OCMStub([mockPharmacy latitude]).andReturn(@1.0);
    OCMStub([mockPharmacy longitude]).andReturn(@2.0);
    OCMStub([(Pharmacy *)mockPharmacy location]).andReturn([[CLLocation alloc] initWithLatitude:1 longitude:2]);
    
    CLCircularRegion *region = (CLCircularRegion *)[self regionsForPharmacies:@[mockPharmacy] fromPharmacyMonitor:pharacyMonitor][0];
    
    XCTAssertEqual(region.center.latitude, 1);
    XCTAssertEqual(region.center.longitude, 2);
}

- (void)testThatItIncludesPharmacyIDInRegionIdentifier {
    NearbyPharmacyMonitor *pharacyMonitor = [[NearbyPharmacyMonitor alloc] initWithLocationMonitor:nil regionRadius:0 settingsManager:nil notificationManager:nil];
    id mockPharmacy = OCMClassMock([Pharmacy class]);
    OCMStub([mockPharmacy id]).andReturn(@123);
    
    CLRegion *region = [self regionsForPharmacies:@[mockPharmacy] fromPharmacyMonitor:pharacyMonitor][0];
    
    XCTAssertTrue([[region.identifier lowercaseString] containsString:@"id = 123"]);
}

- (void)testThatItIncludesRegionRadiusInRegionIdentifier {
    NearbyPharmacyMonitor *pharacyMonitor = [[NearbyPharmacyMonitor alloc] initWithLocationMonitor:nil regionRadius:1 settingsManager:nil notificationManager:nil];
    id mockPharmacy = OCMClassMock([Pharmacy class]);
    
    CLRegion *region = [self regionsForPharmacies:@[mockPharmacy] fromPharmacyMonitor:pharacyMonitor][0];
    
    XCTAssertTrue([[region.identifier lowercaseString] containsString:@"radius = 1"]);
}

- (id)mockSettingsManagerWithNotificationsEnabled:(BOOL)enabled {
    id mockSettingsManager = OCMClassMock([SettingsManager class]);
    OCMStub([mockSettingsManager notifyAboutNearbyPharmacies]).andReturn(enabled);
    return mockSettingsManager;
}

- (void)invokeLocationMonitorDelegate:(id<LocationMonitorDelegate>)delegate withRegion:(CLRegion *)region {
    id mockLocationMonitor = OCMClassMock([LocationMonitor class]);
    [delegate locationMonitor:mockLocationMonitor didEnterRegion:region];
}

- (void)testThatItDoesNotPresentNotificationWhenNearbyNotificationsAreDisabled {
    id mockNotificationManager = OCMClassMock([NotificationManager class]);
    id mockSettingsManager = [self mockSettingsManagerWithNotificationsEnabled:NO];
    NearbyPharmacyMonitor *delegate = [[NearbyPharmacyMonitor alloc] initWithLocationMonitor:nil regionRadius:0 settingsManager:mockSettingsManager notificationManager:mockNotificationManager];
    
    [[mockNotificationManager reject] presentLocalNotification:[OCMArg any]];
    
    CLCircularRegion *region = [[CLCircularRegion alloc] init];
    [self invokeLocationMonitorDelegate:delegate withRegion:region];
}

- (void)testThatItDoesNotPresentNotificationForRegion:(CLRegion *)region {
    id mockNotificationManager = OCMClassMock([NotificationManager class]);
    id mockSettingsManager = [self mockSettingsManagerWithNotificationsEnabled:YES];
    NearbyPharmacyMonitor *delegate = [[NearbyPharmacyMonitor alloc] initWithLocationMonitor:nil regionRadius:0 settingsManager:mockSettingsManager notificationManager:mockNotificationManager];
    
    [[mockNotificationManager reject] presentLocalNotification:[OCMArg any]];
    
    [self invokeLocationMonitorDelegate:delegate withRegion:region];
}

- (void)testThatItDoesNotPresentNotificationForRegionWithoutPharmacyID {
    CLCircularRegion *region = [[CLCircularRegion alloc] initWithCenter:CLLocationCoordinate2DMake(0, 0) radius:0 identifier:@"Pharmacy id radius = 0"];
    [self testThatItDoesNotPresentNotificationForRegion:region];
}

- (void)testThatItDoesNotPresentNotificationForRegionWithInvalidPharmacyID {
    CLCircularRegion *region = [[CLCircularRegion alloc] initWithCenter:CLLocationCoordinate2DMake(0, 0) radius:0 identifier:@"Pharmacy id = abc radius = 0"];
    [self testThatItDoesNotPresentNotificationForRegion:region];
}

- (void)testThatItDoesNotPresentNotificationForRegionWithoutRadius {
    CLCircularRegion *region = [[CLCircularRegion alloc] initWithCenter:CLLocationCoordinate2DMake(0, 0) radius:0 identifier:@"Pharmacy id = 123"];
    [self testThatItDoesNotPresentNotificationForRegion:region];
}

- (void)testThatItDoesNotPresentNotificationForRegionWitInvalidRadius {
    CLCircularRegion *region = [[CLCircularRegion alloc] initWithCenter:CLLocationCoordinate2DMake(0, 0) radius:0 identifier:@"Pharmacy id = 123 radius = abc"];
    [self testThatItDoesNotPresentNotificationForRegion:region];
}

- (void)testThatItDoesNotPresentNotificationIfRadiusDiffers {
    CLCircularRegion *region = [[CLCircularRegion alloc] initWithCenter:CLLocationCoordinate2DMake(0, 0) radius:1 identifier:@"Pharmacy id = 123 radius = 2"];
    [self testThatItDoesNotPresentNotificationForRegion:region];
}

- (void)testThatItPresentsNotificationForValidRegion {
    id mockNotificationManager = OCMClassMock([NotificationManager class]);
    id mockSettingsManager = [self mockSettingsManagerWithNotificationsEnabled:YES];
    NearbyPharmacyMonitor *delegate = [[NearbyPharmacyMonitor alloc] initWithLocationMonitor:nil regionRadius:0 settingsManager:mockSettingsManager notificationManager:mockNotificationManager];
    
    id mockPharmacy = OCMClassMock([Pharmacy class]);
    id mockDataManager = OCMClassMock([DataManager class]);
    OCMStub([mockDataManager sharedManager]).andReturn(mockDataManager);
    OCMStub([mockDataManager fetchPharmacyWithID:1]).andReturn(mockPharmacy);
    
    CLCircularRegion *region = [[CLCircularRegion alloc] initWithCenter:CLLocationCoordinate2DMake(0, 0) radius:0 identifier:@"Pharmacy id = 1 radius = 0"];
    [self invokeLocationMonitorDelegate:delegate withRegion:region];
    
    OCMVerify([mockNotificationManager presentLocalNotification:[OCMArg any]]);
}

@end
