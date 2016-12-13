#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>
#import "PlanDocumentsViewController.h"

@interface PlanDocumentsViewControllerTests : XCTestCase

@end

@implementation PlanDocumentsViewControllerTests

- (void)testThatItLoadsEuropAssistWebsite {
    PlanDocumentsViewController *planDocumentsViewController = [[PlanDocumentsViewController alloc] init];
    
    id mockPlanDocumentsViewController = OCMPartialMock(planDocumentsViewController);
    OCMExpect([mockPlanDocumentsViewController loadURLString:[OCMArg checkWithBlock:^BOOL(NSString *URLString) {
        XCTAssertTrue([URLString containsString:@"//www.christiestudenthealth.com/tools-resources"]);
        return YES;
    }]]);
    
    (void)planDocumentsViewController.view;
    [planDocumentsViewController viewWillAppear:NO];
    
    OCMVerifyAll(mockPlanDocumentsViewController);
}

@end
