//
//  LPPayoff.h
//  LivePaperSDK
//
//  Created by Alejandro Mendez on 1/12/17.
//  Copyright © 2017 Hewlett-Packard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LivePaperSDK/LPProjectEntity.h>
#import <LivePaperSDK/LPSession.h>

typedef NS_ENUM(NSInteger, LPPayoffType) {
    LPPayoffTypeUrl,
    LPPayoffTypeRich,
    LPPayoffTypeCustom
};

/**
 LPPayoff represents a 'HP Link' Payoff object. More information about this resource can be found at:
 https://mylinks.linkcreationstudio.com/developer/doc/v2/payoff/
 */
@interface LPPayoff : LPProjectEntity

@property(nonatomic, readonly) LPPayoffType type;
@property(nonatomic) NSURL *url;
@property(nonatomic) NSDictionary *richPayoffData;
@property(nonatomic) NSURL *richPayoffPublicUrl;

/**
 Creates a payoff using a dictionary.
 
 @param dictionary      Dictionary with the payoff data structure. Structure can be found at: https://mylinks.linkcreationstudio.com/developer/doc/v2/payoff/
 @param projectId       The identifier of the project under which the resource will be created.
 @param session         The user session object
 @param completion      The completion block to run upon success
 
 */
+ (void)createWithDictionary:(NSDictionary *)dictionary projectId:(NSString *)projectId session:(LPSession *)session completion:(void (^)(LPPayoff *payoff, NSError *error))completion;

/**
 Creates a web payoff
 
 @param name            The name of the payoff
 @param url             The URL to which the user will be redirected
 @param projectId       The identifier of the project under which the resource will be created.
 @param session         The user session object
 @param completion      The completion block to run upon success
 
 */
+ (void)createWebPayoffWithName:(NSString *)name url:(NSURL *) url projectId:(NSString *)projectId session:(LPSession *)session completion:(void (^)(LPPayoff *payoff, NSError *error))completion;

/**
 Creates a rich payoff
 
 @param name            The name of the payoff
 @param publicURL       The URL to which non-LinkReader users will be redirected
 @param richPayoffData  The rich payoff content structure. Refer to: https://mylinks.linkcreationstudio.com/developer/doc/v2/payoff/#tocAnchor-1-5
 @param projectId       The identifier of the project under which the resource will be created.
 @param session         The user session object
 @param completion      The completion block to run upon success
 
 */
+ (void)createRichPayoffWithName:(NSString *)name publicURL:(NSURL *)publicURL richPayoffData:(NSDictionary *)richPayoffData projectId:(NSString *)projectId session:(LPSession *)session  completion:(void (^)(LPPayoff *payoff, NSError *error))completion;

/**
 Gets a payoff object.
 
 @param identifier      The identifier of the resource to get
 @param projectId       The identifier of the project where the resource was created
 @param session         The user session object
 @param completion      The completion block to run upon success
 
 */
+ (void)get:(NSString *)identifier projectId:(NSString *)projectId session:(LPSession *)session completion:(void (^)(LPPayoff * payoff, NSError *error))completion;

/**
 Lists the payoffs in a project
 
 @param projectId        The identifier of the project where the resource was created
 @param session          The user session object
 @param completion       The completion block to run upon success
 
 */
+ (void)list:(LPSession *)session projectId:(NSString *)projectId completion:(void (^)(NSArray <LPPayoff *> *payoffs, NSError *error)) completion;

@end
