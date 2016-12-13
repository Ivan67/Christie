//
//  AuthenticationManager.h
//  ChristiePortal
//
//  Created by Sergey on 25/11/15.
//  Copyright © 2015 Rhinoda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LocalAuthentication/LocalAuthentication.h>

typedef void (^AuthenticationCompletionHandler)(BOOL success, NSError *error);
typedef void (^AuthenticationFailureHandler)(NSError *error);

/**
 * AuthenticationManager is a convenience wrapper around the Local Authentication API.
 *
 * Its sole purpose is to call the completion handler on the *main* queue for easier
 * testing.
 */
@interface AuthenticationManager : NSObject

- (instancetype)initWithContext:(LAContext *)context;

/**
 * Authenticate using the specified policy.
 *
 * @param policy The authentication policy.
 * @param reason User-friendly text shown in the interface.
 * @param completion: Completion handler that is invoked when the authentication is complete.
 * @param failure: Failure handler that is invoked if the policy cannot be evaluated.
 */
- (void)authenticateWithPolicy:(LAPolicy)policy
                        reason:(NSString *)reason
                     copletion:(AuthenticationCompletionHandler)completionHandler
                       failure:(AuthenticationFailureHandler)failureHandler;

@end
