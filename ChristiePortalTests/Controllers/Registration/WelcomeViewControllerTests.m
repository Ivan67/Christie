//
//  WelcomeViewControllerTests.m
//  ChristiePortal
//
//  Created by Sergey on 18/11/15.
//  Copyright © 2015 Rhinoda. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "APIClient.h"
#import "VerificationCodeViewController.h"
#import "WelcomeViewController.h"

@interface WelcomeViewController ()

@property (weak, nonatomic) IBOutlet UITextField *lastNameField;
@property (weak, nonatomic) IBOutlet UITextField *studentIDField;

- (IBAction)continueRegisration;
- (IBAction)logInInstead;

@end

@interface WelcomeViewControllerTests : XCTestCase

@property (nonatomic) WelcomeViewController *welcomeViewController;
@property (nonatomic) id welcomeViewControllerMock;
@property (nonatomic) id APIClientMock;

@end

@implementation WelcomeViewControllerTests

- (void)setUp {
    [super setUp];
    
    self.welcomeViewController = [[WelcomeViewController alloc] init];
    self.welcomeViewControllerMock = OCMPartialMock(self.welcomeViewController);
    (void)self.welcomeViewController.view;
    
    self.APIClientMock = OCMClassMock([APIClient class]);
    OCMStub([self.APIClientMock sharedClient]).andReturn(self.APIClientMock);
}

- (void)testThatItShowsErrorWhenLastNameIsEmpty {
    self.welcomeViewController.lastNameField.text = nil;
    self.welcomeViewController.studentIDField.text = @"Fixture student ID";
    
    [self.welcomeViewControllerMock continueRegisration];
    
    OCMVerify([self.welcomeViewControllerMock showErrorAlertWithMessage:[OCMArg checkWithBlock:^BOOL(NSString *message) {
        XCTAssertTrue([message containsString:@"your last name"]);
        return YES;
    }]]);
}

- (void)testThatItShowsErrorWhenStudentIDIsEmpty {
    self.welcomeViewController.lastNameField.text = @"Fixture last name";
    self.welcomeViewController.studentIDField.text = nil;
    
    [self.welcomeViewControllerMock continueRegisration];
    
    OCMVerify([self.welcomeViewControllerMock showErrorAlertWithMessage:[OCMArg checkWithBlock:^BOOL(NSString *message) {
        XCTAssertTrue([message containsString:@"your student ID"]);
        return YES;
    }]]);
}

- (void)testThatItSendsRequest {
    self.welcomeViewController.lastNameField.text = @"Fixture last name";
    self.welcomeViewController.studentIDField.text = @"Fixture student ID";

    OCMExpect([self.APIClientMock POST:@"invitations" parameters:[OCMArg checkWithBlock:^BOOL(NSDictionary *parameters) {
        NSDictionary *invitationInfo = parameters[@"invitations"][0];
        XCTAssertEqualObjects(invitationInfo[@"lastName"], @"Fixture last name");
        XCTAssertEqualObjects(invitationInfo[@"studentId"], @"Fixture student ID");
        return YES;
    }] success:[OCMArg any] failure:[OCMArg any]]);
    
    [self.welcomeViewControllerMock continueRegisration];

    OCMVerifyAll(self.APIClientMock);
}

- (void)testThatItShowsVerificationCodeSreenOnRequestSuccess {
    id taskMock = OCMClassMock([NSURLSessionDataTask class]);
    id responseObject = @{
        @"invitations": @{
            @"code": @"Fixture code"
        }
    };
    
    OCMStub([self.APIClientMock POST:[OCMArg any] parameters:[OCMArg any] success:([OCMArg invokeBlockWithArgs:taskMock, responseObject, nil]) failure:[OCMArg any]]);
    
    id navigationManagerMock = OCMClassMock([NavigationManager class]);
    OCMStub([self.welcomeViewControllerMock navigationManager]).andReturn(navigationManagerMock);
    
    self.welcomeViewController.lastNameField.text = @"Fixture last name";
    self.welcomeViewController.studentIDField.text = @"Fixture student ID";
    
    OCMExpect([navigationManagerMock navigateTo:@"/welcome/verification-code" withParameters:[OCMArg checkWithBlock:^BOOL(NSDictionary *parameters) {
        XCTAssertEqualObjects(parameters[@"code"], @"Fixture code");
        return YES;
    }]]);
    
    [self.welcomeViewControllerMock continueRegisration];
    
    OCMVerifyAll(navigationManagerMock);
}

- (void)testThatItShowsLoginScreenWhenLoginButtonIsPressed {
    id navigationManagerMock = OCMClassMock([NavigationManager class]);
    OCMStub([self.welcomeViewControllerMock navigationManager]).andReturn(navigationManagerMock);
    
    [self.welcomeViewController logInInstead];
    
    OCMVerify([navigationManagerMock navigateTo:@"/login"]);
}

@end
