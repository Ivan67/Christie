#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "APIClient.h"
#import "AccountViewController.h"

@interface AccountViewController ()

@property (weak, nonatomic) IBOutlet UITextField *userIDField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordField;

- (IBAction)continueRegistration;

@end

@interface AccountViewControllerTests : XCTestCase

@property (nonatomic) AccountViewController *accountViewController;
@property (nonatomic) id accountViewControllerMock;
@property (nonatomic) id APIClientMock;

@end

@implementation AccountViewControllerTests

- (void)setUp {
    [super setUp];
    
    self.accountViewController = [[AccountViewController alloc] init];
    self.accountViewControllerMock = OCMPartialMock(self.accountViewController);
    (void)self.accountViewController.view;
    
    self.APIClientMock = OCMClassMock([APIClient class]);
    OCMStub([self.APIClientMock sharedClient]).andReturn(self.APIClientMock);
}

- (void)testThatItShowsErrorWhenUsernameIsEmpty {
    self.accountViewController.userIDField.text = nil;
    self.accountViewController.passwordField.text = @"Fixture password";
    self.accountViewController.confirmPasswordField.text = @"Fixture confirm password";
    
    [self.accountViewControllerMock continueRegistration];
    
    OCMVerify([self.accountViewControllerMock showErrorAlertWithMessage:[OCMArg checkWithBlock:^BOOL(NSString *message) {
        XCTAssertTrue([message containsString:@"your username"]);
        return YES;
    }]]);
}

- (void)testThatItShowsErrorWhenPasswordIsEmpty {
    self.accountViewController.userIDField.text = @"Fixture login";
    self.accountViewController.passwordField.text = nil;
    self.accountViewController.confirmPasswordField.text = @"Fixture confirm password";
    
    [self.accountViewControllerMock continueRegistration];
    
    OCMVerify([self.accountViewControllerMock showErrorAlertWithMessage:[OCMArg checkWithBlock:^BOOL(NSString *message) {
        XCTAssertTrue([message containsString:@"your password"]);
        return YES;
    }]]);
}

- (void)testThatItShowsErrorWhenConfirmPasswordIsEmpty {
    self.accountViewController.userIDField.text = @"Fixture login";
    self.accountViewController.passwordField.text = @"Fixture password";
    self.accountViewController.confirmPasswordField.text = nil;
    
    [self.accountViewControllerMock continueRegistration];
    
    OCMVerify([self.accountViewControllerMock showErrorAlertWithMessage:[OCMArg checkWithBlock:^BOOL(NSString *message) {
        XCTAssertTrue([message containsString:@"confirm your password"]);
        return YES;
    }]]);
}

- (void)testThatItSendsRequest {
    self.accountViewController.userIDField.text = @"Fixture login";
    self.accountViewController.passwordField.text = @"Fixture password";
    self.accountViewController.confirmPasswordField.text = @"Fixture password";
    self.accountViewController.navigationParameters = @{
        @"code": @"123456"
    };
    
    OCMExpect([self.APIClientMock POST:@"users" parameters:[OCMArg checkWithBlock:^BOOL(NSDictionary *parameters) {
        NSDictionary *userInfo = parameters[@"users"];
        XCTAssertEqualObjects(userInfo[@"username"], @"Fixture login");
        XCTAssertEqualObjects(userInfo[@"plainPassword"], @"Fixture password");
        XCTAssertEqualObjects(userInfo[@"invitationCode"], @"123456");
        return YES;
    }] success:[OCMArg any] failure:[OCMArg any]]);

    [self.accountViewControllerMock viewWillAppear:NO];
    [self.accountViewControllerMock continueRegistration];
    
    OCMVerifyAll(self.APIClientMock);
}

- (void)testThatItShowsSecurityQuestionsScreenOnRequestSuccess {
    id taskMock = OCMClassMock([NSURLSessionDataTask class]);
    id responseObject = @{
        @"users": @{
            @"id": @123
        }
    };
    
    OCMStub([self.APIClientMock POST:[OCMArg any] parameters:[OCMArg any] success:([OCMArg invokeBlockWithArgs:taskMock, responseObject, nil]) failure:[OCMArg any]]);
    
    id navigationManagerMock = OCMClassMock([NavigationManager class]);
    OCMStub([self.accountViewControllerMock navigationManager]).andReturn(navigationManagerMock);
    
    self.accountViewController.userIDField.text = @"Fixture login";
    self.accountViewController.passwordField.text = @"Fixture password";
    self.accountViewController.confirmPasswordField.text = @"Fixture password";
    self.accountViewController.navigationParameters = @{
        @"code": @"123456"
    };
    
    OCMExpect([navigationManagerMock navigateTo:@"/welcome/verification-code/account/security-questions" withParameters:[OCMArg checkWithBlock:^BOOL(NSDictionary *parameters) {
        XCTAssertEqualObjects(parameters[@"userID"], @123);
        return YES;
    }]]);
    
    [self.accountViewControllerMock viewWillAppear:NO];
    [self.accountViewControllerMock continueRegistration];
    
    OCMVerifyAll(navigationManagerMock);
}

@end
