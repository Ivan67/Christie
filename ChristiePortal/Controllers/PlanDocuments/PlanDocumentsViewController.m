#import "PlanDocumentsViewController.h"

@implementation PlanDocumentsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:@"Plan Documents" image:@"menu_plan"];
    [self loadURLString:@"http://www.christiestudenthealth.com/tools-resources/#forms-brochures"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self checkInternetAccess];
}

@end
