#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Pharmacy : NSManagedObject

/**
 * The location of the pharmacy.
 */
@property (nonatomic, copy) CLLocation *location;

/**
 * Pharmacy name for humans (CVS Store #XXX).
 */
@property (nonatomic, readonly, copy) NSString *displayName;

/**
 * Short address (includes street name and building).
 */
@property (nonatomic, readonly, copy) NSString *shortAddress;

/**
 * The name of the entity.
 */
+ (NSString *)entityName;

/**
 * Calculates the distance (in meters) from the pharmacy's location to the specified location.
 *
 * @param location The location relative to which the distance is calculated.
 * @return The distance (in meters) between the two locations.
 */
-(CLLocationDistance)distanceToLocation:(CLLocation *)location;

/**
 * Checks whether the pharmacy is open at the specified date.
 *
 * @return \c YES if pharmacy is open, \c NO otherwise.
 */
- (BOOL)isOpenAt:(NSDate *)date;

/**
 * Checks whether Photo is open at the specified date.
 *
 * @return \c YES if Photo is open, \c NO otherwise.
 */
- (BOOL)hasPhotoOpenAt:(NSDate *)date;

/**
 * Checks whether Minute Clinic is open at the specified date.
 *
 * @return \c YES if Minute Clinic is open, \c NO otherwise.
 */
- (BOOL)hasMinuteClinicOpenAt:(NSDate *)date;

/**
 * Checks whether the pharmacy is open 24 hours a day.
 *
 * @return \c YES if pharmacy is open 24/7, \c NO otherwise.
 */
- (BOOL)isOpen24Hours;

/**
 * Checks whether Photo is open 24 hours a day.
 *
 * @return \c YES if Photo is open 24/7, \c NO otherwise.
 */
- (BOOL)hasPhotoOpen24Hours;

/**
 * Checks whether Minute Clinic is open 24 hours a day.
 *
 * @return \c YES if Minute Clinic open 24/7, \c NO otherwise.
 */
- (BOOL)hasMinuteClinicOpen24Hours;

@end

NS_ASSUME_NONNULL_END

#import "Pharmacy+CoreDataProperties.h"
