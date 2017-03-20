//
//  LPGetImage.m
//  LivePaperSDK
//
//  Created by Alejandro Mendez on 2/8/17.
//  Copyright © 2017 Hewlett-Packard. All rights reserved.
//

#import "LPGetImageOperation.h"
#import "LRBaseNetworkOperation+Private.h"
#import "LPSessionPrivate.h"
#import "HPLinkNetworkingHelper.h"

@interface LPGetImageOperation ()

@property (nonatomic, copy, nullable) LPGetImageOperationCompletion completion;
@property (nonatomic, nullable) NSURL *imageUrl;
@property (nonatomic, nullable) LPSession *session;
@property (nonatomic, nullable) NSString *projectId;
@property (nonatomic, nullable) NSDictionary *headers;

@end

@implementation LPGetImageOperation

+ (instancetype)executeWithSession:(LPSession *)session imageUrl:(NSURL *)imageUrl projectId:(NSString*)projectId completion:(LPGetImageOperationCompletion)completion {
    
    LPGetImageOperation *operation = [[[self class] alloc] initWithSession:session imageUrl:imageUrl projectId:projectId completion:completion];
    [[HPLinkOperationQueue sharedQueue] addOperation:operation];
    return operation;
}

+ (instancetype)executeWithImageUrl:(NSURL *)imageUrl additionalHeaders:(NSDictionary*)headers completion:(LPGetImageOperationCompletion)completion {
    
    LPGetImageOperation *operation = [[[self class] alloc] initWithImageUrl:imageUrl
                                                          additionalHeaders:headers completion:completion];
    [[HPLinkOperationQueue sharedQueue] addOperation:operation];
    return operation;
}

- (instancetype)initWithSession:(LPSession *)session imageUrl:(NSURL *)imageUrl projectId:(NSString*)projectId completion:(LPGetImageOperationCompletion)completion {
    if (self = [super init]) {
        _session = session;
        _imageUrl = imageUrl;
        _projectId = projectId;
        _completion = completion;
        _headers = @{@"Accept" : @"image/jpg, image/jpeg" };
    }
    return self;
}

- (instancetype)initWithImageUrl:(NSURL *)imageUrl additionalHeaders:(NSDictionary*)headers completion:(LPGetImageOperationCompletion)completion {
    if (self = [super init]) {
        _imageUrl = imageUrl;
        _headers = headers;
    }
    return self;
}


-(void)executeOperation {
    NSMutableURLRequest *request = [HPLinkNetworkingHelper requestWithMethod:HPHttpMethodGet url:self.imageUrl data:nil headers:self.headers];
    
    HPLinkBaseNetworkOperationCompletion completion = ^(id  _Nullable data, NSHTTPURLResponse * _Nullable response, NSError * _Nullable error) {
        [self handleResponseWithData:data response:response error:error];
    };
    
    LPBaseNetworkOperation *operation;
    if (self.session) {
        operation = [[LPAuthenticatedNetworkOperation alloc] initWithSession:self.session request:request completion:completion];
    }else {
        operation = [[LPBaseNetworkOperation alloc] initWithSession:self.session request:request completion:completion];
    }
    operation.progressCallback = self.progressCallback;
    operation.requestDeserializer = nil;
    [[HPLinkOperationQueue sharedQueue] addOperation:operation];
}

- (void)handleResponseWithData:(NSData *)data  response:(NSHTTPURLResponse *)response error:(NSError *)error {
    UIImage *image;
    if (data && !error) {
        image = [UIImage imageWithData:data];
        if (!image) {
            error = [NSError errorWithDomain:[LPErrors domainName] code:LPInternalErrorCode_ResponseDataError userInfo:@{NSLocalizedDescriptionKey: @"Unable to create image from response data."}];
        }
    }
    if (self.completion) {
        self.completion(image, data, response, error);
    }
    [self finishOperation:error];
}

@end
