//
//  LPTests.m
//  LivePaperSDK
//
//  Created by Alejandro Mendez on 01/12/17.
//  Copyright © 2015 Hewlett-Packard. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "LPBaseTestCase.h"
#import "HPTestData.h"

@interface LPPayoffTests : LPBaseTestCase

@property (nonatomic) NSDictionary *entityDict;
@property (nonatomic) NSString *entityId;

@end

@implementation LPPayoffTests

- (void)setUp {
    [super setUp];    
}

- (void)tearDown {
    [super tearDown];
}

- (void)testCreateWebPayoff {
    
    __block NSDictionary *entityDict = [HPMockHelper mockPayoffCreate:LPPayoffTypeUrl project:self.projectId testRequestDataBlock:^(NSURLRequest *request) {
        NSDictionary *requestDictionary = [NSJSONSerialization JSONObjectWithData:request.OHHTTPStubs_HTTPBody options:0 error:nil];
        XCTAssertEqualObjects(requestDictionary[[self entityName]][@"name"], entityDict[@"name"]);
        XCTAssertEqualObjects(requestDictionary[[self entityName]][@"type"], entityDict[@"type"]);
        XCTAssertEqualObjects(requestDictionary[[self entityName]][@"url"], entityDict[@"url"]);
    }];
    
    XCTestExpectation * expectation = [self expectationWithDescription:@"wait"];
    [LPPayoff createWebPayoffWithName:entityDict[@"name"] url:[NSURL URLWithString:entityDict[@"url"]] projectId:self.projectId session:self.session completion:^(LPPayoff *payoff, NSError *error) {
        XCTAssertNotNil(payoff);
        [self verifyEntity:payoff entityDictionary:entityDict];
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:2.0 handler:nil];
}


- (void)testCreateRichPayoff {
    
    __block NSDictionary *richPayoff;
    __block NSDictionary *entityDict = [HPMockHelper mockPayoffCreate:LPPayoffTypeRich project:self.projectId testRequestDataBlock:^(NSURLRequest *request) {
        NSDictionary *requestDictionary = [NSJSONSerialization JSONObjectWithData:request.OHHTTPStubs_HTTPBody options:0 error:nil];
        XCTAssertEqualObjects(requestDictionary[[self entityName]][@"name"], entityDict[@"name"]);
        XCTAssertEqualObjects(requestDictionary[[self entityName]][@"type"], entityDict[@"type"]);
        XCTAssertEqualObjects(requestDictionary[[self entityName]][@"richPayoff"], richPayoff);
    }];
    
    NSDictionary *richData = [self richPayoffFromEncodedString:entityDict[@"richPayoff"][@"private"][@"data"]];
    NSString *publicUrl = entityDict[@"richPayoff"][@"public"][@"url"];
    NSString *name = entityDict[@"name"];
    richPayoff = [self richPayoffStructureWithData:richData publicUrl:publicUrl];
    
    
    XCTestExpectation * expectation = [self expectationWithDescription:@"wait"];
    [LPPayoff createRichPayoffWithName:name publicURL:[NSURL URLWithString:publicUrl] richPayoffData:richData projectId:self.projectId session:self.session completion:^(LPPayoff *payoff, NSError *error) {
        XCTAssertNotNil(payoff);
        [self verifyEntity:payoff entityDictionary:entityDict];
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:2.0 handler:nil];
    
}


- (void)testPayoffLinks {
    
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
    [LPPayoff list:self.session projectId:self.projectId completion:^(NSArray<LPPayoff *> *payoffs, NSError *error) {
        XCTAssertEqual(payoffs.count, entityArray.count);
        for (LPPayoff *payoff in payoffs) {
            NSDictionary *entityDict = [entityArray objectAtIndex:[payoffs indexOfObject:payoff]];
            [self verifyEntity:payoff entityDictionary:entityDict];
        }
        [expect fulfill];
    }];
    [self waitForExpectationsWithTimeout:2.0 handler:nil];
}

- (void)testGetPayoff {
    [self mockPayoffGet:LPPayoffTypeUrl];
    XCTestExpectation * expect = [self expectationWithDescription:@"wait"];
    [LPPayoff get:self.entityId projectId:self.projectId session:self.session completion:^(LPPayoff *payoff, NSError *error) {
        [self verifyEntity:payoff entityDictionary:self.entityDict];
        [expect fulfill];
    }];
    [self waitForExpectationsWithTimeout:2.0 handler:nil];
}

- (void)testUpdateRichPayoff {
    [self mockPayoffGet:LPPayoffTypeRich];
    NSString *newName = @"some name";
    NSString *newUrl = @"http://www.apple.com";
    
    NSDictionary *newRichData = [self sampleRichData];
    NSDictionary *richPayoff = [self richPayoffStructureWithData:newRichData publicUrl:newUrl];
    
    NSMutableDictionary *modifiedEntityDict = self.entityDict.mutableCopy;
    modifiedEntityDict[@"name"] = newName;
    modifiedEntityDict[@"richPayoff"] = richPayoff;
    NSString *entityId = self.entityDict[@"id"];
    
    XCTestExpectation * expectRequest = [self expectationWithDescription:@"expectRequest"];
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.absoluteString containsString:[NSString stringWithFormat:@"api/v2/projects/%@/%@",self.projectId, [self pluralEntityName]]]
        && [request.HTTPMethod isEqualToString:@"PUT"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        XCTAssertEqualObjects(request.HTTPMethod, @"PUT");
        NSDictionary *requestDictionary = [NSJSONSerialization JSONObjectWithData:request.OHHTTPStubs_HTTPBody options:0 error:nil];
        XCTAssertEqualObjects(requestDictionary[[self entityName]][@"name"], newName);
        XCTAssertEqualObjects(requestDictionary[[self entityName]][@"richPayoff"], richPayoff);
        [expectRequest fulfill];
        return [OHHTTPStubsResponse responseWithData:[@"" dataUsingEncoding:NSUTF8StringEncoding] statusCode:200 headers:@{}];
    }];
    
    XCTestExpectation * expect = [self expectationWithDescription:@"wait"];
    
    [LPPayoff get:entityId projectId:self.projectId session:self.session completion:^(LPPayoff *payoff, NSError *error) {
        payoff.name = newName;
        payoff.richPayoffData = newRichData;
        payoff.richPayoffPublicUrl = [NSURL URLWithString:newUrl];
        [payoff update:^(NSError *error) {
            [expect fulfill];
        }];
    }];
    [self waitForExpectationsWithTimeout:2.0 handler:nil];
}

- (void)testUpdateUrlPayoff {
    [self mockPayoffGet:LPPayoffTypeUrl];
    NSString *newName = @"some name";
    NSString *newUrl = @"http://www.apple.com";
    
    NSMutableDictionary *modifiedEntityDict = self.entityDict.mutableCopy;
    modifiedEntityDict[@"name"] = newName;
    modifiedEntityDict[@"url"] = newUrl;
    NSString *entityId = self.entityDict[@"id"];
    
    XCTestExpectation * expectRequest = [self expectationWithDescription:@"expectRequest"];
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.absoluteString containsString:[NSString stringWithFormat:@"api/v2/projects/%@/%@",self.projectId, [self pluralEntityName]]]
        && [request.HTTPMethod isEqualToString:@"PUT"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        XCTAssertEqualObjects(request.HTTPMethod, @"PUT");
        NSDictionary *requestDictionary = [NSJSONSerialization JSONObjectWithData:request.OHHTTPStubs_HTTPBody options:0 error:nil];
        XCTAssertEqualObjects(requestDictionary[[self entityName]][@"name"], newName);
        XCTAssertEqualObjects(requestDictionary[[self entityName]][@"url"], newUrl);
        [expectRequest fulfill];
        return [OHHTTPStubsResponse responseWithData:[@"" dataUsingEncoding:NSUTF8StringEncoding] statusCode:200 headers:@{}];
    }];
    
    XCTestExpectation * expect = [self expectationWithDescription:@"wait"];
    
    [LPPayoff get:entityId projectId:self.projectId session:self.session completion:^(LPPayoff *payoff, NSError *error) {
        payoff.name = newName;
        payoff.url = [NSURL URLWithString:newUrl];
        [payoff update:^(NSError *error) {
            [expect fulfill];
        }];
    }];
    [self waitForExpectationsWithTimeout:2.0 handler:nil];
}


- (void)testDeleteTrigger {
    [self mockPayoffGet:LPPayoffTypeUrl];
    XCTestExpectation * expectRequest = [self expectationWithDescription:@"expectRequest"];
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.absoluteString containsString:[NSString stringWithFormat:@"api/v2/projects/%@/%@",self.projectId, [self pluralEntityName]]]
        && [request.HTTPMethod isEqualToString:@"DELETE"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        XCTAssertEqualObjects(request.HTTPMethod, @"DELETE");
        [expectRequest fulfill];
        return [OHHTTPStubsResponse responseWithData:[@"" dataUsingEncoding:NSUTF8StringEncoding] statusCode:201 headers:@{}];
    }];
    
    XCTestExpectation * expect = [self expectationWithDescription:@"wait"];
    [LPPayoff get:self.entityId projectId:self.projectId session:self.session completion:^(LPPayoff *payoff, NSError *error) {
        [payoff delete:^(NSError *error) {
            [expect fulfill];
        }];
    }];
    [self waitForExpectationsWithTimeout:2.0 handler:nil];
}

#pragma mark Helper methods

- (NSString *)entityName {
    return @"payoff";
}

- (NSDictionary *)sampleRichData {
    return  @{
                 @"type":@"content action layout",
                 @"version":@(1),
                 @"data":@{
                         @"content":@{
                                 @"type":@"image",
                                 @"label":@"Movember!",
                                 @"data":@{
                                         @"URL": @"http://static.movember.com/uploads/2014/profiles/ef4/ef48a53fb031669fe86e741164d56972-546b9b5c56e15-hero.jpg"}
                                 },
                         @"actions":@[
                                 @{
                                     @"type":@"webpage",
                                     @"label":@"Donate!",
                                     @"icon":@{@"id":@"533"},
                                     @"data":@{@"URL":@"http://MOBRO.CO/oamike"}
                                     },
                                 @{
                                     @"type":@"share",
                                     @"label":@"Share!",
                                     @"icon":@{@"id":@"527"},
                                     @"data":@{@"URL":@"Help Mike get the prize of most donations on his team! MOBRO.CO/oamike"}
                                     }
                                 ]
                         }
                 };
}

- (NSDictionary *)richPayoffStructureWithData:(NSDictionary *)richPayoffData publicUrl:(NSString *)url {
    NSString *base64EncodedRichPayoffData = [[NSJSONSerialization dataWithJSONObject:richPayoffData options:0 error:nil] base64EncodedStringWithOptions:0];
    return  @{
             @"version" : @"1.0",
             @"private" : @{
                     @"content-type" : @"custom-base64",
                     @"data" : base64EncodedRichPayoffData
                     },
             @"public" : @{
                     @"url" : url
                     },
             @"type" : @"content action layout"
             };
}

- (NSDictionary *)richPayoffFromEncodedString:(NSString *)encodedString {
    NSData *data = [[NSData alloc] initWithBase64EncodedString:encodedString options:NSDataBase64DecodingIgnoreUnknownCharacters];
    NSError *jsonError = nil;
    return [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
}

- (void)verifyEntity:(LPPayoff *)payoff entityDictionary:(NSDictionary *)entity{
    
    XCTAssertEqualObjects(payoff.identifier, entity[@"id"]);
    XCTAssertEqualObjects(payoff.name, entity[@"name"]);
    if ([entity[@"type"] isEqualToString:@"url"]) {
        XCTAssertEqual(payoff.type, LPPayoffTypeUrl);
        XCTAssertEqualObjects(payoff.url.absoluteString, entity[@"url"]);
    }else if ([entity[@"type"] isEqualToString:@"richpayoff"]) {
        XCTAssertEqual(payoff.type, LPPayoffTypeRich);
        NSDictionary *richPayoff = entity[@"richPayoff"];
        NSDictionary *private = richPayoff[@"private"];
        NSDictionary *public = richPayoff[@"public"];
        NSURL *publicURL = [NSURL URLWithString:[public objectForKey:@"url"]];
        XCTAssertEqualObjects(payoff.richPayoffPublicUrl, publicURL);
        NSDictionary *richData = [self richPayoffFromEncodedString:[private objectForKey:@"data"]];
        XCTAssertEqualObjects(payoff.richPayoffData, richData);
    }else{
        XCTFail("Trigger type not found");
    }
}

- (void)mockPayoffGet:(LPPayoffType)type {
    NSString *jsonFile;
    switch (type) {
        case LPPayoffTypeUrl:
            jsonFile = [NSString stringWithFormat:@"%@_get_url.json", [self entityName]];
            break;
        case LPPayoffTypeRich:
            jsonFile = [NSString stringWithFormat:@"%@_get_rich.json", [self entityName]];
            break;
        default:
            jsonFile = [NSString stringWithFormat:@"%@_get_url.json", [self entityName]];
            break;
    }
    NSString *path = OHPathForFile(jsonFile,self.class);
    self.entityDict = [NSJSONSerialization JSONObjectWithData:[[NSData alloc] initWithContentsOfFile:path] options:0 error:nil][[self entityName]];
    self.entityId = self.entityDict[@"id"];
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.absoluteString containsString:[NSString stringWithFormat:@"api/v2/projects/%@/%@",self.projectId, [self pluralEntityName]]] && [request.HTTPMethod isEqualToString:@"GET"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithFileAtPath:OHPathForFile(jsonFile,self.class)
                                                statusCode:200 headers:@{@"Content-Type":@"application/json"}];
    }];
}


@end
