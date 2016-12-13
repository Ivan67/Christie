#import "CignaSearchViewController.h"
#import "LocationMonitor.h"

@interface CignaSearchViewController () <WebViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *overlayView;

@property (nonatomic, copy) NSString *searchTerm;
@property (nonatomic, copy) NSString *searchLocation;
@property (nonatomic) BOOL loadedSearchResults;

@end

@implementation CignaSearchViewController

- (instancetype)initWithGeocoder:(CLGeocoder *)geocoder {
    if (self = [super initWithNibName:nil bundle:nil]) {
        _geocoder = geocoder;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.delegate = self;
    [self setTitle:@"Cigna" image:@"menu_doctors"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self checkInternetAccess];
    self.searchTerm = self.navigationParameters[@"doctor"];
    self.searchLocation = self.navigationParameters[@"location"];
    
    if (self.searchLocation.length == 0) {
        CLLocation *location = [LocationMonitor sharedMonitor].location;
        [self.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray* placemarks, NSError* error) {
            if (error == nil) {
                CLPlacemark *placemark = [placemarks lastObject];
                self.searchLocation = [NSString stringWithFormat:@"%@, %@, %@",
                                       placemark.locality,
                                       placemark.administrativeArea,
                                       placemark.country];
            }
        }];
    }

    self.loadedSearchResults = NO;
    self.overlayView.hidden = NO;
    
    [self loadURLString:@"http://hcpdirectory.cigna.com/web/public/providers"];
}

- (void)webViewControllerDidFinishLoad:(WebViewController *)webViewController {
    if (self.webView.loading) {
        return;
    }
    
    if ([self.webView.request.URL.resourceSpecifier hasPrefix:@"//hcpdirectory.cigna.com/web/public/providers/searchresults"]) {
        self.overlayView.hidden = YES;
        self.loadedSearchResults = YES;
        return;
    }

    if (!self.loadedSearchResults) {
        [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@""
            "function waitForElement(selector, callback) {"
            "    var interval = setInterval(function() {"
            "        var element = document.querySelector(selector);"
            "        if (element) {"
            "            callback(element);"
            "            clearInterval(interval);"
            "        }"
            "    }, 50);"
            "}"
            "waitForElement('#searchLocation', function(element) {"
            "    var searchLocationInput = document.getElementById('searchLocation');"
            "    searchLocation.value = '%@';"
            "    var searchTermDoctorInput = document.getElementById('searchTermDoctor');"
            "    searchTermDoctorInput.value = '%@';"
            "    var planSelectorLink = document.getElementById('planselectorlink');"
            "    planSelectorLink.click();"
            "    waitForElement('#medicalPlan-PPO', function(planCheckbox) {"
            "        planCheckbox.checked = true;"
            "        waitForElement('.js-plan-select', function(chooseButton) {"
            "            chooseButton.click();"
            "            var searchButton = document.querySelector('button#search');"
            "            searchButton.click();"
            "        });"
            "    });"
            "});", self.searchLocation, self.searchTerm]
        ];
    }
}

@end
