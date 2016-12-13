//
//  UIViewControllerAlertHelpersTests.m
//  ChristiePortal
//
//  Created by Sergey on 01/12/15.
//  Copyright © 2015 Rhinoda. All rights reserved.
//

#import <BlocksKit/BlocksKit.h>
#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>
#import "UIViewController+AlertHelpers.h"

@interface UIViewControllerAlertHelpersTests : XCTestCase

@end

@implementation UIViewControllerAlertHelpersTests

- (void)testThatItShowsGenericAlert {
    id mockViewController = OCMPartialMock([[UIViewController alloc] init]);
    id action = OCMClassMock([UIAlertAction class]);
    
    [mockViewController showAlertWithTitle:@"Fixture title" message:@"Fixture message" actions:@[action]];
    
    OCMVerify([[mockViewController ignoringNonObjectArgs] presentViewController:[OCMArg checkWithBlock:^BOOL(UIAlertController *alertController) {
        XCTAssertTrue([alertController.title containsString:@"Fixture title"]);
        XCTAssertTrue([alertController.message containsString:@"Fixture message"]);
        XCTAssertTrue([alertController.actions containsObject:action]);
        return YES;
    }] animated:NO completion:[OCMArg any]]);
}

- (void)testThatItShowsErrorAlert {
    id mockViewController = OCMPartialMock([[UIViewController alloc] init]);
    
    [mockViewController showErrorAlertWithMessage:@"Fixture message"];
    
    OCMVerify([[mockViewController ignoringNonObjectArgs] presentViewController:[OCMArg checkWithBlock:^BOOL(UIAlertController *alertController) {
        XCTAssertTrue([alertController.title containsString:@"Error"]);
        XCTAssertTrue([alertController.message containsString:@"Fixture message"]);
        BOOL hasOKAction = [alertController.actions bk_any:^BOOL(UIAlertAction *action) {
            return [action.title containsString:@"OK"];
        }];
        XCTAssertTrue(hasOKAction);
        return YES;
    }] animated:NO completion:[OCMArg any]]);
}

@end
