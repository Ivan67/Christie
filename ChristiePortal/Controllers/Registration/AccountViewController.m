#import <LocalAuthentication/LocalAuthentication.h>
#import "AccountViewController.h"
#import "APIClient.h"

@interface AccountViewController ()

@property (weak, nonatomic) IBOutlet UITextField *userIDField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordField;

@property (nonatomic, copy) NSString *verificationCode;

@end

@implementation AccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.userIDField.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0);
    self.passwordField.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0);
    self.confirmPasswordField.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self checkInternetAccess];
    self.verificationCode = self.navigationParameters[@"code"];
}

- (IBAction)continueRegistration {
    NSString *username = self.userIDField.text;
    [self.userIDField resignFirstResponder];
    
    NSString *password = self.passwordField.text;
    [self.passwordField resignFirstResponder];
    
    NSString *confirmPassword = self.confirmPasswordField.text;
    [self.confirmPasswordField resignFirstResponder];
    
    NSString *errorMessage;
    if (username.length == 0 && password.length == 0 && confirmPassword.length == 0) {
        errorMessage = @"Please enter your username and password";
    } else if (username.length == 0 && password.length == 0) {
        errorMessage = @"Please enter your username and password";
    } else if (username.length == 0) {
        errorMessage = @"Please enter your username";
    } else if (password.length == 0) {
        errorMessage = @"Please enter your password";
    } else if (confirmPassword.length == 0){
        errorMessage = @"Please confirm your password";
    } else if (![password isEqual:confirmPassword]){
        errorMessage = @"Passwords do not match";
    }
    
    if (errorMessage.length != 0) {
        [self showErrorAlertWithMessage:errorMessage];
        return;
    }

    NSDictionary *parameters = @{
        @"users" : @{
            @"username" : username,
            @"plainPassword" : password,
            @"confirmPassword": confirmPassword,
            @"invitationCode" : self.verificationCode
        },
    };

    [[APIClient sharedClient] POST:@"users" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        [[APIClient sharedClient].requestSerializer setAuthorizationHeaderFieldWithUsername:username password:password];
        [self.navigationManager navigateTo:@"/welcome/verification-code/account/security-questions" withParameters:@{
            @"userID": responseObject[@"users"][@"id"]
        }];
    } failure:nil];
}

@end
