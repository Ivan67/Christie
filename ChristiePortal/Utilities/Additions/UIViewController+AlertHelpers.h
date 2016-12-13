//
//  UIViewController+AlertHelpers.h
//  ChristiePortal
//
//  Created by Sergey on 01/12/15.
//  Copyright © 2015 Rhinoda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (AlertHelpers)

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message actions:(NSArray<UIAlertAction *> *)actions;
- (void)showErrorAlertWithMessage:(NSString *)message;

@end
