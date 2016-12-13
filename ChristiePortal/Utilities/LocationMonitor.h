#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>

extern const NSUInteger LocationMonitorMaxNumberOfRegions;

extern NSString *const LocationMonitorLocationDidChangeNotification;
extern NSString *const LocationMonitorLocationKey;

@class LocationMonitor;

@protocol LocationMonitorDelegate <NSObject>

@required
- (void)locationMonitor:(LocationMonitor *)monitor didEnterRegion:(CLRegion *)region;

@optional
- (void)locationMonitor:(LocationMonitor *)monitor didExitRegion:(CLRegion *)region;

@end

@protocol LocationMonitorDataSource <NSObject>

/**
 * Provides region data for the associated LocationMonitor.
 *
 * @return An array of regions to be monitored by the location monitor.
 */
@required
- (NSArray<CLRegion *> *)locationMonitor:(LocationMonitor *)monitor regionsForLocation:(CLLocation *)location;

@end

/**
 * LocationMonitor monitors for location changes and nearby regions.
 *
 * Because the maximum number of monitored regions is limited by the system,
 * LocationMonitor uses a data source for obtaining the regions to monitor
 * (typically nearest regions). The data source is polled when the location
 * changes significantly, e.g. device moves from one cell tower to another.
 *
 * LocationMonitor also notifies its delegate when the device enters or exits
 * one of the monitored regions, similarly to CLLocationManager.
 */
@interface LocationMonitor : NSObject <CLLocationManagerDelegate>

/**
 * Delegate object.
 */
@property (weak, nonatomic) id<LocationMonitorDelegate> delegate;

/**
 * Region data source.
 */
@property (weak, nonatomic) id<LocationMonitorDataSource> dataSource;

/**
 * The lastest location recorded by the LocationMonitor.
 */
@property (nonatomic) CLLocation *location;

/**
 * Returns the shared LocationManager instance.
 *
 * @return The LocationMonitor singleton.
 */
+ (instancetype)sharedMonitor;

/**
 * Creates a new LocationMonitor that uses the given location manager.
 *
 * @return New LocationMonitor object.
 */
- (instancetype)initWithLocationManager:(CLLocationManager *)locationManager;

/**
 * Starts monitoring for location changes and nearby stores.
 */
- (void)startMonitoringForLocationChanges;

@end
