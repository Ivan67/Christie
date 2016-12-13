#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "FrontViewController.h"

@interface MyChristieViewController : FrontViewController <MFMailComposeViewControllerDelegate,MFMessageComposeViewControllerDelegate, UIPrintInteractionControllerDelegate>

@end
