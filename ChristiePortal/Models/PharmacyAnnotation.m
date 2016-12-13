#import "Pharmacy.h"
#import "PharmacyAnnotation.h"

@implementation PharmacyAnnotation

- (instancetype)initWithPharmacy:(Pharmacy *)pharmacy {
    if (self = [super init]) {
        self.pharamcy = pharmacy;
    }
    return self;
}

- (CLLocationCoordinate2D)coordinate {
    return self.pharamcy.location.coordinate;
}

- (NSString *)title {
    return self.pharamcy.displayName;
}

@end
