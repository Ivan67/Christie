#import <Foundation/Foundation.h>

@interface Environment : NSObject

/**
 * Are we running tests?
 *
 * @return \c YES if running tests, otherwise \c NO.
 */
+ (BOOL)isRunningTests;

/**
 * Are we debugging notifications?
 *
 * When notification debugging is enabled, the app displays a test notification
 * imeediately after is it launched.
 *
 * @return \c YES if debugging notifications, otherwise \c NO.
 */
+ (BOOL)isDebuggingNotifications;

/**
 * Is automatic login enabled?
 *
 * When automatic login is enabled, the app automatically logs in as with a pre-determined
 * username and password.
 *
 * @return \c YES if automatic login is enabled, otherwise \c NO.
 */
+ (BOOL)isAutoLoginEnabled;

/**
 * Is fake user login enabled?
 *
 * When fake user login is enabled, the app automatically logs in as a fake user with
 * pre-defined attributes.
 *
 * @return \c YES if fake user login is enabled, otherwise \c NO.
 */
+ (BOOL)isFakeUserLoginEnabled;

@end
