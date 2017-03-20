//
//  LPProjectEntityPrivate.h
//  LivePaperSDK
//
//  Created by Alejandro Mendez on 1/27/17.
//  Copyright © 2017 Hewlett-Packard. All rights reserved.
//

#import "LPProjectEntity.h"
#import "LPBaseEntityPrivate.h"

@interface LPProjectEntity ()

@property (nonatomic) NSString *projectId;

+ (void)entityCreateWithDictionary:(NSDictionary *)dictionary projectId:(NSString *)projectId session:(LPSession *)session completion:(void (^)(id entity, NSError *error))completion;

+ (void)entityList:(LPSession *)session projectId:(NSString *)projectId completion:(void (^)(NSArray *projectEntity, NSError *error)) handler;

+ (void)entityGet:(NSString *)identifier projectId:(NSString *)projectId session:(LPSession *)session completion:(void (^)(id entity, NSError *error))completion;

@end


