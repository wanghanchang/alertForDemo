//
//  MyInfoRequest.h
//  LiveRecorder
//
//  Created by 匹诺曹 on 2017/7/5.
//  Copyright © 2017年 匹诺曹. All rights reserved.
//

#import "BaseRequest.h"

@interface MyInfoRequest : BaseRequest

+ (void)getMyVCInfoWithDark:(BOOL)isDark AndReturnBlock:(void(^)(int a,float balance))block;
+ (void)getMyVCInfoWithProgressBlock:(void(^)(int a,float balance))block;
@end
