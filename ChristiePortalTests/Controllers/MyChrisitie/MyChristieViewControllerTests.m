#import <BlocksKit/BlocksKit.h>
#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>
#import "MyChristieViewController.h"
#import "PickerViewController.h"
#import "User.h"

@interface MyChristieViewController () <MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *memberNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *memberIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *countryLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;

- (IBAction)showClaimsView;
- (IBAction)showShareCardMenu;

@end

@interface MyChristieViewControllerTests : XCTestCase

@property (nonatomic) MyChristieViewController *myChristieViewController;
@property (nonatomic) id myChristieViewControllerMock;

@end

@implementation MyChristieViewControllerTests

- (void)setUp {
    [super setUp];
    
    self.myChristieViewController = [[MyChristieViewController alloc]init];
    (void)self.myChristieViewController.view;
    
    self.myChristieViewControllerMock = OCMPartialMock(self.myChristieViewController);
}

- (void)testThatItDisplaysUserInfo {
    User *user = OCMPartialMock([[User alloc] init]);
    OCMStub([(id)user sharedUser]).andReturn(user);
    
    user.firstName = @"John";
    user.lastName = @"Smith";
    user.oldMemberID = @"ABC123";
    user.phone = @"+1 (123) 456 78 90";
    user.email = @"user@example.com";
    user.country = @"USA";
    user.address1 = @"address 1";
    user.address2 = @"address 2";
    user.birthDate = [NSDate dateWithTimeIntervalSince1970:0];
    
    [self.myChristieViewController viewWillAppear:NO];
    
    XCTAssertEqualObjects(self.myChristieViewController.memberNameLabel.text, @"John Smith");
    XCTAssertEqualObjects(self.myChristieViewController.memberIDLabel.text, @"ABC123");
    XCTAssertEqualObjects(self.myChristieViewController.phoneLabel.text, @"+1 (123) 456 78 90");
    XCTAssertEqualObjects(self.myChristieViewController.emailLabel.text, @"user@example.com");
    XCTAssertEqualObjects(self.myChristieViewController.countryLabel.text, @"USA");
    XCTAssertEqualObjects(self.myChristieViewController.addressLabel.text, @"address 1, address 2");
    XCTAssertEqualObjects(self.myChristieViewController.dateLabel.text, @"01/01/1970");
}

- (void)testThatItShowsShareCardMenu {
    OCMExpect([[self.myChristieViewControllerMock ignoringNonObjectArgs] presentViewController:[OCMArg checkWithBlock:^BOOL(PickerViewController *pickerViewController) {
        XCTAssertTrue([pickerViewController isKindOfClass:[PickerViewController class]]);
        BOOL hasPrintAction = [pickerViewController.actions bk_any:^BOOL(PickerAction *action) {
            return [[action.title lowercaseString] containsString:@"print"];
        }];
        XCTAssertTrue(hasPrintAction);
        BOOL hasEmailAction = [pickerViewController.actions bk_any:^BOOL(PickerAction *action) {
            return [[action.title lowercaseString] containsString:@"email"];
        }];
        XCTAssertTrue(hasEmailAction);
        BOOL hasTextAction = [pickerViewController.actions bk_any:^BOOL(PickerAction *action) {
            return [[action.title lowercaseString] containsString:@"text"];
        }];
        XCTAssertTrue(hasTextAction);
        return YES;
    }] animated:NO completion:[OCMArg any]]);
    
    [self.myChristieViewControllerMock showShareCardMenu];
    
    OCMVerifyAll(self.myChristieViewControllerMock);
}

- (void)executeShareMenuActionWithTitle:(NSString *)title {
    __block PickerViewController *pickerViewController;
    
    OCMStub([[self.myChristieViewControllerMock ignoringNonObjectArgs] presentViewController:[OCMArg checkWithBlock:^BOOL(id obj) {
        if (![obj isKindOfClass:[PickerViewController class]]) {
            return NO;
        }
        pickerViewController = obj;
        return YES;
    }] animated:NO completion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        [invocation getArgument:&pickerViewController atIndex:2];
        PickerAction *foundAction = [pickerViewController.actions bk_match:^BOOL(PickerAction *action) {
            return [[action.title lowercaseString] containsString:title];
        }];
        if (foundAction != nil) {
            foundAction.handler();
        }
    });
    
    [self.myChristieViewControllerMock showShareCardMenu];
}

- (void)testThatItShowsErrorIfPrintingIsNotAvailable {
    id printInteractionControllerMock = OCMClassMock([UIPrintInteractionController class]);
    OCMStub([printInteractionControllerMock isPrintingAvailable]).andReturn(NO);
    
    OCMExpect([self.myChristieViewControllerMock showErrorAlertWithMessage:[OCMArg checkWithBlock:^BOOL(NSString *message) {
        return [[message lowercaseString] containsString:@"printing is not available"];
    }]]);
    
    [self executeShareMenuActionWithTitle:@"print"];
    
    OCMVerifyAll(self.myChristieViewControllerMock);
}

- (void)testThatItShowsErrorIfCannotPrintCardImage {
    id printInteractionControllerMock = OCMClassMock([UIPrintInteractionController class]);
    OCMStub([printInteractionControllerMock isPrintingAvailable]).andReturn(YES);
    OCMStub([printInteractionControllerMock canPrintData:[OCMArg any]]).andReturn(NO);
    
    OCMExpect([self.myChristieViewControllerMock showErrorAlertWithMessage:[OCMArg checkWithBlock:^BOOL(NSString *message) {
        return [[message lowercaseString] containsString:@"image format"];
    }]]);
    
    [self executeShareMenuActionWithTitle:@"print"];
    
    OCMVerifyAll(self.myChristieViewControllerMock);
}

- (void)testThatItShowsPrintInteractionScreen {
    id printInteractionControllerMock = OCMClassMock([UIPrintInteractionController class]);
    OCMStub([printInteractionControllerMock isPrintingAvailable]).andReturn(YES);
    OCMStub([printInteractionControllerMock canPrintData:[OCMArg any]]).andReturn(YES);
    OCMStub([printInteractionControllerMock sharedPrintController]).andReturn(printInteractionControllerMock);
    
    OCMExpect([printInteractionControllerMock setPrintingItem:[OCMArg isNotNil]]);
    OCMExpect([printInteractionControllerMock setPrintInfo:[OCMArg checkWithBlock:^BOOL(UIPrintInfo *printInfo) {
        XCTAssertTrue([[printInfo.jobName lowercaseString] containsString:@"card"]);
        return YES;
    }]]);
    OCMExpect([[printInteractionControllerMock ignoringNonObjectArgs] presentAnimated:NO completionHandler:[OCMArg any]]);
    
    [self executeShareMenuActionWithTitle:@"print"];
    
    OCMVerifyAll(printInteractionControllerMock);
}

- (void)stubNoticeAlert {
    id alertActionMock = OCMClassMock([UIAlertAction class]);
    OCMStub([[alertActionMock ignoringNonObjectArgs] actionWithTitle:[OCMArg any] style:0 handler:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void (^handler)(UIAlertAction *action);
        [invocation getArgument:&handler atIndex:4];
        if (handler != nil) {
            handler(alertActionMock);
        }
    }).andReturn(alertActionMock);
}

- (void)testThatItShowsErrorIfMessagingIsNotSupported {
    id messageComposeViewControllerMock = OCMClassMock([MFMessageComposeViewController class]);
    OCMStub([messageComposeViewControllerMock canSendText]).andReturn(NO);
    [self stubNoticeAlert];
    
    OCMExpect([self.myChristieViewControllerMock showErrorAlertWithMessage:[OCMArg checkWithBlock:^BOOL(NSString *message) {
        XCTAssertTrue([[message lowercaseString] containsString:@"messaging is not supported"]);
        return YES;
    }]]);
    
    [self executeShareMenuActionWithTitle:@"text"];
    
    OCMVerifyAll(self.myChristieViewControllerMock);
}

- (void)testThatItShowsMessageComposeScreen {
    id messageComposeViewControllerMock = OCMClassMock([MFMessageComposeViewController class]);
    OCMStub([messageComposeViewControllerMock canSendText]).andReturn(YES);
    OCMStub([messageComposeViewControllerMock canSendSubject]).andReturn(YES);
    OCMStub([messageComposeViewControllerMock canSendAttachments]).andReturn(YES);
    [self stubNoticeAlert];
    
    OCMExpect([[self.myChristieViewControllerMock ignoringNonObjectArgs] presentViewController:[OCMArg checkWithBlock:^BOOL(MFMessageComposeViewController *messageComposeViewController) {
        if (![messageComposeViewController isKindOfClass:[MFMessageComposeViewController class]]) {
            return NO;
        }
        XCTAssertTrue([[messageComposeViewController.subject lowercaseString] containsString:@"card"]);
        return YES;
    }] animated:NO completion:[OCMArg any]]);
    
    [self executeShareMenuActionWithTitle:@"text"];
    
    OCMVerifyAll(self.myChristieViewControllerMock);
}

- (void)testThatItHidesMessageComposeScreenWhenFinished {
    id messageComposeViewControllerMock = OCMClassMock([MFMessageComposeViewController class]);
    OCMStub([messageComposeViewControllerMock canSendText]).andReturn(YES);
    [self stubNoticeAlert];
    
    __block MFMessageComposeViewController *messageComposeViewController;
    OCMStub([[self.myChristieViewControllerMock ignoringNonObjectArgs] presentViewController:[OCMArg checkWithBlock:^BOOL(id obj) {
        if (![obj isKindOfClass:[MFMessageComposeViewController class]]) {
            return NO;
        }
        messageComposeViewController = obj;
        return YES;
    }] animated:NO completion:[OCMArg any]]);
    
    [self executeShareMenuActionWithTitle:@"text"];
    [messageComposeViewController.messageComposeDelegate messageComposeViewController:messageComposeViewController didFinishWithResult:MessageComposeResultSent];
    
    OCMVerify([[self.myChristieViewControllerMock ignoringNonObjectArgs] dismissViewControllerAnimated:NO completion:[OCMArg any]]);
}

- (void)testThatItShowsErrorIfMailingIsNotSupported {
    id mailComposeViewControllerMock = OCMClassMock([MFMailComposeViewController class]);
    OCMStub([mailComposeViewControllerMock canSendMail]).andReturn(NO);
    [self stubNoticeAlert];
    
    OCMExpect([self.myChristieViewControllerMock showErrorAlertWithMessage:[OCMArg checkWithBlock:^BOOL(NSString *message) {
        XCTAssertTrue([[message lowercaseString] containsString:@"mailing is not supported"]);
        return YES;
    }]]);
    
    [self executeShareMenuActionWithTitle:@"email"];
    
    OCMVerifyAll(self.myChristieViewControllerMock);
}

- (void)testThatItShowsMailComposeScreen {
    id mailComposeViewControllerMock = OCMClassMock([MFMailComposeViewController class]);
    OCMStub([mailComposeViewControllerMock canSendMail]).andReturn(YES);
    [self stubNoticeAlert];
    
    OCMExpect([[self.myChristieViewControllerMock ignoringNonObjectArgs] presentViewController:[OCMArg checkWithBlock:^BOOL(MFMailComposeViewController *mailComposeViewController) {
        if (![mailComposeViewController isKindOfClass:[MFMailComposeViewController class]]) {
            return NO;
        }
        return YES;
    }] animated:NO completion:[OCMArg any]]);
    
    [self executeShareMenuActionWithTitle:@"email"];
    
    OCMVerifyAll(self.myChristieViewControllerMock);
}

- (void)testThatItHidesMailComposeScreenWhenFinished {
    id mailComposeViewControllerMock = OCMClassMock([MFMailComposeViewController class]);
    OCMStub([mailComposeViewControllerMock canSendMail]).andReturn(YES);
    [self stubNoticeAlert];
    
    __block MFMailComposeViewController *mailComposeViewController;
    OCMStub([[self.myChristieViewControllerMock ignoringNonObjectArgs] presentViewController:[OCMArg checkWithBlock:^BOOL(id obj) {
        if (![obj isKindOfClass:[MFMailComposeViewController class]]) {
            return NO;
        }
        mailComposeViewController = obj;
        return YES;
    }] animated:NO completion:[OCMArg any]]);
    
    [self executeShareMenuActionWithTitle:@"email"];
    [mailComposeViewController.mailComposeDelegate mailComposeController:mailComposeViewController didFinishWithResult:MFMailComposeResultSent error:nil];
    
    OCMVerify([[self.myChristieViewControllerMock ignoringNonObjectArgs] dismissViewControllerAnimated:NO completion:[OCMArg any]]);
}

- (void)testThatItShowsClaimsViewControllerWhenClaimsButtonPressed {
    id navigationManagerMock = OCMClassMock([NavigationManager class]);
    OCMStub([self.myChristieViewControllerMock navigationManager]).andReturn(navigationManagerMock);

    [self.myChristieViewControllerMock showClaimsView];

    OCMVerify([navigationManagerMock navigateTo:@"/my-christie/claims"]);
}

@end
