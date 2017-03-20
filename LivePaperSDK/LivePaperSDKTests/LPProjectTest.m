//
//  LPProjectTest.m
//  LivePaperSDK
//
//  Created by Alejandro Mendez on 2/6/17.
//  Copyright © 2017 Hewlett-Packard. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "LPBaseTestCase.h"

@interface LPProjectTest : LPBaseTestCase

@end

@implementation LPProjectTest

- (void)setUp {
    [super setUp];
    
}

- (void)tearDown {
    [super tearDown];
}

- (void)testCreateProject {
    
    NSDictionary *projectDict = [self mockCreateProject];
    [self mockGetUser];
    
    XCTestExpectation * expect = [self expectationWithDescription:@"wait"];
    [LPProject createWithName:projectDict[@"name"] session:self.session completion:^(LPProject * _Nullable project, NSError * _Nullable error) {
        [self verifyProject:project entityDictionary:projectDict];
        [expect fulfill];
    }];
    [self waitForExpectationsWithTimeout:2.0 handler:nil];
}


- (void)testListProjects {
    
    NSString *path = OHPathForFile(@"project_list.json",self.class);
    NSArray *projectList = [NSJSONSerialization JSONObjectWithData:[[NSData alloc] initWithContentsOfFile:path] options:0 error:nil][@"projects"];
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.absoluteString containsString:@"api/v2/projects"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithFileAtPath:OHPathForFile(@"project_list.json",self.class)
                                                statusCode:200 headers:@{@"Content-Type":@"application/json"}];
    }];
    
    
    XCTestExpectation * expect = [self expectationWithDescription:@"wait"];
    [LPProject list:self.session completion:^(NSArray<LPProject *> * _Nullable projects, NSError * _Nullable error) {
        XCTAssertEqual(projects.count, projectList.count);
        for (LPProject *project in projects) {
            NSDictionary *projectDict = [projectList objectAtIndex:[projects indexOfObject:project]];
            [self verifyProject:project entityDictionary:projectDict];
        }
        [expect fulfill];
    }];
    [self waitForExpectationsWithTimeout:2.0 handler:nil];
}

- (void)testGetProject {
    
    NSDictionary *projectDict = [self mockGetProject];
    NSString *projectId = projectDict[@"id"];
    
    
    XCTestExpectation * expect = [self expectationWithDescription:@"wait"];
    [LPProject get:projectId session:self.session completion:^(LPProject * _Nullable project, NSError * _Nullable error) {
        [self verifyProject:project entityDictionary:projectDict];
        [expect fulfill];
    }];
    [self waitForExpectationsWithTimeout:2.0 handler:nil];
}

- (void)testUpdateProject {
    
    NSString *newName = @"some name";
    
    NSString *path = OHPathForFile(@"project_get.json",self.class);
    NSDictionary *projectDict = [NSJSONSerialization JSONObjectWithData:[[NSData alloc] initWithContentsOfFile:path] options:0 error:nil][@"project"];
    NSMutableDictionary *modifiedProjectDict = projectDict.mutableCopy;
    modifiedProjectDict[@"name"] = @"my new name";
    NSString *projectId = projectDict[@"id"];
    
    XCTestExpectation * expectRequest = [self expectationWithDescription:@"expectRequest"];
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.absoluteString containsString:[NSString stringWithFormat:@"api/v2/projects/%@",projectId]]
        && [request.HTTPMethod isEqualToString:@"GET"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithFileAtPath:OHPathForFile(@"project_get.json",self.class)
                                                statusCode:200 headers:@{@"Content-Type":@"application/json"}];
    }];
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.absoluteString containsString:[NSString stringWithFormat:@"api/v2/projects/%@",projectId]]
        && [request.HTTPMethod isEqualToString:@"PUT"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        XCTAssertEqualObjects(request.HTTPMethod, @"PUT");
        NSDictionary *requestDictionary = [NSJSONSerialization JSONObjectWithData:request.OHHTTPStubs_HTTPBody options:0 error:nil];
        XCTAssertEqualObjects(requestDictionary[@"project"][@"name"], newName);
        [expectRequest fulfill];
        return [OHHTTPStubsResponse responseWithData:[@"" dataUsingEncoding:NSUTF8StringEncoding] statusCode:200 headers:@{}];
    }];
    
    XCTestExpectation * expect = [self expectationWithDescription:@"wait"];
    
    [LPProject get:projectId session:self.session completion:^(LPProject * _Nullable project, NSError * _Nullable error) {
        project.name = newName;
        [project update:^(NSError * _Nullable error) {
            
            [expect fulfill];
        }];
    }];
    [self waitForExpectationsWithTimeout:2.0 handler:nil];
}

- (void)testDeleteProject {
    
    NSString *path = OHPathForFile(@"project_get.json",self.class);
    NSDictionary *projectDict = [NSJSONSerialization JSONObjectWithData:[[NSData alloc] initWithContentsOfFile:path] options:0 error:nil][@"project"];
    NSString *projectId = projectDict[@"id"];
    
    XCTestExpectation * expectRequest = [self expectationWithDescription:@"expectRequest"];
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.absoluteString containsString:[NSString stringWithFormat:@"api/v2/projects/%@",projectId]]
            && [request.HTTPMethod isEqualToString:@"GET"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithFileAtPath:OHPathForFile(@"project_get.json",self.class)
                                                statusCode:200 headers:@{@"Content-Type":@"application/json"}];
    }];
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.absoluteString containsString:[NSString stringWithFormat:@"api/v2/projects/%@",projectId]]
            && [request.HTTPMethod isEqualToString:@"DELETE"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        XCTAssertEqualObjects(request.HTTPMethod, @"DELETE");
        [expectRequest fulfill];
        return [OHHTTPStubsResponse responseWithData:[@"" dataUsingEncoding:NSUTF8StringEncoding] statusCode:201 headers:@{}];
    }];
    
    XCTestExpectation * expect = [self expectationWithDescription:@"wait"];
    [LPProject get:projectId session:self.session completion:^(LPProject * _Nullable project, NSError * _Nullable error) {
       [project delete:^(NSError * _Nullable error) {
           [expect fulfill];
       }];
    }];
    [self waitForExpectationsWithTimeout:2.0 handler:nil];
}

- (void)testUploadingImages {
    
    NSString *imageLocation = [HPMockHelper mockImageUpload];
    XCTestExpectation * expect = [self expectationWithDescription:@"wait"];
    [LPProject uploadImageFile:[HPTestData getImageData] projectId:@"0xkbvb" session:self.session progress:nil completion:^(NSURL *url, NSError *error) {
        XCTAssertEqualObjects(url.absoluteString, imageLocation);
        [expect fulfill];
    }];
    [self waitForExpectationsWithTimeout:2.0 handler:nil];
}

- (void)testGettingDefaultProject {
    
    [HPMockHelper mockGetDefaultProject:self.projectId];
    
    XCTestExpectation * expect = [self expectationWithDescription:@"wait"];
    [LPProject getDefaultProjectIdWithSession:self.session completion:^(NSString * _Nullable projectId, NSError * _Nullable error) {
        XCTAssertNotNil(projectId);
        XCTAssertEqualObjects(projectId, self.projectId);
        [expect fulfill];
    }];
    [self waitForExpectationsWithTimeout:2.0 handler:nil];
}

#pragma mark Helper methods

- (void)verifyProject:(LPProject *)project entityDictionary:(NSDictionary *)entityDict {
    XCTAssertEqualObjects(project.identifier, entityDict[@"id"]);
    XCTAssertEqualObjects(project.name, entityDict[@"name"]);
    XCTAssertEqualObjects(project.dateCreated, entityDict[@"dateCreated"]);
    XCTAssertEqualObjects(project.dateModified, entityDict[@"dateModified"]);
    XCTAssertEqualObjects(project.accountId, entityDict[@"accountId"]);
    XCTAssertEqualObjects(project.creatorEmail, entityDict[@"createdBy"][@"emailId"]);
}

- (NSDictionary *)mockGetProject {
    NSString *path = OHPathForFile(@"project_get.json",self.class);
    NSDictionary *projectDict = [NSJSONSerialization JSONObjectWithData:[[NSData alloc] initWithContentsOfFile:path] options:0 error:nil][@"project"];
    NSString *projectId = projectDict[@"id"];
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.absoluteString containsString:[NSString stringWithFormat:@"api/v2/projects/%@",projectId]] &&
        [request.HTTPMethod isEqualToString:@"GET"];;
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithFileAtPath:OHPathForFile(@"project_get.json",self.class)
                                                statusCode:200 headers:@{@"Content-Type":@"application/json"}];
    }];
    return projectDict;
}

- (NSDictionary *)mockCreateProject {
    NSString *path = OHPathForFile(@"project_get.json",self.class);
    NSDictionary *projectDict = [NSJSONSerialization JSONObjectWithData:[[NSData alloc] initWithContentsOfFile:path] options:0 error:nil][@"project"];
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.absoluteString containsString:@"api/v2/projects"] &&
        [request.HTTPMethod isEqualToString:@"POST"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithFileAtPath:OHPathForFile(@"project_get.json",self.class)
                                                statusCode:200 headers:@{@"Content-Type":@"application/json"}];
    }];
    return projectDict;
}

- (void)mockGetUser {
    NSString *path = OHPathForFile(@"user_get.json",self.class);
    NSDictionary *userDict = [NSJSONSerialization JSONObjectWithData:[[NSData alloc] initWithContentsOfFile:path] options:0 error:nil][@"user"];
    NSString *userId = userDict[@"clientId"];
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.absoluteString containsString:[NSString stringWithFormat:@"auth/v2/users/%@",userId]];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithFileAtPath:OHPathForFile(@"user_get.json",self.class)
                                                statusCode:200 headers:@{@"Content-Type":@"application/json"}];
    }];
}

@end
