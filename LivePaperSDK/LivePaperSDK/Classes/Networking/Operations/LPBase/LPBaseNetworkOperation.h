//
//  LRBaseLppOperation.h
//  LinkReaderSDK
//
//  Created by Alejandro Mendez on 11/3/16.
//  Copyright © 2016 HP. All rights reserved.
//

#import <HPLinkUtils/HPLinkBaseNetworkOperation.h>
#import "LPSessionPrivate.h"
#import "LPErrors.h"

@interface LPBaseNetworkOperation : HPLinkBaseNetworkOperation

+ (nullable instancetype)executeWithSession:(nonnull LPSession *)session request:(nullable NSURLRequest *)request completion:(nullable HPLinkBaseNetworkOperationCompletion)completion;

- (nullable instancetype)initWithSession:(nonnull LPSession *)session request:(nullable NSURLRequest *)request completion:(nullable HPLinkBaseNetworkOperationCompletion)completion;


@end
