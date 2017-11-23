
//
//  HTTPErrorAlert.m
//  Project61
//
//  Created by hzpnc on 15/7/9.
//  Copyright (c) 2015年 hzpnc. All rights reserved.
//

#import "HTTPErrorAlert.h"

#import "PNCAlertDialog.h"


static id<UnhandleableErrorhandler> staticHandler;

@implementation HTTPErrorAlert

+ (void)setUnhandleableErrorHandler:(id<UnhandleableErrorhandler>)handler {
    staticHandler = handler;
}

- (void)handleError:(int)error {
    [self handleError:error andData:nil];
}

- (void)handleError:(int)error andData:(id)data {
    NSString* message;
    
#ifdef DEBUG
    message = [NSString stringWithFormat:@"发生未知的错误(%d),请稍候重试", error];
#else
    message = @"";
#endif
    if (error == PARAM_BLANK) {
        message = @"参数为空";
    }else if (error == REDIS_FAULT) {
        message = @"redis服务器错误";
    }else if (error == DB_ERROR){
        message = @"Mysql数据库错误";
    } else if (error == NO_NET) {
        message = @"网络异常";
    } else if (error == VERIFY_CODE_INVALIDATE || error == VERIFY_CODE_TOO_FAST) {
        message = @"请输入有效的验证码";
    } else if (error == ERR_IPA) {
        message = @"购买失败";
    }
    if (message.length != 0) {
        [[PNCAlertDialog alertWithTitle:@"提示"
                             andMessage:message
                   containsButtonTitles:@[@"确定"]
                   buttonTapEventsBlock:^(PNCDialog *dialog, int buttonIndex) {
                       if(self.callback) {
                           self.callback(error);
                       }
                       [dialog hide];
                   }] show];
    }
}

+ (void)handleError:(int)error {
    [[[HTTPErrorAlert alloc] init] handleError:error];
}

+ (void)handleError:(int)error andData:(id)data {
    [[[HTTPErrorAlert alloc] init] handleError:error andData:data];
}

+ (void)handleError:(int)error withCallback:(ErrorHandleCallback)callback {
    HTTPErrorAlert* alert = [[HTTPErrorAlert alloc] init];
    alert.callback = callback;
    [alert handleError:error];
}


@end
