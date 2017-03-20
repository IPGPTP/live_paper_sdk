//
//  LPGetTokenOperation.h
//  LivePaperSDK
//
//  Created by Alejandro Mendez on 12/9/16.
//  Copyright © 2016 Hewlett-Packard. All rights reserved.
//

#import "LPBaseNetworkOperation.h"
#import "LpSession.h"

@interface LPGetTokenOperation : LPBaseNetworkOperation

+ (instancetype)executeWithSession:(LPSession *)session completion:(HPLinkBaseNetworkOperationCompletion)completion;

- (instancetype)initWithSession:(LPSession *)session queue:(NSOperationQueue *)queue completion:(HPLinkBaseNetworkOperationCompletion)completion;

@end
