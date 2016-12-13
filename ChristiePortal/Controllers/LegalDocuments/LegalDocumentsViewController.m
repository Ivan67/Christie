#import "LegalDocumentsViewController.h"

@implementation LegalDocumentsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:@"Legal documents" image:@"menu_legal"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self checkInternetAccess];
}

@end
