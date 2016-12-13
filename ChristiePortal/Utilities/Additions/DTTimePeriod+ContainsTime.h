#import <Foundation/Foundation.h>
#import <DateTools.h>

@interface DTTimePeriod (ContainsTime)

- (BOOL)containsTime:(NSDate *)time;

@end
