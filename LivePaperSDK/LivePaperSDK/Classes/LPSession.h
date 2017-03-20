//
//  LPSession.h
//  LivePaperSDK
//
//  Created by Alejandro Mendez on 1/12/17.
//  Copyright © 2017 Hewlett-Packard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <LivePaperSDK/LPStack.h>
#import <LivePaperSDK/LPErrors.h>

@interface LPSession : NSObject

@property (readonly, retain) NSString *accessToken;

/**
 Returns the LivePaperSDK version
 
 @return a string represeting the LivePaperSDK version
 */
+ (NSString*) version;

/**
 Initializes a LPSession instance. The client credentials can be obtained at: https://mylinks.linkcreationstudio.com/developer/libraries/ios/
 
 @param clientId        The client ID
 @param secret          The client secret
 
 @return an initialized LPSession object
 */
+ (instancetype)createSessionWithClientId:(NSString *)clientId secret:(NSString *)secret;

/**
 Initializes a LPSession instance. The client credentials can be obtained at: https://mylinks.linkcreationstudio.com/developer/libraries/ios/
 
 @param clientId        The client ID
 @param secret          The client secret
 @param stack           The stack used to create the session. All resources created with this session will be created in this stack.
 
 @return an initialized LPSession object
 */
+ (instancetype)createSessionWithClientId:(NSString *)clientId secret:(NSString *)secret stack:(LPStack)stack;

/**
 Retrieves a LivePaper access token
 
 @param completion    The completion block to run upon success
 
 */
- (void)retrieveAccessToken:(void (^)(NSString *accessToken, NSError *error))completion;


//-----------------------------------
# pragma mark Quick Start methods
//-----------------------------------
// These functions create a link, payoff and trigger under the user's default project.
// For more functionality please refer to the LPProject, LPLink, LPPayoff and LPPayoff classes, as well as the online documentation:
// https://mylinks.linkcreationstudio.com/developer/doc/v2/


/**
 Creates a short URL trigger, an URL payoff and a link
 
 @param name          The name of the trigger, payoff and link
 @param url           The URL to which the user will be redirected
 @param completion    The completion block to run upon success
 
 */
- (void)createShortUrl:(NSString *)name destination:(NSURL *)url completion:(void (^)(NSURL *shortUrl, NSError *error))completion;

/**
 Creates a QR code trigger, an URL payoff and a link
 
 @param name          The name of the trigger, payoff and link
 @param url           The URL to which the user will be redirected
 @param completion    The completion block to run upon success
 
 */
- (void)createQrCode:(NSString *)name destination:(NSURL *)url completion:(void (^)(UIImage *image, NSError *error))completion;

/**
 Creates a watermark trigger, an URL payoff and a link
 
 @param name          The name of the trigger, payoff and link
 @param url           The URL to which the user will be redirected
 @param imageData     The image data to be watermarked
 @param completion    The completion block to run upon success
 
 */
- (void)createWatermark:(NSString *)name destination:(NSURL *)url imageData:(NSData*)imageData completion:(void (^)(UIImage *watermarkedImage, NSError *error))completion;

/**
 Creates a watermark trigger, a rich payoff and a link
 
 @param name            The name of the trigger, payoff and link
 @param richPayoffData  The rich payoff content structure. Refer to: https://mylinks.linkcreationstudio.com/developer/doc/v2/payoff/#tocAnchor-1-5
 @param publicURL       The URL to which non-LinkReader users will be redirected
 @param imageData       The image data to be watermarked
 @param completion      The completion block to run upon success
 
 */
- (void)createWatermark:(NSString *)name richPayoffData:(NSDictionary *)richPayoffData publicURL:(NSURL *)publicURL imageData:(NSData *)imageData completion:(void (^)(UIImage *watermarkedImage, NSError *error))completion;


@end
