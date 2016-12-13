#import <UIKit/UIKit.h>

@class NavigationManager;

@interface MenuViewController : UIViewController

@property (nonatomic, readonly) NavigationManager *navigationManager;

- (instancetype)initWithNavigationManager:(NavigationManager *)navigationManager;

@end
