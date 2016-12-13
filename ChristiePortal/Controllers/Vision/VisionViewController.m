#import "VisionViewController.h"

@interface VisionViewController ()

@end

@implementation VisionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Vision";
    [self setTitle:@"Vision" image:@"menu_vision"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self checkInternetAccess];
}

@end
