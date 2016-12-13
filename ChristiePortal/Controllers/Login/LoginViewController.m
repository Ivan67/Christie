#import <LocalAuthentication/LocalAuthentication.h>
#import <SSKeychain.h>
#import "APIClient.h"
#import "AuthenticationManager.h"
#import "Constants.h"
#import "Environment.h"
#import "LoginViewController.h"
#import "SettingsManager.h"
#import "User.h"

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *userIDField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIView *useTouchIDView;
@property (weak, nonatomic) IBOutlet UIButton *useTouchIDButton;

- (IBAction)logInWithPassword;
- (IBAction)logInWithTouchID;
- (IBAction)resetPassword;

@end

@implementation LoginViewController

- (instancetype)initWithSettingsManager:(SettingsManager *)settingsManager
                  authenticationManager:(AuthenticationManager *)authenticationManager {
    if (self = [super initWithNibName:nil bundle:nil]) {
        _settingsManager = settingsManager;
        _authenticationManager = authenticationManager;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.userIDField.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0);
    self.passwordField.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self checkInternetAccess];
  
#ifdef DEBUG
    if (![Environment isRunningTests]) {
        static NSString *const FakeUserUsername = @"user";
        static NSString *const FakeUserPassword = @"user";
        
        if ([Environment isAutoLoginEnabled]) {
            self.userIDField.text = FakeUserUsername;
            self.passwordField.text = FakeUserPassword;
            [self logInWithPassword];
            return;
        }

        if ([Environment isFakeUserLoginEnabled]) {
            const NSDictionary *FakeUserResponse = @{
                @"users": @{
                    @"id": @123
                },
                @"linked": @{
                    @"entities": @[@{
                        @"first-name": @"FirstName",
                        @"last-name": @"LastName",
                        @"old-id": @"OLDID123",
                        @"phone": @"+1234567890",
                        @"email": @"user@example.com",
                        @"physical-country": @"Physical Country",
                        @"physical-address1": @"Physical Address 1",
                        @"physical-address2": @"Physical Address 2",
                    }],
                    @"members": @[@{
                        @"student-id": @456,
                        @"birth-date": @"2016-01-01T12:30:40+06:00"
                    }]
                }
            };
            [self completeLoginWithUsername:FakeUserUsername password:FakeUserPassword response:FakeUserResponse];
            return;
        }
    }
#endif
    
    if (self.settingsManager.useTouchID) {
        self.useTouchIDView.alpha = 1;
        self.useTouchIDButton.enabled = YES;
        [self logInWithTouchID];
    } else {
        self.useTouchIDView.alpha = 0.5;
        self.useTouchIDButton.enabled = NO;
    }
}

- (IBAction)logInWithPassword {
    __block NSString *username = self.userIDField.text;
    [self.userIDField resignFirstResponder];
    
    __block NSString *password = self.passwordField.text;
    [self.passwordField resignFirstResponder];
    
    NSString *errorMessage = nil;
    if (username.length == 0) {
        errorMessage = @"Please enter your user ID";
    } else if (password.length == 0) {
        errorMessage = @"Please enter your password";
    }
    
    if (errorMessage != nil) {
        [self showErrorAlertWithMessage:errorMessage];
        return;
    }
    
    APIClient *API = [APIClient sharedClient];
    [API.requestSerializer setAuthorizationHeaderFieldWithUsername:username password:password];
    
    NSDictionary *parameters = @{
        @"username": username,
        @"password": password,
        @"include": @"member.entity"
    };
    
    [API GET:@"users" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        [self completeLoginWithUsername:(NSString *)username password:password response:(id)responseObject];
    } failure:nil];
}

- (IBAction)logInWithTouchID {
    [self.authenticationManager authenticateWithPolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics reason:@"Log into your account" copletion:^(BOOL success, NSError *error) {
        if (success) {
            self.userIDField.text = self.settingsManager.username;
            self.passwordField.text = [SSKeychain passwordForService:KeychainServiceName account:self.userIDField.text];
            [self logInWithPassword];
        }
    } failure:^(NSError *error) {
        [self showErrorAlertWithMessage:@"Your device either does not support Touch ID or Touch ID has not been configured. To set up Touch ID go to Settings > Touch ID & Passcode and add one or more fingerprints."];
    }];
}

- (IBAction)resetPassword {
    // TODO
}

- (void)completeLoginWithUsername:(NSString *)username password:(NSString *)password response:(id)responseObject {
    User *user = [User sharedUser];
    user.loggedIn = YES;
    user.username = username;
    user.id = [responseObject[@"users"][@"id"] integerValue];
    
    NSDictionary *entity = [responseObject[@"linked"][@"entities"] firstObject];
    user.firstName = entity[@"first-name"];
    user.lastName = entity[@"last-name"];
    user.oldMemberID = entity[@"old-id"];
    user.phone = entity[@"phone"];
    user.email = entity[@"email"];
    user.country = entity[@"physical-country"];
    user.address1 = entity[@"physical-address1"];
    user.address2 = entity[@"physical-address2"];

    NSDictionary *member = [responseObject[@"linked"][@"members"] firstObject];
    user.studentID = [member[@"student-id"] integerValue];
    
    NSDateFormatter *birthDateFormatter = [[NSDateFormatter alloc] init];
    birthDateFormatter.dateFormat = @"yyyy-MM-dd'T'hh:mm:ssZZZZZ";
    user.birthDate = [birthDateFormatter dateFromString:member[@"birth-date"]];
    
    self.settingsManager.username = username;
    NSError *error;
    if (![SSKeychain setPassword:password forService:KeychainServiceName account:username error:&error]) {
        NSLog(@"Failed to save password into the keychain: %@", error);
    }
    
    self.userIDField.text = nil;
    self.passwordField.text = nil;
    
    [self.navigationManager navigateTo:@"/start"];
}

@end
