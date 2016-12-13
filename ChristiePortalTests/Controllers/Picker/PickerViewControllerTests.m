//
//  PickerViewControllerTests.m
//  ChristiePortal
//
//  Created by Sergey on 16/12/15.
//  Copyright © 2015 Rhinoda. All rights reserved.
//

#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>
#import "PickerViewController.h"

@interface PickerViewController ()

@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *button1;
@property (weak, nonatomic) IBOutlet UIButton *button2;
@property (weak, nonatomic) IBOutlet UIButton *button3;
@property (weak, nonatomic) IBOutlet UIButton *button4;

- (IBAction)performActionForButton:(UIButton *)button;

@end

@interface PickerViewControllerTests : XCTestCase

@end

@implementation PickerViewControllerTests

- (void)testThatItDismissesItselfAfterCancel {
    PickerViewController *pickerViewController = OCMPartialMock([[PickerViewController alloc] init]);
    (void)pickerViewController.view;
    
    [pickerViewController performActionForButton:pickerViewController.cancelButton];
    
    OCMVerify([[(id)pickerViewController ignoringNonObjectArgs] dismissViewControllerAnimated:NO completion:[OCMArg any]]);
}

- (void)testThatItDismissesItselfAfterActionCompletion {
    PickerViewController *pickerViewController = OCMPartialMock([[PickerViewController alloc] init]);
    [pickerViewController addAction:[PickerAction actionWithTitle:@"Fixture action" handler:nil]];
    (void)pickerViewController.view;
    
    [pickerViewController performActionForButton:pickerViewController.button1];
    
    OCMVerify([[(id)pickerViewController ignoringNonObjectArgs] dismissViewControllerAnimated:NO completion:[OCMArg any]]);
}

- (void)testThatItDismissesItselfAfterOnTouch {
    PickerViewController *pickerViewController = OCMPartialMock([[PickerViewController alloc] init]);
    [pickerViewController addAction:[PickerAction actionWithTitle:@"Fixture action" handler:nil]];
    (void)pickerViewController.view;
    
    [pickerViewController touchesBegan:[NSSet set] withEvent:nil];
    
    OCMVerify([[(id)pickerViewController ignoringNonObjectArgs] dismissViewControllerAnimated:NO completion:[OCMArg any]]);
}

- (void)testThatItCallsActionHandler {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Called action handler"];
    
    PickerViewController *pickerViewController = OCMPartialMock([[PickerViewController alloc] init]);
    [pickerViewController addAction:[PickerAction actionWithTitle:@"Fixture action" handler:^{
        [expectation fulfill];
    }]];
    (void)pickerViewController.view;
    
    [pickerViewController performActionForButton:pickerViewController.button1];
    
    [self waitForExpectationsWithTimeout:0.1 handler:nil];
}

- (void)testThatItHidesButtonsWithoutActions {
    PickerViewController *pickerViewController = OCMPartialMock([[PickerViewController alloc] init]);
    [pickerViewController addAction:[PickerAction actionWithTitle:@"Fixture action 1" handler:nil]];
    [pickerViewController addAction:[PickerAction actionWithTitle:@"Fixture action 2" handler:nil]];
    
    (void)pickerViewController.view;
    
    XCTAssertFalse(pickerViewController.button1.hidden);
    XCTAssertFalse(pickerViewController.button2.hidden);
    XCTAssertTrue(pickerViewController.button3.hidden);
    XCTAssertTrue(pickerViewController.button4.hidden);
}

@end
