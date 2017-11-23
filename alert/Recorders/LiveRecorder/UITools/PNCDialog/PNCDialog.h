//
//  PNCDialog.h
//  Project61
//
//  Created by hzpnc on 15/7/8.
//  Copyright (c) 2015年 hzpnc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PNCDialog;

typedef void(^PNCDialogButtonTapEvent)(PNCDialog* dialog, int buttonIndex);

@interface PNCDialog : UIView

@property (nonatomic, strong) UIView*   contentView;

@property BOOL      hideWhenTouchUpOutside;

//显示对话框
- (void)show;

//隐藏对话框
- (void)hide;
//.s后自动隐藏
- (void)hideWithinSecond:(CGFloat)seconds after:(CGFloat)scs;

@end
