//
//  LPBaseNetworkingTestCase.h
//  LivePaperSDK
//
//  Created by Alejandro Mendez on 1/3/17.
//  Copyright © 2017 Hewlett-Packard. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <LivePaperSDK/LivePaperSDK.h>
#import <OHHTTPStubs/OHHTTPStubs.h>
#import <OHHTTPStubs/OHPathHelpers.h>

@interface LPSession (LPTests)
@property (nonatomic, readonly) NSURL *baseURL;
@end


@interface LPBaseNetworkingTestCase : XCTestCase
@property (nonatomic) LPSession *session;
@end
