//
//  LPBaseEntityPrivate.h
//  LivePaperSDK
//
//  Created by Alejandro Mendez on 1/13/17.
//  Copyright © 2017 Hewlett-Packard. All rights reserved.
//

#import "LPBaseEntity.h"
#import "LPSessionPrivate.h"
#import "LPAuthenticatedNetworkOperation.h"
#import "LPContainerResource.h"

@protocol LPBaseEntity <NSObject>
+ (NSString *)entityName;
- (NSDictionary *)dictionaryRepresentationForEdit;
- (void)clearEntityValues;
@end

@interface LPBaseEntity () 
@property (nonatomic) LPSession *session;
@property (nonatomic) NSArray *atomLinks;
@property (nonatomic) NSString *identifier;
@property (nonatomic) NSDictionary *rawData;
@property (nonatomic) NSString *dateCreated;
@property (nonatomic) NSString *dateModified;

- (instancetype)initWithSession:(LPSession *)session dictionary:(NSDictionary *)dictionary;

// Get
+ (void)baseGet:(NSString *)identifier session:(LPSession *)session completion:(void (^)(id instance, NSError *error))completion;
+ (void)baseGetWithContainerResource:(LPContainerResource *)containerResource identifier:(NSString *)identifier session:(LPSession *)session completion:(void (^)(id instance, NSError *error))completion;

// Create
+ (void)baseCreateWithDictionary:(NSDictionary *)dictionary session:(LPSession *)session completion:(void (^)(id instance, NSError *error))completion;
+ (void)baseCreateWithContainerResource:(LPContainerResource *)containerResource dictionary:(NSDictionary *)dictionary session:(LPSession *)session completion:(void (^)(id instance, NSError *error))completion;

// Update
- (void)baseUpdateWithSession:(LPSession *)session completion:(void (^)(NSError *error))completion;
- (void)baseUpdateWithContainerResource:(LPContainerResource *)containerResource session:(LPSession *)session completion:(void (^)(NSError *error))completion;

// Delete
- (void)baseDeleteWithContainerResource:(LPContainerResource *)containerResource completion:(void (^)(NSError *error))completion;
- (void)baseDeleteCompletion:(void (^)(NSError *error))completion;

// List
+ (void)baseListWithSession:(LPSession *)session completion:(void (^)(NSArray *entities, NSError *error))completion;
+ (void)baseListWithContainerResource:(LPContainerResource *)containerResource session:(LPSession *)session completion:(void (^)(NSArray *entities, NSError *error))completion;


// Auxiliary methods
- (NSDictionary *)dictionaryRepresentationForEdit;
- (void)clearEntityValues;
+ (NSDictionary *)commonHeaders;
+ (NSString *)entityNamePlural;
- (NSString *)baseUrl;
- (NSString *)baseUrlWithId;
+ (NSString *)baseUrlWithSession:(LPSession *)session;
+ (NSString *)baseUrlWithSession:(LPSession *)session identifier:(NSString *)identifier;
+ (NSArray *)entityListFromDictionary:(NSDictionary *)dictionary session:(LPSession *)session error:(NSError **)error;
+ (NSError *)badRequestParametersError:(id)parameters;

@end

