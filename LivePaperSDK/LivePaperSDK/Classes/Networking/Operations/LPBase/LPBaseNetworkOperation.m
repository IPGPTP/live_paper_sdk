//
//  LRBaseLppOperation.m
//  LinkReaderSDK
//
//  Created by Alejandro Mendez on 11/3/16.
//  Copyright © 2016 HP. All rights reserved.
//

#import "LRBaseNetworkOperation+Private.h"

@implementation LPBaseNetworkOperation

+ (instancetype)executeWithSession:(LPSession *)session request:(NSURLRequest *)request completion:(HPLinkBaseNetworkOperationCompletion)completion{
    
    LPBaseNetworkOperation *operation = [[[self class] alloc] initWithSession:session request:request completion:completion];
    [[HPLinkOperationQueue sharedQueue] addOperation:operation];
    return operation;
    
}

- (instancetype)initWithSession:(LPSession *)session request:(NSURLRequest *)request completion:(HPLinkBaseNetworkOperationCompletion)completion{
    if (self = [super initWithRequest:request completion:completion]) {
        _lpSession = session;
    }
    return self;
}


- (LPSession *)lpSession {
    return _lpSession;
}

- (void)populateError:(NSError **)error withData:(NSData *)data response:(NSHTTPURLResponse *)httpResponse {
    
     NSString *responseData = data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : @"";
     NSString *errorMessage;
     if ([[httpResponse allHeaderFields][@"Content-Type"] isEqualToString:@"application/json"]) {
         NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:error];
         if (responseDictionary[@"error"] && [responseDictionary[@"error"] isKindOfClass:[NSArray class]]) {
             NSArray *error = responseDictionary[@"error"];
             if (error.firstObject &&
                 [error.firstObject isKindOfClass:[NSDictionary class]] &&
                 error.firstObject[@"errorDescription"]) {
                 errorMessage = error.firstObject[@"errorDescription"];
             }
         }
     }
     if (!errorMessage) {
         errorMessage = [NSString stringWithFormat:@"Error with status: %zd", httpResponse.statusCode];
     }
     
     *error = [NSError errorWithDomain:[LPErrors domainName] code:LPInternalErrorCode_RequestError userInfo:@{NSLocalizedDescriptionKey: errorMessage, LPErrorResponseStatusKey: @(httpResponse.statusCode), LPErrorResponseDataKey: responseData  }];
}

@end
