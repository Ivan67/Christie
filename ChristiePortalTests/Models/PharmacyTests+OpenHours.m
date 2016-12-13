
#import "PharmacyTests.h"

@interface PharmacyTests (OpenHours)

@end

@implementation PharmacyTests (OpenHours)

- (NSDate *)dateWithHour:(NSInteger)hour minute:(NSInteger)minute {
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.year = 2016;
    dateComponents.weekOfYear = 1;
    dateComponents.weekday = WeekdayMonday;
    dateComponents.hour = hour;
    dateComponents.minute = minute;
    
    NSCalendar *gregorianCalendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    NSDate *date = [gregorianCalendar dateFromComponents:dateComponents];
    return date;
}

- (NSDate *)dateWithWeekday:(NSInteger)weekday hour:(NSInteger)hour minute:(NSInteger)minute {
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.year = 2016;
    dateComponents.weekOfYear = 1;
    dateComponents.weekday = weekday;
    dateComponents.hour = hour;
    dateComponents.minute = minute;
    
    NSCalendar *gregorianCalendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    NSDate *date = [gregorianCalendar dateFromComponents:dateComponents];
    return date;
}

/***********************************
 *   P H A R M A C Y   H O U R S   *
 ***********************************/

- (void)testThatIsOpen24HoursReturnsYesIfItIsOpen24Hours {
    self.pharmacy.pharmacyHours = @"Open 24 hours";
    
    XCTAssertTrue([self.pharmacy isOpen24Hours]);
}

- (void)testThatIsOpen24HoursReturnsNoIfItIsNotOpen24Hours {
    self.pharmacy.pharmacyHours = @"M-F 0:00 AM - 0:00 PM Sat 0:00 AM - 0:00 PM Sun 0:00 AM - 0:00 PM";
    
    XCTAssertFalse([self.pharmacy isOpen24Hours]);
}

- (void)testThatIsOpenAlwaysReturnsYesIfItIsOpen24Hours {
    self.pharmacy.pharmacyHours = @"Open 24 hours";
    
    XCTAssertTrue([self.pharmacy isOpenAt:[self dateWithHour:0 minute:0]]);
    XCTAssertTrue([self.pharmacy isOpenAt:[self dateWithHour:6 minute:0]]);
    XCTAssertTrue([self.pharmacy isOpenAt:[self dateWithHour:12 minute:0]]);
    XCTAssertTrue([self.pharmacy isOpenAt:[self dateWithHour:18 minute:0]]);
    XCTAssertTrue([self.pharmacy isOpenAt:[self dateWithHour:24 minute:0]]);
}

- (void)testThatItIsOpenAtTimesWithinPharmacyOpenHours {
    self.pharmacy.pharmacySunHoursOpen = [self dateWithHour:6 minute:0];
    self.pharmacy.pharmacySunHoursClose = [self dateWithHour:18 minute:0];
    self.pharmacy.pharmacySatHoursOpen = [self dateWithHour:6 minute:0];
    self.pharmacy.pharmacySatHoursClose = [self dateWithHour:18 minute:0];
    self.pharmacy.pharmacyMFHoursOpen = [self dateWithHour:6 minute:0];
    self.pharmacy.pharmacyMFHoursClose = [self dateWithHour:18 minute:0];
    
    XCTAssertTrue([self.pharmacy isOpenAt:[self dateWithWeekday:WeekdaySunday hour:6 minute:0]]);
    XCTAssertTrue([self.pharmacy isOpenAt:[self dateWithWeekday:WeekdaySunday hour:12 minute:0]]);
    XCTAssertTrue([self.pharmacy isOpenAt:[self dateWithWeekday:WeekdaySunday hour:17 minute:59]]);
    
    XCTAssertTrue([self.pharmacy isOpenAt:[self dateWithWeekday:WeekdaySaturday hour:6 minute:0]]);
    XCTAssertTrue([self.pharmacy isOpenAt:[self dateWithWeekday:WeekdaySaturday hour:12 minute:0]]);
    XCTAssertTrue([self.pharmacy isOpenAt:[self dateWithWeekday:WeekdaySaturday hour:17 minute:59]]);
    
    for (Weekday weekday = WeekdayMonday; weekday <= WeekdayFriday; weekday++) {
        XCTAssertTrue([self.pharmacy isOpenAt:[self dateWithWeekday:weekday hour:6 minute:0]]);
        XCTAssertTrue([self.pharmacy isOpenAt:[self dateWithWeekday:weekday hour:12 minute:0]]);
        XCTAssertTrue([self.pharmacy isOpenAt:[self dateWithWeekday:weekday hour:17 minute:59]]);
    }
}

- (void)testThatItIsClosedAtTimesOutsideOfPharmacyOpenHours {
    self.pharmacy.pharmacySunHoursOpen = [self dateWithHour:6 minute:0];
    self.pharmacy.pharmacySunHoursClose = [self dateWithHour:18 minute:0];
    self.pharmacy.pharmacySatHoursOpen = [self dateWithHour:6 minute:0];
    self.pharmacy.pharmacySatHoursClose = [self dateWithHour:18 minute:0];
    self.pharmacy.pharmacyMFHoursOpen = [self dateWithHour:6 minute:0];
    self.pharmacy.pharmacyMFHoursClose = [self dateWithHour:18 minute:0];
    
    XCTAssertFalse([self.pharmacy isOpenAt:[self dateWithWeekday:WeekdaySunday hour:18 minute:0]]);
    XCTAssertFalse([self.pharmacy isOpenAt:[self dateWithWeekday:WeekdaySunday hour:0 minute:0]]);
    XCTAssertFalse([self.pharmacy isOpenAt:[self dateWithWeekday:WeekdaySunday hour:5 minute:59]]);
    
    XCTAssertFalse([self.pharmacy isOpenAt:[self dateWithWeekday:WeekdaySaturday hour:18 minute:0]]);
    XCTAssertFalse([self.pharmacy isOpenAt:[self dateWithWeekday:WeekdaySaturday hour:0 minute:0]]);
    XCTAssertFalse([self.pharmacy isOpenAt:[self dateWithWeekday:WeekdaySaturday hour:5 minute:59]]);
    
    for (Weekday weekday = WeekdayMonday; weekday <= WeekdayFriday; weekday++) {
        XCTAssertFalse([self.pharmacy isOpenAt:[self dateWithWeekday:weekday hour:18 minute:0]]);
        XCTAssertFalse([self.pharmacy isOpenAt:[self dateWithWeekday:weekday hour:0 minute:0]]);
        XCTAssertFalse([self.pharmacy isOpenAt:[self dateWithWeekday:weekday hour:5 minute:59]]);
    }
}

/*****************************
 *   P H O T O   H O U R S   *
 *****************************/

- (void)testThatHasPhotoOpen24HoursReturnsYesIfPhotoIsOpen24Hours {
    self.pharmacy.photoHours = @"Open 24 hours";
    
    XCTAssertTrue([self.pharmacy hasPhotoOpen24Hours]);
}

- (void)testThatHasPhotoOpen24HoursReturnsNoIfPhotoIsNotOpen24Hours {
    self.pharmacy.photoHours = @"M-F 0:00 AM - 0:00 PM Sat 0:00 AM - 0:00 PM Sun 0:00 AM - 0:00 PM";
    
    XCTAssertFalse([self.pharmacy hasPhotoOpen24Hours]);
}

- (void)testThatHasPhotoOpenAlwaysReturnsYesIfPhotoIsOpen24Hours {
    self.pharmacy.photoHours = @"Open 24 hours";
    
    XCTAssertTrue([self.pharmacy hasPhotoOpenAt:[self dateWithHour:0 minute:0]]);
    XCTAssertTrue([self.pharmacy hasPhotoOpenAt:[self dateWithHour:6 minute:0]]);
    XCTAssertTrue([self.pharmacy hasPhotoOpenAt:[self dateWithHour:12 minute:0]]);
    XCTAssertTrue([self.pharmacy hasPhotoOpenAt:[self dateWithHour:18 minute:0]]);
    XCTAssertTrue([self.pharmacy hasPhotoOpenAt:[self dateWithHour:24 minute:0]]);
}

- (void)testThatItHasPhotoOpenAtTimesWithinPhotoOpenHours {
    self.pharmacy.photoSunHoursOpen = [self dateWithHour:6 minute:0];
    self.pharmacy.photoSunHoursClose = [self dateWithHour:18 minute:0];
    self.pharmacy.photoSatHoursOpen = [self dateWithHour:6 minute:0];
    self.pharmacy.photoSatHoursClose = [self dateWithHour:18 minute:0];
    self.pharmacy.photoMFHoursOpen = [self dateWithHour:6 minute:0];
    self.pharmacy.photoMFHoursClose = [self dateWithHour:18 minute:0];
    
    XCTAssertTrue([self.pharmacy hasPhotoOpenAt:[self dateWithWeekday:WeekdaySunday hour:6 minute:0]]);
    XCTAssertTrue([self.pharmacy hasPhotoOpenAt:[self dateWithWeekday:WeekdaySunday hour:12 minute:0]]);
    XCTAssertTrue([self.pharmacy hasPhotoOpenAt:[self dateWithWeekday:WeekdaySunday hour:17 minute:59]]);
    
    XCTAssertTrue([self.pharmacy hasPhotoOpenAt:[self dateWithWeekday:WeekdaySaturday hour:6 minute:0]]);
    XCTAssertTrue([self.pharmacy hasPhotoOpenAt:[self dateWithWeekday:WeekdaySaturday hour:12 minute:0]]);
    XCTAssertTrue([self.pharmacy hasPhotoOpenAt:[self dateWithWeekday:WeekdaySaturday hour:17 minute:59]]);
    
    for (Weekday weekday = WeekdayMonday; weekday <= WeekdayFriday; weekday++) {
        XCTAssertTrue([self.pharmacy hasPhotoOpenAt:[self dateWithWeekday:weekday hour:6 minute:0]]);
        XCTAssertTrue([self.pharmacy hasPhotoOpenAt:[self dateWithWeekday:weekday hour:12 minute:0]]);
        XCTAssertTrue([self.pharmacy hasPhotoOpenAt:[self dateWithWeekday:weekday hour:17 minute:59]]);
    }
}

- (void)testThatItHasPhotoClosedAtTimesOutsideOfPhotoOpenHours {
    self.pharmacy.photoSunHoursOpen = [self dateWithHour:6 minute:0];
    self.pharmacy.photoSunHoursClose = [self dateWithHour:18 minute:0];
    self.pharmacy.photoSatHoursOpen = [self dateWithHour:6 minute:0];
    self.pharmacy.photoSatHoursClose = [self dateWithHour:18 minute:0];
    self.pharmacy.photoMFHoursOpen = [self dateWithHour:6 minute:0];
    self.pharmacy.photoMFHoursClose = [self dateWithHour:18 minute:0];
    
    XCTAssertFalse([self.pharmacy hasPhotoOpenAt:[self dateWithWeekday:WeekdaySunday hour:18 minute:0]]);
    XCTAssertFalse([self.pharmacy hasPhotoOpenAt:[self dateWithWeekday:WeekdaySunday hour:0 minute:0]]);
    XCTAssertFalse([self.pharmacy hasPhotoOpenAt:[self dateWithWeekday:WeekdaySunday hour:5 minute:59]]);
    
    XCTAssertFalse([self.pharmacy hasPhotoOpenAt:[self dateWithWeekday:WeekdaySaturday hour:18 minute:0]]);
    XCTAssertFalse([self.pharmacy hasPhotoOpenAt:[self dateWithWeekday:WeekdaySaturday hour:0 minute:0]]);
    XCTAssertFalse([self.pharmacy hasPhotoOpenAt:[self dateWithWeekday:WeekdaySaturday hour:5 minute:59]]);
    
    for (Weekday weekday = WeekdayMonday; weekday <= WeekdayFriday; weekday++) {
        XCTAssertFalse([self.pharmacy hasPhotoOpenAt:[self dateWithWeekday:weekday hour:18 minute:0]]);
        XCTAssertFalse([self.pharmacy hasPhotoOpenAt:[self dateWithWeekday:weekday hour:0 minute:0]]);
        XCTAssertFalse([self.pharmacy hasPhotoOpenAt:[self dateWithWeekday:weekday hour:5 minute:59]]);
    }
}

/*********************************************
 *   M I N U T E   C L I N I C   H O U R S   *
 *********************************************/

- (void)testThatHasMinuteClinicOpen24HoursReturnsYesIfMinuteClinicIsOpen24Hours {
    self.pharmacy.minuteClinicHours = @"Open 24 hours";
    
    XCTAssertTrue([self.pharmacy hasMinuteClinicOpen24Hours]);
}

- (void)testThatHasMinuteClinicOpen24HoursReturnsNoIfMinuteClinicIsNotOpen24Hours {
    self.pharmacy.minuteClinicHours = @"M-F 0:00 AM - 0:00 PM Sat 0:00 AM - 0:00 PM Sun 0:00 AM - 0:00 PM";
    
    XCTAssertFalse([self.pharmacy hasMinuteClinicOpen24Hours]);
}

- (void)testThatHasMinuteClinicOpenAlwaysReturnsYesIfMinuteClinicIsOpen24Hours {
    self.pharmacy.minuteClinicHours = @"Open 24 hours";
    
    XCTAssertTrue([self.pharmacy hasMinuteClinicOpenAt:[self dateWithHour:0 minute:0]]);
    XCTAssertTrue([self.pharmacy hasMinuteClinicOpenAt:[self dateWithHour:6 minute:0]]);
    XCTAssertTrue([self.pharmacy hasMinuteClinicOpenAt:[self dateWithHour:12 minute:0]]);
    XCTAssertTrue([self.pharmacy hasMinuteClinicOpenAt:[self dateWithHour:18 minute:0]]);
    XCTAssertTrue([self.pharmacy hasMinuteClinicOpenAt:[self dateWithHour:24 minute:0]]);
}

- (void)testThatItHasMinuteClinicOpenAtTimesWithinMinuteClinicOpenHours {
    self.pharmacy.minuteClinicSunHoursOpen = [self dateWithHour:6 minute:0];
    self.pharmacy.minuteClinicSunHoursClose = [self dateWithHour:18 minute:0];
    self.pharmacy.minuteClinicSatHoursOpen = [self dateWithHour:6 minute:0];
    self.pharmacy.minuteClinicSatHoursClose = [self dateWithHour:18 minute:0];
    self.pharmacy.minuteClinicMFHoursOpen = [self dateWithHour:6 minute:0];
    self.pharmacy.minuteClinicMFHoursClose = [self dateWithHour:18 minute:0];
    
    XCTAssertTrue([self.pharmacy hasMinuteClinicOpenAt:[self dateWithWeekday:WeekdaySunday hour:6 minute:0]]);
    XCTAssertTrue([self.pharmacy hasMinuteClinicOpenAt:[self dateWithWeekday:WeekdaySunday hour:12 minute:0]]);
    XCTAssertTrue([self.pharmacy hasMinuteClinicOpenAt:[self dateWithWeekday:WeekdaySunday hour:17 minute:59]]);
    
    XCTAssertTrue([self.pharmacy hasMinuteClinicOpenAt:[self dateWithWeekday:WeekdaySaturday hour:6 minute:0]]);
    XCTAssertTrue([self.pharmacy hasMinuteClinicOpenAt:[self dateWithWeekday:WeekdaySaturday hour:12 minute:0]]);
    XCTAssertTrue([self.pharmacy hasMinuteClinicOpenAt:[self dateWithWeekday:WeekdaySaturday hour:17 minute:59]]);
    
    for (Weekday weekday = WeekdayMonday; weekday <= WeekdayFriday; weekday++) {
        XCTAssertTrue([self.pharmacy hasMinuteClinicOpenAt:[self dateWithWeekday:weekday hour:6 minute:0]]);
        XCTAssertTrue([self.pharmacy hasMinuteClinicOpenAt:[self dateWithWeekday:weekday hour:12 minute:0]]);
        XCTAssertTrue([self.pharmacy hasMinuteClinicOpenAt:[self dateWithWeekday:weekday hour:17 minute:59]]);
    }
}

- (void)testThatItHasMinuteClinicClosedAtTimesOutsideOfMinuteClinicOpenHours {
    self.pharmacy.minuteClinicSunHoursOpen = [self dateWithHour:6 minute:0];
    self.pharmacy.minuteClinicSunHoursClose = [self dateWithHour:18 minute:0];
    self.pharmacy.minuteClinicSatHoursOpen = [self dateWithHour:6 minute:0];
    self.pharmacy.minuteClinicSatHoursClose = [self dateWithHour:18 minute:0];
    self.pharmacy.minuteClinicMFHoursOpen = [self dateWithHour:6 minute:0];
    self.pharmacy.minuteClinicMFHoursClose = [self dateWithHour:18 minute:0];
    
    XCTAssertFalse([self.pharmacy hasMinuteClinicOpenAt:[self dateWithWeekday:WeekdaySunday hour:18 minute:0]]);
    XCTAssertFalse([self.pharmacy hasMinuteClinicOpenAt:[self dateWithWeekday:WeekdaySunday hour:0 minute:0]]);
    XCTAssertFalse([self.pharmacy hasMinuteClinicOpenAt:[self dateWithWeekday:WeekdaySunday hour:5 minute:59]]);
    
    XCTAssertFalse([self.pharmacy hasMinuteClinicOpenAt:[self dateWithWeekday:WeekdaySaturday hour:18 minute:0]]);
    XCTAssertFalse([self.pharmacy hasMinuteClinicOpenAt:[self dateWithWeekday:WeekdaySaturday hour:0 minute:0]]);
    XCTAssertFalse([self.pharmacy hasMinuteClinicOpenAt:[self dateWithWeekday:WeekdaySaturday hour:5 minute:59]]);
    
    for (Weekday weekday = WeekdayMonday; weekday <= WeekdayFriday; weekday++) {
        XCTAssertFalse([self.pharmacy hasMinuteClinicOpenAt:[self dateWithWeekday:weekday hour:18 minute:0]]);
        XCTAssertFalse([self.pharmacy hasMinuteClinicOpenAt:[self dateWithWeekday:weekday hour:0 minute:0]]);
        XCTAssertFalse([self.pharmacy hasMinuteClinicOpenAt:[self dateWithWeekday:weekday hour:5 minute:59]]);
    }
}

@end
