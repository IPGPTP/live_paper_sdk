//
//  LPProjectTests.m
//  LivePaperSDK
//
//  Created by Alejandro Mendez on 2/8/17.
//  Copyright © 2017 Hewlett-Packard. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "LPBaseTestCase.h"

@interface LPSessionTests : LPBaseTestCase

@end

@implementation LPSessionTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testCreateShortUrl {
    [HPMockHelper mockGetDefaultProject:self.projectId];
    NSDictionary *triggerEntityDict = [HPMockHelper mockTriggerCreate:LPTriggerTypeShortUrl project:self.projectId testRequestDataBlock:nil];
    [HPMockHelper mockPayoffCreate:LPPayoffTypeUrl project:self.projectId testRequestDataBlock:nil];
    [HPMockHelper mockLinkCreateWithProjectId:self.projectId testRequestDataBlock:nil];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"wait"];
    [self.session createShortUrl:@"my short url" destination:[NSURL URLWithString:@"http://www.apple.com"] completion:^(NSURL *shortUrl, NSError *error) {
        XCTAssertEqualObjects(triggerEntityDict[@"uid"], shortUrl.absoluteString);
        XCTAssertNotNil(shortUrl);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:2.0 handler:nil];
}


- (void)testCreateQrCode {
    [HPMockHelper mockGetDefaultProject:self.projectId];
    NSDictionary *triggerEntityDict = [HPMockHelper mockTriggerCreate:LPTriggerTypeQrCode project:self.projectId testRequestDataBlock:nil];
    [HPMockHelper mockPayoffCreate:LPPayoffTypeUrl project:self.projectId testRequestDataBlock:nil];
    [HPMockHelper mockLinkCreateWithProjectId:self.projectId testRequestDataBlock:nil];
    [HPMockHelper mockQrCodeWithProjectId:self.projectId entityId:triggerEntityDict[@"id"] testRequestDataBlock:nil];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"wait"];
    [self.session createQrCode:@"my qr code" destination:[NSURL URLWithString:@"http://www.apple.com"] completion:^(UIImage *image, NSError *error) {
        XCTAssertNotNil(image);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:2.0 handler:nil];
}

- (void)testCreateWatermark {
    NSData *data = [HPTestData getImageData];
    
    [HPMockHelper mockGetDefaultProject:self.projectId];
    NSDictionary *triggerEntityDict = [HPMockHelper mockTriggerCreate:LPTriggerTypeWatermark project:self.projectId testRequestDataBlock:nil];
    [HPMockHelper mockPayoffCreate:LPPayoffTypeUrl project:self.projectId testRequestDataBlock:nil];
    [HPMockHelper mockLinkCreateWithProjectId:self.projectId testRequestDataBlock:nil];
    
    [HPMockHelper mockImageUpload];
    [HPMockHelper mockWatermarkingWithProjectId:self.projectId entityId:triggerEntityDict[@"id"] testRequestDataBlock:nil];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"wait"];
    [self.session createWatermark:@"my watermark" destination:[NSURL URLWithString:@"http://www.apple.com"] imageData:data completion:^(UIImage *watermarkedImage, NSError *error) {
        XCTAssertNotNil(watermarkedImage);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:2.0 handler:nil];
}


- (void)testCreateWatermarkWithRichPayoff {
    NSData *data = [HPTestData getImageData];
    
    [HPMockHelper mockGetDefaultProject:self.projectId];
    NSDictionary *triggerEntityDict = [HPMockHelper mockTriggerCreate:LPTriggerTypeWatermark project:self.projectId testRequestDataBlock:nil];
    [HPMockHelper mockPayoffCreate:LPPayoffTypeRich project:self.projectId testRequestDataBlock:nil];
    [HPMockHelper mockLinkCreateWithProjectId:self.projectId testRequestDataBlock:nil];
    
    [HPMockHelper mockImageUpload];
    [HPMockHelper mockWatermarkingWithProjectId:self.projectId entityId:triggerEntityDict[@"id"] testRequestDataBlock:nil];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"wait"];
    [self.session createWatermark:@"my watermark" richPayoffData:[HPTestData richPayoff] publicURL:[NSURL URLWithString:@"http://www.google.com"] imageData:data completion:^(UIImage *watermarkedImage, NSError *error) {
        XCTAssertNotNil(watermarkedImage);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:2.0 handler:nil];
}

@end
