//
//  HealthPlanDetectorTests.m
//  ChristiePortal
//
//  Created by Sergey on 12/01/16.
//  Copyright © 2016 Rhinoda. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HealthPlanDetector.h"

#define AssertCoordinateHealhPlan(_latitude, _longitude, _expectedPlan) \
    do { \
        CLLocation *location = [[CLLocation alloc] initWithLatitude:(_latitude) longitude:(_longitude)]; \
        HealthPlan plan = [HealthPlanDetector healthPlanFromLocation:location]; \
        XCTAssertEqual(plan, _expectedPlan); \
    } while (NO)

@interface HealthPlanDetectorTests : XCTestCase

@end

@implementation HealthPlanDetectorTests

- (void)testThatItReturnsUnknownForNilLocation {
    HealthPlan plan = [HealthPlanDetector healthPlanFromLocation:nil];
    XCTAssertEqual(plan, HealthPlanUnknown);
}

- (void)testThatItReturnsTuftsForLocationsInsideRIAndMA {
    AssertCoordinateHealhPlan(41.821589, -71.412467, HealthPlanTufts); // Providence, RI
    AssertCoordinateHealhPlan(41.696500, -70.304946, HealthPlanTufts); // Barnstable, RI
    AssertCoordinateHealhPlan(41.958468, -70.681228, HealthPlanTufts); // Plymouth, RI
    AssertCoordinateHealhPlan(41.488006, -71.319808, HealthPlanTufts); // Newport, RI
    AssertCoordinateHealhPlan(42.449502, -73.250115, HealthPlanTufts); // Pittsfield, MA
    AssertCoordinateHealhPlan(42.360082, -71.058880, HealthPlanTufts); // Boston, MA
    AssertCoordinateHealhPlan(42.709686, -71.170463, HealthPlanTufts); // Lawrence, MA
}

- (void)testThatItReturnsCignaForLocationsOutsideRIAndMA {
    AssertCoordinateHealhPlan(43.012680, -71.453704, HealthPlanCigna); // Manchester, NH
    AssertCoordinateHealhPlan(42.875964, -72.561950, HealthPlanCigna); // Brattleboro, NH
    AssertCoordinateHealhPlan(41.768238, -72.679367, HealthPlanCigna); // Hartford, CT
    AssertCoordinateHealhPlan(42.650121, -73.766326, HealthPlanCigna); // Albany, NY
    AssertCoordinateHealhPlan(40.712117, -74.003631, HealthPlanCigna); // New York, NY
}

- (void)testThatItReturnsBothForLocationsNearBorder {
    AssertCoordinateHealhPlan(42.898100, -70.893402, HealthPlanBoth);
    AssertCoordinateHealhPlan(42.753062, -71.242218, HealthPlanBoth);
    AssertCoordinateHealhPlan(42.726839, -72.137603, HealthPlanBoth);
    AssertCoordinateHealhPlan(42.753062, -73.280181, HealthPlanBoth);
    AssertCoordinateHealhPlan(42.055410, -73.494415, HealthPlanBoth);
    AssertCoordinateHealhPlan(42.023283, -71.790504, HealthPlanBoth);
    AssertCoordinateHealhPlan(41.776432, -71.802864, HealthPlanBoth);
    AssertCoordinateHealhPlan(41.442726, -71.805267, HealthPlanBoth);
    AssertCoordinateHealhPlan(41.401535, -71.833076, HealthPlanBoth);
}

@end
