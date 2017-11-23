//
//  PNCInputDialog.h
//  Project61
//
//  Created by hzpnc on 15/7/8.
//  Copyright (c) 2015年 hzpnc. All rights reserved.
//

#import "PNCDialog.h"

typedef void(^PNCDialogInputOnSubmitBlock)(PNCDialog* dialog, NSString* content, int buttonIndex);


@interface PNCInputDialog : PNCDialog

+ (instancetype)inputWithTitle:(NSString *)title
                       andHint:(NSString *)hint
                 andOriginText:(NSString *)originText
          containsButtonTitles:(NSArray*)buttonTitles
                andCommitBlock:(PNCDialogInputOnSubmitBlock)block;
@end
