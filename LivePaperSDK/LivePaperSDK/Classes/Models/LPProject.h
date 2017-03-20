//
//  LPProject.h
//  LivePaperSDK
//
//  Created by Alejandro Mendez on 1/12/17.
//  Copyright © 2017 Hewlett-Packard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LivePaperSDK/LPSession.h>
#import <LivePaperSDK/LPBaseEntity.h>

/**
 LPLink represents a 'HP Link' Project object. More information about this resource can be found at:
 https://mylinks.linkcreationstudio.com/developer/doc/v2/project/
 */
@interface LPProject : LPBaseEntity

@property (nonatomic, nullable) NSString *name;
@property (nonatomic, readonly, nullable) NSString *accountId;
@property (nonatomic, readonly, nullable) NSString *creatorEmail;


/**
 Creates a project resource.
 
 @param name                The name of the link
 @param session             The user session object
 @param completion  The completion block to run upon success
 
 */
+ (void)createWithName:(nonnull NSString *)name session:(nonnull LPSession *)session completion:(nullable void (^)(  LPProject * _Nullable project, NSError * _Nullable error))completion;

/**
 Gets a project resource.
 
 @param identifier          The identifier of the resource to get
 @param session             The user session object
 @param completion          The completion block to run upon success
 
 */
+ (void)get:(nonnull NSString *)identifier session:(nonnull LPSession *)session completion:(nullable void (^)(LPProject * _Nullable project, NSError * _Nullable error))completion;

/**
 Lists the projects in a project
 
 @param session             The user session object
 @param completion          The completion block to run upon success
 
 */
+ (void)list:(nonnull LPSession *)session completion:(nullable void (^)(NSArray <LPProject *> * _Nullable projects, NSError * _Nullable error))completion;

/**
 Deletes the project resource
 
 @param completion          The completion block to run upon success
 
 */
- (void)delete:(nullable void (^)(NSError * _Nullable error))completion;

/**
 Updates the project resource
 
 @param completion          The completion block to run upon success
 
 */
- (void)update:(nullable void (^)(NSError * _Nullable error))completion;

/**
 Gets the identifier of the user's default project
 
 @param session             The user session object
 @param completion          The completion block to run upon success
 
 */
+ (void)getDefaultProjectIdWithSession:(nonnull LPSession *)session completion:(nullable void (^)(NSString * _Nullable projectId, NSError * _Nullable error))completion;

/**
 Uploads an image to 'HP Link' File Storage so that it can be watermarked later on.
 
 @param imageData           The image data to be uploaded
 @param projectId           The identifier of the project where the image will be uploaded. NOTE: Image uploaded to one project cannot be watermarked using a trigger from another project.
 @param session             The user session object
 @param progress            A progress block that will be called with the progress value
 @param completion          The completion block to run upon success
 
 */
+ (void)uploadImageFile:(nonnull NSData *)imageData projectId:(nonnull NSString *)projectId session:(nonnull LPSession *)session progress:(nullable void (^)(double progress))progress completion:(nullable void (^)(NSURL * _Nullable url, NSError * _Nullable error))completion;


@end
