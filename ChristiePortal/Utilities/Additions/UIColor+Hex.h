#import <UIKit/UIKit.h>

@interface UIColor (Hex)

+ (instancetype)colorWithRGB:(NSUInteger)rgb;
+ (instancetype)colorWithRGB:(NSUInteger)rgb alpha:(CGFloat)alpha;

@end
