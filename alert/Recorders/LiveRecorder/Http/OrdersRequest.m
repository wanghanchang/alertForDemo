//
//  OrdersRequest.m
//  LiveRecorder
//
//  Created by 匹诺曹 on 17/5/15.
//  Copyright © 2017年 匹诺曹. All rights reserved.
//

#import "OrdersRequest.h"
#import <AlipaySDK/AlipaySDK.h>
#import "HTTPErrorAlert.h"
#import "MD5Relevant.h"
#import "Base64.h"

@implementation OrdersRequest

+ (instancetype)sharedRequest {
    static dispatch_once_t onceToken;
    static OrdersRequest *request;
    dispatch_once(&onceToken, ^{
        request = [[OrdersRequest alloc] init];
    });
    return request;
}

- (void)getGoldRechargeParametersWithReturnParam:(void (^)(NSString *, NSString *))block {
    [BaseRequest getWithRequsetURL:@"/v1/wallets/prepare" withParameter:nil withSessionId:YES withReturnValueBlock:^(id obj) {
        NSDictionary *dic = (NSDictionary*)obj;
        block(dic[@"parameter"],dic[@"timestamp"]);
    } withErrorCodeBlock:^(int errorCode) {
    } withFailureBlock:^{
    }];
}


- (void)getPayTypeAndInfoWithOrderId:(NSString *)ordersId WithReturnKeyBlock:(void (^)(int, PayTypeEntity *))block {
    [BaseRequest getWithRequsetURL:@"/v1/orders/check" withParameter:@{@"orderId" : ordersId} withSessionId:YES withReturnValueBlock:^(id obj) {
        NSDictionary *dic = (NSDictionary*)obj;
        PayTypeEntity *entity = [[PayTypeEntity alloc] init];
        entity.payType = dic[@"payType"];
        entity.isBalance = [dic[@"isBalance"] intValue];
        entity.balance = [dic[@"balance"] floatValue];
        entity.sysOrderId = dic[@"sysOrderId"];
        entity.timeStamp = dic[@"timestamp"];
        block(HTTP_OK,entity);
    } withErrorCodeBlock:^(int errorCode) {
    } withFailureBlock:^{
    }];
}

- (void)getOrderIdByFileId:(NSString *)fileId WithOrdersId:(NSString *)ordersId WithReturnKeyBlock:(void (^)(int, OrderEntity *))block {
    NSDictionary *dic = @{@"fileId" : fileId,
                          @"orderId" : ordersId
                          };
    
    [BaseRequest getWithParticularRequsetURL:@"/v1/orders" withParameter:dic withSessionId:YES withReturnValueBlock:^(id obj) {
        NSDictionary *dic = (NSDictionary*)obj;
        int code = [dic[@"result"] intValue];
        if (code == ORDER_UN_FINISED || code == HTTP_OK) {
            OrderEntity *order = [[OrderEntity alloc] init];
            order.failureTime = dic[@"failureTime"];
            order.feeScale = dic[@"feeScale"];
            order.fileRectime = dic[@"fileRectime"];
            order.fileSeconds = dic[@"fileSeconds"];
            order.inTime = dic[@"inTime"];
            order.price = dic[@"price"];
            order.note = dic[@"note"];
            order.state = [dic[@"state"] intValue];
            order.sysOrderId = dic[@"sysOrderId"];
            order.transText = dic[@"transText"];
            order.transTime = dic[@"transTime"];
            block(code,order);
        } else if (code == FILE_INVALIDATE || code == SESSION_EXPIRED) {
            block(code,nil);
        } else {
            [HTTPErrorAlert handleError:[dic[@"result"] intValue]];
        }
    } withErrorCodeBlock:^(int errorCode) {
    } withFailureBlock:^{
    }];
}

- (void)getPayInfoByGoldWithOrderOrderId:(PayTypeEntity *)entity WithReturnKeyBlock:(void (^)(int))block {
   NSInteger b = entity.isBalance ? 1 : 0;
   NSString *str = [NSString stringWithFormat:@"%.2f_%ld_%@_%@",entity.balance,b,entity.sysOrderId,entity.timeStamp];
   NSString *md5 =  [MD5Relevant md5:str];
   NSString *cipher = [md5 authCodeEncoded:[CommonUtils generateKey]];
    
    
    NSDictionary *param = @{@"orderId" : entity.sysOrderId,
                            @"cipher" : cipher
                            };
    
    [BaseRequest postWithRequsetURL:@"/v1/orders/deduction" withParameter:param withSessionId:YES withReturnValueBlock:^(id obj) {
        block(HTTP_OK);
    } withErrorCodeBlock:^(int errorCode) {
        block(errorCode);
    } withFailureBlock:^{
    }];
}

- (void)getPayInfoByAliPayWithOrderId:(NSString *)orderId WithReturnKeyBlock:(void (^)(int))block {
    NSDictionary *param = @{@"type" : @"alipay",
                            @"orderId" : orderId
                            };
    
    [BaseRequest getWithRequsetURL:@"/v1/orders/sign" withParameter:param withSessionId:YES withReturnValueBlock:^(id obj) {
        NSDictionary *resultDic = (NSDictionary *)obj;
        NSString *appScheme = @"hangzhoupinuocao";
        [[AlipaySDK defaultService] payOrder:resultDic[@"alipaySign"]
                                  fromScheme:appScheme callback:^(NSDictionary *resultDic) {
                                      DLog(@"reslut = %@",resultDic);
                                      if ([[resultDic valueForKey:@"resultStatus"] isEqualToString:@"9000"]) {
                                          DLog(@"支付成功");
                                          block(HTTP_OK);
                                      }else {
                                          block(PAY_BAD);
                                          DLog(@"支付失败");
                                      }
        }];
    } withErrorCodeBlock:^(int errorCode) {
        block(errorCode);
    } withFailureBlock:^{
        if (![[UIApplication sharedApplication] canOpenURL: [NSURL URLWithString:@"alipay:"]]) {
            NSArray *array = [[UIApplication sharedApplication] windows];
            UIWindow* win=[array objectAtIndex:0];
            [win setHidden:YES];
        }

    }];
}

- (void)getPayInfoByWechatPayWithOrderId:(NSString *)orderId WithReturnKeyBlock:(void (^)(int))block {

    NSDictionary *param = @{@"type" : @"wechat",
                            @"orderId" : orderId
                            };
    
    [BaseRequest getWithRequsetURL:@"/v1/orders/sign" withParameter:param withSessionId:YES withReturnValueBlock:^(id obj) {
            NSDictionary *dic = (NSDictionary *)obj[@"wechatSign"];
        
        PayReq *request   = [[PayReq alloc] init];
        request.openID = [dic objectForKey:@"appid"];
        request.partnerId = [dic objectForKey:@"partnerid"];
        request.prepayId= [dic objectForKey:@"prepayid"];
        request.package =[dic objectForKey:@"package"];
        request.nonceStr= [dic objectForKey:@"noncestr"];
        request.timeStamp = [[dic objectForKey:@"timestamp"] intValue];
        request.sign = [dic objectForKey:@"sign"];
        [WXApi sendReq:request];
        block(HTTP_OK);
    } withErrorCodeBlock:^(int errorCode) {
        if (errorCode == SESSION_EXPIRED) {
            [BaseRequest SessionExpiredWithReLoginState:^(int a) {
                if (a == HTTP_OK) {
                    [self getPayInfoByWechatPayWithOrderId:orderId WithReturnKeyBlock:block];
                }
            }];
        }
        block(errorCode);
    } withFailureBlock:^{
    }];
}


- (void)getUserOrderListWithState:(NSInteger)state WithIndex:(NSInteger)index WithReturn:(void (^)(int, NSMutableArray *))block {
    NSDictionary *param = @{@"state" : [NSNumber numberWithInteger:state],
                            @"rows"  : [NSNumber numberWithInteger:MAX_COUNT],
                            @"index" : [NSNumber numberWithInteger:index]
                            };
    [BaseRequest getNoHUDWithRequsetURL:@"/v1/orders/list" WithDark:NO withParameter:param withSessionId:YES withReturnValueBlock:^(id obj) {
        NSDictionary *dataDic = (NSDictionary *)obj;
        NSArray *array = dataDic[@"orders"];
        NSMutableArray *entityArray = [[NSMutableArray alloc] initWithCapacity:30];
        [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            OrderEntity *order = [[OrderEntity alloc] init];
            order.fileRectime = obj[@"fileRectime"];
            order.fileSeconds = obj[@"fileSeconds"];
            order.inTime = obj[@"inTime"];
            order.price = obj[@"price"];
            order.state = [obj[@"state"] intValue];
            order.sysOrderId = obj[@"sysOrderId"];
            [entityArray addObject:order];
        }];
        block(HTTP_OK,entityArray);
    } withErrorCodeBlock:^(int errorCode) {
        block(errorCode,nil);
    } withFailureBlock:^{
        block(NO_NET,nil);
    }];
}

- (void)getOrderDetailByOrderId:(NSString*)orderId WithReturnKeyBlock:(void(^)(int a,OrderEntity *entity))block {

    NSDictionary *param = @{@"orderId" : orderId};
    
    [BaseRequest getWithRequsetURL:@"/v1/orders/detail" withParameter:param withSessionId:YES withReturnValueBlock:^(id obj) {
        NSDictionary *dic = (NSDictionary*)obj;
            OrderEntity *order = [[OrderEntity alloc] init];
            order.failureTime = dic[@"failureTime"];
            order.feeScale = dic[@"feeScale"];
            order.fileRectime = dic[@"fileRectime"];
            order.fileSeconds = dic[@"fileSeconds"];
            order.inTime = dic[@"inTime"];
            order.price = dic[@"price"];
            order.note = dic[@"note"];
            order.state = [dic[@"state"] intValue];
            order.sysOrderId = dic[@"sysOrderId"];
            order.transText = dic[@"transText"];
            order.transTime = dic[@"transTime"];
            block(HTTP_OK,order);
    } withErrorCodeBlock:^(int errorCode) {
        block(errorCode,nil);
    } withFailureBlock:^{
    }];
}

- (void)removeOrderByByOrderId:(NSString *)orderId WithReturnKeyBlock:(void (^)(int))block {
    NSDictionary *param = @{@"orderIds" : orderId};
    [BaseRequest deleteWithRequsetURL:@"/v1/orders" withParameter:param withSessionId:YES withReturnValueBlock:^(id obj) {
        block(HTTP_OK);
    } withErrorCodeBlock:^(int errorCode) {
        block(errorCode);
    } withFailureBlock:^{
        
    }];
}


- (void)getTranslateStateByFileId:(NSString*)fileId WithReturnBlock:(void (^)(int, int, NSString *, NSString *))block{
    NSDictionary *param = @{@"fileId" : fileId};
    
    [BaseRequest getWithRequsetURL:@"/v1/records/detail" withParameter:param withSessionId:YES withReturnValueBlock:^(id obj) {
        NSDictionary *dic = (NSDictionary*)obj;
        block(HTTP_OK,[dic[@"isTrans"] intValue],dic[@"orderId"],dic[@"transText"]);
        
    } withErrorCodeBlock:^(int errorCode) {
    } withFailureBlock:^{
    }];
    
    //        isTrans	是否转写	number	0 否 1是
    //        orderId	订单ID	string	无则空字符 自行判断
    //        result	错误码	number
    //        transText	转写结果	string

}



- (void)getGoldSignWithPackageId:(NSString *)packageId andPayType:(NSString *)type andReturnKey:(void (^)(int))block{
    NSDictionary *param = @{@"packageId" : packageId,
                            @"type" : type
                          };
    [BaseRequest getWithRequsetURL:@"/v1/wallets" withParameter:param withSessionId:YES withReturnValueBlock:^(id obj) {
        NSLog(@"obj = %@",obj);

        if ([param[@"type"] isEqualToString:@"wechat"]) {
            
            NSDictionary *dic = (NSDictionary *)obj[@"wechatSign"];
            
            PayReq *request   = [[PayReq alloc] init];
            request.openID = [dic objectForKey:@"appid"];
            request.partnerId = [dic objectForKey:@"partnerid"];
            request.prepayId= [dic objectForKey:@"prepayid"];
            request.package =[dic objectForKey:@"package"];
            request.nonceStr= [dic objectForKey:@"noncestr"];
            request.timeStamp = [[dic objectForKey:@"timestamp"] intValue];
            request.sign = [dic objectForKey:@"sign"];
            [WXApi sendReq:request];
        } else {
            NSDictionary *resultDic = (NSDictionary *)obj;
            NSString *appScheme = @"hangzhoupinuocao";
            [[AlipaySDK defaultService] payOrder:resultDic[@"alipaySign"]
                                      fromScheme:appScheme callback:^(NSDictionary *resultDic) {
                                          DLog(@"reslut = %@",resultDic);
                                          if ([[resultDic valueForKey:@"resultStatus"] isEqualToString:@"9000"]) {
                                              DLog(@"支付成功");
                                              block(HTTP_OK);
                                          }else {
                                              block(PAY_BAD);
                                              DLog(@"支付失败");
                                          }
                                      }];
        }
    } withErrorCodeBlock:^(int errorCode) {
        block(errorCode);
    } withFailureBlock:^{
        if (![[UIApplication sharedApplication] canOpenURL: [NSURL URLWithString:@"alipay:"]]) {
            NSArray *array = [[UIApplication sharedApplication] windows];
            UIWindow* win=[array objectAtIndex:0];
            [win setHidden:YES];
        }
    }];
    
}

- (void)getIsShowAWPayWithReturnBlock:(void (^)(BOOL))block {
    [BaseRequest getWithRequsetURL:@"/v1/settings/pay-config" withParameter:nil withSessionId:NO withReturnValueBlock:^(id obj) {
        BOOL isShowAWPay =   [obj[@"isOpenAWPay"] intValue];
        block(isShowAWPay);
    } withErrorCodeBlock:^(int errorCode) {
        block(errorCode);
    } withFailureBlock:^{
    }];
}
@end

@implementation OrderEntity

@end

@implementation PayTypeEntity

@end

