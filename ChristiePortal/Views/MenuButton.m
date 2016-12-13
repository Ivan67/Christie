#import "MenuButton.h"

@implementation MenuButton

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        for (NSUInteger i = 0; i < 3; i++) {
            CGRect barFrame = CGRectMake(0,
                                         frame.size.height * 2 / 5 * i,
                                         frame.size.width,
                                         frame.size.height / 5);
            UIView *barView = [[UIView alloc] initWithFrame:barFrame];
            barView.backgroundColor = [UIColor whiteColor];
            barView.layer.cornerRadius = 2;
            [self addSubview:barView];
        }
    }
    return self;
}

- (void)transitionToCloseStateWithDuration:(NSTimeInterval)duration {
    NSArray<UIView *> *bars = self.subviews;
    for (UIView *barView in bars) {
        barView.transform = CGAffineTransformIdentity;
    }
    
    [UIView animateKeyframesWithDuration:duration delay:0 options:0 animations:^{
        [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:0.5 animations:^{
            bars[0].transform = CGAffineTransformTranslate(bars[0].transform, 0, bars[0].frame.size.height * 2);
            bars[2].transform = CGAffineTransformTranslate(bars[2].transform, 0, -bars[2].frame.size.height * 2);
        }];
        [UIView addKeyframeWithRelativeStartTime:0.5 relativeDuration:0 animations:^{
            bars[1].alpha = 0;
        }];
        [UIView addKeyframeWithRelativeStartTime:0.5 relativeDuration:0.5 animations:^{
            bars[0].transform = CGAffineTransformScale(CGAffineTransformRotate(bars[0].transform, M_PI_4), 1.2, 1);
            bars[2].transform = CGAffineTransformScale(CGAffineTransformRotate(bars[2].transform, -M_PI_4), 1.2, 1);
        }];
    } completion:^(BOOL finished) {
        self->_toggled = YES;
    }];
}

- (void)transitionToNormalStateWithDuration:(NSTimeInterval)duration {
    [UIView animateKeyframesWithDuration:duration delay:0 options:0 animations:^{
        NSArray<UIView *> *bars = self.subviews;
        [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:0.5 animations:^{
            bars[0].transform = CGAffineTransformRotate(CGAffineTransformScale(bars[0].transform, 1 / 1.2, 1), -M_PI_4);
            bars[2].transform = CGAffineTransformRotate(CGAffineTransformScale(bars[2].transform, 1 / 1.2, 1), M_PI_4);
        }];
        [UIView addKeyframeWithRelativeStartTime:0.5 relativeDuration:0 animations:^{
            bars[1].alpha = 1;
        }];
        [UIView addKeyframeWithRelativeStartTime:0.5 relativeDuration:0.5 animations:^{
            bars[0].transform = CGAffineTransformTranslate(bars[0].transform, 0, -bars[0].frame.size.height * 2);
            bars[2].transform = CGAffineTransformTranslate(bars[2].transform, 0, bars[2].frame.size.height * 2);
        }];
    } completion:^(BOOL finished) {
        self->_toggled = NO;
    }];
}

- (void)toggleAnimated:(BOOL)animated {
    NSTimeInterval duration = 0;
    if (animated) {
        duration = [CATransaction animationDuration];
    }
   
    _toggled = !_toggled;
    
    if (self.toggled) {
        [self transitionToCloseStateWithDuration:duration];
    } else {
        [self transitionToNormalStateWithDuration:duration];
    }
}

@end
