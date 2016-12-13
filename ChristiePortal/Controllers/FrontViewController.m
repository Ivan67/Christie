#import <SWRevealViewController.h>
#import "Constants.h"
#import "FrontViewController.h"
#import "MenuButton.h"
#import "MenuOverlayView.h"
#import "Random.h"

@interface FrontViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

@property (nonatomic) MenuButton *menuButton;
@property (nonatomic) MenuOverlayView *menuOverlayView;

@end

@implementation FrontViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter addObserver:self selector:@selector(menuWillToggle) name:MenuWillOpenNotification object:nil];
        [notificationCenter addObserver:self selector:@selector(menuWillToggle) name:MenuWillCloseNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self name:MenuWillOpenNotification object:nil];
    [notificationCenter removeObserver:self name:MenuWillCloseNotification object:nil];
}

- (void)setTitle:(NSString *)title image:(NSString *)image {
    
    CGFloat sizeWidth = self.navigationController.navigationBar.frame.size.width / 2;
    CGFloat sizeHeight = self.navigationController.navigationBar.frame.size.height * 0.5;
    CGFloat marginLeftImageView = sizeHeight / 2;
    CGFloat marginLeftLabel = sizeHeight * 2;
    UIImageView *imageView;
    UILabel *labelTitle;
    
    UIView *viewTitle = [[UIView alloc]initWithFrame:CGRectMake(0, 0, sizeWidth, sizeHeight)];
    
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(marginLeftImageView, 0 , sizeHeight, sizeHeight)];
    imageView.image = [UIImage imageNamed:image];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(marginLeftLabel, 0 , sizeWidth , sizeHeight)];
    labelTitle.text = title;
    labelTitle.textColor = [UIColor whiteColor];
    
    CGSize newSize = [labelTitle sizeThatFits:CGSizeMake(MAXFLOAT, sizeHeight)];
    CGRect newFrame = labelTitle.frame;
    newFrame.size = newSize;
    labelTitle.frame = newFrame;
    
    viewTitle.frame = CGRectMake(0, 0, labelTitle.frame.size.width + imageView.frame.size.width + marginLeftLabel - marginLeftImageView, sizeHeight);
    
    [viewTitle addSubview:imageView];
    [viewTitle addSubview:labelTitle];
    self.navigationItem.titleView = viewTitle;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.revealViewController tapGestureRecognizer];
    [self.revealViewController panGestureRecognizer];
    
    UINavigationController *navigationController = self.navigationController;
    if (navigationController.revealViewController.frontViewController == navigationController
        && self == navigationController.viewControllers[0])
    {
        CGFloat menuButtonHeight = self.navigationController.navigationBar.frame.size.height * 0.5;
        self.menuButton = [[MenuButton alloc] initWithFrame:CGRectMake(0, 0, menuButtonHeight, menuButtonHeight)];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.menuButton];
        
        if (self.revealViewController != nil) {
            [self.menuButton addTarget:self.revealViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        self.menuOverlayView = [[MenuOverlayView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:self.menuOverlayView];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.backgroundImageView != nil) {
        static NSArray *backgroundImages;
        
        if (backgroundImages == nil) {
            backgroundImages = @[
                [UIImage imageNamed:@"background_0"],
                [UIImage imageNamed:@"background_1"],
                [UIImage imageNamed:@"background_2"],
                [UIImage imageNamed:@"background_3"]
            ];
        }
    
        NSUInteger backgroundIndex = [Random nextIntegerWithUpperBound:backgroundImages.count];
        self.backgroundImageView.image = backgroundImages[backgroundIndex];
    }
}

- (void)menuWillToggle {
    [self.menuButton toggleAnimated:YES];
    [self.menuOverlayView toggleAnimated:YES];
}

@end