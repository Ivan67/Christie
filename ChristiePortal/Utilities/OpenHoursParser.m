#import <DateTools.h>
#import "OpenHoursParser.h"

@implementation OpenHoursParser

+ (void)parseHoursRange:(NSString *)hoursRange intoOpenHour:(NSString **)openHour closeHour:(NSString **)closeHour {
    NSScanner *hoursScanner = [[NSScanner alloc] initWithString:hoursRange];
    [hoursScanner scanUpToString:@"-" intoString:openHour];
    [hoursScanner scanString:@"-" intoString:nil];
    [hoursScanner scanUpToString:@"\0" intoString:closeHour];
}

+ (NSDate *)dateFromHour:(NSString *)hour inTimeZone:(NSTimeZone *)timeZone {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    formatter.timeZone = timeZone;
    formatter.dateFormat = @"hh:mm a";
    return [formatter dateFromString:hour];
}

+ (void)parseOpenHours:(NSString *)openHours
            inTimeZone:(NSTimeZone *)timeZone
      workdayOpenHours:(DTTimePeriod **)workdayOpenHours
     saturdayOpenHours:(DTTimePeriod **)saturdayOpenHours
       sundayOpenHours:(DTTimePeriod **)sundayOpenHours {
    
    static NSString *const WorkdayPrefix = @"M-F";
    static NSString *const SaturdayPrefix = @"Sat";
    static NSString *const SundayPrefix = @"Sun";
    static NSString *const EndOfString = @"\0";
    static NSString *const Open24Hours = @"Open 24 hours";
    NSScanner *scanner = [[NSScanner alloc] initWithString:openHours];
    
    NSString *workdayHoursString;
    if (![scanner scanString:WorkdayPrefix intoString:nil] ||
        ![scanner scanUpToString:SaturdayPrefix intoString:&workdayHoursString]) {
        workdayHoursString = @"";
    }
    
    if ([workdayHoursString containsString:Open24Hours]) {
        *workdayOpenHours = nil;
    } else {
        NSString *workdayOpenHour, *workdayCloseHour;
        [self parseHoursRange:workdayHoursString intoOpenHour:&workdayOpenHour closeHour:&workdayCloseHour];
        *workdayOpenHours = [DTTimePeriod timePeriodWithStartDate:[self dateFromHour:workdayOpenHour inTimeZone:timeZone]
                                                          endDate:[self dateFromHour:workdayCloseHour inTimeZone:timeZone]];
    }
    
    NSString *saturdayHoursString;
    if (![scanner scanString:SaturdayPrefix intoString:nil] ||
        ![scanner scanUpToString:SundayPrefix intoString:&saturdayHoursString]) {
        saturdayHoursString = @"";
    }
    
    if ([saturdayHoursString containsString:Open24Hours]) {
        *saturdayOpenHours = nil;
    } else {
        NSString *saturdayOpenHour, *saturdayCloseHour;
        [self parseHoursRange:saturdayHoursString intoOpenHour:&saturdayOpenHour closeHour:&saturdayCloseHour];
        *saturdayOpenHours = [DTTimePeriod timePeriodWithStartDate:[self dateFromHour:saturdayOpenHour inTimeZone:timeZone]
                                                           endDate:[self dateFromHour:saturdayCloseHour inTimeZone:timeZone]];
    }
    
    NSString *sundayHoursString;
    if (![scanner scanString:SundayPrefix intoString:nil] ||
        ![scanner scanUpToString:EndOfString intoString:&sundayHoursString]) {
        sundayHoursString = @"";
    }
    
    if ([sundayHoursString containsString:Open24Hours]) {
        *sundayOpenHours = nil;
    } else {
        NSString *sundayOpenHour, *sundayCloseHour;
        [self parseHoursRange:sundayHoursString intoOpenHour:&sundayOpenHour closeHour:&sundayCloseHour];
        *sundayOpenHours = [DTTimePeriod timePeriodWithStartDate:[self dateFromHour:sundayOpenHour inTimeZone:timeZone]
                                                         endDate:[self dateFromHour:sundayCloseHour inTimeZone:timeZone]];
    }
}

@end
