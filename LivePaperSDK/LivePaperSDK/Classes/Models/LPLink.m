//
//  LPLink.m
//  LivePaperSDK
//
//  Created by Alejandro Mendez on 1/12/17.
//  Copyright © 2017 Hewlett-Packard. All rights reserved.
//


#import "LPLink.h"
#import "LPSession.h"
#import "LPSessionPrivate.h"
#import "LPProjectEntityPrivate.h"

#define LP_LINKS_URI  @"/api/v2/links"

@interface LPLink () <LPBaseEntity>

@property (nonatomic) NSString *triggerId;
@property (nonatomic) NSString *payoffId;

@end

@implementation LPLink

- (instancetype)initWithSession:(LPSession *)session dictionary:(NSDictionary *)dictionary {
    if (self = [super initWithSession:session dictionary:dictionary]) {
        
        NSString *triggerId = dictionary[@"triggerId"];
        NSString *payoffId = dictionary[@"payoffId"];
        
        if(!triggerId || !payoffId){
            return nil;
        }
        _triggerId = triggerId;
        _payoffId = payoffId;        
    }
    return self;
}

#pragma mark - Public methods

+ (void)createWithName:(NSString *)name triggerId:(NSString *)triggerId payoffId:(NSString *)payoffId projectId:(NSString *)projectId session:(LPSession *)session completion:(void (^)(LPLink * link, NSError *error))completion
{
    NSDictionary *linkDictionary = @{
                                     @"name" : name,
                                     @"payoffId" : payoffId,
                                     @"triggerId" : triggerId
                                     };
    [self entityCreateWithDictionary:@{ @"link" : linkDictionary } projectId:projectId session:session completion:completion];    
}

+ (void)get:(NSString *)identifier projectId:(NSString *)projectId session:(LPSession *)session completion:(void (^)(LPLink * link, NSError *error))completion{
    [self entityGet:identifier projectId:projectId session:session completion:completion];
}

+ (void)list:(LPSession *)session projectId:(NSString *)projectId completion:(void (^)(NSArray <LPLink *> *links, NSError *error)) completion{
    [self entityList:session projectId:projectId completion:completion];
}

#pragma mark <LPBaseEntity>

- (void)clearEntityValues {
    [super clearEntityValues];
    self.triggerId = nil;
    self.payoffId = nil;
}

+(NSString *)entityName {
    return @"link";
}

-(NSDictionary *)dictionaryRepresentationForEdit {
    return @{
             [[self class] entityName]:@{
                @"name" : [self name] ?: @""
             }
             };
}

@end
