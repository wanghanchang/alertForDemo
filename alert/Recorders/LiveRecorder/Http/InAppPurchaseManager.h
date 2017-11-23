//
//  InAppPurchaseManager.h
//  LiveRecorder
//
//  Created by 匹诺曹 on 2017/6/30.
//  Copyright © 2017年 匹诺曹. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@protocol RechargeStateDelegate <NSObject>

- (void)isRechargeSuccess:(BOOL)recharged;

@end

@interface InAppPurchaseManager : NSObject <SKProductsRequestDelegate>

@property (nonatomic,assign) NSInteger price;
@property (nonatomic,assign) NSInteger goldCount;
@property (nonatomic,assign) BOOL isHide;
@property (nonatomic,weak) id<RechargeStateDelegate> delegate;

+ (instancetype)sharedManager;

- (void)initTansaction;

-(void)purchaseProductWithIdentifier:(NSString*)identifier;
@end
