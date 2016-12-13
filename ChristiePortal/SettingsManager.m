//
//  SettingsManager.m
//  ChristiePortal
//
//  Created by Sergey on 24/11/15.
//  Copyright © 2015 Rhinoda. All rights reserved.
//

#import "SettingsManager.h"

NSString *const SettingsImportedCVSDataKey = @"importedCVSData";
NSString *const SettingsCompletedRegistrationKey = @"completedRegistration";
NSString *const SettingsUsernameKey = @"username";
NSString *const SettingsNotifyAboutNearbyPharmaciesKey = @"notifyAboutNearbyPharmacies";
NSString *const SettingsUseTouchIDKey = @"useTouchID";

@implementation SettingsManager

- (instancetype)initWithUserDefaults:(NSUserDefaults *)userDefaults {
    if (self = [super init]) {
        _userDefaults = userDefaults;
    }
    return self;
}

- (void)registerDefaults {
    [_userDefaults registerDefaults:@{
        SettingsImportedCVSDataKey: @NO,
        SettingsCompletedRegistrationKey: @NO,
        SettingsUsernameKey: @"",
        SettingsNotifyAboutNearbyPharmaciesKey : @YES,
        SettingsUseTouchIDKey : @NO
    }];
}

- (BOOL)importedCVSData {
    return [self.userDefaults boolForKey:SettingsImportedCVSDataKey];
}

- (void)setImportedCVSData:(BOOL)importedCVSData {
    [self.userDefaults setBool:importedCVSData forKey:SettingsImportedCVSDataKey];
}

- (BOOL)completedRegistration {
    return [self.userDefaults boolForKey:SettingsCompletedRegistrationKey];
}

- (void)setCompletedRegistration:(BOOL)completedRegistration {
    [self.userDefaults setBool:completedRegistration forKey:SettingsCompletedRegistrationKey];
}

- (NSString *)username {
    return [self.userDefaults stringForKey:SettingsUsernameKey];
}

- (void)setUsername:(NSString *)username {
    [self.userDefaults setValue:username forKey:SettingsUsernameKey];
}

- (BOOL)notifyAboutNearbyPharmacies {
    return [self.userDefaults boolForKey:SettingsNotifyAboutNearbyPharmaciesKey];
}

- (void)setNotifyAboutNearbyPharmacies:(BOOL)notifyAboutNearbyPharmacies {
    [self.userDefaults setBool:notifyAboutNearbyPharmacies forKey:SettingsNotifyAboutNearbyPharmaciesKey];
}
     
- (BOOL)useTouchID {
    return [self.userDefaults boolForKey:SettingsUseTouchIDKey];
}

- (void)setUseTouchID:(BOOL)useTouchID {
    [self.userDefaults setBool:useTouchID forKey:SettingsUseTouchIDKey];
}

@end
