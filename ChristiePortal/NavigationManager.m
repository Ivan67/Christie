#import <objc/runtime.h>
#import "NavigationManager.h"

static void *NavigationManagerPropertyKey = &NavigationManagerPropertyKey;
static void *NavigationParmaetersPropertyKey = &NavigationParmaetersPropertyKey;

static NavigationManager *getViewControllerNavigationManager(UIViewController *viewController) {
    return objc_getAssociatedObject(viewController, NavigationManagerPropertyKey);
}

static void setViewControllerNavigationManager(UIViewController *viewController, NavigationManager *navigationManager) {
    objc_setAssociatedObject(viewController, NavigationManagerPropertyKey, navigationManager, OBJC_ASSOCIATION_ASSIGN);
}

static NSDictionary *getViewControllerNavigationParameters(UIViewController *viewController) {
    return objc_getAssociatedObject(viewController, NavigationParmaetersPropertyKey);
}

static void setViewControllerNavigationParameters(UIViewController *viewController, NSDictionary *navigationParameters) {
    objc_setAssociatedObject(viewController, NavigationParmaetersPropertyKey, navigationParameters, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@interface NavigationManager ()

@property (nonatomic, readonly) NSMutableDictionary<NSString *, UIViewController *> *viewControllers;
@property (nonatomic, readonly) NSMutableDictionary<NSString *, NavigationManagerViewControlerBlock> *viewControllerBlocks;

@end

@implementation NavigationManager

- (instancetype)initWithNavigationController:(UINavigationController *)navigationController {
    if (self = [super init]) {
        _navigationController = navigationController;
        _viewControllers = [NSMutableDictionary dictionary];
        _viewControllerBlocks = [NSMutableDictionary dictionary];
    }
    return self;
}

- (instancetype)initWithNavigationController:(UINavigationController *)navigationController
                     parentNavigationManager:(NavigationManager *)parentNavigationManager{
    if (self = [self initWithNavigationController:navigationController]) {
        _parentNavigationManager = parentNavigationManager;
    }
    return self;
}

- (void)registerPath:(NSString *)path forViewController:(UIViewController *)viewController {
    self.viewControllers[path] = viewController;
}

- (void)registerPath:(NSString *)path forBlock:(NavigationManagerViewControlerBlock)block {
    self.viewControllerBlocks[path] = block;
}

- (id)viewControllerForPath:(NSString *)path {
    id viewController = self.viewControllers[path];
    if (viewController == nil) {
        NavigationManagerViewControlerBlock block = self.viewControllerBlocks[path];
        if (block != nil) {
            viewController = block();
        }
    }
    return viewController;
}

- (void)navigateTo:(NSString *)path {
    [self navigateTo:path withParameters:nil];
}

+ (NSMutableArray<NSString *> *)componentsFromPath:(NSString *)path {
    NSMutableArray<NSString *> *components = [NSMutableArray arrayWithArray:[path componentsSeparatedByString:@"/"]];
    if (components.count > 0) {
        [components removeObjectAtIndex:0];
    }
    return components;
}

- (void)navigateTo:(NSString *)path withParameters:(NSDictionary *)parameters {
    NSMutableString *currentPath = [NSMutableString stringWithString:@""];
    NSMutableArray<UIViewController *> *viewControllers = [[NSMutableArray alloc] init];
    
    for (NSString *component in [NavigationManager componentsFromPath:path]) {
        [currentPath appendFormat:@"/%@", component];
        
        id viewController = [self viewControllerForPath:currentPath];
        if (viewController == nil) {
            NSLog(@"NavigationManager: Could not find route for %@", currentPath);
            break;
        }
        
        setViewControllerNavigationManager(viewController, self);
        setViewControllerNavigationParameters(viewController, parameters);

        [viewControllers addObject:viewController];
    }

    [self.navigationController setViewControllers:viewControllers animated:YES];
}

@end

@implementation UIViewController (NavigationManager)

- (NavigationManager *)navigationManager {
    return getViewControllerNavigationManager(self);
}

- (NSDictionary *)navigationParameters {
    return getViewControllerNavigationParameters(self);
}

- (void)setNavigationParameters:(NSDictionary *)navigationParameters {
    setViewControllerNavigationParameters(self, navigationParameters);
}

@end
