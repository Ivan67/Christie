//
//  DTTimePeriod+TimeContains.h
//  ChristiePortal
//
//  Created by Sergey on 12/10/15.
//  Copyright © 2015 Rhinoda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DateTools.h>

@interface DTTimePeriod (ContainsTime)

- (BOOL)containsTime:(NSDate *)time;

@end
