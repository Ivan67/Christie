//
//  NSError.m
//  ChristiePortal
//
//  Created by Sergey on 10/18/15.
//  Copyright © 2015 Rhinoda. All rights reserved.
//

#import <AFNetworking.h>
#import "NSError+ResponseData.h"

@implementation NSError (ResponseData)

- (NSData *)responseData {
    return self.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
}

- (NSDictionary *)responseObject {
    NSData *responseData = self.responseData;
    if (responseData != nil) {
        return [NSJSONSerialization JSONObjectWithData:responseData options:(NSJSONReadingOptions)0 error:nil];
    }
    return nil;
}

@end
