#import <UIKit/UIKit.h>

@interface MenuOverlayView : UIView

@property (nonatomic, readonly, getter=isToggled) BOOL toggled;

- (void)toggleAnimated:(BOOL)animated;

@end
