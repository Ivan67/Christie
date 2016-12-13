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
