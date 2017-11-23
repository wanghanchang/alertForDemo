//
//  WechatQQRequest.h
//  LiveRecorder
//
//  Created by 匹诺曹 on 17/4/25.
//  Copyright © 2017年 匹诺曹. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseRequest.h"
#import "WXApi.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>


#define UMENG_APPKEY        @"57c63ade67e58e8435001e82"
#define PNC_TEXT            @"找律师就上匹诺曹，在线答疑，线上办案，伴您起航http://wap.pnc516.com/share/wap.html"
#define PNC_URL             @"http://www.pnc516.com"
#define PNC_DOWNLOAD_URL    @"http://wap.pnc516.com/share/wap.html"
#define WECHAT_APP_ID       @"wx023e99927d74b7db"
#define WECHAT_APP_SECRET   @"65a6a3bd9a10c35aed2985d20bf13784"
//#define SINA_APP_ID         @"2624132152"
//#define SINA_APP_SECRET     @"7ebcca1433db207745b8755abb0e0865"
#define QQ_APP_ID           @"100737223" //scheme需要转为十六进制:60120c7
#define QQ_APP_SECRET       @"07138c3b25944866c6abd013aa8b7b8c"
#define PNC_LAWYER          @"匹诺曹律师——让天下没有难打的官司"


#define WX_BASE_URL @"https://api.weixin.qq.com/sns"

@class WechatQQEntity;

@interface WechatQQRequest : BaseRequest

- (void)getAuthResult:(BaseResp *)resp WithStateCode:(void(^)(int code))block;

- (void)thirdPathDistinguishByType:(NSString *)type withId:(NSString *)theId WithReturn:(void(^)(WechatQQEntity *entity))block;

- (void)thirdPathAuthByType:(NSString *)type withMobile:(NSString *)mobile WithKey:(NSString*)key WithReturn:(void(^)(int a))block;

+ (void)getShareUrlWithFileId:(NSString*)fileId WithStateCode:(void(^)(NSString *shareUrl,int a))block;

+ (void)goWechatShare:(int)count WithUrl:(NSString*)url;

+ (void)goQQShare:(int)count WithUrl:(NSString*)url;

@end

@interface WechatQQEntity : NSObject

@property (nonatomic,strong) NSString *authType;
@property (nonatomic,assign) int isBind;
@property (nonatomic,strong) NSString *mobile;
@property (nonatomic,strong) NSString *theId;
@property (nonatomic,strong) NSString *systemCode;

@end
