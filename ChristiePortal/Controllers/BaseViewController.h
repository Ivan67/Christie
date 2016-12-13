//
//  BaseViewController.h
//  ChristiePortal
//
//  Created by Sergey on 19/10/15.
//  Copyright © 2015 Rhinoda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NavigationManager.h"
#import "UIViewController+AlertHelpers.h"
#import "Reachability.h"

@interface BaseViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
- (void)checkInternetAccess;

@end
