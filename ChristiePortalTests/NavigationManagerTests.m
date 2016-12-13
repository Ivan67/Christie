
#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>
#import "NavigationManager.h"

@interface NavigationManagerTests : XCTestCase

@end

@implementation NavigationManagerTests

- (void)testThatItStoresParentNavigationManager {
    NavigationManager *parentNavigationManager = [[NavigationManager alloc] initWithNavigationController:nil];
    NavigationManager *childNavigationManager = [[NavigationManager alloc] initWithNavigationController:nil parentNavigationManager:parentNavigationManager];
    
    XCTAssertEqual(childNavigationManager.parentNavigationManager, parentNavigationManager);
}

- (void)testThatItRegistersViewControllers {
    NavigationManager *navigationManager = [[NavigationManager alloc] initWithNavigationController:nil];
    
    id mockViewController = OCMClassMock([UIViewController class]);
    [navigationManager registerPath:@"/a" forViewController:mockViewController];
    
    id returnedViewController = [navigationManager viewControllerForPath:@"/a"];
    
    XCTAssertEqual(returnedViewController, mockViewController);
}

- (void)testThatItRegistersViewControllerBlocks {
    NavigationManager *navigationManager = [[NavigationManager alloc] initWithNavigationController:nil];
    
    id mockViewController = OCMClassMock([UIViewController class]);
    [navigationManager registerPath:@"/a" forBlock:^UIViewController *{
        return mockViewController;
    }];
    
    id returnedViewController = [navigationManager viewControllerForPath:@"/a"];
    
    XCTAssertEqual(returnedViewController, mockViewController);
}

- (void)testThatItSetsExtensionPropertiesOnViewControllers {
    NavigationManager *navigationManager = [[NavigationManager alloc] initWithNavigationController:nil];
    
    UIViewController *staticViewController = [[UIViewController alloc] init];
    [navigationManager registerPath:@"/a" forViewController:staticViewController];
    UIViewController *viewControllerFromBlock = [[UIViewController alloc] init];
    [navigationManager registerPath:@"/b" forBlock:^UIViewController *{
        return viewControllerFromBlock;
    }];
    
    [navigationManager navigateTo:@"/a" withParameters:@{@"keyA": @"valueA"}];
    [navigationManager navigateTo:@"/b" withParameters:@{@"keyB": @"valueB"}];
    
    XCTAssertEqual(staticViewController.navigationManager, navigationManager);
    XCTAssertEqual(viewControllerFromBlock.navigationManager, navigationManager);
    XCTAssertEqualObjects(staticViewController.navigationParameters, @{@"keyA": @"valueA"});
    XCTAssertEqualObjects(viewControllerFromBlock.navigationParameters, @{@"keyB": @"valueB"});
}

- (void)testThatNavigationParametersPropertyWorks {
    UIViewController *viewController = [[UIViewController alloc] init];
    
    viewController.navigationParameters = @{@"key": @"value"};
    NSDictionary *navigationParameters = viewController.navigationParameters;
    
    XCTAssertEqualObjects(navigationParameters, @{@"key": @"value"});
}

- (void)testThatItNavigatesToRootViewController {
    id mockNavigationController = OCMClassMock([UINavigationController class]);
    NavigationManager *navigationManager = [[NavigationManager alloc] initWithNavigationController:mockNavigationController];
    
    id mockViewController = OCMClassMock([UIViewController class]);
    [navigationManager registerPath:@"/a" forViewController:mockViewController];
    
    OCMExpect([mockNavigationController setViewControllers:[OCMArg checkWithBlock:^BOOL(NSArray<UIViewController *> *viewControllers) {
        XCTAssertEqual(viewControllers.count, 1u);
        XCTAssertEqual(viewControllers[0], mockViewController);
        return YES;
    }] animated:YES]);
    
    [navigationManager navigateTo:@"/a"];
    
    OCMVerifyAll(mockNavigationController);
}

- (void)testThatItNavigatesToChildViewController {
    id mockNavigationController = OCMClassMock([UINavigationController class]);
    NavigationManager *navigationManager = [[NavigationManager alloc] initWithNavigationController:mockNavigationController];
    
    id mockParentViewController = OCMClassMock([UIViewController class]);
    [navigationManager registerPath:@"/a" forViewController:mockParentViewController];
    id mockChildViewController = OCMClassMock([UIViewController class]);
    [navigationManager registerPath:@"/a/b" forViewController:mockChildViewController];
    
    OCMExpect([mockNavigationController setViewControllers:[OCMArg checkWithBlock:^BOOL(NSArray<UIViewController *> *viewControllers) {
        XCTAssertEqual(viewControllers.count, 2u);
        XCTAssertEqual(viewControllers[0], mockParentViewController);
        XCTAssertEqual(viewControllers[1], mockChildViewController);
        return YES;
    }] animated:YES]);
    
    [navigationManager navigateTo:@"/a/b"];
    
    OCMVerifyAll(mockNavigationController);
}

- (void)testThatItStopsPushingAtFirstUnregisteredViewController {
    id mockNavigationController = OCMClassMock([UINavigationController class]);
    NavigationManager *navigationManager = [[NavigationManager alloc] initWithNavigationController:mockNavigationController];
    
    id mockParentViewController = OCMClassMock([UIViewController class]);
    [navigationManager registerPath:@"/a" forViewController:mockParentViewController];
    id mockGrandchildViewController = OCMClassMock([UIViewController class]);
    [navigationManager registerPath:@"/a/b/c" forViewController:mockGrandchildViewController];
    
    OCMExpect([mockNavigationController setViewControllers:[OCMArg checkWithBlock:^BOOL(NSArray<UIViewController *> *viewControllers) {
        XCTAssertEqual(viewControllers.count, 1u);
        XCTAssertEqual(viewControllers[0], mockParentViewController);
        return YES;
    }] animated:YES]);
    
    [navigationManager navigateTo:@"/a/b/c"];

    OCMVerifyAll(mockNavigationController);
}

@end
