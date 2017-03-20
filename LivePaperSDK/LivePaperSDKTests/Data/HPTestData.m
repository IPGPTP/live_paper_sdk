//
//  HPTestData.m
//  LivePaperSDK
//
//  Created by Live Paper on 10/28/15.
//  Copyright © 2015 Hewlett-Packard. All rights reserved.
//

#import "HPTestData.h"
#import <UIKit/UIKit.h>

@implementation HPTestData

+ (NSDictionary *)richPayoff {
    return @{
                               @"type" : @"content action layout",
                               @"version" : @"1",
                               @"data" : @{
                                       @"content" : @{
                                               @"type" : @"image",
                                               @"label" : @"Movember!",
                                               @"data" : @{
                                                       @"URL" : @"http://static.movember.com/uploads/2014/profiles/ef4/ef48a53fb031669fe86e741164d56972-546b9b5c56e15-hero.jpg"
                                                       }
                                               },
                                       @"actions" : @[
                                               @{
                                                   @"type" : @"webpage",
                                                   @"label" : @"Donate!",
                                                   @"icon" : @{ @"id" : @"533" },
                                                   @"data" : @{ @"URL" : @"http://MOBRO.CO/oamike" }
                                                   },
                                               @{
                                                   @"type" : @"share",
                                                   @"label" : @"Share!",
                                                   @"icon" : @{ @"id" : @"527" },
                                                   @"data" : @{ @"URL" : @"Help Mike get the prize of most donations on his team! MOBRO.CO/oamike"}
                                                   }
                                               ]
                                       }
                               };
}

+ (NSData *)getImageData {
    return [self getImageData:nil extension:nil];
}

+ (NSData *)getImageData:(NSString *)imageName extension:(NSString *)extension {
    if (!imageName || !extension) {
        imageName = @"forest";
        extension = @"jpg";
    }
    return [NSData dataWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:imageName ofType:extension]];
}

+ (NSData *)getWatemarkedImageData {
    UIImage *testImage = [UIImage imageNamed:@"watermarked.jpeg" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
    return UIImageJPEGRepresentation(testImage, 0.8);
}

+ (NSData *)getQrCodeImageData {
    UIImage *testImage = [UIImage imageNamed:@"qrcode.jpeg" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
    return UIImageJPEGRepresentation(testImage, 0.8);
}

@end
