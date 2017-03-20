//
//  LRBaseNetworkOperationTest.m
//  LivePaperSDK
//
//  Created by Alejandro Mendez on 1/3/17.
//  Copyright © 2017 Hewlett-Packard. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "LPBaseNetworkingTestCase.h"
#import "LPBaseNetworkOperation.h"

@interface LRBaseNetworkOperationTest : LPBaseNetworkingTestCase
@end

@implementation LRBaseNetworkOperationTest

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testRequestSuccess {
    
    NSString *dummyUrl = @"http://dummy.com";
    NSString *expextedResponseString = @"my_data";
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.absoluteString containsString:dummyUrl];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithData:[expextedResponseString dataUsingEncoding:NSUTF8StringEncoding] statusCode:200 headers:nil];
    }];

    
    [LPBaseNetworkOperation executeWithSession:self.session url:dummyUrl method:LPHttpMethodGet data:nil completion:^(id  _Nullable data, NSHTTPURLResponse * _Nullable response, NSError * _Nullable error) {
        XCTAssertNil(error);
        NSString * responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        XCTAssertEqual(responseString, expextedResponseString);
    }];
}

- (void)testRequestFailure {
    
    NSString *dummyUrl = @"http://dummy.com";
    int errorCode = 500;
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.absoluteString containsString:dummyUrl];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithData:[@"" dataUsingEncoding:NSUTF8StringEncoding] statusCode:errorCode headers:nil];
    }];
    
    [LPBaseNetworkOperation executeWithSession:self.session url:dummyUrl method:LPHttpMethodGet data:nil completion:^(id  _Nullable data, NSHTTPURLResponse * _Nullable response, NSError * _Nullable error) {
        XCTAssertNotNil(error);
        XCTAssertEqual(error.code, errorCode);
    }];
}

@end
