
#import <XCTest/XCTest.h>
#import <DateTools.h>
#import "OpenHoursParser.h"

@interface OpenHoursParserTests : XCTestCase

@end

@implementation OpenHoursParserTests

- (void)testThatItReturnsCorrectWorkdayHours {
    DTTimePeriod *ignoredOpenHours;
    DTTimePeriod *workdayOpenHours;
    
    [OpenHoursParser parseOpenHours:@"M-F 06:00 AM - 07:00 PM"
                     inTimeZone:nil
               workdayOpenHours:&workdayOpenHours
              saturdayOpenHours:&ignoredOpenHours
                sundayOpenHours:&ignoredOpenHours];
    
    XCTAssertEqual(workdayOpenHours.StartDate.hour, 6);
    XCTAssertEqual(workdayOpenHours.StartDate.minute, 0);
    XCTAssertEqual(workdayOpenHours.StartDate.second, 0);
    XCTAssertEqual(workdayOpenHours.EndDate.hour, 19);
    XCTAssertEqual(workdayOpenHours.EndDate.minute, 0);
    XCTAssertEqual(workdayOpenHours.EndDate.second, 0);
}

- (void)testThatItReturnsCorrectSaturdayHours {
    DTTimePeriod *ignoredOpenHours;
    DTTimePeriod *saturdayOpenHours;
    
    [OpenHoursParser parseOpenHours:@"Sat 06:00 AM - 07:00 PM"
                         inTimeZone:nil
                   workdayOpenHours:&ignoredOpenHours
                  saturdayOpenHours:&saturdayOpenHours
                    sundayOpenHours:&ignoredOpenHours];
    
    XCTAssertEqual(saturdayOpenHours.StartDate.hour, 6);
    XCTAssertEqual(saturdayOpenHours.StartDate.minute, 0);
    XCTAssertEqual(saturdayOpenHours.StartDate.second, 0);
    XCTAssertEqual(saturdayOpenHours.EndDate.hour, 19);
    XCTAssertEqual(saturdayOpenHours.EndDate.minute, 0);
    XCTAssertEqual(saturdayOpenHours.EndDate.second, 0);
}

- (void)testThatItReturnsCorrectSundayHours {
    DTTimePeriod *ignoredOpenHours;
    DTTimePeriod *sundayOpenHours;
    
    [OpenHoursParser parseOpenHours:@"Sun 06:00 AM - 07:00 PM"
                         inTimeZone:nil
                   workdayOpenHours:&ignoredOpenHours
                  saturdayOpenHours:&ignoredOpenHours
                    sundayOpenHours:&sundayOpenHours];
    
    XCTAssertEqual(sundayOpenHours.StartDate.hour, 6);
    XCTAssertEqual(sundayOpenHours.StartDate.minute, 0);
    XCTAssertEqual(sundayOpenHours.StartDate.second, 0);
    XCTAssertEqual(sundayOpenHours.EndDate.hour, 19);
    XCTAssertEqual(sundayOpenHours.EndDate.minute, 0);
    XCTAssertEqual(sundayOpenHours.EndDate.second, 0);
}

- (void)testThatItReturnsNilStartEndDatesForEmptyString {
    DTTimePeriod *workdayOpenHours;
    DTTimePeriod *saturdayOpenHours;
    DTTimePeriod *sundayOpenHours;
    
    [OpenHoursParser parseOpenHours:nil
                         inTimeZone:nil
                   workdayOpenHours:&workdayOpenHours
                  saturdayOpenHours:&saturdayOpenHours
                    sundayOpenHours:&sundayOpenHours];
    
    XCTAssertNotNil(workdayOpenHours);
    XCTAssertNil(workdayOpenHours.StartDate);
    XCTAssertNil(workdayOpenHours.EndDate);
    
    XCTAssertNotNil(saturdayOpenHours);
    XCTAssertNil(saturdayOpenHours.StartDate);
    XCTAssertNil(saturdayOpenHours.EndDate);
    
    XCTAssertNotNil(sundayOpenHours);
    XCTAssertNil(sundayOpenHours.StartDate);
    XCTAssertNil(sundayOpenHours.EndDate);
}

- (void)testThatItReturnsNilStartEndDatesForBadlyFormattedWorkdayHoursTimes {
    DTTimePeriod *ignoredOpenHours;
    DTTimePeriod *workdayOpenHours;
    
    [OpenHoursParser parseOpenHours:@"M-F 06:00 - 19:00"
                         inTimeZone:nil
                   workdayOpenHours:&workdayOpenHours
                  saturdayOpenHours:&ignoredOpenHours
                    sundayOpenHours:&ignoredOpenHours];
    
    XCTAssertNotNil(workdayOpenHours);
    XCTAssertNil(workdayOpenHours.StartDate);
    XCTAssertNil(workdayOpenHours.EndDate);
}

- (void)testThatItReturnsNilStartEndDatesForBadlyFormattedSaturdayHoursTimes {
    DTTimePeriod *ignoredOpenHours;
    DTTimePeriod *saturdayOpenHours;
    
    [OpenHoursParser parseOpenHours:@"Sat 06:00 - 19:00"
                         inTimeZone:nil
                   workdayOpenHours:&ignoredOpenHours
                  saturdayOpenHours:&saturdayOpenHours
                    sundayOpenHours:&ignoredOpenHours];
    
    XCTAssertNotNil(saturdayOpenHours);
    XCTAssertNil(saturdayOpenHours.StartDate);
    XCTAssertNil(saturdayOpenHours.EndDate);
}

- (void)testThatItReturnsNilStartEndDatesForBadlyFormattedSundayHoursTimes {
    DTTimePeriod *ignoredOpenHours;
    DTTimePeriod *sundayOpenHours;
    
    [OpenHoursParser parseOpenHours:@"Sun 06:00 - 19:00"
                         inTimeZone:nil
                   workdayOpenHours:&ignoredOpenHours
                  saturdayOpenHours:&ignoredOpenHours
                    sundayOpenHours:&sundayOpenHours];
    
    XCTAssertNotNil(sundayOpenHours);
    XCTAssertNil(sundayOpenHours.StartDate);
    XCTAssertNil(sundayOpenHours.EndDate);
}

- (void)testThatItReturnsNilForWorkdayHoursIfOpen24Hours {
    DTTimePeriod *ignoredOpenHours;
    DTTimePeriod *workdayOpenHours;
    
    [OpenHoursParser parseOpenHours:@"M-F Open 24 hours"
                         inTimeZone:nil
                   workdayOpenHours:&workdayOpenHours
                  saturdayOpenHours:&ignoredOpenHours
                    sundayOpenHours:&ignoredOpenHours];
    
    XCTAssertNil(workdayOpenHours);
}

- (void)testThatItReturnsNilForSaturdayHoursIfOpen24Hours {
    DTTimePeriod *ignoredOpenHours;
    DTTimePeriod *saturdayOpenHours;
    
    [OpenHoursParser parseOpenHours:@"Sat Open 24 hours"
                         inTimeZone:nil
                   workdayOpenHours:&ignoredOpenHours
                  saturdayOpenHours:&saturdayOpenHours
                    sundayOpenHours:&ignoredOpenHours];
    
    XCTAssertNil(saturdayOpenHours);
}

- (void)testThatItReturnsNilForSundayHoursIfOpen24Hours {
    DTTimePeriod *ignoredOpenHours;
    DTTimePeriod *sundayOpenHours;
    
    [OpenHoursParser parseOpenHours:@"Sun Open 24 hours"
                         inTimeZone:nil
                   workdayOpenHours:&ignoredOpenHours
                  saturdayOpenHours:&ignoredOpenHours
                    sundayOpenHours:&sundayOpenHours];
    
    XCTAssertNil(sundayOpenHours);
}

@end
