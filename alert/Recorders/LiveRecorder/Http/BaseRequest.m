//
//  BaseRequest.m
//  LiveRecorder
//
//  Created by 匹诺曹 on 17/4/25.
//  Copyright © 2017年 匹诺曹. All rights reserved.
//

#import "BaseRequest.h"

#import "HTTPErrorAlert.h"
#import "MD5Relevant.h"
#import "PNCProgressHUD.h"
#import "AppDelegate.h"
#import "PNCAlertDialog.h"


@interface BaseRequest ()


@end
@implementation BaseRequest

//针对一些特殊的 需要返回所有数据的请求,在上一层判断错误码
+ (void)getWithParticularRequsetURL:(NSString *)url
                      withParameter:(NSDictionary *)parameter
                      withSessionId:(BOOL)sid
               withReturnValueBlock:(ReturnValueBlock)block
                 withErrorCodeBlock:(ErrorCodeBlock)errorBlock
                   withFailureBlock:(FailureBlock)failureBlock
{
    [PNCProgressHUD showHUD];    
    NSString *theUrl = [BASE_URL stringByAppendingString:url];
    DLog(@"theUrl = %@\n parameter = %@",theUrl,parameter);
    
    AFHTTPSessionManager *manager = [self getAFNManagerConfigInfo];
    
    if (sid == YES) {
        NSString *sid = [[AccountInfo shareInfo] sessionid];
        if (sid) {
            DLog(@"SID = %@",sid);
            [manager.requestSerializer setValue:sid forHTTPHeaderField:@"sid"];
        }
        else {
            DLog(@"no sid,check your code step");
        }
    }
    [manager GET:theUrl parameters:parameter progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject
                                                            options:NSJSONReadingAllowFragments
                                                              error:nil];
        [PNCProgressHUD hideHUD];        
        DLog(@"result = %@",dic);
        block(dic);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [PNCProgressHUD hideHUD];
        [HTTPErrorAlert handleError:NO_NET];
        failureBlock();
    }];
}

+ (void)getWithRequsetURL:(NSString *)url
            withParameter:(NSDictionary *)parameter
            withSessionId:(BOOL)sid
     withReturnValueBlock:(ReturnValueBlock)block
       withErrorCodeBlock:(ErrorCodeBlock)errorBlock
         withFailureBlock:(FailureBlock)failureBlock
{
    [PNCProgressHUD showHUD];

    NSString *theUrl = [BASE_URL stringByAppendingString:url];
    DLog(@"theUrl = %@\n parameter = %@",theUrl,parameter);
    
    AFHTTPSessionManager *manager = [self getAFNManagerConfigInfo];
    
    if (sid == YES) {
        NSString *sid = [[AccountInfo shareInfo] sessionid];
        if (sid) {
            DLog(@"SID = %@",sid);
            [manager.requestSerializer setValue:sid forHTTPHeaderField:@"sid"];
        }
        else {
            DLog(@"no sid,check your code step");
        }
    }
    [manager GET:theUrl parameters:parameter progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject
                                                                     options:NSJSONReadingAllowFragments
                                                                       error:nil];
        [PNCProgressHUD hideHUD];

        DLog(@"result = %@",dic);
        if ([dic[@"result"] intValue] == HTTP_OK) {
            block(dic);
        } else {
            int errCode = [dic[@"result"] intValue];
            errorBlock(errCode);
            if (errCode == SESSION_EXPIRED) {
            } else if (errCode == ORDER_PAYED) {
                
            } else if (errCode == LOG_OUT_B || errCode == LOG_OUT_A) {
                [self doExit];
            } else {
                [HTTPErrorAlert handleError:[dic[@"result"] intValue]];
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [PNCProgressHUD hideHUD];
        [HTTPErrorAlert handleError:NO_NET];
        failureBlock();
    }];
}

+ (void)doExit {
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    [[PNCAlertDialog forceAlertWithTitle:@"提示" andMessage:@"您已被强制登出" containsButtonTitles:@[@"确定"] buttonTapEventsBlock:^(PNCDialog *dialog, int buttonIndex) {
        if (buttonIndex == 0) {
            [dialog hide];
            [delegate logout];
        }
    }] show];
    
}


+ (void)postWithRequsetURL:(NSString *)url
            withParameter:(NSDictionary *)parameter
            withSessionId:(BOOL)sid
     withReturnValueBlock:(ReturnValueBlock)block
       withErrorCodeBlock:(ErrorCodeBlock)errorBlock
         withFailureBlock:(FailureBlock)failureBlock
{
    [PNCProgressHUD showHUD];

    NSString *theUrl = [BASE_URL stringByAppendingString:url];
    DLog(@"theUrl = %@\n parameter = %@",theUrl,parameter);
    
    AFHTTPSessionManager *manager = [self getAFNManagerConfigInfo];
    
    if (sid == YES) {
        NSString *sid = [[AccountInfo shareInfo] sessionid];
        if (sid) {
            [manager.requestSerializer setValue:sid forHTTPHeaderField:@"sid"];
        }
        else {
            DLog(@"no sid,check your code step");
        }
    }
    [manager POST:theUrl parameters:parameter progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject
                                                            options:NSJSONReadingAllowFragments
                                                              error:nil];
        [PNCProgressHUD hideHUD];

        DLog(@"result = %@",dic);
        if ([dic[@"result"] intValue] == HTTP_OK) {
            block(dic);
        } else {
            int errCode = [dic[@"result"] intValue];
            errorBlock(errCode);
            if (errCode == SESSION_EXPIRED) {
            } else if (errCode == LOG_OUT_B || errCode == LOG_OUT_A) {
                [self doExit];
            } else {
                [HTTPErrorAlert handleError:[dic[@"result"] intValue]];
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [PNCProgressHUD hideHUD];
        [HTTPErrorAlert handleError:NO_NET];
        failureBlock();
    }];
}

+ (void)SessionExpiredWithReLoginState:(void (^)(int))block {
    
    NSString *cipher = [MD5Relevant md5: [CommonUtils generateKey]];
    NSDictionary *param = @{@"cipher": cipher,
                            @"mobile": [[AccountInfo shareInfo] mobile]};
    [BaseRequest postWithRequsetURL:@"/v1/accounts/relogin" withParameter:param withSessionId:NO withReturnValueBlock:^(id obj) {
        NSDictionary *dic = (NSDictionary*)obj;
        [[AccountInfo shareInfo] svaeMyProfileInfoFromJson:dic];
        [[AccountInfo shareInfo] updateMyProfileWithKey:SYSTEM_CODE andValue:dic[@"systemCode"]];
        block(HTTP_OK);
    } withErrorCodeBlock:^(int errorCode) {
        block(errorCode);
        [HTTPErrorAlert handleError:NO_NET];
    } withFailureBlock:^{
    }];
}


+ (AFHTTPSessionManager *)getAFNManagerConfigInfo {
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer.stringEncoding = NSUTF8StringEncoding;
    manager.requestSerializer.timeoutInterval = 15;
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[@"application/json",
                                                                              @"text/html",
                                                                              @"text/json",
                                                                              @"text/plain",
                                                                              @"text/javascript",
                                                                              @"text/xml",
                                                                              @"image/*"]];
    return manager;
}


+ (void)deleteWithRequsetURL:(NSString *)url
            withParameter:(NSDictionary *)parameter
            withSessionId:(BOOL)sid
     withReturnValueBlock:(ReturnValueBlock)block
       withErrorCodeBlock:(ErrorCodeBlock)errorBlock
         withFailureBlock:(FailureBlock)failureBlock
{
    [PNCProgressHUD showHUD];
    
    NSString *theUrl = [BASE_URL stringByAppendingString:url];
    DLog(@"theUrl = %@\n parameter = %@",theUrl,parameter);
    
    AFHTTPSessionManager *manager = [self getAFNManagerConfigInfo];
    
    if (sid == YES) {
        NSString *sid = [[AccountInfo shareInfo] sessionid];
        if (sid) {
            DLog(@"SID = %@",sid);
            [manager.requestSerializer setValue:sid forHTTPHeaderField:@"sid"];
        }
        else {
            DLog(@"no sid,check your code step");
        }
    }
    
    [manager DELETE:theUrl parameters:parameter success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject
                                                            options:NSJSONReadingAllowFragments
                                                              error:nil];
        [PNCProgressHUD hideHUD];
        DLog(@"result = %@",dic);
        if ([dic[@"result"] intValue] == HTTP_OK) {
            block(dic);
        } else {
            int errCode = [dic[@"result"] intValue];
            errorBlock(errCode);
            if (errCode == SESSION_EXPIRED) {
            } else if (errCode == LOG_OUT_B || errCode == LOG_OUT_A) {
                [self doExit];
            } else {
                [HTTPErrorAlert handleError:[dic[@"result"] intValue]];
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [PNCProgressHUD hideHUD];
        [HTTPErrorAlert handleError:NO_NET];
        failureBlock();
    }];
    
}

+ (void)getNoHUDWithRequsetURL:(NSString *)url
                      WithDark:(BOOL)isDark
            withParameter:(NSDictionary *)parameter
            withSessionId:(BOOL)sid
     withReturnValueBlock:(ReturnValueBlock)block
       withErrorCodeBlock:(ErrorCodeBlock)errorBlock
         withFailureBlock:(FailureBlock)failureBlock
{
    NSString *theUrl = [BASE_URL stringByAppendingString:url];
    if (isDark == YES) {
        [PNCProgressHUD showNoHUD];
    }    
    AFHTTPSessionManager *manager = [self getAFNManagerConfigInfo];
    if (sid == YES) {
        NSString *sid = [[AccountInfo shareInfo] sessionid];
        if (sid) {
            [manager.requestSerializer setValue:sid forHTTPHeaderField:@"sid"];
        }
    }
    [manager GET:theUrl parameters:parameter progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject
                                                            options:NSJSONReadingAllowFragments
                                                              error:nil];
        if (isDark == YES) {
            [PNCProgressHUD hideHUD];
        }

        DLog(@"result = %@",dic);
        if ([dic[@"result"] intValue] == HTTP_OK) {
            block(dic);
        } else {
            int errCode = [dic[@"result"] intValue];
            errorBlock(errCode);
            if (errCode == SESSION_EXPIRED) {
            } else if (errCode == LOG_OUT_B || errCode == LOG_OUT_A) {
                [self doExit];
            } else {
                [HTTPErrorAlert handleError:[dic[@"result"] intValue]];
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (isDark == YES) {
            [PNCProgressHUD hideHUD];
        }
        failureBlock();
    }];
}


@end
