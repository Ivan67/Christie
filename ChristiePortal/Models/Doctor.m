#import "Doctor.h"

@implementation Doctor

- (instancetype)initWithName:(NSString *)name address:(NSString *)address type:(NSString *)type {
    if (self = [super init]) {
        _name = name;
        _address = address;
        _type = type;
    }
    return self;
}

@end
