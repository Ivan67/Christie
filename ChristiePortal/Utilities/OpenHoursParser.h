//
//  OpenHoursParser.h
//  ChristiePortal
//
//  Created by Sergey on 12/10/15.
//  Copyright © 2015 Rhinoda. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DTTimePeriod;

@interface OpenHoursParser : NSObject

+ (void)parseOpenHours:(NSString *)openHours
            inTimeZone:(NSTimeZone *)timeZone
      workdayOpenHours:(DTTimePeriod **)workdayOpenHours
     saturdayOpenHours:(DTTimePeriod **)saturdayOpenHours
       sundayOpenHours:(DTTimePeriod **)sundayOpenHours;

@end
