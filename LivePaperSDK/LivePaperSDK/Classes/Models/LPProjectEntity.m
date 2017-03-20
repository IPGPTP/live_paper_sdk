//
//  LPProjectEntity.m
//  LivePaperSDK
//
//  Created by Alejandro Mendez on 1/27/17.
//  Copyright © 2017 Hewlett-Packard. All rights reserved.
//

#import "LPProjectEntityPrivate.h"

@implementation LPProjectEntity

- (instancetype)initWithSession:(LPSession *)session dictionary:(NSDictionary *)dictionary {
    if (self = [super initWithSession:session dictionary:dictionary]) {
        NSString *projectId = dictionary[@"projectId"];
        NSString *name = dictionary[@"name"];
        if(!projectId || !name){
            return nil;
        }
        _projectId = projectId;
        _name = name;
    }
    return self;
}

- (void)update:(void (^)(NSError *))completion {
    [self baseUpdateWithContainerResource:[[self class] containerWithIdentifier:[self projectId]] session:[self session] completion:completion];
}

- (void)delete:(void (^)(NSError *))completion {
    [self baseDeleteWithContainerResource:[[self class] containerWithIdentifier:[self projectId]] completion:completion];
}

#pragma mark Protected methods

+ (void)entityCreateWithDictionary:(NSDictionary *)dictionary projectId:(NSString *)projectId session:(LPSession *)session completion:(void (^)(id entity, NSError *error))completion {
    
    return [self baseCreateWithContainerResource:[[self class] containerWithIdentifier:projectId] dictionary:dictionary session:session completion:completion];
}

+ (void)entityList:(LPSession *)session projectId:(NSString *)projectId completion:(void (^)(NSArray *links, NSError *error)) handler {
    [self baseListWithContainerResource:[self containerWithIdentifier:projectId] session:session completion:handler];
}

+ (void)entityGet:(NSString *)identifier projectId:(NSString *)projectId session:(LPSession *)session completion:(void (^)(id entity, NSError *error))completion{
    [self baseGetWithContainerResource:[self containerWithIdentifier:projectId] identifier:identifier session:session completion:completion];
}

#pragma mark Private methods

+ (LPContainerResource *)containerWithIdentifier:(NSString *)identifier {
    return [LPContainerResource resourceWithEntityName:@"projects" identifier:identifier];
}

#pragma mark LPBaseEntity

- (void)clearEntityValues {
    [super clearEntityValues];
    self.name = nil;
    self.projectId = nil;
}


@end
