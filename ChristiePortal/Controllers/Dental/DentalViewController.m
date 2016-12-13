#import "DentalViewController.h"

@implementation DentalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:@"Dental" image:@"menu_dental"];
    [self loadURLString:@"https://www1.careington.com/providers/search_providers2.aspx"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self checkInternetAccess];
}

@end
