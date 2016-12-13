//
//  Pharmacy+CoreDataProperties.h
//  ChristiePortal
//
//  Created by Sergey on 21/12/15.
//  Copyright © 2015 Rhinoda. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Pharmacy.h"

NS_ASSUME_NONNULL_BEGIN

@interface Pharmacy (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *address;
@property (nullable, nonatomic, retain) NSString *code;
@property (nullable, nonatomic, retain) NSNumber *completed;
@property (nullable, nonatomic, retain) NSNumber *favorite;
@property (nullable, nonatomic, retain) NSNumber *id;
@property (nullable, nonatomic, retain) NSDate *lastViewed;
@property (nullable, nonatomic, retain) NSNumber *latitude;
@property (nullable, nonatomic, retain) NSNumber *longitude;
@property (nullable, nonatomic, retain) NSString *minuteClinicHours;
@property (nullable, nonatomic, retain) NSDate *minuteClinicMFHoursClose;
@property (nullable, nonatomic, retain) NSDate *minuteClinicMFHoursOpen;
@property (nullable, nonatomic, retain) NSDate *minuteClinicSatHoursClose;
@property (nullable, nonatomic, retain) NSDate *minuteClinicSatHoursOpen;
@property (nullable, nonatomic, retain) NSDate *minuteClinicSunHoursClose;
@property (nullable, nonatomic, retain) NSDate *minuteClinicSunHoursOpen;
@property (nullable, nonatomic, retain) NSNumber *numericCode;
@property (nullable, nonatomic, retain) NSString *pharmacyHours;
@property (nullable, nonatomic, retain) NSDate *pharmacyMFHoursClose;
@property (nullable, nonatomic, retain) NSDate *pharmacyMFHoursOpen;
@property (nullable, nonatomic, retain) NSDate *pharmacySatHoursClose;
@property (nullable, nonatomic, retain) NSDate *pharmacySatHoursOpen;
@property (nullable, nonatomic, retain) NSDate *pharmacySunHoursClose;
@property (nullable, nonatomic, retain) NSDate *pharmacySunHoursOpen;
@property (nullable, nonatomic, retain) NSString *phone;
@property (nullable, nonatomic, retain) NSString *photoHours;
@property (nullable, nonatomic, retain) NSDate *photoMFHoursClose;
@property (nullable, nonatomic, retain) NSDate *photoMFHoursOpen;
@property (nullable, nonatomic, retain) NSDate *photoSatHoursClose;
@property (nullable, nonatomic, retain) NSDate *photoSatHoursOpen;
@property (nullable, nonatomic, retain) NSDate *photoSunHoursClose;
@property (nullable, nonatomic, retain) NSDate *photoSunHoursOpen;
@property (nullable, nonatomic, retain) NSString *service;
@property (nullable, nonatomic, retain) id timeZone;
@property (nullable, nonatomic, retain) NSString *url;

@end

NS_ASSUME_NONNULL_END
