#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>
#import "EuropAssistViewController.h"

@interface EuropAssistViewControllerTests : XCTestCase

@end

@implementation EuropAssistViewControllerTests

- (void)testThatItLoadsEuropAssistWebsite {
    EuropAssistViewController *europAssistViewController = [[EuropAssistViewController alloc] init];
    
    id mockEuropAssistViewController = OCMPartialMock(europAssistViewController);
    OCMExpect([mockEuropAssistViewController loadURLString:[OCMArg checkWithBlock:^BOOL(NSString *URLString) {
        XCTAssertTrue([URLString containsString:@"//www.europ-assistance.com/en"]);
        return YES;
    }]]);
    
    (void)europAssistViewController.view;
    [europAssistViewController viewWillAppear:NO];
    
    OCMVerifyAll(mockEuropAssistViewController);
}

@end
