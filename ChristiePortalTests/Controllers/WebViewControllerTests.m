//
//  WebViewControllerTests.m
//  ChristiePortal
//
//  Created by Sergey on 18/11/15.
//  Copyright © 2015 Rhinoda. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "WebViewController.h"

@interface WebViewController () <UIWebViewDelegate>

@end

@interface WebViewControllerTests : XCTestCase

@end

@implementation WebViewControllerTests

- (void)testThatItLoadsURLInWebView {
    WebViewController *webViewController = [[WebViewController alloc] init];
    
    id webViewMock = OCMPartialMock([[UIWebView alloc] init]);
    webViewController.webView = webViewMock;
    
    NSString *URLString = @"http://example.com";
    [webViewController loadURLString:URLString];
    
    OCMVerify([webViewMock loadRequest:[OCMArg checkWithBlock:^BOOL(NSURLRequest *URLRequest) {
        XCTAssertEqualObjects(URLRequest.URL.absoluteString, URLString);
        return YES;
    }]]);
}

- (void)testThatItStopsAcitivityIndicatorWhenRequestFails {
    WebViewController *webViewController = [[WebViewController alloc] init];
    
    id activityIndicatorMock = OCMClassMock([UIActivityIndicatorView class]);
    webViewController.activityIndicator = activityIndicatorMock;
    
    NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:0 userInfo:nil];
    [webViewController webView:webViewController.webView didFailLoadWithError:error];
    
    OCMVerify([activityIndicatorMock stopAnimating]);
}

- (void)testThatItShowsErrorWhenRequestFails {
    WebViewController *webViewController = [[WebViewController alloc] init];
    
    NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:0 userInfo:@{
        NSLocalizedDescriptionKey: @"Fixture description"
    }];
    
    id webViewControllerMock = OCMPartialMock(webViewController);
    [webViewControllerMock webView:webViewController.webView didFailLoadWithError:error];
    
    OCMVerify([webViewControllerMock showErrorAlertWithMessage:[OCMArg checkWithBlock:^BOOL(NSString *message) {
        XCTAssertTrue([message containsString:@"Fixture description"]);
        return YES;
    }]]);
}

- (void)testThatItDoesNotShowErrorWhenRequestIsCancelled {
    WebViewController *webViewController = [[WebViewController alloc] init];
    
    NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorCancelled userInfo:@{
        NSLocalizedDescriptionKey: @"Fixture description"
    }];
    
    id webViewControllerMock = OCMPartialMock(webViewController);
    [[webViewControllerMock reject] showErrorAlertWithMessage:[OCMArg any]];
    
    [webViewControllerMock webView:webViewController.webView didFailLoadWithError:error];
}

- (void)testThatItStartsAnimatingActivityIndicatorWhenLoadIsStarted {
    WebViewController *webViewController = [[WebViewController alloc] init];
    id activityIndicatorMock = OCMClassMock([UIActivityIndicatorView class]);
    webViewController.activityIndicator = activityIndicatorMock;
    
    NSString *URLString = @"http://example.com";
    [webViewController loadURLString:URLString];
    
    OCMVerify([activityIndicatorMock startAnimating]);
}

- (void)testThatItStopsAnimatingActivityIndicatorWhenLoadIsFinished {
    WebViewController *webViewController = [[WebViewController alloc] init];
    
    id activityIndicatorMock = OCMClassMock([UIActivityIndicatorView class]);
    webViewController.activityIndicator = activityIndicatorMock;
    
    id webViewMock = OCMPartialMock([[UIWebView alloc] init]);
    webViewController.webView = webViewMock;
    OCMStub([webViewMock isLoading]).andReturn(NO);
    
    (void)webViewController.view;
    [webViewController loadURLString:nil];
    [[webViewMock delegate] webViewDidFinishLoad:webViewMock];
    
    OCMVerify([activityIndicatorMock stopAnimating]);
}

- (void)testThatItCallsDelegateWhenLoadIsStarted {
    WebViewController *webViewController = [[WebViewController alloc] init];
    id webViewMock = OCMPartialMock([[UIWebView alloc] init]);
    webViewController.webView = webViewMock;
    id webViewControllerDelegateMock = OCMProtocolMock(@protocol(WebViewControllerDelegate));
    webViewController.delegate = webViewControllerDelegateMock;
    
    [webViewController webViewDidStartLoad:webViewMock];
    
    OCMVerify([webViewControllerDelegateMock webViewControllerDidStartLoad:webViewController]);
}

- (void)testThatItCallsDelegateWhenLoadIsFinished {
    WebViewController *webViewController = [[WebViewController alloc] init];
    id webViewMock = OCMPartialMock([[UIWebView alloc] init]);
    webViewController.webView = webViewMock;
    id webViewControllerDelegateMock = OCMProtocolMock(@protocol(WebViewControllerDelegate));
    webViewController.delegate = webViewControllerDelegateMock;
    
    [webViewController webViewDidFinishLoad:webViewMock];
    
    OCMVerify([webViewControllerDelegateMock webViewControllerDidFinishLoad:webViewController]);
}

@end
