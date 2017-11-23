//
//  RecordUploadOrShare.m
//  LiveRecorder
//
//  Created by 匹诺曹 on 17/5/26. 
//  Copyright © 2017年 匹诺曹. All rights reserved.
//

#import "RecordUploadOrShare.h"
#import "HTTPErrorAlert.h"
#import "Base64.h"
@implementation RecordUploadOrShare

+ (void)generateOrdersId:(void (^)(int, NSString *))block {
    [[UpLoadTranslate translate] getOrderIdWithReturnKeyBlock:^(int a, NSString *orderId) {
        if (a == HTTP_OK ) {
            block(a,orderId);
        } else if (a == SESSION_EXPIRED) {
            [BaseRequest SessionExpiredWithReLoginState:^(int a) {
                if (a == HTTP_OK) {
                    [self generateOrdersId:block];
                }
            }];
        }
    }];
}

- (void)checkUserNetTouploadWithEntity:(EntityLiveRecord *)recordEntity withState:(UploadBlock)block WithUserCancel:(void (^)(BOOL))cancel {
    AFNetworkReachabilityManager *mgr = [AFNetworkReachabilityManager sharedManager];
    if (mgr.networkReachabilityStatus == AFNetworkReachabilityStatusReachableViaWWAN || mgr.networkReachabilityStatus == AFNetworkReachabilityStatusUnknown) {
        
        float MB =   recordEntity.fileLength / 1024.0 / 1024.0 ;
        NSString *str = [NSString stringWithFormat:@"当前为移动网络，建议连接WLAN网络后上传(本次上传消耗约%.2fMB流量)",MB];
        [[PNCAlertDialog forceAlertWithTitle:@"提示" andMessage:str containsButtonTitles:@[@"继续上传",@"取消"] buttonTapEventsBlock:^(PNCDialog *dialog, int buttonIndex) {
            if (buttonIndex == 0) {
                [self uploadWithEntity:recordEntity withState:block];
            } else {
                cancel(YES);
            }
            [dialog hide];
        }] show];
    } else if (mgr.networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable) {
        [HTTPErrorAlert handleError:NO_NET];
        cancel(YES);
    } else {
        [self uploadWithEntity:recordEntity withState:block];
    }

}

- (void)uploadWithEntity:(EntityLiveRecord *)recordEntity withState:(UploadBlock)block {
    //如果有fileId 并且已经上传完  直接分享;
    //如果文件已经被删除 那么从新上传
    
        NSString *k = [CommonUtils generateKey];
        NSString *key = [k substringToIndex:16];
        NSString *iv = [k substringFromIndex:16];
        [[UpLoadTranslate translate] getTokenWithReturnKeyBlock:^(int a, UpLoadEntity *entity) {
            if (a == HTTP_OK) {
                if (recordEntity.fileId == nil || [recordEntity.fileId trimAll].length == 0) {
                    recordEntity.fileId = entity.fileId;
                    [[LiveRecordHelper helper] updateEntity:recordEntity forEntityId:recordEntity.entityId];
                }
                NSString *qiniuToken = [[NSString alloc] init];
                if (entity.encrypt == 0) {
                    //不加密
                    qiniuToken = entity.uploadToken;
                }
                if (entity.encrypt == 1) {
                    qiniuToken = [NSString descryptAES:entity.uploadToken key:key withIV:iv];
                }
                if (entity.encrypt == 2) {
                    qiniuToken = [entity.uploadToken authCodeDecoded:k encoding:NSUTF8StringEncoding];
                }
                
                [self uploodQiNiu:qiniuToken WithFileId:recordEntity.fileId WithEntity:recordEntity withBlock:block];
            } else if (a == SESSION_EXPIRED) {
                [BaseRequest SessionExpiredWithReLoginState:^(int a) {
                    if (a == HTTP_OK) {
                        [self uploadWithEntity:recordEntity withState:block];
                    }
                }];
            }
        }];
}


- (void)uploodQiNiu:(NSString*)qiniuToken WithFileId:(NSString*)fileId WithEntity:(EntityLiveRecord*)recordEntity withBlock:(UploadBlock)block {
    
    [UpLoadTranslate translate].stop = NO;
    [[UpLoadTranslate translate] uploodQiNiu:qiniuToken WithFileId:fileId WithEntity:recordEntity WithState:^(int a) {
        if (a == HTTP_OK) {
            recordEntity.isFinishUplaod = YES;
            [[LiveRecordHelper helper] updateEntity:recordEntity forEntityId:recordEntity.entityId];
            block(Up_done,100);
        }
        if (a == UPLOAD_BAD) {
                [[PNCAlertDialog alertWithTitle:@"提示" andMessage:@"上传失败" containsButtonTitles:@[@"确定"] buttonTapEventsBlock:^(PNCDialog *dialog, int buttonIndex) {
                    if (buttonIndex == 0) {
                        [dialog hide];
                    }
                }] show];
            block(Up_fail,0);
        }
    } withProgressBlock:^(float progress) {
        block(Up_ing,progress);
    }];
}


+ (void)goShareWithEntity:(EntityLiveRecord *)recordEntity WithReturnKey:(void (^)(int, NSString *))block {
    [WechatQQRequest getShareUrlWithFileId:recordEntity.fileId WithStateCode:^(NSString *shareUrl, int a) {
        if (a == HTTP_OK) {
            block(HTTP_OK,shareUrl);
        }
        if (a == FILE_INVALIDATE) {
            recordEntity.fileId = nil;
            recordEntity.isFinishUplaod = NO;
            [[LiveRecordHelper helper] updateEntity:recordEntity forEntityId:recordEntity.entityId];
            block(FILE_INVALIDATE,nil);
        }
    }];
}




@end
