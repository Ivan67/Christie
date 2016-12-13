//
//  NearbyPharmacyRegionMonitorDelegate.h
//  ChristiePortal
//
//  Created by Sergey on 30/11/15.
//  Copyright © 2015 Rhinoda. All rights reserved.
//

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
