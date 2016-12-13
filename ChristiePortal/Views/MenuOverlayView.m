#import "MenuOverlayView.h"
#import "UIColor+Hex.h"

@implementation MenuOverlayView

- (instancetype)init {
    if (self = [super init]) {
        [self setUp];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setUp];
    }
    return self;
}

- (void)setUp {
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth
                          | UIViewAutoresizingFlexibleHeight
                          | UIViewAutoresizingFlexibleTopMargin
                          | UIViewAutoresizingFlexibleBottomMargin
                          | UIViewAutoresizingFlexibleLeftMargin
                          | UIViewAutoresizingFlexibleRightMargin;
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.backgroundColor = [UIColor colorWithRGB:0 alpha:0.5];
    self.alpha = 0;
}

- (void)toggleAnimated:(BOOL)animated {
    NSTimeInterval duration = 0;
    if (animated) {
        duration = [CATransaction animationDuration];
    }
    
    _toggled = !_toggled;
    
    [UIView animateWithDuration:duration animations:^{
        self.alpha = self.toggled ? 1 : 0;
    }];
}

@end
