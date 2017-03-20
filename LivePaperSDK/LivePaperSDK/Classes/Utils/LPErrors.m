//
//  LPErrors.m
//  LivePaperSDK
//
//  Created by Alejandro Mendez on 1/12/17.
//  Copyright © 2017 Hewlett-Packard. All rights reserved.
//

#import "LPErrors.h"

NSString *const LPErrorResponseStatusKey = @"LPErrorResponseStatusKey";
NSString *const LPErrorResponseDataKey = @"LPErrorResponseDataKey";

@implementation LPErrors

+ (NSString *)domainName {
    return [[NSBundle mainBundle] bundleIdentifier];
}

@end
