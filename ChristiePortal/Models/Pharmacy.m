
#import <DateTools.h>
#import "DTTimePeriod+ContainsTime.h"
#import "Pharmacy.h"

static NSString *const Open24HoursString = @"Open 24 hours";

typedef NS_ENUM(NSInteger, Weekday) {
    WeekdaySunday = 1,
    WeekdayMonday = 2,
    WeekdayTuesday = 3,
    WeekdayWednesday = 4,
    WeekdayThursday = 5,
    WeekdayFriday = 6,
    WeekdaySaturday = 7
};

@implementation Pharmacy

+ (NSString *)entityName {
    return NSStringFromClass(self.class);
}

- (CLLocation *)location {
    return [[CLLocation alloc] initWithLatitude:[self.latitude doubleValue] longitude:[self.longitude doubleValue]];
}

- (void)setLocation:(CLLocation *)location {
    self.latitude = @(location.coordinate.latitude);
    self.longitude = @(location.coordinate.longitude);
}

- (NSString *)displayName {
    return [NSString stringWithFormat:@"CVS Store #%ld", (long)[self.numericCode integerValue]];
}

- (NSString *)shortAddress {
    NSScanner *scanner = [[NSScanner alloc] initWithString:self.address];
    NSString *shortAddress;
    [scanner scanUpToString:@"," intoString:&shortAddress];
    return shortAddress;
}

- (CLLocationDistance)distanceToLocation:(CLLocation *)location {
    return [self.location distanceFromLocation:location];
}

- (BOOL)isOpenAt:(NSDate *)date {
    if ([self isOpen24Hours]) {
        return YES;
    }
    
    DTTimePeriod *openPeriod;
    switch (date.weekday) {
        case WeekdaySunday:
            openPeriod = [DTTimePeriod timePeriodWithStartDate:self.pharmacySunHoursOpen
                                                       endDate:self.pharmacySunHoursClose];
            break;
        case WeekdaySaturday:
            openPeriod = [DTTimePeriod timePeriodWithStartDate:self.pharmacySatHoursOpen
                                                       endDate:self.pharmacySatHoursClose];
            break;
        default:
            openPeriod = [DTTimePeriod timePeriodWithStartDate:self.pharmacyMFHoursOpen
                                                       endDate:self.pharmacyMFHoursClose];
    }
    return [openPeriod containsTime:date];
}

- (BOOL)hasPhotoOpenAt:(NSDate *)date {
    if ([self hasPhotoOpen24Hours]) {
        return YES;
    }
    
    DTTimePeriod *openPeriod;
    switch (date.weekday) {
        case WeekdaySunday:
            openPeriod = [DTTimePeriod timePeriodWithStartDate:self.photoSunHoursOpen
                                                       endDate:self.photoSunHoursClose];
            break;
        case WeekdaySaturday:
            openPeriod = [DTTimePeriod timePeriodWithStartDate:self.photoSatHoursOpen
                                                       endDate:self.photoSatHoursClose];
            break;
        default:
            openPeriod = [DTTimePeriod timePeriodWithStartDate:self.photoMFHoursOpen
                                                       endDate:self.photoMFHoursClose];
    }
    return [openPeriod containsTime:date];
}

- (BOOL)hasMinuteClinicOpenAt:(NSDate *)date {
    if ([self hasMinuteClinicOpen24Hours]) {
        return YES;
    }
    
    DTTimePeriod *openPeriod;
    switch (date.weekday) {
        case WeekdaySunday:
            openPeriod = [DTTimePeriod timePeriodWithStartDate:self.minuteClinicSunHoursOpen
                                                       endDate:self.minuteClinicSunHoursClose];
            break;
        case WeekdaySaturday:
            openPeriod = [DTTimePeriod timePeriodWithStartDate:self.minuteClinicSatHoursOpen
                                                       endDate:self.minuteClinicSatHoursClose];
            break;
        default:
            openPeriod = [DTTimePeriod timePeriodWithStartDate:self.minuteClinicMFHoursOpen
                                                       endDate:self.minuteClinicMFHoursClose];
    }
    return [openPeriod containsTime:date];
}

- (BOOL)isOpen24Hours {
    return [self.pharmacyHours containsString:Open24HoursString];
}

- (BOOL)hasPhotoOpen24Hours {
    return [self.photoHours containsString:Open24HoursString];
}

- (BOOL)hasMinuteClinicOpen24Hours {
    return [self.minuteClinicHours containsString:Open24HoursString];
}

@end
