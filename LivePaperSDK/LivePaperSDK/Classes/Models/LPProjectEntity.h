//
//  LPProjectEntity.h
//  LivePaperSDK
//
//  Created by Alejandro Mendez on 1/27/17.
//  Copyright © 2017 Hewlett-Packard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LivePaperSDK/LPBaseEntity.h>

/**
 LPProjectEntity represents a resource created under a 'HP Link' Project object. It can represent an LPTrigger, LPPayoff or LPLink.
 */
@interface LPProjectEntity : LPBaseEntity

// The name given to the resource
@property (nonatomic) NSString *name;
// The identifier of the project under which this resource was created
@property (nonatomic, readonly) NSString *projectId;

/**
 Updates the resource
 
 @param completion  The completion block to run upon success
 
 */
- (void)update:(void (^)(NSError *))completion;

/**
 Deletes the resource in the server
 
 @param completion  The completion block to run upon success
 
 */
- (void)delete:(void (^)(NSError *))completion;

@end
