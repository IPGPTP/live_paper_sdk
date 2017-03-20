//
//  LpBaseEntity.h
//  LivePaperSDK
//
//  Created by Alejandro Mendez on 1/13/17.
//  Copyright © 2017 Hewlett-Packard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LivePaperSDK/LPSession.h>

/**
 LPBaseEntity is the base class for several objects in the LivePaperSDK
 */
@interface LPBaseEntity : NSObject

// The identifier of the resource
@property (nonatomic, readonly) NSString *identifier;
// The atom links available for this resource
@property (nonatomic, readonly) NSArray *atomLinks;
// The session object associated with this resource
@property (nonatomic, readonly) LPSession *session;
// The raw data that represents this resource
@property (nonatomic, readonly) NSDictionary *rawData;
// A string that represents the date the resource was created
@property (nonatomic, readonly) NSString *dateCreated;
// A string that represents the date the resource was last modified
@property (nonatomic, readonly) NSString *dateModified;


@end
