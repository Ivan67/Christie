#import "DTTimePeriod+ContainsTime.h"

@implementation DTTimePeriod (ContainsTime)

- (BOOL)containsTime:(NSDate *)time {
    if (time.hour < self.StartDate.hour
        || (time.hour == self.StartDate.hour && time.minute < self.StartDate.minute)
        || (time.hour == self.StartDate.hour && time.minute == self.StartDate.minute && time.second < self.StartDate.second)) {
        return NO;
    }
    if (time.hour > self.EndDate.hour
        || (time.hour == self.EndDate.hour && time.minute >= self.EndDate.minute)
        || (time.hour == self.EndDate.hour && time.minute == self.EndDate.minute && time.second >= self.EndDate.second)) {
        return NO;
    }
    return YES;
}

@end
