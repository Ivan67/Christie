//
//  LoadingViewController.m
//  ChristiePortal
//
//  Created by Sergey on 23/10/15.
//  Copyright © 2015 Rhinoda. All rights reserved.
//

#import "LoadingViewController.h"

@interface LoadingViewController ()

@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

@end

@implementation LoadingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.progressView.progress = 0;
}

- (float)progress {
    return self.progressView.progress;
}

- (void)setProgress:(float)progress {
    [self.progressView setProgress:progress animated:YES];
}

@end
