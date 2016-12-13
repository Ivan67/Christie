#import <XCTest/XCTest.h>
#import "DTTimePeriod+ContainsTime.h"

@interface DTTimePeriodContainsTimeTests : XCTestCase

@end

@implementation DTTimePeriodContainsTimeTests;

- (NSDate *)timeFromString:(NSString *)string {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"HH:mm:ss";
    return [dateFormatter dateFromString:string];
}

- (DTTimePeriod *)timePeriodWithStartTime:(NSString *)startTime endTime:(NSString *)endTime {
    return [[DTTimePeriod alloc] initWithStartDate:[self timeFromString:startTime] endDate:[self timeFromString:endTime]];
}

- (void)testThatItContainsStartDate {
    DTTimePeriod *timePeriod = [self timePeriodWithStartTime:@"00:00:00" endTime:@"12:00:00"];
    
    XCTAssertTrue([timePeriod containsTime:[self timeFromString:@"00:00:00"]]);
}

- (void)testThatItDoesNotContainEndDate {
    DTTimePeriod *timePeriod = [self timePeriodWithStartTime:@"00:00:00" endTime:@"12:00:00"];
    
    XCTAssertFalse([timePeriod containsTime:[self timeFromString:@"12:00:00"]]);
}

- (void)testThatItDoesNotContainTimeBeforeStartDate {
    DTTimePeriod *timePeriod = [self timePeriodWithStartTime:@"00:01:01" endTime:@"12:00:00"];
    
    XCTAssertFalse([timePeriod containsTime:[self timeFromString:@"23:00:00"]]);
    XCTAssertFalse([timePeriod containsTime:[self timeFromString:@"00:00:00"]]);
    XCTAssertFalse([timePeriod containsTime:[self timeFromString:@"00:01:00"]]);
}

- (void)testThatItDoesNotContainTimeAfterEndDate {
    DTTimePeriod *timePeriod = [self timePeriodWithStartTime:@"00:00:00" endTime:@"12:00:00"];
    
    XCTAssertFalse([timePeriod containsTime:[self timeFromString:@"13:00:00"]]);
    XCTAssertFalse([timePeriod containsTime:[self timeFromString:@"12:01:00"]]);
    XCTAssertFalse([timePeriod containsTime:[self timeFromString:@"12:00:01"]]);
}
 
@end