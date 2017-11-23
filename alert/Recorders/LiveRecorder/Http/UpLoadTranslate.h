//
//  UpLoadTranslate.h
//  LiveRecorder
//
//  Created by 匹诺曹 on 17/5/4.
//  Copyright © 2017年 匹诺曹. All rights reserved.
//

#import "BaseRequest.h"
#import "LiveRecordHelper.h"

@class UpLoadEntity;

@interface UpLoadTranslate : BaseRequest

+ (UpLoadTranslate*)translate;

- (void)getTokenWithReturnKeyBlock:(void(^)(int a,UpLoadEntity *entity))block;

- (void)getOrderIdWithReturnKeyBlock:(void(^)(int a,NSString *orderId))block;

- (void)uploodQiNiu:(NSString*)token WithFileId:(NSString*)fileId WithEntity:(EntityLiveRecord*)entity WithState:(void(^)(int a))block withProgressBlock:(void(^)(float progress))progress;

- (void)getShareUrlWithFieldId:(NSString *)fieldId Block:(void (^)(NSString *url,int a))block;

@property (nonatomic,assign) BOOL stop;

@end

@interface UpLoadEntity : NSObject
//加密类型
@property (nonatomic,assign) int encrypt;
@property (nonatomic,copy) NSString *fileId;
@property (nonatomic,copy) NSString *md5;
@property (nonatomic,copy) NSString *uploadToken;
@property (nonatomic,copy) NSString *testInfo;

@end
