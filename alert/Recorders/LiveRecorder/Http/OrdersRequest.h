//
//  OrdersRequest.h
//  LiveRecorder
//
//  Created by 匹诺曹 on 17/5/15.
//  Copyright © 2017年 匹诺曹. All rights reserved.
//

#import "BaseRequest.h"
#import "WXApi.h"
#import "OrdersTableView.h"
#define MAX_COUNT     20

@class OrderEntity;
@class PayTypeEntity;

typedef NS_ENUM(NSInteger,PayType) {
    AliPay = 0,
    WechatPay = 1,
} ;

@interface OrdersRequest : BaseRequest <WXApiDelegate>

+ (instancetype)sharedRequest;


//获取支付类型以及需要的金币信息;
-(void)getPayTypeAndInfoWithOrderId:(NSString*)ordersId WithReturnKeyBlock:(void(^)(int a,PayTypeEntity *entity))block;

//金币充值凭证接口
- (void)getGoldRechargeParametersWithReturnParam:(void(^)(NSString *param,NSString *timestamp))block;
//金币充值接口
- (void)getRechargePayGoldWithGoldNum:(float)gold andReturnKey:(void(^)(int a ,int b))block;
//金币扣费接口
- (void)getPayInfoByGoldWithOrderOrderId:(PayTypeEntity*)entity WithReturnKeyBlock:(void(^)(int a))block;



//提交订单
- (void)getOrderIdByFileId:(NSString*)fileId WithOrdersId:(NSString*)ordersId WithReturnKeyBlock:(void(^)(int a,OrderEntity *entity))block ;
//支付宝
- (void)getPayInfoByAliPayWithOrderId:(NSString*)orderId WithReturnKeyBlock:(void(^)(int a))block;
//微信
- (void)getPayInfoByWechatPayWithOrderId:(NSString*)orderId WithReturnKeyBlock:(void(^)(int a))block;
//拿订单列表
- (void)getUserOrderListWithState:(NSInteger)state WithIndex:(NSInteger)index WithReturn:(void(^)(int a,NSMutableArray *array))block;
//从订单界面到订单详情
- (void)getOrderDetailByOrderId:(NSString*)orderId WithReturnKeyBlock:(void(^)(int a,OrderEntity *entity))block;
//删除订单
- (void)removeOrderByByOrderId:(NSString*)orderId WithReturnKeyBlock:(void(^)(int a))block;

//特殊
- (void)getTranslateStateByFileId:(NSString*)fileId WithReturnBlock:(void(^)(int a,int isTrans, NSString *orderId,NSString *transText))block;

//订单与签名
- (void)getGoldSignWithPackageId:(NSString*)packageId andPayType:(NSString*)type andReturnKey:(void(^)(int code))block;

//判断支付方式
- (void)getIsShowAWPayWithReturnBlock:(void(^)(BOOL isOpenAVPay))block;

@end

@interface OrderEntity : NSObject

@property (nonatomic,copy) NSString *failureTime;
@property (nonatomic,copy) NSString *feeScale;
@property (nonatomic,copy) NSString *fileRectime;
@property (nonatomic,copy) NSString *fileSeconds;
@property (nonatomic,copy) NSString *inTime;
@property (nonatomic,copy) NSString *note;
@property (nonatomic,copy) NSString *price;
@property (nonatomic,assign) DataType state;
@property (nonatomic,copy) NSString *sysOrderId;
@property (nonatomic,copy) NSString *transText;
@property (nonatomic,copy) NSString *transTime;

@end

@interface PayTypeEntity : NSObject
@property (nonatomic,assign) float balance;//余额
@property (nonatomic,assign) BOOL isBalance;
@property (nonatomic,copy) NSString *payType;
@property (nonatomic,copy) NSString *sysOrderId;
@property (nonatomic,copy) NSString *timeStamp;
@end


