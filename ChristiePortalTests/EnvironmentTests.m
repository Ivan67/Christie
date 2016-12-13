//
//  EnvironmentTests.m
//  ChristiePortal
//
//  Created by Sergey on 23/12/15.
//  Copyright © 2015 Rhinoda. All rights reserved.
//

#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>
#import "Environment.h"

@interface EnvironmentTests : XCTestCase

@end

@implementation EnvironmentTests

- (void)testThatIsRunningTestsReturnsYesInTests {
    XCTAssertTrue([Environment isRunningTests]);
}

- (void)testThatItReturnsPositiveResults {
    NSDictionary *environment = @{
        @"XCInjectBundle": @"SomeBundleName",
        @"NotificationDebugging": @"1",
        @"AutoLoginEnabled": @"1",
        @"FakeUserLoginEnabled": @"1"
    };
    
    id mockProcessInfo = OCMClassMock([NSProcessInfo class]);
    OCMStub([mockProcessInfo processInfo]).andReturn(mockProcessInfo);
    OCMStub([mockProcessInfo environment]).andReturn(environment);
    
    XCTAssertTrue([Environment isRunningTests]);
    XCTAssertTrue([Environment isDebuggingNotifications]);
    XCTAssertTrue([Environment isAutoLoginEnabled]);
    XCTAssertTrue([Environment isFakeUserLoginEnabled]);
    
    [mockProcessInfo stopMocking];
}

- (void)testThatItReturnsNegativeResults {
    NSMutableDictionary *environment = [NSMutableDictionary dictionaryWithDictionary:@{
        @"NotificationDebugging": @"0",
        @"AutoLoginEnabled": @"0",
        @"FakeUserLoginEnabled": @"0"
    }];
    environment[@"XCInjectBundle"] = nil;
    
    id mockProcessInfo = OCMClassMock([NSProcessInfo class]);
    OCMStub([mockProcessInfo processInfo]).andReturn(mockProcessInfo);
    OCMStub([mockProcessInfo environment]).andReturn(environment);
    
    XCTAssertFalse([Environment isRunningTests]);
    XCTAssertFalse([Environment isDebuggingNotifications]);
    XCTAssertFalse([Environment isAutoLoginEnabled]);
    XCTAssertFalse([Environment isFakeUserLoginEnabled]);
    
    [mockProcessInfo stopMocking];
}

@end
