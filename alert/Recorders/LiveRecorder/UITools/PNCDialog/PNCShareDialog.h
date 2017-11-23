//
//  PNCShareDialog.h
//  LiveRecorder
//
//  Created by 匹诺曹 on 17/5/10.
//  Copyright © 2017年 匹诺曹. All rights reserved.
//

#import "PNCDialog.h"

typedef void(^PNCDialogSharePickBlock)(PNCDialog* dialog,NSInteger pickedCount,NSInteger buttonIndex);

typedef NS_ENUM(NSUInteger,Share_Type) {
    Share_Wechat_Friend = 0,
    Share_Wechat_myFriends = 1,
    Share_QQ_Friend = 2,
    Share_QQ_Zone = 3,
    Share_Copy = 4,
};


@interface PNCShareDialog : PNCDialog
+ (instancetype)initWithPickedBlock:(PNCDialogSharePickBlock)block;

@end
