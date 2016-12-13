
#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>
#import "DataManager.h"
#import "NavigationManager.h"
#import "NotificationManager.h"
#import "Pharmacy.h"
#import "UIViewController+AlertHelpers.h"
#import "User.h"

@interface NotificationManagerTests : XCTestCase

@end

@implementation NotificationManagerTests

- (void)testThatItRegistersUserNotificationSettingsWithApplication {
    id mockApplication = OCMClassMock([UIApplication class]);
    NotificationManager *notificationManager = [[NotificationManager alloc] initWithApplication:mockApplication navigationManager:nil];
    
    [notificationManager registerUserNotificationSettings];
    
    OCMVerify([mockApplication registerUserNotificationSettings:[OCMArg isNotNil]]);
}

- (void)testItCorrectlyCreatesNearbyPharamcyNotificaton {
    NotificationManager *notificationManager = [[NotificationManager alloc] initWithApplication:nil navigationManager:nil];
    
    id mockPharmacy = OCMClassMock([Pharmacy class]);
    OCMStub([(Pharmacy *)mockPharmacy id]).andReturn(@1);
    OCMStub([mockPharmacy displayName]).andReturn((@"Fixture name"));
    OCMStub([mockPharmacy shortAddress]).andReturn((@"Fixture address"));
    
    id mockDataManager = OCMClassMock([DataManager class]);
    OCMStub([mockDataManager sharedManager]).andReturn(mockDataManager);
    OCMStub([mockDataManager fetchPharmacyWithID:1]).andReturn(mockPharmacy);
    
    UILocalNotification *notification = [notificationManager notificationForNearbyPharmacy:mockPharmacy];
    XCTAssertTrue([notification.alertBody containsString:@"Fixture name"]);
    XCTAssertTrue([notification.alertBody containsString:@"Fixture address"]);
}

- (void)testThatItPresentsNotifications {
    id mockApplication = OCMClassMock([UIApplication class]);
    NotificationManager *notificationManager = [[NotificationManager alloc] initWithApplication:mockApplication navigationManager:nil];
    
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    [notificationManager presentLocalNotification:notification];
    
    OCMVerify([mockApplication presentLocalNotificationNow:notification]);
}

- (void)testThatItShowsErrorIfUserIsNotLoggedInWhenHandlingNotification {
    id mockUser = OCMClassMock([User class]);
    OCMStub([mockUser sharedUser]).andReturn(mockUser);
    OCMStub([mockUser isLoggedIn]).andReturn(NO);
    
    id mockApplication = OCMClassMock([UIApplication class]);
    id mockAppDelegate = OCMProtocolMock(@protocol(UIApplicationDelegate));
    id mockWindow = OCMClassMock([UIWindow class]);
    id mockRootViewController = OCMClassMock([UIViewController class]);
    OCMStub([mockWindow rootViewController]).andReturn(mockRootViewController);
    OCMStub([mockAppDelegate window]).andReturn(mockWindow);
    OCMStub([mockApplication delegate]).andReturn(mockAppDelegate);
    OCMStub([mockApplication applicationState]).andReturn(UIApplicationStateInactive);
    
    NotificationManager *notificationManager = [[NotificationManager alloc] initWithApplication:mockApplication navigationManager:nil];

    OCMExpect([mockRootViewController showErrorAlertWithMessage:[OCMArg checkWithBlock:^BOOL(NSString *message) {
        return [[message lowercaseString] containsString:@"not logged in"];
    }]]);

    [notificationManager handleLocalNotification:[[UILocalNotification alloc] init]];
    
    OCMVerifyAll(mockRootViewController);
}

- (void)testThatItShowsPharmacyDetailsScreenWhenHandlingNearbyPharmacyNotification {
    id mockUser = OCMClassMock([User class]);
    OCMStub([mockUser sharedUser]).andReturn(mockUser);
    OCMStub([mockUser isLoggedIn]).andReturn(YES);
    
    id mockApplication = OCMClassMock([UIApplication class]);
    OCMStub([mockApplication applicationState]).andReturn(UIApplicationStateInactive);
    id mockNavigationManager = OCMClassMock([NavigationManager class]);
    
    NotificationManager *notificationManager = [[NotificationManager alloc] initWithApplication:mockApplication navigationManager:mockNavigationManager];
    
    id mockPharmacy = OCMClassMock([Pharmacy class]);
    OCMStub([(Pharmacy *)mockPharmacy id]).andReturn(@1);
    id mockDataManager = OCMClassMock([DataManager class]);
    OCMStub([mockDataManager sharedManager]).andReturn(mockDataManager);
    OCMStub([mockDataManager fetchPharmacyWithID:1]).andReturn(mockPharmacy);
    
    OCMExpect([mockNavigationManager navigateTo:@"/pharmacies/search/details" withParameters:[OCMArg checkWithBlock:^BOOL(NSDictionary *parameters) {
        XCTAssertEqual(parameters[@"pharmacy"], mockPharmacy);
        return YES;
    }]]);
    
    UILocalNotification *notification = [notificationManager notificationForNearbyPharmacy:mockPharmacy];
    [notificationManager handleLocalNotification:notification];
    
    OCMVerifyAll(mockNavigationManager);
}

@end
