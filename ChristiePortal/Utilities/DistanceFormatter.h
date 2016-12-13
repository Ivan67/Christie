#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

/**
 * A helper class for converting distance in meters to a human readable string.
 */
@interface DistanceFormatter : NSObject

/**
 * Converts a distance expressed in meters to a human readable string in imperial units.
 *
 * @return The distance as a string.
 */
+ (NSString *)stringFromDistance:(CLLocationDistance)distanceInMeters;

@end
