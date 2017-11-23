//
//  BaseRequest.h
//  LiveRecorder
//
//  Created by 匹诺曹 on 17/4/25.
//  Copyright © 2017年 匹诺曹. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>
#import <AFNetworkActivityIndicatorManager.h>
#import "HttpCode.h"

typedef void (^ReturnValueBlock) (id obj);
typedef void (^ErrorCodeBlock) (int errorCode);
typedef void (^FailureBlock)();
typedef void (^NetWorkBlock)(BOOL netConnetState);

@interface BaseRequest : NSObject

@property (nonatomic,strong) AFHTTPSessionManager *manager;
//整个回传 部分状态码
+ (void)getWithParticularRequsetURL:(NSString *)url
                      withParameter:(NSDictionary *)parameter
                      withSessionId:(BOOL)sid
               withReturnValueBlock:(ReturnValueBlock)block
                 withErrorCodeBlock:(ErrorCodeBlock)errorBlock
                   withFailureBlock:(FailureBlock)failureBlock;

+ (void)getWithRequsetURL:(NSString *)url
            withParameter:(NSDictionary *)parameter
            withSessionId:(BOOL)sid
     withReturnValueBlock:(ReturnValueBlock)block
       withErrorCodeBlock:(ErrorCodeBlock)errorBlock
         withFailureBlock:(FailureBlock)failureBlock;

+ (void)postWithRequsetURL:(NSString *)url
             withParameter:(NSDictionary *)parameter
             withSessionId:(BOOL)sid
      withReturnValueBlock:(ReturnValueBlock)block
        withErrorCodeBlock:(ErrorCodeBlock)errorBlock
          withFailureBlock:(FailureBlock)failureBlock;

+ (void)SessionExpiredWithReLoginState:(void(^)(int a))block;

+ (void)deleteWithRequsetURL:(NSString *)url
               withParameter:(NSDictionary *)parameter
               withSessionId:(BOOL)sid
        withReturnValueBlock:(ReturnValueBlock)block
          withErrorCodeBlock:(ErrorCodeBlock)errorBlock
            withFailureBlock:(FailureBlock)failureBlock;

+ (void)getNoHUDWithRequsetURL:(NSString *)url
                      WithDark:(BOOL)isDark
                 withParameter:(NSDictionary *)parameter
                 withSessionId:(BOOL)sid
          withReturnValueBlock:(ReturnValueBlock)block
            withErrorCodeBlock:(ErrorCodeBlock)errorBlock
              withFailureBlock:(FailureBlock)failureBlock;
@end
