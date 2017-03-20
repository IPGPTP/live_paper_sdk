//
//  LPGetImage.h
//  LivePaperSDK
//
//  Created by Alejandro Mendez on 2/8/17.
//  Copyright © 2017 Hewlett-Packard. All rights reserved.
//

#import "LPAuthenticatedNetworkOperation.h"

typedef void (^LPGetImageOperationCompletion)(UIImage * _Nullable image, NSData * _Nullable data, NSHTTPURLResponse * _Nullable response, NSError* _Nullable error);

@interface LPGetImageOperation : HPLinkBaseOperation

@property (nonatomic, copy, nullable) void (^progressCallback)(double progress);

+ (nullable instancetype)executeWithSession:(nonnull LPSession *)session imageUrl:(nonnull NSURL *)imageUrl projectId:(nonnull NSString*)projectId completion:(nullable LPGetImageOperationCompletion)completion;

+ (nullable instancetype)executeWithImageUrl:(nonnull NSURL *)imageUrl additionalHeaders:(nullable NSDictionary*)headers completion:(nullable LPGetImageOperationCompletion)completion;

- (nullable instancetype)initWithSession:(nonnull LPSession *)session imageUrl:(nonnull NSURL *)imageUrl projectId:(nonnull NSString*)projectId completion:(nullable LPGetImageOperationCompletion)completion;

- (nullable instancetype)initWithImageUrl:(nonnull NSURL *)imageUrl additionalHeaders:(nullable NSDictionary*)headers completion:(nullable LPGetImageOperationCompletion)completion;


@end
