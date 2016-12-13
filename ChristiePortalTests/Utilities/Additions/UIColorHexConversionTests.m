//
//  UIColorHexConversionTests.m
//  ChristiePortal
//
//  Created by Sergey on 09/11/15.
//  Copyright © 2015 Rhinoda. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "UIColor+Hex.h"

static const CGFloat ColorAccuracy = 1E-6;

@interface UIColorHexConversionTests : XCTestCase

@end

@implementation UIColorHexConversionTests

- (void)testThatColorWithRGBSetsRedComponent {
    UIColor *color = [UIColor colorWithRGB:0xAABBCC];
    
    CGFloat red;
    [color getRed:&red green:nil blue:nil alpha:nil];
    
    XCTAssertEqualWithAccuracy(0xAA / 255.0, red, ColorAccuracy);
}

- (void)testThatColorWithRGBSetsGreenComponent {
    UIColor *color = [UIColor colorWithRGB:0xAABBCC];
    
    CGFloat green;
    [color getRed:nil green:&green blue:nil alpha:nil];
    
    XCTAssertEqualWithAccuracy(0xBB / 255.0, green, ColorAccuracy);
}

- (void)testThatColorWithRGBSetsBlueComponent {
    UIColor *color = [UIColor colorWithRGB:0xAABBCC];
    
    CGFloat blue;
    [color getRed:nil green:nil blue:&blue alpha:nil];
    
    XCTAssertEqualWithAccuracy(0xCC / 255.0, blue, ColorAccuracy);
}

- (void)testThatColorWithRGBSetsAlphaComponentToOne {
    UIColor *color = [UIColor colorWithRGB:0xAABBCC];
    
    CGFloat alpha;
    [color getRed:nil green:nil blue:nil alpha:&alpha];
    
    XCTAssertEqualWithAccuracy(1, alpha, ColorAccuracy);
}

- (void)testThatColorWithRGAlphaBSetsAlphaComponent {
    UIColor *color = [UIColor colorWithRGB:0xAABBCC alpha:0.5];
    
    CGFloat alpha;
    [color getRed:nil green:nil blue:nil alpha:&alpha];
    
    XCTAssertEqualWithAccuracy(0.5, alpha, ColorAccuracy);
}

@end
