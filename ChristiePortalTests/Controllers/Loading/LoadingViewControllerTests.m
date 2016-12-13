//
//  LoadingViewControllerTests.m
//  ChristiePortal
//
//  Created by Sergey on 18/11/15.
//  Copyright © 2015 Rhinoda. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "LoadingViewController.h"

@interface LoadingViewController ()

@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

@end

@interface LoadingViewControllerTests : XCTestCase

@end

@implementation LoadingViewControllerTests

- (void)testThatItSetsInitialProgressToZero {
    LoadingViewController *loadingViewController = [[LoadingViewController alloc] init];
    (void)loadingViewController.view;
    
    XCTAssertEqual(loadingViewController.progress, 0);
}

- (void)testThatItUpdatesProgressViewProgressWhenUpdatingProgress {
    LoadingViewController *loadingViewController = [[LoadingViewController alloc] init];
    (void)loadingViewController.view;
    
    loadingViewController.progress = 0.5;
    float progress = loadingViewController.progressView.progress;
    
    XCTAssertEqual(progress, 0.5);
}

- (void)testThatItReturnsProgressViewProgressWhenGettingProgress {
    LoadingViewController *loadingViewController = [[LoadingViewController alloc] init];
    (void)loadingViewController.view;
    
    loadingViewController.progressView.progress = 0.5;
    float progress = loadingViewController.progress;
    
    XCTAssertEqual(progress, 0.5);
}

@end
