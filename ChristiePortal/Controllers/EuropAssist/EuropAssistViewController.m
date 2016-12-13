#import "EuropAssistViewController.h"

@implementation EuropAssistViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setTitle:@"Europ Assist" image:@"menu_ea"];
    [self loadURLString:@"http://www.europ-assistance.com/en"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self checkInternetAccess];
}

@end
