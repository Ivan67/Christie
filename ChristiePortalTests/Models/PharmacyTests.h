

#import <XCTest/XCTest.h>
#import "Pharmacy.h"

typedef NS_ENUM(NSInteger, Weekday) {
    WeekdaySunday = 1,
    WeekdayMonday = 2,
    WeekdayTuesday = 3,
    WeekdayWednesday = 4,
    WeekdayThursday = 5,
    WeekdayFriday = 6,
    WeekdaySaturday = 7
};

@interface PharmacyTests : XCTestCase

@property (nonatomic) Pharmacy *pharmacy;

@end
