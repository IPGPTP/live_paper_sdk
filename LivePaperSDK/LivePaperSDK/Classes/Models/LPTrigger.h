//
//  LPTrigger.h
//  LivePaperSDK
//
//  Created by Alejandro Mendez on 1/12/17.
//  Copyright © 2017 Hewlett-Packard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LivePaperSDK/LPSession.h>
#import <LivePaperSDK/LPProjectEntity.h>

typedef NS_ENUM(NSInteger, LPTriggerType) {
    LPTriggerTypeShortUrl,
    LPTriggerTypeQrCode,
    LPTriggerTypeWatermark
};

typedef NS_ENUM(NSInteger, LPTriggerState) {
    LPTriggerStateActive,
    LPTriggerStateDisabled,
    LPTriggerStateInactive,
    LPTriggerStateArchived
};

typedef NS_ENUM(NSInteger, LPTriggerQrCodeErrorCorrection) {
    LPTriggerQrCodeErrorCorrectionLow,
    LPTriggerQrCodeErrorCorrectionMedium,
    LPTriggerQrCodeErrorCorrectionQuartile,
    LPTriggerQrCodeErrorCorrectionHigh
};

/**
 LPTrigger represents a 'HP Link' Trigger object. More information about this resource can be found at:
 https://mylinks.linkcreationstudio.com/developer/doc/v2/trigger/
 */
@interface LPTrigger : LPProjectEntity

@property(nonatomic) LPTriggerState state;
@property(nonatomic, readonly) LPTriggerType type;
@property(nonatomic, readonly, nonnull) NSString *renewalDate;
// The unique identifier of the trigger object
@property(nonatomic, readonly, nonnull) NSString *uid;
// For short URL Triggers, the actual short URL that corresponds to this trigger
@property(nonatomic, readonly, nullable) NSURL *shortURL;
// For QR code Triggers, the URL used to download the QR Code image. The image can be retrieved using the instance methods below.
@property(nonatomic, readonly, nullable) NSURL *qrCodeImageURL;
// For watermark Triggers, the URL used to download the watermarked image. The image can be retrieved using the instance methods below.
@property(nonatomic, readonly, nullable) NSURL *watermarkImageURL;

/**
 Creates a short URL trigger.
 
 @param name                The name of the trigger
 @param projectId           The identifier of the project where the resource will be created.
 @param session             The user session object
 @param completion  The completion block to run upon success
 
 */
+ (void)createShortUrlWithName:(nonnull NSString *)name projectId:(nonnull NSString *)projectId session:(nonnull LPSession *)session completion:(void (^ _Nullable)(LPTrigger *_Nullable trigger, NSError * _Nullable error))completion;

/**
 Creates a QR code trigger.
 
 @param name                The name of the trigger
 @param projectId           The identifier of the project where the resource will be created.
 @param session             The user session object
 @param completion  The completion block to run upon success
 
 */
+ (void)createQrCodeWithName:(nonnull NSString *)name projectId:(nonnull NSString *)projectId session:(nonnull LPSession *)session completion:(void (^ _Nullable)(LPTrigger * _Nullable trigger, NSError * _Nullable error))completion;

/**
 Creates a Watermark trigger.
 
 @param name                The name of the trigger
 @param projectId           The identifier of the project where the resource will be created.
 @param session             The user session object
 @param completion  The completion block to run upon success
 
 */
+ (void)createWatermarkWithName:(nonnull NSString *)name projectId:(nonnull NSString *)projectId session:(nonnull LPSession *)session completion:(void (^ _Nullable)(LPTrigger * _Nullable trigger, NSError * _Nullable error))completion;

/**
 Gets a trigger object.
 
 @param identifier          The identifier of the resource to get
 @param projectId           The identifier of the project where the resource was created
 @param session             The user session object
 @param completion  The completion block to run upon success
 
 */
+ (void)get:(nonnull NSString *)identifier projectId:(nonnull NSString *)projectId session:(nonnull LPSession *)session completion:(void (^ _Nullable)(LPTrigger * _Nullable trigger, NSError * _Nullable error))completion;

/**
 Lists the triggers in a project
 
 @param projectId           The identifier of the project where the resource was created
 @param session             The user session object
 @param completion          The completion block to run upon success
 
 */
+ (void)list:(nonnull LPSession *)session projectId:(nonnull NSString *)projectId completion:(void (^ _Nullable)(NSArray <LPTrigger *> * _Nullable triggers, NSError * _Nullable error))completion;

//-----------------------------------
# pragma mark Watermark Trigger Methods
//-----------------------------------

/**
 Gets the watermarked image at a URL with the given parameters.
 
 @param imageURL                The image URL. The URL must be obtained via the Link File Storage. Use the 'uploadImageFile:projectId:session:progress:completion:' on the LPProject class to upload an image to Link File Storage.
 @param strength                The strength of the applied watermark. The values should be between 1 and 10.
 @param watermarkResolution     The watermark resolution. Please refer to https://mylinks.linkcreationstudio.com/developer/doc/v2/trigger/#tocAnchor-1-13 for more information about this parameter.
 @param imageResolution         The image resolution in pixels per inch.
 @param adjustImageLevels       If 'true', optimizes the scannability of the watermarked image, which may result in a subtle adjustment of the light and dark tone regions of the image.
 @param progress                A progress block that will be called with the progress value
 @param completion              The completion block to run upon success
 
 */
- (void)getWatermarkForImageURL:(nonnull NSURL *) imageURL strength:(int) strength watermarkResolution:(int)watermarkResolution imageResolution:(int)imageResolution adjustImageLevels:(BOOL)adjustImageLevels progress:(nullable void (^)(double progress))progress completion:(nullable void (^)(UIImage *_Nullable image, NSError * _Nullable error))completion;

/**
 Uploads an image and watermark it using the given parameters.
 
 @param imageData               The image data
 @param strength                The strength of the applied watermark. The values should be between 1 and 10.
 @param watermarkResolution     The watermark resolution. Please refer to https://mylinks.linkcreationstudio.com/developer/doc/v2/trigger/#tocAnchor-1-13 for more information about this parameter.
 @param imageResolution         The image resolution in pixels per inch.
 @param adjustImageLevels       If 'true', optimizes the scannability of the watermarked image, which may result in a subtle adjustment of the light and dark tone regions of the image.
 @param progress                A progress block that will be called with the progress value
 @param completion              The completion block to run upon success
 
 */
- (void)getWatermarkForImageData:(nonnull NSData *)imageData strength:(int) strength watermarkResolution:(int)watermarkResolution imageResolution:(int)imageResolution adjustImageLevels:(BOOL)adjustImageLevels progress:(nullable void (^)(double progress))progress completion:(nullable void (^)(UIImage * _Nullable image, NSError * _Nullable error))completion;

/**
 Get the watermarked image at a URL with the default paremeters. Will first download the image to try to extract the image resolution data.
 
 @param imageURL    The image URL. The URL MUST be obtained via the Link File Storage. Use the 'uploadImageFile:projectId:session:progress:completion:' method on the LPProject class to upload an image to Link File Storage.
 @param progress    A progress block that will be called with the progress value
 @param completion  The completion block to run upon success
 
 */
- (void)getWatermarkForImageURL:(nonnull NSURL *)imageURL progress:(nullable void (^)(double progress))progress completion:(nullable void (^)(UIImage * _Nullable image, NSError * _Nullable error))completion;


/**
 Upload an image and watermark it using the default paremeters. Will first download the image to try to extract the image resolution data.
 
 @param imageData   The image data
 @param progress    A progress block that will be called with the progress value
 @param completion  The completion block to run upon success
 
 */
- (void)getWatermarkForImageData:(nonnull NSData *)imageData progress:(nullable void (^)(double progress))progress completion:(nullable void (^)(UIImage * _Nullable image, NSError * _Nullable error))completion;


//-----------------------------------
# pragma mark QR code trigger methods
//-----------------------------------


/**
 Downloads a QR code image with the specified parameters.
 
 @param size            The size of the QR code image, in pixels
 @param margin          The margin of the QR code
 @param errorCorrection The QR code error correction
 @param progress        A progress block that will be called with the progress value
 @param completion      The completion block to run upon success
 
 */
- (void)getQrCodeImageWithSize:(int)size margin:(int)margin errorCorrection:(LPTriggerQrCodeErrorCorrection)errorCorrection progress:(nullable void (^)(double progress))progress completion:(nullable void (^ )(UIImage * _Nullable image, NSError * _Nullable error))completion;

/**
 Downloads a QR code image with the default parameters. Please refer to https://mylinks.linkcreationstudio.com/developer/doc/v2/trigger/#tocAnchor-1-16 for the default paramter values.
 
 @param progress    A progress block that will be called with the progress value
 @param completion  The completion block to run upon success
 */
- (void)getQrCodeImageWithProgress:(nullable void (^)(double progress))progress completion:(nullable void (^ )(UIImage * _Nullable image, NSError * _Nullable error))completion;


@end
