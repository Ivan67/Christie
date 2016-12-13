#import <AudioToolbox/AudioServices.h>
#import "DataManager.h"
#import "NavigationManager.h"
#import "NotificationManager.h"
#import "Pharmacy.h"
#import "User.h"
#import "UIViewController+AlertHelpers.h"

static NSString *const NotificationIdentifierKey = @"notificationIdentifier";
static NSString *const PharmacyIDKey = @"pharmacyID";

static NSString *const NearbyPharmacyNotificationIdentifier = @"NearbyPharmacyNotification";

@interface NotificationManager ()

@property (weak, nonatomic, readonly) UIApplication *application;
@property (nonatomic, readonly) NavigationManager *navigationManager;

@end

@implementation NotificationManager

- (instancetype)initWithApplication:(UIApplication *)application
                  navigationManager:(NavigationManager *)navigationManager {
    if (self = [super init]) {
        _application = application;
        _navigationManager = navigationManager;
    }
    return self;
}

- (void)registerUserNotificationSettings {
    UIUserNotificationType types = UIUserNotificationTypeAlert;
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
    [self.application registerUserNotificationSettings:settings];
}

- (UILocalNotification *)notificationForNearbyPharmacy:(Pharmacy *)pharmacy {
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.alertBody = [NSString stringWithFormat:@"Nearby pharmacy\n%@\n%@", pharmacy.displayName, pharmacy.shortAddress];
    notification.userInfo = @{
        NotificationIdentifierKey: NearbyPharmacyNotificationIdentifier,
        PharmacyIDKey: pharmacy.id
    };
    return notification;
}

- (void)vibrate {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

- (void)presentLocalNotification:(UILocalNotification *)notification {
    [self vibrate];
    [self.application presentLocalNotificationNow:notification];
}

- (void)handleLocalNotification:(UILocalNotification *)notification {
    UIApplication *application = self.application;
    if (application.applicationState == UIApplicationStateActive) {
        // The notification was fired while running in the foreground (the user didn't tap it).
        return;
    }
    
    if (![User sharedUser].loggedIn) {
        UIViewController *rootViewController = [application.delegate window].rootViewController;
        [rootViewController showErrorAlertWithMessage:@"You are not logged in"];
        return;
    }

    if ([notification.userInfo[NotificationIdentifierKey] isEqualToString:NearbyPharmacyNotificationIdentifier]) {
        NSInteger pharmacyID = [notification.userInfo[PharmacyIDKey] integerValue];
        [self presentDetailsForPharmacyWithID:pharmacyID];
    }
}

- (void)presentDetailsForPharmacyWithID:(NSInteger)pharmacyID {
    Pharmacy *pharmacy = [[DataManager sharedManager] fetchPharmacyWithID:pharmacyID];
    if (pharmacy != nil) {
        [self.navigationManager navigateTo:@"/pharmacies/search/details" withParameters:@{
            @"pharmacy": pharmacy
        }];
    }
}

@end
