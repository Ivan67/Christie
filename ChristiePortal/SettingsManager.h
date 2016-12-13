//
//  SettingsManager.h
//  ChristiePortal
//
//  Created by Sergey on 24/11/15.
//  Copyright © 2015 Rhinoda. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const SettingsImportedCVSDataKey;
extern NSString *const SettingsCompletedRegistrationKey;
extern NSString *const SettingsUsernameKey;
extern NSString *const SettingsNotifyAboutNearbyPharmaciesKey;
extern NSString *const SettingsUseTouchIDKey;

@interface SettingsManager : NSObject

@property (nonatomic, readonly) NSUserDefaults *userDefaults;

@property (nonatomic) BOOL importedCVSData;
@property (nonatomic) BOOL completedRegistration;
@property (nonatomic) NSString *username;
@property (nonatomic) BOOL notifyAboutNearbyPharmacies;
@property (nonatomic) BOOL useTouchID;

- (instancetype)initWithUserDefaults:(NSUserDefaults *)userDefaults;

- (void)registerDefaults;

@end
