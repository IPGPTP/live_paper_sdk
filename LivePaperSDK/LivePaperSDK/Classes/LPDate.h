//
//  LPDate.h
//  LivePaperSDK
//
//  Copyright (c) 2015 Hewlett-Packard. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LPDate : NSObject

+ (NSDate *) dateFromString:(NSString *)string;

+ (NSString *) stringFromDate:(NSDate *)date;

@end
