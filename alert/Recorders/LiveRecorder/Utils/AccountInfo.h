//
//  AccountInfo.h
//  LiveRecorder
//
//  Created by 匹诺曹 on 17/4/28.
//  Copyright © 2017年 匹诺曹. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kSuiteProfile   @"profile"

@interface AccountInfo : NSObject

+ (instancetype)shareInfo;

- (void)svaeMyProfileInfoFromJson:(NSDictionary *)dic;

- (void)updateMyProfileWithKey:(NSString *)key andValue:(NSString *)value;

- (NSString *)mobile;

- (NSString *)uid;

- (NSString *)sessionid;

- (NSString *)wx_access_token;

- (NSString *)wx_open_id;

- (NSString *)wx_refresh_token;

- (NSString *)systemCode;

- (NSString *)qq_token;

- (NSString *)qq_openId;

- (void)cleanCurrentProfile;
@end
