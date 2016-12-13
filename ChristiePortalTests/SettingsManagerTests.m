//
//  SettingsManagerTests.m
//  ChristiePortal
//
//  Created by Sergey on 04/12/15.
//  Copyright © 2015 Rhinoda. All rights reserved.
//

#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>
#import "SettingsManager.h"

@interface SettingsManagerTests : XCTestCase

@end

@implementation SettingsManagerTests

- (void)testThatItRegistersUserDefaults {
    id mockUserDefaults = OCMClassMock([NSUserDefaults class]);
    SettingsManager *settingsManager = [[SettingsManager alloc] initWithUserDefaults:mockUserDefaults];
    
    OCMExpect([mockUserDefaults registerDefaults:[OCMArg checkWithBlock:^BOOL(NSDictionary *defaults) {
        XCTAssertFalse([defaults[SettingsImportedCVSDataKey] boolValue]);
        XCTAssertFalse([defaults[SettingsCompletedRegistrationKey] boolValue]);
        XCTAssertEqual([defaults[SettingsUsernameKey] length], 0u);
        XCTAssertFalse([defaults[SettingsUseTouchIDKey] boolValue]);
        XCTAssertTrue([defaults[SettingsNotifyAboutNearbyPharmaciesKey] boolValue]);
        return YES;
    }]]);
    
    [settingsManager registerDefaults];
    
    OCMVerifyAll(mockUserDefaults);
}

- (void)testThatItReadsSettingsFromUserDefaults {
    id mockUserDefaults = OCMClassMock([NSUserDefaults class]);
    SettingsManager *settingsManager = [[SettingsManager alloc] initWithUserDefaults:mockUserDefaults];
    
    (void)settingsManager.importedCVSData;
    (void)settingsManager.completedRegistration;
    (void)settingsManager.username;
    (void)settingsManager.notifyAboutNearbyPharmacies;
    (void)settingsManager.useTouchID;
    
    OCMVerify([mockUserDefaults boolForKey:SettingsImportedCVSDataKey]);
    OCMVerify([mockUserDefaults boolForKey:SettingsCompletedRegistrationKey]);
    OCMVerify([mockUserDefaults stringForKey:SettingsUsernameKey]);
    OCMVerify([mockUserDefaults boolForKey:SettingsNotifyAboutNearbyPharmaciesKey]);
    OCMVerify([mockUserDefaults boolForKey:SettingsUseTouchIDKey]);
}

- (void)testThatItWritesSettingsToUserDefaults {
    id mockUserDefaults = OCMClassMock([NSUserDefaults class]);
    SettingsManager *settingsManager = [[SettingsManager alloc] initWithUserDefaults:mockUserDefaults];
    
    settingsManager.importedCVSData = YES;
    settingsManager.importedCVSData = NO;
    settingsManager.completedRegistration = YES;
    settingsManager.completedRegistration = NO;
    settingsManager.username = @"Fixture username";
    settingsManager.notifyAboutNearbyPharmacies = YES;
    settingsManager.notifyAboutNearbyPharmacies = NO;
    settingsManager.useTouchID = YES;
    settingsManager.useTouchID = NO;
    
    OCMVerify([mockUserDefaults setBool:YES forKey:SettingsImportedCVSDataKey]);
    OCMVerify([mockUserDefaults setBool:NO forKey:SettingsImportedCVSDataKey]);
    OCMVerify([mockUserDefaults setBool:YES forKey:SettingsCompletedRegistrationKey]);
    OCMVerify([mockUserDefaults setBool:NO forKey:SettingsCompletedRegistrationKey]);
    OCMVerify([mockUserDefaults setValue:@"Fixture username" forKey:SettingsUsernameKey]);
    OCMVerify([mockUserDefaults setBool:YES forKey:SettingsNotifyAboutNearbyPharmaciesKey]);
    OCMVerify([mockUserDefaults setBool:NO forKey:SettingsNotifyAboutNearbyPharmaciesKey]);
    OCMVerify([mockUserDefaults setBool:YES forKey:SettingsUseTouchIDKey]);
    OCMVerify([mockUserDefaults setBool:NO forKey:SettingsUseTouchIDKey]);
}

@end
