//
//  UIColor+Hex.m
//  ChristiePortal
//
//  Created by Sergey on 10/19/15.
//  Copyright © 2015 Rhinoda. All rights reserved.
//

#import "UIColor+Hex.h"

@implementation UIColor (Hex)

+ (instancetype)colorWithRGB:(NSUInteger)rgb {
    return [UIColor colorWithRed:((rgb & 0xFF0000) >> 16) / 255.0
                           green:((rgb & 0x00FF00) >> 8) / 255.0
                            blue:(rgb & 0x0000FF) / 255.0
                           alpha:1];
    
}

+ (instancetype)colorWithRGB:(NSUInteger)rgb alpha:(CGFloat)alpha {
    return [UIColor colorWithRed:((rgb & 0xFF0000) >> 16) / 255.0
                           green:((rgb & 0x00FF00) >> 8) / 255.0
                            blue:(rgb & 0x0000FF) / 255.0
                           alpha:alpha];
}

@end
