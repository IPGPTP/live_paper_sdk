//
//  LPErrors.h
//  LivePaperSDK
//
//  Created by Alejandro Mendez on 1/12/17.
//  Copyright © 2017 Hewlett-Packard. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, LPInternalErrorCode) {
    LPInternalErrorCode_BadParameters,
    LPInternalErrorCode_EntityError,
    LPInternalErrorCode_MalformedResponse,
    LPInternalErrorCode_ResponseDataError,
    LPInternalErrorCode_RequestError,
    LPInternalErrorCode_AuthenticationFailure
};

FOUNDATION_EXPORT NSString *const LPErrorResponseStatusKey;
FOUNDATION_EXPORT NSString *const LPErrorResponseDataKey;


@interface LPErrors : NSObject

+ (NSString *)domainName;

@end
