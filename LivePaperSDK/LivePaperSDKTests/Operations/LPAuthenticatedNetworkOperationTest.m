//
//  LPAuthenticatedNetworkOperationTest.m
//  LivePaperSDK
//
//  Created by Alejandro Mendez on 1/3/17.
//  Copyright © 2017 Hewlett-Packard. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "LPAuthenticatedNetworkOperation.h"
#import "LPBaseNetworkingTestCase.h"

@interface LPAuthenticatedNetworkOperationTest : LPBaseNetworkingTestCase
@end

@implementation LPAuthenticatedNetworkOperationTest

- (void)setUp {
    [super setUp];
    self.session = [LPSession createSessionWithClientID:@"client" secret:@"secret"];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testGetTokenCallWhenNotAuthenticated {
    
    XCTestExpectation *expectTokenCall = [self expectationWithDescription:@"expectTokenCall"];
    XCTestExpectation *expectOriginalCall = [self expectationWithDescription:@"expectOriginalCall"];
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.absoluteString containsString:[[self.session baseURL] absoluteString]];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        [expectTokenCall fulfill];
        NSString* fixture = OHPathForFile(@"GetTokenSuccess.json", self.class);
        return [OHHTTPStubsResponse responseWithFileAtPath:fixture
                                                statusCode:200 headers:@{@"Content-Type":@"application/json"}];
    }];
    
    NSString *dummyGetUrl = @"http://dummy.com";
    __block int originalRequestCount = 0;
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.absoluteString containsString:dummyGetUrl];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        int status = originalRequestCount == 0 ? 401 : 200;
        originalRequestCount++;
        return [OHHTTPStubsResponse responseWithData:[@"" dataUsingEncoding:NSUTF8StringEncoding] statusCode:status headers:nil];
    }];
    
    [LPAuthenticatedNetworkOperation executeWithSession:self.session url:dummyGetUrl request:nil completion:^(id  _Nullable data, NSHTTPURLResponse * _Nullable response, NSError * _Nullable error) {
        XCTAssertNil(error);
        [expectOriginalCall fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:2.0 handler:nil];
}

- (void)testErrorThrownWhenAuthenticationDoesNotFix401 {
    
    XCTestExpectation *expectOriginalCall = [self expectationWithDescription:@"expectOriginalCall"];
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.absoluteString containsString:[[self.session baseURL] absoluteString]];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        NSString* fixture = OHPathForFile(@"GetTokenSuccess.json", self.class);
        return [OHHTTPStubsResponse responseWithFileAtPath:fixture
                                                statusCode:200 headers:@{@"Content-Type":@"application/json"}];
    }];
    
    NSString *dummyGetUrl = @"http://dummy.com";
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.absoluteString containsString:dummyGetUrl];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithData:[@"" dataUsingEncoding:NSUTF8StringEncoding] statusCode:401 headers:nil];
    }];
    
    [LPAuthenticatedNetworkOperation executeWithSession:self.session url:dummyGetUrl request:nil completion:^(id  _Nullable data, NSHTTPURLResponse * _Nullable response, NSError * _Nullable error) {
        XCTAssertNotNil(error);
        XCTAssertEqual(error.code, 401);
        [expectOriginalCall fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:2.0 handler:nil];
}

@end
