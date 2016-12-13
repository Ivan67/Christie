
#import <XCTest/XCTest.h>
#import "Polygon.h"

@interface PolygonTests : XCTestCase

@end

@implementation PolygonTests

- (void)testThatPolygonContainsPointWithinItsBounds {
    const CGPoint points[] = {
        CGPointMake(0, 0),
        CGPointMake(1, 0),
        CGPointMake(1, 1),
        CGPointMake(0, 1)
    };
    Polygon *polygon = [Polygon polygonWithPoints:points count:sizeof(points) / sizeof(points[0])];
    
    XCTAssertTrue([polygon containsPoint:CGPointMake(0.5, 0.5)]);
}

- (void)testThatPolygonDoesNotContainPointOutsideOfItsBounds {
    const CGPoint points[] = {
        CGPointMake(0, 0),
        CGPointMake(1, 0),
        CGPointMake(1, 1),
        CGPointMake(0, 1)
    };
    Polygon *polygon = [Polygon polygonWithPoints:points count:sizeof(points) / sizeof(points[0])];
    
    XCTAssertFalse([polygon containsPoint:CGPointMake(1, 1.1)]);
    XCTAssertFalse([polygon containsPoint:CGPointMake(-1, 0)]);
}

@end
