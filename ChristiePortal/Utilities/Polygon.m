//
//  Polygon.m
//  ChristiePortal
//
//  Created by Sergey on 28/10/15.
//  Copyright © 2015 Rhinoda. All rights reserved.
//

#import "Polygon.h"

@interface Polygon ()

@property (nonatomic) CGPathRef path;

@end

@implementation Polygon

+ (instancetype)polygonWithPoints:(const CGPoint *)points count:(NSUInteger)count {
    return [[self alloc] initWithPoints:points count:count];
}

- (instancetype)initWithPoints:(const CGPoint *)points count:(NSUInteger)count {
    if (self = [super init]) {
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path, NULL, points[0].x, points[0].y);
        for (NSUInteger i = 1; i < count; i++) {
            CGPathAddLineToPoint(path, NULL, points[i].x, points[i].y);
        }
        _path = path;
    }
    return self;
}

- (void)dealloc {
    CGPathRelease(_path);
}

- (BOOL)containsPoint:(CGPoint)point {
    return CGPathContainsPoint(self.path, NULL, point, YES);
}

@end
