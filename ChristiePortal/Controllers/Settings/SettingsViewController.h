#import "FrontViewController.h"

@class AuthenticationManager;
@class SettingsManager;

@interface SettingsViewController : FrontViewController

@property (nonatomic, readonly) SettingsManager *settingsManager;
@property (nonatomic, readonly) AuthenticationManager *authenticationManager;

- (instancetype)initWithSettingsManager:(SettingsManager *)settingsManager
                  authenticationManager:(AuthenticationManager *)authenticationManager;

@end

