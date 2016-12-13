
#import <AFNetworking.h>
#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>
#import "NSError+APIClient.h"

@interface NSErrorAPIClientTests : XCTestCase

@end

@implementation NSErrorAPIClientTests

- (void)testThatItHandles401Error {
    id responseMock = OCMClassMock([NSHTTPURLResponse class]);
    OCMStub([responseMock statusCode]).andReturn(401);
    
    id errorMock = OCMPartialMock([[NSError alloc] init]);
    OCMStub([errorMock userInfo]).andReturn(@{
        AFNetworkingOperationFailingURLResponseErrorKey: responseMock
    });
    
    NSString *remoteDescription = [errorMock remoteDescription];
    
    XCTAssertTrue([remoteDescription containsString:@"Invalid username or password"]);
}

- (void)testThatItReturnsLocalizedDescriptionIfResponseHasNoErrorsKey {
    id errorMock = OCMPartialMock([[NSError alloc] init]);
    OCMStub([errorMock responseObject]).andReturn(nil);
    OCMStub([errorMock localizedDescription]).andReturn(@"Fixture localized description");
    
    NSString *remoteDescription = [errorMock remoteDescription];
    
    XCTAssertTrue([remoteDescription isEqualToString:@"Fixture localized description"]);
}

- (void)testThatItReturnsNewlineSeparatedErrorTitlesIfHasErrorsKey {
    id errorMock = OCMPartialMock([[NSError alloc] init]);
    OCMStub([errorMock responseObject]).andReturn((@{
        @"errors": @[
            @{@"title": @"Fixture error 1"},
            @{@"title": @"Fixture error 2"},
            @{@"title": @"Fixture error 3"}
        ]
    }));
    
    NSString *remoteDescription = [errorMock remoteDescription];
    
    XCTAssertTrue([remoteDescription isEqualToString:@"Fixture error 1\nFixture error 2\nFixture error 3"]);
}

@end
