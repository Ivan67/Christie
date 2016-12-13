#import "User.h"

@implementation User

+ (instancetype)sharedUser {
    static User *sharedUser;
    static dispatch_once_t once;
    
    dispatch_once(&once, ^{
        sharedUser = [[User alloc] init];
    });
    
    return sharedUser;
}

@end
