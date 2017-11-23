//
//  LoginRequest.m
//  LiveRecorder
//
//  Created by 匹诺曹 on 17/4/27.
//  Copyright © 2017年 匹诺曹. All rights reserved.
//

#import "LoginRequest.h"
#import "AccountInfo.h"

@implementation LoginRequest

+ (void)getSmsCodeByPhoneNum:(NSString *)phoneNumber WithState:(void (^)(int))block{
    NSString *sms = @"/v1/accounts/sms-code";
    NSDictionary *param = @{@"mobile": phoneNumber};
    [BaseRequest getWithRequsetURL:sms withParameter:param withSessionId:NO withReturnValueBlock:^(id obj) {
        block(HTTP_OK);
    } withErrorCodeBlock:^(int errorCode) {
        block(errorCode);
    } withFailureBlock:^{
        
    }];
}

+ (void)loginWithMobile:(NSString *)phoneNumber andSmsCode:(NSString*)smsCode WithState:(void (^)(int))block{
    NSString *log = @"/v1/accounts/auth";
    NSDictionary *param = @{@"mobile"  : phoneNumber,
                            @"smsCode" : smsCode };
    [BaseRequest postWithRequsetURL:log withParameter:param withSessionId:NO withReturnValueBlock:^(id obj) {
        [[AccountInfo shareInfo] svaeMyProfileInfoFromJson:obj];
        [[AccountInfo shareInfo] updateMyProfileWithKey:SYSTEM_CODE andValue:[obj valueForKey:SYSTEM_CODE]];
        block(HTTP_OK);
    } withErrorCodeBlock:^(int errorCode) {
        block(errorCode);
    } withFailureBlock:^{
        
    }];    
}

+ (void)loginWithMobile:(NSString *)phoneNumber andSmsCode:(NSString*)smsCode AndAuthType:(NSString *)type withId:(NSString *)theId WithState:(void (^)(int))block{
    NSString *log = @"/v1/accounts/auth";
    NSDictionary *param = [NSDictionary dictionary];
    if ([type isEqualToString:@"qq"]) {
            param = @{@"type" : type,
                      @"qqId" : theId,
                      @"mobile"  : phoneNumber,
                      @"smsCode" : smsCode};
    } else {
            param = @{@"type" : type,
                      @"wechatId" : theId ,
                      @"mobile"  : phoneNumber,
                      @"smsCode" : smsCode};
    }
    [BaseRequest postWithRequsetURL:log withParameter:param withSessionId:NO withReturnValueBlock:^(id obj) {
        [[AccountInfo shareInfo] svaeMyProfileInfoFromJson:obj];
        block(HTTP_OK);
    } withErrorCodeBlock:^(int errorCode) {
        block(errorCode);
    } withFailureBlock:^{
    }];
}

+ (void)justifyVersionWithCode:(NSNumber *)code WithReturnKey:(void (^)(int, NSDictionary *))block {
    NSDictionary *param = @{@"vCode" : code};
    
    [BaseRequest getNoHUDWithRequsetURL:@"/v1/settings/update-ipa" WithDark:NO withParameter:param withSessionId:NO withReturnValueBlock:^(id obj) {
        block(HTTP_OK,obj);
    } withErrorCodeBlock:^(int errorCode) {
    } withFailureBlock:^{
    }];

}

@end
