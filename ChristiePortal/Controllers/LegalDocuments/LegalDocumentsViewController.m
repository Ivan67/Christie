//
//  HelpController.m
//  ChristiePortal
//
//  Created by Rhinoda3 on 08.09.15.
//  Copyright (c) 2015 Rhinoda. All rights reserved.
//

#import "LegalDocumentsViewController.h"

@implementation LegalDocumentsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:@"Legal documents" image:@"menu_legal"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self checkInternetAccess];
}

@end
