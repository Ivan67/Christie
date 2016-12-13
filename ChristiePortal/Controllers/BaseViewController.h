#import <UIKit/UIKit.h>
#import "NavigationManager.h"
#import "UIViewController+AlertHelpers.h"
#import "Reachability.h"

@interface BaseViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
- (void)checkInternetAccess;

@end
