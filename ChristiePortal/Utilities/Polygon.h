//
//  Polygon.h
//  ChristiePortal
//
//  Created by Sergey on 28/10/15.
//  Copyright © 2015 Rhinoda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CoreLocation/CoreLocation.h>

@interface Polygon : NSObject

/**
 * Creates a polygon with an array of points
 *
 * @return The new polygon.
 */
+ (instancetype)polygonWithPoints:(const CGPoint *)points count:(NSUInteger)count;

/**
 * Initializes a polygon with an array of points.
 *
 * @return A polygon with the specified vertices.
 */
- (instancetype)initWithPoints:(const CGPoint *)points count:(NSUInteger)count;

/**
 * Checks if a point lies within the polygon's bounds.
 *
 * @return \c YES if the point is within the polygon, otherwise \c NO.
 */
- (BOOL)containsPoint:(CGPoint)point;

@end
