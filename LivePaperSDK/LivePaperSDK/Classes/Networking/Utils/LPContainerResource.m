//
//  ContainerResource.m
//  LivePaperSDK
//
//  Created by Alejandro Mendez on 1/17/17.
//  Copyright © 2017 Hewlett-Packard. All rights reserved.
//

#import "LPContainerResource.h"

@implementation LPContainerResource

+ (instancetype)resourceWithEntityName:(NSString *)entityName identifier:(NSString *)identifier {
    LPContainerResource * resource = [LPContainerResource new];
    resource.entityName = entityName;
    resource.identifier = identifier;
    return resource;
}

@end
