#import <UIKit/UIKit.h>

@interface UIViewController (AlertHelpers)

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message actions:(NSArray<UIAlertAction *> *)actions;
- (void)showErrorAlertWithMessage:(NSString *)message;

@end
