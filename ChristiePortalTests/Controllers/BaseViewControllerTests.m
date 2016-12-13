#import <AFNetworking.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "BaseViewController.h"
#import "NSError+APIClient.h"

@interface BaseViewControllerTests : XCTestCase

@end

@implementation BaseViewControllerTests

- (void)testThatItStartsAnimatingActivityIndicatorWhenNetworkRequestIsStarted {
    BaseViewController *baseViewController = [[BaseViewController alloc] init];
    id activityIndicatorMock = OCMClassMock([UIActivityIndicatorView class]);
    baseViewController.activityIndicator = activityIndicatorMock;
    
    NSNotificationCenter *notificationCenter = [[NSNotificationCenter alloc] init];
    id notificationCenterMock = OCMPartialMock(notificationCenter);
    OCMStub([notificationCenterMock defaultCenter]).andReturn(notificationCenterMock);
    [baseViewController viewWillAppear:NO];
    
    [notificationCenterMock postNotificationName:AFNetworkingTaskDidResumeNotification object:nil];
    
    OCMVerify([activityIndicatorMock startAnimating]);
}

- (void)testThatItStopsAnimatingActivityIndicatorWhenNetworkRequestIsCompleted {
    BaseViewController *baseViewController = [[BaseViewController alloc] init];
    id activityIndicatorMock = OCMClassMock([UIActivityIndicatorView class]);
    baseViewController.activityIndicator = activityIndicatorMock;
    
    NSNotificationCenter *notificationCenter = [[NSNotificationCenter alloc] init];
    id notificationCenterMock = OCMPartialMock(notificationCenter);
    OCMStub([notificationCenterMock defaultCenter]).andReturn(notificationCenterMock);
    [baseViewController viewWillAppear:NO];
    
    [notificationCenterMock postNotificationName:AFNetworkingTaskDidResumeNotification object:nil];
    [notificationCenterMock postNotificationName:AFNetworkingTaskDidCompleteNotification object:nil];
    
    OCMVerify([activityIndicatorMock stopAnimating]);
}

- (void)testThatItShowsErrorAlerWhenNetworkRequestFails {
    NSNotificationCenter *notificationCenter = [[NSNotificationCenter alloc] init];
    id notificationCenterMock = OCMPartialMock(notificationCenter);
    OCMStub([notificationCenterMock defaultCenter]).andReturn(notificationCenterMock);
    
    BaseViewController *baseViewController = [[BaseViewController alloc] init];
    id baseViewControllerMock = OCMPartialMock(baseViewController);
    [baseViewControllerMock viewWillAppear:NO];
    
    id errorMock = OCMClassMock([NSError class]);
    OCMStub([errorMock remoteDescription]).andReturn(@"Fixture error description");
    [notificationCenter postNotificationName:AFNetworkingTaskDidCompleteNotification object:nil userInfo:@{
        AFNetworkingTaskDidCompleteErrorKey: errorMock
    }];
    
    OCMVerify([[baseViewControllerMock ignoringNonObjectArgs] presentViewController:[OCMArg checkWithBlock:^BOOL(UIAlertController *alertController) {
        XCTAssertTrue([alertController isKindOfClass:[UIAlertController class]]);
        XCTAssertTrue([alertController.message containsString:@"Fixture error description"]);
        return YES;
    }] animated:NO completion:[OCMArg any]]);
}

- (void)testThatItResignsFirstResponderFromTextFieldOnReturn {
    BaseViewController *baseViewController = [[BaseViewController alloc] init];
    id mockTextField = OCMClassMock([UITextField class]);
    
    BOOL shouldReturn = [baseViewController textFieldShouldReturn:mockTextField];
    
    XCTAssertFalse(shouldReturn);
    OCMVerify([mockTextField resignFirstResponder]);
}

@end
