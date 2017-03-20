//
//  GetTokenOperationTest.m
//  LivePaperSDK
//
//  Created by Alejandro Mendez on 1/3/17.
//  Copyright © 2017 Hewlett-Packard. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "LPBaseNetworkingTestCase.h"
#import "LPGetTokenOperation.h"

@interface LPGetTokenOperationTest : LPBaseNetworkingTestCase
@end

@implementation LPGetTokenOperationTest

- (void)setUp {
    [super setUp];
    self.session = [LPSession createSessionWithClientID:@"client" secret:@"secret"];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testSuccess {
    
    XCTAssertNil(self.session.accessToken);
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        
        
        return [request.URL.absoluteString containsString:[self.session.baseURL absoluteString]];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        NSString* fixture = OHPathForFile(@"GetTokenSuccess.json", self.class);
        return [OHHTTPStubsResponse responseWithFileAtPath:fixture
                                                statusCode:200 headers:@{@"Content-Type":@"application/json"}];
    }];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"expectation"];
    
    [LPGetTokenOperation executeWithSession:self.session completion:^(id  _Nullable data, NSHTTPURLResponse * _Nullable response, NSError * _Nullable error) {
        XCTAssertNil(error);
        XCTAssertNotNil(self.session.accessToken);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:2.0 handler:nil];
}

- (void)testFailure {
    
    XCTAssertNil(self.session.accessToken);
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.absoluteString containsString:[[self.session baseURL] absoluteString]];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithData:[@"" dataUsingEncoding:NSUTF8StringEncoding] statusCode:500 headers:nil];;
    }];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"expectation"];
    
    [LPGetTokenOperation executeWithSession:self.session completion:^(id  _Nullable data, NSHTTPURLResponse * _Nullable response, NSError * _Nullable error) {
        XCTAssertNotNil(error);
        XCTAssertNil(self.session.accessToken);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:2.0 handler:nil];
}


@end
