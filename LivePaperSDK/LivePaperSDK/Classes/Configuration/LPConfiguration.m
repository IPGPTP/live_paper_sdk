//
//  LPConfiguration.m
//  LivePaperSDK
//
//  Created by Alejandro Mendez on 1/3/17.
//  Copyright © 2017 Hewlett-Packard. All rights reserved.
//

#import "LPConfiguration.h"

@implementation LPConfiguration

+ (NSString *)baseUrlForStack:(LPStack)stack{
    switch (stack) {
        case LPStack_Production:
            return @"https://www.livepaperapi.com";
            break;
        case LPStack_Staging:
            return @"https://stage.livepaperapi.com";
            break;
        case LPStack_Development:
            return @"https://dev.livepaperapi.com";
            break;
        default:
            return @"https://www.livepaperapi.com";
            break;
    }
}

+ (NSString *)baseStorageUrlForStack:(LPStack)stack{
    switch (stack) {
        case LPStack_Production:
            return @"https://storage.livepaperapi.com";
            break;
        case LPStack_Staging:
            return @"https://stage.storage.livepaperapi.com";
            break;
        case LPStack_Development:
            return @"https://dev.storage.livepaperapi.com";
            break;
        default:
            return @"https://storage.livepaperapi.com";
            break;
    }
}

@end
