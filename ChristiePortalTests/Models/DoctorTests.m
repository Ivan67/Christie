
#import <XCTest/XCTest.h>
#import "Doctor.h"

@interface DoctorTests : XCTestCase

@end

@implementation DoctorTests

- (void)testThatItInitializesProperties {
    Doctor *doctor = [[Doctor alloc] initWithName:@"Fixture name" address:@"Fixture address" type:@"Fixture type"];
    
    XCTAssertEqualObjects(doctor.name, @"Fixture name");
    XCTAssertEqualObjects(doctor.address, @"Fixture address");
    XCTAssertEqualObjects(doctor.type, @"Fixture type");
}

@end
