//
//  LPGetTokenOperation.m
//  LivePaperSDK
//
//  Created by Alejandro Mendez on 12/9/16.
//  Copyright © 2016 Hewlett-Packard. All rights reserved.
//

#import "LPGetTokenOperation.h"
#import "LRBaseNetworkOperation+Private.h"
#import "LPSessionPrivate.h"

@implementation LPGetTokenOperation

+ (instancetype)executeWithSession:(LPSession *)session completion:(HPLinkBaseNetworkOperationCompletion)completion{
    return [super executeWithSession:session request:nil completion:completion];
}

- (instancetype)initWithSession:(LPSession *)session queue:(NSOperationQueue *)queue completion:(HPLinkBaseNetworkOperationCompletion)completion{
    
    if (self = [super initWithSession:session request:nil completion:completion]){
    }
    return self;
}

+ (NSURL *)tokenUrl:(LPSession *)session {
    return [[session baseURL] URLByAppendingPathComponent:@"auth/v2/token"];
}

- (NSURLRequest *)prepareRequest {
    NSMutableURLRequest *request = [super prepareRequest].mutableCopy;
    
    NSString *authorizationString = [[[NSString stringWithFormat:@"%@:%@", self.lpSession.clientId, self.lpSession.secret] dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
    [request addValue:[NSString stringWithFormat:@"Basic %@", authorizationString] forHTTPHeaderField:@"Authorization"];
    [request setHTTPBody:[@"grant_type=client_credentials&scope=default" dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPMethod: @"POST"];
    [request setURL:[[self class] tokenUrl:self.lpSession]];
    return request;
}

-(void)finishOperationWithData:(id)data response:(NSHTTPURLResponse *)response error:(NSError *)error{
    NSString *token;
    if (!error) {
        if (data && [data isKindOfClass:[NSDictionary class]]) {
            NSDictionary *jsonDict = (NSDictionary*)data;
            if (jsonDict[@"accessToken"]) {
                token = jsonDict[@"accessToken"];
            }
        }
        if (token && token.length > 0) {
            self.lpSession.accessToken = token;
        }else{
            error = [NSError errorWithDomain:[LPErrors domainName] code:LPInternalErrorCode_MalformedResponse userInfo:@{NSLocalizedDescriptionKey: @"Access token not found"}];
        }
        
    }
    [super finishOperationWithData:token response:response error:error];
}


@end
