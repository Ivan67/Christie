
#import <XCTest/XCTest.h>
#import "DistanceFormatter.h"

static const double MetersPerMile = 1609.34;

@interface DistanceFormatterTests : XCTestCase

@end

@implementation DistanceFormatterTests

- (void)testThatItFormatsShortDistances {
    NSString *formattedDistance = [DistanceFormatter stringFromDistance:MetersPerMile / 10];
    
    XCTAssertEqualObjects(formattedDistance, @"0.1 mi");
}

- (void)testThatItFormatsLongDistances {
    NSString *formattedDistance = [DistanceFormatter stringFromDistance:100 * MetersPerMile];
    
    XCTAssertEqualObjects(formattedDistance, @"100 mi");
}

@end
