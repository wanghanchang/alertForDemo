//
//  MyInfoRequest.m
//  LiveRecorder
//
//  Created by 匹诺曹 on 2017/7/5.
//  Copyright © 2017年 匹诺曹. All rights reserved.
//

#import "MyInfoRequest.h"

@implementation MyInfoRequest

+ (void)getMyVCInfoWithDark:(BOOL)isDark AndReturnBlock:(void (^)(int, float))block {
    [BaseRequest getNoHUDWithRequsetURL:@"/v1/accounts/personal-center" WithDark:isDark withParameter:nil withSessionId:YES withReturnValueBlock:^(id obj) {
        NSDictionary *dic = (NSDictionary*)obj;
        float balance = [dic[@"balance"] floatValue];
        block(HTTP_OK,balance);
    } withErrorCodeBlock:^(int errorCode) {
        block(errorCode,0);
    } withFailureBlock:^{
    }];
}

+ (void)getMyVCInfoWithProgressBlock:(void (^)(int, float))block {
    [BaseRequest getWithRequsetURL:@"/v1/accounts/personal-center" withParameter:nil withSessionId:YES withReturnValueBlock:^(id obj) {
        NSDictionary *dic = (NSDictionary*)obj;
        float balance = [dic[@"balance"] floatValue];
        block(HTTP_OK,balance);
    } withErrorCodeBlock:^(int errorCode) {
        block(errorCode,0);
    } withFailureBlock:^{
    }];
}


@end
