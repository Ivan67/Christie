//
//  AuthenticationManager.m
//  ChristiePortal
//
//  Created by Sergey on 25/11/15.
//  Copyright © 2015 Rhinoda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AuthenticationManager.h"

@interface AuthenticationManager ()

@property (nonatomic, readonly) LAContext *context;

@end

@implementation AuthenticationManager

- (instancetype)initWithContext:(LAContext *)context {
    if (self = [super init]) {
        _context = context;
    }
    return self;
}

- (void)authenticateWithPolicy:(LAPolicy)policy reason:(NSString *)reason copletion:(AuthenticationCompletionHandler)completionHandler failure:(AuthenticationFailureHandler)failureHandler {
    NSError *failureError;
    if (![self.context canEvaluatePolicy:policy error:&failureError]) {
        if (failureHandler != nil) {
            failureHandler(failureError);
        }
        return;
    }

    [self.context evaluatePolicy:policy localizedReason:reason reply:^(BOOL success, NSError *error) {
        if (completionHandler != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(success, error);
            });
        }
    }];
}

@end
