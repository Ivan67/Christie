#import "DoctorSpeciality.h"

@implementation DoctorSpeciality

- (instancetype)initWithTitle:(NSString *)title definition:(NSString *)definition {
    if (self = [super init]) {
        _title = title;
        _definition = definition;
    }
    return self;
}

@end
