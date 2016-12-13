#import <BlocksKit/BlocksKit.h>
#import <LocalAuthentication/LocalAuthentication.h>
#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>
#import <SSKeychain.h>
#import "APIClient.h"
#import "AuthenticationManager.h"
#import "SettingsManager.h"
#import "SettingsViewController.h"
#import "User.h"

@interface SettingsViewController ()

@property (weak, nonatomic) IBOutlet UISwitch *notifySwitch;
@property (weak, nonatomic) IBOutlet UISwitch *useTouchIDSwitch;
@property (weak, nonatomic) IBOutlet UITextField *currentPasswordField;
@property (weak, nonatomic) IBOutlet UITextField *theNewPasswordField;
@property (weak, nonatomic) IBOutlet UITextField *repeatNewPasswordField;

- (IBAction)changePassword;
- (IBAction)saveNotifySwitch;
- (IBAction)saveUseTouchIDSwitch;
- (IBAction)confirmLogOut;

@end

@interface SettingsViewControllerTests : XCTestCase

@property (nonatomic) id settingsManagerMock;
@property (nonatomic) id authenticationManagerMock;
@property (nonatomic) SettingsViewController *settingsViewController;
@property (nonatomic) id settingsViewControllerMock;
@property (nonatomic) id alertActionMock;

@end

@implementation SettingsViewControllerTests

- (void)setUp {
    [super setUp];
    
    self.settingsManagerMock = OCMClassMock([SettingsManager class]);
    self.authenticationManagerMock = OCMClassMock([AuthenticationManager class]);
    
    self.settingsViewController = [[SettingsViewController alloc] initWithSettingsManager:self.settingsManagerMock authenticationManager:self.authenticationManagerMock];
    (void)self.settingsViewController.view;
    
    self.settingsViewControllerMock = OCMPartialMock(self.settingsViewController);
}

- (void)tearDown {
    [super tearDown];
    
    [self.alertActionMock stopMocking];
}

- (void)testThatItLoadsSettings {
    XCTAssertFalse(self.settingsViewController.notifySwitch.on);
    XCTAssertFalse(self.settingsViewController.useTouchIDSwitch.on);
    
    OCMStub([self.settingsManagerMock notifyAboutNearbyPharmacies]).andReturn(YES);
    OCMStub([self.settingsManagerMock useTouchID]).andReturn(YES);
    [self.settingsViewController viewWillAppear:NO];
    
    XCTAssertTrue(self.settingsViewController.notifySwitch.on);
    XCTAssertTrue(self.settingsViewController.useTouchIDSwitch.on);
}

- (void)testThatItShowErrorWhenCurrentPasswordIsEmpty {
    self.settingsViewController.currentPasswordField.text = nil;
    self.settingsViewController.theNewPasswordField.text = @"Fixture new password";
    self.settingsViewController.repeatNewPasswordField.text = @"Fixture repeat new password";
    
    [self.settingsViewController changePassword];
    
    OCMVerify([self.settingsViewControllerMock showErrorAlertWithMessage:[OCMArg checkWithBlock:^BOOL(NSString *message) {
        XCTAssertTrue([message containsString:@"current password"]);
        return YES;
    }]]);
}

- (void)testThatItShowErrorWhenCurrentPasswordIsInvalid {
    self.settingsViewController.currentPasswordField.text = @"Fixture invalid password";
    self.settingsViewController.theNewPasswordField.text = @"Fixture new password";
    self.settingsViewController.repeatNewPasswordField.text = @"Fixture repeat new password";
    
    id userMock = OCMClassMock([User class]);
    OCMStub([userMock sharedUser]).andReturn(userMock);
    OCMStub([userMock username]).andReturn(@"Fxiture username");
    
    id keychainMock = OCMClassMock([SSKeychain class]);
    OCMStub([keychainMock passwordForService:[OCMArg any] account:@"Fixture username"]).andReturn(@"Fixture password");
    
    [self.settingsViewController changePassword];
    
    OCMVerify([self.settingsViewControllerMock showErrorAlertWithMessage:[OCMArg checkWithBlock:^BOOL(NSString *message) {
        XCTAssertTrue([message containsString:@"Invalid password"]);
        return YES;
    }]]);
}

- (void)testThatItShowsErrorWhenNewPasswordIsEmpty {
    self.settingsViewController.currentPasswordField.text = @"Fixture password";
    self.settingsViewController.theNewPasswordField.text = nil;
    self.settingsViewController.repeatNewPasswordField.text = @"Fixture repeat new password";
    
    id keychainMock = OCMClassMock([SSKeychain class]);
    OCMStub([keychainMock passwordForService:[OCMArg any] account:[OCMArg any]]).andReturn(@"Fixture password");
    
    [self.settingsViewController changePassword];
    
    OCMVerify([self.settingsViewControllerMock showErrorAlertWithMessage:[OCMArg checkWithBlock:^BOOL(NSString *message) {
        XCTAssertTrue([message containsString:@"your new password"]);
        return YES;
    }]]);
}

- (void)testThatItShowsErrorWhenRepeatPasswordIsEmptyOrInvalid {
    self.settingsViewController.currentPasswordField.text = @"Fixture password";
    self.settingsViewController.theNewPasswordField.text = @"Fixture new password";
    self.settingsViewController.repeatNewPasswordField.text = nil;
    
    id keychainMock = OCMClassMock([SSKeychain class]);
    OCMStub([keychainMock passwordForService:[OCMArg any] account:[OCMArg any]]).andReturn(@"Fixture password");
    
    [self.settingsViewController changePassword];
    
    OCMVerify([self.settingsViewControllerMock showErrorAlertWithMessage:[OCMArg checkWithBlock:^BOOL(NSString *message) {
        XCTAssertTrue([message containsString:@"do not match"]);
        return YES;
    }]]);
}

- (void)testThatItShowsAlertOnPasswordChangeRequestSuccess {
    self.settingsViewController.currentPasswordField.text = @"Fixture password";
    self.settingsViewController.theNewPasswordField.text = @"Fixture new password";
    self.settingsViewController.repeatNewPasswordField.text = @"Fixture new password";
    
    id keychainMock = OCMClassMock([SSKeychain class]);
    OCMStub([keychainMock passwordForService:[OCMArg any] account:[OCMArg any]]).andReturn(@"Fixture password");
    
    id userMock = OCMClassMock([User class]);
    OCMStub([userMock sharedUser]).andReturn(userMock);
    OCMStub([userMock id]).andReturn(123);
    OCMStub([userMock username]).andReturn(@"Fixture username");
    
    id APIClientMock = OCMClassMock([APIClient class]);
    OCMStub([APIClientMock sharedClient]).andReturn(APIClientMock);
    
    OCMExpect([APIClientMock PUT:@"users/123" parameters:[OCMArg any] success:([OCMArg invokeBlockWithArgs:[NSNull null], [NSNull null], nil]) failure:[OCMArg any]]);
    
    [self.settingsViewController changePassword];
    
    OCMVerifyAll(APIClientMock);
    OCMVerify([self.settingsViewControllerMock showAlertWithTitle:@"Password changed" message:[OCMArg checkWithBlock:^BOOL(NSString *message) {
        XCTAssertTrue([message containsString:@"successfully changed"]);
        return YES;
    }] actions:[OCMArg any]]);
}

- (void)testThatItSavesNotifySwitchStateToSettings {
    self.settingsViewController.notifySwitch.on = YES;
    [self.settingsViewController saveNotifySwitch];
    
    OCMVerify([self.settingsManagerMock setNotifyAboutNearbyPharmacies:YES]);
}

- (void)testThatItSavesUseTouchIDSwitchStateToSettingsWhenItIsOff {
    self.settingsViewController.useTouchIDSwitch.on = NO;
    [self.settingsViewController saveUseTouchIDSwitch];
    
    OCMVerify([self.settingsManagerMock setUseTouchID:NO]);
}

- (void)testThatItShowsErrorIfTouchIDAuthenticationIsNotAvailable {
    OCMStub([self.authenticationManagerMock authenticateWithPolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics reason:[OCMArg any] copletion:[OCMArg any] failure:([OCMArg invokeBlockWithArgs:[NSNull null], nil])]);
    
    self.settingsViewController.useTouchIDSwitch.on = YES;
    [self.settingsViewController saveUseTouchIDSwitch];
    
    OCMVerify([self.settingsViewControllerMock showErrorAlertWithMessage:[OCMArg checkWithBlock:^BOOL(NSString *message) {
        XCTAssertTrue([message containsString:@"Touch ID"]);
        return YES;
    }]]);
}

- (void)testThatItTurnsOffUseTouchIDSwitchIfTouchIDAuthenticationIsNotAvailable {
    OCMStub([self.authenticationManagerMock authenticateWithPolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics reason:[OCMArg any] copletion:[OCMArg any] failure:([OCMArg invokeBlockWithArgs:[NSNull null], nil])]);
    
    self.settingsViewController.useTouchIDSwitch.on = YES;
    [self.settingsViewController saveUseTouchIDSwitch];
    
    XCTAssertFalse(self.settingsViewController.useTouchIDSwitch.on);
}

- (void)testThatItTurnsOnUseTouchIDIfTouchIDAuthenticationSucceeded {
    OCMStub([self.authenticationManagerMock authenticateWithPolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics reason:[OCMArg any] copletion:([OCMArg invokeBlockWithArgs:@YES, [NSNull null], nil]) failure:[OCMArg any]]);
    
    self.settingsViewController.useTouchIDSwitch.on = YES;
    [self.settingsViewController saveUseTouchIDSwitch];
    
    XCTAssertTrue(self.settingsViewController.useTouchIDSwitch.on);
    OCMVerify([self.settingsManagerMock setUseTouchID:YES]);
}

- (void)testThatItTurnsOffUseTouchIDIfTouchIDAuthenticationFailed {
    OCMStub([self.authenticationManagerMock authenticateWithPolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics reason:[OCMArg any] copletion:([OCMArg invokeBlockWithArgs:@NO, [NSNull null], nil]) failure:[OCMArg any]]);
    
    self.settingsViewController.useTouchIDSwitch.on = YES;
    [self.settingsViewController saveUseTouchIDSwitch];
    
    XCTAssertFalse(self.settingsViewController.useTouchIDSwitch.on);
    OCMVerify([self.settingsManagerMock setUseTouchID:NO]);
}

- (void)testThatItShowsLogoutConfirmAlert {
    OCMExpect([self.settingsViewControllerMock showAlertWithTitle:[OCMArg any] message:[OCMArg checkWithBlock:^BOOL(NSString *message) {
        XCTAssertTrue([message containsString:@"you sure"]);
        return YES;
    }] actions:[OCMArg checkWithBlock:^BOOL(NSArray<UIAlertAction *> *actions) {
        BOOL hasYesAction = [actions bk_any:^BOOL(UIAlertAction *action) {
            return [action.title containsString:@"Yes"];
        }];
        XCTAssertTrue(hasYesAction);
        BOOL hasNoAction = [actions bk_any:^BOOL(UIAlertAction *action) {
            return [action.title containsString:@"No"];
        }];
        XCTAssertTrue(hasNoAction);
        return YES;
    }]]);
    
    [self.settingsViewController confirmLogOut];
    
    OCMVerifyAll(self.settingsViewControllerMock);
}

- (void)stubAndInvokeAlertActionWithTitle:(NSString *)title {
    self.alertActionMock = OCMClassMock([UIAlertAction class]);
    OCMStub([[self.alertActionMock ignoringNonObjectArgs] actionWithTitle:title style:0 handler:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void (^handler)(UIAlertAction *action);
        [invocation getArgument:&handler atIndex:4];
        if (handler != nil) {
            handler(nil);
        }
    }).andReturn(self.alertActionMock);
}

- (void)testThatItForgetsUsernameWhenLoggingOut {
    User *user = [[User alloc] init];
    user.username = @"Fixture username";
    user.loggedIn = YES;
    
    id userMock = OCMPartialMock(user);
    OCMStub([userMock sharedUser]).andReturn(user);
    OCMStub([self.settingsManagerMock username]).andReturn(@"Fixture username");
    
    [self stubAndInvokeAlertActionWithTitle:@"Yes"];
    
    [self.settingsViewController confirmLogOut];
    
    XCTAssertEqual(user.username.length, 0u);
    XCTAssertFalse(user.loggedIn);
    OCMVerify([self.settingsManagerMock setUsername:nil]);
}

- (void)testThatItMarksUserNotLoggedInWhenLoggingOut {
    id userMock = OCMClassMock([User class]);
    OCMStub([userMock sharedUser]).andReturn(userMock);
    
    [self stubAndInvokeAlertActionWithTitle:@"Yes"];
    [self.settingsViewController confirmLogOut];
    
    OCMVerify([userMock setLoggedIn:NO]);
}

- (void)testThatItShowsLoginScreenAfterSuccessfulLogout {
    id navigationManagerMock = OCMClassMock([NavigationManager class]);
    OCMStub([self.settingsViewControllerMock navigationManager]).andReturn(navigationManagerMock);
    
    id parentNavigationControllerMock = OCMClassMock([NavigationManager class]);
    OCMStub([navigationManagerMock parentNavigationManager]).andReturn(parentNavigationControllerMock);
    
    [self stubAndInvokeAlertActionWithTitle:@"Yes"];
    
    [self.settingsViewControllerMock confirmLogOut];
    
    OCMVerify([parentNavigationControllerMock navigateTo:@"/login"]);
}

- (void)testThatItDoesNotForgetUserWhenLogoutIsCancelled {
    User *user = [[User alloc] init];
    user.username = @"Fixture username";
    user.loggedIn = YES;
    id userMock = OCMPartialMock(user);
    
    OCMStub([userMock sharedUser]).andReturn(user);
    OCMStub([self.settingsManagerMock username]).andReturn(@"Fixture username");
    
    [self stubAndInvokeAlertActionWithTitle:@"No"];
    
    [[self.settingsManagerMock reject] setUsername:[OCMArg any]];
    
    [self.settingsViewControllerMock confirmLogOut];
    
    XCTAssertEqualObjects(user.username, @"Fixture username");
    XCTAssertTrue(user.loggedIn);
}

- (void)testThatItDoesNotDisableUseTouchIDWhenLogoutIsCancalled {
    OCMStub([self.settingsManagerMock useTouchID]).andReturn(YES);
    [self stubAndInvokeAlertActionWithTitle:@"No"];
    
    [[self.settingsManagerMock reject] setUseTouchID:NO];
    
    [self.settingsViewController confirmLogOut];
}

@end
