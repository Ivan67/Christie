#import <CoreLocation/CoreLocation.h>
#import "WebViewController.h"

@interface CignaSearchViewController : WebViewController

@property (nonatomic, readonly) CLGeocoder *geocoder;

- (instancetype)initWithGeocoder:(CLGeocoder *)geocoder;

@end
