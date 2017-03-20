//
//  LPUser.h
//  LivePaperSDK
//
//  Created by Alejandro Mendez on 1/13/17.
//  Copyright © 2017 Hewlett-Packard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LivePaperSDK/LPSession.h>
#import <LivePaperSDK/LPBaseEntity.h>

@interface LPUser : LPBaseEntity

@property (nonatomic, readonly) NSString *firstName;
@property (nonatomic, readonly) NSString *lastName;
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *email;
@property (nonatomic, readonly) NSString *accountId;


+ (void)get:(NSString *)identifier session:(LPSession *)session completion:(void (^)(LPUser * project, NSError *error))completion;

@end
