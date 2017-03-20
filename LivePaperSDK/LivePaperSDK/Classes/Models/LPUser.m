//
//  LPUser.m
//  LivePaperSDK
//
//  Created by Alejandro Mendez on 1/13/17.
//  Copyright © 2017 Hewlett-Packard. All rights reserved.
//

#import "LPUser.h"
#import "LPBaseEntityPrivate.h"

@interface LPUser () <LPBaseEntity>

@property (nonatomic) NSString *firstName;
@property (nonatomic) NSString *lastName;
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *email;
@property (nonatomic) NSString *accountId;

@end

@implementation LPUser

- (instancetype)initWithSession:(LPSession *)session dictionary:(NSDictionary *)dictionary
{
    if (self = [super init]) {
        if (!dictionary || ![dictionary isKindOfClass:[NSDictionary class]]) {
            return nil;
        }
        
        NSString *firstName = dictionary[@"firstName"];
        NSString *lastName = dictionary[@"lastName"];
        NSString *name = dictionary[@"name"];
        NSString *email = dictionary[@"email"];
        NSString *accountId;
        
        NSArray *links = dictionary[@"link"];
        for (NSDictionary *link in links) {
            if ([link isKindOfClass:[NSDictionary class]] && [link[@"rel"] isKindOfClass:[NSString class]]) {
                if ([link[@"rel"] isEqualToString:@"defaultAccount"]) {
                    accountId = [[link[@"href"] componentsSeparatedByString:@"/"] lastObject];
                }
            }
        }
        
        if(!firstName || !lastName || !name || !email || !accountId){
            return nil;
        }
        
        _firstName = firstName;
        _lastName = lastName;
        _name = name;
        _email = email;
        _accountId = accountId;
    }
    return self;
}

+ (void)get:(NSString *)identifier session:(LPSession *)session completion:(void (^)(LPUser * project, NSError *error))completion
{
    [self baseGet:identifier session:session completion:completion];
}

#pragma mark Private methods

+ (NSString*)baseUrlSuffix {
    return @"/auth/v2";
}

#pragma mark LPBaseEntity

- (NSDictionary *)dictionaryRepresentationForEdit {
    return nil;
}

+ (NSString *)entityName {
    return @"user";
}

+ (instancetype)entityFromDictionary:(NSDictionary *)dictionary session:(LPSession *)session {
    if (!dictionary || ![dictionary isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    NSString *identifier = dictionary[@"clientId"];
    NSString *firstName = dictionary[@"firstName"];
    NSString *lastName = dictionary[@"lastName"];
    NSString *name = dictionary[@"name"];
    NSString *email = dictionary[@"email"];
    NSString *accountId  = nil;
    
    NSArray *links = dictionary[@"link"];
    for (NSDictionary *link in links) {
        if ([link isKindOfClass:[NSDictionary class]] && [link[@"rel"] isKindOfClass:[NSString class]]) {
            if ([link[@"rel"] isEqualToString:@"defaultAccount"]) {
                accountId = [[link[@"href"] componentsSeparatedByString:@"/"] lastObject];
            }
        }
    }
    
    if(identifier && firstName && lastName && name && email && accountId){
        LPUser *user = [LPUser new];
        user.identifier = identifier;
        user.firstName = firstName;
        user.name = name;
        user.email = email;
        user.accountId = accountId;
        return user;
    }
    return nil;
}

@end
