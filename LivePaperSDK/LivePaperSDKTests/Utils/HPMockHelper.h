//
//  HPMockHelper.h
//  LivePaperSDK
//
//  Created by Alejandro Mendez on 2/10/17.
//  Copyright © 2017 Hewlett-Packard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LivePaperSDK/LivePaperSDK.h>

@interface HPMockHelper : NSObject

+ (NSString *)mockImageUpload;
+ (void)mockImageDownload:(NSString *)urlString;
+ (void)mockGetDefaultProject:(NSString *)defaultProject;
+ (NSString *)pluralEntityName:(NSString *)entityName;
+ (NSDictionary *)mockPayoffCreate:(LPPayoffType)type project:(NSString *)projectId testRequestDataBlock:(void (^)(NSURLRequest *request))block;
+ (NSDictionary *)mockTriggerCreate:(LPTriggerType)type project:(NSString *)projectId testRequestDataBlock:(void (^)(NSURLRequest *request))block;
+ (NSDictionary *)mockLinkCreateWithProjectId:(NSString *)projectId testRequestDataBlock:(void (^)(NSURLRequest *request))block;


+ (void)mockQrCodeWithProjectId:(NSString *)projectId entityId:(NSString *)entityId testRequestDataBlock:(void (^)(NSURLRequest *request))block;
+ (void)mockWatermarkingWithProjectId:(NSString *)projectId entityId:(NSString *)entityId testRequestDataBlock:(void (^)(NSURLRequest *request))block;

@end
