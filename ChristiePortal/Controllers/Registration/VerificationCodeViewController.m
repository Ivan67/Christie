#import <AFNetworking/AFNetworking.h>
#import "AccountViewController.h"
#import "VerificationCodeViewController.h"

@interface VerificationCodeViewController ()

@property (weak, nonatomic) IBOutlet UITextField *verificationCodeField;
@property (nonatomic, copy) NSString *expectedVerificationCode;

@end

@implementation VerificationCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.verificationCodeField.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self checkInternetAccess];
    self.expectedVerificationCode = self.navigationParameters[@"code"];
}

- (IBAction)continueRegistration {
    NSString *verificationCode = self.verificationCodeField.text;
    [self.verificationCodeField resignFirstResponder];
    
    NSString *errorMessage;
    if (verificationCode.length == 0) {
        errorMessage = @"Please enter your verification code";
    }
    
    if (errorMessage.length != 0) {
        [self showErrorAlertWithMessage:errorMessage];
        return;
    }

    if ([self.verificationCodeField.text isEqualToString:self.expectedVerificationCode]) {
        [self.navigationManager navigateTo:@"/welcome/verification-code/account" withParameters:@{
            @"code": self.verificationCodeField.text
        }];
    } else {
        [self showErrorAlertWithMessage:@"The entered verification code in incorrect. Please check the spelling of your verification code and try again."];
    }
}

@end
