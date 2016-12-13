
#import "UIView+LayoutHelpers.h"

@implementation UIView (LayoutHelpers)

-(void)sizeToFitSubviews {
    if (self.subviews.count == 0) {
        return;
    }
        
    CGFloat maxWidth = 0;
    CGFloat maxHeight = 0;
    
    for (UIView *subview in self.subviews) {
        [subview sizeToFitSubviews];
        
        CGFloat requiredWidth = subview.frame.origin.x + subview.frame.size.width;
        maxWidth = MAX(requiredWidth, maxWidth);
        
        CGFloat requiredHeight = subview.frame.origin.y + subview.frame.size.height;
        maxHeight = MAX(requiredHeight, maxHeight);
    }

    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, maxWidth, maxHeight);
}

@end
