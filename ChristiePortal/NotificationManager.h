#import <UIKit/UIKit.h>

@class NavigationManager;

@interface NotificationManager : NSObject

/**
 * Creates a new NotificationManager object.
 *
 * @param application The application object used for displaying notifications.
 * @param navigationManager The navigation manager to use for navigating to various screns
 *        when the user activates a notification.
 *
 * @return The newly created NavigationManager object.
 */
- (instancetype)initWithApplication:(UIApplication *)application
                  navigationManager:(NavigationManager *)navigationManagerr;

/**
 * Registers user notification settings with the application.
 */
- (void)registerUserNotificationSettings;

/**
 * Creates a local notification for a nearby pharmacy.
 *
 * @param pharamcy The nearby pharmacy.
 * @return A local notification for the specified nearby pharmacy.
 */
- (UILocalNotification *)notificationForNearbyPharmacy:(Pharmacy *)pharmacy;

/**
 * Presents a local notification returned by one of the notificationForXXX methods.
 *
 * @param notification The notification to be presented by the application.
 */
- (void)presentLocalNotification:(UILocalNotification *)notification;

/**
 * Handles a local notification.
 *
 * @param notification The local notification to be dispatched.
 */
- (void)handleLocalNotification:(UILocalNotification *)notification;

@end
