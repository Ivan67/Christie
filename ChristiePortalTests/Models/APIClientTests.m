#import <XCTest/XCTest.h>
#import "APIClient.h"

@interface APIClientTests : XCTestCase

@end

@implementation APIClientTests

- (void)testThatSharedClientReturnValueIsNotNil {
    APIClient *client = [APIClient sharedClient];
    
    XCTAssertNotNil(client);
}

- (void)testThatSharedClientReturnValueIsConsistent {
    APIClient *client1 = [APIClient sharedClient];
    APIClient *client2 = [APIClient sharedClient];
    
    XCTAssertEqual(client1, client2);
}

- (void)testThatItSetsRequestContentType {
    APIClient *client = [[APIClient alloc] init];
    
    NSString *contentType = [client.requestSerializer valueForHTTPHeaderField:@"Content-Type"];
    
    XCTAssertEqualObjects(contentType, @"application/vnd.api+json");
}

- (void)testThatItAcceptsAPIResponseContentType {
    APIClient *client = [[APIClient alloc] init];
    
    NSSet<NSString *> *contentTypes = client.responseSerializer.acceptableContentTypes;
    BOOL acceptsAPIContentType = [contentTypes containsObject:@"application/vnd.api+json"];
    
    XCTAssertTrue(acceptsAPIContentType);
}

@end
