#import "AccountViewController.h"
#import "APIClient.h"
#import "WelcomeViewController.h"

@interface WelcomeViewController ()

@property (weak, nonatomic) IBOutlet UITextField *lastNameField;
@property (weak, nonatomic) IBOutlet UITextField *studentIDField;

@end

@implementation WelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.lastNameField.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0);
    self.studentIDField.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0);
}

- (IBAction)continueRegisration {
    NSString *lastName = self.lastNameField.text;
    [self.lastNameField resignFirstResponder];
    
    NSString *studentID = self.studentIDField.text;
    [self.studentIDField resignFirstResponder];
    
    NSString *errorMessage;
    if (lastName.length == 0) {
        errorMessage = @"Please enter your last name";
    } else if (studentID.length == 0) {
        errorMessage = @"Please enter your student ID";
    }

    if (errorMessage.length != 0) {
        [self showErrorAlertWithMessage:errorMessage];
        return;
    }
    
    NSDictionary *parameters = @{
        @"invitations": @[@{
            @"lastName": lastName,
            @"studentId": studentID
        }]
    };
    
    [[APIClient sharedClient] POST:@"invitations" parameters:parameters success:^(NSURLSessionDataTask *operation, id responseObject) {
        [self.navigationManager navigateTo:@"/welcome/verification-code" withParameters:@{
            @"code": responseObject[@"invitations"][@"code"]
        }];
    } failure:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self checkInternetAccess];
}

- (IBAction)logInInstead {
    [self.navigationManager navigateTo:@"/login"];
}

@end