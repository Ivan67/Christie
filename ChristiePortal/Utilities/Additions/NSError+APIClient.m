//
//  NSError+API.m
//  ChristiePortal
//
//  Created by Sergey on 10/18/15.
//  Copyright © 2015 Rhinoda. All rights reserved.
//

#import <AFNetworking.h>
#import "NSError+APIClient.h"
#import "NSError+ResponseData.h"

@implementation NSError (APIClient)

- (NSString *)remoteDescription {
    NSInteger statusCode = [self.userInfo[AFNetworkingOperationFailingURLResponseErrorKey] statusCode];
    if (statusCode == 401 /* Unathorized */) {
        return @"Invalid username or password";
    }
    
    NSArray *errors = self.responseObject[@"errors"];
    if (errors == nil) {
        return self.localizedDescription;
    }
    
    NSMutableArray *titles = [[NSMutableArray alloc] init];
    for (NSDictionary *error in errors) {
        [titles addObject:error[@"title"]];
    }
    return [titles componentsJoinedByString:@"\n"];
}

@end
