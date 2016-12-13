#import <Foundation/Foundation.h>
#import <AFNetworking.h>
#import "NSError+APIClient.h"

@class Doctor;

/**
 * Manages network requests to the server-side API.
 */
@interface APIClient : AFHTTPSessionManager

/**
 * Returns the shared APIClient object.
 *
 * @return Shared APIClient object.
 */
+ (instancetype)sharedClient;

/**
 * Fetches all doctors and returns them as an array.
 *
 * @return Array of all doctors.
 */
- (NSArray<Doctor *> *)fetchDoctors;

@end
