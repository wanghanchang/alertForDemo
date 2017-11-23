//
//  AccountInfo.m
//  LiveRecorder
//
//  Created by 匹诺曹 on 17/4/28.
//  Copyright © 2017年 匹诺曹. All rights reserved.
//

#import "AccountInfo.h"

static AccountInfo *info = nil;

@implementation AccountInfo

+ (instancetype)shareInfo  {
    @synchronized (self) {
        if (info == nil) {
            info = [[AccountInfo alloc] init];
        }
    }
    return info;
}

- (void)svaeMyProfileInfoFromJson:(NSDictionary *)dic {
    NSUserDefaults *userDefault = [[NSUserDefaults alloc] initWithSuiteName:kSuiteProfile];
    [userDefault setValue:NOT_NULL([dic valueForKey:MOBILE]) forKey:MOBILE];
    [userDefault setValue:NOT_NULL([dic valueForKey:SESSEION]) forKey:SESSEION];
    [userDefault setValue:NOT_NULL([dic valueForKey:UID]) forKey:UID];
    [userDefault synchronize];
}

- (void)cleanCurrentProfile {
    [[NSUserDefaults standardUserDefaults]removePersistentDomainForName:kSuiteProfile];
}

- (void)updateMyProfileWithKey:(NSString *)key andValue:(NSString *)value {
    NSUserDefaults *userDefault = [[NSUserDefaults alloc] initWithSuiteName:kSuiteProfile];
    [userDefault setValue:value forKey:key];
    [userDefault synchronize];
}

- (NSString *)mobile {
    NSUserDefaults *userDefault = [[NSUserDefaults alloc] initWithSuiteName:kSuiteProfile];
    return [userDefault valueForKey:MOBILE];
}

- (NSString *)uid {
    NSUserDefaults *userDefault = [[NSUserDefaults alloc] initWithSuiteName:kSuiteProfile];
    return [userDefault valueForKey:UID];
}

- (NSString *)sessionid {
    NSUserDefaults *userDefault = [[NSUserDefaults alloc] initWithSuiteName:kSuiteProfile];
    return [userDefault valueForKey:SESSEION];
}

- (NSString *)wx_access_token {
    NSUserDefaults *userDefault = [[NSUserDefaults alloc] initWithSuiteName:kSuiteProfile];
    return [userDefault valueForKey:WX_ACCESS_TOKEN];
}

- (NSString *)wx_open_id {
    NSUserDefaults *userDefault = [[NSUserDefaults alloc] initWithSuiteName:kSuiteProfile];
    return [userDefault valueForKey:WX_OPEN_ID];
}

- (NSString *)wx_refresh_token {
    NSUserDefaults *userDefault = [[NSUserDefaults alloc] initWithSuiteName:kSuiteProfile];
    return [userDefault valueForKey:WX_REFRESH_TOKEN];
}

- (NSString *)systemCode {
    NSUserDefaults *userDefault = [[NSUserDefaults alloc] initWithSuiteName:kSuiteProfile];
    return [userDefault valueForKey:SYSTEM_CODE];
}

- (NSString *)qq_token {
    NSUserDefaults *userDefault = [[NSUserDefaults alloc] initWithSuiteName:kSuiteProfile];
    return [userDefault valueForKey:QQ_TOKEN];
}

- (NSString *)qq_openId {
    NSUserDefaults *userDefault = [[NSUserDefaults alloc] initWithSuiteName:kSuiteProfile];
    return [userDefault valueForKey:QQ_OPENID];
}

@end
