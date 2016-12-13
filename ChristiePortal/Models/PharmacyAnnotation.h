#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@class Pharmacy;

@interface PharmacyAnnotation : NSObject <MKAnnotation>

@property (weak, nonatomic) Pharmacy *pharamcy;

- (instancetype)initWithPharmacy:(Pharmacy *)pharmacy;

@end
