
#import <AFNetworking.h>
#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>
#import "NSError+ResponseData.h"

@interface NSErrorResponseDataTests : XCTestCase

@end

@implementation NSErrorResponseDataTests

- (void)testThatItReturnsResponseData {
    id errorMock = OCMPartialMock([[NSError alloc] init]);
    OCMStub([errorMock userInfo]).andReturn((@{
        AFNetworkingOperationFailingURLResponseDataErrorKey: [@"Fixture response data" dataUsingEncoding:NSUTF8StringEncoding]
    }));
    
    NSData *reponseData = [errorMock responseData];
    
    XCTAssertEqualObjects(reponseData, [@"Fixture response data" dataUsingEncoding:NSUTF8StringEncoding]);
}

- (void)testThatItDeserializesJSON {
    id errorMock = OCMPartialMock([[NSError alloc] init]);
    OCMStub([errorMock responseData]).andReturn([@"{ \"fixture_key\": \"fixture_value\" }" dataUsingEncoding:NSUTF8StringEncoding]);
    
    NSDictionary *responseObject = [errorMock responseObject];
    
    XCTAssertEqualObjects(responseObject[@"fixture_key"], @"fixture_value");
}

- (void)testThatItReturnsNilForNilResponseData {
    id errorMock = OCMPartialMock([[NSError alloc] init]);
    OCMStub([errorMock responseData]).andReturn(nil);
    
    NSDictionary *responseObject = [errorMock responseObject];
    
    XCTAssertNil(responseObject);
}

@end
