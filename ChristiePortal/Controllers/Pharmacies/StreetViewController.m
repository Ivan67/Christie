#import "StreetViewController.h"
@import GoogleMaps;

@interface StreetViewController ()

@end

@implementation StreetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Street View";
    [self loadView];
}

- (void)loadView {
    GMSPanoramaView *panoView = [[GMSPanoramaView alloc] initWithFrame:CGRectZero];
    self.view = panoView;
    
    [panoView moveNearCoordinate:self.coordinate];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
