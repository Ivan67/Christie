//
//  Random2.m
//  ChristiePortal
//
//  Created by Sergey on 19/11/15.
//  Copyright © 2015 Rhinoda. All rights reserved.
//

#import "Random.h"

@implementation Random

+ (NSUInteger)nextIntegerWithUpperBound:(NSUInteger)upperBound {
    return arc4random_uniform((uint32_t)upperBound);
}

@end
