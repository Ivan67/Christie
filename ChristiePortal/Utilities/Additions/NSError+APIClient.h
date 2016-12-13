//
//  NSError+API.h
//  ChristiePortal
//
//  Created by Sergey on 10/18/15.
//  Copyright © 2015 Rhinoda. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSError (APIClient)

/**
 * Returns the description of an API request error as described by the server.
 *
 * The error description is obtained by concatenating all error titles from the @c errors[i].title
 * property of the response object where @c i is the error index.
 *
 * If failed, returns localizedDescription.
 */
@property (nonatomic, readonly, copy) NSString *remoteDescription;

@end
