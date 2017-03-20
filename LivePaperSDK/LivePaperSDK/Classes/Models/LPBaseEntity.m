//
//  LpBaseEntity.m
//  LivePaperSDK
//
//  Created by Alejandro Mendez on 1/13/17.
//  Copyright © 2017 Hewlett-Packard. All rights reserved.
//

#import "LPBaseEntityPrivate.h"
#import "LPErrors.h"

@implementation LPBaseEntity

- (instancetype)initWithSession:(LPSession *)session dictionary:(NSDictionary *)dictionary
{
    if (self = [super init]) {
        if (!dictionary || ![dictionary isKindOfClass:[NSDictionary class]]) {
            return nil;
        }
        
        NSString *identifier = dictionary[@"id"];
        NSArray *atomLinks = dictionary[@"link"];
        NSString *dateCreated = dictionary[@"dateCreated"];
        NSString *dateModified = dictionary[@"dateModified"];
        
        if(!identifier || !atomLinks || !dateCreated || !dateModified){
            return nil;
        }
        _identifier = identifier;
        _atomLinks = atomLinks;
        _dateCreated = dateCreated;
        _dateModified = dateModified;
        _session = session;
        _rawData = dictionary;
    }
    return self;
}


+ (void)baseGet:(NSString *)identifier session:(LPSession *)session completion:(void (^)(id instance, NSError *error))completion
{
    [self baseGetWithContainerResource:nil identifier:identifier session:session completion:completion];
}

+ (void)baseGetWithContainerResource:(LPContainerResource *)containerResource identifier:(NSString *)identifier session:(LPSession *)session completion:(void (^)(id instance, NSError *error))completion
{
    NSURL * url = [self baseUrlWithContainerResource:containerResource session:session identifier:identifier];
    NSMutableURLRequest *request = [HPLinkNetworkingHelper requestWithMethod:HPHttpMethodGet url:url data:nil headers:[self commonHeaders]];
    [LPAuthenticatedNetworkOperation executeWithSession:session request:request completion:^(id data, NSHTTPURLResponse * response, NSError * error) {
        id instance = nil;
        if (!error) {
            instance = [[self alloc] initWithSession:session dictionary:data[[self entityName]]];
            if (!instance) {
                error = [self malformedResponseError:data];
            }
        }
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
               completion(instance, error);
            });
        }
    }];
}

+ (void)baseCreateWithDictionary:(NSDictionary *)dictionary session:(LPSession *)session completion:(void (^)(id instance, NSError *error))completion {
    [self baseCreateWithContainerResource:nil dictionary:dictionary session:session completion:completion];
}

+ (void)baseCreateWithContainerResource:(LPContainerResource *)containerResource dictionary:(NSDictionary *)dictionary session:(LPSession *)session completion:(void (^)(id instance, NSError *error))completion {
    
    NSURL * url = [self baseUrlWithContainerResource:containerResource session:session identifier:nil];
    NSMutableURLRequest *request = [HPLinkNetworkingHelper jsonRequestWithMethod:HPHttpMethodPost url:url data:dictionary headers:[self commonHeaders]];
    
    [LPAuthenticatedNetworkOperation executeWithSession:session request:request completion:^(id data, NSHTTPURLResponse * response, NSError * error) {
        id instance = nil;
        if (!error) {
            instance = [[self alloc] initWithSession:session dictionary:data[[self entityName]]];
            if (!instance) {
                error = [self malformedResponseError:data];
            }
        }
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(instance, error);
            });
        }
    }];
}

+ (void)baseListWithSession:(LPSession *)session completion:(void (^)(NSArray *entities, NSError *error))completion {
    [self baseListWithContainerResource:nil session:session completion:completion];
}

+ (void)baseListWithContainerResource:(LPContainerResource *)containerResource session:(LPSession *)session completion:(void (^)(NSArray *entities, NSError *error))completion {
    
    NSURL * url = [self baseUrlWithContainerResource:containerResource session:session identifier:nil];
    NSMutableURLRequest *request = [HPLinkNetworkingHelper jsonRequestWithMethod:HPHttpMethodGet url:url data:nil headers:[self commonHeaders]];
    
    [LPAuthenticatedNetworkOperation executeWithSession:session request:request completion:^(id data, NSHTTPURLResponse * response, NSError * error) {
        NSArray *entities = nil;
        if (!error) {
            entities = [self entityListFromDictionary:data session:session error:&error];
        }
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(entities, error);
            });
        }
    }];
}

- (void)baseDeleteCompletion:(void (^)(NSError *error))completion
{
    [self baseDeleteWithContainerResource:nil completion:completion];
}


- (void)baseDeleteWithContainerResource:(LPContainerResource *)containerResource completion:(void (^)(NSError *error))completion {
    
    NSURL * url = [[self class] baseUrlWithContainerResource:containerResource session:self.session identifier:[self identifier]];
    NSMutableURLRequest *request = [HPLinkNetworkingHelper requestWithMethod:HPHttpMethodDelete url:url data:nil headers:[[self class] commonHeaders]];
    
    [LPAuthenticatedNetworkOperation executeWithSession:self.session request:request completion:^(id data, NSHTTPURLResponse * response, NSError * error) {
        if (!error) {
            self.identifier = nil;
            self.rawData = nil;
            [self clearEntityValues];
        }
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(error);
            });
        }
    }];
}

- (void)baseUpdateWithSession:(LPSession *)session completion:(void (^)(NSError *error))completion {
    [self baseUpdateWithContainerResource:nil session:session completion:completion];
}

- (void)baseUpdateWithContainerResource:(LPContainerResource *)containerResource session:(LPSession *)session completion:(void (^)(NSError *error))completion {
    
    NSURL *url = [[self class] baseUrlWithContainerResource:containerResource session:session identifier:[self identifier]];
    NSMutableURLRequest *request = [HPLinkNetworkingHelper jsonRequestWithMethod:HPHttpMethodPut url:url data:[self dictionaryRepresentationForEdit] headers:[[self class] commonHeaders]];
    
    [LPAuthenticatedNetworkOperation executeWithSession:session request:request completion:^(id data, NSHTTPURLResponse * response, NSError * error) {
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(error);
            });
        }
    }];
}


+ (NSDictionary *)commonHeaders {
    return @{ @"Accept" : @"application/json", @"Content-Type": @"application/json" };
}

- (NSString *)baseUrl {
    return [[self class] baseUrlWithSession:self.session identifier:nil];
}

- (NSString *)baseUrlWithId {
    return [[self class] baseUrlWithSession:self.session identifier:self.identifier];
}

+ (NSString *)baseUrlWithSession:(LPSession *)session {
    return [self baseUrlWithSession:session identifier:nil];
}

+ (NSString *)baseUrlWithSession:(LPSession *)session identifier:(NSString *)identifier {
    NSString *baseUrl = [NSString stringWithFormat:@"%@/api/v2/%@", [[session baseURL] absoluteString], [self entityNamePlural]];
    if (identifier) {
        baseUrl = [baseUrl stringByAppendingFormat:@"/%@", identifier];
    }
    return baseUrl;
}

+ (NSString*)baseUrlSuffix {
    return @"/api/v2";
}

+ (NSURL *)baseUrlWithContainerResource:(LPContainerResource *)containerResource session:(LPSession *)session identifier:(NSString *)identifier {
    
    NSURL *url = [[session baseURL] URLByAppendingPathComponent:[self baseUrlSuffix]];
    
    while(containerResource != nil){
        url = [url URLByAppendingPathComponent:containerResource.entityName];
        url = [url URLByAppendingPathComponent:containerResource.identifier];
        containerResource = containerResource.parent;
    }
    url = [url URLByAppendingPathComponent:[self entityNamePlural]];
    if (identifier) {
        url = [url URLByAppendingPathComponent:identifier];
    }
    return url;
}

+ (NSArray *)entityListFromDictionary:(NSDictionary *)dictionary session:(LPSession *)session error:(NSError **)error {
    if (!dictionary || ![dictionary isKindOfClass:[NSDictionary class]]) {
        *error = [self malformedResponseError:dictionary];
        return nil;
    }
    NSArray * entities = dictionary[[self entityNamePlural]];
    if (!entities || ![entities isKindOfClass:[NSArray class]]) {
        *error = [self malformedResponseError:dictionary];
        return nil;
    }
    NSMutableArray *deserializedEntities = @[].mutableCopy;
    for(NSDictionary * entity in entities){
        id deserializedEntity = [[self alloc] initWithSession:session dictionary:entity];
        if (!deserializedEntity) {
            //TODO: handle more than one malformed item
            *error = [self malformedResponseError:entity];
        }
        if (deserializedEntity) {
            [deserializedEntities addObject:deserializedEntity];
        }
    }
    return deserializedEntities;
}

+ (NSString *)entityNamePlural {
    //  :( , but it works for now...
    return [[self entityName] stringByAppendingString:@"s"];
}

#pragma mark Private methods

+ (NSError *)malformedResponseError:(id)responseObject {
    return [NSError errorWithDomain:[LPErrors domainName] code:LPInternalErrorCode_MalformedResponse userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Malformed response object: %@",responseObject] }];
}

+ (NSError *)badRequestParametersError:(id)parameters {
    return [NSError errorWithDomain:[LPErrors domainName] code:LPInternalErrorCode_BadParameters userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Bad parameters: %@",parameters] }];
}

#pragma mark <LPBaseEntity>

- (void)clearEntityValues {
    self.identifier = nil;
    self.atomLinks = nil;
    self.dateCreated = nil;
    self.dateModified = nil;
}

+(NSString *)entityName{
    return nil;
}

+(instancetype)entityFromDictionary:(NSDictionary *)dictionary session:(LPSession *)session {
    return nil;
}

-(NSDictionary *)dictionaryRepresentationForEdit {
    return nil;
}

@end
