//
//  LPProjectEntityTestCase.h
//  LivePaperSDK
//
//  Created by Alejandro Mendez on 2/3/17.
//  Copyright © 2017 Hewlett-Packard. All rights reserved.
//
#import <XCTest/XCTest.h>
#import <LivePaperSDK/LivePaperSDK.h>
#import <OHHTTPStubs/OHHTTPStubs.h>
#import <OHHTTPStubs/OHPathHelpers.h>
#import <OHHTTPStubs/NSURLRequest+HTTPBodyTesting.h>

#import "HPTestData.h"
#import "HPMockHelper.h"

extern NSString * const LPClientId;
extern NSString * const LPClientSecret;

@interface LPBaseTestCase : XCTestCase

@property (nonatomic) LPSession *session;
@property (nonatomic) NSString *projectId;

- (NSString *)pluralEntityName;
- (NSURL *)urlForAtomLink:(NSString *)name atomLinks:(NSArray *)atomLinks;

@end
