//
//  RecordUploadOrShare.h
//  LiveRecorder
//
//  Created by 匹诺曹 on 17/5/26.
//  Copyright © 2017年 匹诺曹. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PNCShareDialog.h"
#import "LiveRecordHelper.h"
#import "NSString+AESSecurity.h"
#import "UpLoadTranslate.h"
#import "NSString+Trim.h"
#import "PNCAlertDialog.h"
#import "OrdersRequest.h"
#import "WechatQQRequest.h"

#import "PNCProgressDialog.h"


//typedef void(^PNCDialogInputOnSubmitBlock)(PNCDialog* dialog, NSString* content, int buttonIndex);

typedef NS_ENUM(NSInteger,UpDateState) {
    Up_fail = -1,
    Up_ing = 0,
    Up_done = 1,
};

typedef void(^UploadBlock)(UpDateState upState, float progress);

@interface RecordUploadOrShare : NSObject

@property (nonatomic,assign) Share_Type share_type;


+ (void)generateOrdersId:(void(^)(int a, NSString *ordersId))block;

- (void)uploadWithEntity:(EntityLiveRecord *)recordEntity withState:(UploadBlock)block;

- (void)checkUserNetTouploadWithEntity:(EntityLiveRecord *)recordEntity withState:(UploadBlock)block WithUserCancel:(void(^)(BOOL isCancel))cancel;

+ (void)goShareWithEntity:(EntityLiveRecord *)recordEntity WithReturnKey:(void(^)(int a,NSString *shareUrl))block ;

@end
