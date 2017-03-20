//
//  LPTrigger.m
//  LivePaperSDK
//
//  Created by Alejandro Mendez on 1/12/17.
//  Copyright © 2017 Hewlett-Packard. All rights reserved.
//

#import "LPTrigger.h"
#import <LivePaperSDK/LPProject.h>
#import "LPSessionPrivate.h"
#import "LPProjectEntityPrivate.h"
#import "LPDate.h"
#import "ImageIO/ImageIO.h"
#import "LPGetTokenOperation.h"
#import "LPGetImageOperation.h"


static int const LPTriggerDefaultWmStrength = 10;
static int const LPTriggerDefaultWmResolution = 60;
static int const LPTriggerDefaultImageResolution = 300;

static NSString * const LPTriggerTypeShortUrlValue = @"shorturl";
static NSString * const LPTriggerTypeQrCodeValue = @"qrcode";
static NSString * const LPTriggerTypeWatermarkValue = @"watermark";

static NSString * const LPTriggerStateActiveValue = @"active";
static NSString * const LPTriggerStateInactiveValue = @"inactive";
static NSString * const LPTriggerStateDisabledValue = @"disabled";
static NSString * const LPTriggerStateArchivedValue = @"archived";

static NSString * const LPTriggerQrCodeErrorCorrectionLowValue = @"low";
static NSString * const LPTriggerQrCodeErrorCorrectionMediumValue = @"medium";
static NSString * const LPTriggerQrCodeErrorCorrectionQuartileValue = @"quartile";
static NSString * const LPTriggerQrCodeErrorCorrectionHighValue = @"high";



@interface LPTrigger () <LPBaseEntity>

@property(nonatomic) LPTriggerType type;
@property(nonatomic) NSString *renewalDate;
@property(nonatomic) NSString *uid;

@property(nonatomic) NSURL *shortURL;
@property(nonatomic) NSURL *qrCodeImageURL;
@property(nonatomic) NSURL *watermarkImageURL;

@end

@implementation LPTrigger

- (instancetype)initWithSession:(LPSession *) session dictionary:(NSDictionary *)dictionary
{
    self = [super initWithSession:session dictionary:dictionary];
    if (self) {
        NSString *renewalDate = dictionary[@"renewalDate"];
        NSString *state = dictionary[@"state"];
        NSString *type = dictionary[@"type"];
        NSString *uid = dictionary[@"uid"];
        if (!renewalDate || !state || !type || !uid) {
            return nil;
        }
        _renewalDate = renewalDate;
        _uid = uid;
        
        if ([type isEqualToString:LPTriggerTypeShortUrlValue]) {
            _type = LPTriggerTypeShortUrl;
        }else if ([type isEqualToString:LPTriggerTypeQrCodeValue]) {
            _type = LPTriggerTypeQrCode;
        }else if ([type isEqualToString:LPTriggerTypeWatermarkValue]) {
            _type = LPTriggerTypeWatermark;
        }else{
            return nil;
        }
        
        if ([state isEqualToString:LPTriggerStateActiveValue]) {
            _state = LPTriggerStateActive;
        }else if ([state isEqualToString:LPTriggerStateInactiveValue]) {
            _state = LPTriggerStateInactive;
        }else if ([state isEqualToString:LPTriggerStateDisabledValue]) {
            _state = LPTriggerStateDisabled;
        }else if ([state isEqualToString:LPTriggerStateArchivedValue]) {
            _state = LPTriggerStateArchived;
        }else{
            return nil;
        }
        
        if (self.type == LPTriggerTypeShortUrl) {
            _shortURL = [self urlForRel:@"shortURL"];
        } else {
            _shortURL = nil;
        }
        
        if (self.type == LPTriggerTypeQrCode) {
            _qrCodeImageURL = [self urlForRel:@"download"];
        } else {
            _qrCodeImageURL = nil;
        }
        
        if (self.type == LPTriggerTypeWatermark) {
            _watermarkImageURL = [self urlForRel:@"download"];
        } else {
            _watermarkImageURL = nil;
        }
    }
    return self;
}


#pragma mark - Public methods

+ (void)createWithDictionary:(NSDictionary *)dictionary projectId:(NSString *)projectId session:(LPSession *)session completion:(void (^)(LPTrigger *trigger, NSError *error))completion
{
    [self entityCreateWithDictionary:@{ @"trigger" : dictionary } projectId:projectId session:session completion:completion];
}

+ (void)createShortUrlWithName:(NSString *)name projectId:(NSString *)projectId session:(LPSession *)session completion:(void (^)(LPTrigger *trigger, NSError *error))completion
{
    NSDictionary *dictionary = @{
                           @"name" : name ?: @"",
                           @"type" : LPTriggerTypeShortUrlValue
                           };
    [self createWithDictionary:dictionary projectId:projectId session:session completion:completion];
}

+ (void)createQrCodeWithName:(NSString *)name projectId:(NSString *)projectId session:(LPSession *)session completion:(void (^)(LPTrigger *trigger, NSError *error))completion
{
    NSDictionary *dictionary = @{
                                 @"name" : name ?: @"",
                                 @"type" : LPTriggerTypeQrCodeValue,
                                 @"typeFriendly" : @"true"
                                 };
    [self createWithDictionary:dictionary projectId:projectId session:session completion:completion];
}


+ (void)createWatermarkWithName:(NSString *)name projectId:(NSString *)projectId session:(LPSession *)session completion:(void (^)(LPTrigger *trigger, NSError *error))completion
{
    NSDictionary *dictionary = @{
                                 @"name" : name ?: @"",
                                 @"type" : LPTriggerTypeWatermarkValue
                                 };
    [self createWithDictionary:dictionary projectId:projectId session:session completion:completion];
}


+ (void)get:(NSString *)identifier projectId:(NSString *)projectId session:(LPSession *)session completion:(void (^)(LPTrigger * trigger, NSError *error))completion
{
    [self entityGet:identifier projectId:projectId session:session completion:completion];
}

+ (void)list:(LPSession *)session projectId:(NSString *)projectId completion:(void (^)(NSArray <LPTrigger *> *links, NSError *error))completion{
    [self entityList:session projectId:projectId completion:completion];
}

- (void)getWatermarkForImageURL:(NSURL *)imageURL strength:(int) strength watermarkResolution:(int)watermarkResolution imageResolution:(int)imageResolution adjustImageLevels:(BOOL)adjustImageLevels progress:(void (^_Nullable)(double progress))progress completion:(void (^)(UIImage *image, NSError *error))completion
{
    if (self.type != LPTriggerTypeWatermark) {
        [self handleWatermarkNotSupportedWithCompletion:completion];
        return;
    }
    
    NSURLComponents *urlComponents = [NSURLComponents componentsWithString:self.watermarkImageURL.absoluteString];
    urlComponents.queryItems = urlComponents.queryItems ?: @[];
    urlComponents.queryItems = [urlComponents.queryItems arrayByAddingObjectsFromArray:@[
                            [NSURLQueryItem queryItemWithName:@"imageURL" value:[imageURL absoluteString]],
                            [NSURLQueryItem queryItemWithName:@"strength" value:@(strength).stringValue],
                            [NSURLQueryItem queryItemWithName:@"wpi" value:@(watermarkResolution).stringValue],
                            [NSURLQueryItem queryItemWithName:@"ppi" value:@(imageResolution).stringValue],
                            [NSURLQueryItem queryItemWithName:@"adjustImageLevels" value:(adjustImageLevels ? @"true" : @"false")]
                                                                                         ]];
    LPGetImageOperation *operation = [[LPGetImageOperation alloc] initWithSession:self.session imageUrl:urlComponents.URL projectId:self.projectId completion:^(UIImage * _Nullable image, NSData * _Nullable data, NSHTTPURLResponse * _Nullable response, NSError * _Nullable error) {
        [self handleCompletionWithImage:image error:error withCompletion:completion];
    }];
    operation.progressCallback = progress;
    [[HPLinkOperationQueue sharedQueue] addOperation:operation];
}

- (void)getWatermarkForImageData:(NSData *)imageData strength:(int) strength watermarkResolution:(int)watermarkResolution imageResolution:(int)imageResolution adjustImageLevels:(BOOL)adjustImageLevels progress:(void (^_Nullable)(double progress))progress completion:(void (^)(UIImage *image, NSError *error))completion
{
    if (self.type != LPTriggerTypeWatermark) {
        [self handleWatermarkNotSupportedWithCompletion:completion];
        return;
    }
    
    [LPProject uploadImageFile:imageData projectId:self.projectId session:self.session progress:^(double progressValue) {
        if (progress) {
            progress(progressValue * 0.5);
        }
    } completion:^(NSURL *url, NSError *error) {
        if (url) {
            [self getWatermarkForImageURL:url strength:strength watermarkResolution:watermarkResolution imageResolution:imageResolution adjustImageLevels:adjustImageLevels progress:^(double progressValue) {
                if (progress) {
                    progress(0.5 + progressValue * 0.5);
                }
            } completion:completion];
        } else {
            [self handleCompletionWithImage:nil error:error withCompletion:completion];
        }
    }];
}

- (void)getWatermarkForImageURL:(NSURL *)imageURL progress:(void (^_Nullable)(double progress))progress completion:(void (^)(UIImage *image, NSError *error))completion {
    
    if (self.type != LPTriggerTypeWatermark) {
        [self handleWatermarkNotSupportedWithCompletion:completion];
        return;
    }
    
    LPGetImageOperationCompletion getImageCompletion = ^(UIImage *image, NSData *data, NSHTTPURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            int imageResolution = [[self class] dpiForImageData:data];
            [self getWatermarkForImageURL:imageURL strength:LPTriggerDefaultWmStrength watermarkResolution:MIN(LPTriggerDefaultWmResolution, imageResolution) imageResolution:imageResolution adjustImageLevels:true progress:^(double progressValue) {
                if (progress) {
                    progress(0.5 + progressValue * 0.5);
                }
            } completion:completion];
        }else{
            [self handleCompletionWithImage:nil error:error withCompletion:completion];
        }
    };
    
    LPGetImageOperation *getImageOperation;
    if ([imageURL.absoluteString containsString:@"storage.livepaperapi"]) {
        getImageOperation = [[LPGetImageOperation alloc] initWithSession:self.session imageUrl:imageURL projectId:self.projectId completion:getImageCompletion];
        
    }else{
        getImageOperation = [[LPGetImageOperation alloc] initWithImageUrl:imageURL additionalHeaders:nil completion:getImageCompletion];
    }
    getImageOperation.progressCallback = ^(double progressValue){
        if (progress) {
            progress(progressValue * 0.5);
        }
    };
    [[HPLinkOperationQueue sharedQueue] addOperation:getImageOperation];
}

- (void)getWatermarkForImageData:(NSData *)imageData progress:(void (^_Nullable)(double progress))progress completion:(void (^)(UIImage *image, NSError *error)) completion {
    if (self.type != LPTriggerTypeWatermark) {
        [self handleWatermarkNotSupportedWithCompletion:completion];
        return;
    }
    int imageResolution = [[self class] dpiForImageData:imageData];
    [LPProject uploadImageFile:imageData projectId:self.projectId session:self.session progress:^(double progressValue) {
        if (progress) {
            progress(progressValue * 0.5);
        }
    } completion:^(NSURL *url, NSError *error) {
        if (url) {
            [self getWatermarkForImageURL:url strength:LPTriggerDefaultWmStrength watermarkResolution:MIN(LPTriggerDefaultWmResolution, imageResolution) imageResolution:imageResolution adjustImageLevels:true progress:^(double progressValue) {
                if (progress) {
                    progress(0.5 + progressValue * 0.5);
                }
            } completion:completion];
        } else {
            [self handleCompletionWithImage:nil error:error withCompletion:completion];
        }
    }];
}

- (void)getQrCodeImageWithSize:(int)size margin:(int)margin errorCorrection:(LPTriggerQrCodeErrorCorrection)errorCorrection progress:(nullable void (^)(double progress))progress completion:(nullable void (^ )(UIImage * _Nullable image, NSError * _Nullable error))completion
{
    if(self.type != LPTriggerTypeQrCode){
        [self handleCompletionWithImage:nil error:[NSError errorWithDomain:[LPErrors domainName] code:LPInternalErrorCode_EntityError userInfo:@{NSLocalizedDescriptionKey: @"QR code image is not available for this trigger type."}] withCompletion:completion];
        return;
    }
    
    NSURLComponents *urlComponents = [NSURLComponents componentsWithString:self.qrCodeImageURL.absoluteString];
    urlComponents.queryItems = urlComponents.queryItems ?: @[];
    urlComponents.queryItems = [urlComponents.queryItems arrayByAddingObjectsFromArray:@[
                 [NSURLQueryItem queryItemWithName:@"size" value:@(size).stringValue],
                 [NSURLQueryItem queryItemWithName:@"margin" value:@(margin).stringValue],
                 [NSURLQueryItem queryItemWithName:@"errorCorrection" value:[[self class] stringFromQrCodeErrorCorrection:errorCorrection]]
                                                                                         ]];
    LPGetImageOperation *operation = [[LPGetImageOperation alloc] initWithSession:self.session imageUrl:urlComponents.URL projectId:self.projectId completion:^(UIImage * _Nullable image, NSData * _Nullable data, NSHTTPURLResponse * _Nullable response, NSError * _Nullable error) {
        [self handleCompletionWithImage:image error:error withCompletion:completion];
    }];
    operation.progressCallback = progress;
    [[HPLinkOperationQueue sharedQueue] addOperation:operation];    
}

- (void)getQrCodeImageWithProgress:(nullable void (^)(double progress))progress completion:(nullable void (^ )(UIImage * _Nullable image, NSError * _Nullable error))completion{
    [self getQrCodeImageWithSize:100 margin:4 errorCorrection:LPTriggerQrCodeErrorCorrectionLow progress:progress completion:completion];
}

#pragma mark Private methods

- (NSURL *)urlForRel:(NSString *)rel
{
    __block NSURL *url = nil;
    if (self.atomLinks) {
        [self.atomLinks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([[obj objectForKey:@"rel"] compare:rel options:NSCaseInsensitiveSearch] == NSOrderedSame) {
                url = [NSURL URLWithString:[obj objectForKey:@"href"]];
                *stop = YES;
            }
        }];
    }
    return url;
}

+ (NSString *)stringFromType:(LPTriggerType)type{
    switch (type) {
        case LPTriggerTypeShortUrl:
            return LPTriggerTypeShortUrlValue;
        case LPTriggerTypeQrCode:
            return LPTriggerTypeQrCodeValue;
        case LPTriggerTypeWatermark:
            return LPTriggerTypeWatermarkValue;
    }
}

+ (NSString *)stringFromState:(LPTriggerState)state{
    switch (state) {
        case LPTriggerStateActive:
            return LPTriggerStateActiveValue;
        case LPTriggerStateInactive:
            return LPTriggerStateInactiveValue;
        case LPTriggerStateDisabled:
            return LPTriggerStateDisabledValue;
        case LPTriggerStateArchived:
            return LPTriggerStateArchivedValue;
    }
}

+ (NSString *)stringFromQrCodeErrorCorrection:(LPTriggerQrCodeErrorCorrection)errorCorrection{
    switch (errorCorrection) {
        case LPTriggerQrCodeErrorCorrectionLow:
            return LPTriggerQrCodeErrorCorrectionLowValue;
        case LPTriggerQrCodeErrorCorrectionMedium:
            return LPTriggerQrCodeErrorCorrectionMediumValue;
        case LPTriggerQrCodeErrorCorrectionQuartile:
            return LPTriggerQrCodeErrorCorrectionQuartileValue;
        case LPTriggerQrCodeErrorCorrectionHigh:
            return LPTriggerQrCodeErrorCorrectionHighValue;
    }
}

- (void)handleCompletionWithImage:(UIImage *)image error:(NSError *)error withCompletion:(void (^)(UIImage *image, NSError *error))completion {
    if (completion) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(image, error);
        });
    }
}

- (void)handleWatermarkNotSupportedWithCompletion:(void (^)(UIImage *image, NSError *error))completion {
    [self handleCompletionWithImage:nil error:[NSError errorWithDomain:[LPErrors domainName] code:LPInternalErrorCode_EntityError userInfo:@{NSLocalizedDescriptionKey: @"Watermark image is not available for this trigger type."}] withCompletion:completion];
}

+ (int)dpiForImageData:(NSData*)imageData {
    CGImageSourceRef imageSource = CGImageSourceCreateWithData((CFDataRef)imageData, NULL);
    CFDictionaryRef propertyRef = CGImageSourceCopyPropertiesAtIndex ( imageSource, 0, NULL );
    NSDictionary *properties = (__bridge NSDictionary*)propertyRef;
    // DPIHeight should pull the attributes from JFIF, EXIF and Photoshop formats, but we check each dictionary just in case it is not populated
    NSNumber *dpi = properties[@"DPIHeight"];
    
    // EXIF and Photoshop resolution data is found in the TIFF tag
    if (!dpi) {
        NSDictionary *exifOrPhotoshop = properties[@"TIFF"] ?: properties[@"{TIFF}"];;
        dpi = exifOrPhotoshop[@"XResolution"];
    }
    // Checking for JFIF
    if (!dpi) {
        NSDictionary *jfif = properties[@"JFIF"] ?: properties[@"{JFIF}"];
        dpi = jfif[@"XDensity"];
    }
    if (!dpi) {
        dpi = @(LPTriggerDefaultImageResolution);
    }
    return dpi.intValue;
}

#pragma mark <LPBaseEntity>

+(NSString *)entityName {
    return @"trigger";
}

-(NSDictionary *)dictionaryRepresentationForEdit {
    return @{
             [[self class] entityName]:@{
                     @"name" : [self name] ?: @"",
                     @"state" : [[self class] stringFromState:[self state]] ?: @""
                     }
             };
}

@end
