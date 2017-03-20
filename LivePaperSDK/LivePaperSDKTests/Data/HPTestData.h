//
//  HPTestData.h
//  LivePaperSDK
//
//  Created by Live Paper on 10/28/15.
//  Copyright © 2015 Hewlett-Packard. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HPTestData : NSObject

+ (NSDictionary *)richPayoff;

+ (NSData *)getImageData;
+ (NSData *)getImageData:(NSString *)imageName extension:(NSString *)extension;
+ (NSData *)getWatemarkedImageData;
+ (NSData *)getQrCodeImageData;

@end
