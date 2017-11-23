//
//  HTTPErrorAlert.h
//  Project61
//
//  Created by hzpnc on 15/7/9.
//  Copyright (c) 2015年 hzpnc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HttpCode.h"

typedef void(^ErrorHandleCallback)(int error);

@protocol UnhandleableErrorhandler <NSObject>

- (void)handleError:(int)error;

@end

@interface HTTPErrorAlert : NSObject

@property(copy) ErrorHandleCallback callback;

- (void)handleError:(int) error;

- (void)handleError:(int)error andData:(id)data;

+ (void)handleError:(int)error andData:(id)data;

+ (void)handleError:(int)error;

+ (void)handleError:(int)error withCallback:(ErrorHandleCallback)callback;

+ (void)setUnhandleableErrorHandler:(id<UnhandleableErrorhandler>)handler;

@end
