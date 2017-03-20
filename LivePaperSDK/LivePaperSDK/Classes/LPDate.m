//
//  LPDate.m
//  LivePaperSDK
//
//  Copyright (c) 2015 Hewlett-Packard. All rights reserved.
//

#import "LPDate.h"

#define LP_DATE_FORMAT  @"yyyy-MM-dd'T'HH:mm:ss.SSSZ"

@implementation LPDate

+ (NSDate *) dateFromString:(NSString *)string
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:LP_DATE_FORMAT];
    return [dateFormatter dateFromString:string];
}

+ (NSString *) stringFromDate:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:LP_DATE_FORMAT];
    return [dateFormatter stringFromDate:date];
}

@end
