//
//  NavigationController.m
//  ChristiePortal
//
//  Created by Sergey on 19/01/16.
//  Copyright © 2016 Rhinoda. All rights reserved.
//

#import "NavigationController.h"
#import "UIColor+Hex.h"

@implementation NavigationController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.hidesStatusBar = NO;
        self.statusBarStyle = UIStatusBarStyleLightContent;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.hidesBarsOnSwipe = NO;
    self.interactivePopGestureRecognizer.enabled = NO;
    self.navigationBar.barTintColor = [UIColor colorWithRGB:0x418FDE alpha:0.9];
    self.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    [self.navigationItem.backBarButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]} forState:UIControlStateNormal];
}

- (BOOL)prefersStatusBarHidden {
    return self.hidesStatusBar;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.statusBarStyle;
}

@end
