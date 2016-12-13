//
//  UIViewController+AlertHelpers.m
//  ChristiePortal
//
//  Created by Sergey on 01/12/15.
//  Copyright © 2015 Rhinoda. All rights reserved.
//

#import "UIViewController+AlertHelpers.h"

@implementation UIViewController (AlertHelpers)

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message actions:(NSArray<UIAlertAction *> *)actions {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    for (UIAlertAction *action in actions) {
        [alertController addAction:action];
    }
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)showErrorAlertWithMessage:(NSString *)message {
    [self showAlertWithTitle:@"Error" message:message actions:@[
        [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]
    ]];
}

@end
