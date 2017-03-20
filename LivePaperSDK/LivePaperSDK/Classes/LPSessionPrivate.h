//
//  LPSession.m
//  LivePaperSDK
//
//  Created by Alejandro Mendez on 1/12/17.
//  Copyright © 2017 Hewlett-Packard. All rights reserved.
//

#import "LPSession.h"
#import "LPStack.h"
#import "LPUser.h"

@interface LPSession ()

@property (nonatomic, readonly) NSString *clientId;
@property (nonatomic, readonly) NSString *secret;
@property (nonatomic, readonly) LPStack stack;
@property (nonatomic, readonly) NSURL *baseURL;
@property (nonatomic, readonly) NSURL *baseStorageURL;

@property (nonatomic) LPUser *user;
@property (nonatomic) NSString *defaultProjectId;
@property (nonatomic) NSString *accessToken;


- (instancetype) initWithClientId:(NSString *)clientId secret:(NSString *)secret stack:(LPStack)stack;

@end

