#import <Foundation/Foundation.h>

@class DTTimePeriod;

@interface OpenHoursParser : NSObject

+ (void)parseOpenHours:(NSString *)openHours
            inTimeZone:(NSTimeZone *)timeZone
      workdayOpenHours:(DTTimePeriod **)workdayOpenHours
     saturdayOpenHours:(DTTimePeriod **)saturdayOpenHours
       sundayOpenHours:(DTTimePeriod **)sundayOpenHours;

@end
