//
//  HealthPlanDetector.h
//  ChristiePortal
//
//  Created by Sergey on 12/01/16.
//  Copyright © 2016 Rhinoda. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, HealthPlan) {
    HealthPlanUnknown,
    HealthPlanCigna,
    HealthPlanTufts,
    HealthPlanBoth
};

@interface HealthPlanDetector : NSObject

+ (HealthPlan)healthPlanFromLocation:(CLLocation *)location;

@end
