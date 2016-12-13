#import <BlocksKit/BlocksKit.h>
#import <UIKit/UIKit.h>
#import "DataManager.h"
#import "LocationMonitor.h"

const NSUInteger LocationMonitorMaxNumberOfRegions = 20;

NSString *const LocationMonitorLocationDidChangeNotification = @"LocationMonitorLocationDidChangeNotification";
NSString *const LocationMonitorLocationKey = @"LocationMonitorLocationKey";

@interface LocationMonitor ()

@property (nonatomic) CLLocationManager *locationManager;

@end

@implementation LocationMonitor

+ (instancetype)sharedMonitor {
    static dispatch_once_t once;
    static LocationMonitor *sharedMonitor;

    dispatch_once(&once, ^{
        CLLocationManager *locationManager = [[CLLocationManager alloc] init];
        locationManager.distanceFilter = kCLDistanceFilterNone;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        sharedMonitor = [[LocationMonitor alloc] initWithLocationManager:locationManager];
    });

    return sharedMonitor;
}

- (instancetype)initWithLocationManager:(CLLocationManager *)locationManager {
    if (self = [super init]) {
        _locationManager = locationManager;
        _locationManager.delegate = self;

        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
            [self.locationManager requestAlwaysAuthorization];
            [self.locationManager requestWhenInUseAuthorization];
        }
    }
    return self;
}

- (void)startMonitoringForRegionsAtLocation:(CLLocation *)location {
    if (![CLLocationManager isMonitoringAvailableForClass:[CLCircularRegion class]]) {
        NSLog(@"LocationMonitor: Circular region monitoring is not available on this device");
        return;
    }

    NSArray *regions = [self.dataSource locationMonitor:self regionsForLocation:location];
    
    // The number of regions that can be monitored by CLLocationManager is limited
    // => drop unneeded regions.
    if (regions.count > LocationMonitorMaxNumberOfRegions) {
        regions = [regions subarrayWithRange:NSMakeRange(0, LocationMonitorMaxNumberOfRegions)];
    }

    // The algorithm is the following:
    //
    // 1. Go through all the old regions, i.e. those already being monitored:
    //   - if a region is not nearby, we are not interested in it so stop monitoring it
    //   - else continue monitoring (remove it from the nearest regions)
    //
    // 2. The remaining nearest regions are the new ones, we want to start monitoring
    //    those.
    NSMutableArray *regionsToMonitor = [NSMutableArray arrayWithArray:regions];

    for (__block CLCircularRegion *oldRegion in self.locationManager.monitoredRegions) {
        CLRegion *existingRegion = [regions bk_match:^BOOL(CLRegion *region) {
            return [region.identifier isEqualToString:oldRegion.identifier];
        }];
        if (existingRegion != nil) {
            [regionsToMonitor removeObject:existingRegion];
        } else {
            [self.locationManager stopMonitoringForRegion:oldRegion];
        }
    }

    for (CLRegion *region in regionsToMonitor) {
        [self.locationManager startMonitoringForRegion:region];
    }

    NSLog(@"LocationMonitor: Started monitoring for regions");
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    NSLog(@"LocationMonitor: Started monitoring for region: %@", region);
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
    NSLog(@"LocationMonitor: Monitoring failed for region: %@, reason: %@", region, error);
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    NSLog(@"LocationMonitor: Entered region: %@", region);
    [self.delegate locationMonitor:self didEnterRegion:region];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    NSLog(@"LocationMonitor: Exited region: %@", region);
    [self.delegate locationMonitor:self didExitRegion:region];
}

- (void)startMonitoringForLocationChanges {
    [self.locationManager startMonitoringSignificantLocationChanges];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation *location = [locations lastObject];
    [self startMonitoringForRegionsAtLocation:location];
    
    self.location = location;
    
    NSNotificationCenter *notificatioNCenter = [NSNotificationCenter defaultCenter];
    [notificatioNCenter postNotificationName:LocationMonitorLocationDidChangeNotification object:self userInfo:@{
        LocationMonitorLocationKey: location
    }];
    
    NSLog(@"LocationMonitor: Changed location: %@", location);
}

@end
