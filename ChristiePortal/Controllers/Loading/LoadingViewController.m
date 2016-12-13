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
