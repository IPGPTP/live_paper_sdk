//
//  LPLinkTests.m
//  LivePaperSDK
//
//  Created by Alejandro Mendez on 01/12/17.
//  Copyright © 2015 Hewlett-Packard. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "LPBaseTestCase.h"

@interface LPLinkTests : LPBaseTestCase
@end

@implementation LPLinkTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testCreateLink {
    
    __block NSDictionary *entityDict = [HPMockHelper mockLinkCreateWithProjectId:self.projectId testRequestDataBlock:^(NSURLRequest *request) {
        NSDictionary *requestDictionary = [NSJSONSerialization JSONObjectWithData:request.OHHTTPStubs_HTTPBody options:0 error:nil];
        XCTAssertEqualObjects(requestDictionary[[self entityName]][@"name"], entityDict[@"name"]);
        XCTAssertEqualObjects(requestDictionary[[self entityName]][@"triggerId"], entityDict[@"triggerId"]);
        XCTAssertEqualObjects(requestDictionary[[self entityName]][@"payoffId"], entityDict[@"payoffId"]);
    }];
    
    XCTestExpectation * expect = [self expectationWithDescription:@"wait"];
    [LPLink createWithName:entityDict[@"name"] triggerId:entityDict[@"triggerId"] payoffId:entityDict[@"payoffId"] projectId:self.projectId session:self.session completion:^(LPLink *link, NSError *error) {
        [self verifyEntity:link entityDictionary:entityDict];
        [expect fulfill];
    }];
    [self waitForExpectationsWithTimeout:2.0 handler:nil];
}

- (void)testListLinks {
    
    NSString *jsonFile = [NSString stringWithFormat:@"%@_list.json", [self entityName]];
    NSString *path = OHPathForFile(jsonFile,self.class);
    NSArray *entityArray = [NSJSONSerialization JSONObjectWithData:[[NSData alloc] initWithContentsOfFile:path] options:0 error:nil][[self pluralEntityName]];
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.absoluteString containsString:[NSString stringWithFormat:@"api/v2/projects/%@/%@",self.projectId, [self pluralEntityName]]];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithFileAtPath:OHPathForFile(jsonFile,self.class)
                                                statusCode:200 headers:@{@"Content-Type":@"application/json"}];
    }];
    
    XCTestExpectation * expect = [self expectationWithDescription:@"wait"];
    [LPLink list:self.session projectId:self.projectId completion:^(NSArray<LPLink *> *links, NSError *error) {
        XCTAssertEqual(links.count, entityArray.count);
        for (LPLink *link in links) {
            NSDictionary *entity = [entityArray objectAtIndex:[links indexOfObject:link]];
            [self verifyEntity:link entityDictionary:entity];
        }
        [expect fulfill];
    }];
    [self waitForExpectationsWithTimeout:2.0 handler:nil];
}

- (void)testGetLink {
    
    NSString *jsonFile = [NSString stringWithFormat:@"%@_get.json", [self entityName]];
    NSString *path = OHPathForFile(jsonFile,self.class);
    NSDictionary *entityDict = [NSJSONSerialization JSONObjectWithData:[[NSData alloc] initWithContentsOfFile:path] options:0 error:nil][[self entityName]];
    NSString *entityId = entityDict[@"id"];
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.absoluteString containsString:[NSString stringWithFormat:@"api/v2/projects/%@/%@",self.projectId, [self pluralEntityName]]];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithFileAtPath:OHPathForFile(jsonFile,self.class)
                                                statusCode:200 headers:@{@"Content-Type":@"application/json"}];
    }];
    
    XCTestExpectation * expect = [self expectationWithDescription:@"wait"];
    [LPLink get:entityId projectId:self.projectId session:self.session completion:^(LPLink *link, NSError *error) {
        [self verifyEntity:link entityDictionary:entityDict];
        [expect fulfill];
    }];
    [self waitForExpectationsWithTimeout:2.0 handler:nil];
}

- (void)testUpdateLink {
    
    NSString *newName = @"some name";
    
    NSString *jsonFile = [NSString stringWithFormat:@"%@_get.json", [self entityName]];
    NSString *path = OHPathForFile(jsonFile,self.class);
    
    NSDictionary *entityDict = [NSJSONSerialization JSONObjectWithData:[[NSData alloc] initWithContentsOfFile:path] options:0 error:nil][[self entityName]];
    NSMutableDictionary *modifiedEntityDict = entityDict.mutableCopy;
    modifiedEntityDict[@"name"] = @"my new name";
    NSString *entityId = entityDict[@"id"];
    
    XCTestExpectation * expectRequest = [self expectationWithDescription:@"expectRequest"];
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.absoluteString containsString:[NSString stringWithFormat:@"api/v2/projects/%@/%@",self.projectId, [self pluralEntityName]]]
        && [request.HTTPMethod isEqualToString:@"GET"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithFileAtPath:OHPathForFile(jsonFile, self.class)
                                                statusCode:200 headers:@{@"Content-Type":@"application/json"}];
    }];
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.absoluteString containsString:[NSString stringWithFormat:@"api/v2/projects/%@/%@",self.projectId, [self pluralEntityName]]]
        && [request.HTTPMethod isEqualToString:@"PUT"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        XCTAssertEqualObjects(request.HTTPMethod, @"PUT");
        NSDictionary *requestDictionary = [NSJSONSerialization JSONObjectWithData:request.OHHTTPStubs_HTTPBody options:0 error:nil];
        XCTAssertEqualObjects(requestDictionary[[self entityName]][@"name"], newName);
        [expectRequest fulfill];
        return [OHHTTPStubsResponse responseWithData:[@"" dataUsingEncoding:NSUTF8StringEncoding] statusCode:200 headers:@{}];
    }];
    
    XCTestExpectation * expect = [self expectationWithDescription:@"wait"];
    
    [LPLink get:entityId projectId:self.projectId session:self.session completion:^(LPLink *link, NSError *error) {
        link.name = newName;
        [link update:^(NSError *error) {
           [expect fulfill];
        }];
    }];
    [self waitForExpectationsWithTimeout:2.0 handler:nil];
}


- (void)testDeleteLink {
    
    NSString *jsonFile = [NSString stringWithFormat:@"%@_get.json", [self entityName]];
    NSString *path = OHPathForFile(jsonFile,self.class);
    NSDictionary *entityDict = [NSJSONSerialization JSONObjectWithData:[[NSData alloc] initWithContentsOfFile:path] options:0 error:nil][[self entityName]];
    NSString *entityId = entityDict[@"id"];
    
    XCTestExpectation * expectRequest = [self expectationWithDescription:@"expectRequest"];
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.absoluteString containsString:[NSString stringWithFormat:@"api/v2/projects/%@/%@",self.projectId, [self pluralEntityName]]]
        && [request.HTTPMethod isEqualToString:@"GET"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithFileAtPath:OHPathForFile(jsonFile, self.class)
                                                statusCode:200 headers:@{@"Content-Type":@"application/json"}];
    }];
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.absoluteString containsString:[NSString stringWithFormat:@"api/v2/projects/%@/%@",self.projectId, [self pluralEntityName]]]
        && [request.HTTPMethod isEqualToString:@"DELETE"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        XCTAssertEqualObjects(request.HTTPMethod, @"DELETE");
        [expectRequest fulfill];
        return [OHHTTPStubsResponse responseWithData:[@"" dataUsingEncoding:NSUTF8StringEncoding] statusCode:201 headers:@{}];
    }];
    
    XCTestExpectation * expect = [self expectationWithDescription:@"wait"];
    [LPLink get:entityId projectId:self.projectId session:self.session completion:^(LPLink *link, NSError *error) {
        [link delete:^(NSError *error) {
            [expect fulfill];
        }];
    }];
    [self waitForExpectationsWithTimeout:2.0 handler:nil];
}

#pragma mark Helper methods

- (NSString *)entityName {
    return @"link";
}

- (void)verifyEntity:(LPLink *)link entityDictionary:(NSDictionary *)entity {
    XCTAssertEqualObjects(link.identifier, entity[@"id"]);
    XCTAssertEqualObjects(link.name, entity[@"name"]);
    XCTAssertEqualObjects(link.payoffId, entity[@"payoffId"]);
    XCTAssertEqualObjects(link.triggerId, entity[@"triggerId"]);
}


@end
