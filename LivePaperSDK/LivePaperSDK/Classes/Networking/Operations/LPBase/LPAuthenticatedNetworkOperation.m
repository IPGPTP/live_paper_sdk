//
//  LPLppNetworkOperation.m
//  LivePaperSDK
//
//  Created by Alejandro Mendez on 12/12/16.
//  Copyright © 2016 Hewlett-Packard. All rights reserved.
//

#import "LPAuthenticatedNetworkOperation.h"
#import "LRBaseNetworkOperation+Private.h"
#import "LPGetTokenOperation.h"
#import "LPSessionPrivate.h"

@implementation LPAuthenticatedNetworkOperation

- (NSURLRequest *)prepareRequest {
    NSMutableURLRequest * request = [super prepareRequest].mutableCopy;
    [request addValue:[NSString stringWithFormat:@"Bearer %@", self.lpSession.accessToken] forHTTPHeaderField:@"Authorization"];
    [request addValue:@"app=iossdk" forHTTPHeaderField:@"X-user-info"];
    return request;
}

- (void)handleErrorWithData:(NSData *)data response:(NSHTTPURLResponse *)response error:(NSError *)error{
    if (response.statusCode == 401) {
        if ([self canRetry]) {
            LPGetTokenOperation * operation = [[LPGetTokenOperation alloc] initWithSession:self.lpSession queue:self.operationQueue completion:^(id  _Nullable data, NSHTTPURLResponse * _Nullable response, NSError * _Nullable authError) {
                if (authError) {
                    [super handleErrorWithData:data response:response error:authError];
                }else{
                    [self retryOperation];
                }
            }];
            [[HPLinkOperationQueue sharedQueue] addOperation:operation];
        }else{
            [super handleErrorWithData:data response:response error:[NSError errorWithDomain:[LPErrors domainName] code:LPInternalErrorCode_AuthenticationFailure userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Unable to authenticate with LivePaper platform. Please verify your credentials and try again. Trying to access: %@", response.URL.absoluteString] }]];
        }
    }else{
        [super handleErrorWithData:data response:response error:error];
    }
}

@end
