//
//  LPProjectEntityTestCase.m
//  LivePaperSDK
//
//  Created by Alejandro Mendez on 2/3/17.
//  Copyright © 2017 Hewlett-Packard. All rights reserved.
//

#import "LPBaseTestCase.h"

NSString * const LPClientId = @"my_client_id";
NSString * const LPClientSecret = @"my_client_secret";


@implementation LPBaseTestCase

- (void)setUp {
    [super setUp];
    self.session = [LPSession createSessionWithClientId:LPClientId secret:LPClientSecret stack:LPStack_Staging];
    self.projectId = @"4b13Xz";
}

- (NSString *)entityName {
    return @"";
}

- (NSString *)pluralEntityName {
    return [HPMockHelper pluralEntityName:[self entityName]];
}

- (void)tearDown {
    [OHHTTPStubs removeAllStubs];
    [super tearDown];    
}

- (NSURL *)urlForAtomLink:(NSString *)name atomLinks:(NSArray *)atomLinks
{
    __block NSURL *url = nil;
    if (atomLinks) {
        [atomLinks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([[obj objectForKey:@"rel"] compare:name options:NSCaseInsensitiveSearch] == NSOrderedSame) {
                url = [NSURL URLWithString:[obj objectForKey:@"href"]];
                *stop = YES;
            }
        }];
    }
    return url;
}

@end
