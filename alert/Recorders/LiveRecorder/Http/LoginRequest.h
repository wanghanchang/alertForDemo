//
//  LoginRequest.h
//  LiveRecorder
//
//  Created by 匹诺曹 on 17/4/27.
//  Copyright © 2017年 匹诺曹. All rights reserved.
//

#import "BaseRequest.h"

@interface LoginRequest : BaseRequest

+ (void)getSmsCodeByPhoneNum:(NSString *)phoneNumber WithState:(void(^)(int a))block;

+ (void)loginWithMobile:(NSString *)phoneNumber andSmsCode:(NSString*)smsCode WithState:(void(^)(int a))block;

+ (void)loginWithMobile:(NSString *)phoneNumber andSmsCode:(NSString*)smsCode AndAuthType:(NSString *)type withId:(NSString *)theId WithState:(void (^)(int a))block;


+ (void)justifyVersionWithCode:(NSNumber*)code WithReturnKey:(void (^)(int, NSDictionary *))block;

@end
