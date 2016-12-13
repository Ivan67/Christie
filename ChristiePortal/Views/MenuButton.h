#import <UIKit/UIKit.h>

@interface MenuButton : UIButton

@property (nonatomic, readonly, getter=isToggled) BOOL toggled;

- (void)toggleAnimated:(BOOL)animated;

@end
