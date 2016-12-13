//
//  VisionController.m
//  ChristiePortal
//
//  Created by Rhinoda3 on 08.09.15.
//  Copyright (c) 2015 Rhinoda. All rights reserved.
//

#import "VisionViewController.h"

@interface VisionViewController ()

@end

@implementation VisionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Vision";
    [self setTitle:@"Vision" image:@"menu_vision"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self checkInternetAccess];
}

@end
