#import "WebViewController.h"

@interface WebViewController () {
    BOOL theBool;
    NSTimer *myTimer;
}

@property (nonatomic) UIButton *backButton;

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.webView.scrollView.bounces = NO;
    self.webView.delegate = self;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGSize backButtonSize = CGSizeMake(55, 55);
    CGRect backButtonFrame = CGRectMake(
        CGRectGetMaxX(self.view.frame) - backButtonSize.width,
        CGRectGetMaxY(self.view.frame) - backButtonSize.height,
        backButtonSize.width,
        backButtonSize.height);
    self.backButton = [[UIButton alloc] initWithFrame:backButtonFrame];
    self.backButton.alpha = 0;
    [self.backButton setImage:[UIImage imageNamed:@"web_back_button"] forState:UIControlStateNormal];
    [self.backButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.backButton];
}

- (void)loadURLString:(NSString *)URLString {
    [self.activityIndicator startAnimating];
    
    NSURL *URL = [NSURL URLWithString:URLString];
    NSURLRequest *URLRequest = [NSURLRequest requestWithURL:URL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
    [self.webView loadRequest:URLRequest];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if (error.code != NSURLErrorCancelled) {
        [self.activityIndicator stopAnimating];
        [self showErrorAlertWithMessage:[NSString stringWithFormat:@"Failed to laod the web page: %@", error.localizedDescription]];
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    id<WebViewControllerDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(webViewControllerDidStartLoad:)]) {
        [delegate webViewControllerDidStartLoad:self];
    }
    
    [self.activityIndicator startAnimating];
    [self updateBackButtonVisibility];
    
    self.progressView.progress = 0;
    theBool = false;
    myTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timerCallback) userInfo:nil repeats:YES];
}

-(void)timerCallback {
    if (theBool) {
        if (self.progressView.progress >= 1) {
            self.progressView.hidden = true;
            [myTimer invalidate];
        }
        else {
            self.progressView.progress += 0.1;
        }
    }
    else {
        self.progressView.progress += 0.05;
        if (self.progressView.progress >= 0.95) {
            self.progressView.progress = 0.95;
        }
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    id<WebViewControllerDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(webViewControllerDidFinishLoad:)]) {
        [delegate webViewControllerDidFinishLoad:self];
    }
    
    [self updateBackButtonVisibility];
    
    if (!webView.isLoading) {
        [self.activityIndicator stopAnimating];
        self.progressView.progress = 1.0;
    }
    theBool = true;
}

- (void)goBack {
    [self.webView goBack];
}

- (void)updateBackButtonVisibility {
    [UIView animateWithDuration:[CATransaction animationDuration] animations:^{
        self.backButton.alpha = [self.webView canGoBack] ? 1 : 0;
    }];
}

@end
