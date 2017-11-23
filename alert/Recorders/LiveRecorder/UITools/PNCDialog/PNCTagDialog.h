//
//  PNCTagDialog.h
//  LiveRecorder
//
//  Created by 匹诺曹 on 17/5/8.
//  Copyright © 2017年 匹诺曹. All rights reserved.
//

#import "PNCDialog.h"

typedef void(^PNCDialogTagChooseBlock)(PNCDialog* dialog, NSString* seletedColor,NSString *title,NSInteger buttonIndex);


@interface PNCTagDialog : PNCDialog

+ (instancetype)inputWithTitle:(NSString *)title
            andInitPickedColor:(NSString *)color
                andCommitBlock:(PNCDialogTagChooseBlock)block;

@end
