//
//  HPMockHelper.m
//  LivePaperSDK
//
//  Created by Alejandro Mendez on 2/10/17.
//  Copyright © 2017 Hewlett-Packard. All rights reserved.
//

#import "HPMockHelper.h"
#import "HPTestData.h"
#import <XCTest/XCTest.h>
#import <OHHTTPStubs/OHHTTPStubs.h>
#import <OHHTTPStubs/OHPathHelpers.h>
#import <OHHTTPStubs/NSURLRequest+HTTPBodyTesting.h>


@implementation HPMockHelper

+ (NSString *)mockImageUpload {
    NSString *imageLocation = @"https://stage.storage.livepaperapi.com/objects/v2/projects/0xkbvb/files/ulkFXYyuSZentV0JVMgh9w";
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.absoluteString containsString:@"storage.livepaper"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithData:[@"" dataUsingEncoding:NSUTF8StringEncoding] statusCode:201 headers:@{@"Location":imageLocation}];
    }];
    return imageLocation;
}

+ (void)mockImageDownload:(NSString *)urlString {
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.absoluteString containsString:urlString];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        NSData *imageData = [NSData dataWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"forest" ofType:@"jpg"]];
        return [OHHTTPStubsResponse responseWithData:imageData statusCode:200 headers:@{}];
    }];
}

+ (void)mockGetDefaultProject:(NSString *)defaultProject {
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.absoluteString containsString:@"v2/validate"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithData:[@"" dataUsingEncoding:NSUTF8StringEncoding] statusCode:201 headers:@{@"Project-Id":defaultProject}];
    }];
}

+ (NSDictionary *)mockPayoffCreate:(LPPayoffType)type project:(NSString *)projectId testRequestDataBlock:(void (^)(NSURLRequest *request))block{
    NSString *entityName = @"payoff";
    NSString *jsonFile;
    switch (type) {
        case LPPayoffTypeUrl:
            jsonFile = [NSString stringWithFormat:@"%@_get_url.json", entityName];
            break;
        case LPPayoffTypeRich:
            jsonFile = [NSString stringWithFormat:@"%@_get_rich.json", entityName];
            break;
        default:
            break;
    }
    
    NSString *path = OHPathForFile(jsonFile,self.class);
    NSDictionary *entityDict = [NSJSONSerialization JSONObjectWithData:[[NSData alloc] initWithContentsOfFile:path] options:0 error:nil][@"payoff"];    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.absoluteString containsString:[NSString stringWithFormat:@"api/v2/projects/%@/%@",projectId, [self pluralEntityName:entityName]]] && [request.HTTPMethod isEqualToString:@"POST"];;
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        if (block) {
            block(request);
        }
        return [OHHTTPStubsResponse responseWithFileAtPath:OHPathForFile(jsonFile,self.class)
                                                statusCode:200 headers:@{@"Content-Type":@"application/json"}];
    }];
    return entityDict;
}

+ (NSDictionary *)mockTriggerCreate:(LPTriggerType)type project:(NSString *)projectId testRequestDataBlock:(void (^)(NSURLRequest *request))block{
    NSString *entityName = @"trigger";
    NSString *jsonFile;
    switch (type) {
        case LPTriggerTypeWatermark:
            jsonFile = [NSString stringWithFormat:@"%@_get_wm.json", entityName];
            break;
        case LPTriggerTypeQrCode:
            jsonFile = [NSString stringWithFormat:@"%@_get_qr.json", entityName];
            break;
        case LPTriggerTypeShortUrl:
            jsonFile = [NSString stringWithFormat:@"%@_get_short.json", entityName];
            break;
        default:
            break;
    }
    NSString *path = OHPathForFile(jsonFile,self.class);
    NSDictionary *entityDict = [NSJSONSerialization JSONObjectWithData:[[NSData alloc] initWithContentsOfFile:path] options:0 error:nil][entityName];
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.absoluteString containsString:[NSString stringWithFormat:@"api/v2/projects/%@/%@",projectId, [self pluralEntityName:entityName]]] && [request.HTTPMethod isEqualToString:@"POST"];;
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        if (block) {
            block(request);
        }
        return [OHHTTPStubsResponse responseWithFileAtPath:OHPathForFile(jsonFile,self.class)
                                                statusCode:200 headers:@{@"Content-Type":@"application/json"}];
    }];
    return entityDict;
}

+ (NSDictionary *)mockLinkCreateWithProjectId:(NSString *)projectId testRequestDataBlock:(void (^)(NSURLRequest *request))block {
    NSString *entityName = @"link";
    NSString *jsonFile = [NSString stringWithFormat:@"%@_get.json", entityName];
    NSString *path = OHPathForFile(jsonFile,self.class);
    NSDictionary *entityDict = [NSJSONSerialization JSONObjectWithData:[[NSData alloc] initWithContentsOfFile:path] options:0 error:nil][entityName];
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.absoluteString containsString:[NSString stringWithFormat:@"api/v2/projects/%@/%@",projectId, [self pluralEntityName:entityName]]] && [request.HTTPMethod isEqualToString:@"POST"];;
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        if (block) {
            block(request);
        }        
        return [OHHTTPStubsResponse responseWithFileAtPath:OHPathForFile(jsonFile,self.class)
                                                statusCode:200 headers:@{@"Content-Type":@"application/json"}];
    }];
    return entityDict;
}


+ (void)mockQrCodeWithProjectId:(NSString *)projectId entityId:(NSString *)entityId testRequestDataBlock:(void (^)(NSURLRequest *request))block {
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.absoluteString containsString:[NSString stringWithFormat:@"api/v2/projects/%@/triggers/%@/download", projectId, entityId]]
        && [request.HTTPMethod isEqualToString:@"GET"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        if (block) {
            block(request);
        }
        return [OHHTTPStubsResponse responseWithData:[HPTestData getQrCodeImageData] statusCode:201 headers:@{}];
    }];
}

+ (void)mockWatermarkingWithProjectId:(NSString *)projectId entityId:(NSString *)entityId testRequestDataBlock:(void (^)(NSURLRequest *request))block {
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.absoluteString containsString:[NSString stringWithFormat:@"watermark.livepaperapi.com/watermark/v2/projects/%@/triggers/%@",projectId, entityId]]
        && [request.HTTPMethod isEqualToString:@"GET"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        if (block) {
            block(request);
        }
        return [OHHTTPStubsResponse responseWithData:[HPTestData getWatemarkedImageData] statusCode:201 headers:@{}];
    }];
}

+ (NSString *)pluralEntityName:(NSString *)entityName {
    return [NSString stringWithFormat:@"%@s",entityName];
}


@end
