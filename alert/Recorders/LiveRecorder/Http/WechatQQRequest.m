//
//  WechatQQRequest.m
//  LiveRecorder
//
//  Created by 匹诺曹 on 17/4/25.
//  Copyright © 2017年 匹诺曹. All rights reserved.
//

#import "WechatQQRequest.h"
#import "AccountInfo.h"
#import "MD5Relevant.h"

static NSString *kLinkURL = @"http://tech.qq.com/zt2012/tmtdecode/252.htm";

@implementation WechatQQRequest


+ (void)getShareUrlWithFileId:(NSString*)fileId WithStateCode:(void (^)(NSString *, int))block {
    NSDictionary *dic = @{@"fileId" : fileId};
 
    [BaseRequest getWithRequsetURL:@"/v1/downloads/share-url" withParameter:dic withSessionId:YES withReturnValueBlock:^(id obj) {
        NSString *url = (NSString *)obj[@"shareUrl"];
        block(url,HTTP_OK);
    } withErrorCodeBlock:^(int errorCode) {
    } withFailureBlock:^{
    }];
}


+ (ShareDestType)getShareType {
    BOOL flag = [[[NSUserDefaults standardUserDefaults] objectForKey:@"sdkSwitchFlag"] boolValue];
    return flag? ShareDestTypeTIM :ShareDestTypeQQ;
}

+ (void)goQQShare:(int)count WithUrl:(NSString *)url {
    QQApiNewsObject *obj = [QQApiNewsObject objectWithURL:[NSURL URLWithString:url] title:@"匹诺曹录音" description:@"现场录音" previewImageURL:nil targetContentType:QQApiURLTargetTypeNews];
    if (count == 2) {
        [obj setCflag:kQQAPICtrlFlagQQShare];
    } else {
        [obj setCflag:kQQAPICtrlFlagQZoneShareOnStart];
    }
    obj.shareDestType = [WechatQQRequest getShareType];
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:obj];
    [QQApiInterface sendReq:req];
}

+ (void)goWechatShare:(int)count WithUrl:(NSString*)url {
    
    NSString *kLinkURL = url;
//    NSString *kLinkTagName = @"PNC_LIVE_RECORD";
    NSString *kLinkTitle = @"匹诺曹录音";
    NSString *kLinkDescription = @"现场录音";
    SendMessageToWXReq *sendReq = [[SendMessageToWXReq alloc] init];
    sendReq.bText = NO;//不使用文本信息
    sendReq.scene = count;//0 = 好友列表 1 = 朋友圈 2 = 收藏
    
    //创建分享内容对象
    WXMediaMessage *urlMessage = [WXMediaMessage message];
    
    urlMessage.title = kLinkTitle;//分享标题
    urlMessage.description = kLinkDescription;//分享描述
    [urlMessage setThumbImage:[UIImage imageNamed:@"testImg"]];//分享图片,使用SDK的setThumbImage方法可压缩图片大小
    
    //创建多媒体对象
    WXWebpageObject *webObj = [WXWebpageObject object];
    webObj.webpageUrl = kLinkURL;//分享链接    
    
    //完成发送对象实例
    urlMessage.mediaObject = webObj;
    sendReq.message = urlMessage;
    
    //发送分享信息
    [WXApi sendReq:sendReq];
}

- (AFHTTPSessionManager *)getAFNManagerConfigInfo {
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer.stringEncoding = NSUTF8StringEncoding;
    manager.requestSerializer.timeoutInterval = 30;
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[@"application/json",
                                                                              @"text/html",
                                                                              @"text/json",
                                                                              @"text/plain",
                                                                              @"text/javascript",
                                                                              @"text/xml",
                                                                              @"image/*"]];
    return manager;
}


- (void)getAuthResult:(BaseResp *)resp WithStateCode:(void (^)(int))block {
    if ([resp isKindOfClass:[SendAuthResp class]]) {
        SendAuthResp *temp = (SendAuthResp *)resp;
        NSString *accessUrlStr = [NSString stringWithFormat:@"%@/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code", WX_BASE_URL, WECHAT_APP_ID, WECHAT_APP_SECRET, temp.code];
        
        self.manager = [self getAFNManagerConfigInfo];
        
        [self.manager GET:accessUrlStr parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSDictionary *accessDict = [NSJSONSerialization JSONObjectWithData:responseObject
                                                                       options:NSJSONReadingAllowFragments
                                                                         error:nil];
            DLog(@"acces = %@",accessDict);
            NSString *accessToken = [accessDict objectForKey:WX_ACCESS_TOKEN];
            NSString *openID = [accessDict objectForKey:WX_OPEN_ID];
            NSString *refreshToken = [accessDict objectForKey:WX_REFRESH_TOKEN];
            
            [[AccountInfo shareInfo] updateMyProfileWithKey:WX_ACCESS_TOKEN andValue:accessToken];
            [[AccountInfo shareInfo] updateMyProfileWithKey:WX_OPEN_ID andValue:openID];
            [[AccountInfo shareInfo] updateMyProfileWithKey:WX_REFRESH_TOKEN andValue:refreshToken];
            
            NSString *userUrlStr = [NSString stringWithFormat:@"%@/userinfo?access_token=%@&openid=%@", WX_BASE_URL, accessToken, openID];
            [self.manager  GET:userUrlStr parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                NSDictionary *accessDict = [NSJSONSerialization JSONObjectWithData:responseObject
                                                                           options:NSJSONReadingAllowFragments
                                                                             error:nil];
                DLog(@"info: = %@",accessDict);
                //存不存账户信息;
                block(0);
                
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                DLog(@"error");
                block(9999);
            }];                
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            DLog(@"error");
            block(9999);
        }];
    }
}

- (void)thirdPathDistinguishByType:(NSString *)type withId:(NSString *)theId WithReturn:(void (^)(WechatQQEntity *))block{
    NSString *url = @"/v1/accounts/tripartite-auth";
    NSDictionary *dic = [NSDictionary dictionary];
    if ([type isEqualToString:@"qq"]) {
        dic = @{@"type" : type,
                @"qqId" : theId };
    } else {
        dic = @{@"type" : type,
                @"wechatId" : theId };
    }
    
    [BaseRequest getWithRequsetURL:url withParameter:dic withSessionId:NO withReturnValueBlock:^(id obj) {

        NSDictionary *dic = (NSDictionary*)obj;
        WechatQQEntity *entity = [[WechatQQEntity alloc] init];
        entity.isBind = [dic[@"isBind"] intValue];
        entity.authType = dic[@"authType"];
        entity.mobile = dic[@"mobile"];
        entity.systemCode = dic[@"systemCode"];
        
        if ([entity.authType isEqualToString:@"qq"]) {
            entity.theId = dic[@"qqId"];
        } else {
            entity.theId = dic[@"wechatId"];
        }
        [[AccountInfo shareInfo] updateMyProfileWithKey:SYSTEM_CODE andValue:entity.systemCode];
        [[AccountInfo shareInfo] updateMyProfileWithKey:MOBILE andValue:entity.mobile];

        block(entity);
    } withErrorCodeBlock:^(int errorCode) {
        
    } withFailureBlock:^{
        
    }];
}

- (void)thirdPathAuthByType:(NSString *)type withMobile:(NSString *)mobile WithKey:(NSString *)key WithReturn:(void (^)(int))block {
    NSString *url = @"/v1/accounts/tripartite-auth";
    NSDictionary *dic = [NSDictionary dictionary];
    if ([type isEqualToString:@"qq"]) {
        dic = @{@"type" : type,
                @"mobile" : mobile,
                @"cipher"  : [MD5Relevant md5:key],
                @"qqId" : [[AccountInfo shareInfo] qq_openId]
                };
    } else {
        dic = @{@"type" : type,
                @"mobile" : mobile,
                @"cipher"   : [MD5Relevant md5:key],
                @"wechatId" : [[AccountInfo shareInfo] wx_open_id]
                };
    }
    [BaseRequest postWithRequsetURL:url withParameter:dic withSessionId:NO withReturnValueBlock:^(id obj) {
        NSDictionary *dic = (NSDictionary*)obj;
        [[AccountInfo shareInfo] svaeMyProfileInfoFromJson:dic];
        [[AccountInfo shareInfo] updateMyProfileWithKey:SYSTEM_CODE andValue:dic[@"systemCode"]];
        block([dic[@"result"] intValue]);
        } withErrorCodeBlock:^(int errorCode) {
    } withFailureBlock:^{
    }];
}
@end

@implementation WechatQQEntity

@end
