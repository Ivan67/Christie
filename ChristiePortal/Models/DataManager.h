#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>

@class DoctorSpeciality;
@class Pharmacy;

@interface DataManager : NSObject

/**
 * The main managed object context.
 */
@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;

/**
 * Returns the shared DataManager instance.
 *
 * @return DataManager singleton.
 */
+ (instancetype)sharedManager;

/**
 * Initializes DataManager with the specified managed object context.
 *
 * @param managedObjectContext The managed object context to use for data storage.
 */
- (instancetype)initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

/**
 * Executes a fetch request on the managed object context.
 *
 * This is a generic method for executing any fetch request against the associated MOC.
 * Usually one should not call this method directly but use a dedicated method instead, like -fetchPharmacies.
 *
 * @param fetchRequest The fetch request to be executed.
 * @return Data returned by the managed object context or \c nil if an error occured.
 */
- (NSArray *)fetchUsingRequest:(NSFetchRequest *)fetchRequest;

/**
 * Fetches all Store objects.
 *
 * @return An array containing all Store objects or nil on error.
 */
- (NSArray<Pharmacy *> *)fetchPharmacies;

/**
 * Fetches pharmacies sorted by distance to the specified location.
 *
 * @param location The location relative to which the pharmacies will be sorted.
 *
 * @return An array of Store objects or nil on error.
 */
- (NSArray<Pharmacy *> *)fetchPharmaciesNearLocation:(CLLocation *)location;

/**
 * Fetches the pharmacy with the specified ID.
 *
 * @return The corresponding Store object or nil if not found.
 */
- (Pharmacy *)fetchPharmacyWithID:(NSInteger)pharmacyID;

/**
 * Saves any changes made to the managed object context, i.e. write them to the persistent store.
 */
- (void)saveChanges;

@end

