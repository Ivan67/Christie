#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>

@class LocationMonitor;
@class NotificationManager;
@class SettingsManager;

@interface NearbyPharmacyMonitor : NSObject <LocationMonitorDataSource, LocationMonitorDelegate>

- (instancetype)initWithLocationMonitor:(LocationMonitor *)locationMonitor
                           regionRadius:(CLLocationDistance)regionRadius
                        settingsManager:(SettingsManager *)settingsManager
                    notificationManager:(NotificationManager *)notificationManager;

@end
