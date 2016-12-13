//
//  UIColor+Hex.h
//  ChristiePortal
//
//  Created by Sergey on 10/19/15.
//  Copyright © 2015 Rhinoda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Hex)

+ (instancetype)colorWithRGB:(NSUInteger)rgb;
+ (instancetype)colorWithRGB:(NSUInteger)rgb alpha:(CGFloat)alpha;

@end
