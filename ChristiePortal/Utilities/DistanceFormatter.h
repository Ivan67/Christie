//
//  DistanceFormatter.h
//  ChristiePortal
//
//  Created by Sergey on 10/8/15.
//  Copyright © 2015 Rhinoda. All rights reserved.
//

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
