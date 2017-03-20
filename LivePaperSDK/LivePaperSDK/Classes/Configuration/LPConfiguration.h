//
//  LPConfiguration.h
//  LivePaperSDK
//
//  Created by Alejandro Mendez on 1/3/17.
//  Copyright © 2017 Hewlett-Packard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LPStack.h"

@interface LPConfiguration : NSObject

+ (NSString *)baseUrlForStack:(LPStack)stack;
+ (NSString *)baseStorageUrlForStack:(LPStack)stack;

@end
