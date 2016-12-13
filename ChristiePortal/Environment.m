#import "Environment.h"

@implementation Environment

+ (BOOL)isRunningTests {
    return [NSProcessInfo processInfo].environment[@"XCInjectBundle"] != nil;
}

+ (BOOL)isDebuggingNotifications {
    return [[NSProcessInfo processInfo].environment[@"NotificationDebugging"] boolValue];
}

+ (BOOL)isAutoLoginEnabled {
    return [[NSProcessInfo processInfo].environment[@"AutoLoginEnabled"] boolValue];
}

+ (BOOL)isFakeUserLoginEnabled {
    return [[NSProcessInfo processInfo].environment[@"FakeUserLoginEnabled"] boolValue];
}

@end
