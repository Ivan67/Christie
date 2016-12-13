#import <LocalAuthentication/LocalAuthentication.h>
#import <TPKeyboardAvoidingScrollView.h>
#import <SSKeychain.h>
#import "APIClient.h"
#import "AuthenticationManager.h"
#import "Constants.h"
#import "SettingsManager.h"
#import "SettingsViewController.h"
#import "User.h"

@interface SettingsViewController ()

@property (weak, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UISwitch *notifySwitch;
@property (weak, nonatomic) IBOutlet UISwitch *useTouchIDSwitch;
@property (weak, nonatomic) IBOutlet UITextField *currentPasswordField;
@property (weak, nonatomic) IBOutlet UITextField *theNewPasswordField;
@property (weak, nonatomic) IBOutlet UITextField *repeatNewPasswordField;
@property (weak, nonatomic) IBOutlet UILabel *loggedInAsLabel;

- (IBAction)changePassword;
- (IBAction)saveNotifySwitch;
- (IBAction)saveUseTouchIDSwitch;
- (IBAction)confirmLogOut;

@end

@implementation SettingsViewController

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
    
    [self setTitle:@"Settings" image:@"menu_settings"];
    self.scrollView.contentSize = self.contentView.frame.size;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self checkInternetAccess];
    User *user = [User sharedUser];
    self.loggedInAsLabel.text = [NSString stringWithFormat:@"Logged in as %@", user.username];
    
    self.notifySwitch.on = self.settingsManager.notifyAboutNearbyPharmacies;
    self.useTouchIDSwitch.on = self.settingsManager.useTouchID;
}

- (IBAction)changePassword {
    NSString *currentPassword = self.currentPasswordField.text;
    [self.currentPasswordField resignFirstResponder];
    
    NSString *newPassword = self.theNewPasswordField.text;
    [self.theNewPasswordField resignFirstResponder];
    
    NSString *repeatNewPassword = self.repeatNewPasswordField.text;
    [self.repeatNewPasswordField resignFirstResponder];
    
    NSString *storedPassword = [SSKeychain passwordForService:KeychainServiceName account:[User sharedUser].username];
    
    NSString *errorMessage = nil;
    if (currentPassword.length == 0) {
        errorMessage = @"Please enter your current password";
    } else if (![currentPassword isEqualToString:storedPassword]) {
        errorMessage = @"Invalid password";
    } else if (newPassword.length == 0) {
        errorMessage = @"Please enter your new password";
    } else if (![newPassword isEqualToString:repeatNewPassword]) {
        errorMessage = @"Passwords do not match";
    }

    if (errorMessage != nil) {
        [self showErrorAlertWithMessage:errorMessage];
        return;
    }
    
    NSString *url = [NSString stringWithFormat:@"users/%ld", (long)[User sharedUser].id];
    NSDictionary *parameters = @{
        @"users": @[@{
            @"id": @([User sharedUser].id),
            @"username": [User sharedUser].username,
            @"plainPassword": newPassword
        }]
    };
    
    [[APIClient sharedClient] PUT:url parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        self.currentPasswordField.text = nil;
        self.theNewPasswordField.text = nil;
        self.repeatNewPasswordField.text = nil;
        
        NSError *error;
        if (![SSKeychain setPassword:newPassword forService:KeychainServiceName account:[User sharedUser].username error:&error]) {
            NSLog(@"Failed to save new password into the keychain: %@", error);
        }
        
        [self showAlertWithTitle:@"Password changed" message:@"Your password has been successfully changed" actions:@[
            [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]
        ]];
    } failure:nil];
}

- (IBAction)saveNotifySwitch {
    self.settingsManager.notifyAboutNearbyPharmacies = self.notifySwitch.on;
}

- (IBAction)saveUseTouchIDSwitch {
    if (!self.useTouchIDSwitch.on) {
        self.settingsManager.useTouchID = NO;
        return;
    }

    [self.authenticationManager authenticateWithPolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics reason:@"Confirm your identity" copletion:^(BOOL success, NSError *error) {
        self.settingsManager.useTouchID = success;
        self.useTouchIDSwitch.on = success;
    } failure:^(NSError *error) {
        self.useTouchIDSwitch.on = NO;
        [self showErrorAlertWithMessage:@"Your device either does not support Touch ID or Touch ID has not been configured. To set up Touch ID go to Settings > Touch ID & Passcode and add one or more fingerprints."];
    }];
}

- (IBAction)confirmLogOut {
    [self showAlertWithTitle:@"Log out" message:@"Are you sure you want to log out?" actions:@[
        [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:nil],
        [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self logOut];
            [self.navigationManager.parentNavigationManager navigateTo:@"/login"];
        }]
    ]];
}

- (void)logOut {
    User *user = [User sharedUser];
    user.username = nil;
    user.loggedIn = NO;
    
    self.settingsManager.username = nil;
    self.settingsManager.useTouchID = NO;
    
    NSLog(@"User logged out");
}

@end
