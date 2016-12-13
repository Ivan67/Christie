#import <XCTest/XCTest.h>
#import "VerificationCodeViewController.h"
#import <OCMock/OCMock.h>

@interface VerificationCodeViewController ()

@property (weak, nonatomic) IBOutlet UITextField *verificationCodeField;

- (IBAction)continueRegistration;

@end


@interface VerificationCodeViewControllerTests : XCTestCase

@property (nonatomic) VerificationCodeViewController *verificationCodeViewController;
@property (nonatomic) id verificationCodeViewControllerMock;

@end

@implementation VerificationCodeViewControllerTests

- (void)setUp {
    [super setUp];

    self.verificationCodeViewController = [[VerificationCodeViewController alloc] init];
    self.verificationCodeViewControllerMock = OCMPartialMock(self.verificationCodeViewController);
    (void)self.verificationCodeViewController.view;
}

- (void)testThatItShowsErrorWhenVerificationCodeIsEmpty {
    self.verificationCodeViewController.verificationCodeField.text = nil;
    
    [self.verificationCodeViewControllerMock continueRegistration];
    
    OCMVerify([self.verificationCodeViewControllerMock showErrorAlertWithMessage:[OCMArg checkWithBlock:^BOOL(NSString *message) {
        XCTAssertTrue([message containsString:@"enter your verification code"]);
        return YES;
    }]]);
}

- (void)testThatItShowsAccountScreenVerificationCodeIsCorrect {
    self.verificationCodeViewController.verificationCodeField.text = @"Fixture code";
    self.verificationCodeViewController.navigationParameters = @{
        @"code": @"Fixture code"
    };
    
    id navigationManagerMock = OCMClassMock([NavigationManager class]);
    OCMStub([self.verificationCodeViewControllerMock navigationManager]).andReturn(navigationManagerMock);
    
    OCMExpect([navigationManagerMock navigateTo:@"/welcome/verification-code/account" withParameters:[OCMArg checkWithBlock:^BOOL(NSDictionary *parameters) {
        XCTAssertEqualObjects(parameters[@"code"], @"Fixture code");
        return YES;
    }]]);
    
    [self.verificationCodeViewControllerMock viewWillAppear:NO];
    [self.verificationCodeViewControllerMock continueRegistration];
    
    OCMVerifyAll(navigationManagerMock);
}

- (void)testThatItShowsErrorWhenVerificationCodeIsIncorrect {
    self.verificationCodeViewController.verificationCodeField.text = @"Incorrect code";
    self.verificationCodeViewController.navigationParameters = @{
        @"code": @"Correct code"
    };
    
    [self.verificationCodeViewControllerMock viewWillAppear:NO];
    [self.verificationCodeViewControllerMock continueRegistration];
    
    OCMVerify([self.verificationCodeViewControllerMock showErrorAlertWithMessage:[OCMArg checkWithBlock:^BOOL(NSString *message) {
        XCTAssertTrue([message containsString:@"verification code in incorrect"]);
        return YES;
    }]]);
}

@end
