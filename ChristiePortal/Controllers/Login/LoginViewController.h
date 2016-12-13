#import "BaseViewController.h"

@class AuthenticationManager;
@class SettingsManager;

@interface LoginViewController : BaseViewController <UITextFieldDelegate>

@property (nonatomic, readonly) SettingsManager *settingsManager;
@property (nonatomic, readonly) AuthenticationManager *authenticationManager;

- (instancetype)initWithSettingsManager:(SettingsManager *)settingsManager
                  authenticationManager:(AuthenticationManager *)authenticationManager;

@end

