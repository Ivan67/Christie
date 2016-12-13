//
//  NearbyPharmacyRegionMonitorDelegate.m
//  ChristiePortal
//
//  Created by Sergey on 30/11/15.
//  Copyright © 2015 Rhinoda. All rights reserved.
//

#import <BlocksKit/BlocksKit.h>
#import <UIKit/UIKit.h>
#import "DataManager.h"
#import "LocationMonitor.h"
#import "NearbyPharmacyMonitor.h"
#import "NotificationManager.h"
#import "Pharmacy.h"
#import "SettingsManager.h"

static const NSInteger InvalidPharmacyID = 0;

@interface NearbyPharmacyMonitor ()

@property (nonatomic, readonly) LocationMonitor *locationMonitor;
@property (nonatomic, readonly) CLLocationDistance regionRadius;
@property (nonatomic, readonly) NotificationManager *notificationManager;
@property (nonatomic, readonly) SettingsManager *settingsManger;

@end

@implementation NearbyPharmacyMonitor

- (instancetype)initWithLocationMonitor:(LocationMonitor *)locationMonitor
                           regionRadius:(CLLocationDistance)regionRadius
                        settingsManager:(SettingsManager *)settingsManager
                    notificationManager:(NotificationManager *)notificationManager {
    if (self = [super init]) {
        _locationMonitor = locationMonitor;
        _locationMonitor.dataSource = self;
        _locationMonitor.delegate = self;
        _regionRadius = regionRadius;
        _settingsManger = settingsManager;
        _notificationManager = notificationManager;
    }
    return self;
}

- (NSArray<CLRegion *> *)locationMonitor:(LocationMonitor *)monitor regionsForLocation:(CLLocation *)location {
    NSArray<Pharmacy *> *nearestPharmacies = [[DataManager sharedManager] fetchPharmaciesNearLocation:location];
    return [nearestPharmacies bk_map:^id(Pharmacy *pharmacy) {
        NSString *identifier = [NSString stringWithFormat:@"Pharmacy id = %@ radius = %.0f", pharmacy.id, self.regionRadius];
        return [[CLCircularRegion alloc] initWithCenter:pharmacy.location.coordinate
                                                 radius:self.regionRadius
                                             identifier:identifier];
    }];
}

- (void)locationMonitor:(LocationMonitor *)monitor didEnterRegion:(CLRegion *)region {
    if (!self.settingsManger.notifyAboutNearbyPharmacies) {
        return;
    }
    
    Pharmacy *pharmacy = [self pharmacyFromRegion:(CLCircularRegion *)region];
    if (pharmacy != nil) {
        UILocalNotification *notification = [self.notificationManager notificationForNearbyPharmacy:pharmacy];
        [self.notificationManager presentLocalNotification:notification];
    }
}

- (Pharmacy *)pharmacyFromRegion:(CLCircularRegion *)region {
    NSInteger pharmacyID = [self pharmacyIDFromRegionIdentifier:region.identifier radius:region.radius];
    if (pharmacyID != InvalidPharmacyID) {
        return [[DataManager sharedManager] fetchPharmacyWithID:pharmacyID];
    }
    return nil;
}

- (NSInteger)pharmacyIDFromRegionIdentifier:(NSString *)identifier radius:(CLLocationDistance)radius {
    NSScanner *scanner = [[NSScanner alloc] initWithString:identifier];
    
    NSInteger pharmacyID;
    if (![scanner scanString:@"Pharmacy id =" intoString:nil]
        || ![scanner scanInteger:&pharmacyID]) {
        return InvalidPharmacyID;
    }
    
    CLLocationDistance scannedRadius;
    if (![scanner scanString:@"radius =" intoString:nil] ||
        ![scanner scanDouble:&scannedRadius]) {
        return InvalidPharmacyID;
    }
    
    if (floor(scannedRadius) != floor(radius)) {
        return InvalidPharmacyID;
    }
    return pharmacyID;
}

@end
