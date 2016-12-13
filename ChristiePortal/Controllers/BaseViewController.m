#import <AFNetworking.h>
#import "BaseViewController.h"
#import "NSError+APIClient.h"

@interface BaseViewController () {
    Reachability *internetReachable;
    Reachability *hostReachable;

    NSInteger statusNet;
}

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.activityIndicator.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self
                           selector:@selector(networkTaskDidStart)
                               name:AFNetworkingTaskDidResumeNotification
                             object:nil];
    [notificationCenter addObserver:self
                           selector:@selector(networkTaskDidFinish:)
                               name:AFNetworkingTaskDidCompleteNotification
                             object:nil];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self
                                  name:AFNetworkingTaskDidResumeNotification
                                object:nil];
    [notificationCenter removeObserver:self
                                  name:AFNetworkingTaskDidCompleteNotification
                                object:nil];
}

- (void)networkTaskDidStart {
    [self.activityIndicator startAnimating];
}

- (void)networkTaskDidFinish:(NSNotification *)notification {
    [self.activityIndicator stopAnimating];
    
    NSError *error = notification.userInfo[AFNetworkingTaskDidCompleteErrorKey];
    if (error != nil) {
        [self showErrorAlertWithMessage:error.remoteDescription];
    }
}

- (void)checkInternetAccess {
    
    internetReachable = [Reachability reachabilityForInternetConnection];

    [self checkNetworkStatus];
    
    NSString *errorMessage = nil;
    
    if (statusNet == 1) {
        errorMessage = @"No internet connection";
    }
    if (errorMessage != nil) {
        [self showErrorAlertWithMessage:errorMessage];
        return;
    }

}

- (void)checkNetworkStatus {
    
    NetworkStatus internetStatus = [internetReachable currentReachabilityStatus];
    switch (internetStatus)
    {
        case NotReachable:
        {
            statusNet = 1;
            break;
        }
        case ReachableViaWiFi:
        {
            statusNet = 2;
            break;
        }
        case ReachableViaWWAN:
        {
            statusNet = 3;
            break;
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

@end
