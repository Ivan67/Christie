//
//  PharmacyAnnotation.h
//  ChristiePortal
//
//  Created by Sergey on 04/02/16.
//  Copyright © 2016 Rhinoda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@class Pharmacy;

@interface PharmacyAnnotation : NSObject <MKAnnotation>

@property (weak, nonatomic) Pharmacy *pharamcy;

- (instancetype)initWithPharmacy:(Pharmacy *)pharmacy;

@end
