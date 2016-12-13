//
//  LoginViewControllerTests.m
//  ChristiePortal
//
//  Created by Sergey on 16/11/15.
//  Copyright © 2015 Rhinoda. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <LocalAuthentication/LocalAuthentication.h>
#import <SSKeychain.h>
#import "APIClient.h"
#import "AuthenticationManager.h"
#import "LoginViewController.h"
#import "SettingsManager.h"
#import "User.h"

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *userIDField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIView *useTouchIDView;
@property (weak, nonatomic) IBOutlet UIButton *useTouchIDButton;

- (IBAction)logInWithPassword;
- (IBAction)logInWithTouchID;
- (IBAction)resetPassword;

@end

@interface LoginViewControllerTests : XCTestCase

@property (nonatomic) id settingsManagerMock;
@property (nonatomic) id authenticationManagerMock;
@property (nonatomic) LoginViewController *loginViewController;
@property (nonatomic) id loginViewControllerMock;
@property (nonatomic) id APIClientMock;

@end

@implementation LoginViewControllerTests

- (void)setUp {
    [super setUp];
    
    self.settingsManagerMock = OCMClassMock([SettingsManager class]);
    self.authenticationManagerMock = OCMClassMock([AuthenticationManager class]);
    self.loginViewController = [[LoginViewController alloc] initWithSettingsManager:self.settingsManagerMock authenticationManager:self.authenticationManagerMock];
    self.loginViewControllerMock = OCMPartialMock(self.loginViewController);
    
    (void)self.loginViewController.view;
    
    self.APIClientMock = OCMClassMock([APIClient class]);
    OCMStub([self.APIClientMock sharedClient]).andReturn(self.APIClientMock);
}

- (void)testThatItShowsErrorWhenUsernameIsEmpty {
    self.loginViewController.userIDField.text = nil;
    self.loginViewController.passwordField.text = @"Fixture password";
    
    [self.loginViewController logInWithPassword];
    
    OCMVerify([self.loginViewControllerMock showErrorAlertWithMessage:[OCMArg checkWithBlock:^BOOL(NSString *message) {
        XCTAssertTrue([message containsString:@"your user ID"]);
        return YES;
    }]]);
}

- (void)testThatItShowsErrorWhenPasswordIsEmpty {
    self.loginViewController.userIDField.text = @"Fixture username";
    self.loginViewController.passwordField.text = nil;

    [self.loginViewController logInWithPassword];
    
    OCMVerify([self.loginViewControllerMock showErrorAlertWithMessage:[OCMArg checkWithBlock:^BOOL(NSString *message) {
        XCTAssertTrue([message containsString:@"your password"]);
        return YES;
    }]]);
}

- (void)testThatItSendsRequest {
    self.loginViewController.userIDField.text = @"Fixture username";
    self.loginViewController.passwordField.text = @"Fixture password";
    
    [self.loginViewController logInWithPassword];
    
    OCMVerify([self.APIClientMock GET:@"users" parameters:[OCMArg checkWithBlock:^BOOL(NSDictionary *parameters) {
        XCTAssertEqualObjects(parameters[@"username"], @"Fixture username");
        XCTAssertEqualObjects(parameters[@"password"], @"Fixture password");
        return YES;
    }] success:[OCMArg any] failure:[OCMArg any]]);
}

- (void)testThatItSetsHTTPAuthorizationHeaders {
    id requestSerializerMock = OCMClassMock([AFJSONRequestSerializer class]);
    OCMStub([self.APIClientMock requestSerializer]).andReturn(requestSerializerMock);
    
    self.loginViewController.userIDField.text = @"Fixture username";
    self.loginViewController.passwordField.text = @"Fixture password";
    
    [self.loginViewController logInWithPassword];
    
    OCMVerify([requestSerializerMock setAuthorizationHeaderFieldWithUsername:@"Fixture username" password:@"Fixture password"]);
}

- (void)testThatItRemembersUserInformation {
    id taskMock = OCMClassMock([NSURLSessionDataTask class]);
    
    NSDictionary *responseObject = @{
        @"users": @{
            @"id": @123
        },
        @"linked": @{
            @"entities": @[@{
                @"first-name": @"Fixture first name",
                @"last-name": @"Fixture last name",
                @"old-id": @"Fixture old id",
                @"phone": @"Fixture phone",
                @"email": @"Fixture email",
                @"physical-country": @"Fixture physical country",
                @"physical-address1": @"Fixture physical address 1",
                @"physical-address2": @"Fixture physical address 2"
            }],
            @"members": @[@{
                @"student-id": @456,
                @"birth-date": @"1995-10-08T00:00:00+00:00"
            }]
        }
    };
    
    OCMStub([self.APIClientMock GET:[OCMArg any] parameters:[OCMArg any] success:([OCMArg invokeBlockWithArgs:taskMock, responseObject, nil]) failure:[OCMArg any]]);
    
    id userMock = OCMClassMock([User class]);
    OCMStub([userMock sharedUser]).andReturn(userMock);
    
    self.loginViewController.userIDField.text = @"Fixture username";
    self.loginViewController.passwordField.text = @"Fixture password";
    
    [self.loginViewController logInWithPassword];
    
    NSDictionary *userInfo = responseObject[@"users"];
    OCMVerify([userMock setId:[userInfo[@"id"] integerValue]]);
    
    NSDictionary *entityInfo = [responseObject[@"linked"][@"entities"] firstObject];
    OCMVerify([userMock setFirstName:entityInfo[@"first-name"]]);
    OCMVerify([userMock setLastName:entityInfo[@"last-name"]]);
    OCMVerify([userMock setOldMemberID:entityInfo[@"old-id"]]);
    OCMVerify([userMock setPhone:entityInfo[@"phone"]]);
    OCMVerify([userMock setEmail:entityInfo[@"email"]]);
    OCMVerify([userMock setCountry:entityInfo[@"physical-country"]]);
    OCMVerify([userMock setAddress1:entityInfo[@"physical-address1"]]);
    OCMVerify([userMock setAddress2:entityInfo[@"physical-address2"]]);
    
    NSDictionary *memberInfo = [responseObject[@"linked"][@"members"] firstObject];
    OCMVerify([userMock setStudentID:[memberInfo[@"student-id"] integerValue]]);
    OCMVerify([userMock setBirthDate:[NSDate dateWithTimeIntervalSince1970:813110400]]);
}

- (void)testThatItShowsStartScreenOnRequestSuccess {
    id taskMock = OCMClassMock([NSURLSessionDataTask class]);
    
    OCMStub([self.APIClientMock GET:[OCMArg any] parameters:[OCMArg any] success:([OCMArg invokeBlockWithArgs:taskMock, [NSNull null], nil]) failure:[OCMArg any]]);
    
    self.loginViewController.userIDField.text = @"Fixture username";
    self.loginViewController.passwordField.text = @"Fixture password";
    
    id navigationManagerMock = OCMClassMock([NavigationManager class]);
    OCMStub([self.loginViewControllerMock navigationManager]).andReturn(navigationManagerMock);
    
    [self.loginViewControllerMock logInWithPassword];
    
    OCMVerify([navigationManagerMock navigateTo:@"/start"]);
}

- (void)testThatItAutomaticallyLogsInWithTouchIDIfUseTouchIDIsEnabled {
    OCMStub([self.settingsManagerMock useTouchID]).andReturn(YES);
    
    [self.loginViewController viewWillAppear:NO];
    
    OCMVerify([self.loginViewControllerMock logInWithTouchID]);
}

- (void)testThatItDoesNotAutomaticallyLogInWithTouchIDIfUseTouchIDIsDisabled {
    OCMStub([self.settingsManagerMock useTouchID]).andReturn(NO);
    
    [[self.loginViewControllerMock reject] logInWithTouchID];
    
    [self.loginViewController viewWillAppear:NO];
}

- (void)testThatItShowsErrorIfTouchIDAuthenticationIsNotAvailable {
    OCMStub([self.authenticationManagerMock authenticateWithPolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics reason:[OCMArg any] copletion:[OCMArg any] failure:([OCMArg invokeBlockWithArgs:[NSNull null], nil])]);
    
    [self.loginViewController logInWithTouchID];
    
    OCMVerify([self.loginViewControllerMock showErrorAlertWithMessage:[OCMArg checkWithBlock:^BOOL(NSString *message) {
        XCTAssertTrue([message containsString:@"Touch ID"]);
        return YES;
    }]]);
}

- (void)testThatItAutoFillsLoginAndPasswordOnSuccessfulTouchIDLogin {
    OCMStub([self.authenticationManagerMock authenticateWithPolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics reason:[OCMArg any] copletion:([OCMArg invokeBlockWithArgs:@YES, [NSNull null], nil]) failure:[OCMArg any]]);
    OCMStub([self.settingsManagerMock username]).andReturn(@"Fixture username");
    
    id keychainMock = OCMClassMock([SSKeychain class]);
    OCMStub([keychainMock passwordForService:[OCMArg any] account:[OCMArg any]]).andReturn(@"Fixture password");
    
    [self.loginViewController logInWithTouchID];
    
    XCTAssertEqualObjects(self.loginViewController.userIDField.text, @"Fixture username");
    XCTAssertEqualObjects(self.loginViewController.passwordField.text, @"Fixture password");
}

- (void)testThatItDoesNotAutoFillsLoginAndPasswordWhenTouchIDFailsOrCancelled {
    OCMStub([self.authenticationManagerMock authenticateWithPolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics reason:[OCMArg any] copletion:([OCMArg invokeBlockWithArgs:@NO, [NSNull null], nil]) failure:[OCMArg any]]);
    OCMStub([self.settingsManagerMock username]).andReturn(@"Fixture username");
    
    id keychainMock = OCMClassMock([SSKeychain class]);
    OCMStub([keychainMock passwordForService:[OCMArg any] account:[OCMArg any]]).andReturn(@"Fixture password");
    
    self.loginViewController.userIDField.text = @"Old username";
    self.loginViewController.passwordField.text = @"Old password";
    [self.loginViewController logInWithTouchID];
    
    XCTAssertEqualObjects(self.loginViewController.userIDField.text, @"Old username");
    XCTAssertEqualObjects(self.loginViewController.passwordField.text, @"Old password");
}

@end
