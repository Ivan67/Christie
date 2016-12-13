#import <UIKit/UIKit.h>

typedef UIViewController *(^NavigationManagerViewControlerBlock)();

@interface NavigationManager : NSObject

@property (nonatomic, readonly) UINavigationController *navigationController;
@property (nonatomic, readonly) NavigationManager *parentNavigationManager;

- (instancetype)initWithNavigationController:(UINavigationController *)navigationController;
- (instancetype)initWithNavigationController:(UINavigationController *)navigationController parentNavigationManager:(NavigationManager *)parentNavigationManager;

- (void)registerPath:(NSString *)path forViewController:(UIViewController *)viewController;
- (void)registerPath:(NSString *)path forBlock:(NavigationManagerViewControlerBlock)block;

- (id)viewControllerForPath:(NSString *)path;

- (void)navigateTo:(NSString *)path;
- (void)navigateTo:(NSString *)path withParameters:(NSDictionary *)parameters;

@end

@interface UIViewController (NavigationManager)

@property (nonatomic, readonly) NavigationManager *navigationManager;
@property (nonatomic) NSDictionary *navigationParameters;

@end
