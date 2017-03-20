//
//  ContainerResource.h
//  LivePaperSDK
//
//  Created by Alejandro Mendez on 1/17/17.
//  Copyright © 2017 Hewlett-Packard. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LPContainerResource : NSObject

@property (nonatomic, weak) id parent;
@property (nonatomic) NSString* entityName;
@property (nonatomic) NSString* identifier;

+ (instancetype)resourceWithEntityName:(NSString *)entityName identifier:(NSString *)identifier;

@end
