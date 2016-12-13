#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>
#import "CignaSearchViewController.h"
#import "LocationMonitor.h"

@interface CignaSearchViewController () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIView *overlayView;

@end

@interface CignaSearchViewControllerTests : XCTestCase

@end

@implementation CignaSearchViewControllerTests

- (void)testThatItGeocodesCurrentLocationIfSearchLocationIsNotSpecified {
    id mockLocation = OCMClassMock([CLLocation class]);
    id mockLocationMonitor = OCMClassMock([LocationMonitor class]);
    OCMStub([mockLocationMonitor sharedMonitor]).andReturn(mockLocationMonitor);
    OCMStub([(LocationMonitor *)mockLocationMonitor location]).andReturn(mockLocation);
    
    id mockGeocoder = OCMClassMock([CLGeocoder class]);
    CignaSearchViewController *cignaSearchViewController = [[CignaSearchViewController alloc] initWithGeocoder:mockGeocoder];
    (void)cignaSearchViewController.view;
    
    cignaSearchViewController.navigationParameters = @{
        @"doctor": @"",
        @"location": @""
    };
    [cignaSearchViewController viewWillAppear:NO];

    OCMVerify([mockGeocoder reverseGeocodeLocation:mockLocation completionHandler:[OCMArg any]]);
}

- (void)testThatItStartsLoadingCignaWebsiteInWebViewWhenViewAppears {
    CignaSearchViewController *cignaSearchViewController = [[CignaSearchViewController alloc] initWithGeocoder:nil];
    (void)cignaSearchViewController.view;

    id mockWebView = OCMPartialMock(cignaSearchViewController.webView);
    cignaSearchViewController.webView = mockWebView;
    
    OCMExpect([mockWebView loadRequest:[OCMArg checkWithBlock:^BOOL(NSURLRequest *request) {
        XCTAssertTrue([request.URL.absoluteString containsString:@"//hcpdirectory.cigna.com/web/public/providers"]);
        return YES;
    }]]);
    
    [cignaSearchViewController viewWillAppear:NO];

    OCMVerifyAll(mockWebView);
}

- (void)testThatItRunsJavaScriptAfterPageLoad {
    CignaSearchViewController *cignaSearchViewController = [[CignaSearchViewController alloc] initWithGeocoder:nil];
    (void)cignaSearchViewController.view;
    
    cignaSearchViewController.navigationParameters = @{
        @"doctor": @"Fixture doctor",
        @"location": @"Fixture location"
    };
    [cignaSearchViewController viewWillAppear:NO];
    
    id mockWebView = OCMClassMock([UIWebView class]);
    OCMStub([mockWebView isLoading]).andReturn(NO);
    cignaSearchViewController.webView = mockWebView;
    
    [cignaSearchViewController webViewDidFinishLoad:mockWebView];
    
    OCMVerify([mockWebView stringByEvaluatingJavaScriptFromString:[OCMArg checkWithBlock:^BOOL(NSString *script) {
        XCTAssertTrue([script containsString:@"Fixture location"]);
        XCTAssertTrue([script containsString:@"Fixture doctor"]);
        return YES;
    }]]);
}

@end
