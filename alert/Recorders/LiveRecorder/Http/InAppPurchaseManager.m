//
//  InAppPurchaseManager.m
//  LiveRecorder
//
//  Created by 匹诺曹 on 2017/6/30.
//  Copyright © 2017年 匹诺曹. All rights reserved.
//

#import "InAppPurchaseManager.h"
#import "BaseRequest.h"
#import "HTTPErrorAlert.h"
#import "MD5Relevant.h"
#import "Base64.h"
#import "OrdersRequest.h"

static InAppPurchaseManager *purchaseManager=nil;

@implementation InAppPurchaseManager

+(instancetype)sharedManager {
    static dispatch_once_t onceToken; dispatch_once(&onceToken, ^{
        purchaseManager = [[InAppPurchaseManager alloc] init];
    });
    return purchaseManager;
}

- (void)initTansaction {
    [[SKPaymentQueue defaultQueue] addTransactionObserver:(id)self];
}

- (void)dealloc {
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:(id)self];
}

- (void)setPriceAndGoldWithIdentifer:(NSString *)identifier {
    if ([identifier isEqualToString:@"PNC.LiveRecord001"]) {
        self.price = 6;
        self.goldCount = 60;
    } else if ([identifier isEqualToString:@"PNC.LiveRecord002"]) {
        self.price = 18;
        self.goldCount = 180;
    } else if ([identifier isEqualToString:@"PNC.LiveRecord003"]) {
        self.price = 50;
        self.goldCount = 500;
    } else if ([identifier isEqualToString:@"PNC.LiveRecord004"]) {
        self.price = 108;
        self.goldCount = 1080;
    } else {
        DLog(@"error");
    }
}

-(void)purchaseProductWithIdentifier:(NSString*)identifier {
    [PNCProgressHUD showHUD];
    if(![SKPaymentQueue canMakePayments]){
        return;
    }
    if(![identifier hasPrefix:@"PNC.LiveRecord"]){
        return;
    }
    self.isHide = NO;
    [self setPriceAndGoldWithIdentifer:identifier];
    
    NSSet *set = [NSSet setWithObject:identifier];
    //发起购买商品的请求
    SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:set];
    request.delegate= self;
    [request start];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    if(response.products.count==0){
        return;
    }
    NSLog(@"-----------收到产品反馈信息--------------");
    NSArray *myProduct = response.products;
    DLog(@"产品Product ID:%@",response.invalidProductIdentifiers);
    DLog(@"产品付费数量: %d", (int)[myProduct count]);
    SKProduct *product=response.products.lastObject;
    DLog(@"product info");
    DLog(@"SKProduct 描述信息%@", [product description]);
    DLog(@"产品标题 %@" , product.localizedTitle);
    DLog(@"Product id: %@" , product.productIdentifier);
    SKPayment *payment=[SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
    DLog(@"f2");

}


-(void)request:(SKRequest *)request didFailWithError:(NSError*)error{
    [PNCProgressHUD hideHUD];
    [self.delegate isRechargeSuccess:NO];
    [HTTPErrorAlert handleError:ERR_IPA];
    DLog(@"f1");

}

-(void)requestDidFinish:(SKRequest *)request{
    if (self.isHide) {
        [PNCProgressHUD showHUD];
        self.isHide = NO;
    }
    DLog(@"f0");
}

-(void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions{
    if(transactions.count==0 || !transactions){
        return;
    }
    SKPaymentTransaction *transaction=transactions.lastObject;
    switch (transaction.transactionState) {
        case SKPaymentTransactionStatePurchased:{//交易完成
            [self recordTransaction:transaction];
            break;
        }
        case SKPaymentTransactionStateFailed:{//交易失败
            [PNCProgressHUD hideHUD];
            self.isHide = YES;
            [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
            break;
        }
        case SKPaymentTransactionStateRestored://已经购买过该商品
            break;
        case SKPaymentTransactionStatePurchasing: //商品添加进列表
            break;
        default:
            break;
    }
Ø
}

#pragma mark - 请求服务端，记录交易 告诉服务器我买了什么
-(void)recordTransaction:(SKPaymentTransaction *)transaction{
    [PNCProgressHUD hideHUD];

    NSURL *receiptURL=[[NSBundle mainBundle] appStoreReceiptURL];
    NSData *receiptData=[NSData dataWithContentsOfURL:receiptURL];
    if(!receiptData){
        return;
    }
    NSString *receiptString=[receiptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    
    [[OrdersRequest sharedRequest] getGoldRechargeParametersWithReturnParam:^(NSString *param, NSString *timestamp) {
        NSString *md5 = [MD5Relevant md5:[NSString stringWithFormat:@"%@_%@",param,timestamp]];
        NSString *cipher = [md5 authCodeEncoded:[CommonUtils generateKey]];
        NSDictionary *dic = @{@"appleReceipt":receiptString,
                              @"cipher" : cipher,
                              @"count" : INTEGER(self.goldCount),
                              @"price" : INTEGER(self.price),
                              @"parameter" : paramØ
                              };
        [BaseRequest postWithRequsetURL:@"/v1/wallets/apple-checØk" withParameter:dic withSessionId:YES withReturnValueBlock:^(id obj) {
            [self.delegate isRechargeSuccess:YES];
        } withErrorCodeBlock:^(int errorCode) {
            [self.delegate isRechargeSuccess:NO];
        } withFailureBlock:^{
        }];
    }];
    
    //结束交易
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
}




@end
