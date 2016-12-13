#import "FrontViewController.h"

@class WebViewController;

@protocol WebViewControllerDelegate <NSObject>

@optional
- (void)webViewControllerDidStartLoad:(WebViewController *)webViewController;
- (void)webViewControllerDidFinishLoad:(WebViewController *)webViewController;

@end

@interface WebViewController : FrontViewController <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) id<WebViewControllerDelegate> delegate;

- (void)loadURLString:(NSString *)URLString;

@end
