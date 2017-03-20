//
//  LPPayoff.m
//  LivePaperSDK
//
//  Created by Alejandro Mendez on 1/12/17.
//  Copyright © 2017 Hewlett-Packard. All rights reserved.
//

#import "LPPayoff.h"
#import "LPSessionPrivate.h"
#import "LPProjectEntityPrivate.h"

static NSString * const LPPayoffTypeUrlValue = @"url";
static NSString * const LPPayoffTypeRichValue = @"richpayoff";
static NSString * const LPPayoffTypeCustomValue = @"custom";
static NSString * const LPPayoffTypeAdvancedValue = @"advanced";

@interface LPPayoff () <LPBaseEntity>

@property(nonatomic) LPPayoffType type;

@end

@implementation LPPayoff

#pragma mark - Private methods

- (instancetype) initWithSession:(LPSession *) session dictionary:(NSDictionary *)dictionary;
{
    self = [super initWithSession:session dictionary:dictionary];
    if (self) {
        NSString *type = dictionary[@"type"];
        if(!type){
            return nil;
        }
        
        if ([type isEqualToString:LPPayoffTypeUrlValue]) {
            _type = LPPayoffTypeUrl;
        }else if ([type isEqualToString:LPPayoffTypeRichValue]) {
            _type = LPPayoffTypeRich;
        }else if ([type isEqualToString:LPPayoffTypeCustomValue] ||
                  [type isEqualToString:LPPayoffTypeAdvancedValue]) {
            _type = LPPayoffTypeCustom;
        }else{
            return nil;
        }
        switch (_type) {
            case LPPayoffTypeUrl:{
                NSString *url = dictionary[@"url"];
                if(!url){
                    return nil;
                }
                _url = [NSURL URLWithString:url];
                break;
            }
            case LPPayoffTypeRich:{
                NSDictionary *richPayoff = dictionary[@"richPayoff"];
                NSDictionary *private = richPayoff[@"private"];
                NSDictionary *public = richPayoff[@"public"];
                if (!richPayoff || !private || !public) {
                    return nil;
                }
                _richPayoffPublicUrl = [NSURL URLWithString:[public objectForKey:@"url"]];
                NSString *base64EncodedString = [private objectForKey:@"data"];
                NSData *data = [[NSData alloc] initWithBase64EncodedString:base64EncodedString options:NSDataBase64DecodingIgnoreUnknownCharacters];
                NSError *jsonError = nil;
                _richPayoffData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                break;
            }
            case LPPayoffTypeCustom :
                if ([type isEqualToString:LPPayoffTypeAdvancedValue]) {
                    
                }
        }
        
    }
    return self;
}

#pragma mark - Public methods

+ (void)createWithDictionary:(NSDictionary *)dictionary projectId:(NSString *)projectId session:(LPSession *)session completion:(void (^)(LPPayoff *payoff, NSError *error))completion
{
    [self entityCreateWithDictionary:dictionary projectId:projectId session:session completion:completion];
}

+ (void)createWebPayoffWithName:(NSString *)name url:(NSURL *) url projectId:(NSString *)projectId session:(LPSession *)session completion:(void (^)(LPPayoff *payoff, NSError *error))completion
{
    NSDictionary *dictionary = @{ @"payoff" : @{
                                        @"name" : name ?: @"",
                                        @"url" : [url absoluteString],
                                        @"type" : @"url"
                                    }
                                };
    [self createWithDictionary:dictionary projectId:projectId session:session completion:completion];
}

+ (void)createRichPayoffWithName:(NSString *)name publicURL:(NSURL *)publicURL richPayoffData:(NSDictionary *)richPayoffData projectId:(NSString *)projectId session:(LPSession *)session  completion:(void (^)(LPPayoff *payoff, NSError *error))completion
{
    NSError *jsonError = nil;
    NSString *base64EncodedRichPayoffData = [[NSJSONSerialization dataWithJSONObject:richPayoffData options:0 error:&jsonError] base64EncodedStringWithOptions:0];
    NSDictionary *richPayoff = @{
                                 @"version" : @"1.0",
                                 @"private" : @{
                                         @"content-type" : @"custom-base64",
                                         @"data" : base64EncodedRichPayoffData
                                         },
                                 @"public" : @{
                                         @"url" : [publicURL absoluteString] ?: @""
                                         },
                                 @"type" : @"content action layout"
                                 };
    NSDictionary *dictionary = @{ @"payoff" : @{
                                          @"name" : name ?: @"",
                                          @"richPayoff" : richPayoff ?: @"",
                                          @"type" : @"richpayoff"
                                        }
                                };
    [self createWithDictionary:dictionary projectId:projectId session:session completion:completion];
}

+ (void)get:(NSString *)identifier projectId:(NSString *)projectId session:(LPSession *)session completion:(void (^)(LPPayoff * entity, NSError *error))completion{
    [self entityGet:identifier projectId:projectId session:session completion:completion];
}

+ (void)list:(LPSession *)session projectId:(NSString *)projectId completion:(void (^)(NSArray <LPPayoff *> *links, NSError *error)) completion {
    [self entityList:session projectId:projectId completion:completion];
}

#pragma mark Private

+ (NSString *)stringFromType:(LPPayoffType)type{
    switch (type) {
        case LPPayoffTypeUrl:
            return LPPayoffTypeUrlValue;
        case LPPayoffTypeRich:
            return LPPayoffTypeRichValue;
        case LPPayoffTypeCustom:
            return LPPayoffTypeCustomValue;
    }
}

#pragma mark <LPBaseEntity>

+(NSString *)entityName {
    return @"payoff";
}

-(NSDictionary *)dictionaryRepresentationForEdit {
    
    NSMutableDictionary *payoffDictionary = [NSMutableDictionary dictionaryWithDictionary: @{ @"name" : self.name }];
    [payoffDictionary setValue:[[self class] stringFromType:self.type] forKey:@"type"];
    switch (self.type) {
        case LPPayoffTypeUrl:{
            [payoffDictionary setValue:[_url absoluteString] forKey:@"url"];
            break;
        }
        case LPPayoffTypeRich:{
            NSError *jsonError = nil;
            NSString *base64EncodedRichPayoffData = [[NSJSONSerialization dataWithJSONObject:_richPayoffData options:0 error:&jsonError] base64EncodedStringWithOptions:0];
            NSDictionary *richPayoff = @{
                                         @"version" : @"1.0",
                                         @"private" : @{
                                                 @"content-type" : @"custom-base64",
                                                 @"data" : base64EncodedRichPayoffData
                                                 },
                                         @"public" : @{
                                                 @"url" : [_richPayoffPublicUrl absoluteString]
                                                 },
                                         @"type" : @"content action layout"
                                         };
            [payoffDictionary setValue:richPayoff forKey:@"richPayoff"];
            break;
        }
        default:
            break;
    }
    
    return @{
             [[self class] entityName]:payoffDictionary
             };
}


@end
