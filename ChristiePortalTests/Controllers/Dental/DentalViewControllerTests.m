#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>
#import "DentalViewController.h"

@interface DentalViewControllerTests : XCTestCase

@end

@implementation DentalViewControllerTests

- (void)testThatItLoadsDentalWebsite {
    DentalViewController *dentalViewController = [[DentalViewController alloc] init];
    
    id mockDentalViewController = OCMPartialMock(dentalViewController);
    OCMExpect([mockDentalViewController loadURLString:[OCMArg checkWithBlock:^BOOL(NSString *URLString) {
        XCTAssertTrue([URLString containsString:@"//www1.careington.com/providers/search_providers2.aspx"]);
        return YES;
    }]]);
    
    (void)dentalViewController.view;
    [dentalViewController viewWillAppear:NO];
    
    OCMVerifyAll(mockDentalViewController);
}

@end
