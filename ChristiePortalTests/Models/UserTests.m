//
//  UserTests.m
//  ChristiePortal
//
//  Created by Sergey on 18/11/15.
//  Copyright © 2015 Rhinoda. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "User.h"

@interface UserTests : XCTestCase

@end

@implementation UserTests

- (void)testThatSharedUserReturnValueIsNotNil {
    User *user = [User sharedUser];
    
    XCTAssertNotNil(user);
}

- (void)testThatSharedUserReturnValueIsConsistent {
    User *user1 = [User sharedUser];
    User *user2 = [User sharedUser];
    
    XCTAssertEqual(user1, user2);
}

@end
