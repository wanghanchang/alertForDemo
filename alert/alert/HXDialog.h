//
//  HXDialog.h
//  alert
//
//  Created by 匹诺曹 on 2017/11/12.
//  Copyright © 2017年 匹诺曹. All rights reserved.
//

#import <UIKit/UIKit.h>


@class HXDialog;

typedef void(^PNCDialogButtonTapEvent)(HXDialog* dialog, int buttonIndex);

@interface HXDialog : UIView

@property (nonatomic, strong) UIView*   contentView;

@property BOOL      hideWhenTouchUpOutside;

//显示对话框
- (void)show;

//隐藏对话框
- (void)hide;
//.s后自动隐藏
- (void)hideWithinSecond:(CGFloat)seconds after:(CGFloat)scs;


@end
