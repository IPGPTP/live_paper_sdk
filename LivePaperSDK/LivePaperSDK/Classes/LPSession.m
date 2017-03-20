//
//  LPSession.m
//  LivePaperSDK
//
//  Copyright (c) 2015 Hewlett-Packard. All rights reserved.
//

#import <LivePaperSDK/LPProject.h>
#import "LPSessionPrivate.h"
#import "LPTrigger.h"
#import "LPPayoff.h"
#import "LPLink.h"
#import "LPConfiguration.h"
#import "LPGetTokenOperation.h"

@implementation LPSession

- (instancetype) initWithClientId:(NSString *)clientId secret:(NSString *)secret stack:(LPStack)stack
{
    self = [super init];
    if (self) {
        _clientId = clientId;
        _secret = secret;
        _stack = stack;
        _baseURL = [NSURL URLWithString:[LPConfiguration baseUrlForStack:stack]];
        _baseStorageURL = [NSURL URLWithString:[LPConfiguration baseStorageUrlForStack:stack]];
    }
    return self;
}

+ (instancetype) createSessionWithClientId:(NSString *)clientId secret:(NSString *)secret stack:(LPStack)stack {
    return [[LPSession alloc] initWithClientId:clientId secret:secret stack:stack];
}

+ (instancetype) createSessionWithClientId:(NSString *)clientId secret:(NSString *)secret
{
    return [self createSessionWithClientId:clientId secret:secret stack:LPStack_Production];
}

+ (NSString*) version {
    NSDictionary *infoDictionary = [[NSBundle bundleForClass: [self class]] infoDictionary];
    return [infoDictionary valueForKey:@"CFBundleShortVersionString"];
}

- (void)retrieveAccessToken:(void (^)(NSString *, NSError *))completion
{
    [LPGetTokenOperation executeWithSession:self completion:^(id  _Nullable data, NSHTTPURLResponse * _Nullable response, NSError * _Nullable error) {
        completion(data, error);
    }];    
}

- (void)createShortUrl:(NSString *)name destination:(NSURL *)url completion:(void (^)(NSURL *, NSError *))completion
{
    if (!self.defaultProjectId) {
        [LPProject getDefaultProjectIdWithSession:self completion:^(NSString * _Nullable projectId, NSError * _Nullable error) {
            if (error) {
                if (completion) {
                    completion(nil, error);
                }
            }else{
                [self createShortUrl:name destination:url completion:completion];
            }
        }];
        return;
    }
    
    [LPTrigger createShortUrlWithName:name projectId:self.defaultProjectId session:self completion:^(LPTrigger *trigger, NSError *error) {
        if (error) {
            if (completion) {
                completion(nil, error);
            }
            return;
        }
        [LPPayoff createWebPayoffWithName:name url:url projectId:self.defaultProjectId session:self completion:^(LPPayoff *payoff, NSError *error) {
            if (error) {
                if (completion) {
                    completion(nil, error);
                }
                return;
            }
            [LPLink createWithName:name triggerId:trigger.identifier payoffId:payoff.identifier projectId:self.defaultProjectId session:self completion:^(LPLink * link, NSError *error) {
                if (completion) {
                    if (error) {
                        completion(nil, error);
                    }else{
                        completion(trigger.shortURL, nil);
                    }
                }
            }];
        }];
    }];
}


- (void)createQrCode:(NSString *)name destination:(NSURL *)url completion:(void (^)(UIImage *image, NSError *error))completion
{
    if (!self.defaultProjectId) {
        [LPProject getDefaultProjectIdWithSession:self completion:^(NSString * _Nullable projectId, NSError * _Nullable error) {
            if (error) {
                if (completion) {
                    completion(nil, error);
                }
            }else{
                [self createQrCode:name destination:url completion:completion];
            }
        }];
        return;
    }
    
    [LPTrigger createQrCodeWithName:name projectId:self.defaultProjectId session:self completion:^(LPTrigger *trigger, NSError *error) {
        if (error) {
            if (completion) {
                completion(nil, error);
            }
            return;
        }
        [LPPayoff createWebPayoffWithName:name url:url projectId:self.defaultProjectId session:self completion:^(LPPayoff *payoff, NSError *error) {
            if (error) {
                if (completion) {
                    completion(nil, error);
                }
                return;
            }
            [LPLink createWithName:name triggerId:trigger.identifier payoffId:payoff.identifier projectId:self.defaultProjectId session:self completion:^(LPLink * link, NSError *error) {
                if (completion) {
                    if (error) {
                        completion(nil, error);
                    }else{
                        [trigger getQrCodeImageWithProgress:nil completion:completion];
                    }
                }
            }];
        }];
    }];
}

- (void)createWatermark:(NSString *)name destination:(NSURL *)url imageData:(NSData*)imageData completion:(void (^)(UIImage *watermarkedImage, NSError *error))completion
{
    if (!self.defaultProjectId) {
        [LPProject getDefaultProjectIdWithSession:self completion:^(NSString * _Nullable projectId, NSError * _Nullable error) {
            if (error) {
                if (completion) {
                    completion(nil, error);
                }
            }else{
                [self createWatermark:name destination:url imageData:imageData completion:completion];
            }
        }];
        return;
    }
    
    [LPTrigger createWatermarkWithName:name projectId:self.defaultProjectId session:self completion:^(LPTrigger *trigger, NSError *error) {
        if (error) {
            if (completion) {
                completion(nil, error);
            }
            return;
        }
        [LPPayoff createWebPayoffWithName:name url:url projectId:self.defaultProjectId session:self completion:^(LPPayoff *payoff, NSError *error) {
            if (error) {
                if (completion) {
                    completion(nil, error);
                }
                return;
            }
            [LPLink createWithName:name triggerId:trigger.identifier payoffId:payoff.identifier projectId:self.defaultProjectId session:self completion:^(LPLink * link, NSError *error) {
                if (completion) {
                    if (error) {
                        completion(nil, error);
                    }else{
                        [trigger getWatermarkForImageData:imageData progress:nil completion:completion];
                    }
                }
            }];
        }];
    }];
}

- (void)createWatermark:(NSString *)name richPayoffData:(NSDictionary *)richPayoffData publicURL:(NSURL *)publicURL imageData:(NSData *)imageData completion:(void (^)(UIImage *watermarkedImage, NSError *error))completion
{
    if (!self.defaultProjectId) {
        [LPProject getDefaultProjectIdWithSession:self completion:^(NSString * _Nullable projectId, NSError * _Nullable error) {
            if (error) {
                if (completion) {
                    completion(nil, error);
                }
            }else{
                [self createWatermark:name richPayoffData:richPayoffData publicURL:publicURL imageData:imageData completion:completion];
            }
        }];
        return;
    }
    
    [LPTrigger createWatermarkWithName:name projectId:self.defaultProjectId session:self completion:^(LPTrigger *trigger, NSError *error) {
        if (error) {
            if (completion) {
                completion(nil, error);
            }
            return;
        }
        [LPPayoff createRichPayoffWithName:name publicURL:publicURL richPayoffData:richPayoffData projectId:self.defaultProjectId session:self completion:^(LPPayoff *payoff, NSError *error) {
            if (error) {
                if (completion) {
                    completion(nil, error);
                }
                return;
            }
            [LPLink createWithName:name triggerId:trigger.identifier payoffId:payoff.identifier projectId:self.defaultProjectId session:self completion:^(LPLink * link, NSError *error) {
                if (completion) {
                    if (error) {
                        completion(nil, error);
                    }else{
                        [trigger getWatermarkForImageData:imageData progress:nil completion:completion];
                    }
                }
            }];
        }];
    }];
}


@end
