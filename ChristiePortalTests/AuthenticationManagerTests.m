
#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>
#import "AuthenticationManager.h"

@interface AuthenticationManagerTests : XCTestCase

@end

@implementation AuthenticationManagerTests

- (void)testThatItCallsFailureHandlerIfPolicyCannotBeEvaluated {
    id mockContext = OCMClassMock([LAContext class]);
    AuthenticationManager *authenticationManager = [[AuthenticationManager alloc] initWithContext:mockContext];
    
    static const LAPolicy policy = LAPolicyDeviceOwnerAuthenticationWithBiometrics;
    id mockError = OCMClassMock([NSError class]);
    OCMStub([mockContext canEvaluatePolicy:policy error:[OCMArg setTo:mockError]]).andReturn(NO);
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Failure handler is called"];
    [authenticationManager authenticateWithPolicy:policy reason:@"Fixture reason" copletion:nil failure:^(NSError *error) {
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testThatItCallsCompletionHandler {
    id mockContext = OCMClassMock([LAContext class]);
    AuthenticationManager *authenticationManager = [[AuthenticationManager alloc] initWithContext:mockContext];
    
    static const LAPolicy policy = LAPolicyDeviceOwnerAuthenticationWithBiometrics;
    OCMStub([mockContext canEvaluatePolicy:policy error:[OCMArg setTo:nil]]).andReturn(YES);
    id mockError = OCMClassMock([NSError class]);
    OCMStub([mockContext evaluatePolicy:policy localizedReason:@"Fixture reason" reply:([OCMArg invokeBlockWithArgs:@YES, mockError, nil])]);
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Completion handler is called"];
    [authenticationManager authenticateWithPolicy:policy reason:@"Fixture reason" copletion:^(BOOL success, NSError *error) {
        if (success && error == mockError) {
            [expectation fulfill];
        }
    } failure:nil];
    
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

@end
