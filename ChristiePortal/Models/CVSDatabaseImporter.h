#import <CoreData/CoreData.h>

@class CVSDatabaseReader;

@interface CVSDatabaseImporter : NSObject

/**
 * The main managed object context to which the data will eventually
 * be imported.
 */
@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;

/**
 * The private managed object context used for performing the import
 * in a background queue.
 */
@property (nonatomic, readonly) NSManagedObjectContext *privateManagedObjectContext;

/**
 * Initializes a CVSImported using a given managed object context.
 */
- (instancetype)initWithDatabaseReader:(CVSDatabaseReader *)databaseReader
                  managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                 privateManagedObjectContext:(NSManagedObjectContext *)privateManagedObjectContext;

/**
 * Imports data from the CVS store database.
 *
 * @param progressHandler Import progress block.
 * @param completionHandler Import completion block.
 */
- (void)importCVSDataUsingProgressBlock:(void(^)(float progress))progressHandler
                             completion:(void(^)())completionHandler;


@end
