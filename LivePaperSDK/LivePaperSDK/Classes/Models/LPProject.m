//
//  LPProject.m
//  LivePaperSDK
//
//  Created by Alejandro Mendez on 1/12/17.
//  Copyright © 2017 Hewlett-Packard. All rights reserved.
//

#import "LPBaseEntityPrivate.h"
#import "LPProject.h"
#import "LPAuthenticatedNetworkOperation.h"

static NSString * const LPValidateEndpoint = @"auth/v2/validate";
static NSString * const LPProjectsEndpoint = @"api/v2/projects";

@interface LPProject () <LPBaseEntity>
@property (nonatomic) NSString *accountId;
@property (nonatomic) NSString *creatorEmail;
@end


@implementation LPProject

- (instancetype)initWithSession:(LPSession *)session dictionary:(NSDictionary *)dictionary {
    if (self = [super initWithSession:session dictionary:dictionary]) {
        
        NSString *name = dictionary[@"name"];
        NSString *accountId = dictionary[@"accountId"];
        NSDictionary *createdBy = dictionary[@"createdBy"];
        NSString *creatorEmail = nil;
        if (createdBy && [createdBy isKindOfClass:[NSDictionary class]]) {
            creatorEmail = createdBy[@"emailId"];
        }
        
        if(!name || !accountId || !creatorEmail){
            return nil;
        }
        _name = name;
        _accountId = accountId;
        _creatorEmail = creatorEmail;
    }
    return self;
}

+ (void)createWithName:(NSString *)name session:(LPSession *)session completion:(void (^)(LPProject *project, NSError *error))completion {
    
    if (!session.user) {
        [LPUser get:session.clientId session:session completion:^(LPUser *user, NSError *error) {
            if (!error) {
                session.user = user;
                [self createWithName:name session:session completion:completion];
            }else{
                if (completion) {
                    completion(nil, error);
                }
            }
        }];
        return;
    }
    
    NSDictionary * projectDictionary = @{[self entityName]: @{
                                             @"name" : name ?: @"",
                                             @"accountId" : session.user.accountId,
                                         }};
    return [self baseCreateWithDictionary:projectDictionary session:session completion:completion];
}

+ (void)get:(NSString *)projectId session:(LPSession *)session completion:(void (^)(LPProject *project, NSError *error))completion {
    [self baseGet:projectId session:session completion:completion];
}

+ (void)list:(LPSession *)session completion:(void (^)(NSArray <LPProject*> *projects, NSError *error))completion{
    [self baseListWithSession:session completion:completion];
}

- (void)delete:(void (^)(NSError *error))completion {
    [self baseDeleteCompletion:completion];
}

- (void)update:(void (^)(NSError *error))completion{
    [self baseUpdateWithSession:self.session completion:completion];
}

+ (void)getDefaultProjectIdWithSession:(LPSession *)session completion:(void (^)(NSString *projectId, NSError *error))completion {
    
    NSURL *validateUrl = [[session baseURL] URLByAppendingPathComponent:LPValidateEndpoint];
    
    NSMutableURLRequest *request = [HPLinkNetworkingHelper requestWithMethod:HPHttpMethodPost url:validateUrl data:nil headers:[self commonHeaders]];
    
    [LPAuthenticatedNetworkOperation executeWithSession:session request:request completion:^(id  _Nullable data, NSHTTPURLResponse * _Nullable response, NSError * _Nullable error) {
        NSString *projectId = nil;
        if (!error) {
            projectId = [response allHeaderFields][@"Project-Id"];
            if (!projectId) {
                error = [NSError errorWithDomain:[LPErrors domainName] code:LPInternalErrorCode_MalformedResponse userInfo:@{NSLocalizedDescriptionKey: @"Unable to get project id from response."}];
            }else{
                session.defaultProjectId = projectId;
            }
        }
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(projectId, error);
            });
        }
    }];
}

+ (void)uploadImageFile:(nonnull NSData *)imageData projectId:(nonnull NSString *)projectId session:(nonnull LPSession *)session progress:(void (^_Nullable)(double progress))progress completion:(nullable void (^)(NSURL * _Nullable url, NSError * _Nullable error))completion {
    
    NSURL *url = [[session baseStorageURL] URLByAppendingPathComponent:[NSString stringWithFormat:@"objects/v2/projects/%@/files", projectId]];
    
    
    NSDictionary *headers = @{
                @"Accept" : @"application/json",
                @"Content-Type": @"image/jpeg" };
    NSMutableURLRequest *request = [HPLinkNetworkingHelper requestWithMethod:HPHttpMethodPost url:url data:imageData headers:headers];
    
    LPAuthenticatedNetworkOperation *operation = [[LPAuthenticatedNetworkOperation alloc] initWithSession:session request:request completion:^(id  _Nullable data, NSHTTPURLResponse * _Nullable response, NSError * _Nullable error) {
        NSString *imageUrl = nil;
        if (!error) {
            imageUrl = [response allHeaderFields][@"Location"];
        }
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion([NSURL URLWithString:imageUrl], error);
            });
        }
    }];
    operation.progressCallback = progress;
    [[HPLinkOperationQueue sharedQueue] addOperation:operation];
}


#pragma mark LPBaseEntity

- (void)clearEntityValues {
    [super clearEntityValues];
    self.accountId = nil;
    self.creatorEmail = nil;
}


+(NSString *)entityName {
    return @"project";
}

- (NSDictionary *)dictionaryRepresentationForEdit {
    return @{
             [[self class] entityName]: @{
                @"name": self.name ?: @""
             }
            };
}

@end
