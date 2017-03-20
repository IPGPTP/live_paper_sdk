//
//  LPTriggerTests.m
//  LivePaperSDK
//
//  Created by Alejandro Mendez on 01/12/17.
//  Copyright © 2015 Hewlett-Packard. All rights reserved.
//

#import "LPBaseTestCase.h"
#import <XCTest/XCTest.h>
#import "HPTestData.h"
#import "ImageIO/ImageIO.h"
#import "OHHTTPStubs/OHHTTPStubs.h"

@interface LPTrigger(Tests)
+ (int)dpiForImageData:(NSData*)imageData;
@end


@interface LPTriggerTests : LPBaseTestCase

@property (nonatomic) NSDictionary *entityDict;
@property (nonatomic) NSString *entityId;

@end

@implementation LPTriggerTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testCreateWatermark {
    
    NSDictionary *entityDict = [self mockTriggerCreate:LPTriggerTypeWatermark];
    
    XCTestExpectation * expectation = [self expectationWithDescription:@"wait"];
    [LPTrigger createWatermarkWithName:entityDict[@"name"] projectId:self.projectId session:self.session completion:^(LPTrigger * trigger, NSError *error) {
        XCTAssertNotNil(trigger);
        [self verifyEntity:trigger entityDictionary:entityDict];
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:2.0 handler:nil];
}

- (void)testCreateQrCode {
    
    NSDictionary *entityDict = [self mockTriggerCreate:LPTriggerTypeQrCode];
    
    XCTestExpectation * expectation = [self expectationWithDescription:@"wait"];
    [LPTrigger createQrCodeWithName:entityDict[@"name"] projectId:self.projectId session:self.session completion:^(LPTrigger * trigger, NSError *error) {
        XCTAssertNotNil(trigger);
        [self verifyEntity:trigger entityDictionary:entityDict];
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:2.0 handler:nil];
}

- (void)testCreateShortUrl {
    
    NSDictionary *entityDict = [self mockTriggerCreate:LPTriggerTypeShortUrl];
    
    XCTestExpectation * expectation = [self expectationWithDescription:@"wait"];
    [LPTrigger createShortUrlWithName:entityDict[@"name"] projectId:self.projectId session:self.session completion:^(LPTrigger * trigger, NSError *error) {
        XCTAssertNotNil(trigger);
        [self verifyEntity:trigger entityDictionary:entityDict];
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:2.0 handler:nil];
}

- (void)testTriggerLinks {
    
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
    [LPTrigger list:self.session projectId:self.projectId completion:^(NSArray<LPTrigger *> *triggers, NSError *error) {
        XCTAssertEqual(triggers.count, entityArray.count);
        for (LPTrigger *trigger in triggers) {
            NSDictionary *entityDict = [entityArray objectAtIndex:[triggers indexOfObject:trigger]];
            [self verifyEntity:trigger entityDictionary:entityDict];
        }
        [expect fulfill];
    }];
    [self waitForExpectationsWithTimeout:2.0 handler:nil];
}

- (void)testGetTrigger {
    [self mockTriggerGet:LPTriggerTypeWatermark];
    XCTestExpectation * expect = [self expectationWithDescription:@"wait"];
    [LPTrigger get:self.entityId projectId:self.projectId session:self.session completion:^(LPTrigger *trigger, NSError *error) {
        [self verifyEntity:trigger entityDictionary:self.entityDict];
        
        [expect fulfill];
    }];
    [self waitForExpectationsWithTimeout:2.0 handler:nil];
}

- (void)testUpdateTrigger {
    [self mockTriggerGet:LPTriggerTypeWatermark];
    NSString *newName = @"some name";
    NSString *newState = @"inactive";
    
    NSMutableDictionary *modifiedEntityDict = self.entityDict.mutableCopy;
    modifiedEntityDict[@"name"] = newName;
    modifiedEntityDict[@"state"] = newState;
    NSString *entityId = self.entityDict[@"id"];
    
    XCTestExpectation * expectRequest = [self expectationWithDescription:@"expectRequest"];
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.absoluteString containsString:[NSString stringWithFormat:@"api/v2/projects/%@/%@",self.projectId, [self pluralEntityName]]]
        && [request.HTTPMethod isEqualToString:@"PUT"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        XCTAssertEqualObjects(request.HTTPMethod, @"PUT");
        NSDictionary *requestDictionary = [NSJSONSerialization JSONObjectWithData:request.OHHTTPStubs_HTTPBody options:0 error:nil];
        XCTAssertEqualObjects(requestDictionary[[self entityName]][@"name"], newName);
        XCTAssertEqualObjects(requestDictionary[[self entityName]][@"state"], newState);
        [expectRequest fulfill];
        return [OHHTTPStubsResponse responseWithData:[@"" dataUsingEncoding:NSUTF8StringEncoding] statusCode:200 headers:@{}];
    }];
    
    XCTestExpectation * expect = [self expectationWithDescription:@"wait"];
    
    [LPTrigger get:entityId projectId:self.projectId session:self.session completion:^(LPTrigger *trigger, NSError *error) {
        trigger.name = newName;
        trigger.state = LPTriggerStateInactive;
        [trigger update:^(NSError *error) {
            [expect fulfill];
        }];
    }];
    [self waitForExpectationsWithTimeout:2.0 handler:nil];
}


- (void)testDeleteTrigger {
    [self mockTriggerGet:LPTriggerTypeWatermark];
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
    [LPTrigger get:self.entityId projectId:self.projectId session:self.session completion:^(LPTrigger *trigger, NSError *error) {
        [trigger delete:^(NSError *error) {
            [expect fulfill];
        }];
    }];
    [self waitForExpectationsWithTimeout:2.0 handler:nil];
}


- (void)testDownloadWatermarkWithImageData {
    [self mockTriggerGet:LPTriggerTypeWatermark];
    
    NSString *imageLocation = [HPMockHelper mockImageUpload];
    [self mockWatermarking:imageLocation strength:10 ppi:300 wpi:60 adjustImageLevels:true];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"wait"];
    NSData *data = [HPTestData getImageData];
    
    [LPTrigger get:self.entityId projectId:self.projectId session:self.session completion:^(LPTrigger *trigger, NSError *error) {
        [trigger getWatermarkForImageData:data progress:nil completion:^(UIImage *image, NSError *error) {
            XCTAssertNotNil(image);
            [expectation fulfill];
        }];
    }];
    [self waitForExpectationsWithTimeout:2.0 handler:nil];
}

- (void)testUsingCorrectPpi {
    
    NSArray * dataArray = @[
                            @{ @"image" : @"JFIF_200ppi", @"imageExt" : @"jpg", @"ppi"  : @(200)},
                            @{ @"image" : @"EXIF_5ppi", @"imageExt" : @"jpeg", @"ppi"  : @(5)},
                            @{ @"image" : @"Photoshop_180ppi", @"imageExt" : @"jpeg", @"ppi"  : @(180)}
                            ];
    
    for (NSDictionary * dataDict in dataArray) {
        NSString *image = dataDict[@"image"];
        NSString *imageExt = dataDict[@"imageExt"];
        NSNumber *ppi = dataDict[@"ppi"];
        
        [self mockTriggerGet:LPTriggerTypeWatermark];
        NSString *imageLocation = [HPMockHelper mockImageUpload];
        [self mockWatermarking:imageLocation strength:10 ppi:ppi.intValue wpi:MIN(60, ppi.intValue) adjustImageLevels:true];
        
        XCTestExpectation *expectation = [self expectationWithDescription:@"wait"];
        NSData *data = [HPTestData getImageData:image extension:imageExt];
        
        [LPTrigger get:self.entityId projectId:self.projectId session:self.session completion:^(LPTrigger *trigger, NSError *error) {
            [trigger getWatermarkForImageData:data progress:nil completion:^(UIImage *image, NSError *error) {
                XCTAssertNotNil(image);
                [expectation fulfill];
            }];
        }];
        [self waitForExpectationsWithTimeout:2.0 handler:nil];
        
        [OHHTTPStubs removeAllStubs];
    }
}

- (void)testDownloadWatermarkWithImageDataWithCustomParemeters {
    [self mockTriggerGet:LPTriggerTypeWatermark];
    int wpi = 70;
    int ppi = 250;
    int adjustImageLevels = NO;
    int strength = 10;
    NSString *imageLocation = [HPMockHelper mockImageUpload];
    
    [self mockWatermarking:imageLocation strength:strength ppi:ppi wpi:wpi adjustImageLevels:adjustImageLevels];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"wait"];
    UIImage *testImage = [UIImage imageNamed:@"forest.jpg" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
    NSData *data = UIImageJPEGRepresentation(testImage, 0.8);
    
    [LPTrigger get:self.entityId projectId:self.projectId session:self.session completion:^(LPTrigger *trigger, NSError *error) {
        [trigger getWatermarkForImageData:data strength:strength watermarkResolution:wpi imageResolution:ppi adjustImageLevels:adjustImageLevels progress:nil completion:^(UIImage *image, NSError *error) {
            XCTAssertNotNil(image);
            [expectation fulfill];
        }];
    }];
    [self waitForExpectationsWithTimeout:2.0 handler:nil];
}

- (void)testDownloadWatermarkWithLppStorageImageUrl {
    [self mockTriggerGet:LPTriggerTypeWatermark];
    
    NSString *uploadedImageUrl = @"https://stage.storage.livepaperapi.com/objects/v2/projects/4b13Xz/files/fAomAm6lRYebvPZwq-rUBg";
    [HPMockHelper mockImageDownload:uploadedImageUrl];
    [self mockWatermarking:uploadedImageUrl strength:10 ppi:300 wpi:60 adjustImageLevels:YES];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"wait"];
    [LPTrigger get:self.entityId projectId:self.projectId session:self.session completion:^(LPTrigger *trigger, NSError *error) {
        [trigger getWatermarkForImageURL:[NSURL URLWithString:uploadedImageUrl] progress:nil completion:^(UIImage *image, NSError *error) {
            XCTAssertNotNil(image);
            [expectation fulfill];
        }];
    }];
    
    [self waitForExpectationsWithTimeout:2.0 handler:nil];
}

- (void)testDownloadWatermarkWithLppStorageImageUrlWithCustomParameters {
    
    [self mockTriggerGet:LPTriggerTypeWatermark];
    
    int wpi = 70;
    int ppi = 250;
    int adjustImageLevels = NO;
    int strength = 10;
    NSString *uploadedImageUrl = @"https://stage.storage.livepaperapi.com/objects/v2/projects/4b13Xz/files/fAomAm6lRYebvPZwq-rUBg";
    [self mockWatermarking:uploadedImageUrl strength:strength ppi:ppi wpi:wpi adjustImageLevels:adjustImageLevels];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"wait"];
    [LPTrigger get:self.entityId projectId:self.projectId session:self.session completion:^(LPTrigger *trigger, NSError *error) {
        [trigger getWatermarkForImageURL:[NSURL URLWithString:uploadedImageUrl] strength:strength watermarkResolution:wpi imageResolution:ppi adjustImageLevels:adjustImageLevels progress:nil completion:^(UIImage *image, NSError *error) {
            XCTAssertNotNil(image);
            [expectation fulfill];
        }];
    }];
    
    [self waitForExpectationsWithTimeout:2.0 handler:nil];
}

- (void)testQrCode {
    [self mockTriggerGet:LPTriggerTypeQrCode];
    [self mockQrCodeWithSize:100 margin:4 errorCorrection:@"low"];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"wait"];
    [LPTrigger get:self.entityId projectId:self.projectId session:self.session completion:^(LPTrigger *trigger, NSError *error) {
        [trigger getQrCodeImageWithProgress:nil completion:^(UIImage * _Nullable image, NSError * _Nullable error) {
            XCTAssertNotNil(image);
            [expectation fulfill];
        }];
    }];
    
    [self waitForExpectationsWithTimeout:20.0 handler:nil];
}

- (void)testQrCodeWithCustomParams {
    int size = 100;
    int margin = 4;
    NSString *errorCorrection = @"low";
    [self mockTriggerGet:LPTriggerTypeQrCode];
    [self mockQrCodeWithSize:size margin:margin errorCorrection:errorCorrection];
    XCTestExpectation *expectation = [self expectationWithDescription:@"wait"];
    [LPTrigger get:@"E57kQ3vORIqF-MfTkYJahQ" projectId:self.projectId session:self.session completion:^(LPTrigger *trigger, NSError *error) {
        [trigger getQrCodeImageWithSize:size margin:margin errorCorrection:LPTriggerQrCodeErrorCorrectionLow progress:nil completion:^(UIImage *image, NSError *error) {
            XCTAssertNotNil(image);
            [expectation fulfill];
        }];
    }];
    
    [self waitForExpectationsWithTimeout:2.0 handler:nil];
}

#pragma mark Helper methods

- (NSString *)entityName {
    return @"trigger";
}

- (NSDictionary *)mockTriggerCreate:(LPTriggerType)type {
    __block NSDictionary *entityDict =  [HPMockHelper mockTriggerCreate:type project:self.projectId testRequestDataBlock:^(NSURLRequest *request) {
        NSDictionary *requestDictionary = [NSJSONSerialization JSONObjectWithData:request.OHHTTPStubs_HTTPBody options:0 error:nil];
        XCTAssertEqualObjects(requestDictionary[[self entityName]][@"name"], entityDict[@"name"]);
        XCTAssertEqualObjects(requestDictionary[[self entityName]][@"type"], entityDict[@"type"]);
    }];
    return entityDict;
}

- (void)verifyEntity:(LPTrigger *)trigger entityDictionary:(NSDictionary *)entity{
    
    XCTAssertEqualObjects(trigger.identifier, entity[@"id"]);
    XCTAssertEqualObjects(trigger.name, entity[@"name"]);
    XCTAssertEqualObjects(trigger.renewalDate, entity[@"renewalDate"]);
    XCTAssertEqualObjects(trigger.uid, entity[@"uid"]);
    if ([entity[@"type"] isEqualToString:@"qrcode"]) {
        XCTAssertEqual(trigger.type, LPTriggerTypeQrCode);
    }else if ([entity[@"type"] isEqualToString:@"watermark"]) {
        XCTAssertEqual(trigger.type, LPTriggerTypeWatermark);
    }else if ([entity[@"type"] isEqualToString:@"shorturl"]) {
        XCTAssertEqual(trigger.type, LPTriggerTypeShortUrl);
    }else{
        XCTFail("Trigger type not found");
    }
    if ([entity[@"state"] isEqualToString:@"active"]) {
        XCTAssertEqual(trigger.state, LPTriggerStateActive);
    }else if ([entity[@"state"] isEqualToString:@"disabled"]) {
        XCTAssertEqual(trigger.state, LPTriggerStateDisabled);
    }else if ([entity[@"state"] isEqualToString:@"inactive"]) {
        XCTAssertEqual(trigger.state, LPTriggerStateInactive);
    }else if ([entity[@"state"] isEqualToString:@"archived"]) {
        XCTAssertEqual(trigger.state, LPTriggerStateArchived);
    }else{
        XCTFail("Trigger state not found");
    }
    switch (trigger.type) {
        case LPTriggerTypeShortUrl:
            XCTAssertEqualObjects(trigger.shortURL, [self urlForAtomLink:@"shortURL" atomLinks:entity[@"link"]]);
            break;
        case LPTriggerTypeQrCode:
            XCTAssertEqualObjects(trigger.qrCodeImageURL, [self urlForAtomLink:@"download" atomLinks:entity[@"link"]]);
            break;
        case LPTriggerTypeWatermark:
            XCTAssertEqualObjects(trigger.watermarkImageURL, [self urlForAtomLink:@"download" atomLinks:entity[@"link"]]);
            break;
    }
}

- (void)mockTriggerGet:(LPTriggerType)type {
    NSString *jsonFile;
    switch (type) {
        case LPTriggerTypeQrCode:
            jsonFile = [NSString stringWithFormat:@"%@_get_qr.json", [self entityName]];
            break;
        case LPTriggerTypeWatermark:
            jsonFile = [NSString stringWithFormat:@"%@_get_wm.json", [self entityName]];
            break;
        default:
            jsonFile = [NSString stringWithFormat:@"%@_get_wm.json", [self entityName]];
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

- (void)mockWatermarking:(NSString *)imageLocation strength:(int)strength ppi:(int)ppi wpi:(int)wpi adjustImageLevels:(BOOL)adjustImageLevels{
    NSString *expectedImageLocation = [NSString stringWithFormat:@"imageURL=%@", imageLocation];
    NSString *expectedStrength = [NSString stringWithFormat:@"strength=%d",strength];
    NSString *expectedPpi = [NSString stringWithFormat:@"ppi=%d",ppi];
    NSString *expectedWpi = [NSString stringWithFormat:@"wpi=%d",wpi];
    NSString *expectedLevels = [NSString stringWithFormat:@"adjustImageLevels=%@", adjustImageLevels ? @"true" : @"false"];
    
    XCTestExpectation * expectRequest = [self expectationWithDescription:@"expectRequest"];
    [HPMockHelper mockWatermarkingWithProjectId:self.projectId entityId:self.entityId testRequestDataBlock:^(NSURLRequest *request) {
        [expectRequest fulfill];
        XCTAssert([[request URL].absoluteString containsString:expectedImageLocation]);
        XCTAssert([[request URL].absoluteString containsString:expectedStrength]);
        XCTAssert([[request URL].absoluteString containsString:expectedPpi]);
        XCTAssert([[request URL].absoluteString containsString:expectedWpi]);
        XCTAssert([[request URL].absoluteString containsString:expectedLevels]);
    }];
}

- (void)mockQrCodeWithSize:(int)size margin:(int)margin errorCorrection:(NSString *)errorCorrection {
    NSString *expectedSize = [NSString stringWithFormat:@"size=%d",size];
    NSString *expectedMargin = [NSString stringWithFormat:@"margin=%d",margin];
    NSString *expectedErrorCorrection = [NSString stringWithFormat:@"errorCorrection=%@",errorCorrection];
    
    XCTestExpectation * expectRequest = [self expectationWithDescription:@"expectRequest"];
    [HPMockHelper mockQrCodeWithProjectId:self.projectId entityId:self.entityId testRequestDataBlock:^(NSURLRequest *request) {
        [expectRequest fulfill];
        XCTAssert([[request URL].absoluteString containsString:expectedSize]);
        XCTAssert([[request URL].absoluteString containsString:expectedMargin]);
        XCTAssert([[request URL].absoluteString containsString:expectedErrorCorrection]);
    }];
}

@end
