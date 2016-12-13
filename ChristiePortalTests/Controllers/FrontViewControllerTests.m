#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "FrontVIewController.h"
#import "Random.h"

@interface FrontViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

@end

@interface FrontViewControllerTests : XCTestCase

@end

@implementation FrontViewControllerTests

- (void)testThatItUpdatesBackgroundImage {
    FrontViewController *frontViewController = [[FrontViewController alloc] init];
    
    id backgroundImageViewMock = OCMPartialMock([[UIImageView alloc] init]);
    frontViewController.backgroundImageView = backgroundImageViewMock;
    
    static const NSUInteger randomNumbers[] = {0, 1};
    __block NSUInteger randomIndex = 0;
    
    id randomMock = OCMClassMock([Random class]);
    OCMStub([[randomMock ignoringNonObjectArgs] nextIntegerWithUpperBound:0]).andDo(^(NSInvocation *invocation) {
        NSUInteger returnValue = randomNumbers[randomIndex++];
        [invocation setReturnValue:&returnValue];
    });
    
    [frontViewController viewWillAppear:NO];
    UIImage *image1 = frontViewController.backgroundImageView.image;

    [frontViewController viewWillAppear:NO];
    UIImage *image2 = frontViewController.backgroundImageView.image;
    
    XCTAssertNotNil(image1);
    XCTAssertNotNil(image2);
    XCTAssertNotEqual(image1, image2);
}

@end
