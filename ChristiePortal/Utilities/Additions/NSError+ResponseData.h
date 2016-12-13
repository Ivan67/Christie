#import <Foundation/Foundation.h>

@interface NSError (ResponseData)

/**
 * Returns raw response data.
 */
@property (readonly, copy) NSData *responseData;

/**
 * Returns response data serialized as JSON.
 */
@property (readonly, copy) NSDictionary *responseObject;

@end
