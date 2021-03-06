#import "DistanceFormatter.h"

@implementation DistanceFormatter

+ (NSString *)stringFromDistance:(CLLocationDistance)distanceInMeters {
    static const double MetersPerMile = 1609.34;
    
    double distanceInMiles = distanceInMeters / MetersPerMile;
    if (distanceInMiles >= 100) {
        return [NSString stringWithFormat:@"%.0f mi", distanceInMiles];
    } else {
        return [NSString stringWithFormat:@"%.1f mi", distanceInMiles];
    }
}

@end
