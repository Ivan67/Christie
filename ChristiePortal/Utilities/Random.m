#import "Random.h"

@implementation Random

+ (NSUInteger)nextIntegerWithUpperBound:(NSUInteger)upperBound {
    return arc4random_uniform((uint32_t)upperBound);
}

@end
