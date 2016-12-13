//
//  DentalController.m
//  ChristiePortal
//
//  Created by Rhinoda3 on 08.09.15.
//  Copyright (c) 2015 Rhinoda. All rights reserved.
//

#import "DentalViewController.h"

@implementation DentalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:@"Dental" image:@"menu_dental"];
    [self loadURLString:@"https://www1.careington.com/providers/search_providers2.aspx"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self checkInternetAccess];
}

@end