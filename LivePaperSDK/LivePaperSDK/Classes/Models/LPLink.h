//
//  LPLink.h
//  LivePaperSDK
//
//  Created by Alejandro Mendez on 1/12/17.
//  Copyright © 2017 Hewlett-Packard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LivePaperSDK/LPSession.h>
#import <LivePaperSDK/LPProjectEntity.h>

/**
 LPLink represents a 'HP Link' Link object. More information about this resource can be found at:
 https://mylinks.linkcreationstudio.com/developer/doc/v2/link/
 */
@interface LPLink : LPProjectEntity

@property (nonatomic, readonly) NSString *linkId;
@property (nonatomic, readonly) NSString *triggerId;
@property (nonatomic, readonly) NSString *payoffId;

/**
 Creates a link between a trigger and a payoff object.
 
 @param name                The name of the link
 @param triggerId           The identifier of the trigger object
 @param payoffId            The identifier of the payoff object
 @param projectId           The identifier of the project where the resource will be created.
 @param session             The user session object
 @param completion  The completion block to run upon success
 
 */
+ (void)createWithName:(NSString *)name triggerId:(NSString *)triggerId payoffId:(NSString *)payoffId projectId:(NSString *)projectId session:(LPSession *)session completion:(void (^)(LPLink *link, NSError *error))completion;

/**
 Gets a link resource.
 
 @param identifier          The identifier of the resource to get
 @param projectId           The identifier of the project where the resource was created
 @param session             The user session object
 @param completion          The completion block to run upon success
 
 */
+ (void)get:(NSString *)identifier projectId:(NSString *)projectId session:(LPSession *)session completion:(void (^)(LPLink * link, NSError *error))completion;

/**
 Lists the links in a project
 
 @param projectId           The identifier of the project where the resource was created
 @param session             The user session object
 @param completion          The completion block to run upon success
 
 */
+ (void)list:(LPSession *)session projectId:(NSString *)projectId completion:(void (^)(NSArray <LPLink *> *links, NSError *error)) completion;

@end
